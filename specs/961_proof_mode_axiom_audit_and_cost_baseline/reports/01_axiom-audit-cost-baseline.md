# Research Report: Task #961

**Task**: 961 - Proof mode: axiom audit and cost baseline (M13, diagnostics standard)
**Started**: 2026-11-24T02:55:00Z
**Completed**: 2026-11-24T03:10:00Z
**Effort**: Medium-large implementation (4 deliverable surfaces: schema doc, emitter commands, audit test module, baseline doc + script)
**Dependencies**: None hard. PR #7 has MERGED (confirmed below), which activates the task's conditional "add one nested logical rewrite to the cost baseline". PRs #8, #9, #10 remain OPEN.
**Sources/Inputs**:
- `records/proof-mode.md` (M13, the three-tier lanes), `records/theorem-library.md` (`## Diagnostics`), `records/proof-mode-architecture.md` (`## Three tiers`)
- `Tests/BimodalTest/WalkthroughAxioms.lean` (the audit pattern), the five `Tests/BimodalTest/Automation/ProofMode*Test.lean` acceptance modules
- `FormalSystem/Automation/ProofMode/` (10 modules), `FormalSystem/Theorems/ProofMode/`, `FormalSystem/Tactic/FormulaViews.lean`
- `data/*.jsonl` + `data/*_metadata.json` (existing record shapes), `BimodalTools/CertificateRecords.lean`, `BimodalTools/DataExport.lean`, `BimodalLib/Registry.lean`
- `specs/evidence/phase5-hoist-kernel-ab/README.md` (the in-repo cost-baseline precedent)
- Five executed `lean_run_code` probes (lean-lsp, index `warming` -> `consulted` on later calls; every figure below is a compiled measurement, not an estimate)
- No literature source is referenced by this task; the Literature Extraction Protocol does not apply.
**Artifacts**: - `specs/961_proof_mode_axiom_audit_and_cost_baseline/reports/01_axiom-audit-cost-baseline.md`
**Standards**: report-format.md, subagent-return.md

**Measurement provenance for every figure in this report**: commit
`521385a908f7a850639e5579707089bae88863be`, toolchain `leanprover/lean4:v4.33.0-rc1`, Mathlib
pinned at tag `v4.33.0-rc1`. Measured 2026-11-24 via `lean_run_code` against the existing
`.olean` build; no rebuild occurred between probes.

## Executive Summary

- **The whole cost baseline was measurable inside research, and is measured below.** Both
  instruments already exist with no new dependency: Mathlib's `#count_heartbeats in <cmd>`
  (`Mathlib/Util/CountHeartbeats.lean`, present in the pinned tree) and
  `Lean.Expr.sizeWithoutSharing`. Nothing needs to be invented; the implementation phase writes
  the harness around two working primitives.
- **The record's open question about `lintro` on long scripts now has a closed-form answer.**
  Elaborated term size for an `n`-deep `lintro` chain is **exactly `5n² + 17n + 41`**, fitting
  every measured depth `n = 2..16` with zero residual (33, 95, 137, 189, 251, 323, 405, 497,
  711, 965, 1593). Heartbeats over the same range are **linear**, ~5.3/level. So the deduction
  theorem's whole-derivation transform costs **quadratic term size but linear elaboration** —
  the quadratic lands on the kernel, not the elaborator.
- **The axiom audit has a real finding, not a formality.** The four tactic families do *not*
  share one axiom profile. `lstart`/`lapply`/`lexact`/`lsplit` scripts rest on `[propext]`
  alone; **a single `lintro`** — and `lcases` on a disjunction — pulls in the full
  `[propext, Classical.choice, Quot.sound]`. TM⁺ rows measure *lighter* than their TM
  counterparts: `[propext, Quot.sound]`, no `Classical.choice`. The merged congruence kit
  (`lrewrite`) is `[propext]` only; `lsimp` inherits whatever its rule list brings.
- **A structural blocker the plan must route around**: `#print axioms` cannot name an `example`
  (verified: `Unknown constant`). All 52 proof-mode acceptance declarations are `example`s, and
  the task forbids changing them. The audit module must therefore declare **named mirrors**
  rather than annotate the existing fixtures.
- **PR #7 is MERGED**, so the conditional nested-logical-rewrite baseline is in scope and is
  measured: term size grows **linearly** at exactly **+346 per nested scope level** from a base
  of 785 (`785 + 346·d`, verified `d = 0..4`). One congruence certificate is already ~8x a basic
  modus-ponens script, confirming the contribution's claim about certificate size — but it grows
  linearly, so `lintro`'s quadratic overtakes it past ~depth 20.
- **Per-tier cost separates cleanly**, as `records/proof-mode-architecture.md` predicts: views
  tier 55-89 term nodes at `[propext]`; derivation tier 99-2413 at a family-dependent axiom set.
- **Recommended approach**: one `DiagnosticRecord` schema in `BimodalLib/Diagnostics/`, keyed by
  the registered declaration's fully-qualified name plus a `stage` enum, emitted as snake_case
  JSONL matching the `data/proof_steps.jsonl` convention and reusing `Formula.toJson` verbatim;
  two emitter commands (`#reprove_record`, `#compare_record`); a named-mirror audit module under
  `Tests/BimodalTest/Automation/`; and `scripts/proof-mode-cost-baseline.sh` driving a probe file
  via `lake env lean`, on the `scripts/typst-machine-appendix.sh` stamping pattern.

## Context & Scope

