# Implementation Plan: Task #906

- **Task**: 906 - Settle whether `lcU` is derivable from TM⁺ + `LC_n` at `.ZTime` via a non-`.ZTime`
  separating model
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None blocking. Territory-serialized against task 899 on
  `docs/theorem-index.md` — see "Territory" below.
- **Research Inputs**: `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/reports/01_lcu-lcn-separating-model.md`
- **Artifacts**: plans/01_lcu-lcn-separating-model.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md,
  plan-compliance.md, lean4.md
- **Type**: formal
- **Lean Intent**: false

## Overview

The research dispatch reached the deliverable's **second** branch and compiled it: `lcU α β` is
not a theorem of TM⁺ + `LC_n` + mirror `LC_n` at `FrameClass.Base`, witnessed by the translation
frame over ℚ, with the headline `lcU_not_extDerivable_base` compiling `sorry`-free. Nothing
mathematical is left to decide, and this plan attempts none: no derivation search, no `.ZTime`
claim, no completeness claim, no new proof work of any kind. What is left is **custody** — three
things the research produced that currently live nowhere durable.

First, the result itself is not written down where a reader of the library would find it:
`PlusLCSchema.lean` still says only that "nothing here says that `lcU` … follows from `lcN`",
which is now an understatement of a settled negative. Second, the load-bearing half of the
argument — the determinism collapse and the deterministic-class soundness arm — exists only as a
probe under `specs/`, outside the Lake build and outside CI. Third, and discovered at plan time
rather than in the report, **the probe is not in version control at all**: it is untracked and
unwired, so it is absent from a fresh clone and would rot unwatched (see "Premise Re-Validation").

So five phases, in dependency order. The `⟐` sibling of the determinism collapse goes into
`PlusDeterminism.lean` beside the `⊡` one. The research result is recorded in `PlusLCSchema.lean`'s
docstring, where `.Base` validity and non-derivability were both listed as unclaimed. The
deterministic-class soundness arm and `LC_n`'s deterministic validity go into `LCExtension.lean`
beside its two existing soundness arms, with their axiom profiles pinned in
`LCExtensionTest.lean`. The four new `LCExtension.lean` declarations get their
`docs/theorem-index.md` rows, isolated into their own phase because that file is held by a
concurrent sibling. Finally the probe is tracked, wired into
`scripts/check-evidence-probes.sh`, and reduced to the part that is genuinely probe-shaped — the
ℚ model and the headline — importing the promoted halves rather than carrying a second copy of
them.

Every Lean declaration landed here is a **verbatim transcription** of an already-compiled probe
declaration, not a re-derivation. The signatures are pinned below under
`## Lean Challenge Statements`, and `plan-compliance.md`'s Statement Fidelity clause governs them.

### Premise Re-Validation

The dispatch flagged the `## Description` line for Carried-Figure Discipline. Each of its four
checkable claims was checked against the prior artifact **and** against live state; the results
are stated here even where they only confirm the description.

1. **"both `lcN_plusValidZTime` and `lcU_plusValidZTime` are compiled" — CONFIRMED, live.**
   `lcN_plusValidZTime` is declared at `FormalSystem/PlusLanguage/PlusLCSchema.lean:353` and
   `lcU_plusValidZTime` at `:464`; the file's single occurrence of the string `sorry` is a
   docstring reference to another probe, not a proof body. `check-module-invariants.sh` C1 was
   observed PASS at commit `d7bf732fb` during this planning dispatch. The description's inference
   therefore stands: the two systems have identical `.ZTime` models and no `.ZTime` separating
   model can exist, which is also the research's Decision 6 and Recommendation 5.
2. **"both schemata's validity is open and unclaimed per `PlusLCSchema.lean`'s own docstring" —
   CONFIRMED, live, and STILL TRUE after the research.** The phrase "open and unclaimed" occurs at
   `PlusLCSchema.lean:81`, `:224`, `:244`, `:454` and `:482`. This is the premise most at risk of
   being over-written by this plan, so it is stated sharply: the research settled the
   **derivability** of `lcU` from `IsLCAxiom` at `.Base`, and settled nothing about the **validity**
   of either schema at `.Base`. Every docstring edit in Phase 2 adds a derivability sentence and
   leaves every validity sentence exactly as it stands.
3. **"the first target is `.Base`" — CONFIRMED as the route actually taken.** The research separated
   on the deterministic subclass of `.Base` (`DetSat .Base`), which is what let it avoid `LC_n`'s
   open `.Base` validity entirely, and the result extends to `.Dense` and `.RTime` by `Sat`
   antitonicity (Finding 9, argued not compiled — recorded as such below).
4. **"RESEARCH TASK, report only. No Lean work beyond what is needed to state the separating model"
   — SUPERSEDED by the research dispatch's own Decision 5, and the excess is currently outside
   version control.** The probe
   `specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` exists, is 189 lines, and
   contains zero occurrences of `sorry` (all three figures read live at authoring time). It is
   **untracked** — `git status --porcelain specs/evidence/` reports `?? specs/evidence/lcu-lcn-separation/`
   — and it is **absent from `scripts/check-evidence-probes.sh`'s `WIRED` array**, where the
   precedent probe `limit-closure-schema/lc-schema-omega-chain` does appear (array entry at
   `check-evidence-probes.sh:2289`, comment-table row at `:2089`). The research postflight commit
   `d7bf732fb` did not pick the directory up. Phase 5 fixes this; it is recorded here because it
   is a fact about live state that the report does not contain.

### Research Integration

The plan executes the report's Recommendations 1 and 2, records Recommendation 3 as a docstring
note, honours Recommendations 4 and 5 as Non-Goals, and adds one item the report had no occasion
to name.

- **Recommendation 1 (record the result in `PlusLCSchema.lean` and `LCExtension.lean`)** — Phase 2
  for `PlusLCSchema.lean`, and Phase 3 for `LCExtension.lean`'s completeness-target block (folded
  into the same phase as the declarations that module gains, so the module is edited once).
- **Recommendation 2 (promote the probe's Part I and Part III)** — Phase 1 (`dstab_iff_of_deterministic`
  into `PlusDeterminism.lean`, its natural fifth stable-surface name) and Phase 3
  (`lcAnte_iff_lcCons_of_deterministic`, `lcN_plusValidOn_of_deterministic`,
  `isLCAxiom_plusValidDetIn_base`, `ext_sound_detIn` into `LCExtension.lean`).
- **Recommendation 3 (the guarded until-form is the candidate below `.ZTime`)** — recorded as a
  docstring note in Phase 2, tagged for what it is: an immediate corollary of the same determinism
  collapse, argued in the report (Finding 6) and **not** separately compiled.
- **Recommendation 4 (target the naming rules; the cheap follow-up is whether `IsLCUAxiom` derives
  `lcN`)** — Non-Goal. It is a new research question, not this task's recording work.
- **Recommendation 5 (do not look for a `.ZTime` separating model)** — honoured, and written into
  `PlusLCSchema.lean`'s docstring in Phase 2 so the next reader does not re-open it.
- **Addition not in the report**: tracking and wiring the probe (Phase 5), plus the generated-surface
  regeneration steps every phase that changes Lean line counts carries
  (`typst/generated/status.typ`, the module-inventory blocks). The latter are mechanical
  consequences enumerated by `plan-authoring-gate-collisions.md` Condition 1.

