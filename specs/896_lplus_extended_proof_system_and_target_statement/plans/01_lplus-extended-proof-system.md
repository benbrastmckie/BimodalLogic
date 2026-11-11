# Implementation Plan: Task #896

- **Task**: 896 - The extended L⁺ proof system (TM⁺ + axiom set + naming rules) with its ZTime soundness, and the completeness targets as stated Props
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: Task 895 (COMPLETED — `FormalSystem/Metalogic/AuxiliaryAtoms.lean` landed), Task 893 (COMPLETED — `lcU` landed in `FormalSystem/PlusLanguage/PlusLCSchema.lean`)
- **Research Inputs**: `specs/896_lplus_extended_proof_system_and_target_statement/reports/01_lplus-extended-proof-system.md` (with its verified-green companion `probes/01_lcextension-skeleton.lean`)
- **Artifacts**: plans/01_lplus-extended-proof-system.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Land one new library module, `FormalSystem/Metalogic/LCExtension.lean`, carrying the extended
L⁺ proof system as a `Prop`-valued theoremhood closure over `PlusDerivable fc []`: a `RuleSet`
flag record, the `ExtDerivation` inductive with its ten constructors (including the three naming
rules gated by their flags and carrying their freshness side conditions), the two LC axiom-set
predicates with their `.ZTime` validity, the soundness theorem `ext_sound_ztime` assembled from
`plus_soundness_ztime`, `clock_irr_sound` and the Auxiliary-Atoms soundness, and the three
completeness targets as stated `Prop` definitions with no proof and no `sorry`. The whole module
text is already verified green under `lean_run_code` in the research dispatch, so this is
transcription plus repo-convention documentation, not derivation. Definition of done: the full
project and the test library both build with zero warnings, five (optionally six) axiom profiles
are pinned by a build-breaking evidence module, the repository's own invariant and ledger gates
are clean for every touched file, and no completeness claim is made anywhere — the three target
Props stay unproved by construction.

### Research Integration