The task carries four deliverables, three of them added by the revision:

1. **(revision a)** ONE record schema for every stage of the library pipeline — enumerate,
   decide, extract, certify, admit, re-prove, compare — keyed by statement identifier and stage,
   carrying fragment, frame class, commit and the producing command.
2. **(revision b)** The commands that emit the RE-PROVE and COMPARE records for a proof-mode
   script. The cost script is their first consumer; `theorem_library_tableau_pipeline` writes the
   other five stages' emitters against the same schema.
3. **(revision c)** `docs/reference/diagnostics.md`, documenting the schema and every field.
4. **(original)** The axiom audit test module and the cost baseline at
   `docs/development/proof-mode-cost-baseline.md`, with the measuring script checked in.

Scope boundary respected throughout: `FormalSystem/Theorems/` must not import
`FormalSystem/Automation/`; every tactic assembles native `DerivationTree` /
`PlusDerivationTree` constructors and proved rules only; the existing acceptance tests must keep
passing unchanged.

Research deliberately went past "find the right tools" to **actually produce the baseline**,
because the baseline was cheap to measure and the adequacy gate
(`proof_mode_reprove_perpetuity`) depends on this record hard and needs a cost figure to quote.

## Findings

### Codebase Patterns

**The audit pattern is `Tests/BimodalTest/WalkthroughAxioms.lean`.** Each row is a
`#guard_msgs`-pinned `#print axioms` over a *named* declaration, with a module docstring stating
the permitted set (`propext`, `Classical.choice`, `Quot.sound`, or any subset) and naming
`Lean.ofReduceBool` as the hard stop a stray `native_decide` would introduce. The audits are
deliberately filed in the test library, not beside the declarations, so the library module stays
free of debug directives. The pattern transfers without modification.

**`example` is not addressable.** Verified: `#print axioms P6._example` -> `Unknown constant
P6._example`. The five acceptance modules contain **52 `example` declarations** (31 in
`ProofModeTest.lean`, plus one `opaque projectionContract`), all anonymous. Since the task
requires the acceptance tests keep passing *unchanged*, the audit module cannot annotate them in
place and must not rewrite them into `def`s. The sanctioned route is a new module of named `def`s
that mirror one representative script per family.

**Test-library wiring.** `lakefile.toml` sets `testDriver = "BimodalTest"`; the library root is
`Tests/BimodalTest.lean` (120 lines), which already imports `BimodalTest.WalkthroughAxioms`
(line 37) and the five `BimodalTest.Automation.ProofMode*Test` modules (lines 68-72). A new audit
module must be added to that root or `lake test` will never compile it. The `BimodalTest` library
carries `weak.linter.hashCommand = false`, so `#print axioms`, `#guard_msgs` and
`#count_heartbeats` are permitted there and nowhere else in the build graph.

**Tactic families map onto the elaborator modules** (`FormalSystem/Automation/ProofMode/`):

