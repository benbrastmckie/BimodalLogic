# Implementation Summary: Task #856

- **Task**: 856 - Build the L^▷ proof system: OpenAxiom, OpenDerivationTree, soundness and conservativity
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T16:30:00Z
- **Completed**: 2026-11-05T18:20:00Z
- **Effort**: ~1h50m wall clock across two dispatches, 15 of 15 phases
- **Dependencies**: 854 (completed), 859 (completed) — the ▷-definability gate, both verdicts in
- **Artifacts**: plans/01_open-proof-system-soundness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The L^▷ proof system exists, is sound at every frame class, and is conservative over TM⁺ in both
directions and over TM at all four classes, with the collapse to TM⁺ under `Determined` recovering
the landed deterministic completeness. All three of the task's acceptance baselines are
discharged. Eight new Lean files, sorry-free, zero new axioms, every declaration's axiom profile
measured and equal to the semantic half it lifts. **No completeness is claimed for L^▷ at any
frame class, in any form**, and the canonical-bundle obstruction one language down is untouched:
`plus_incomplete_base` stands as proved, `blc` stays a non-theorem, and an LC_n-style schema is
still required in L^▷ exactly as in L⁺.

## What Changed

### `FormalSystem/OpenLanguage/` — the syntax layer (Phases 1-5)

- `OpenAxioms.lean` — new, 580 lines. `IsPureFutureOpen` / `IsPurePastOpen` (the crossed,
  recursively-guarded purity predicates); `OpenFormula.kPlus` / `kMinus`; the 71-constructor
  `OpenAxiom` (18 restricted-modal + 53 TM⁺ mirrors); the 71-arm **wildcard-free**
  `OpenAxiom.minFrameClass`, whose eight non-`.Base` arms match `PlusAxiom.minFrameClass` exactly;
  nine `rfl` pins; the five-surface extension recipe, the class-split statement and the
  no-completeness guard.
- `OpenDerivation.lean` — new, 383 lines. `OpenContext`; `OpenDerivationTree` (seven rules, no
  eighth); `lift` / `height` / `ofWeakeningNil` and the height lemmas the soundness recursion's
  termination argument consumes; `OpenDerivable` with `mono`; three derived necessitation rules;
  `OpenDerivationTree.ofPlus` and `openDerivable_of_plusDerivable` — **backward conservativity
  over TM⁺** — with its four class rows.
- `OpenErasure.lean` — new, 482 lines. `eraseOpen` and its retraction `eraseOpen_ofPlus`; the
  purity transports; `dischargeAxiom`, a 71-arm wildcard-free table producing a TM⁺ derivation of
  each schema's erasure; `OpenDerivationTree.erase`; `plusDerivable_of_openDerivable` —
  **forward conservativity over TM⁺, unconditional** — and `plusDerivable_openDerivable_iff`,
  both directions.

### `FormalSystem/Metalogic/Conservativity/Open/` — the metatheory (Phases 6-13)

- `OpenAxiomValidity.lean` — new, 2,587 lines. The two L^▷ purity congruences
  (`openTruthAt_congr_agreeFrom` / `openTruthAt_congr_agreeUpTo`); the time-shift infrastructure
  `openTruthAt_congr_ext` / `openTruthAt_timeShift`; the `K±` clause lemmas `openKPlus_iff` /
  `openKMinus_iff`; nine clause-lemma re-exports over the `StabClauses OpenFormula` instance; a
  per-constructor validity theorem **and** a reflection-validity theorem for each of the 71
  constructors; thirteen block aggregates whose covered-name lists partition the constructor set
  exactly (14+4+4+6+8+6+4+4+5+6+2+6+2 = 71); and the two **wildcard-free 71-arm** dispatch lemmas
  `openAxiom_validIn_min` / `openAxiom_reflect_time_validIn_min` with their `fc`-indexed liftings.
- `OpenSoundness.lean` — new, 252 lines. `openReflectTime_allFuture`; the simultaneous recursion
  `open_derivable_valid_and_reflect_time_validIn` (seven cases, no wildcard, well-founded on
  derivation height); **`open_soundness_validIn`** and the context form `open_soundness_in`; the
  four class rows; `open_not_derivable_nil_bot` (consistency at `.Base`); three acceptance checks.
- `Forward.lean` — new, 218 lines. `forward_open` and its four class rows;
  **`openDerivable_ofFormula_iff`** and its four class rows — conservativity over TM, both
  directions; **`openDerivable_ofPlus_iff`** — conservativity over TM⁺, both directions,
  unconditional and syntactic, carrying no engine argument; the no-completeness guard and the
  class-split paragraph; three acceptance checks.
- `Open.lean`, `Open/README.md` — the aggregator and the module table.