- Every ingredient exists at a known landed signature (the report's Codebase-Patterns table), so
  no search or lemma discovery is scheduled in any phase.
- The two mandatory divergences from the archived task-879 probe are carried into Phase 1's task
  list: `lcU` is library API and must not be redefined, and both naming-rule constructors use the
  landed `aaAnte qa m k a p b₀` encoding, not the archived probe's `List Atom` shape.
- The mirror rule's conclusion is `φ.reflectTime`, matching `aa_reflectTime_sound_ztime` exactly;
  the arbitrary-conclusion form is derived inside the module as an `example` from
  `PlusFormula.reflect_time_involution`.
- Two report judgements were re-derived at plan-authoring time and one of them did not hold; see
  Decisions for the import list (narrowed and compiled) and Risks for the file-scope correction.

### Prior Plan Reference

No prior plan. The archived
`specs/879_lplus_ztime_completeness_tm_plus_lc_programme/probes/01_target-statements.lean` is a
superseded probe, not a prior plan, and is explicitly not the implementation source.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no roadmap phases are scheduled.

## Goals & Non-Goals

**Goals**:
- `RuleSet.none`, `RuleSet.all` -- the two named rule-set instances: every naming rule off, and
  all three on.
- `IsLCAxiom`, `IsLCUAxiom` -- the two axiom-set predicates, over the library `lcN`/`lcU` and
  their `reflectTime` mirrors.
- `isLCAxiom_plusValidZTime`, `isLCUAxiom_plusValidZTime` -- each axiom set is `.ZTime`-valid,
  which is what discharges `ext_sound_ztime`'s `hAx` hypothesis concretely rather than only
  parametrically.
- `ext_sound_ztime` -- **the headline**: `ExtDerivation .ZTime Ax R φ` implies `PlusValidZTime φ`
  whenever `Ax` is `.ZTime`-valid.
- `ext_sound_validIn` -- the class-generic arm, for a rule set with both Auxiliary-Atoms rules
  off, which converts the `fc` parameter from a latent trap into a stated fact.
- `ExtComplete` -- completeness of an extension at `.ZTime`, as a predicate on `(Ax, R)`.
- `LCComplete`, `LCRulesComplete`, `LCURulesComplete` -- the three completeness targets, stated
  and deliberately unproved.
- `ext_sound_lc_ztime`, `ext_sound_lcU_ztime` -- the soundness half of those three targets,
  outright.

**Non-Goals**:
- Proving any of the three completeness targets, or any weakened variant of one. They are
  statements only.
- Modifying `PlusDerivationTree`, `PlusAxiom` or `PlusFormula` (standing ruling). `ExtDerivation`
  sits strictly on top of `PlusDerivable fc []` and touches none of the three.
- Introducing `plusValidIn_box` / `plusValidIn_allFuture` as named library lemmas. The `nec` and
  `tnec` soundness cases are two-line inline arguments (`PlusTruth.box_iff` is `Iff.rfl`), and the
  verified probe discharges them that way.
- Any `sorry`, any new axiom beyond `[propext, Classical.choice, Quot.sound]`, any vacuous
  definition, and any `pinned:C14` theorem-index cell (which would pull
  `scripts/check-module-invariants.sh` into scope for no gain in strength).

## Decisions

- **Three imports, not `import FormalSystem`.** The probe used the blanket import. The landing
  module uses `FormalSystem.Metalogic.AuxiliaryAtoms`,
  `FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness` and
  `FormalSystem.PlusLanguage.PlusReversal`. This exact three-line list was compiled in this
  planning dispatch (`lake env lean` on the Challenge block below: exit 0, `declaration uses
  'sorry'` the only diagnostics), so it is a measured fact, not a guess.
- **`aaBwd` is stated with conclusion `φ.reflectTime`** and premise
  `((aaAnte …).imp φ).reflectTime`, matching `aa_reflectTime_sound_ztime` exactly. Zero soundness
  glue; the arbitrary-conclusion form is derived in-module as an `example`.
- **`hexh`/`hdisj` are recursive `ExtDerivation` premises, not `PlusValidZTime` hypotheses**, so
  `ExtDerivation` carries no semantic hypothesis anywhere. The induction supplies exactly the
  validity the Auxiliary-Atoms soundness theorems want.
- **`ExtDerivation` keeps its `fc` parameter**, because the `tm` base and the `clock` rule are
  genuinely class-generic. The narrow hazard (the two Auxiliary-Atoms rules are `.ZTime`-only) is
  recorded in the module docstring and backed by `ext_sound_validIn`.
- **Axiom profiles are pinned in a `Tests/BimodalTest/` evidence module**, following
  `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean`, because C27 allow-lists a live
  `#print axioms` under `FormalSystem/` only for `FormalSystem/MainResults.lean`. Theorem-index
  rows carry a bare `pcq` Axioms cell plus a "Profiles guarded by …" note, the dependency's own
  precedent.
- **The theorem-index rows go in a new `###` subsection** inserted after the
  `` ### `LC_n` — Reynolds' infinite limit-closure schema `` table and immediately before
  `### Conservativity — TM⁻ over L⁻, TM over TM⁻, TM⁺ over TM` (both headings confirmed present
  at authoring time). These are proof-system and target-statement rows, not naming-rule soundness
  rows, so they do not belong in the naming-rules table.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The declared `file_scope` is six paths short of what the gates force | H | H (already materialised) | The research report judged the three READMEs and `typst/generated/status.typ` "not needed"; verified otherwise at plan time — `.githooks/pre-commit` blocks any commit staging a `.lean` file while `typst/generated/status.typ` is count-stale, and `check-module-invariants.sh`'s `INV` check fails on the generated inventory blocks for `dir=FormalSystem` and `dir=FormalSystem/Metalogic` once a new loose `.lean` file lands. All ten paths are declared in the phase blocks below |
| Transcribing the archived task-879 probe verbatim | H | M | Implement from `probes/01_lcextension-skeleton.lean` only. Phase 1 names both divergences as explicit checklist items |
| C17 flags the three target Props as dead (no proof, no consumer by construction) | M | H | Name all three in the module docstring's `## Main Results` list **and** give each a theorem-index row; each therefore needs its own `Paper: —` doc line for C15's second assertion |
| A `linter.style.show` warning breaks the zero-warning expectation | M | M (observed once in the probe) | Write `change`, never `show`, at the one goal-changing site in the mirror-shape acceptance `example` |
| Task 911 is `planned` and claims `FormalSystem.lean`, the three READMEs and `typst/generated/status.typ` | M | M | Overlap is real and is for the orchestrator's admission gate to serialise, not for this plan to dodge. Within each phase: re-read every shared file immediately before editing, and stage only this task's own hunks (never a directory or glob pathspec) |
| An axiom profile moved since the research dispatch measured it | M | L | Every `#guard_msgs` expected text is re-measured with `#print axioms` in the implementing dispatch. A carried profile is never typed into a guard from the report |
| A red `#guard_msgs` guard is re-baselined to turn the build green | H | L | Prohibited: a moved profile is understood and justified in the same commit as the change that moved it, per the evidence module's own "When one of these guards fires" discipline |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: The module and its two aggregator imports [COMPLETED]

**Goal**: `FormalSystem/Metalogic/LCExtension.lean` exists, carries every declaration named under
Goals, is reachable from both aggregators, and builds with zero warnings.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/LCExtension.lean` with the repo module header: the Apache
      copyright block copied in shape from `FormalSystem/Metalogic/AuxiliaryAtoms.lean`, then the
      three imports exactly as compiled in the Decisions entry above, then a `/-!` module
      docstring.
- [ ] In that docstring: a `## Main Results` list naming `ExtDerivation`, `ext_sound_ztime`,
      `ext_sound_validIn`, `ext_sound_lc_ztime`, `ext_sound_lcU_ztime`, `ExtComplete` and all
      three target Props `LCComplete`, `LCRulesComplete`, `LCURulesComplete` (this is what keeps
      C17 off the three unconsumed Props); a paragraph recording the `fc`-parameter hazard (the
      `clock` rule and the `tm` base are class-generic, the two Auxiliary-Atoms rules are
      `.ZTime`-only, and `ext_sound_validIn` is the stated class-generic arm); and a sentence
      recording that `PlusDerivationTree`, `PlusAxiom` and `PlusFormula` are untouched. Do **not**
      use the words "sorry-free" in `FormalSystem/Metalogic.lean`'s docstring (see Phase 3).
- [ ] Transcribe, in the probe's order: `structure RuleSet` (`clock aaFwd aaBwd : Bool`),
      `RuleSet.none`, `RuleSet.all`, `IsLCAxiom`, `IsLCUAxiom`, `isLCAxiom_plusValidZTime`,
      `isLCUAxiom_plusValidZTime`, `inductive ExtDerivation` (all ten constructors),
      `ext_sound_ztime`, `ext_sound_validIn`, `ExtComplete`, `LCComplete`, `LCRulesComplete`,
      `LCURulesComplete`, `ext_sound_lc_ztime`, `ext_sound_lcU_ztime`.
- [ ] Do **not** redefine `lcU` or `lcN` — both are library API in
      `FormalSystem/PlusLanguage/PlusLCSchema.lean`. Do **not** use the archived task-879 probe's
      `(b₀ : Atom) (Q : List Atom) … (p : Atom → ℕ → Atom)` naming-rule encoding; both `aaFwd` and
      `aaBwd` take the landed `(qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula) (p : ℕ → ℕ → ℕ)
      (b₀ : ℕ)` shape.
- [ ] Add the four `example`s from the probe: the arbitrary-conclusion mirror shape derived via
      `PlusFormula.reflect_time_involution`, and inhabitation of each of `IsLCAxiom` and
      `IsLCUAxiom`. Write `change`, not `show`, at the one goal-changing site.
- [ ] Give every declaration that will carry a theorem-index row in Phase 3 — `ExtDerivation`,
      `isLCAxiom_plusValidZTime`, `isLCUAxiom_plusValidZTime`, `ext_sound_ztime`,
      `ext_sound_validIn`, `ext_sound_lc_ztime`, `ext_sound_lcU_ztime`, `ExtComplete`,
      `LCComplete`, `LCRulesComplete`, `LCURulesComplete` — a `/--` doc comment ending in a
      `Paper: —` line with a one-clause reason, which is what C15's second assertion checks.
- [ ] Append `import FormalSystem.Metalogic.LCExtension` to `FormalSystem/Metalogic.lean`'s import
      block and to `FormalSystem.lean`.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` in the
      same commit as the Lean lines — `.githooks/pre-commit` blocks a `.lean` commit while the
      counts are stale, and `--no-verify` is not an acceptable substitute here.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts (a) that the three-import list above suffices for every
declaration transcribed — measured in this planning dispatch by compiling the Challenge block
with `lake env lean`, exit 0 — and (b) that the module lands at roughly 330-400 lines including
docstrings, a figure **carried from** `reports/01_lplus-extended-proof-system.md`'s "one new
~400-line module" and not independently re-derived. Confirm (a) by building the module; if a
`Unknown identifier` error appears, add the one missing import rather than falling back to
`import FormalSystem`, and record which. Confirm (b) by `wc -l` after the build is green; the
`longFile` baseline is 1500 lines, so neither figure approaches it.

**Tier Justification**: `suite_selection_select` over this phase's paths returns `__FULL_SWEEP__`
— no shell suite maps any of them — so the covering check is the `interface` row's own
changed-module-plus-enumerated-dependents build,
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.LCExtension`
followed by `… -- build FormalSystem`, which is what observes both a break confined to the new
module and a typo in either aggregator's new import line.

**Files to modify**:
- `FormalSystem/Metalogic/LCExtension.lean` - created: copyright header, module docstring, `RuleSet`, the two axiom predicates and their validity lemmas, `ExtDerivation`, both soundness theorems, `ExtComplete`, the three target Props, the two instantiations, four `example`s
- `FormalSystem/Metalogic.lean` - CORRECTION TARGET, confirmed present at authoring time (its import block ends with `import FormalSystem.Metalogic.AuxiliaryAtoms`): one new import line appended to that block. If the block's shape has changed, append in whatever trailing or alphabetical position the file then uses and record the placement in the progress file
- `FormalSystem.lean` - CORRECTION TARGET, confirmed present at authoring time (it already carries `import FormalSystem.Metalogic.AuxiliaryAtoms`): one new import line beside it. If that line has moved, place the new import beside whichever `Metalogic` import the file then carries and record the placement
- `typst/generated/status.typ` - regenerated by `bash scripts/typst-sync-check.sh --fix`, staged with the Lean lines

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.LCExtension` green with zero warnings (the project enables `weak.linter.mathlibStandardSet`; CI builds with `--wfail`, so a lint warning is a CI failure).
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` green — this is what elaborates both aggregators' new import lines.
- `grep -n 'sorry' FormalSystem/Metalogic/LCExtension.lean` returns nothing.
- All fourteen `## Lean Challenge Statements` identifiers are present in the module at the pinned signatures; `RuleSet` and `ExtDerivation` are present too (they are deliberately not Challenge identifiers — see that section's note).
- `.githooks/pre-commit` accepted the commit without `--no-verify`.

---

### Phase 2: The axiom-profile evidence module [NOT STARTED]

**Goal**: every load-bearing declaration's axiom profile is pinned by a build-breaking
`#guard_msgs` block in `Tests/BimodalTest/Metalogic/LCExtensionTest.lean`, wired into the test
library.

**Tasks**:
- [ ] Measure, in this dispatch, `#print axioms` for each of `isLCAxiom_plusValidZTime`,
      `isLCUAxiom_plusValidZTime`, `ext_sound_ztime`, `ext_sound_validIn`, `ext_sound_lc_ztime`
      and `ext_sound_lcU_ztime`, each fully qualified under
      `FormalSystem.Metalogic.LCExtension`. Record the measured text; do **not** type a profile
      from the research report.
- [ ] Create `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` following
      `Tests/BimodalTest/Metalogic/AuxiliaryAtomsTest.lean`: copyright header, a `/-!` docstring
      saying the module is permanent evidence rather than a conventional test, a "When one of
      these guards fires" paragraph (a moved profile is justified in the same commit as the change
      that moved it, never re-baselined to turn a red build green), and a "What this module does
      not pin" paragraph recording that it pins no completeness, decidability or axiomatizability
      claim, because the module under test makes none.
- [ ] Write one `/-- info: … -/` + `#guard_msgs in` + `#print axioms …` block per measured
      declaration, using the measured expected text verbatim.
- [ ] Add `import BimodalTest.Metalogic.LCExtensionTest` to `Tests/BimodalTest.lean` (hand
      maintained, not generated).
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` with
      this phase's Lean lines if the counts moved; if `--fix` rewrites nothing, record the no-op
      rather than reporting a change.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts six pinned profiles, all expected at
`[propext, Classical.choice, Quot.sound]` — the count and the ceiling are both **carried from**
`reports/01_lplus-extended-proof-system.md`, which measured five of the six (`ext_sound_validIn`
was verified green but its profile not reported). Confirm by running `#print axioms` on each of
the six before writing any expected text; if a profile differs from the carried value, the
measured value wins and the divergence is recorded in the progress file.

**Tier Justification**: `suite_selection_select` over this phase's paths returns `__FULL_SWEEP__`
— no shell suite maps any of them — so the covering check is the `local` row's own single-target
build, `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest`,
which is the only thing that can observe a `#guard_msgs` mismatch (the default build target does
not include the test library).

**Files to modify**:
- `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` - created: measured `#guard_msgs`-gated `#print axioms` blocks for six declarations, plus the evidence-module docstring
- `Tests/BimodalTest.lean` - CORRECTION TARGET, confirmed present at authoring time (it carries `import BimodalTest.Metalogic.AuxiliaryAtomsTest` in its `Metalogic` import group): one new import line added to that group. If the group's shape has changed, add the import wherever the file then groups its `Metalogic` tests and record the placement
- `typst/generated/status.typ` - regenerated by `bash scripts/typst-sync-check.sh --fix` if this phase's new test file moved the counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` green with zero warnings.
- Every `#guard_msgs` expected text was populated from a `#print axioms` run in this dispatch; no guard was re-baselined to silence a red build.
- `grep -n 'sorry' Tests/BimodalTest/Metalogic/LCExtensionTest.lean` returns nothing.
- `.githooks/pre-commit` accepted the commit without `--no-verify`.

---

### Phase 3: The ledger, the generated inventory, and the full gate set [NOT STARTED]

**Goal**: the new module is recorded in the repository's per-theorem ledger and its generated
inventory surfaces, and the complete gate set runs green (or with every finding attributed to a
pre-existing baseline rather than to a file this task touched).

**Tasks**:
- [ ] Insert a new `###` subsection in `docs/theorem-index.md` — placed after the
      `` ### `LC_n` — Reynolds' infinite limit-closure schema, and the ω-chain it runs on ``
      table and immediately before `### Conservativity — TM⁻ over L⁻, TM over TM⁻, TM⁺ over TM`
      (both confirmed present at authoring time; if either heading has moved, place the new
      subsection adjacent to whichever LC-schema table then exists and record the placement) —
      with the standard six-column header `| Paper label | Statement | Lean name | File | Frame
      class | Axioms |`.
- [ ] Add one row each for `ExtDerivation`, `ExtComplete`, `LCComplete`, `LCRulesComplete`,
      `LCURulesComplete`, `isLCAxiom_plusValidZTime`, `isLCUAxiom_plusValidZTime`,
      `ext_sound_ztime`, `ext_sound_validIn`, `ext_sound_lc_ztime` and `ext_sound_lcU_ztime`.
      Paper-label cell `—`; Axioms cell a bare `pcq` plus "Profiles guarded by
      `Tests/BimodalTest/Metalogic/LCExtensionTest.lean`" in the Statement cell; **no**
      `pinned:C14` cell anywhere.
- [ ] Each of the three target Props' rows states plainly that the Prop is **stated and
      unproved** — the row is a statement of an open target, never a claim that it holds.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and replace the
      `<!-- TODO: add description -->` cell the generator writes for the new
      `LCExtension.lean` row in `FormalSystem/Metalogic/README.md`'s `filter=non-aggregators`
      loose-row block with a real description, in the register of the neighbouring
      `AuxiliaryAtoms.lean` and `NamingRules.lean` rows: the extended proof system, its ZTime
      soundness, and that the three completeness targets are statements only.
- [ ] Re-read each touched README immediately before staging — task 911 is live on this tree —
      and stage only this task's own hunks, never a directory or glob pathspec. A no-change
      outcome for a given README is expected, not a failure.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
- [ ] Run the complete gate set and record its outcome per the criteria below.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts (a) eleven new theorem-index rows, and (b) that
`--emit-inventory` rewrites blocks in exactly `FormalSystem/Metalogic/README.md`,
`FormalSystem/README.md` and `README.md` and nowhere else — the three registered blocks covering
`dir=FormalSystem/Metalogic` (`rows=loose filter=non-aggregators`), `dir=FormalSystem`
(`rows=loose`) and `dir=FormalSystem` (`rows=totals`), all confirmed present at authoring time by
grepping for `BEGIN GENERATED: inventory`. Confirm (a) by counting the rows actually added, and
(b) by reading the diff `--emit-inventory` produced and staging exactly the files it rewrote; if
it rewrites a fourth file, stage it and record it rather than reverting it.

**Files to modify**:
- `docs/theorem-index.md` - a new `###` subsection with eleven rows, each anchored by the `Paper: —` line Phase 1 placed at its declaration
- `FormalSystem/Metalogic/README.md` - generated inventory block regenerated by `check-module-invariants.sh --emit-inventory`, plus the hand-written description cell for the new `LCExtension.lean` row
- `FormalSystem/README.md` - generated inventory block regenerated by the same run, if that run touches it
- `README.md` - generated `rows=totals` inventory block regenerated by the same run, if that run touches it
- `typst/generated/status.typ` - regenerated by `bash scripts/typst-sync-check.sh --fix`
- `FormalSystem/Metalogic/LCExtension.lean` - touched only if C15's second assertion reports a row whose declaration lacks its `Paper:` line; add the missing line rather than dropping the row

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, unscoped) green with zero warnings, **and** `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` green — the default target does not include the test library.
- `bash .claude/scripts/verify-deploy.sh` — the agent-system deploy gate set — is run and its outcome recorded, checking the command's exit status rather than only a diff of its stdout. This repository's deployed `.claude/` tree is already stale for the core, lean, literature, memory and typst extensions (see this dispatch's deploy-freshness context), so findings there are pre-existing baseline: the criterion is that no finding names a file this task touched, and any pre-existing finding is enumerated rather than reported as a bare pass or fail.
- The repository's own gate set runs, each through its own `scripts/` entry point with its exit status recorded, and each finding stated as a touched-file scope or a baseline delta rather than an absolute repo-wide zero: `bash scripts/check-module-invariants.sh` (C8, C15 both assertions, C17, C27, and `FAIL INV` on the generated inventory blocks), `bash scripts/typst-sync-check.sh`, `bash scripts/check-metalogic-cycles.sh`, `bash scripts/check-copyright-headers.sh`, `bash scripts/check-paper-definitions.sh`, `bash scripts/check-phantom-citations.sh`, `bash scripts/check-evidence-probes.sh`, `bash scripts/readme-lint.sh`.
- `check-metalogic-cycles.sh` assertions A and B are unchanged: `LCExtension.lean` is a loose file directly under `Metalogic/`, so it contributes no directory-level edge as a source, and its three imports introduce no new upward edge.
- C17 reports no dead declaration for `LCComplete`, `LCRulesComplete` or `LCURulesComplete` — each is named in the module docstring's `## Main Results` list and carries a theorem-index row.
- C27 reports no live `#print axioms` under `FormalSystem/`: every profile pin lives in `Tests/BimodalTest/Metalogic/LCExtensionTest.lean`.
- `grep -rn 'sorry' FormalSystem/Metalogic/LCExtension.lean Tests/BimodalTest/Metalogic/LCExtensionTest.lean` returns nothing, and no `def X := True`-shaped vacuous declaration exists in either file.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 896 .` is run and its verdict recorded. Per `rules/plan-compliance.md` that verdict is **ADVISORY ONLY**: a drift finding is a signal to investigate, never grounds to fail the phase on its own. If no manifest exists for this task the expected outcome is `ERROR: no manifest found … exit 71`; record that as the verdict and do **not** run the script without `--check` afterwards, which would pin the implementation rather than the contract.
- `.githooks/pre-commit` accepted every Lean-touching commit without `--no-verify`.

---

## Lean Challenge Statements

The block below **type-checks against the live library as written**: it was compiled in this
planning dispatch with `lake env lean`, exit 0, with `declaration uses 'sorry'` as the only
diagnostics. Following the task-894 and task-895 precedent, the `def`s carry real bodies rather
than `sorry`, because the shape of each definition is itself part of this task's contract; every
theorem body is `sorry`.

**Two declarations here are deliberately not Challenge identifiers.** `structure RuleSet` and
`inductive ExtDerivation` precede the first `def`, in the block's preamble region, because
`structure` and `inductive` are not among `lean-challenge-snapshot.sh`'s declaration-boundary
keywords (`theorem|lemma|def|instance|abbrev`) and so contribute no name to the harvested
identifier set. They are consequently **absent from `- **Goals**:` as well**, which is what keeps
the two sets equal; both are nonetheless required deliverables and are verified by Phase 1's
criteria instead.

```lean
import FormalSystem.Metalogic.AuxiliaryAtoms
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness
import FormalSystem.PlusLanguage.PlusReversal

namespace FormalSystem.Metalogic.LCExtension

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.Metalogic.NamingRules FormalSystem.Metalogic.AuxiliaryAtoms
open FormalSystem.Metalogic.Conservativity

structure RuleSet where
  clock : Bool
  aaFwd : Bool
  aaBwd : Bool

inductive ExtDerivation (fc : FrameClass) (Ax : PlusFormula → Prop) (R : RuleSet) :
    PlusFormula → Prop
  | tm {φ} (d : PlusDerivable fc [] φ) : ExtDerivation fc Ax R φ
  | ax {φ} (h : Ax φ) : ExtDerivation fc Ax R φ
  | mp {φ ψ} (d₁ : ExtDerivation fc Ax R (φ.imp ψ)) (d₂ : ExtDerivation fc Ax R φ) :
      ExtDerivation fc Ax R ψ
  | nec {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R (PlusFormula.box φ)
  | tnec {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R φ.allFuture
  | refl {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R φ.reflectTime
  | clock {q φ} (hR : R.clock = true) (hq : Fresh q φ)
      (d : ExtDerivation fc Ax R ((clockAnte q).imp φ)) : ExtDerivation fc Ax R φ
  | aaFwd {φ} (hR : R.aaFwd = true) (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula)
      (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
      (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
      (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
      (ha : ∀ i, i < k → (a i).StateLocal)
      (hfresh : ∀ j, j < m → Fresh (qa j) φ)
      (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
      (hexh : ExtDerivation fc Ax R (bigAnd k fun i => (a i).neg).neg)
      (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' →
        ExtDerivation fc Ax R (((a i).and (a i')).neg))
      (d : ExtDerivation fc Ax R ((aaAnte qa m k a p b₀).imp φ)) :
      ExtDerivation fc Ax R φ
  | aaBwd {φ} (hR : R.aaBwd = true) (qa : ℕ → Atom) (m k : ℕ) (a : ℕ → PlusFormula)
      (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (hb₀ : b₀ < m)
      (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
      (hp : ∀ j, j < m → ∀ i, i < k → p j i < m)
      (ha : ∀ i, i < k → (a i).StateLocal)
      (hfresh : ∀ j, j < m → Fresh (qa j) φ)
      (hfreshA : ∀ j, j < m → ∀ i, i < k → Fresh (qa j) (a i))
      (hexh : ExtDerivation fc Ax R (bigAnd k fun i => (a i).neg).neg)
      (hdisj : ∀ i, i < k → ∀ i', i' < k → i ≠ i' →
        ExtDerivation fc Ax R (((a i).and (a i')).neg))
      (d : ExtDerivation fc Ax R (((aaAnte qa m k a p b₀).imp φ).reflectTime)) :
      ExtDerivation fc Ax R φ.reflectTime

def RuleSet.none : RuleSet := ⟨false, false, false⟩

def RuleSet.all : RuleSet := ⟨true, true, true⟩

def IsLCAxiom (ψ : PlusFormula) : Prop :=
  ∃ (n : ℕ) (α : ℕ → PlusFormula), 0 < n ∧ (ψ = lcN n α ∨ ψ = (lcN n α).reflectTime)

def IsLCUAxiom (ψ : PlusFormula) : Prop :=
  ∃ α β : PlusFormula, ψ = lcU α β ∨ ψ = (lcU α β).reflectTime

theorem isLCAxiom_plusValidZTime {ψ : PlusFormula} (h : IsLCAxiom ψ) : PlusValidZTime ψ := sorry

theorem isLCUAxiom_plusValidZTime {ψ : PlusFormula} (h : IsLCUAxiom ψ) : PlusValidZTime ψ := sorry

theorem ext_sound_ztime {Ax : PlusFormula → Prop} {R : RuleSet}
    (hAx : ∀ ψ, Ax ψ → PlusValidZTime ψ) {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime Ax R φ) : PlusValidZTime φ := sorry

theorem ext_sound_validIn {fc : FrameClass} {Ax : PlusFormula → Prop} {R : RuleSet}
    (hFwd : R.aaFwd = false) (hBwd : R.aaBwd = false)
    (hAx : ∀ ψ, Ax ψ → PlusValidIn fc ψ) {φ : PlusFormula}
    (d : ExtDerivation fc Ax R φ) : PlusValidIn fc φ := sorry

def ExtComplete (Ax : PlusFormula → Prop) (R : RuleSet) : Prop :=
  ∀ φ : PlusFormula, PlusValidZTime φ → ExtDerivation FrameClass.ZTime Ax R φ

def LCComplete : Prop := ExtComplete IsLCAxiom RuleSet.none

def LCRulesComplete : Prop := ExtComplete IsLCAxiom RuleSet.all

def LCURulesComplete : Prop := ExtComplete IsLCUAxiom RuleSet.all

theorem ext_sound_lc_ztime {R : RuleSet} {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime IsLCAxiom R φ) : PlusValidZTime φ := sorry

theorem ext_sound_lcU_ztime {R : RuleSet} {φ : PlusFormula}
    (d : ExtDerivation FrameClass.ZTime IsLCUAxiom R φ) : PlusValidZTime φ := sorry

end FormalSystem.Metalogic.LCExtension
```

## Testing & Validation

- [ ] Full project build green with zero warnings, and `lake build BimodalTest` green (CI builds with `--wfail`; a lint warning is a CI failure).
- [ ] Zero `sorry` and zero new axiom in both new files; the measured profile ceiling is `[propext, Classical.choice, Quot.sound]` or lower for every pinned declaration.
- [ ] All fourteen `## Lean Challenge Statements` identifiers present in `FormalSystem/Metalogic/LCExtension.lean` at their pinned signatures, plus `RuleSet` and `ExtDerivation`.
- [ ] Six axiom-profile `#guard_msgs` blocks compile against **measured** profiles.
- [ ] The three target Props are present, unproved, `sorry`-free, and nowhere claimed to hold; the four `example`s (mirror-shape acceptance, two axiom-predicate inhabitations) compile.
- [ ] `scripts/check-module-invariants.sh` clean for every touched file, with any pre-existing repo-wide finding enumerated; C17, C27, C15 (both assertions) and `INV` each addressed by name.
- [ ] `scripts/typst-sync-check.sh` green, and `.githooks/pre-commit` accepted every Lean-touching commit without `--no-verify`.
- [ ] `scripts/check-metalogic-cycles.sh` assertions A and B unchanged — no new directory-level edge, no new upward import.
- [ ] `scripts/check-copyright-headers.sh`, `check-paper-definitions.sh`, `check-phantom-citations.sh`, `check-evidence-probes.sh`, `readme-lint.sh` each run with exit status recorded and any finding attributed to a touched file or to the pre-existing baseline.
- [ ] `verify-deploy.sh` run with its exit status recorded and every finding attributed to the stale-deploy baseline or to a touched file.

## Artifacts & Outputs

- `FormalSystem/Metalogic/LCExtension.lean` — the extended L⁺ proof system, its ZTime soundness, and the three stated completeness targets.
- `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` — permanent axiom-profile evidence, six build-breaking `#guard_msgs` blocks.
- Edited: `FormalSystem/Metalogic.lean`, `FormalSystem.lean`, `Tests/BimodalTest.lean` (one import line each); `docs/theorem-index.md` (one new subsection, eleven rows); `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` (regenerated inventory blocks plus one hand-written description cell); `typst/generated/status.typ` (regenerated counts).
- `specs/896_lplus_extended_proof_system_and_target_statement/summaries/01_lplus-extended-proof-system-summary.md` at completion.

## Rollback/Contingency

Each phase is one or more green-verified commits, so reverting is a per-commit `git revert` of
this task's own commits in reverse order — no snapshot is required for that route, and it leaves
task 911's concurrent work on the shared files untouched. The two new files are additive: nothing
in the tree imports them until Phase 1's aggregator lines land, so reverting Phase 1's commit
alone restores a buildable tree even if Phases 2 and 3 are incomplete.

If a rollback must instead discard uncommitted working-tree changes, that is the genuine-rollback
case: take the snapshot first per `context/contracts/recovery.md`'s rollback rung (including its
out-of-scope override flag where the revert reaches beyond this task's declared `file_scope`),
then run the destructive command. Never discard uncommitted changes to reach a passing build —
fix forward instead, and if the module cannot be landed, mark the phase `[BLOCKED]` with the goal
state reached rather than substituting any vacuous placeholder for a target Prop.