| Family | Module | Tactics |
|---|---|---|
| basic | `Basic.lean` (212 lines) | `lstart`, `lintro`, `lexact`, `lapply`, `lsplit`, `lcases`, `lleft`, `lright`, `lhave` |
| modal | `Modal.lean` (274) | `lmodal_intro`, `lmodal_cases`, `lmodal_use` (and `ltemporal_intro`, which lives here) |
| temporal | `Temporal.lean` (257) | `ltemporal_use`, `ltemporal_cases`, `ladvance`, `lprogress`, `luntil`, `lsince` |
| discrete | `Discrete.lean` (86) | `lstep`, `linvariant` |
| (congruence kit, merged in PR #7) | `Rewriting.lean` (558), `Simplification.lean` (166), `RuleRegistry.lean` (65), `ModalBoolean.lean` (21) | `lrewrite`, `lsimp` |
| views tier | `FormalSystem/Tactic/FormulaViews.lean` | `lunfold`, `lfold` |

**The three tiers** (`records/proof-mode-architecture.md` § "Three tiers") are Views, Derivation
and Semantic. Views "changes how a formula is written ... No axiom, no rule, no context, no frame
class", producing the same judgment up to definitional equality; Derivation builds
`DerivationTree`/`PlusDerivationTree`. The Semantic tier is a separate mode and is not in this
repository's merged state (PR #9/#10, both open), so the per-tier cost table is **views and
derivation only**, exactly as the task's "cost per tier (views, derivation)" says.

**Existing record shapes, so one schema is not invented beside another.** `data/proof_steps.jsonl`
rows are flat, snake_case at the top level (`theorem_name`, `step_index`, `context`, `goal`,
`rule`, `axiom_name`, `subgoals`, `frame_class`) with nested formula ASTs in the
`{"tag": ..., "left"/"right"/"child"/"event"/"guard": ...}` codec that
`BimodalTools/DataExport.lean` defines. `data/bmlogic.jsonl` and `data/axiom-instances.jsonl`
carry a string `id` (`"bmlogic-00001"`, `"axiom-00001"`) plus `split`, `frame_class`, `label`,
and a nested `proof_trace` object already shaped `{"height", "axiomsUsed", "rulesApplied"}` —
which is substantially the Extract stage's "derivation size and height; axiom schemata used, with
counts". Each dataset has a sidecar `*_metadata.json` carrying `dataset_name`, `version`,
`schema_version`, `description`, `generation_date`, `total_records`, and a `fields` array of
`{field, type, description}`. **The diagnostics schema should be a new JSONL family in this
idiom, with its own `fields` sidecar, not a new convention.**

**Provenance precedent for "the commit and the command that produced it"**:
`scripts/typst-machine-appendix.sh` runs its exporter through `lake env lean --run` with
`--stamp-commit $(git rev-parse --short HEAD)` and `--stamp-date $(date -u +%Y-%m-%d)`, and
carries an explicit determinism contract ("two runs from the same commit on the same (UTC) day
produce byte-identical artifacts") plus a `--json` mode that zeroes the stamp fields so a sync
check can compare. It also takes the shared `.lake/build-guard.lock` once for all its lake calls.
The cost script should copy this shape wholesale.

**Statement identifier.** `BimodalLib/Registry.lean` establishes that a theorem's identity is the
**fully-qualified name of the registered closed derivation**, with its row at
`BimodalLib.Registry.<name>` (`rowName`/`registryPrefix`). A `TheoremEntry` carries `arity`,
`frameClass`, `stmt`, `proof`, `profile`, `profile_eq`, `substClass`, `dual`, and
`TheoremEntry.fragment` reads the fragment off the computed profile. So `fragment` and
`frame_class` in a diagnostics record should be **derived from the row**, not retyped — the same
discipline `profile_eq` enforces by `rfl`. For a tableau-enumerated entry with no declaration yet,
the `data/` `id` convention (`"bmlogic-00001"`) supplies the fallback key.

**Cost-baseline precedent.** `specs/evidence/phase5-hoist-kernel-ab/README.md` is the repo's
existing measured-cost document. Its measurement-conditions discipline is the model to follow:
commit and toolchain pinned; **zero rebuild** (library built to completion before any timing run,
every run a `lake env lean` elaboration of one standalone file against one unchanged build);
**serialized** under an `flock` on `.lake/build-guard.lock` held to exit; **arms interleaved** so
machine load moves both together; **per-site attribution** via `set_option profiler true`, reading
`tactic execution of ... took` and `type checking took` per declaration in source order; and
`maxHeartbeats 0` set identically in both arms, with the note that this is correct in a timing
probe and nowhere else.

**Gates the implementation will meet.** `lake build BimodalLib --wfail` (CI) rejects an
unregistered closed derivation and any warning; `lake exe runLinter BimodalLib` requires a
docstring on every declaration, generated rows included; `scripts/library-index.sh --check`
fails on a stale `BimodalLib/INDEX.md`; `scripts/check-evidence-probes.sh` compile-checks tracked
probes under `specs/evidence/` and is wired into CI as step `evidence-probes`;
`scripts/verify-all.sh` aggregates CI's ten checks locally. A new directory needs a README per
`docs/development/DIRECTORY_README_STANDARD.md`, and the `ProofMode/README.md` inventory table is
a `BEGIN GENERATED` block.

### Measurement 1 — The axiom audit

`#print axioms` over named `def`s holding proof-mode derivations, one representative script per
family, in TM and TM⁺:

| Declaration | Family / system | Script | Measured axiom set |
|---|---|---|---|
| `basicMP` | basic, TM | `lstart; lapply; lexact` | `[propext]` |
| `basicSplit` | basic, TM | `lstart; lsplit; lexact` | `[propext]` |
| `oneIntro` | basic, TM | `lintro; lexact` | `[propext, Classical.choice, Quot.sound]` |
| `basicCases` | basic, TM | `lstart; lcases; lapply; lexact` | `[propext, Classical.choice, Quot.sound]` |
| `modalK` | modal, TM | `lmodal_intro necessity using [...]` | `[propext, Classical.choice, Quot.sound]` |
| `temporalK` | temporal, TM | `ltemporal_intro future using [...]` | `[propext, Classical.choice, Quot.sound]` |
| `discreteStep` | discrete, TM | `lstep future using [...]` at `ZTime` | `[propext, Classical.choice, Quot.sound]` |
| `plusModal` | temporal, TM⁺ | `ltemporal_use` over `PlusDerivationTree` | `[propext, Quot.sound]` |
| `plusCases` | modal, TM⁺ | `lmodal_cases ... using [...]` | `[propext, Quot.sound]` |
| `rw4` | congruence kit, TM | `lrewrite` through 4 nested scopes | `[propext]` |
| `simp1`, `simp2` | congruence kit, TM | `lsimp only [doubleNegationIff, ...]` | `[propext, Classical.choice, Quot.sound]` |
| `viewFoldOnly`, `viewFoldUnfold` | views tier | `lfold` / `lfold; lunfold` | `[propext]` |
| `i16` | basic, TM | 16 nested `lintro` | `[propext, Classical.choice, Quot.sound]` |

Three substantive readings:

1. **The family partition is not the axiom partition.** The interesting line inside the basic
   family is not basic-vs-modal but **`lintro`/`lcases` versus everything else**. `lintro`
   discharges through the deduction theorem, which lives in `FormalSystem/Metalogic/` and is
   where `Classical.choice` and `Quot.sound` enter; `lcases` on a disjunction does the same. A
   script of `lstart`/`lapply`/`lexact`/`lsplit` alone stays at `[propext]`. An audit module that
   pins one row per family would **miss this**, so the recommendation below is one row per family
   *plus* a deliberate `[propext]`-only row and a `lintro` row, so the boundary itself is pinned.
2. **TM⁺ measures lighter than TM.** `[propext, Quot.sound]`, no `Classical.choice`. The TM⁺ rule
   copies in `FormalSystem/Theorems/ProofMode/Plus*.lean` (624 of the 1,157 pure-rule lines) take
   a different route than their TM originals. This is exactly the kind of asymmetry M8's planned
   deletion of the TM⁺ copies would change, so pinning it now gives that work a tripwire.
3. **The congruence kit is foundation-light where its rules are.** `lrewrite` through four nested
   scopes is `[propext]`. `lsimp` is not — but its additions come from the *rule list*
   (`doubleNegationIff` reaches classical machinery), not from the simplifier. Pinning both makes
   that attributable.

No row anywhere acquired `Lean.ofReduceBool`. The `native_decide` hard stop is clean across the
whole proof mode.

### Measurement 2 — Cost baseline: `lintro` nesting (the record's open question)

`#count_heartbeats in def ...` and `Lean.Expr.sizeWithoutSharing` over an `n`-deep `lintro`
chain closing `⊢ A₁ → (A₂ → ... → (Aₙ → A₁))` with `lexact h1`:

| nesting `n` | term size (`sizeWithoutSharing`) | heartbeats | `5n²+17n+41` |
|---:|---:|---:|---:|
| 1 | 33 | 18 | (63) |
| 2 | 95 | 28 | 95 |
| 3 | 137 | 33 | 137 |
| 4 | 189 | 39 | 189 |
| 5 | 251 | 44 | 251 |
| 6 | 323 | 50 | 323 |
| 7 | 405 | 55 | 405 |
| 8 | 497 | 61 | 497 |
| 10 | 711 | 68 | 711 |
| 12 | 965 | 79 | 965 |
| 16 | 1593 | 102 | 1593 |

**Term size is exactly `5n² + 17n + 41` for every measured `n` in `2..16`, residual zero.** The
`n = 1` case sits off the curve (33, not 63) because a single `lintro` needs no re-transform of an
already-transformed derivation. Heartbeats are linear: 18 -> 102 over 15 levels, ~5.3/level.

This is the answer the record was waiting for, and it is a *two-part* answer. The deduction
theorem transforms a whole derivation, so each `lintro` re-walks what the previous ones built —
yet the **elaborator** pays only linearly, because the transform is structural rather than a
re-elaboration. The quadratic growth is in the **term the kernel must check**. A long script is
therefore cheap to write and increasingly expensive to *verify*, which is the opposite of the
usual tactic-cost shape and is the single most quotable figure for the adequacy gate. At the
task's stated threshold of five nested `lintro` steps the absolute cost is still small (251
nodes, 44 heartbeats); extrapolating the fit, a 50-deep script would be ~13,400 nodes and a
100-deep one ~51,700 — large but not prohibitive, which argues the mode is usable on long scripts
and no rule change is needed on cost grounds.

### Measurement 3 — Cost baseline: nested logical rewrite (PR #7 conditional, ACTIVE)

**PR #7 "[1/3] Add checked rewriting and bounded simplification" is MERGED** (`gh pr list`,
merged 2026-11-19), so the task's conditional fires. `lrewrite mapping at provider as mapped`
transporting an implication through `d` nested scopes:

| nested scopes `d` | scope stack | term size | heartbeats | `785 + 346·d` |
|---:|---|---:|---:|---:|
| 0 | (current point) | 785 | 34 | 785 |
| 1 | `□` | 1131 | 41 | 1131 |
| 2 | `□ G` | 1477 | 52 | 1477 |
| 3 | `□ G H` | 1823 | 64 | 1823 |
| 4 | `□ G H □` | 2169 | 74 | 2169 |

**Exactly +346 term nodes per nested scope level, linear, zero residual over `d = 0..4`.**
Heartbeats also linear, ~+10/level.

Two readings. The contribution's claim is **half right**: a single congruence certificate is
indeed large in absolute terms — 785 nodes at depth 0, against 99 for `basicMP` and 33 for a
single `lintro`, so ~8x a basic script before any nesting. But composition is **linear**, not
compounding, so the certificates do not blow up: `lintro`'s quadratic overtakes a nested rewrite
at around depth 20. The baseline the contribution promised and did not record is the table above.

`lsimp`, the other half of the merged kit, for comparison: one rule / one reduction = 1059 nodes,
52 heartbeats; two rules / two reductions = 2413 nodes, 127 heartbeats. The simplifier is the
most expensive single step measured, which matches its bounded-search design.

### Measurement 4 — Cost per tier (views, derivation)

| Tier | Representative | term size | heartbeats | axioms |
|---|---|---:|---:|---|
| Views | `lfold diamond at provider` | 55 | 23 | `[propext]` |
| Views | `lfold diamond at provider; lunfold diamond` | 89 | 34 | `[propext]` |
| Derivation | `lstart; lapply; lexact` | 99 | 25 | `[propext]` |
| Derivation | `lstart; lsplit; lexact` (2 leaves) | — | — | `[propext]` |
| Derivation | `lintro; lexact` | 33 | 14 | `[propext, Classical.choice, Quot.sound]` |
| Derivation | `lmodal_intro necessity using [...]` | 373 | 40 | `[propext, Classical.choice, Quot.sound]` |
| Derivation | `lrewrite` (depth 0) | 785 | 34 | `[propext]` |
| Derivation | `lsimp only [1 rule]` | 1059 | 52 | `[propext, Classical.choice, Quot.sound]` |
| Derivation | `lsimp only [2 rules]` | 2413 | 127 | `[propext, Classical.choice, Quot.sound]` |