### `FormalSystem/Metalogic/Deterministic/OpenCollapse.lean` — the collapse (Phase 14)

New, 209 lines. `openTruthAt_eraseOpen_of_deterministic` (`⊡ = ▷ = ◁ = id` on a deterministic
frame); `OpenValidDetIn` with its adapters; the validity equivalences; and
`detDerivable_eraseOpen_of_openValidDetIn`, the landed `detCompleteness` recovered through the
composite erasure.

### Ledger surfaces (Phase 15)

- `docs/theorem-index.md` — sixteen new rows across the `OpenLanguage` section, each with a
  fully-qualified Lean name, file, frame class and **measured** axiom set; the section preamble
  rewritten from "semantic only" to the system's actual scope plus the no-completeness and
  class-split guards.
- `scripts/check-module-invariants.sh` — eleven new C14 baseline pairs (one `C14_BASELINE` line
  and one matching `#print axioms` line each).
- `scripts/module-invariants-allowlist.txt` — two C5 entries for `OpenAxiom` and
  `OpenDerivationTree`, declaration names the module-path regex cannot distinguish from modules.
- `FormalSystem.lean` — regenerated via `lake exe mk_all --lib FormalSystem`.
- Nine now-false "semantic only" claims rewritten, and the generated inventory blocks regenerated.

## Decisions

- **Prove the 53 TM⁺ mirror schemata directly against `OpenTruthAt`; never atomize, never
  substitute uniformly.** `Conservativity/Plus/Atomization.lean` discharges 45 of its 53 arms by
  reduction to the landed L schemata, and that route is unavailable here for two independent
  reasons: atomization rests on `stab_state_only` and `▷χ` is **not** state-local (two histories
  sharing a state at `t` need not agree up to `t`), and TM⁺ is not substitution-closed because
  `atom_stab` is deliberately atom-restricted. Recorded in the propositional block's docstring so
  the shortcut is not re-attempted.
- **State each reflection helper as `OpenValid (<the literal schema>).reflectTime`.** This is the
  single highest-leverage decision in the task. Because that shape is syntactically what the
  dispatch's goal becomes after `cases ax` beta-reduces the constructor index, all 142 arms of the
  two dispatch lemmas are a bare `exact` — no `simp only [OpenFormula.reflectTime, ...]`
  normalisation at any of them. `StarAxiomValidity.lean` instead lands each reflection arm on the
  *mirror schema at reflected parameters*, which only a `reflectTime` normalisation can reach, and
  pays a per-arm `simp only`. The same shape also means `openValid_reflectTime` discharges every
  `.Base` reflection half, including both pasting arms, so **no reflection lemma for
  `IsPureFutureOpen` / `IsPurePastOpen` is owed at all** — Star needs `hφ.reflectTime` at both.
- **The TM⁺ conservativity row is syntactic, not semantic, and is not modelled on
  `starConservative_of_plusComplete`.** That row's hypothesis is general TM⁺ completeness at `fc`,
  which is *false* at `.Base` by `plus_incomplete_base`. This task's row goes through `eraseOpen`'s
  71-arm discharge table and `eraseOpen_ofPlus`, never through validity, so it carries no engine
  argument. **The measured axiom profile is the mechanical evidence**:
  `openDerivable_ofPlus_iff` is `[propext, Quot.sound]` — **no `Classical.choice`** — while every
  other headline declaration in the task measures all three. A row that passed through a canonical
  model could not have that profile.
- **The eight class-restricted reflection halves could not use `openValid_reflectTime`**, which is
  stated at the unconstrained class only. Four route to their past twin at the reflected parameter
  (`prior_UZ`↔`prior_SZ`, `prior_U_gap`↔`prior_S_gap`) and typecheck by `rfl`, every
  `reflect_time_*` identity involved holding definitionally; `z1`, `density`, `dense_indicator` and
  `sep` have no twin among the schemata and their duals are proved directly, as
  `StarAxiomValidity.lean` does.
- **The five discrete-uniformity schemata transport** from `plusAxiom_validIn_min` rather than
  being proved directly: each records a *frame-level* uniformity fact proved once at the L level,
  so a direct L^▷ proof would re-derive frame reasoning rather than transcribe a truth-clause
  argument. Their `PlusFormula` argument is passed explicitly at each site, since
  `ofPlus ?φ =?= <concrete OpenFormula>` is a higher-order unification problem.
- **`OpenFormula.kPlus` / `kMinus`, `openReflectTime_allFuture` and `openTruthAt_timeShift` live
  outside `OpenLanguage/Formula.lean`**, beside their only consumers, so that file's module
  invariants stay untouched — the same placement decision `OpenContext` already records.