Load-bearing facts carried from the report into the phase work:

- On a deterministic frame `⊡φ ↔ φ` and `⟐φ ↔ φ`, so `lcAnte n α` and `lcCons n α` become the same
  condition and `lcN n α` is valid for the reason `X → X` — at every arity, all parameters, mirror
  included via `plusValidDetIn_reflectTime`. This is why nothing here waits on `LC_n`'s open
  `.Base` validity.
- The separating property is order-theoretic: `lcU`'s consequent body `⟐α ∨ (⟐β U ⟐α)` is
  **unguarded**, which forces the `⟐α`-points to be cofinal; `lcN`'s guarded implication body does
  not. The refuting instance takes `β := α` (an atom), so the until's segment guard carries nothing
  extra and the "state-local `β`" restriction is refuted along with the general case.
- Every declaration this plan lands already compiles `sorry`-free in the probe, so all five phases
  are transcription, scoping and recording work — not proof-search work.

### Prior Plan Reference

No prior plan exists for task 906, and no `prior_plan_path` was supplied. The most recent
Lean-landing plan in this repository
(`specs/924_forward_slack_witnessed_frontier_disposition/plans/01_forward-slack-frontier-disposition.md`)
was read as reference only; no phase is copied from it. Three things were calibrated against it:

- **Effort calibration.** Its per-phase estimate of roughly 1–1.5 h for a phase transcribing
  already-compiled proof plus its scoping docstring is the basis for Phases 1 and 3 here.
- **Validated approach.** Its shape — each phase commits once, green, with the generated-surface
  regeneration staged *in the same commit* as the Lean change rather than deferred — is reused
  verbatim, because the pre-commit hook makes any other shape fail.
- **Territory handling.** Its mechanism was declaration, not avoidance: name the contended path in
  the phase's `Files to modify` so the harvest serializes the pair at admission. That is reused
  here for `docs/theorem-index.md`, with one refinement — the contended file is isolated into a
  phase of its own (Phase 4), so a collision blocks one half-hour phase rather than the plan's
  substance.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context and `roadmap_flag` is not set,
so no roadmap review/update phases are generated and `specs/ROADMAP.md` is **not** written by this
task (the file does exist at `specs/ROADMAP.md`; it is read-only here, and was not read for this
plan because no roadmap context was dispatched). For the record, as information for whoever next
sweeps it: the completeness programme's until-form question now has a settled negative at
`.Base`/`.Dense`/`.RTime` and a named candidate replacement (the guarded form). Recording that in
`ROADMAP.md` is out of scope here.

## Goals & Non-Goals

**Goals**:
- `dstab_iff_of_deterministic` -- the `⟐` sibling of the determinism collapse, landed in
  `PlusDeterminism.lean` as its fifth stable-surface name.
- `lcAnte_iff_lcCons_of_deterministic` -- `lcN`'s antecedent and consequent coincide at every point
  of a deterministic frame.
- `lcN_plusValidOn_of_deterministic` -- `lcN n α` is frame-valid on every deterministic frame, at
  every arity and all parameters.
- `isLCAxiom_plusValidDetIn_base` -- every `IsLCAxiom` member, mirror included, is
  `PlusValidDetIn .Base`.
- `ext_sound_detIn` -- soundness of `ExtDerivation` over the deterministic frames of an arbitrary
  frame class, for a rule set with all three naming rules off.

Beyond those five declarations, this plan commits to three documentary outcomes, which are not
identifiers and so are deliberately absent from the list above: the research result is recorded in
`PlusLCSchema.lean`'s and `LCExtension.lean`'s docstrings (Phases 2 and 3); the four new
`LCExtension.lean` declarations get `docs/theorem-index.md` rows (Phase 4); and the probe enters
version control, enters `check-evidence-probes.sh`'s `WIRED` array, and is reduced to the ℚ model
plus the headline (Phase 5).

**Non-Goals**:
- Any claim about `.Base` **validity** of `lcN` or `lcU`. Both stay "open and unclaimed", in those
  words, in every docstring this plan touches. Non-derivability and non-validity are different
  statements and no edit here may blur them.
- Any `.ZTime` derivability verdict. `lcU` *is* `.ZTime`-valid; the compiled result is at `.Base`
  with `RuleSet.none`, and the soundness argument does not reach `.ZTime` by design. The research's
  Recommendation 5 is written down, not acted on.
- Any completeness claim, or any weakening of `LCComplete`/`LCRulesComplete`/`LCURulesComplete`.
  All three stay `Prop`-valued `def`s with no proof term.
- Generalizing `ext_sound_detIn` to admit the clock rule. The report assesses this as a one-line
  generalization but tags it UNVERIFIED (uncompiled); the statement landed here keeps all three
  flags off, exactly as compiled.
- Compiling Finding 8's discrete strengthening (`ℤ ×ₗ ℤ`) or Finding 9's `.Dense`/`.RTime`
  extensions. Both are argued, not compiled; where this plan's prose mentions them it says so.
- Attempting Recommendation 4's follow-up (does `IsLCUAxiom` derive `lcN`?). A separate research
  question.
- Landing Part II of the probe (the ℚ frame, `Alt`, `Mq`, `Hq`, `pa`, `dstab_pa_iff`,
  `lcU_refuted`) or the headline `lcU_not_extDerivable_base` under `FormalSystem/`. Those stay in
  the probe, which is what the evidence collection is for.
- Authoring the report's Context Extension Recommendation (a new pattern file for the `formal`
  extension). That file's home is a source-store path — `.claude-extensions.json` resolves
  `extensions.formal.source_dir` to `/home/benjamin/.config/nvim/agent-system/extensions/formal`,
  which is **not on this repository's filesystem** (`agent-system/` does not exist here). Per
  `rules/source-store-deploy-boundary.md`'s Task Siting subsection, a task whose declared edit
  target is a source-store path must be created in the repository that holds that `source_dir`, so
  this one cannot carry it. It is recorded here as a follow-up for that repository, not silently
  dropped.
- Writing `specs/ROADMAP.md` (see "Roadmap Alignment").

## Territory

**One concurrent sibling holds a file this plan must touch.**

| File this plan touches | Held by | Phase |
|---|---|---|
| `docs/theorem-index.md` | 899 | 4 |

Task 899's declared `file_scope` is `FormalSystem/PlusLanguage/PlusPasting.lean` and
`docs/theorem-index.md`; this plan touches neither `PlusPasting.lean` nor anything else 899 holds.
Task 905 is dispatched this same cycle with **no declared `file_scope`**, so it may touch any file
in the repository — that is an undeclared-scope hazard, not a known overlap, and the dispatch's
concurrency note items (1), (4) and (5) are the operative protection against it.

**The mechanism is declaration, not avoidance.** `docs/theorem-index.md` is named in Phase 4's
`Files to modify` block, so `plan-file-scope-harvest.sh` writes it into
`active_projects[].file_scope` at plan postflight, and `orchestrate-batch-admit.sh` sees the
overlap with 899 on the next cycle and serializes the two rather than co-dispatching them. The
plan does **not** silently narrow its scope to the free files: every other `LCExtension.lean`
declaration carries an index row, and omitting rows for these four would leave the ledger
inconsistent for no reason but convenience.