The tier separation the architecture record asserts is **measurable**: a views-tier step costs
55-89 nodes at `[propext]`, because it produces "the same judgment, up to definitional equality
or a cast". A derivation-tier step costs 33-2413 nodes at a family-dependent axiom set. The ratio
between the cheapest views step and the most expensive derivation step measured is ~44x.

### Measurement 5 — The derivation-size measure itself

Two distinct measures are both available and they answer different questions:

- **`Lean.Expr.sizeWithoutSharing`** of the declaration's elaborated value. Works for schematic
  statements (free `Formula` parameters) and is what every figure above reports. It measures *the
  term the kernel checks* — the right proxy for "size of any term-mode escape" and for the
  Re-prove stage's "size of the derivation built".
- **`DerivationTree.height`** (`FormalSystem/ProofSystem/Derivation.lean:223`), evaluable by
  `#eval` on a **closed** instance. Verified: a closed `lstart; lapply; lexact` script has height
  1; a closed 3-deep `lintro` chain has height 6. This is the measure the Extract stage's
  `proof_trace.height` field in `data/axiom-instances.jsonl` already uses, so the schema should
  reuse the field name.

**Gap**: there is **no** `DerivationTree.size` (node count). The Diagnostics table asks Extract
for "derivation size and height", and `height` alone is a weak measure (a wide tree and a
spindly one can share it). Adding a `DerivationTree.size` beside `height` is a small, clearly
scoped addition; it belongs in `FormalSystem/ProofSystem/Derivation.lean` beside `height`, or in
`BimodalLib/Diagnostics/` if touching the core module is to be avoided. Either way it must stay
computable, since both measures are read by `#eval`.

### Diagnostics schema — the design

One record per `(statement, stage)`. Shared head, per-stage payload; emitted as JSONL in the
`data/` idiom with a `*_metadata.json` sidecar carrying the `fields` array.

**Shared head** (every stage):

| field | type | source |
|---|---|---|
| `statement` | string | the registered declaration's fully-qualified name (`BimodalLib/Registry.lean`'s key), or a `data/`-style `id` for an entry with no declaration yet |
| `stage` | string enum | `enumerate` \| `decide` \| `extract` \| `certify` \| `admit` \| `reprove` \| `compare` |
| `fragment` | string | `TheoremEntry.fragment`, derived from the row, never retyped |
| `frame_class` | string | `TheoremEntry.frameClass`, likewise |
| `commit` | string | `git rev-parse --short HEAD`, stamped as in `scripts/typst-machine-appendix.sh` |
| `command` | string | the exact command line that produced the record |

**Per-stage payloads**, field for field as `records/theorem-library.md` § Diagnostics lists them.
Only the two this task implements are spelled out here; the other five are reserved keys that
`theorem_library_tableau_pipeline` fills against this same head.

`reprove`: `outcome` (`closed_by_rules` \| `closed_with_leaf_automation` \|
`closed_with_term_escape` \| `not_closed`); `failure_class` (null on the first outcome, otherwise
one of the record's fixed list: `missing_rule` \| `missing_tactic` \| `automation_too_weak` \|
`script_too_awkward` \| `too_slow` \| `defect_in_mode`); `tactic_count`;
`distinct_tactics` (array); `escape_size` (`sizeWithoutSharing` of the term-mode escape, 0 when
none); `heartbeats`; `elab_ms`; `term_size`; `derivation_height`; `axioms` (array, from
`#print axioms`).

`compare`: `script_length`; `hand_proof_length`; `length_ratio`; `built_derivation_size`;
`reference_derivation_size`; `statement_fragment`; `proof_fragment`. The record is explicit that
length is compared against hand proofs **only** — against a tableau-extracted proof a script is
measured for coverage and built-derivation size, not brevity — so `length_ratio` must be
nullable, with `reference_kind` (`hand` \| `extracted`) saying which comparison applies.

**Two timing fields, not one, and that is deliberate.** `heartbeats` is deterministic for a fixed
toolchain and library and is therefore the figure a gate can quote and a CI check can compare;
`elab_ms` is wall clock from `set_option profiler true`, which is what the record's "elaboration
time" literally asks for and what `specs/evidence/phase5-hoist-kernel-ab/` measures, but is
machine-dependent. Recording both costs nothing and keeps the reproducible figure separable from
the human-legible one.

### Recommendations

1. **Emit the RE-PROVE and COMPARE records from two command elaborators in
   `BimodalLib/Diagnostics/`, built on `#count_heartbeats`'s mechanism plus
   `Expr.sizeWithoutSharing`, with `DerivationTree.height` by `#eval` on closed instances.**
   `BimodalLib` is where `records/theorem-library.md` § Layout already files `Diagnostics/`, it
   is outside `defaultTargets`, and it already imports `FormalSystem` and never the reverse.
   [VERIFIED: PASS -- `lean_run_code` probes 3-5: `#count_heartbeats in def ...` reported
   18/25/40/52/127 heartbeats over proof-mode `def`s; a `#term_size` command reading
   `ConstantInfo.value?` and `Expr.sizeWithoutSharing` reported 33/99/373/785/1059/2413;
   `#eval <closed derivation>.height` returned 1 and 6. All three instruments execute against the
   pinned toolchain with no new dependency.]

