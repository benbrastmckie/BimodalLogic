# Implementation Plan: Task #972

- **Task**: 972 - Theorem library: tableau pipeline
- **Status**: [NOT STARTED]
- **Effort**: 14.5 hours
- **Dependencies**: `theorem_library_layout_and_registry` (landed), `proof_mode_axiom_audit_and_cost_baseline` (landed)
- **Research Inputs**: specs/972_theorem_library_tableau_pipeline/reports/01_tableau-pipeline-into-library.md
- **Artifacts**: plans/01_tableau-pipeline-into-library.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The five stages of `records/theorem-library.md` (enumerate, decide, extract, certify, admit) are
assembled from machinery that already exists — the enumerator, atom canonicalization, the
decision procedure, proof extraction, `BranchGates`/`evalBranchGates`, `decidableCertifies`, the
registry and the diagnostics schema — plus exactly three genuinely new components: an L-level
uniform substitution **as data** (which the registry's row type forces and which does not exist
in the tree), a substitution-instance matcher for the subsumption test, and a Lean-source emitter
that turns an extracted `DerivationTree` into a generated, human-readable library module. One
driver executable sequences the stages, emits the five reserved-stage diagnostics records, writes
certified refutations in the form the countermodels record will read without admitting them, and
generates the admitted theorem module. The theorem half runs at `Base` only, because proof
extraction is `Base`-only by construction; the countermodel half runs at all four frame classes.

### Research Integration

The report settles the plan's three hardest questions and is the authority for every design
choice below:

- **The missing prerequisite.** `TheoremEntry.proof : ∀ fc, frameClass ≤ fc → ∀ v, DerivationTree
  fc [] (stmt v)` makes every row schematic by construction, while the tableau extracts a
  derivation of a *concrete* formula. The report built the missing L-level mirror of
  `substPlus`/`PlusDerivationTree.ofTMSubst` on a compiled probe, confirmed all five declarations
  elaborate sorry-free, and confirmed `register_theorem` **accepts** the generalized row
  (`#print axioms` → `[propext, Quot.sound]`). Phase 2 lands exactly that construction.
- **Extraction is `Base`-only** (`extractProof` ignores `_fc`; `ProofExtractionResult.success` is
  hard-coded to `DerivationTree .Base`), so the frame-class axis moves only the countermodel
  half. No phase re-runs the theorem half at `Dense`/`ZTime`/`RTime`.
- **The eight gates are implemented and callable.** `BranchGates`/`gatesOfBranch`/
  `evalBranchGates` (`BimodalTools/TableauBridge.lean:307,365,389`) evaluate exactly the eight
  hypotheses of `not_valid_of_hasOpen_int` as `Bool`s with snake_case JSON emission, and the same
  bundle gates all four classes. CERTIFY is a function call, not new work.
- **Two gate collisions**, both mechanically verified by the report: the cost baseline's `SURFACE`
  array includes the *directory* `BimodalLib/Diagnostics` (verified exit 3, "STALE BASELINE"), and
  that directory is the Evaluation lane's territory. Both are resolved at once by siting the stage
  emitters in `BimodalTools/` — the Library lane's own territory per `records/proof-mode.md`.

**Carried-Figure Discipline.** The dispatch's `## Description` carries one measured figure, and it
was re-checked live rather than taken on trust:

| Carried claim | Live check | Verdict |
|---|---|---|
| "at complexity 4 over Base it is 17 valid, 669 invalid, 120 undetermined of 806, `data/bmlogic-c4_metadata.json`" | `jq` over that file: `total_records=806`, `valid_count=17`, `invalid_count=669`, `timeout_count=120`, `frame_class=Base` | **CONFIRMED, unchanged** |
| the same figure read as the *admissible* theorem yield | same file: `decision_method_distribution.structural_prefilter = 15`, so 17 − 15 = **2** valid formulas carry a derivation | **MATERIALLY QUALIFIED.** M19 admits only a valid formula *with an extracted derivation*; the admissible theorem yield at c4 is 2, not 17. This is the report's correction, now independently confirmed from the metadata's own method histogram. |
| `not_valid_of_hasOpen_int` at `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean` | file present; report read it at `:1045` with all eight hypotheses tabulated | **CONFIRMED** |
| "one command … at each frame class the tableau accepts" | `extractProof`'s `_fc` and `ProofExtractionResult.success`'s hard-coded `.Base`, read live | **QUALIFIED**: the theorem half cannot move off `Base`; the frame-class axis is countermodel-only. |

A second figure the description does **not** carry but which a reader may conflate with it:
`data/exhaustive_c4_metadata.json` is a *different* complexity-4 run reporting 13/673/120. Every
figure this plan or its outputs quote must name its artifact.

### Prior Plan Reference

No prior plan. This is artifact round 01 for this task.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap flag was set, so no roadmap
consultation was performed. The task's own milestone anchor is M19, LANE: library, in
`records/proof-mode.md`.

## Goals & Non-Goals

**Goals**:
- `FormalSystem.ProofSystem.substF` — the L-level uniform substitution on `Formula`.
- `FormalSystem.ProofSystem.substF_reflectTime` — the reflection interaction at the shifted substitution.
- `FormalSystem.ProofSystem.Axiom.ofSubst` — every TM axiom instance is one under substitution.
- `FormalSystem.ProofSystem.Axiom.minFrameClass_ofSubst` — substitution preserves the minimum frame class.
- `FormalSystem.ProofSystem.DerivationTree.subst` — the derivation transfer, seven cases.
- `FormalSystem.ProofSystem.DerivationTree.substNil` — the transfer at the empty context, the shape ADMIT uses.
- `BimodalLib.matchSubst?` — the substitution-instance matcher, returning the witness assignment.
- `BimodalLib.isSubstInstance` — the matcher's `Bool` face, which the subsumption test calls.

**Non-Goals**:
- Admitting countermodel entries into `BimodalLib`. Until `theorem_library_countermodels` lands,
  certified refutations are written to a dataset in the form that record will read and are not
  registered.
- Any `⊡` work. `Formula` has no `⊡` constructor, so "cells whose operator set is within `□`" is
  automatic over `Formula` and is not a filter to implement.
- Re-running the theorem half above `Base`.
- Registering one `Conjecture` constant per enumerated formula (see Decisions).
- An interestingness filter on admission. The user ruling is to keep every non-subsumed theorem.
- Editing `records/proof-mode.md`, any file under `FormalSystem/Automation/ProofMode/` or
  `FormalSystem/Theorems/ProofMode/`, or `BimodalLib/Diagnostics/{Record,Size,Emit}.lean`.
- Adding any rule to the proof system.
- The three context-file extensions the report recommends. Those land under `.claude/**`, a
  disposable deploy artifact whose source store lives in another repository; they are recorded as
  follow-ups, not phases here.

## Decisions

1. **The import edge is `BimodalTools → BimodalLib`, not the converse.** Neither direction exists
   today and `B3` gates neither (it bars only `FormalSystem → BimodalTools|BimodalLib`; read live
   at `scripts/check-module-invariants.sh:967-1002`). The driver needs `BimodalLib.profileF` for
   the fragment filter, `BimodalLib.Subsumption` for the subsumption test and
   `BimodalLib.Diagnostics.Record` for the schema. Making the *results* library depend on the
   tooling library would pull the enumerator and dataset machinery into `lake build BimodalLib`,
   which CI runs with `--wfail` as its own step; making the *tooling* library depend on the
   results library's vocabulary is both lighter and directionally correct. The new edge is
   recorded in `lakefile.toml`'s header comment, which currently sanctions only
   `BimodalTools → FormalSystem`.
