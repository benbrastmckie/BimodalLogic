# Implementation Summary: Task #881

- **Task**: 881 - Generic schema-validity layer over TruthEnv/StabClauses
- **Status**: [COMPLETED]
- **Started**: 2026-11-06T08:42:13Z
- **Completed**: 2026-11-06T09:55:00Z
- **Effort**: ~1.2 hours
- **Dependencies**: None
- **Artifacts**: plans/01_generic-schema-validity-layer.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Every TM⁺ mirror schema is now stated **once**, pointwise, over the existing
`TruthEnv`/operator-clause interface, in the new module
`FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` (68 `generic_*` theorems). The L⋆,
L^▷ and L⁺ validity theorems keep every name, statement and attribute they had and became
one-line delegations: 65 bodies in `Star/StarAxiomValidity.lean`, 55 in
`Open/OpenAxiomValidity.lean`, and the six `⊡` arms of both `Plus/AxiomValidity.lean` dispatchers.
All twelve plan phases completed; the full `lake build` and the `BimodalTest` driver are green
with zero errors and zero warnings.

## What Changed

- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` — **new**, 1,440 lines
  (950 code, 299 docstring/prose, 192 blank). 68 `generic_*` theorems plus five gap-translation
  helpers: the propositional, S5-modal and `⊡` tiers; seriality, monotonicity, connection;
  enrichment, self-accumulation, absorption; **both nestings** of `U`/`S` linearity and **both
  disjunct orderings** of temporal linearity; the `F`/`P` equivalences; the discrete-uniformity
  group with `generic_gap_iff`/`generic_cogap_iff`/`generic_gap_shift`/`generic_cogap_shift`/
  `generic_gap_iff_cogap`; density; Prior-Z; Z1; the Reynolds Dedekind tier; and
  `generic_modal_future` under an explicit homogeneity hypothesis. Carries an
  extension-contract docstring in the house style of the two existing layers, including an
  explicit "What is NOT generic" boundary. No lemma carries an attribute.
- `FormalSystem/Semantics/TruthClauses.lean` — `AtomClause` class (`atom`, `atom_clause`),
  `kPlus`/`kMinus` abbrevs, `kPlus_iff`/`kMinus_iff`; tier table and extension-contract updates.
- `FormalSystem/Semantics/Truth.lean`, `MinusLanguage/MinusTruth.lean`,
  `PlusLanguage/PlusTruth.lean`, `StarLanguage/StarTruth.lean`, `OpenLanguage/OpenTruth.lean`,
  `HybridLanguage/HybridTruth.lean`, `QuantLanguage/QuantTruth.lean` — `AtomClause` instances,
  every field `Iff.rfl`. All seven languages confirmed to share the clause shape.
- `FormalSystem/Metalogic/Conservativity/Star/StarAxiomValidity.lean` — 65 of 86 bodies become
  delegations; `starKPlus_iff`/`starKMinus_iff` deleted (no external consumer); docstrings
  rewritten. 1,479 → 1,213 lines.
- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` — 55 of 145
  `openValidIn_*` bodies become delegations; `openKPlus_iff`/`openKMinus_iff` deleted;
  docstrings rewritten; `longFile` baseline tightened 2600 → 2400. 2,587 → 2,298 lines.
- `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` — the six `⊡` arms of both
  dispatchers delegate; docstring records why the 45 TM atomization arms deliberately do not.
  329 → 348 lines.
- `FormalSystem/Metalogic/SoundnessLemmas.lean`, `FormalSystem.lean` — the new module's imports.
- `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` — seven `atom` `rfl` pins and four
  `kPlus`/`kMinus` pin pairs; needed `import FormalSystem.OpenLanguage.OpenAxioms`.
- Four README inventory blocks plus `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`
  and the root `README.md` regenerated; `Last verified` refreshed on the three directories this
  task changed; `Conservativity/Open/README.md`'s row no longer names the deleted `K±` lemmas;
  `Semantics/README.md`'s `TruthClauses.lean` row names `AtomClause` and the gap operators.
- `scripts/lean-citation-manifest.json` — one span end regenerated (`Semantics.TruthAt`,
  273 → 279) via `scripts/export-lean-citations.py`.
- `typst/generated/status.typ` — line-count fields, via the sanctioned
  `scripts/typst-sync-check.sh --fix`.

## Decisions

- **Pointwise, not validity-level.** The generic statements are at `TruthEnv.T M τ t e …`, so a
  wrapper is one `Valid.of_forall`-shaped line and no `PointTruth`/`TruthEnv` bridge class is
  needed anywhere in the tree.