2. **Write the audit module as a NEW `Tests/BimodalTest/Automation/ProofModeAxioms.lean` of named
   `def` mirrors — do not annotate or convert the 52 existing `example`s** — and add it to
   `Tests/BimodalTest.lean` so `lake test` reaches it.
   [VERIFIED: FAIL -- `#print axioms P6._example` returned `Unknown constant P6._example`, so the
   gate (`#guard_msgs in #print axioms`) cannot be run against any existing acceptance fixture;
   revised to: declare named mirrors in a new module, leaving every acceptance `example`
   byte-identical, which the same probe confirms passes — `#print axioms` over named proof-mode
   `def`s produced all 13 rows in the audit table above.]

3. **Pin one row per tactic family AND pin the `[propext]`/classical boundary explicitly**: at
   minimum a `lstart`/`lapply`/`lexact` row and a `lsplit` row (both `[propext]`), a single-`lintro`
   row and an `lcases` row (both classical), one row each for modal / temporal / discrete, two TM⁺
   rows, an `lrewrite` row, an `lsimp` row, and the views pair. A one-row-per-family module would
   record the boundary's right-hand side only and would not fail when a `[propext]`-only script
   starts reaching for choice.
   [VERIFIED: PASS -- the 13-row axiom table above is the gate's own output, measured via
   `#print axioms` on named proof-mode `def`s at commit `521385a9`; each row's set is as printed.]

4. **State the permitted set and the hard stop in the audit module's docstring, copying
   `WalkthroughAxioms.lean` verbatim in form**: permitted is `propext`, `Classical.choice`,
   `Quot.sound` or any subset; `Lean.ofReduceBool` is a hard stop. Add one sentence recording that
   TM⁺ rows measure at `[propext, Quot.sound]` and that the `[propext]`-only rows are intentional,
   so a future reader does not "fix" a narrow row by widening it.
   [VERIFIED: PASS -- no measured row acquired `Lean.ofReduceBool`; the TM⁺ rows
   (`plusModal`, `plusCases`) measured `[propext, Quot.sound]` and the narrow rows
   (`basicMP`, `basicSplit`, `rw4`, both views rows) measured `[propext]`.]

5. **Record the `lintro` nesting law, not just the five-step figure, in
   `docs/development/proof-mode-cost-baseline.md`.** The task asks for "one long script with at
   least five nested `lintro` steps"; the measured closed form `5n² + 17n + 41` over `n = 2..16`
   is strictly more useful to the adequacy gate than a single point, and it is already measured.
   Pair it with the linear heartbeat trend and say plainly that the quadratic is kernel-side.
   [VERIFIED: PASS -- Measurement 2's table; the fit reproduces every measured size exactly
   (n=16: 5·256 + 17·16 + 41 = 1593, measured 1593).]

6. **Include the nested logical rewrite, since PR #7 has merged**, as the `785 + 346·d` row set,
   and state both halves of the finding: certificates are large in absolute terms but compose
   linearly.
   [VERIFIED: PASS -- `gh pr list --state all` shows #7 MERGED 2026-11-19; Measurement 3's table
   reproduces exactly at `d = 0..4`.]

7. **Add a computable `DerivationTree.size` (node count) beside `height`.** The Diagnostics table
   asks Extract for "derivation size and height"; only `height` exists, and height alone cannot
   distinguish a wide derivation from a spindly one.
   [VERIFIED: PASS -- `grep` over `FormalSystem/ProofSystem/` found `def height` at
   `Derivation.lean:223` and no size/node-count definition; `#eval <closed>.height` returned 1
   and 6, confirming the existing measure is computable and that a sibling `size` would be too.]

8. **Drive the measuring script as `scripts/proof-mode-cost-baseline.sh` over a probe file via
   `lake env lean`, on the `scripts/typst-machine-appendix.sh` pattern**: `--stamp-commit` /
   `--stamp-date`, a build-free `--json` mode for a sync check, the shared
   `.lake/build-guard.lock` taken once, and an explicit determinism contract. Measure under the
   `specs/evidence/phase5-hoist-kernel-ab/README.md` conditions (zero rebuild, serialized,
   interleaved, `profiler true` for per-site attribution, `maxHeartbeats 0` in the timing arm
   only).
   [No compiled gate applicable -- no existing predicate in the tree decides acceptance of a
   shell script's shape; the two cited precedents are conventions, not gates.]

9. **Document the schema at `docs/reference/diagnostics.md` with a `fields` table per stage,
   mirroring the `data/*_metadata.json` `{field, type, description}` shape**, and emit the
   sidecar from the same source so the doc and the emitter cannot drift. Reserve the five
   unimplemented stages' keys in the doc, marked as written by
   `theorem_library_tableau_pipeline`, so that record has a schema to build against rather than a
   gap to guess at.
   [No compiled gate applicable -- no existing compiled predicate decides acceptance of a
   markdown reference page or of a reserved-key list.]

10. **Reuse `Formula.toJson` from `BimodalTools/DataExport.lean` verbatim for every formula
    field, and snake_case every top-level field.** The existing corpus is consistent on both
    points (`theorem_name`/`frame_class`/`axiom_name` at top level; `{"tag": ...}` ASTs nested),
    and `records/theorem-library.md` is explicit that the schema be designed against the existing
    records so one is not invented beside the other.
    [No compiled gate applicable -- the convention is enforced by review and by the datasets'
    own validators, none of which decides acceptance of a new record family's field naming.]

## Decisions

- **The baseline is produced in research, not deferred to implementation.** Every figure in
  Measurements 1-5 is compiled at commit `521385a9`. Implementation's job is to check in the
  harness that reproduces them, not to discover them. This matters because
  `proof_mode_reprove_perpetuity` depends on this record hard and needs a quotable figure.
- **Audit module is new and additive.** The existing 52 acceptance `example`s stay byte-identical.
  Decided against a "convert the fixtures to named defs" route, which `#print axioms` would have
  allowed but the task explicitly forbids.
- **Both a deterministic and a wall-clock cost figure are recorded.** `heartbeats` is the gateable
  one; `elab_ms` satisfies the record's literal "elaboration time". Decided against picking one.
- **The axiom-audit rows pin a boundary, not a family census.** Driven by the measured finding
  that `lintro`/`lcases` and not family membership is what moves the axiom set.
- **Per-tier table covers views and derivation only.** The semantic tier is not in merged state
  (PRs #9 and #10 open), and the task names exactly these two tiers.
- **`DerivationTree.size` is proposed as a new computable definition**, not worked around by
  reporting `Expr.sizeWithoutSharing` in its place: the two measure different objects (the Lean
  term versus the derivation it denotes) and the Extract stage asks for the latter.
- **Deferred to planning, not decided here**: whether `DerivationTree.size` lands in
  `FormalSystem/ProofSystem/Derivation.lean` (natural home, beside `height`, but touches the core
  library and its `--wfail` build) or in `BimodalLib/Diagnostics/` (isolated, but files a measure
  of a core type outside the core). Both satisfy every stated constraint.

## Risks & Mitigations

- **Risk: a checked-in heartbeat figure becomes a brittle test.** Heartbeats are deterministic for
  a fixed toolchain but not across Lean or Mathlib bumps. **Mitigation**: the *audit* module
  asserts axiom sets only (`#guard_msgs`, fully deterministic); the *baseline* figures live in a
  markdown document regenerated by the script, with no `#guard_msgs` pin on any number. The DONE
  WHEN condition is "the audit test passes in `lake test` and the baseline file exists with its
  reproduction command" — which this split satisfies exactly.
- **Risk: PR #8 lands mid-task and moves `lintro`/`linduction` cost.** #8 carries `linduction`,
  whole-judgment time reflection and `keeping`, all of which could change the deduction-theorem
  route. **Mitigation**: pin the measurement commit in the baseline document (as
  `specs/evidence/phase5-hoist-kernel-ab/README.md` does) and make the script's first action a
  re-probe against that pin, so a moved head shows up as a stale baseline rather than as a silent
  wrong figure. This is the pattern that worked on the #8 re-review.
- **Risk: schema churn when `theorem_library_tableau_pipeline` writes the other five emitters.**
  **Mitigation**: the shared head is fixed now and the five unimplemented stages' keys are
  reserved in `docs/reference/diagnostics.md` with their field lists copied from
  `records/theorem-library.md`, so that record extends rather than renegotiates.
- **Risk: `BimodalLib` gate collisions.** `lake exe runLinter BimodalLib` requires a docstring on
  every declaration including generated rows; `lake build BimodalLib --wfail` rejects any warning
  and any unregistered closed derivation; `scripts/library-index.sh --check` fails on a stale
  `INDEX.md`. **Mitigation**: docstring every new declaration in `BimodalLib/Diagnostics/`; the
  diagnostics emitters declare commands and structures, not closed derivations, so the
  registration check does not apply; regenerate `INDEX.md` if any row is added.
- **Risk: `#count_heartbeats` / `#print axioms` outside the test libraries trips the
  `hashCommand` linter.** Only `BimodalTest`, `BimodalToolsTest` and `BimodalLibTest` carry
  `weak.linter.hashCommand = false`. **Mitigation**: keep every `#`-command in a test library or
  in a probe file outside the build graph driven by `lake env lean` — the route
  `scripts/check-evidence-probes.sh` and `scripts/typst-machine-appendix.sh` both already use.
- **Risk: a `lake env lean` probe outside the build graph rots.** **Mitigation**: wire it into
  `scripts/check-evidence-probes.sh`'s list, or state in the probe's header (as
  `specs/evidence/phase5-hoist-kernel-ab/` does) the explicit reason it is deliberately not wired
  — a wall-clock timing comparison is not a compile-check invariant. Pick one and say so; do not
  leave it unstated.
- **Risk: measurement contaminated by a concurrent build.** **Mitigation**: take
  `.lake/build-guard.lock` once and hold it to exit, and never invoke bare `lake`.

## Tactic Survey Results

The Tactic Discovery Survey Protocol's standard portfolio (`aesop`/`simp`/`omega`/`decide`/
`norm_num`/`ring`/`linarith`) is **not applicable** to this task: nothing here closes a
mathematical goal. The analogous survey for this task is over the *measurement* instruments and
the *proof-mode* tactic surface, which is what was run. Every row below is an executed probe, not
a candidate.

| Goal | Instrument / tactic | Result | Premises/Config |
|---|---|---|---|
| Name a proof-mode derivation for `#print axioms` | named `def` | success | 13 rows measured |
| Name an acceptance `example` for `#print axioms` | `#print axioms P6._example` | fail | `Unknown constant`; forced the named-mirror route |
| Measure elaboration cost deterministically | `#count_heartbeats in def ...` | success | `import Mathlib.Util.CountHeartbeats`; 14-127 hb observed |
| Measure elaborated term size | `Expr.sizeWithoutSharing` via a `#term_size` command | success | `ConstantInfo.value?` + `realizeGlobalConstNoOverload` |
| Measure derivation size directly | `#eval <closed derivation>.height` | success | closed instances only; returned 1 and 6 |
| Measure derivation node count | (no `DerivationTree.size`) | fail | absent from `FormalSystem/ProofSystem/`; recommended as an addition |
| Per-site wall-clock attribution | `set_option profiler true` | not re-run | precedent established in `specs/evidence/phase5-hoist-kernel-ab/`; adopted by reference |
| Basic-family script | `lstart; lapply; lexact` | success | 99 nodes, 25 hb, `[propext]` |
| Modal-family script | `lmodal_intro necessity using [...]` | success | 373 nodes, 40 hb, classical |
| Temporal-family script | `ltemporal_intro future using [...]` | success | classical |
| Discrete-family script | `lstep future using [...]` at `ZTime` | success | classical |
| TM⁺ script | `ltemporal_use`, `lmodal_cases` over `PlusDerivationTree` | success | `[propext, Quot.sound]` |
| Congruence kit | `lrewrite` through 0-4 nested scopes | success | `785 + 346·d`, `[propext]` |
| Bounded simplifier | `lsimp only [1-2 rules]` | success | 1059 / 2413 nodes; most expensive step measured |
| Views tier | `lfold` / `lunfold` | success | 55 / 89 nodes, `[propext]` |
| Deep nesting | 1-16 nested `lintro` | success | `5n²+17n+41` exact; heartbeats linear |

## Context Extension Recommendations

- **Topic**: Measuring Lean elaboration cost and term size in this repository.
  **Gap**: `context/project/lean4/` has no entry for `#count_heartbeats` versus wall-clock
  `profiler true`, nor for `Expr.sizeWithoutSharing`, nor for the choice between them. The
  measurement discipline is currently recorded only inside one evidence directory's README
  (`specs/evidence/phase5-hoist-kernel-ab/`), which is task-adjacent and easy to miss.
  **Recommendation**: add `context/project/lean4/patterns/cost-measurement.md` capturing the two
  instruments, the determinism/portability trade-off, and the four measurement conditions (zero
  rebuild, serialized under the build lock, interleaved arms, per-site attribution).
- **Topic**: `#print axioms` cannot name an `example`.
  **Gap**: nothing in `context/project/lean4/` records this, and it is the kind of constraint that
  silently reshapes a plan — an audit task scoped against a fixture file of `example`s will
  discover it only at implementation time.
  **Recommendation**: one line in `context/project/lean4/patterns/` (or in the cost-measurement
  file above): an axiom audit requires named declarations; `example` is unaddressable, so a
  fixture file of `example`s needs named mirrors, not annotation.

## Appendix

### Probes executed (all via `lean_run_code`, imports as shown)

1. `import FormalSystem.Automation.ProofMode` — five named `def`s (basic/modal/temporal/discrete
   families + 5-deep `lintro`), `#print axioms` each.
2. Same import — `oneIntro`, `basicSplit`, `basicCases`, `plusModal`, `plusCases`,
   `#print axioms` each.
3. `+ import Mathlib.Util.CountHeartbeats` — a `#term_size` command elaborator over
   `ConstantInfo.value?` / `Expr.sizeWithoutSharing`; `#count_heartbeats in` over four `def`s.
4. Same — `lintro` depth 1-8, then depth 10/12/16; sizes and heartbeats.
5. Same — `lrewrite` nested-scope depth 0-4; `lsimp` 1-2 rules; closed-instance
   `#eval ... .height`; `lfold`/`lunfold` views rows.
6. `import FormalSystem.Automation.ProofMode` — `#print axioms P6._example` (expected and
   confirmed `Unknown constant`).

### Searches and sweeps used

- `gh pr list --state all --limit 15` — PR #7 MERGED; #8, #9, #10 OPEN; #6, #11 MERGED.
- `grep` sweeps for `M13` / `Diagnostics` in `records/`; tactic-name extraction per elaborator
  module; `count_heartbeats` / `Expr.sizeWithoutSharing` availability in the pinned trees;
  `def height` / size definitions under `FormalSystem/ProofSystem/`; `lunfold` location.
- `lean_local_search Expr.sizeWithoutSharing` — found at `.lean-stdlib/lean/Lean/Expr.lean`
  (index reported `warming` on this call; the subsequent compiled probe is the proof of presence,
  not the search).

### References

- `records/proof-mode.md` § M13, § lanes/gates; `records/theorem-library.md` § Diagnostics,
  § Layout, § Sources and the tableau pipeline; `records/proof-mode-architecture.md` § Three tiers
- `docs/reference/bimodal-lib.md` § The registry, § The index, § What checks the library
- `Tests/BimodalTest/WalkthroughAxioms.lean`; `Tests/BimodalTest.lean` lines 37, 68-72
- `FormalSystem/ProofSystem/Derivation.lean:223` (`DerivationTree.height`)
- `BimodalLib/Registry.lean` (`TheoremEntry`, `rowName`, `registryPrefix`, `frameClassOf`)
- `BimodalTools/DataExport.lean` (`Formula.toJson` codec); `data/proof_steps_metadata.json`
  (`fields` sidecar shape); `data/axiom-instances.jsonl` (`proof_trace` shape)
- `scripts/typst-machine-appendix.sh` (stamping, `--json` mode, determinism contract, shared lock)
- `specs/evidence/phase5-hoist-kernel-ab/README.md` (measurement conditions)
- `.lake/packages/mathlib/Mathlib/Util/CountHeartbeats.lean`