2. **ADMIT reifies the derivation by emitting Lean source, not by re-running extraction at
   elaboration time.** The alternative — a generated body of the shape
   `(tryAxiomProof φ).get (by rfl)` — would force the kernel to reduce bounded proof search with
   no `native_decide` available, an unmeasured blow-up under `--wfail`. Emitting an explicit term
   costs one printer and keeps the generated library auditable, which is the point of a theorem
   library. Every `DerivationTree` constructor takes `Γ` and `φ` explicitly
   (`FormalSystem/ProofSystem/Derivation.lean:91-165`), so the printer needs no implicit-argument
   reconstruction; the four proof-valued arguments print as `(by decide)` for
   `h_fc : h.minFrameClass ≤ fc` (the report's tactic survey confirms `decide` closes it at a
   concrete `.Base`), `(by simp)` for `h : φ ∈ Γ`, and `List.nil_subset _` for weakening at the
   empty context.
3. **The generalization runs through `DerivationTree.substNil`, not through a source-level atom →
   schema-variable rename of every node.** A textual rename looks cheaper and is wrong at
   `time_reflection`: the node's computed conclusion is `reflectTime (substF σ φ)` while the
   generalized statement is `substF σ (reflectTime φ)`, and those differ whenever `σ` sends an
   atom to a formula carrying a temporal operator. `substF_reflectTime` is exactly the identity
   that repairs it, which is why the transfer recurses at the shifted substitution. An
   implementer who finds the rename "simpler" mid-phase is looking at this trap; per
   `.claude/rules/plan-compliance.md` the route is to raise it, not to substitute it.
4. **Do not route the generalization through the Prop-level L→L⁺ transfer.** The composite
   `plusDerivable_substPlus_nil` + `plusDerivable_ofFormula_iff` lands in
   `Derivable = Nonempty (DerivationTree …)`, a `Prop`, while `TheoremEntry.proof` is
   `Type`-valued and `addTheoremEntry` calls `addAndCompile` on the row.
5. **The stage emitters live in `BimodalTools/`, outside `BimodalLib/Diagnostics/`.** This
   resolves the cost-baseline staleness surface and the lane-territory conflict in one move. The
   schema needs no edit: `Stage` already carries all seven stages and `Stage.reservedKeys`
   already fixes all five reserved payloads. `records/theorem-library.md`'s Layout block, which
   plans `BimodalLib/Diagnostics/` as the emitters' home, is revised in Phase 8 under the task's
   own closing instruction.
6. **The non-admitted outcomes are registered as one aggregate `Conjecture` constant per
   (fragment, frame class, verdict) cell**, with the per-formula fact carried by the ADMIT
   record's own `disposition`/`conjecture_verdict` fields. `BimodalLib/Index.lean:357`'s
   `renderConjectures` keys on one constant per conjecture and `lake exe runLinter BimodalLib`
   requires a docstring on every declaration, so a literal one-constant-per-formula reading means
   ~790 new documented constants at c4 and ~5,900 at c5, each adding an `INDEX.md` row.
7. **`fuelExhausted` and `extractionFailed` stay distinct in the records** and are recorded with
   `DecisionResult`'s own four constructor names, not `FormulaLabel`'s three.
   `extractionFailed` is `isKnownValid` — the tableau closed and the formula *is* valid. Both are
   filed under `ConjectureStatus.undetermined`, whose docstring already covers both, but the
   `decide` and `admit` payloads keep the verdict verbatim.
8. **`Head.statement` for an unregistered enumerated formula uses the dataset `id` convention**
   (`bmlogic-NNNNN`-shaped, assigned by the pipeline), not `unregisteredStatementId`, which
   produces `"unregistered:" ++ declName` and an enumerated formula has no declaration name.
   `Stage.carriesFormulaField` is left as the unexercised obligation
   `docs/reference/diagnostics.md` already describes; no compiled test constrains
   `reservedKeys`' contents beyond non-emptiness, so this route builds.
9. **The ruled bound is the user's, taken as settled** (`.decisions.json`, cycle 4): `Boolean`
   and `ModalBoolean` at complexity 5; `TemporalBoolean` and `ModalTemporalBoolean` at
   complexity 4; `Base` only for the theorem half, all four classes for the countermodel half;
   every non-subsumed theorem kept, no interestingness filter. "Complexity N" means N
   *pattern-aware operator layers* in `Formula.complexity`'s measure, not N primitive nodes —
   every artifact stating a bound must say so.
10. **The fragment filter is `BimodalLib.profileF`, not the depth-budget encoding**, because
    `profileF` is the same function the registry's `profile_eq` closes by `rfl`, so the filter
    agrees with how the row will be filed by construction. `passesFilter`
    (`BimodalTools/FormulaEnumerator.lean:780`) is never applied: it additionally requires
    `complexity ≥ 3` and at least one of `box`/`untl`/`snce`, which deletes the whole `Boolean`
    fragment.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Kernel/elaboration cost of the generated module, or of `assert_proof_fragments_recorded`'s `evalProfile` on the new rows | H | M | Phase 7 builds the generated module scoped (`lake build BimodalLib`) before wiring it into `BimodalLib.lean`, and the yield is single-digit schemata. If `evalProfile` cannot evaluate a row, that row is listed as not-computed and needs a recorded reason like any other — Phase 7 carries `record_proof_fragment` as its named contingency. |