- **`(L := …)` is pinned at every call site.** Without it, unifying `TruthEnv.T (L := ?L) …`
  against a language's own truth relation is left to the elaborator. With it, both large rewires
  compiled on the first attempt.
- **Three reducibility traps, recorded in the module's own prose.** `and`/`or`/`top`/`neg`/
  `someFuture`/`kPlus` are `abbrev`s, so `ImpClause.imp_clause` matches *through* an `and`,
  `UntlClause.untl_clause` matches a `someFuture`, and `neg_iff` matches a `kPlus`. The fix is
  ordering: peel the outermost implication with one `rw`, then use a `simp only` that does not
  mention the swallowing lemma. `StarTruth`'s counterparts do not have this problem because
  `StarFormula.and` is a plain `def`.
- **`[BotClause L]` is not a module-level section variable.** Lean's `unusedSectionVars` linter
  flagged eleven lemmas that never touch `bot`, so `BotClause` is a per-theorem binder on
  exactly the four that need it. The grain invariant is thereby compiler-checked rather than
  asserted, and the module sits at zero warnings.
- **Homogeneity is an explicit hypothesis, not a class field.** The three languages' time-shift
  lemmas genuinely differ (L⋆'s moves the stored-time vector; L^▷'s needed a bespoke
  `openTruthAt_congr_ext`), so no single field covers them. `generic_modal_future` takes the
  consequence MF actually uses.
- **L⁺'s 45 TM arms deliberately keep their atomization route.** Each is the landed L-level
  schema transported through one fixed encoding, and that provenance is the content of TM⁺
  conservativity. Recorded in that file's docstring with the reason.

## Plan Deviations

- **Phase 3, altered**: the four seriality lemmas are stated **without** `[F.IsRegular]`.
  Measured: regularity is not consumed. The content is seriality of the *temporal order*
  (`exists_gt`/`exists_lt` on `F.Duration`), and the L-level `serial_future_axiom_valid` is
  likewise introduced by `Valid.of_forall` with no regularity. Carrying the binder would be the
  non-load-bearing hypothesis `lean4.md`'s vacuity rule prohibits — and precisely the defect that
  phase's own verification criterion was written to catch. The binder-free form is strictly
  stronger and still serves every `of_forall_regular` wrapper.
- **Phase 6, altered**: the eight discrete-uniformity lemmas carry **no** frame-constraint
  binder, because there is none to carry — the five uniformity schemata are valid at
  `FrameClass.Base`, and the only structure consumed is that `F.Duration` is a nontrivial
  linearly ordered abelian group, which every `TemporalOrder` already is. The *no-transport* half
  of the task is executed in full: five generic helpers write the gap-translation argument once,
  replacing the `ofPlus` transports both Star and Open used.
- **Phase 10, altered**: the nine `openTruth_*_iff` re-exports were **kept**. They were already
  one-line delegations to `TruthClauses.*` or `Iff.rfl`, so the plan's "replace with delegations"
  half was a no-op; and four still have consumers after the rewire
  (`openTruth_allFuture_iff`/`openTruth_allPast_iff` from `OpenSoundness.lean`;
  `openTruth_and_iff`/`openTruth_untl_iff` from the pasting block, a declared Non-Goal), so
  deleting the other five would trade nine uniform one-liners for an arbitrary partition.

Both Lean-code deviations resolve a conflict *inside* the plan — its task text asks for a
hypothesis its own verification criterion forbids — in the direction the vacuity rule mandates,
and neither weakens a statement. They are raised here, in the plan checklist, in the issue log
and in the module docstrings rather than annotated silently.

## Verification

- Build: **Success** — full `lake build` through `lake-build-guard.sh`, 2,958 jobs, exit 0,
  **0 errors, 0 warnings**. `.olean` newer than source confirmed for all 14 touched modules.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: **0** in this task's files. The repository-wide grep returns one hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, which is pre-existing (last touched
  2026-10-14), untouched by this task, and not vacuous in substance.
- Axiom count: **14 → 14, unchanged.** Per-declaration: `starAxiom_validIn_min`,
  `openAxiom_validIn_min` and `plusAxiom_validIn_min` are each
  `[propext, Classical.choice, Quot.sound]` before and after — **no axiom gained**. The new
  `kPlus_iff` matches the `starKPlus_iff` it replaces exactly, against the plan's unmeasured
  prediction of `[propext]`.
- Tests: **Passed** — `lake test` (`BimodalTest`), 3,022 jobs, exit 0, 0 errors, including the
  extended `ValidityLayerTest.lean` `rfl` bridge pins. Every new pin elaborates.