**Why the contended file is isolated into its own phase.** `docs/theorem-index.md` is the only
contended path, and nothing else in the plan depends on it. Phase 4 therefore does nothing else, so
if 899 is mid-flight when the implementation dispatch runs, exactly one 30-minute phase closes
`[BLOCKED]` and the plan's substance still lands.

**If 899 is still `implementing` when the implementation dispatch begins**: per the dispatch's
concurrency note item (5), do not enter Phase 4. Close it `[BLOCKED]` with the observed state
recorded (`git log -- docs/theorem-index.md`, 899's status in `specs/state.json`), finish every
other phase in full, and report the split. Do **not** edit the file while 899 has uncommitted
changes in it, and do **not** add a `dependencies[]` edge from inside the implementation dispatch —
an edge pointing at 899 would block this task's own admission, including the four phases that have
no collision at all.

## Decisions

1. **Land the recording half, not more mathematics.** The task description's floor was "report
   only"; the research exceeded it with a compiled probe (its Decision 5). This plan does not
   re-open the mathematics and does not extend the result; it puts what was proved where the
   library and CI can see it. Every Lean step is a transcription of an existing compiled body.
2. **`dstab_iff_of_deterministic` goes to `PlusDeterminism.lean`, not to `LCExtension.lean`.** It is
   a statement about the stability modal's dual on a deterministic frame, with no `LC` content at
   all, and that module's own docstring already frames its four results as "the stable import
   surface … downstream work consumes them rather than re-deriving the collapse". It needs no new
   import there (`PlusValidity` already supplies `dstab_iff` and `truth_congr_ext`), which keeps
   Phase 1 at a single-module blast radius.
3. **The remaining three-plus-one go to `LCExtension.lean`, not to a new module and not to
   `PlusLCSchema.lean`.** Following the report's own placement. A new module would pull in C33
   (`lake exe mk_all`), C24 (Init-import closure) and a new inventory row for no benefit;
   `PlusLCSchema.lean` would need a `PlusDeterminism` import and still could not host
   `ext_sound_detIn`, which needs `ExtDerivation`. `LCExtension.lean` already hosts the two
   soundness arms this one sits beside, and needs exactly one new import
   (`FormalSystem.Metalogic.Deterministic.Validity`).
4. **The probe is reduced, not duplicated.** After Phase 3 the probe imports
   `FormalSystem.Metalogic.LCExtension` and keeps only Part II and the headline. Keeping a second
   copy of Part I/III under `specs/` would let the two drift silently; importing the library
   versions means a weakening of either one breaks the probe's compile, which is exactly the signal
   `check-evidence-probes.sh` exists to raise.
5. **Axiom profiles are measured in the implementing dispatch, never carried from the report.**
   The report pins five probe names at `[propext, Classical.choice, Quot.sound]` but did **not**
   pin `dstab_iff_of_deterministic`, which is the one name whose profile is load-bearing for
   another module's standing claim (see Risks). Every pin this plan lands is read out of a live
   `#print axioms`.
6. **`docs/theorem-index.md` rows are added, and the collision is declared.** See "Territory".

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `dstab_iff_of_deterministic`'s measured axiom profile is NOT `[propext]`-only, contradicting `PlusDeterminism.lean`'s "Why this is choice-free" section and its C4 pin block's "All four report `[propext]` only — in particular **no** `Classical.choice`" | H | M | Phase 1 measures the profile BEFORE writing any prose. If it is `[propext]`, the pin block and the "four names" sentence widen to five and the choice-free claim is unchanged. If it is not, the choice-free claim stays **scoped to the original four** and the fifth name's measured profile is recorded explicitly beside it, with one sentence naming which step costs the axiom. Under no branch is the module's existing claim silently widened to cover a name that does not satisfy it |
| 899 is mid-flight in `docs/theorem-index.md` | M | M | Declared file scope serializes the pair at admission; if the dispatch runs anyway, Phase 4 alone closes `[BLOCKED]` (see "Territory") |
| Task 905 has no declared `file_scope` and may touch any file | M | M | Dispatch concurrency note items (1), (4) and (5): re-read every file immediately before editing; treat a build failure outside this task's own scope as possibly a sibling's in-flight edit, checked against `git log` before being treated as a regression; stop and report a foreign commit or foreign uncommitted modification rather than proceeding |
| Adding `import FormalSystem.Metalogic.Deterministic.Validity` to `LCExtension.lean` creates an import cycle, or trips `check-metalogic-cycles.sh` assertion B (which asserts the upward-import set EQUALS its allowlist and so fails on surplus) | H | L | Confirmed acyclic at authoring time: `Deterministic/Validity.lean` imports only `PlusLanguage.PlusDeterminism`, `Metalogic.Independence.DeterminismUndefinable` and `PlusLanguage.PlusReversal`, and nothing under `Metalogic/Deterministic/` imports `LCExtension` (the only importers are the root aggregator `FormalSystem.lean` and the test). `Metalogic/LCExtension.lean` sits at the `Metalogic/` top level, so it contributes no directory-level edge as a source under assertion A's own definition. Both facts are re-confirmed in Phase 3 by running `scripts/check-metalogic-cycles.sh`, not by trusting this cell. If assertion B reports a surplus, the allowlist is extended IN THE SAME PHASE per `plan-authoring-gate-collisions.md` Condition 5, and `scripts/check-metalogic-cycles.sh` enters that phase's file scope |
| The pre-commit hook refuses a phase's commit because `typst/generated/status.typ` drifted | M | H | `plan-authoring-gate-collisions.md` Condition 1: surface (b) is BLOCKING and cannot be deferred. Every phase that changes Lean line counts runs `bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in the SAME commit. `--fix` needs a built library and never runs `git add` itself |
| A new declaration trips C16's `env_linter` batch (docBlame, unusedArguments, simpNF) | M | M | Every new declaration carries a docstring with a `Paper:` anchor line, matching the shape every neighbouring declaration in its module already uses. If a NEW C16 finding lands on an added name, fix the declaration; do not add a `nolints.json` entry to paper over it |
| C16 or another repo-wide check is already red for pre-existing reasons | L | M | `plan-authoring-gate-collisions.md` Condition 4: a gate whose only failures are pre-existing and outside this task's file scope is a recorded PASS, with the pre-existing findings enumerated and with evidence each touched file passes individually. Never edit an out-of-scope file to force an absolute zero |
| Docstring additions shift line numbers and break a `file.lean:NNN` citation elsewhere (C20's third assertion) | M | M | Phase 5 runs `check-module-invariants.sh` and reads C20's verdict. A NEW name-bearing finding is re-anchored if it lives in a file this plan may touch; otherwise it is recorded as an enumerated out-of-scope finding, or carried in `scripts/c20-declaration-baseline.txt` where that is the right carrier |
| `lcAnte_iff_lcCons_of_deterministic`'s body uses the `show` tactic, which `plan-authoring-gate-collisions.md` Condition 8 reports as linted under `--wfail` | L | L | Measured at authoring time: `FormalSystem/` carries 636 live `show` lines, so a `show` is not per se a CI failure in this repository and Condition 8's blanket reading does not hold as stated. The transcription keeps the body verbatim; if the scoped build emits a warning naming that line, replace the `show` with a named `rfl` lemma (Condition 8's own remedy) rather than suppressing the linter |
| The reduced probe stops compiling because its import closure cannot be loaded during a concurrent `lake build` | L | M | `check-evidence-probes.sh` reports this as its own `FAIL (environment: ...)` class, which its header rules is NEVER probe rot. Re-run once the concurrent build has finished; repair no probe on that evidence |
| A docstring sentence is read as settling `.Base` **validity**, or as a `.ZTime` claim | H | M | Every sentence added in Phases 2 and 3 names the frame class and the rule set explicitly (`.Base`/`.Dense`/`.RTime`, `RuleSet.none`), keeps the words "open and unclaimed" on the validity question, and says in the same paragraph that `lcU` *is* `.ZTime`-valid so no `.ZTime` separation exists. Phase 5 greps each edited docstring for the retained "open and unclaimed" phrasing before the task closes |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel. Phase 5 is the final phase: it is the
highest-numbered phase, it is a terminal node of the dependency graph, and it depends — directly —
on every other phase.

---

### Phase 1: The `⟐` Sibling of the Determinism Collapse [NOT STARTED]

**Goal**: `⟐φ ↔ φ` on a deterministic frame becomes a library fact beside `⊡φ ↔ φ`, with its axiom
profile measured rather than assumed.

**Tasks**:
- [ ] Re-read `FormalSystem/PlusLanguage/PlusDeterminism.lean` and
      `specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` immediately before editing
      (dispatch concurrency note item (1)); the probe lines 27-38 are the source text.
- [ ] Confirm by exact-name grep over `FormalSystem/` and `Tests/` that `dstab_iff_of_deterministic`
      is declared nowhere today, so the new name cannot create an ambiguity for a downstream
      `open FormalSystem.PlusLanguage`. (Checked at authoring time — the only occurrences anywhere
      are inside the probe — but re-check rather than trust this line.)
- [ ] Transcribe `dstab_iff_of_deterministic` VERBATIM from the probe, placed directly after
      `stab_iff_of_deterministic` (its `⊡` partner) rather than appended at the end of the module,
      so the two collapses read together. Statement and proof are lifted unchanged; the signature
      is pinned below under `## Lean Challenge Statements` and `plan-compliance.md`'s Statement
      Fidelity clause governs it.
- [ ] Give it a docstring in the module's own idiom: what it says, which direction needs
      determinism (`(⇒)` is `truth_congr_ext` along `states_eq_of_deterministic`; `(⇐)` is
      `⟨τ, rfl, h⟩` and holds on every frame), and a `Paper:` anchor line matching the shape used
      by the module's neighbours.
- [ ] **Measure** the new profile — `#print axioms FormalSystem.PlusLanguage.dstab_iff_of_deterministic`
      via `lake env lean` on a scratch file importing the module, or `lean_verify` on the fully
      qualified name. Record the measured value; do not type it from this plan or from the report,
      which never pinned this name.
- [ ] Update the module docstring's `## Main Results` list to carry the fifth name, and change
      "Those four names are the stable import surface of this module" to name five.
- [ ] Update the `## Axiom pin (C4)` block: add the commented `#print axioms` line for the new name
      and amend the sentence after it. **Two branches, decided by the measurement, not by
      preference**: if the measured profile is `[propext]`, the sentence becomes "All five report
      `[propext]` only — in particular **no** `Classical.choice`". If it is anything else, the
      existing sentence stays scoped to the original four and the fifth is recorded on its own line
      with its measured profile and one sentence naming the step that costs the axiom; the
      `## Why this is choice-free` section is then amended to say which results it covers. Never
      widen the existing claim to cover a name that does not satisfy it.
- [ ] Update `FormalSystem/PlusLanguage/README.md`'s inventory row description for
      `PlusDeterminism.lean` (currently naming the four results and asserting "choice-free
      (`[propext]` only)") to name the fifth and to match whichever branch above was taken. Row
      descriptions are preserved across `--emit-inventory` regeneration, so this is a hand edit of
      the description cell only — never of a generated count cell.
- [ ] Regenerate `typst/generated/status.typ` with `bash scripts/typst-sync-check.sh --fix` and
      stage it in the SAME commit as the `.lean` change; the pre-commit hook is blocking, not
      auto-regenerating.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `PlusDeterminism.lean` is 154 lines at authoring time (read live via `wc -l`,
and matching `FormalSystem/PlusLanguage/README.md`'s inventory row), so the 1500-line `longFile`
ceiling is not in play and no baseline is needed; this phase adds an estimated 15-25 lines. The
phase also asserts that `dstab_iff_of_deterministic` requires NO new import, on the grounds that
`PlusValidity` (already imported) transitively supplies `dstab_iff`, `truth_congr_ext` and
`PlusTruthAt`. Confirm both with `wc -l` and the scoped build rather than trusting the carried
figures; if an import turns out to be needed, the tier rises to `interface` and
`scripts/check-metalogic-cycles.sh` enters this phase's verification.

**Tier Justification**: The edit adds one new declaration to one module and changes no existing
signature, so the covering check is that single module's own build —
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusDeterminism`
— together with `bash scripts/typst-sync-check.sh --counts-only` for the one blocking generated
surface a Lean line-count change touches.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusDeterminism.lean` - the new `dstab_iff_of_deterministic` with its
  docstring, the `## Main Results` fifth entry, the "five names" sentence, and the amended
  `## Axiom pin (C4)` block
- `FormalSystem/PlusLanguage/README.md` - the `PlusDeterminism.lean` inventory row description
  (hand edit of the description cell; counts are regenerated in Phase 5)
- `typst/generated/status.typ` - regenerated line-count fields (`--fix`), staged in the same commit

**Verification**:
- The scoped guarded build is green and warning-free on the new declaration: no
  `linter.autoImplicit`, no unused-variable warning, no `docBlame` finding. CI builds with
  `--wfail`, so a warning is a failure.
- `#print axioms` (or `lean_verify`) on `FormalSystem.PlusLanguage.dstab_iff_of_deterministic`
  reports a measured profile with no `sorryAx` and no custom axiom, and the prose landed in the C4
  block states exactly that measured value.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 BEFORE the commit is attempted.
- The module docstring no longer says "Those four names are the stable import surface".
- An exact-name grep confirms `dstab_iff_of_deterministic` is declared exactly once under
  `FormalSystem/`.

---

### Phase 2: Record the Result in `PlusLCSchema.lean` [NOT STARTED]

**Goal**: A reader of the limit-closure schema module learns that the until-form's derivability
from `LC_n` is settled negatively below `.ZTime`, that its `.Base` validity is still open, and
which shape is the live candidate — without having to find a task report.

**Tasks**:
- [ ] Re-read `FormalSystem/PlusLanguage/PlusLCSchema.lean` immediately before editing (concurrency
      note item (1)), paying attention to the five sites carrying "open and unclaimed" (`:81`,
      `:224`, `:244`, `:454`, `:482` at authoring time — re-locate them live, since line numbers
      move).
- [ ] Add, to the module docstring's `LCU` discussion and to `lcU`'s own declaration docstring, the
      derivability verdict in these terms and no stronger: `lcU α β` is **not** derivable from TM⁺
      plus the `LC_n` axiom set plus its `reflectTime` mirror at `FrameClass.Base`, with
      `RuleSet.none`; the witness is the translation frame over ℚ with atom truth set
      `{q : ℚ | q < 1}` at the identity history and time `0`; the argument runs through the
      deterministic subclass, where `lcN` is valid for the reason `X → X`, so it does **not** wait
      on `LC_n`'s open `.Base` validity. Name `specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean`
      as the compiled record (it is wired into CI in Phase 5), and name the library halves landed
      in Phases 1 and 3 so a reader can follow the argument without the probe.
- [ ] State the extension to `.Dense` and `.RTime` as what the report says it is: a consequence of
      `Sat` antitonicity, argued and **not compiled** (report Finding 9, Medium confidence). Do not
      write it as a compiled fact.
- [ ] State the `.ZTime` position explicitly, so Recommendation 5 is recorded rather than
      re-discovered: both `lcN_plusValidZTime` and `lcU_plusValidZTime` are compiled, so the two
      extensions have exactly the same `.ZTime` models and **no** `.ZTime` separating model exists
      in any form; any apparent one would be an error in the attempt. The `.ZTime` derivability
      question is therefore open and not model-theoretically approachable.
- [ ] Add the guarded-until-form note (report Recommendation 3 / Finding 6):
      `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → ⟐G≤(⟐α → (⟐β U ⟐α))` collapses to `G≤(α → (β U α))` on both sides
      under determinism, so this countermodel says nothing against it; it is the `lcN`-shaped
      candidate if an until-form schema is wanted below `.ZTime`, where `lcU` is now a
      non-candidate. Tag it as argued-not-compiled, and do **not** introduce a `def` for it — this
      plan adds no new schema.
- [ ] Leave every "open and unclaimed" **validity** sentence exactly as it stands. The additions are
      about derivability; nothing in this phase may be read as settling validity. Say so in one
      clause at the point where the two sit closest together.
- [ ] Update `FormalSystem/PlusLanguage/README.md`'s `PlusLCSchema.lean` inventory row description
      with one clause recording the non-derivability verdict and its frame classes, keeping the
      existing ".Base validity is open and unclaimed for both" clause intact.
- [ ] Regenerate `typst/generated/status.typ` with `bash scripts/typst-sync-check.sh --fix` and
      stage it in the SAME commit as the `.lean` change.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `PlusLCSchema.lean` is 490 lines at authoring time (read live via `wc -l`,
matching its `README.md` inventory row), so the `longFile` ceiling is not in play; this phase adds
an estimated 30-45 docstring lines and NO declaration. Confirm with `wc -l` and by checking that
`git diff` shows changes only inside comment and docstring regions.

**Tier Justification**: The edit is confined to docstring and comment regions of one module with no
declaration and no signature change, but a Lean doc comment does compile, so the covering check is
that module's own build —
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusLCSchema`
— plus `bash scripts/typst-sync-check.sh --counts-only` for the blocking generated surface.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` - module-docstring and `lcU`-docstring additions:
  the non-derivability verdict, the frame-class extension marked argued-not-compiled, the `.ZTime`
  no-separating-model statement, and the guarded-form candidate note
- `FormalSystem/PlusLanguage/README.md` - the `PlusLCSchema.lean` inventory row description (hand
  edit of the description cell only)
- `typst/generated/status.typ` - regenerated line-count fields (`--fix`), staged in the same commit

**Verification**:
- The scoped guarded build is green and warning-free; a malformed docstring delimiter fails here
  loudly.
- `git diff` on the `.lean` file shows every changed hunk inside a `/-! ... -/` or `/-- ... -/`
  region: no declaration added, removed or altered.
- The string "open and unclaimed" still occurs at its original five sites (count re-measured on the
  edited file and compared to the pre-edit count), and no validity sentence was reworded.
- Each of the four added statements is present and correctly hedged, confirmed by reading the four
  paragraphs: the `.Base`/`RuleSet.none` verdict, the `.Dense`/`.RTime` extension marked
  argued-not-compiled, the `.ZTime` no-separating-model statement, and the guarded-form note marked
  argued-not-compiled.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 BEFORE the commit is attempted.

---

### Phase 3: The Deterministic Soundness Arm in `LCExtension.lean` [NOT STARTED]

**Goal**: The non-derivability argument's load-bearing half — `LC_n` valid over the deterministic
frames, and `ExtDerivation` sound over them — stops being a probe and becomes library code under
CI, with its axiom profiles pinned.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/LCExtension.lean`,
      `FormalSystem/Metalogic/Deterministic/Validity.lean`,
      `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` and the probe immediately before editing
      (concurrency note item (1)); the probe lines 40-74 and 140-170 are the source text.
- [ ] Before adding the import, confirm acyclicity by grep rather than only by build: nothing under
      `FormalSystem/Metalogic/Deterministic/` may import `FormalSystem.Metalogic.LCExtension`.
      (Checked at authoring time: the only importers are `FormalSystem.lean` and the test module.)
- [ ] Add `import FormalSystem.Metalogic.Deterministic.Validity` beside the module's three existing
      imports.
- [ ] Transcribe, VERBATIM from the probe and in this order, into a new `/-! ## Soundness over the
      deterministic frames -/` section placed directly after `ext_sound_validIn` (append-only
      relative to that arm; do not insert above an existing declaration):
      `lcAnte_iff_lcCons_of_deterministic`, `lcN_plusValidOn_of_deterministic`,
      `isLCAxiom_plusValidDetIn_base`, `ext_sound_detIn`. The signatures are pinned below under
      `## Lean Challenge Statements`; `plan-compliance.md`'s Statement Fidelity clause governs them,
      and `ext_sound_detIn` keeps all three rule flags off exactly as compiled (see Non-Goals).
- [ ] Reconcile the probe's `open`/namespace context: the probe opens
      `FormalSystem.Metalogic.Deterministic`, `FormalSystem.Metalogic.LCExtension` and
      `FormalSystem.Metalogic.Conservativity`, and declares inside `namespace LCUSeparationProbe`.
      In the library the declarations sit inside `namespace FormalSystem.Metalogic.LCExtension`,
      which already opens `FormalSystem.Metalogic.Conservativity`; add only the `open` the module
      does not already carry, and qualify `PlusValidDetIn`/`DetSat`/`plusValidDetIn_reflectTime`
      rather than widening the module's `open` list if one line suffices.
- [ ] Give each of the four a docstring in the module's idiom, each with a `Paper:` anchor line
      matching the neighbouring `Paper: — (formalization-native; the manuscript states no extended
      proof system)` shape, and each saying what it is for: the collapse computation, `LC_n`'s
      deterministic validity (with the explicit note that `.Base` validity of `lcN` is NOT needed
      for it), the axiom-set discharge over `DetSat .Base`, and the deterministic-class soundness
      arm as the third arm this module previously lacked.
- [ ] Add, to the module docstring, (a) the four names under `## Main Results`, and (b) one
      paragraph in the `## The completeness targets` discussion recording Recommendation 1's second
      half: `LCComplete`'s `lcU` instance is unreachable from `IsLCAxiom` with `RuleSet.none` at
      `.Base`/`.Dense`/`.RTime` — the compiled record is the probe — so any derivation of `lcU` from
      `LC_n` must essentially use a `.ZTime`-only principle (`UZ`/`Z1`, or a naming rule whose
      soundness is `.ZTime`-only). State in the same paragraph that this says nothing against
      `LCRulesComplete` or `LCURulesComplete` at `.ZTime`, where `lcU` IS valid, and that all three
      targets remain stated-and-unproved.
- [ ] Measure each new declaration's axiom profile with `lake env lean` / `lean_verify` and add a
      `#guard_msgs`-gated `#print axioms` block for each to
      `Tests/BimodalTest/Metalogic/LCExtensionTest.lean`, following that file's existing block
      shape. A live `#print axioms` under `FormalSystem/` is allow-listed for
      `FormalSystem/MainResults.lean` alone, which is why the pins go in the test module. Never type
      an expected profile from this plan or the report.
- [ ] Update `Tests/BimodalTest/Metalogic/LCExtensionTest.lean`'s own module docstring: it says the
      file pins "six load-bearing declarations" and that "All six sit at the same ceiling,
      `[propext, Classical.choice, Quot.sound]`". Correct the count, and state the uniformity claim
      only if the four measured profiles actually support it — if one differs, record which and
      why, rather than re-baselining the sentence to fit.
- [ ] Regenerate `typst/generated/status.typ` with `bash scripts/typst-sync-check.sh --fix` and
      stage it in the SAME commit as the `.lean` changes.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: `LCExtension.lean` is 375 lines at authoring time (read live via `wc -l`,
matching `FormalSystem/Metalogic/README.md`'s inventory row), so the `longFile` ceiling is not in
play; this phase adds an estimated 90-120 lines there and 30-45 lines to the test module.
`LCExtension.lean`'s direct dependents are asserted to be exactly two — the root aggregator
`FormalSystem.lean` and `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` — from a repo-wide grep
for `Metalogic.LCExtension` at authoring time. Confirm BOTH with `wc -l` and a re-run of that grep
at implementation time rather than trusting the carried figures; if the dependent set has grown,
the Tier Justification's enumerated build set grows with it.

**Tier Justification**: The added `import … Deterministic.Validity` changes this module's position
in the import DAG, which no single-module build can observe, so the covering check is the changed
module plus its enumerated direct dependents —
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.LCExtension`
and
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest.Metalogic.LCExtensionTest`
— together with `bash scripts/check-metalogic-cycles.sh`, which is the only check that observes the
import-graph assertions (cycle set and upward-import allowlist) a module build cannot.

**Files to modify**:
- `FormalSystem/Metalogic/LCExtension.lean` - the added `Deterministic.Validity` import, the four
  new declarations with their docstrings and `Paper:` anchors, the `## Main Results` additions, and
  the completeness-target paragraph recording the non-derivability verdict
- `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` - four new guard-gated axiom-pin blocks with
  measured profiles, in the file's existing block shape, and the corrected count and uniformity
  sentences in its module docstring
- `scripts/check-metalogic-cycles.sh` - only if assertion B reports a surplus upward edge, per
  Condition 5 of `plan-authoring-gate-collisions.md`
- `typst/generated/status.typ` - regenerated line-count fields (`--fix`), staged in the same commit

**Verification**:
- Both scoped guarded builds green and warning-free on the four new declarations: no
  `linter.autoImplicit`, no `docBlame`, no unused-variable warning. CI builds with `--wfail`.
- `bash scripts/check-metalogic-cycles.sh` green (all three assertions), confirming no new cycle and
  no upward-import surplus; if the allowlist had to be extended, the extension landed in this same
  phase.
- `lean_verify` (or `#print axioms` via `lake env lean`) on each of the four fully qualified names:
  no `sorryAx`, no custom axiom, and each measured profile equal to the value written into the test
  module's expected block.
- The test module compiles — which is what makes the four pins build-breaking rather than
  decorative — and its docstring's declaration count matches the number of blocks it now carries.
- Each of the four new declarations carries a docstring and a `Paper:` anchor line, confirmed by
  reading them.
- The completeness-target paragraph names `.Base`/`.Dense`/`.RTime` and `RuleSet.none` explicitly
  and does not assert anything about `.ZTime` derivability or about any target holding.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 BEFORE the commit is attempted.

---

### Phase 4: Theorem-Index Rows for the Four New Declarations [NOT STARTED]

**Goal**: The repository's per-theorem ledger carries the four new `LCExtension.lean` results, so
they are findable the same way every other declaration in that module is — and so C17's
dead-declaration scan sees them.

**Tasks**:
- [ ] **Territory gate first.** Re-read `docs/theorem-index.md` immediately before editing and check
      899's live status in `specs/state.json` plus `git log -- docs/theorem-index.md`. If 899 holds
      uncommitted changes in the file, or is `implementing`, close this phase `[BLOCKED]` with the
      observed state recorded and proceed to Phase 5; do not edit the file and do not add a
      `dependencies[]` edge (see "Territory").
- [ ] Add one row per new declaration, in the `### ` section and row shape the existing
      `FormalSystem.Metalogic.LCExtension.*` rows use (at authoring time: rows for
      `isLCAxiom_plusValidZTime` through `LCURulesComplete`, immediately preceding the
      `Deterministic/` rows). Each row names the fully qualified declaration, its file, its frame
      class and its axiom-profile cell, matching the measured profiles from Phase 3 rather than any
      figure in this plan.
- [ ] Write each row's description to state what the declaration is for and what it does NOT claim:
      the collapse computation; `lcN`'s deterministic validity with the note that `.Base` validity
      of `lcN` is not needed for it; the axiom-set discharge over `DetSat .Base`; and the
      deterministic-class soundness arm, with the non-derivability consequence stated at
      `.Base`/`RuleSet.none` and the `.Base`-validity question left "open and unclaimed" in those
      words.
- [ ] Confirm C15's second assertion is satisfiable for each new row: every theorem-index row must
      be anchored at its declaration, which requires the `Paper:` anchor line Phase 3 added. If a
      row cannot be anchored, fix the declaration's doc comment in `LCExtension.lean` rather than
      dropping the row.

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts exactly four new rows, one per declaration landed in
Phase 3, inserted into the existing `LCExtension.lean` row block of `docs/theorem-index.md` (851
lines at authoring time, read live via `wc -l`, with the `LCExtension` rows at `:521`-`:530`).
Confirm the insertion point live rather than by line number — a sibling's edits move it — and if
Phase 3 landed a different number of declarations, the row count follows Phase 3, not this
hypothesis.

**Tier Justification**: The edit is confined to one markdown file with no compile surface at all,
so the covering check is the structural, build-free pass that actually reads this file —
`bash scripts/check-module-invariants.sh --no-build` — whose C15 second assertion (every
theorem-index row anchored at its declaration), C12 (slash-shaped source paths resolve) and C13
(relative markdown links resolve) are the three checks a theorem-index edit can break; no Lean
build is involved and none is claimed.

**Files to modify**:
- `docs/theorem-index.md` - four new rows for the `LCExtension.lean` declarations landed in Phase 3
  (**held concurrently by task 899** — see "Territory"; this file exists and was read at authoring
  time)

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` reports C15 green with the four new rows
  anchored at their declarations, and C12/C13 green.
- Each of the four rows' axiom-profile cell matches the profile measured in Phase 3 and pinned in
  `LCExtensionTest.lean` — compared cell by cell, not assumed.
- No existing row was reworded or reordered: `git diff` on the file shows only insertions.
- The `git diff` is confined to this task's own four rows; if any other hunk appears, it is a
  sibling's edit and must be reported rather than committed (concurrency note item (5)).

---

### Phase 5: Probe Custody, Reconciliation, Full Gate Set, and the Summary [NOT STARTED]

**Goal**: The compiled record is in version control and watched by CI, every generated surface
matches the tree, the complete gate set is observed green (or green modulo enumerated pre-existing
findings outside this task's file scope), and the verdict is written down in one place a future
reader will find.

**Tasks**:
- [ ] Reduce the probe to what is genuinely probe-shaped. Rewrite
      `specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` so it imports
      `FormalSystem.Metalogic.LCExtension` (which, after Phase 3, reaches
      `Deterministic.Validity`), `FormalSystem.Semantics.Frames.Standard` and
      `FormalSystem.Semantics.Correspondence.DurationFrames`, deletes its own copies of
      `dstab_iff_of_deterministic`, `lcAnte_iff_lcCons_of_deterministic`,
      `lcN_plusValidOn_of_deterministic`, `isLCAxiom_plusValidDetIn_base` and `ext_sound_detIn`, and
      keeps Part II (`QOrd`, `Alt`, `Mq`, `Hq`, `detFq`, `pa`, `dstab_pa_iff`, `lcU_refuted`,
      `detSat_base_Fq`) plus the headline `lcU_not_extDerivable_base`, now referring to the library
      names. Update its header comment to say which halves moved into the library and where.
      **No weakening**: the headline's statement is unchanged, and if any promoted declaration's
      library form does not support it verbatim, stop and report rather than restating the
      obstruction.
- [ ] Track the probe: `git add -- specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean`
      (explicit file pathspec, never a directory or glob add). It is untracked today — see "Premise
      Re-Validation" — and `check-evidence-probes.sh` fails a wired-but-untracked entry with
      `FAIL (untracked: ...)` by design.
- [ ] Re-read `scripts/check-evidence-probes.sh` immediately before editing and match the live
      shape of the `WIRED` array and the comment table that precedes it, not the shape recorded in
      this plan. **This file is confirmed to exist at authoring time** (the array and its comment
      table were read directly; the array is at `:2238`-`:2292`). Add the collection-relative entry
      `"lcu-lcn-separation/lcu-lcn-separating-model"` — the `WIRED` form, not `WIRED_REPO`, which is
      for a stranded probe only — plus its comment-table row saying what the probe holds in place:
      `lcU` is not derivable from TM⁺ + `LC_n` + mirror at `.Base` with `RuleSet.none`. If the
      file's structure has changed under a sibling's edits, follow the live structure; if it is
      absent or unreadable, close this phase `[BLOCKED]` and record the observed state rather than
      inventing a wiring mechanism.
- [ ] Regenerate the module-inventory blocks with
      `bash scripts/check-module-invariants.sh --emit-inventory`. The targets are the
      `<!-- BEGIN GENERATED: inventory -->`-carrying READMEs on the edited files' ancestor chains:
      `FormalSystem/PlusLanguage/README.md`, `FormalSystem/Metalogic/README.md` and the root
      `README.md`. Do not hand-edit a generated block; stage only the files the generator actually
      changed.
- [ ] Run the full gate set (below) and read each verdict. For any failure, determine whether it
      names a file this task touched. A gate whose only failures are pre-existing and outside this
      task's file scope is a recorded PASS for this phase, WITH the pre-existing findings
      enumerated in the summary and with evidence that each touched file passes individually. It is
      not grounds to edit an out-of-scope file.
- [ ] If C20's third assertion reports a NEW name-bearing citation finding caused by this task's
      docstring line shifts, re-anchor the citation if it lives in a file this plan may touch, or
      record it as an enumerated out-of-scope finding and, where the recorded baseline is the right
      carrier, update `scripts/c20-declaration-baseline.txt`.
- [ ] Grep each docstring edited in Phases 2 and 3 to confirm the retained hedges are present: the
      words "open and unclaimed" still attach to every `.Base` **validity** sentence, and every new
      derivability sentence names its frame class and `RuleSet.none`.
- [ ] Write
      `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/summaries/01_lcu-lcn-separating-model-summary.md`
      carrying: the verdict sentence (the deliverable's separating-model branch was reached and
      compiled; the `.ZTime` question is open and not settleable by any model); what landed and
      where; the measured axiom profile of each new declaration; which branch of Phase 1's
      choice-free decision was taken and why; every pre-existing gate finding enumerated; the
      argued-not-compiled items left standing (Findings 8 and 9, and the guarded until-form); the
      two recorded follow-ups (Recommendation 4's converse question, and the `formal`-extension
      pattern file that must be sited in the source-store repository); and any phase that closed
      `[BLOCKED]` on territory.

**Timing**: 1.25 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the inventory regeneration touches exactly three READMEs —
`FormalSystem/PlusLanguage/README.md`, `FormalSystem/Metalogic/README.md` and the root `README.md`
— established at authoring time by grepping the candidates on the edited files' ancestor chains for
`BEGIN GENERATED` (`FormalSystem/README.md` is a fourth candidate and is included in the run, but
whether the generator rewrites it is not asserted). Confirm by running `--emit-inventory` and
reading which files the script reports as changed; if it names a further target, that target is in
scope for this phase and is staged with the others, and if it names fewer, stage only what it
changed rather than touching a file the generator left alone. The phase also asserts the reduced
probe is roughly 110-130 lines, down from 189; the real figure follows from what Phase 3 promoted.

**Files to modify**:
- `specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` - reduced to Part II plus the
  headline, importing the promoted library halves; newly tracked by git (this file exists and is
  untracked at authoring time)
- `scripts/check-evidence-probes.sh` - the new `WIRED` entry and its comment-table row (file
  confirmed present at authoring time)
- `FormalSystem/PlusLanguage/README.md` - regenerated module-inventory block
- `FormalSystem/Metalogic/README.md` - regenerated module-inventory blocks
- `README.md` - regenerated module-inventory block
- `FormalSystem/README.md` - regenerated module-inventory block, only if the generator actually
  rewrites it (it is a candidate on the ancestor chain, not an asserted target; stage only what
  the generator changed)
- `scripts/c20-declaration-baseline.txt` - only if a C20 re-anchor requires it
- `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/summaries/01_lcu-lcn-separating-model-summary.md` -
  new file: the implementation summary

**Verification**:

The complete gate set for this repository, all six observed in this dispatch and none trusted on
sight:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — the full project build,
  green and warning-free (CI uses `--wfail`).
- `bash scripts/check-module-invariants.sh` — green, or green modulo enumerated pre-existing
  findings outside this task's file scope. C2's pinned axiom baseline and C14's documented counts
  are HARD STOPS if either diverges.
- `bash scripts/check-metalogic-cycles.sh` — green on all three assertions, with the import added in
  Phase 3 in place.
- `bash scripts/typst-sync-check.sh` — green (not only `--counts-only`).
- `bash scripts/check-evidence-probes.sh` — green, with the new probe counted, tracked and
  compiling, and no pre-existing probe newly red. A `FAIL (environment: ...)` line is not probe rot
  (see Risks) and is re-run rather than repaired.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` — reports no stale generated
  inventory block.

Additionally:
- `git ls-files specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` returns the path —
  the probe is in version control, not merely on disk.
- An exact-name sweep confirms all five Goals identifiers are present under `FormalSystem/`, with
  the signatures pinned in `## Lean Challenge Statements` below, and that each is declared exactly
  once (no surviving duplicate in the probe).
- The reduced probe contains zero occurrences of `sorry`.
- `.claude/scripts/verify-deploy.sh` is NOT run and is not part of this task's gate set: it gates
  the agent-system deploy tree, and this task touches no file under the source store (which is not
  on this filesystem at all — see Non-Goals). Recorded so its absence is a decision rather than an
  omission.

---

## Lean Challenge Statements

The five signatures this plan commits to, lifted from the compiled probe. Bodies are `sorry` here
by the section's own rule; the real bodies are transcribed verbatim from
`specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean`. `plan-compliance.md`'s Statement
Fidelity clause governs these signatures: a same-named but weaker restatement has not executed this
plan, whatever else compiles.

```lean
import FormalSystem.Metalogic.LCExtension
import FormalSystem.Metalogic.Deterministic.Validity

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusTruth
open FormalSystem.Metalogic.Deterministic FormalSystem.Metalogic.LCExtension

variable {F : TaskFrame}

theorem dstab_iff_of_deterministic (hD : F.Deterministic) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    PlusTruthAt M τ t (PlusFormula.dstab φ) ↔ PlusTruthAt M τ t φ := sorry

theorem lcAnte_iff_lcCons_of_deterministic (hD : F.Deterministic) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (n : ℕ) (α : ℕ → PlusFormula) :
    PlusTruthAt M τ t (lcAnte n α) ↔ PlusTruthAt M τ t (lcCons n α) := sorry

theorem lcN_plusValidOn_of_deterministic (hD : F.Deterministic) (n : ℕ) (α : ℕ → PlusFormula) :
    F.PlusValidOn (lcN n α) := sorry

theorem isLCAxiom_plusValidDetIn_base {ψ : PlusFormula} (h : IsLCAxiom ψ) :
    PlusValidDetIn .Base ψ := sorry

theorem ext_sound_detIn {fc : FormalSystem.ProofSystem.FrameClass} {Ax : PlusFormula → Prop}
    {R : RuleSet} (hClock : R.clock = false) (hFwd : R.aaFwd = false) (hBwd : R.aaBwd = false)
    (hAx : ∀ ψ, Ax ψ → PlusValidDetIn fc ψ) {φ : PlusFormula}
    (d : ExtDerivation fc Ax R φ) : PlusValidDetIn fc φ := sorry
```

Note on the import block: the two `import` lines make the block self-contained as an isolated
Challenge module, but in the library `dstab_iff_of_deterministic` lands in
`FormalSystem/PlusLanguage/PlusDeterminism.lean` (Phase 1, namespace
`FormalSystem.PlusLanguage`, no new import) and the other four in
`FormalSystem/Metalogic/LCExtension.lean` (Phase 3, namespace
`FormalSystem.Metalogic.LCExtension`, one new import). The `open`s above reproduce the probe's own
context so the signatures elaborate as written; they are not a prescription for the library
modules' `open` lists, which Phase 3's reconciliation step keeps as narrow as possible.

## Testing & Validation

- [ ] Full project build green and warning-free under the build guard (CI uses `--wfail`, so a
      linter warning is a failure).
- [ ] Each of the five new declarations verified `sorryAx`-free with a MEASURED axiom profile, and
      the four `LCExtension.lean` profiles pinned by `#guard_msgs`-gated blocks in
      `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` that compile.
- [ ] `scripts/check-metalogic-cycles.sh` green with the new `Deterministic.Validity` import in
      place.
- [ ] `scripts/check-evidence-probes.sh` green with the new probe tracked, wired and compiling.
- [ ] `scripts/typst-sync-check.sh` green (full run, not `--counts-only`), and
      `check-module-invariants.sh --emit-inventory --check` reporting no stale block.
- [ ] `scripts/check-module-invariants.sh` green, or green modulo enumerated pre-existing findings
      outside this task's file scope, with C2 and C14 treated as hard stops.
- [ ] Every `.Base` **validity** sentence in the edited docstrings still carries "open and
      unclaimed"; every new derivability sentence names its frame class and `RuleSet.none`; no
      sentence anywhere asserts a `.ZTime` derivability verdict or a completeness claim.
- [ ] The reduced probe's headline `lcU_not_extDerivable_base` is unchanged in statement.

## Artifacts & Outputs

- `FormalSystem/PlusLanguage/PlusDeterminism.lean` — `dstab_iff_of_deterministic`, the amended
  stable-surface list and the amended C4 axiom-pin block.
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` — the recorded non-derivability verdict, the
  `.ZTime` no-separating-model statement, and the guarded-until-form candidate note.
- `FormalSystem/Metalogic/LCExtension.lean` — `lcAnte_iff_lcCons_of_deterministic`,
  `lcN_plusValidOn_of_deterministic`, `isLCAxiom_plusValidDetIn_base`, `ext_sound_detIn`, the new
  import, and the completeness-target paragraph.
- `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` — four new measured axiom pins.
- `docs/theorem-index.md` — four new ledger rows (territory-contended; may close `[BLOCKED]`).
- `specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` — tracked, wired, reduced to the
  ℚ model plus the headline.
- `scripts/check-evidence-probes.sh` — the new `WIRED` entry and comment-table row.
- `FormalSystem/PlusLanguage/README.md`, `FormalSystem/Metalogic/README.md`, `README.md`,
  `typst/generated/status.typ` — regenerated or hand-amended generated surfaces.
- `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/summaries/01_lcu-lcn-separating-model-summary.md`
  — the implementation summary.

## Rollback/Contingency

Every phase commits once, green, so rollback granularity is one phase. Nothing here changes an
existing declaration's statement or an existing proof, so a revert cannot break a downstream
consumer: the Lean additions are new names, and the rest is docstrings, markdown and generated
surfaces.

- **A phase fails mid-way**: fix forward — correct the source. Never discard uncommitted changes to
  reach a passing build (`rules/error-handling.md`'s write-gating constraint). If a defensive
  checkpoint is wanted before the Phase 3 import change, use
  `bash .claude/scripts/git-snapshot.sh 906 --no-revert`, never the default reverting form, which
  is forbidden under concurrency by the dispatch's own note item (3).
- **Phase 1's measurement forces the non-`[propext]` branch**: that is a planned branch, not a
  failure. Take it, and do not widen `PlusDeterminism.lean`'s choice-free claim.
- **Phase 3's import trips `check-metalogic-cycles.sh` assertion B**: extend the allowlist in the
  same phase (Condition 5). If assertion A reports a new cycle instead, revert the import, close
  the phase `[BLOCKED]`, and report — the declarations would then need a new module, which is
  outside this plan's shape and needs a plan revision rather than an improvised deviation.
- **Phase 4 is territory-blocked by 899**: close it `[BLOCKED]` per `status-markers.md`, record the
  observed state (899's status and `git log -- docs/theorem-index.md`), and leave the rows for a
  follow-up round. The four declarations stand without their ledger rows; nothing gates on their
  presence. If the rows land only partially — some added, some not — the heading is
  `[COMPLETED WITH EXCLUSIONS]` instead, and it then REQUIRES a `#### Reasoned Exclusions`
  subsection in the phase body with `Item | Reason | Evidence` columns; do not use that marker
  without the record.
- **A gate is red for pre-existing reasons outside this task's file scope**: recorded PASS with the
  findings enumerated (Condition 4). Never edit an out-of-scope file to force a zero.