| The subsumption matcher has no verification story; a wrong answer silently drops or duplicates an entry | M | M | It is computable and tested, not kernel-verified, because a wrong answer never admits an *unproved* entry. Phase 3 tests both directions on `RegistryCheckTest.lean`'s fixture pattern, including the repeated-variable agreement case, and Phase 3 also lands a build-time command that fails when any registered row is a substitution instance of another. |
| Wall-clock cost at complexity 5; `evalBranchGates` re-runs `buildTableau` per invalid formula | H | H | Reuse `labelFormulaImpl`'s existing `IO.asTask` + cooperative `abortRef` + adaptive fuel (`min 500 (150 + complexity * 30)`) and the enumerator's checkpoint/resume rather than writing a new driver loop. The fuel landscape is bimodal — formulas resolve at 500 or not at all — so raising fuel is not a mitigation. Phase 1 measures the gate pass rate and marginal gating cost on a single uncontended, sampled run before Phase 6 fixes the command's defaults. |
| The report's own cost probe was contaminated by self-contention (two concurrent elaborations, ~25 min upper bound, no usable figure) | M | M | Phase 1 takes the measurement once, under the shared `.lake/build-guard.lock`, with the PID captured before any relaunch and one waiter per log per `context/patterns/bounded-build-waiter.md`. No elapsed time from the research probe is carried forward as a figure. |
| `typst/generated/status.typ` drift blocks the commit of any phase staging a `.lean` path | M | H | `scripts/typst-status-counts.sh:202-207` counts `FormalSystem/`, `Tests/` and `BimodalTools/` lines but **not** `BimodalLib/`. Every phase touching the first three regenerates `status.typ` with `scripts/typst-sync-check.sh --fix` in that same phase and carries the file in its own `Files to modify`; a `BimodalLib`-only phase needs no regeneration (the hook fires and is a no-op). |
| `readme-lint.sh` Check 4's grandfathering is asymmetric | M | H | `scripts/readme-date-baseline.txt` pins `BimodalTools/README.md` (2026-09-27), `FormalSystem/README.md` (2026-10-02) and `FormalSystem/ProofSystem/README.md` (2026-09-21) as `stale`; refreshing any of those stamps permanently un-grandfathers it and turns the gate red. `BimodalLib/README.md` and `BimodalLib/Theorems/README.md` carry **no** baseline row, so a commit touching `BimodalLib/**` makes them stale and they MUST be refreshed. Each phase below states which stamps it touches and which it must leave alone. |
| A new directory under a scanned root with `.lean` files and no `README.md` fails Check 1 (gated) | M | M | Phase 7 creates `BimodalLib/Theorems/Enumerated/README.md` in the same phase as the directory. |
| `BimodalLib/INDEX.md` goes stale; CI runs `library-index.sh --no-build --check` | M | H | Regenerate in the same phase that admits (Phase 7) and declare `(dual := …)` for the polarity pairs the enumeration produces together — the `U(⊥,⊤) → ⊥` / `S(⊥,⊤) → ⊥` pair and the `¬G⊥` / `¬H⊥` pair are time reflections of each other. |
| `C25N` requires every `lean_exe` root to be named `PascalCase(target)Main` | L | H | The target is `theorem_library_pipeline` and the root is therefore `BimodalTools.TheoremLibraryPipelineMain`, fixed at authoring time in Phase 6. |
| `C35` fails if a seeded declaration's recorded line span moves | L | L | No phase edits a file carrying a `scripts/lean-citation-seeds.txt` entry; Phase 2 adds a new file rather than inserting into an existing one. Phase 8's verification runs the check and reports any finding against the pre-task baseline captured in Phase 1. |
| `--wfail` makes every linter category a hard gate, including `unusedVariables` | M | M | Every new declaration is written with all arguments read (the five substitution declarations each consume `σ`); no `set_option` or `nolints.json` row is pre-authorized, and if `unusedArguments` nonetheless fires, the remedy is a hand-inserted ledger row adjacent to a sibling exemption, never `runLinter --update`. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4, 5 | 2 (Phase 4); 1 (Phase 5) |
| 3 | 6 | 2, 3, 4, 5 |
| 4 | 7 | 6 |
| 5 | 8 | 7 |

Phases within the same wave are logically independent. **They are nonetheless executed
sequentially**: Phases 2, 4, 5 and 6 each stage a `.lean` path under `FormalSystem/`,
`BimodalTools/` or `Tests/` and therefore each regenerate `typst/generated/status.typ`, so two of
them running concurrently would race that one file. The wave table records dependency, not a
licence to parallelize across a shared generated surface.

---

### Phase 1: Baseline Pin and the Two Unmeasured Figures [NOT STARTED]

**Goal**: Capture the pre-task state of every gate this plan will later be judged against, and
take the two figures the research report leaves unmeasured — the eight-gate pass rate per
(fragment, frame class) and the marginal cost of gating — on one uncontended, sampled run, so
Phase 6 fixes the command's defaults against a measurement rather than a guess.

**Tasks**:
- [ ] Write the baseline capture to `specs/972_theorem_library_tableau_pipeline/probes/baseline.md`:
      `bash scripts/check-module-invariants.sh --no-build` finding set,
      `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` info/new counts,
      `bash scripts/typst-sync-check.sh --counts-only`,
      `bash scripts/library-index.sh --no-build --check`, and
      `git log -1 --format=%H -- BimodalLib/Diagnostics` against the pin recorded in
      `docs/development/proof-mode-cost-baseline.md`.
- [ ] Re-confirm, in the same file, the four carried figures tabulated under "Research
      Integration" above, naming the artifact each one comes from.
- [ ] Write a probe under `specs/972_theorem_library_tableau_pipeline/probes/` that, for each of
      the four fragments, enumerates at the ruled bound with `enumerateUpToDepth`, deduplicates
      with `deduplicateCanonical`, filters by `BimodalLib.profileF`, and reports the surviving
      count. Report the count only; do not decide yet.
- [ ] Extend the probe to take a **bounded sample** (at most 150 formulas per fragment, selected
      by a fixed stride so the sample is reproducible) through `decideAuto φ .Base`, and record
      the four-way `DecisionResult` split.
- [ ] For the `invalid` members of that sample, call `evalBranchGates` at each of `Base`, `Dense`,
      `ZTime`, `RTime` and record (a) the per-gate `Bool` histogram, (b) the `BranchGates.gated`
      pass rate per (fragment, frame class), and (c) the wall-clock delta between DECIDE alone
      and DECIDE + gate evaluation over the same sample.
- [ ] Run the probe ONCE, under the shared `.lake/build-guard.lock`, detached as a shell-level
      background job with its PID captured before any relaunch, blocked on with the bounded
      single-call idiom of `context/patterns/bounded-build-waiter.md`. If the first launch's
      PID-file write fails, kill the job before relaunching — the research report's own cost
      figure was lost to exactly this double-launch.
- [ ] Record the figures in `probes/baseline.md` and state explicitly which of them are sampled
      rather than exhaustive.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The phase writes only under `specs/**` and runs read-only gates; the
covering check is that `probes/baseline.md` exists with a figure for every row of its own table
and that each sampled figure is labelled sampled.