- Plan compliance: **passed** — `lean-plan-compliance-check.sh` resolves all seven Goals
  declarations.
- Project gates, each run and each result reported:
  `check-module-invariants.sh --no-build` **ALL CHECKS PASSED** (the three failures it initially
  reported — stale INV blocks, C33's missing root import, C35's drifted citation span — were each
  repaired by its own sanctioned command: `--emit-inventory`, `lake exe mk_all --lib FormalSystem`,
  `export-lean-citations.py`); `check-evidence-probes.sh` **PASS** (52 probes);
  `check-copyright-headers.sh --strict` **PASS** (0 nonconforming of 779);
  `readme-lint.sh` **PASS**; `check-metalogic-cycles.sh` **PASS** (still exactly one
  directory-level cycle in `Metalogic/`); `typst-sync-check.sh` **PASS** (all 4 checks);
  `warning-budget.py` **OK** (0 warnings).
  `reanchor-lean-citations.py --by-name` re-pointed **0** citations across the 13 changed files.
  `scripts/c20-declaration-baseline.txt` **has not grown** (22 lines before and after) and
  `scripts/nolints.json` is **unmodified**.
- **One gate FAILS, and it is not this task's**: `check-paper-definitions.sh` exits 1, reporting
  9 drifted definitions against `docs/reference/paper-definitions-of-record.md`. The drift is in
  the live LaTeX source at `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, outside
  this repository; the first drift shown is a `\begin{enumerate}[wide=0pt, labelsep=.1in,
  itemsep=.075in]` → `\begin{enumerate}[named]` change in `def:task-relation`. This task touched
  no `.tex` file and no file under `docs/reference/` (the record was last committed 2026-10-18),
  so the failure pre-dates this work and is not repaired here.
- Files verified: Yes.

## Impacts

- A fourth language inherits all 68 schemata by declaring `AtomClause` plus the operator bundle
  it already declares; its validity theorems cost one delegating line each. That, not a line
  count, is the deliverable.
- `HybridFormula` and `QuantFormula` now carry `AtomClause` instances and so can consume the
  layer, which the task description did not anticipate — the layer serves more consumers than
  three.
- `TruthClauses.kPlus_iff`/`kMinus_iff` are now the single statement of Reynolds' gap operators;
  the four per-language transcriptions are gone or never existed.
- `Conservativity/Plus/Atomization.lean` and `PlusLanguage/PlusStateLocal.lean` are intact and
  still consumed; nothing was dismantled.

## Follow-ups

- **The task's ~1,500-line-recovery hypothesis is wrong, measured.** Net Lean delta across every
  file this task touched is **8,827 → 9,862, +1,035 lines**: −555 recovered from the two
  transcriptions (Star −266, Open −289) against +1,440 for the new module, +64 for the clause
  interface, +19 for L⁺'s docstring record, and +67 for instances, test pins and aggregators. The
  hypothesis mistook each file's *total* size for its duplicated-proof content: Star's 1,479 lines
  also held 16 register schemata and two 69-arm dispatchers, the removed bodies are replaced by
  2–4-line delegations rather than by nothing, and the new module carries its own
  extension-contract docstring (299 of its 1,440 lines are prose). The payoff is single-statement,
  not fewer lines.
- `check-paper-definitions.sh`'s 9 drifted definitions need a decision by someone who owns the
  paper: re-pin the record or revert the `.tex`. Out of scope here.
- `readme-lint.sh` reports 20 stale `Last verified` dates across the tree. Three belonging to
  directories this task changed were refreshed; the rest pre-date this work.
- The agent-system gate set (`.claude/scripts/tests/run-all.sh`, `verify-deploy.sh`) is deferred
  to this batch invocation's final stage per the dispatch directive — and is vacuous for this
  task, which modified no file under `.claude/**` and no shell script, so no suite in that set is
  scoped to it. The project's own Lean gate set, which is what verifies this work, was run in
  full above.
- The deployed `.claude/` tree is stale for six extensions (flagged in the dispatch). Left alone
  deliberately, per the plan's Non-Goals.

## References

- `specs/881_generic_schema_validity_layer_over_truthenv/plans/01_generic-schema-validity-layer.md`
- `specs/881_generic_schema_validity_layer_over_truthenv/handoffs/` — twelve phase handoffs
- `FormalSystem/Semantics/TruthClauses.lean` — the clause layer's extension contract
- `FormalSystem/Semantics/ValidityLayer.lean` — the validity layer, and the original contract
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` — the new layer