- **Long files are baselined, not split.** `OpenAxiomValidity.lean` crossed the package-level
  1500-line `longFile` ceiling at Phase 10 and carries `set_option linter.style.longFile 2600`
  with the reason comment `docs/development/LEAN_STYLE_GUIDE.md` requires, which explicitly states
  that splitting a file only to satisfy that linter is not a justification for the split.

## Plan Deviations

- **Phase 7** altered: two supporting theorems (`openTruthAt_congr_ext`, `openTruthAt_timeShift`)
  and a clause-lemma re-export section were added inside the phase's single declared file, because
  the `modal_future` arm moves the time of evaluation and no L^▷ `timeShift` lemma existed.
- **Phases 8 and 9** altered: `openValid_reflectTime` pairs a schema with *its own* time
  reflection, which is what the dispatch's reflection arm owes; it does not let a past-mirror
  *constructor* inherit its future twin's validity arm. Each past-mirror constructor therefore got
  its own direct proof. In Phase 9 a mirror transport could not have worked anyway: the future and
  past linearity schemata differ in disjunct nesting (`linear_until`/`temp_linearity`
  right-associated, `linear_since`/`temp_linearity_past` left-associated).
- **Phase 10** altered: the pasting arms consume the **L^▷** purity congruences, not the L⁺
  `truth_congr_agreeFrom` / `truth_congr_agreeUpTo` the plan named — the L⁺ halves are statements
  about `PlusTruthAt` and a pure L^▷ formula may contain the crossed restricted modal.
- **Phase 13** altered: `openDerivable_ofPlus_iff` is a one-line re-export of
  `OpenLanguage.plusDerivable_openDerivable_iff`, which Phase 5 had already landed as exactly the
  composition the plan's bullet describes. The plan-named declaration exists at the plan-named
  signature with no engine argument; the proof is not duplicated.
- **Phase 15** altered: the re-run grep the task itself mandates found **nine** now-false
  "semantic only" occurrences, not the plan's three. All nine were rewritten;
  `docs/theorem-index.md:595` and the Hybrid/Nomic/Quant occurrences, which concern other
  components and remain true, were left alone.

Every deviation is annotated inline on the corresponding plan checklist item. No named plan
declaration was skipped, and none was landed at a weaker signature.

## Verification

- **Build**: Success — unscoped guarded `lake build`, exit 0, 2908 jobs, zero `error:`, **zero
  `warning:`**. Every phase was additionally gated on a full-library build before its commit.
- **Sorry count**: 0 (`lean-sorry-census.sh` over all resolved source roots).
- **Vacuous count**: 0 attributable. The single grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, is pre-existing, untouched by this task,
  and a false positive of the single-line pattern.
- **Axiom count**: no new `axiom` declaration in any of this task's files.
- **Axiom profiles, measured per declaration** and compared against the semantic half each lifts:

  | Declaration | Axioms | Comparison |
  |---|---|---|
  | `openAxiom_validIn_min` | `[propext, Classical.choice, Quot.sound]` | = `plusAxiom_validIn_min` |
  | `openAxiom_reflect_time_validIn_min` | `[propext, Classical.choice, Quot.sound]` | = its L⁺ twin |
  | `open_soundness_validIn` | `[propext, Classical.choice, Quot.sound]` | = `star_soundness_validIn` |
  | `openDerivable_ofFormula_iff` | `[propext, Classical.choice, Quot.sound]` | = `starDerivable_ofFormula_iff` |
  | `openDerivable_ofPlus_iff` | `[propext, Quot.sound]` | **narrower** — no `Classical.choice` |
  | `plusDerivable_of_openDerivable` | `[propext, Quot.sound]` | syntactic, choice-free |
  | `openTruthAt_timeShift` | `[propext, Classical.choice, Quot.sound]` | = `plusTruthAt_timeShift` |
  | `openTruthAt_congr_agreeFrom` | `[propext]` | narrower than its consumers |
  | `OpenDerivationTree` | `[propext]` | = `StarDerivationTree` |
  | `openTruthAt_eraseOpen_of_deterministic` | `[propext]` | — |
  | `detDerivable_eraseOpen_of_openValidDetIn` | `[propext, Classical.choice, Quot.sound]` | = `detCompleteness` |

  Nothing picked up `Classical.choice` where the semantic half was choice-free.
- **`scripts/check-metalogic-cycles.sh`**: exit 0, all three assertions PASS (one directory-level
  cycle, the recorded 10 upward imports, no syntax module importing a semantics module).