**Scope Hypothesis**: The surviving per-fragment enumeration counts after canonicalization and the
`profileF` filter are expected to be of the order of the report's measured fragment tabulation
(c5 Boolean 902, c5 ModalBoolean 751, c4 TemporalBoolean 399, c4 ModalTemporalBoolean 140 — all
`Base`, from the report's own tabulation over `data/bmlogic-c{4,5}.jsonl`). The implementer
confirms the live counts from the probe's own output and records any divergence; a divergence is a
finding about the filter, not a reason to change the bound.

**Files to modify**:
- `specs/972_theorem_library_tableau_pipeline/probes/baseline.md` - the captured baselines and the two new figures
- `specs/972_theorem_library_tableau_pipeline/probes/gate-yield-probe.lean` - the sampled enumerate/decide/gate probe

**Verification**:
- `probes/baseline.md` records a value for every gate named in its first task, and the
  `BimodalLib/Diagnostics` pin comparison is stated as match or mismatch.
- The gate pass rate is present for all four frame classes, and the `ZTime` row is consistent
  with `TableauBridge.lean`'s own recorded measurement that `regionLabel` and `temporalWitness`
  come back `false` there (if it is not, that disagreement is recorded as a finding).
- The probe ran exactly once; the log shows one PID and one waiter.

---

### Phase 2: The L-Level Uniform Substitution, as Data [NOT STARTED]

**Goal**: Land the five-declaration mirror of `substPlus`/`PlusDerivationTree.ofTMSubst` at the L
level, in `FormalSystem/ProofSystem/`, so a concrete extracted derivation can be generalized to a
schematic one that `register_theorem` accepts.

**Tasks**:
- [ ] Create `FormalSystem/ProofSystem/Substitution.lean` with the Apache copyright header and a
      module docstring in the shape `FormalSystem/PlusLanguage/Substitution.lean` uses (`## Main
      definitions`, `## Tags`), sited in namespace `FormalSystem.ProofSystem` with
      `open FormalSystem.Syntax`.
- [ ] `substF (σ : Atom → Formula) : Formula → Formula` — structural on the six `Formula`
      constructors, the `atom` arm returning `σ p`.
- [ ] `substCtxF` as an `abbrev` for `List.map (substF σ)`, mirroring `substCtxPlus`.
- [ ] `substF_atom : substF Formula.atom φ = φ` — the identity law, by `induction φ` with the
      `atom` arm closing by `rfl`.
- [ ] `substF_reflectTime (σ) (φ) : substF σ φ.reflectTime = (substF (fun p => (σ p).reflectTime) φ).reflectTime`
      — by `induction φ`; the `atom` arm is
      `(Formula.reflect_time_involution (σ p)).symm`.
- [ ] `Axiom.ofSubst` — 20 arms, each `rfl`-shaped, one per `Axiom` constructor in `Axioms.lean`
      source order; the three parameter-free constructors (`serial_future`,
      `discrete_box_necessity`, `dense_indicator`) map to themselves.
- [ ] `Axiom.minFrameClass_ofSubst` — `cases ax <;> rfl`.
- [ ] `DerivationTree.subst` — seven cases, mirroring `PlusDerivationTree.ofTMSubst` arm for arm:
      `axiom` through `Axiom.ofSubst` with `rw [Axiom.minFrameClass_ofSubst]`; `assumption`
      through `List.mem_map_of_mem`; `modus_ponens`, `necessitation`,
      `temporal_necessitation` structurally; `time_reflection` transported along
      `(substF_reflectTime σ φ).symm ▸ …` with the recursive call at the shifted substitution;
      `weakening` discharging its side condition with `List.mem_map`/`List.mem_map_of_mem`.
- [ ] `DerivationTree.substNil` — the corollary at the empty context.
- [ ] Add the new file to `FormalSystem/ProofSystem/README.md`'s file listing. **Do not touch
      that README's `Last verified` stamp** — it is grandfathered `stale 2026-09-21` in
      `scripts/readme-date-baseline.txt` and refreshing it un-grandfathers it.
- [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`.
- [ ] Regenerate the module-inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`.
- [ ] Regenerate the line-count surface: `bash scripts/typst-sync-check.sh --fix`.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: `Axiom.ofSubst` is expected to need exactly 20 arms (one per `Axiom`
constructor, of which three are parameter-free) and `DerivationTree.subst` exactly 7 (one per
`DerivationTree` constructor). The implementer confirms both counts live against
`FormalSystem/ProofSystem/Axioms.lean`'s `inductive Axiom` and `Derivation.lean`'s
`inductive DerivationTree` before writing the arms, rather than against this line; a constructor
added since this plan was authored is a missing arm, not an overcount.

**Tier Justification**: The phase adds a module to the published library's import closure and
moves three generated surfaces (`FormalSystem.lean`, the inventory blocks,
`typst/generated/status.typ`), so the covering check is the scoped
`lake build FormalSystem.ProofSystem.Substitution` plus `typst-sync-check.sh --counts-only` and
`mk_all --lib FormalSystem --check`; a `full` sweep adds nothing this trio does not already decide.

**Files to modify**:
- `FormalSystem/ProofSystem/Substitution.lean` - new: the five declarations plus `substCtxF` and `substF_atom`
- `FormalSystem.lean` - regenerated by `mk_all --lib FormalSystem`
- `README.md` - regenerated inventory block
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `typst/generated/status.typ` - regenerated `formalsystem-file-count` / `formalsystem-line-count`
- `FormalSystem/ProofSystem/README.md` - file listing only, stamp untouched

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.ProofSystem.Substitution`
  exits 0 with no warning (CI builds `--wfail`, so a warning is a failure).
- The file contains no `sorry`, no `axiom` and no `native_decide`.
- `lake env lean` on a scratch probe reports `#print axioms FormalSystem.ProofSystem.DerivationTree.substNil`
  with no `sorryAx` and no `Classical.choice`.
- `lake exe mk_all --lib FormalSystem --check` exits 0.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` reports no NEW finding against the Phase 1
  baseline; in particular `C26` (no non-trailing underscore in a live `def`/`abbrev` name),
  `C33`, `INV` and `B3` are clean. Pre-existing findings enumerated in that baseline are a
  recorded PASS for this phase.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` reports no new Check 4
  finding.

---

### Phase 3: The Subsumption Matcher, Its Tests, and the Non-Redundancy Command [NOT STARTED]

**Goal**: Land the substitution-instance matcher the ADMIT stage needs, test it in both
directions, and make the registry's non-redundancy a build invariant rather than a property the
pipeline merely tries to maintain.

**Tasks**:
- [ ] Create `BimodalLib/Subsumption.lean` (copyright header, module docstring) with
      `matchSubst? (schema target : Formula) : Option (List (Atom × Formula))` — a structural
      one-pass matcher that binds each atom of `schema` to the corresponding subterm of `target`
      and **fails on disagreement** when an atom recurs, and
      `isSubstInstance (schema target : Formula) : Bool := (matchSubst? schema target).isSome`.
- [ ] Add a meta-level `subsumedBy?` that, given a candidate statement, scans the constants of
      type `TheoremEntry` in scope and returns the first row whose `stmt schemaVar` the candidate
      is a substitution instance of — the same environment-walk shape `BimodalLib/Index.lean`
      already uses.
- [ ] Add the command `assert_no_subsumed_entries`, mirroring `assert_registry_complete`'s
      elaborator shape, which fails when one registered row's statement is a substitution instance
      of another's.
- [ ] Add `import BimodalLib.Subsumption` to `BimodalLib.lean`.
- [ ] Create `Tests/BimodalLibTest/SubsumptionTest.lean` following `RegistryCheckTest.lean`'s
      fixture pattern: positive cases (`□⊥ → ⊥` is an instance of `□A → A`), negative cases
      (`□⊥ → p` is not an instance of `⊥ → A`), the repeated-variable agreement case (`A → A`
      matches `⊥ → ⊥` and does not match `⊥ → p`), and the reflexive case (every schema is an
      instance of itself).
- [ ] Bump the `Last verified` stamp in `BimodalLib/README.md` to the commit date. Neither it nor
      `BimodalLib/Theorems/README.md` carries a `readme-date-baseline.txt` row, so a commit under
      `BimodalLib/**` makes the stamp stale and the gate red unless it is refreshed.
- [ ] Regenerate `typst/generated/status.typ` — this phase stages a `.lean` path under `Tests/`,
      which `tests-line-count` reads.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The covering check is `lake build BimodalLib` plus
`lake build BimodalLibTest` with `--wfail`, which elaborates every `#guard` in the new test file;
nothing here crosses into `FormalSystem`'s closure or any interface another phase consumes
before Phase 6.

**Scope Hypothesis**: The matcher is expected to be a single structural recursion plus an
association-list agreement check, on the order of 60 lines, with no new Mathlib dependency. The
implementer confirms from the landed file's own line count and import list; if the agreement check
needs `DecidableEq Formula` and that instance is absent, that is a finding to record, not grounds
to weaken the agreement check to a shape that admits a non-instance.

**Files to modify**:
- `BimodalLib/Subsumption.lean` - new: the matcher, its Bool face, the environment scan and the build-time assertion
- `BimodalLib.lean` - add the import
- `Tests/BimodalLibTest/SubsumptionTest.lean` - new: the four test classes
- `typst/generated/status.typ` - regenerated `tests-file-count` / `tests-line-count`
- `BimodalLib/README.md` - module listing and refreshed `Last verified` stamp

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib` and
  `-- build BimodalLibTest` both exit 0 with no warning.
- Every test class above is present and its `#guard` passes; the negative cases are asserted as
  `false`, not merely absent.
- `bash scripts/library-index.sh --no-build --check` exits 0 — `Subsumption.lean` registers no
  row, so the index must be unchanged; a drift here means the module accidentally registered
  something.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` reports no new finding, and
  the `BimodalTools/README.md` and `FormalSystem/*/README.md` stamps are byte-identical to their
  pre-phase values.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 4: The Lean-Source Emitter [NOT STARTED]

**Goal**: Turn a runtime `Formula`, `Axiom` instance and `DerivationTree` into Lean source text
that elaborates, so the ADMIT stage can generate an auditable library module instead of
re-running proof search in the kernel.

**Tasks**:
- [ ] Create `BimodalTools/LeanSourceEmit.lean` (copyright header, module docstring).
- [ ] `formulaSource : Formula → String` — the six primitive constructors in fully-explicit
      `Formula.imp`/`Formula.box`/`Formula.untl`/`Formula.snce`/`Formula.bot`/`Formula.atom`
      form, parenthesized unconditionally so the output needs no precedence table. Atoms print
      through an explicit `Atom` constructor call, never through notation.
- [ ] `schemaSource : Nat → String` — the bound schema-variable spelling the generated signature
      uses (`A`, `B`, `C`, … for arity ≤ 26; `v 0`, `v 1`, … above it).
- [ ] `axiomSource : {φ : Formula} → Axiom φ → String` — 20 arms, each printing the constructor
      name from `allAxiomNames`' spelling plus its `Formula` arguments through `formulaSource`;
      the three parameter-free constructors print bare. Assert coverage against
      `BimodalTools.allAxiomNames` in the same module, in the shape
      `BenchmarkAnchorsMain.lean`/`MachineAppendixMain.lean` already use, so an added `Axiom`
      constructor fails here rather than silently printing nothing.
- [ ] `derivationSource : {Γ : Context} → {φ : Formula} → DerivationTree fc Γ φ → String` —
      seven arms. `axiom` prints
      `DerivationTree.axiom [] <φ> (Axiom.<c> <args>) (by decide)`; `assumption` prints its
      membership proof as `(by simp)`; `weakening` at the empty context prints
      `(List.nil_subset _)`; the three unary rules and `modus_ponens` recurse.
- [ ] `entrySource` — the whole generated declaration for one admitted theorem: a docstring, the
      concrete derivation as a `private def`, and the schematic `def` whose body is
      `DerivationTree.substNil` applied to it, closed by `simpa [substF] using …` exactly as the
      research probe's verified shape does, followed by its `register_theorem` line.
- [ ] Add `import BimodalTools.LeanSourceEmit` to `BimodalTools.lean`.
- [ ] Create `Tests/BimodalToolsTest/LeanSourceEmitTest.lean`: a round-trip test that emits the
      source for a hand-built derivation of `□p → p` and for one `modus_ponens`-shaped tree,
      writes it to a temporary module, and elaborates it with `lake env lean`; plus the axiom
      coverage `#guard`.
- [ ] Regenerate `typst/generated/status.typ` (this phase stages paths under `BimodalTools/` and
      `Tests/`).

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: `axiomSource` is expected to need exactly 20 arms and `derivationSource`
exactly 7, matching `BimodalTools.allAxiomNames`' 20 entries and `DerivationTree`'s 7
constructors. The in-module coverage assertion against `allAxiomNames` is what confirms the first
count mechanically; the second is confirmed by the compiler's own exhaustiveness check on the
match, so neither rests on this line.

**Tier Justification**: The covering check is `lake build BimodalToolsTest --wfail` plus the
round-trip test's own `lake env lean` elaboration of the emitted text — the emitter's only
contract is that its output elaborates, and that test decides it directly.

**Files to modify**:
- `BimodalTools/LeanSourceEmit.lean` - new: the four printers plus `entrySource` and the axiom-coverage assertion
- `BimodalTools.lean` - add the import
- `Tests/BimodalToolsTest/LeanSourceEmitTest.lean` - new: the round-trip and coverage tests
- `typst/generated/status.typ` - regenerated `tools-*` and `tests-*` counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalToolsTest` exits
  0 with no warning.
- The round-trip test's emitted module elaborates sorry-free, and `#print axioms` on its
  generalized declaration reports no `sorryAx`.
- The axiom-coverage assertion names all 20 constructors; deleting one arm makes it fail (checked
  once, by inspection of the assertion's own shape, not by actually deleting an arm).
- `BimodalTools/README.md`'s `Last verified` stamp is byte-identical to its pre-phase value — it
  is grandfathered `stale 2026-09-27` and refreshing it would un-grandfather it. The module
  listing may be extended without touching the stamp.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 5: The Five Reserved-Stage Emitters [NOT STARTED]

**Goal**: Emit the enumerate, decide, extract, certify and admit records in the schema
`BimodalLib/Diagnostics/Record.lean` already fixes, sited in `BimodalTools/` so neither the cost
baseline's staleness surface nor the Evaluation lane's territory is touched.

**Tasks**:
- [ ] Create `BimodalTools/PipelineDiagnostics.lean` (copyright header, module docstring that
      names `Stage.reservedKeys` as the payload authority and says why the emitters are not under
      `BimodalLib/Diagnostics/`).
- [ ] One record structure per reserved stage, each with exactly the fields
      `Stage.reservedKeys` lists for it, in that order, plus a `toJson` that emits the shared
      `Head` fields first — `import BimodalLib.Diagnostics.Record` read-only; do not edit it.
- [ ] `decide`'s `verdict` field carries `DecisionResult`'s own four constructor names
      (`valid`, `invalid`, `fuelExhausted`, `extractionFailed`), never `FormulaLabel`'s three.
- [ ] `certify`'s `gates` object is `BranchGates.toJson`'s output verbatim, reusing its
      snake_case keys rather than restating them.
- [ ] `admit`'s `disposition` is a closed vocabulary (`admitted`, `subsumed`, `conjecture`), with
      `subsumed_by` naming the subsuming row and `conjecture_verdict` the verbatim verdict.
- [ ] Head identifiers for an unregistered enumerated formula use the dataset `id` convention per
      Decision 8; admitted entries use the registered declaration's fully-qualified name.
- [ ] Honour the two stamp options the diagnostics reference fixes: `diagnostics.commit` for the
      head's commit, `diagnostics.zeroTimings` for a byte-stable record.
- [ ] Add `import BimodalTools.PipelineDiagnostics` to `BimodalTools.lean`.
- [ ] Create `Tests/BimodalToolsTest/PipelineDiagnosticsTest.lean`: for each of the five stages, a
      `#guard` that the emitted key list equals `Stage.reservedKeys` for that stage prefixed by
      `Head.keys`, and one golden record per stage under `diagnostics.zeroTimings`.
- [ ] Regenerate `typst/generated/status.typ`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The covering check is the per-stage key-equality `#guard` against
`Stage.reservedKeys` under `lake build BimodalToolsTest --wfail` — schema agreement is the whole
contract of this phase, and that guard decides it mechanically.

**Files to modify**:
- `BimodalTools/PipelineDiagnostics.lean` - new: the five record structures and their emitters
- `BimodalTools.lean` - add the import
- `Tests/BimodalToolsTest/PipelineDiagnosticsTest.lean` - new: key-equality and golden-record tests
- `typst/generated/status.typ` - regenerated `tools-*` and `tests-*` counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalToolsTest` exits
  0 with no warning.
- All five key-equality guards pass.
- `git log -1 --format=%H -- BimodalLib/Diagnostics` is unchanged from the Phase 1 baseline, and
  `bash scripts/proof-mode-cost-baseline.sh` does not report `STALE BASELINE` (exit 3) — the
  direct check that this phase's siting decision held.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 6: The Driver, Its Executable Target, and the Named Entry Point [NOT STARTED]

**Goal**: Sequence the five stages into one command that enumerates, decides, extracts,
certifies, decides admission and writes every output, reusing the existing fuel/abort/checkpoint
machinery rather than writing a new driver loop.

**Tasks**:
- [ ] Create `BimodalTools/TheoremPipeline.lean`: the stage driver.
      ENUMERATE calls `enumerateUpToDepth` at the per-fragment bound, then
      `deduplicateCanonical`, then filters by `BimodalLib.profileF`; `passesFilter` is never
      called (Decision 10).
      DECIDE calls `decideAutoAdaptive` reusing `labelFormulaImpl`'s `IO.asTask` + `abortRef` +
      adaptive-fuel shape and the enumerator's checkpoint/resume.
      EXTRACT calls `extractProof` for `valid` and
      `extractCountermodelSimple`/`extractCountermodelBlocked` for `invalid`, carrying the live
      `DerivationTree` in a `ProofPool`-shaped in-process array.
      CERTIFY calls `evalBranchGates` per `invalid` verdict at each requested frame class — and
      re-derives the branch rather than trusting any dataset `invalid` label, because
      `structural_invalid_prefilter` verdicts never had a branch — and `decidableCertifies` for
      the ZTime certificate route.
      ADMIT calls `BimodalLib.isSubstInstance` for self-subsumption among the candidates and
      `BimodalTools.entrySource` for the admitted ones.
- [ ] Create `BimodalTools/TheoremLibraryPipelineMain.lean` — the name is forced by `C25N`
      (`PascalCase(target)Main` for target `theorem_library_pipeline`). CLI: `--fragment`,
      `--max-complexity`, `--frame-class` (repeatable), `--out-module`, `--out-countermodels`,
      `--out-records`, `--checkpoint`, `--deadline-s`, `--json`.
- [ ] Add the `[[lean_exe]]` block for `theorem_library_pipeline` to `lakefile.toml`, and extend
      that file's header comment to record the now-used `BimodalTools → BimodalLib` edge
      alongside the `BimodalTools → FormalSystem` one it already sanctions (Decision 1).
- [ ] Create `scripts/theorem-library-pipeline.sh` as the one named entry point, in the shape
      `scripts/proof-mode-cost-baseline.sh` fixes: the staleness pin read before measuring,
      `flock` on `.lake/build-guard.lock` held to exit with a bounded announced wait, the
      `--json` zeroed-determinism contract, and a `_metadata.json` sidecar beside each dataset.
- [ ] Record the exact command that reproduces a run in the sidecar and in each record's `command`
      head field.
- [ ] Regenerate `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 2, 3, 4, 5

**Verification Tier**: interface

**Tier Justification**: The phase adds a `lean_exe` root to `lakefile.toml`, which `C25`/`C25N`
and `scripts/lake_targets.py` both read, so the covering check is the scoped
`lake build BimodalTools.TheoremLibraryPipelineMain` plus
`check-module-invariants.sh --no-build`'s `C25`/`C25N` arms — a surface no cheaper tier reaches,
since the exe root sits outside both library closures and a plain `lake build` never elaborates it.

**Files to modify**:
- `BimodalTools/TheoremPipeline.lean` - new: the five-stage driver
- `BimodalTools/TheoremLibraryPipelineMain.lean` - new: the executable root and CLI
- `BimodalTools.lean` - add the `TheoremPipeline` import (not the `Main` root)
- `lakefile.toml` - the new `lean_exe` block and the header-comment edge note
- `scripts/theorem-library-pipeline.sh` - new: the named entry point
- `typst/generated/status.typ` - regenerated `tools-*` counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTools.TheoremLibraryPipelineMain`
  exits 0 with no warning.
- `bash scripts/theorem-library-pipeline.sh --help` prints the flag set, and a smoke run at
  `--fragment Boolean --max-complexity 3` completes and writes all three outputs.
- `bash scripts/check-module-invariants.sh --no-build` reports no new finding; `C25`, `C25N` and
  `B3` are clean.
- `python3 scripts/lake_targets.py` lists `theorem_library_pipeline` with root
  `BimodalTools.TheoremLibraryPipelineMain`.
- Two `--json` runs at the same bound are byte-identical.

---

### Phase 7: The End-to-End Run at the Ruled Bound, and Admission [NOT STARTED]

**Goal**: Run the command end to end at the ruled bound, land the generated theorem module so the
admitted entries build, write the certified refutations in the form
`theorem_library_countermodels` will read without admitting them, and leave the stage records with
the command that reproduces them.

**Tasks**:
- [ ] Run `bash scripts/theorem-library-pipeline.sh` at the ruled bound: `Boolean` and
      `ModalBoolean` at complexity 5, `TemporalBoolean` and `ModalTemporalBoolean` at complexity 4;
      `Base` for the theorem half, all four frame classes for the countermodel half. Detach it as
      a shell-level background job with a captured PID and block on it with the bounded
      single-call idiom; use `--checkpoint` so an interrupted run resumes.
- [ ] Write the stage records to `data/theorem-library-pipeline.jsonl` with the sidecar
      `data/theorem-library-pipeline_metadata.json` carrying the `fields` array, mirroring
      `data/proof-mode-diagnostics.jsonl`'s convention.
- [ ] Write the certified refutations to `data/theorem-library-countermodels.jsonl` with its
      sidecar: one record per refuted inference carrying the inference as `Γ ⊭ φ`, the frame
      class, the grade (`gated_tableau` or `certificate`), the model, and the eight gate `Bool`s.
      Nothing here is registered in `BimodalLib`.
- [ ] Create `BimodalLib/Theorems/Enumerated/Base.lean` from the pipeline's emitted source — one
      file, because the theorem half is `Base`-only and the yield is single-digit schemata — with
      the Apache header and a module docstring naming the generating command and the bound.
- [ ] Declare `(dual := …)` for the polarity pairs the enumeration produces together (the
      `U(⊥,⊤) → ⊥` / `S(⊥,⊤) → ⊥` pair and the `¬G⊥` / `¬H⊥` pair are time reflections of each
      other), so the index's "laws with no declared dual" section does not grow.
- [ ] Create `BimodalLib/Theorems/Enumerated/README.md` — a new directory holding `.lean` files
      fails `readme-lint.sh` Check 1, which is gated — with a current `Last verified` stamp.
- [ ] Add `import BimodalLib.Theorems.Enumerated.Base` to `BimodalLib.lean` and to
      `BimodalLib/Theorems/Complete.lean`, so the new rows are covered by
      `assert_registry_complete`'s companion checks and by `assert_proof_fragments_recorded`.
- [ ] Add `assert_no_subsumed_entries` to `BimodalLib/Theorems/Complete.lean`, so non-redundancy
      of the registry becomes a build invariant.
- [ ] If `assert_proof_fragments_recorded` reports a new row whose proof leaves the cell of its
      statement, add a `record_proof_fragment` line next to that registration giving the reason —
      the sanctioned remedy, named here so it is not discovered mid-phase. If `evalProfile`
      cannot evaluate a row, it is listed as not-computed and needs a recorded reason the same way.
- [ ] Register the non-admitted outcomes as one aggregate `Conjecture` constant per (fragment,
      frame class, verdict) cell in `BimodalLib/Conjectures/Enumerated.lean`, each with a
      docstring naming the dataset as the per-formula record (Decision 6), plus its own
      `README.md` listing if a new directory is created.
- [ ] Regenerate `BimodalLib/INDEX.md` with `bash scripts/library-index.sh`.
- [ ] Bump the `Last verified` stamps in `BimodalLib/README.md`, `BimodalLib/Theorems/README.md`
      and `BimodalLib/Conjectures/README.md` to the commit date.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: interface

**Tier Justification**: The phase moves `BimodalLib/INDEX.md`, a generated surface CI checks with
`library-index.sh --no-build --check`, and adds rows that two build-time commands
(`assert_proof_fragments_recorded`, `assert_no_subsumed_entries`) range over; the covering check
is `lake build BimodalLib` + `lake build BimodalLibTest` + `library-index.sh --no-build --check`,
which together decide every surface this phase touches.

**Scope Hypothesis**: After generalization and subsumption, the admitted set is expected to be
roughly eight to ten distinct schemata at the ruled bound (EFQ, identity, T, necessitated
identity, the `□⊥` pair, the unfulfillable-until/since pair, and the `¬G⊥`/`¬H⊥` seriality pair),
on the strength of the report's reading of the 17 complexity-4 valid formulas and the 2-of-17
derivation-bearing ratio. The implementer confirms the actual count from the run's own `admit`
records and records the figure; a larger or smaller set is a finding to report, never a reason to
re-tune the bound, which is the user's ruling.

**Files to modify**:
- `data/theorem-library-pipeline.jsonl` - new: the five stages' records
- `data/theorem-library-pipeline_metadata.json` - new: the sidecar with the `fields` array
- `data/theorem-library-countermodels.jsonl` - new: the certified refutations, not admitted
- `data/theorem-library-countermodels_metadata.json` - new: its sidecar
- `BimodalLib/Theorems/Enumerated/Base.lean` - new: the generated admitted entries and their `register_theorem` lines
- `BimodalLib/Theorems/Enumerated/README.md` - new: required by `readme-lint.sh` Check 1
- `BimodalLib/Conjectures/Enumerated.lean` - new: the aggregate conjecture constants
- `BimodalLib.lean` - add the two imports
- `BimodalLib/Theorems/Complete.lean` - add the import and `assert_no_subsumed_entries`
- `BimodalLib/INDEX.md` - regenerated by `scripts/library-index.sh`
- `BimodalLib/README.md` - listing and refreshed stamp
- `BimodalLib/Theorems/README.md` - listing and refreshed stamp
- `BimodalLib/Conjectures/README.md` - listing and refreshed stamp

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib` exits 0 with
  no warning, so the admitted entries build and both build-time assertions pass.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLibTest` exits 0.
- Every admitted declaration is sorry-free and reports no `sorryAx` under `#print axioms`;
  `BimodalLib/Theorems/Enumerated/Base.lean` contains no `sorry`, no `axiom` and no
  `native_decide`.
- `bash scripts/library-index.sh --no-build --check` exits 0 and the new rows appear under their
  computed fragments.
- Each of the five stages has at least one record in `data/theorem-library-pipeline.jsonl`, each
  record's `command` field reproduces the run, and the `decide` payloads carry all four
  `DecisionResult` names rather than three.
- Every `data/theorem-library-countermodels.jsonl` record carries all eight gate `Bool`s and a
  grade; no countermodel is registered in `BimodalLib`.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` reports no new finding.
- No `.lean` path under `FormalSystem/`, `BimodalTools/` or `Tests/` was staged, so
  `typst/generated/status.typ` needs no regeneration; if any such path was in fact touched,
  `bash scripts/typst-sync-check.sh --fix` runs in this phase.

---

### Phase 8: Revise docs/, Trim the Record, and the Final Gate [NOT STARTED]

**Goal**: Describe what now exists in `docs/`, cut the implemented part from the design record,
and close the orchestration's gate obligation.

**Tasks**:
- [ ] Extend `docs/reference/bimodal-lib.md` with the enumerated-entry directory, the subsumption
      matcher and its build-time assertion, and the aggregate-conjecture convention.
- [ ] Extend `docs/reference/diagnostics.md` with the five now-implemented reserved stages, the
      emitters' siting in `BimodalTools/` and why, and the unregistered-statement identifier
      convention (Decision 8), leaving `Stage.carriesFormulaField` recorded as the unexercised
      obligation it remains.
- [ ] Add the uniform-substitution layer to the appropriate `docs/` reference page, stating that
      the transfer is syntactic and sound over `Formula` because TM is closed under uniform
      substitution while TM⁺ is not.
- [ ] Revise `records/theorem-library.md`: correct the Layout block's `Diagnostics/` line to the
      emitters' actual home, and cut the "Sources and the tableau pipeline" stage list down to
      what remains unimplemented (stages 6 and 7, re-prove and compare). Do **not** edit
      `records/proof-mode.md` or any proof-mode source file.
- [ ] State the theorem-half yield in any new prose as the derivation-bearing count with its
      artifact named, never as the raw `valid` count, and say which complexity measure a bound is
      in (Decision 9).
- [ ] Add `scripts/theorem-library-pipeline.sh` to
      `.claude/docs/reference/utility-scripts-inventory.md`'s equivalent in-repo home if one
      exists under `scripts/README.md`; otherwise list it in `scripts/README.md`.
- [ ] Record as follow-ups, not work: the three context-file extensions the research report
      recommends (they land under a source store in another repository), and
      `theorem_library_countermodels` as the consumer of this task's refutation dataset.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Files to modify**:
- `docs/reference/bimodal-lib.md` - the new directory, matcher and conventions
- `docs/reference/diagnostics.md` - the five implemented stages and their siting
- `records/theorem-library.md` - Layout correction and the stage-list trim
- `scripts/README.md` - the new named entry point

**Verification**:
- Scoped touched-path check: every file this phase modified passes individually —
  `bash scripts/check-module-invariants.sh --no-build` reports no new finding naming any of them
  (`C5`, `C9D`, `C12`, `C13`, `C14`, `C20`, `C31`, `C32`, `C35` are the arms that range over
  `docs/`), and `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` reports no new
  finding.
- No prose states a count that the tree contradicts (`C14`), and every `file.lean:NNN` citation
  added resolves in range (`C20`).
- Under `/orchestrate`, the complete gate set — `bash scripts/verify-all.sh`, the full
  `check-module-invariants.sh`, `library-index.sh --check`, `typst-sync-check.sh` — is
  **explicitly deferred to the orchestration close** (Move 4), which owns the once-per-invocation
  obligation; this phase does not invoke the full battery as its own criterion. A standalone,
  non-orchestrated run of this phase runs that complete set directly instead.
- Any gate finding that is pre-existing and outside this task's file scope is a recorded PASS with
  the finding enumerated against the Phase 1 baseline, per
  `context/project/lean4/patterns/plan-authoring-gate-collisions.md` Condition 4.

---

## Lean Challenge Statements

```lean
import FormalSystem.ProofSystem.Derivation

open FormalSystem.Syntax FormalSystem.ProofSystem

/-- Interpret an L formula in L by replacing each atom `p` with `σ p`. -/
def FormalSystem.ProofSystem.substF (σ : Atom → Formula) : Formula → Formula := sorry

/-- The reflection interaction, at the shifted substitution. -/
theorem FormalSystem.ProofSystem.substF_reflectTime (σ : Atom → Formula) (φ : Formula) :
    substF σ φ.reflectTime = (substF (fun p => (σ p).reflectTime) φ).reflectTime := sorry

/-- Every TM axiom instance is a TM axiom instance under `substF σ`. -/
def FormalSystem.ProofSystem.Axiom.ofSubst (σ : Atom → Formula) : {φ : Formula} → Axiom φ →
    Axiom (substF σ φ) := sorry

/-- Substitution preserves the minimum frame class. -/
theorem FormalSystem.ProofSystem.Axiom.minFrameClass_ofSubst (σ : Atom → Formula) {φ : Formula}
    (ax : Axiom φ) : (Axiom.ofSubst σ ax).minFrameClass = ax.minFrameClass := sorry

/-- The substitution transfer: every TM derivation becomes a TM derivation of the substituted
conclusion over the substituted context, at the same frame class. -/
def FormalSystem.ProofSystem.DerivationTree.subst {fc : FrameClass} (σ : Atom → Formula) :
    {Γ : Context} → {φ : Formula} → DerivationTree fc Γ φ →
      DerivationTree fc (Γ.map (substF σ)) (substF σ φ) := sorry

/-- The transfer at the empty context: the shape the ADMIT stage uses. -/
def FormalSystem.ProofSystem.DerivationTree.substNil {fc : FrameClass} {φ : Formula}
    (σ : Atom → Formula) (d : DerivationTree fc [] φ) :
    DerivationTree fc [] (substF σ φ) := sorry

/-- The witness assignment making `target` a substitution instance of `schema`, or `none`.
Fails on disagreement when an atom of `schema` recurs. -/
def BimodalLib.matchSubst? (schema target : Formula) : Option (List (Atom × Formula)) := sorry

/-- Whether `target` is a substitution instance of `schema`. -/
def BimodalLib.isSubstInstance (schema target : Formula) : Bool := sorry
```

## Testing & Validation

- [ ] `lake build FormalSystem.ProofSystem.Substitution`, `lake build BimodalLib`,
      `lake build BimodalLibTest`, `lake build BimodalToolsTest` and
      `lake build BimodalTools.TheoremLibraryPipelineMain` each exit 0 with no warning.
- [ ] Nothing added under `BimodalLib/` or `FormalSystem/` contains `sorry`, a new `axiom` or
      `native_decide`; `#print axioms` on every admitted entry and on `DerivationTree.substNil`
      reports no `sorryAx` and no `Classical.choice`.
- [ ] The subsumption check is tested in both directions, including the repeated-variable
      agreement case and the reflexive case.
- [ ] `assert_no_subsumed_entries` and `assert_proof_fragments_recorded` both pass with the new
      rows in scope.
- [ ] `scripts/library-index.sh --no-build --check` exits 0.
- [ ] `scripts/typst-sync-check.sh --counts-only` exits 0 after every phase that staged a `.lean`
      path under `FormalSystem/`, `BimodalTools/` or `Tests/`.
- [ ] `scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` reports no new finding, and no
      grandfathered stamp (`BimodalTools/README.md`, `FormalSystem/README.md`,
      `FormalSystem/ProofSystem/README.md`) was refreshed.
- [ ] `scripts/proof-mode-cost-baseline.sh` does not report `STALE BASELINE`.
- [ ] `scripts/check-module-invariants.sh` reports no new finding against the Phase 1 baseline.
- [ ] The command runs end to end at the ruled bound and two `--json` runs are byte-identical.

## Artifacts & Outputs

- `FormalSystem/ProofSystem/Substitution.lean` — the L-level uniform substitution as data.
- `BimodalLib/Subsumption.lean` — the matcher and `assert_no_subsumed_entries`.
- `BimodalLib/Theorems/Enumerated/Base.lean` — the admitted enumerated entries.
- `BimodalLib/Conjectures/Enumerated.lean` — the aggregate conjecture constants.
- `BimodalTools/LeanSourceEmit.lean`, `BimodalTools/PipelineDiagnostics.lean`,
  `BimodalTools/TheoremPipeline.lean`, `BimodalTools/TheoremLibraryPipelineMain.lean`.
- `scripts/theorem-library-pipeline.sh` — the one named entry point.
- `data/theorem-library-pipeline.jsonl` + sidecar — the five stages' records.
- `data/theorem-library-countermodels.jsonl` + sidecar — certified refutations, written in the
  form `theorem_library_countermodels` will read, not admitted.
- Tests: `Tests/BimodalLibTest/SubsumptionTest.lean`,
  `Tests/BimodalToolsTest/LeanSourceEmitTest.lean`,
  `Tests/BimodalToolsTest/PipelineDiagnosticsTest.lean`.
- Revised `docs/reference/bimodal-lib.md`, `docs/reference/diagnostics.md`, and a trimmed
  `records/theorem-library.md`.

## Rollback/Contingency

Every phase is a separate commit, so a failed phase is reverted by dropping its commit without
touching the earlier ones. The two phases that need a named contingency:

- **Phase 2** is the critical path. If `DerivationTree.subst`'s `time_reflection` case will not
  close, the phase is marked `[BLOCKED]` and raised — it must **not** be worked around by a
  source-level atom rename (Decision 3) nor by the Prop-level L→L⁺ route (Decision 4), both of
  which are unsound or non-compiling for reasons already established.
- **Phase 7** depends on a long run. The `--checkpoint` flag makes it resumable, and a partial run
  is a legitimate `[PARTIAL]` outcome: the records and refutations written so far stand, and the
  generated module is landed only once it builds. If the admitted set turns out to be empty at the
  ruled bound, that is a reportable finding about the derivation-bearing yield, and Phase 7 closes
  with the records, the refutation dataset and an empty generated module rather than being
  retried at a different bound — the bound is the user's ruling.

Before any destructive rollback, `bash .claude/scripts/git-snapshot.sh 972`. An ordinary
defensive checkpoint before a long Phase 7 run uses
`bash .claude/scripts/git-snapshot.sh 972 --no-revert` instead.