- **`scripts/check-module-invariants.sh`** (bare, no flags): exit 1 on **one** group, `C16`, which
  is a single `unusedArguments` finding at
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136` — a different file and a
  different component, clean in the working tree and last changed in another task's commit. Every
  finding attributable to this task was repaired: `INV` (five stale generated inventory blocks),
  `C5` (two declaration names shaped like module paths), `C15` (thirteen theorem-index rows
  unanchored at their declaration) and `C33` (two modules missing from the generated root). INV,
  C5, C14 (both halves), C15 (both halves), C17, C19, C21, C23, C24, C26, C28, C33, C35, C36 and
  C37 all PASS.
- **`--emit-inventory --check`**: exit 0 — no generated block would change.
- **Plan compliance**: `COMPLIANCE_CHECK: passed` — every declaration named in the plan's
  `## Lean Challenge Statements` block resolves in the source roots.
- **Tests**: N/A — the task adds no test-suite target. The nine `example` acceptance checks
  embedded in the three new metatheory files elaborate on every build.
- **Files verified**: Yes.
- **Full gate set**: **deferred to the batch stage** per this dispatch's own directive, and the
  deferral is recorded in Phase 15's verification notes in the plan. The narrowing invocations the
  directive names (`run-all.sh --only`, `verify-deploy.sh --only-gate`) cover agent-system shell
  suites and deployed `.claude/` tree integrity; this task touched no file under `.claude/**` and
  no agent-system script, so neither has a suite or gate covering its `modified_files`. The gates
  that do cover them are this repository's own, and those were run in full and are tabulated above.

## Impacts

- L^▷ is no longer a semantics without a logic. `OpenAxiom`, `OpenDerivationTree` and
  `open_soundness_validIn` are the prerequisite 559 named for any completeness statement about
  L^▷; that statement is now **statable**, which it was not before.
- The TM⁺ conservativity row is **unconditional and statable**, in deliberate contrast to
  `Conservativity.starConservative_of_plusComplete`, whose hypothesis is false at `.Base`. Any
  future task comparing the two languages' proof power can cite it without an engine.
- The constructor set is closed and the closure is **enforced**: four wildcard-free 71-arm
  dispatches (`minFrameClass`, `dischargeAxiom`, and the two validity dispatches) mean a new
  `OpenAxiom` constructor is a build error at four sites rather than a silent gap at any.
- `openTruthAt_timeShift` and `openTruthAt_congr_ext` are new, reusable L^▷ semantic
  infrastructure that `OpenLanguage/` did not carry.
- Eleven new C14 baseline pairs mean every headline row of this component is axiom-pinned on every
  build, so an axiom regression in it is a hard stop rather than a silent widening.

## Follow-ups

- **A generic schema-validity layer.** The 53 TM⁺ mirror schemata were discharged directly against
  `OpenTruthAt` because atomization is unavailable; `StarAxiomValidity.lean` paid the same cost
  against `StarTruthAt`. Stating those schemata once over `[TruthEnv L] [StabClauses L]` in
  `Semantics/TruthClauses.lean` would serve L⁺, L⋆ and L^▷ at once and remove roughly 1,500 lines
  of parallel transcription across two files. Recorded in `Conservativity/Open/README.md` as
  deliberately out of scope here.
- **The missing `reflect_time_*` push-through lemmas on `OpenFormula`.** Ten identities
  (`neg`, `and`, `or`, `allFuture`, `allPast`, `top`, `diamond`, `kPlus`, `kMinus`, `iff`) hold by
  `rfl` but are unnamed; `openReflectTime_allFuture` was declared in `OpenSoundness.lean` because
  one was needed there. Landing all ten beside the existing five would be tidier.
- **`FAIL C16` is open and belongs to another component**:
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136`,
  `mem_cellAt_of_shift_of_hasForwardSlack`, argument 23 `hslk` unused. It blocks the bare
  `check-module-invariants.sh` gate repo-wide and is not repairable from inside this task.
- **No completeness claim, and none in prospect from here.** 559's binding obstruction —
  closedness of the canonical bundle, to which `▷` and `◁` contribute no closure principle — is
  untouched. An LC_n-style schema is still required in L^▷ exactly as in L⁺.

## References

- `specs/856_open_language_proof_system_and_soundness/plans/01_open-proof-system-soundness.md`
- `specs/856_open_language_proof_system_and_soundness/handoffs/` — per-phase handoffs for phases
  1-15
- `FormalSystem/Metalogic/Conservativity/Open/README.md` — the module table and the atomization
  obstruction
- `FormalSystem/Metalogic/Conservativity/Star/StarAxiomValidity.lean` and `StarSoundness.lean` —
  the templates Phases 7-12 transcribe
- `FormalSystem/PlusLanguage/README.md` — the "Extension recipe" that is this component's
  per-constructor cost model
- `docs/theorem-index.md` — the single ledger, now carrying every result of this task
