# Implementation Plan: Task #989

- **Task**: 989 - Pointed semantic lemmas: after-merge follow-ups
- **Status**: [COMPLETED]
- **Effort**: 4.5 hours
- **Dependencies**: None blocking. Adjacent and separate: `connective_signature_layer_shared_primitives` (owns the named interval operators and the `next`/`prev` encoding), `promote_next_prev_covby_to_generic_lemmas` (owns the `next_iff_covBy` promotion).
- **Research Inputs**: `specs/989_pointed_semantic_lemmas_after_merge_followups/reports/01_pointed-semantic-lemmas-followups.md`
- **Artifacts**: plans/01_pointed-semantic-lemmas-followups.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Three after-merge follow-ups from the posted review of the pointed semantic lemmas
contribution, all confirmed outstanding on the merged tree: a positive universal-existential
reading beside `release_iff`/`trigger_iff`, titled module docstrings plus one `assert_not_exists`
spelling for the three generic `FormalSystem/Semantics/` modules, and two primitive-tense
persistence lemmas (reaching L⁻, which has no `untl`) plus L⋆ versions of the time-shift and
state-local transport factories. Ten new declarations land across four library modules and two
test modules, each new declaration carrying at least one test row. Done means: all ten
declarations present with the signatures pinned below, a full `lake build` green, and both
generated surfaces a Lean line-count change moves (`typst/generated/status.typ`, `README.md`'s
`dir=FormalSystem` inventory) regenerated and current.

### Research Integration

The research report compiled every recommended declaration before writing it, in ten probes
against the already-built `.olean` tree, and the plan takes its statements verbatim into
`## Lean Challenge Statements` below. Two findings reshape the work relative to the posted
review and are carried as plan decisions, not options:

- **`PointTransport.lean` cannot take the directory-form lock.** `assert_not_exists
  FormalSystem.ProofSystem.Axiom` fails there, because the module's own import closure
  (`Semantics.HistoryMorphism → PlusLanguage.PlusValidity → Semantics.Validity →
  Semantics.ValidityLayer → Semantics.FrameClassValidity → ProofSystem.Axioms`) already puts
  both `Axiom` and `FrameClass` in its environment. Item 2's lock unification is therefore
  scoped to the three generic modules, and `PointTransport.lean` keeps a `DerivationTree`-rooted
  lock with the reason recorded in its docstring.
- **The L⋆ factories are not free wraps.** `Shifted` and `SameStateNow` leave `Point.env`
  unconstrained, which is harmless where `Env _ := PUnit` and fatal at a stored-time language, so
  two new env-aware relations (`SameStateNowEnv`, `ShiftedEnv`) are a prerequisite, added
  alongside the existing relations rather than replacing them.

One measured bonus carried forward: the new primitive-tense `allFuture_persist_of_tense` is
`[propext]`, strictly cleaner than the existing `untl`-derived `allFuture_persist`
(`[propext, Classical.choice, Quot.sound]`).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no roadmap flag was set, so roadmap
consultation is skipped and this plan carries no roadmap-review or roadmap-regeneration phase.

## Goals & Non-Goals

- **Goals**:
  - `release_iff_forall`, `trigger_iff_forall` -- the direct universal-existential readings of the
    strict release and trigger clauses, each proved from the existing negated-clause lemma.
  - `allFuture_persist_of_tense`, `allPast_persist_of_tense` -- primitive-tense persistence over
    `AllFutureClause`/`AllPastClause`, so L⁻ is covered.
  - `SameStateNowEnv`, `ShiftedEnv` -- env-aware point relations, added beside the existing
    environment-blind ones.
  - `SameStateNowEnv.intro`, `ShiftedEnv.intro` -- the explicit-point constructors, in the
    directory's `.intro` style.
  - `star_iffTransport_timeShift`, `star_iffTransport_stateLocal` -- the two L⋆ transport
    factories, over the env-aware relations.
  - Titled module docstrings for `TemporalRules.lean`, `TemporalIntervals.lean` and
    `RankProgress.lean`, in `StateLocalTransfer.lean`'s shape, plus one `assert_not_exists`
    spelling across those three.
  - One test row per new declaration, spanning L, L⁻, L⁺ and L⋆.

- **Non-Goals**:
  - Named `release`/`trigger`/`weakUntil`/`inclusiveUntil` operators at the signature layer --
    `connective_signature_layer_shared_primitives`' territory; the L⋆ positive-reading row
    therefore spells the `(untl guard.neg event.neg).neg` encoding rather than a named operator.
  - The `next_iff_covBy`/`prev_iff_covBy` promotion -- `promote_next_prev_covby_to_generic_lemmas`'
    territory.
  - Dropping or restating `release_iff`/`trigger_iff`. The posted review keeps both; the positive
    readings sit beside them.
  - Strengthening `Shifted`/`SameStateNow` themselves, or any change to `Shifted.intro`/
    `SameStateNow.intro`'s two-environment signatures.
  - Any `docs/theorem-index.md` row. C15 asserts index-row → anchor, not declaration → index-row,
    and the four contributed modules carry no index rows today.
  - An L⋆ reversal factory. There is no `starTruthAt_rev` to wrap.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A later pass "fixes" `PointTransport.lean`'s lock to the directory form and hits the compile error | M | M | Phase 1 records the measured import chain in the module docstring, where the next reader will be standing |
| The `(L := StarFormula)` ascriptions read as redundant and get deleted, producing an unrelated-looking `Function expected at v` error | M | M | Phase 4 adds a one-line comment at the `ShiftedEnv` application naming the reason |
| C16 `docBlame` fires on any of the ten new declarations, including the two structure-like `def`s | M | M | Every task writes the docstring with the declaration; the neighbouring relations are the template |
| C17's dead-declaration scan fires on a declaration whose test row was forgotten -- `trigger_iff_forall` is the easy one to miss | M | M | The per-phase task lists enumerate one row per new declaration; Phase 5 re-reads the C17 section of a full `check-module-invariants.sh` run |
| The pre-commit hook refuses a phase commit because `typst/generated/status.typ` drifted | H | H if unscheduled | Every phase that moves a Lean line count regenerates and stages that file in the same phase (it is the commit-blocking surface) |
| `typst-sync-check.sh --fix` fails because the library is not fully built | L | M | Run the full guarded `lake build` and retry; `--fix` is build-requiring even though `--counts-only` is not |
| A full `check-module-invariants.sh` or lint run is red for pre-existing, untouched-file reasons | M | M | Phase 5 states its criteria as a baseline delta plus per-touched-file evidence, never an absolute repo-wide zero |
| Under `--wfail` any linter warning is a CI failure, including `unusedVariables` | M | L | Each phase's own guarded build must be diagnostic-free, not merely exit 0 |

## Decisions

- **Order the phases (2) → (1) → (3a) → (3b).** Item 2 is the cheapest and touches the same four
  module headers items 1 and 3 touch, so doing it first avoids two passes over the same headers.
- **Add relations rather than strengthen `Shifted`/`SameStateNow`.** Strengthening would break the
  two-environment `.intro` signatures and change an API that merged with the contribution;
  `plus_iffTransport_stateLocal` and its test row consume the weaker relation, and the strengthened
  relation stays usable with the existing L⁺ factory via `.1`.
- **Name the positive readings `_iff_forall`, not `_iff_pos`.** `_pos` means "positive" in the
  Mathlib convention this tree already consumes (`List.length_pos_iff` at six call sites under
  `FormalSystem/Metalogic/`).
- **Name the primitive-tense siblings `_of_tense`,** following `always_iff_of_tense`.
- **Accept the `Classical.choice` delta on the positive readings.** It is intrinsic to the `mp`
  direction and already the profile of the directly analogous `TruthClauses.someFuture_iff_of_allFuture`
  and `somePast_iff_of_allPast`.
- **Place the two primitive-tense lemmas in their own new section with explicit binders**, not under
  `TemporalRules.lean`'s existing `Persistence` section, whose `variable` line carries
  `[BotClause L] [ImpClause L]` that these two lemmas do not need.
- **Regenerate both coupled generated surfaces in every phase that moves a Lean line count.**
  `typst/generated/status.typ` is commit-blocking via `.githooks/pre-commit` and cannot be
  deferred; `README.md`'s `dir=FormalSystem` inventory block is non-blocking and could be deferred,
  but is regenerated in the same phase anyway so no phase's own verification runs against a stale
  tree. Both are declared in every phase that moves the quantity, per the
  coupled-generated-surface declaration obligation.
- **Verification criteria name the repository's own Lean gates directly, not a shell-suite subset.**
  Measured at plan authoring time by one `suite_selection_select` call over this plan's whole
  touched set: every `FormalSystem/**.lean` and `Tests/**.lean` path is unmapped, while the two
  regeneration targets map only to agent-system shell suites with no bearing on Lean content. The
  honest covering check for each phase is therefore the repository-specific one named in that
  phase's `Tier Justification` -- the unmappable-criterion case, not a suite-list or sentinel claim.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: phases 2 and
3 both edit `Tests/BimodalTest/Semantics/TemporalRulesTest.lean`, and every phase stages the same
two generated surfaces.

### Phase 1: Module Docstrings and One Lock Spelling [COMPLETED]

**Goal**: The three generic modules carry a titled docstring in `StateLocalTransfer.lean`'s shape
and the directory-form `assert_not_exists`; `PointTransport.lean` carries the same docstring
sections plus the recorded reason its lock cannot take that form.

**Tasks**:
- [x] Confirm the starting state before editing: `grep -n "assert_not_exists" FormalSystem/Semantics/TemporalRules.lean FormalSystem/Semantics/TemporalIntervals.lean FormalSystem/Semantics/RankProgress.lean FormalSystem/Semantics/PointTransport.lean` and read the four module headers.
- [x] Rewrite `TemporalRules.lean`'s `/-! ... -/` block into the full shape `FormalSystem/Semantics/StateLocalTransfer.lean` uses: `# ` title, framing paragraph, `## Main Results`, `## References`, `## Tags`. Keep the existing framing prose as the paragraph.
- [x] Same for `TemporalIntervals.lean` and `RankProgress.lean`.
- [x] Use no `file.lean:NNN` citation anywhere in the new docstrings -- C20 gates any citation that is out of range or lands on a blank line. Cite module paths and declaration names instead.
- [x] Replace the lock line in each of the three modules with `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`, the form 16 of the directory's 20 locks already use (`FormalSystem/Semantics/Truth.lean` and `TruthTransport.lean` are the in-directory templates).
- [x] Extend `PointTransport.lean`'s existing docstring with `## Main Results`, `## References` and `## Tags`, plus a short "Why this module's lock is not the directory form" paragraph naming the import chain `Semantics.HistoryMorphism → PlusLanguage.PlusValidity → Semantics.Validity → Semantics.ValidityLayer → Semantics.FrameClassValidity → ProofSystem.Axioms` by module name.
- [x] Respell `PointTransport.lean`'s lock as `assert_not_exists FormalSystem.ProofSystem.DerivationTree FormalSystem.PlusLanguage.PlusDerivationTree`, dropping `Derivable` (implied: `ProofSystem/Derivable.lean` imports `ProofSystem/Derivation.lean`, which declares `DerivationTree`). `FormalSystem.StarLanguage.StarDerivationTree` is added in Phase 4, with the imports that make it meaningful.
- [x] Guarded scoped build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.TemporalRules FormalSystem.Semantics.TemporalIntervals FormalSystem.Semantics.RankProgress FormalSystem.Semantics.PointTransport`, and confirm it is diagnostic-free, not merely exit 0 (CI builds with `--wfail`).
- [x] Regenerate the commit-blocking surface and stage it: `bash scripts/typst-sync-check.sh --fix` then stage `typst/generated/status.typ`. If `--fix` reports an unbuilt library, run `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` and retry.
- [x] Regenerate the inventory surface and stage it: `bash scripts/check-module-invariants.sh --emit-inventory`, then `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm it is current.

**Timing**: 60 minutes

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The edit is four module headers and four lock lines with no declaration or signature change, so the guarded scoped build of exactly those four modules plus `bash scripts/typst-sync-check.sh --counts-only` is the cheapest check covering both the `assert_not_exists` elaboration surface and the one commit-blocking generated surface the line-count change moves.

**Scope Hypothesis**: Three module docstrings lack a `# ` title and three locks read `DerivationTree FrameClass`, and both generated surfaces are green before this phase -- the first two carried from the research report's merged-tree table in `reports/01_pointed-semantic-lemmas-followups.md` and re-derived at plan authoring time by reading all four headers, the third measured at plan authoring time (`check-module-invariants.sh --emit-inventory --check`: PASS). Confirm with the `grep` in the first task and with the `--emit-inventory --check` run before editing; if a surface is already stale for an unrelated reason, record that pre-existing drift rather than absorbing it into this phase's diff.

**Files to modify**:
- `FormalSystem/Semantics/TemporalRules.lean` - titled docstring in `StateLocalTransfer.lean`'s shape; lock to the directory form
- `FormalSystem/Semantics/TemporalIntervals.lean` - same
- `FormalSystem/Semantics/RankProgress.lean` - same
- `FormalSystem/Semantics/PointTransport.lean` - docstring sections plus the recorded import chain; lock respelled without `Derivable`
- `typst/generated/status.typ` - regenerated `formalsystem-line-count` (commit-blocking surface)
- `README.md` - regenerated `dir=FormalSystem` inventory totals (non-blocking INV surface)

**Verification**:
- The guarded scoped build of the four modules exits 0 with no diagnostics.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `grep -n "assert_not_exists" FormalSystem/Semantics/{TemporalRules,TemporalIntervals,RankProgress}.lean` shows the directory form in all three, and `PointTransport.lean` shows the two-name `DerivationTree`-rooted form.
- Each of the four modules opens with a `# ` title and carries `## Main Results`, `## References` and `## Tags`.

---

### Phase 2: Positive Reading for Release and Trigger [COMPLETED]

**Goal**: `release_iff_forall` and `trigger_iff_forall` exist in `TemporalIntervals.lean`, each
proved from the existing negated-clause lemma, with three test rows spanning L and L⋆.

**Tasks**:
- [x] Add `release_iff_forall` immediately after `trigger_iff` in `TemporalIntervals.lean`, with the signature pinned in `## Lean Challenge Statements` below and the compiled proof: `rw [release_iff]`, then `constructor`; the `mp` direction uses `by_contra` and `push Not` (this toolchain's spelling, as at `TruthClauses.lean`'s own call site -- not `push_neg`), the `mpr` direction `rintro`s the existential and discharges both arms.
- [x] Add `trigger_iff_forall` beside it: the `snce`/`<`-reversed mirror, same proof skeleton, opening `rw [trigger_iff]`.
- [x] Give both a docstring (C16 `docBlame`) and declare both as `theorem`, never `lemma` (C23 gates live `lemma`).
- [x] Add three test rows to `Tests/BimodalTest/Semantics/TemporalRulesTest.lean`, beside the existing `release_iff`/`trigger_iff` rows: `release_iff_forall` at L via `Formula.release`; `release_iff_forall` at L⋆ with an explicit `regs : ℕ → F.Duration`, spelling the `(StarFormula.untl guard.neg event.neg).neg` encoding because L⋆ has no named `release`; and `trigger_iff_forall` at L via `Formula.trigger`.
- [x] Guarded scoped build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.TemporalIntervals BimodalTest.Semantics.TemporalRulesTest`, diagnostic-free.
- [x] Regenerate and stage `typst/generated/status.typ` (`bash scripts/typst-sync-check.sh --fix`) and `README.md` (`bash scripts/check-module-invariants.sh --emit-inventory`).

**Timing**: 50 minutes

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: Both declarations are additive with no change to any existing signature and the test module needs no new import, so the guarded scoped build of the one edited library module plus the one edited test module is the cheapest check that covers the whole edit.

**Scope Hypothesis**: Three test rows and two new theorems, and no new import is needed in `TemporalRulesTest.lean` because it already imports `FormalSystem.StarLanguage.StarTruth` (read at plan authoring time, in that file's import block). Confirm with `grep -n "^import" Tests/BimodalTest/Semantics/TemporalRulesTest.lean` before writing the L⋆ row; if the L⋆ row needs anything further, add the import in this phase rather than deferring it.

**Files to modify**:
- `FormalSystem/Semantics/TemporalIntervals.lean` - `release_iff_forall` and `trigger_iff_forall` after `trigger_iff`
- `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` - three rows: release at L, release at L⋆, trigger at L
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated `dir=FormalSystem` inventory totals

**Verification**:
- The guarded scoped build of `FormalSystem.Semantics.TemporalIntervals` and `BimodalTest.Semantics.TemporalRulesTest` exits 0 with no diagnostics.
- Both new theorems match the signatures pinned in `## Lean Challenge Statements` character for character modulo whitespace.
- Each of `release_iff_forall` and `trigger_iff_forall` occurs at least once in `Tests/` outside its own declaring line (the condition C17's dead-declaration scan reads).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 3: Primitive-Tense Persistence, Reaching L⁻ [COMPLETED]

**Goal**: `allFuture_persist_of_tense` and `allPast_persist_of_tense` exist in
`TemporalRules.lean`, stated over `AllFutureClause`/`AllPastClause` so L⁻ -- which has
`TenseClauses` but no `untl` -- is covered, with one L⁻ test row each.

**Tasks**:
- [x] Add a new `section TensePersistence` to `TemporalRules.lean` immediately after `end Persistence`, with no shared `variable` line: both lemmas carry the explicit binders pinned below, because neither needs the `Persistence` section's `[BotClause L] [ImpClause L]`.
- [x] Add `allFuture_persist_of_tense` as the explicit term the research compiled: `(AllFutureClause.allFuture_clause M τ s e P).mpr fun u hsu => (AllFutureClause.allFuture_clause M τ t e P).mp h u (lt_trans hts hsu)`. No tactic block -- the term keeps the measured `[propext]` profile.
- [x] Add `allPast_persist_of_tense` dually, with `hst : s < t` and `lt_trans hus hst`.
- [x] Docstrings on both; `theorem`, not `lemma`. Each docstring says explicitly that this is the primitive-tense sibling of `allFuture_persist`/`allPast_persist` and that it is the form L⁻ can use.
- [x] Add `import FormalSystem.MinusLanguage.MinusTruth` to `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` (it is not there today) and open `FormalSystem.MinusLanguage` alongside the existing opens.
- [x] Add two L⁻ test rows: `allFuture_persist_of_tense (L := MinusFormula) (e := PUnit.unit) h hts` closing `MinusTruthAt M τ t (MinusFormula.allFuture P) → t < s → MinusTruthAt M τ s (MinusFormula.allFuture P)`, and the `allPast` mirror.
- [x] Guarded scoped build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.TemporalRules BimodalTest.Semantics.TemporalRulesTest`, diagnostic-free.
- [x] Regenerate and stage `typst/generated/status.typ` and `README.md` as in Phase 1.

**Timing**: 45 minutes

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: The two theorems are additive in one library module and the only new import lands in a test module, which `scripts/check-metalogic-cycles.sh` does not scan, so the guarded scoped build of `FormalSystem.Semantics.TemporalRules` plus `BimodalTest.Semantics.TemporalRulesTest` is the cheapest check covering the edit.

**Scope Hypothesis**: Two new theorems, two test rows and exactly one new test-module import. The claim that L⁻ carries `TenseClauses` only -- so these lemmas, and not the existing `untl`-derived ones, are what reaches it -- is carried from `reports/01_pointed-semantic-lemmas-followups.md`'s reading of `MinusTruth.lean`; confirm at implementation time by compiling the two L⁻ rows, which is the same evidence the report's probe used.

**Files to modify**:
- `FormalSystem/Semantics/TemporalRules.lean` - new `TensePersistence` section with both primitive-tense lemmas
- `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` - `MinusTruth` import and two L⁻ rows
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated `dir=FormalSystem` inventory totals

**Verification**:
- The guarded scoped build exits 0 with no diagnostics.
- Both new theorems match the pinned signatures.
- The two L⁻ rows compile, which is what establishes that the lemmas reach a language with no `untl`.
- Each of `allFuture_persist_of_tense` and `allPast_persist_of_tense` occurs in `Tests/` outside its own declaring line.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 4: Env-Aware Point Relations and the Two L⋆ Transport Factories [COMPLETED]

**Goal**: `PointTransport.lean` imports the two L⋆ modules, carries `SameStateNowEnv`/`ShiftedEnv`
with their `.intro` lemmas beside the existing environment-blind relations, and carries
`star_iffTransport_timeShift`/`star_iffTransport_stateLocal` in a new `Star` section, with one
test row each.

**Tasks**:
- [x] Add `import FormalSystem.StarLanguage.StarTruth` and `import FormalSystem.StarLanguage.StarStateLocal` to `PointTransport.lean` (precedent for a `FormalSystem/Semantics/` module importing L⋆: `StateLocalTransfer.lean` and `ValidityLayer.lean`), and `open FormalSystem.StarLanguage` alongside the existing opens.
- [x] Extend the lock to `assert_not_exists FormalSystem.ProofSystem.DerivationTree FormalSystem.PlusLanguage.PlusDerivationTree FormalSystem.StarLanguage.StarDerivationTree`, and note the addition in the docstring paragraph Phase 1 wrote.
- [x] Add `SameStateNowEnv` and `ShiftedEnv` to the `Relations` section, with docstrings, as `def`s whose bodies are the conjunctions pinned in the research report (`SameStateNow p q ∧ p.env = q.env`; `Shifted Δ p q ∧ q.env = shift p.env`). Do **not** modify `SameStateNow`, `Shifted`, or either of their `.intro` lemmas: their two-environment signatures are consumed by `plus_iffTransport_stateLocal` and its existing test row.
- [x] Add `SameStateNowEnv.intro` and `ShiftedEnv.intro` in the directory's `.intro` style, both discharged by `⟨⟨rfl, _⟩, rfl⟩`-shaped terms.
- [x] Add a `/-! ## TM⋆ factories -/` marker and a `section Star` after `end Plus`, holding `star_iffTransport_timeShift` and `star_iffTransport_stateLocal` with the compiled proofs: `rintro ⟨τ, t, v⟩ ⟨σ, s, w⟩ ⟨⟨_, _⟩, _⟩`, `dsimp only at`, `subst`, then `exact starTruthAt_timeShift M φ σ t Δ v` / `exact isStateLocal_of_stateLocal hφ F M τ σ t v h` -- the same `dsimp only at`-before-`subst` shape the L⁺ factories use.
- [x] Keep the `(L := StarFormula)` ascription on the relation in `star_iffTransport_timeShift`'s statement and add a one-line comment saying it is load-bearing: without it, `fun v i => v i + Δ` fails to elaborate with `Function expected at v but this term has type TruthEnv.Env ?m F`.
- [x] Add two test rows to `Tests/BimodalTest/Semantics/PointTransportTest.lean`, one per factory; these rows are also what give `SameStateNowEnv`, `ShiftedEnv` and both `.intro` lemmas their C17 references. The `ShiftedEnv.intro` call site needs the same `(L := StarFormula)` ascription plus an explicit `(fun (v : ℕ → F.Duration) i => v i + Δ)`.
- [x] Guarded scoped build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.PointTransport FormalSystem.Semantics BimodalTest.Semantics.PointTransportTest`, diagnostic-free.
- [x] Re-run `bash scripts/check-metalogic-cycles.sh` -- Assertion B asserts the library-wide upward import set EQUALS a 10-line allowlist and fails on surplus as well as deficit, so a new library import is checked here rather than discovered at the end.
- [x] Regenerate and stage `typst/generated/status.typ` and `README.md` as in Phase 1.

**Timing**: 75 minutes

**Depends on**: 3

**Verification Tier**: interface

**Tier Justification**: The two new library imports change `FormalSystem.Semantics.PointTransport`'s own import closure, so the covering check is the guarded build of that module plus its two enumerated direct dependents (`FormalSystem/Semantics.lean` and `BimodalTest.Semantics.PointTransportTest`, the only two importers in the tree) together with `bash scripts/check-metalogic-cycles.sh`, whose Assertion B is the one library-wide check a new import can move.

**Scope Hypothesis**: Six new declarations here (two `def`s, two `.intro` theorems, two factories), two new imports and two test rows -- and the hypothesis that `FormalSystem/Semantics/** → FormalSystem/StarLanguage/**` is not an upward edge, so no allowlist extension is owed. That hypothesis was measured at plan authoring time: `scripts/check-metalogic-cycles.sh` reports PASS with the upward set exactly its recorded 10 lines, none of them a `Semantics` source, while `StateLocalTransfer.lean` already imports `FormalSystem.StarLanguage.StarStateLocal`. Confirm by re-running that gate in this phase; if it reports surplus, extend `scripts/check-metalogic-cycles.sh`'s allowlist in this same phase and add that file to this phase's scope rather than deferring.

**Files to modify**:
- `FormalSystem/Semantics/PointTransport.lean` - two L⋆ imports, lock extension, `SameStateNowEnv`/`ShiftedEnv` and their `.intro` lemmas, new `Star` section with both factories
- `Tests/BimodalTest/Semantics/PointTransportTest.lean` - one row per L⋆ factory
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated `dir=FormalSystem` inventory totals

**Verification**:
- The guarded build of `FormalSystem.Semantics.PointTransport`, `FormalSystem.Semantics` and `BimodalTest.Semantics.PointTransportTest` exits 0 with no diagnostics.
- `bash scripts/check-metalogic-cycles.sh` exits 0, with its upward-import set unchanged from the 10 recorded lines.
- The six new declarations match the pinned signatures, and `SameStateNow`, `Shifted`, `SameStateNow.intro` and `Shifted.intro` are byte-identical to their pre-phase text.
- The existing `plus_iffTransport_stateLocal` test row still compiles unchanged.
- Each of the six new names occurs in `Tests/` outside its own declaring line.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 5: Full-Tree Reconciliation and Gate Battery [COMPLETED]

**Goal**: The whole project builds, the repository's own invariant and sync gates are green or
their red findings are accounted for as pre-existing, both generated surfaces are current, and the
complete agent-system gate set is explicitly deferred to the orchestration close.

**Tasks**:
- [x] Full guarded build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. Detach as a shell-level background job and block on it with the bounded single-call idiom if it does not plausibly fit one foreground call.
- [x] `bash scripts/check-module-invariants.sh` (full). Read C16 (`docBlame`, `unusedArguments`), C17 (dead declarations), C20, C23, C26 and INV. Every finding naming one of this task's touched files is in scope and must be fixed here; a finding naming only untouched files is recorded as a pre-existing baseline item with its name, not treated as a blocker and not fixed by editing an out-of-scope file.
- [x] If C16 raises `unusedArguments` on any new declaration, remedy it with a hand-inserted row in `scripts/nolints.json`, placed next to an existing exemption of the same shape -- never `lake exe runLinter --update`, which rewrites the whole ledger. Add `scripts/nolints.json` to this phase's touched set if that happens.
- [x] `bash scripts/typst-sync-check.sh` (full: Checks 2, 2b, 3, 4), and `bash scripts/check-module-invariants.sh --emit-inventory --check`. Stage any residual regeneration either one asks for.
- [x] `bash scripts/check-metalogic-cycles.sh` -- all three assertions.
- [x] Axiom profiles, via `lean_verify` on fully qualified names: `[propext]` expected for `allFuture_persist_of_tense`, `allPast_persist_of_tense` and `star_iffTransport_stateLocal`; `[propext, Classical.choice, Quot.sound]` for `release_iff_forall`, `trigger_iff_forall` and `star_iffTransport_timeShift`. A profile matching these is recorded; a profile exceeding them is investigated before close.
- [x] Confirm all ten identifiers named under `- **Goals**:` are present as declarations in the resolved Lean source roots (the `lean-plan-compliance-check.sh` spot-check's default must-exist polarity). All ten are `theorem` or `def` declarations, so the script's known tactic-syntax false-positive class does not apply here.
- [x] Scoped touched-path discharge for this dispatch: `bash .claude/scripts/verify-touched.sh --task-dir /home/benjamin/Projects/BimodalLogic/specs/989_pointed_semantic_lemmas_after_merge_followups --session <session_id> --dispatch-seq <dispatch_seq>` over this task's touched paths.
- [x] Record explicitly, in this phase's verification notes, that the complete agent-system gate set (`bash .claude/scripts/verify-deploy.sh`) is DEFERRED to the orchestration close's once-per-invocation batch gate stage and was not independently run in this dispatch.

**Timing**: 45 minutes

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Scope Hypothesis**: This phase expects to modify nothing beyond a residual regeneration of the
two generated surfaces, because phases 1-4 each regenerated and staged them -- and expects
`scripts/nolints.json` to need no row at all, since no new declaration here carries a
plan-pinned-but-unread hypothesis, the shape that ordinarily produces an `unusedArguments`
finding. Confirm by running the full gate battery before editing anything: the actual file set is
whatever `typst-sync-check.sh`, `--emit-inventory --check` and `check-module-invariants.sh`
report, not this prediction.

**Files to modify**:
- `typst/generated/status.typ` - any residual regeneration the full sync check asks for
- `README.md` - any residual inventory regeneration
- `scripts/nolints.json` - only if C16 raises `unusedArguments` on a new declaration; a single hand-inserted row beside an existing exemption of the same shape

**Verification**:
- The full guarded `lake build` exits 0 with no diagnostics (CI builds with `--wfail`, so a warning is a failure).
- `bash scripts/check-module-invariants.sh` is green, or every red finding is enumerated by name and shown to name no file this task touched, with each touched file shown to pass its own checks individually.
- `bash scripts/typst-sync-check.sh` exits 0 and `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0 on all three assertions.
- All ten declarations named under `- **Goals**:` resolve in the source roots with the pinned signatures, and each occurs in `Tests/` outside its own declaring line.
- The measured axiom profiles match the expectations listed above.
- `bash .claude/scripts/verify-touched.sh ...` reports its verdict for this task's touched paths, and the deferral of the complete gate set to the orchestration close is recorded in this phase's notes.

#### Verification Notes

**Full guarded `lake build`**: exit 0, 3027 jobs, zero `error:` and zero `warning:` lines across
both captured streams, and the `.olean` of every one of the six modules this task touched is
newer than its source (all three evidence tiers of
`context/project/lean4/operations/long-builds.md`'s "Reading the build's verdict").

**Green gates**: `scripts/typst-sync-check.sh` (full, all 4 checks),
`scripts/check-module-invariants.sh --emit-inventory --check`, and
`scripts/check-metalogic-cycles.sh` (all three assertions, upward-import set still exactly its
recorded 10 lines).

**Axiom profiles measured via `lean_verify` on fully qualified names** — every one matches the
plan's prediction, none exceeds it:

| Declaration | Measured | Predicted |
|---|---|---|
| `allFuture_persist_of_tense` | `[propext]` | `[propext]` |
| `allPast_persist_of_tense` | `[propext]` | `[propext]` |
| `star_iffTransport_stateLocal` | `[propext]` | `[propext]` |
| `release_iff_forall` | `[propext, Classical.choice, Quot.sound]` | same |
| `trigger_iff_forall` | `[propext, Classical.choice, Quot.sound]` | same |
| `star_iffTransport_timeShift` | `[propext, Classical.choice, Quot.sound]` | same |

**Zero-debt scans**: `sorry_count` 0; `axiom_count` 14, identical to the pre-task baseline; the
two vacuous-pattern matches (`PointTransport.AnyPoint`, `Examples.int_domain_universal`) are
byte-identical to their pre-task text and neither is a placeholder — `AnyPoint := True` is the
correct semantics of "any two points of the frame", the index `plus_iffTransport_box` consumes.

**All ten `- **Goals**:` declarations resolve** in the source roots at the pinned signatures, and
each occurs in `Tests/` outside its own declaring line. `scripts/nolints.json` needed no row: the
C16 `env_linter` batch over the FormalSystem closure (`docBlame`, `unusedArguments` and four
others) reports no un-nolisted finding, so the phase's Scope Hypothesis held.

**Pre-existing red findings, enumerated by name, none naming a file this task touched**:

- `FAIL C14 axiom sets diverged from baseline` — the sole divergence is one absent line,
  `FormalSystem.Metalogic.Decidability.RaySummary.exists_kappa_collision_cellAt_ne_at_K4_clip`.
  Proven pre-existing: at the pre-task commit the baseline in `scripts/check-module-invariants.sh`
  already targeted that name while the only declaration in the tree was already
  `..._clip_pre`, so the `#print axioms` emitted no line then either. Neither
  `scripts/check-module-invariants.sh` nor anything under `FormalSystem/Metalogic/` is in this
  task's diff. It is a naming drift, not an axiom change.
- `FAIL C16 env_linter batch over the other lakefile roots` — six entries, in
  `BimodalLibTest.DiagnosticsTest`, `BimodalTest.Automation.ProofModeTemporalTest` and four
  `BimodalTools.*` modules. Neither `scripts/c16-roots-baseline.txt` nor any of those source
  trees is in this task's diff, and neither of the two test modules this task edited appears in
  the findings.
- `verify-touched.sh` reported 16 failing agent-system shell suites across its narrowed and OWED
  passes. This task touched no file under `.claude/**`, `scripts/**` or `agent-system/**`, so no
  failing suite subjects anything it changed; two spot-checks confirm unrelated causes
  (`test-source-store-path-lib.sh` fails on a machine-level source-store resolution —
  `/home/benjamin/.config/nvim` for the `core` extension; `test-lean-plan-compliance-check.sh`
  merely exceeds a 170s bound), and a sibling dispatch's `verify-deploy` held the host gate lock
  for at least 195s during the run. All six of this task's Lean paths resolved to the
  OWED fallback record, and their real covering evidence is the full `lake build` plus the
  repository's own Lean gates above.

**Full gate set DEFERRED**: the complete agent-system gate set (`bash .claude/scripts/verify-deploy.sh`)
was NOT independently run in this dispatch. It is deferred to the once-per-invocation batch gate
stage at the orchestration close, per this dispatch's Batch Gate Deferral directive, and its
result is attributed back to this task by its own `modified_files`.

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.TruthClauses
import FormalSystem.Semantics.PointTransport
import FormalSystem.StarLanguage.StarTruth
import FormalSystem.StarLanguage.StarStateLocal

namespace FormalSystem.Semantics.TemporalIntervals

open TruthClauses

theorem release_iff_forall {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (neg (UntlClause.untl (neg guard) (neg event))) ↔
      ∀ s : F.Duration, t < s → TruthEnv.T M τ s e event ∨
        ∃ r : F.Duration, t < r ∧ r < s ∧ TruthEnv.T M τ r e guard := sorry

theorem trigger_iff_forall {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [SnceClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (event guard : L) :
    TruthEnv.T M τ t e (neg (SnceClause.snce (neg guard) (neg event))) ↔
      ∀ s : F.Duration, s < t → TruthEnv.T M τ s e event ∨
        ∃ r : F.Duration, s < r ∧ r < t ∧ TruthEnv.T M τ r e guard := sorry

end FormalSystem.Semantics.TemporalIntervals

namespace FormalSystem.Semantics.TemporalRules

open TruthClauses

theorem allFuture_persist_of_tense {L : Type} [TruthEnv L] [AllFutureClause L]
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {e : TruthEnv.Env L F}
    {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (AllFutureClause.allFuture P)) (hts : t < s) :
    TruthEnv.T M τ s e (AllFutureClause.allFuture P) := sorry

theorem allPast_persist_of_tense {L : Type} [TruthEnv L] [AllPastClause L]
    {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {e : TruthEnv.Env L F}
    {t s : F.Duration} {P : L}
    (h : TruthEnv.T M τ t e (AllPastClause.allPast P)) (hst : s < t) :
    TruthEnv.T M τ s e (AllPastClause.allPast P) := sorry

end FormalSystem.Semantics.TemporalRules

namespace FormalSystem.Semantics.PointTransport

open FormalSystem.StarLanguage

def SameStateNowEnv {L : Type} [TruthEnv L] {F : TaskFrame} (p q : Point L F) : Prop := sorry

def ShiftedEnv {L : Type} [TruthEnv L] {F : TaskFrame} (Δ : F.Duration)
    (shift : TruthEnv.Env L F → TruthEnv.Env L F) (p q : Point L F) : Prop := sorry

theorem SameStateNowEnv.intro {L : Type} [TruthEnv L] {F : TaskFrame} (τ σ : WorldHistory F)
    (t : F.Duration) {e : TruthEnv.Env L F} (h : τ.state t = σ.state t) :
    SameStateNowEnv (⟨τ, t, e⟩ : Point L F) ⟨σ, t, e⟩ := sorry

theorem ShiftedEnv.intro {L : Type} [TruthEnv L] {F : TaskFrame} (σ : WorldHistory F)
    (t Δ : F.Duration) (shift : TruthEnv.Env L F → TruthEnv.Env L F)
    (e : TruthEnv.Env L F) :
    ShiftedEnv Δ shift (⟨σ.timeShift Δ, t, e⟩ : Point L F) ⟨σ, t + Δ, shift e⟩ := sorry

theorem star_iffTransport_timeShift {F : TaskFrame} (M : TaskModel F) (Δ : F.Duration)
    (φ : StarFormula) :
    IffTransport (ShiftedEnv (L := StarFormula) Δ (fun v i => v i + Δ)) M M φ φ := sorry

theorem star_iffTransport_stateLocal {F : TaskFrame} {φ : StarFormula} (hφ : φ.StateLocal)
    (M : TaskModel F) :
    IffTransport (SameStateNowEnv (L := StarFormula)) M M φ φ := sorry

end FormalSystem.Semantics.PointTransport
```

The two `def` bodies are `sorry` because this section pins statements, never definitions: their
intended bodies are `SameStateNow p q ∧ p.env = q.env` and `Shifted Δ p q ∧ q.env = shift p.env`,
recorded in Phase 4's task list and in `reports/01_pointed-semantic-lemmas-followups.md`.

## Testing & Validation

- [x] `release_iff_forall` exercised at L (via `Formula.release`) and at L⋆ (via the spelled-out
  `(untl guard.neg event.neg).neg` encoding with an explicit `regs`).
- [x] `trigger_iff_forall` exercised at L.
- [x] `allFuture_persist_of_tense` and `allPast_persist_of_tense` each exercised at L⁻, the
  language the existing `untl`-derived persistence lemmas cannot reach.
- [x] `star_iffTransport_timeShift` and `star_iffTransport_stateLocal` each exercised at L⋆,
  which also references `SameStateNowEnv`, `ShiftedEnv` and both `.intro` lemmas.
- [x] The existing `plus_iffTransport_stateLocal` and `iffTransport_timeShift` test rows still
  compile unchanged, establishing that the env-aware relations were added rather than substituted.
- [x] Across the four test rounds the new declarations are exercised at L, L⁻, L⁺ (unchanged rows)
  and L⋆.
- [x] Full `lake build` green with no diagnostics; `check-module-invariants.sh`,
  `typst-sync-check.sh` and `check-metalogic-cycles.sh` green or their findings accounted for as
  pre-existing and untouched-file-only.

## Artifacts & Outputs

- `FormalSystem/Semantics/TemporalIntervals.lean` -- titled docstring, directory-form lock,
  `release_iff_forall`, `trigger_iff_forall`
- `FormalSystem/Semantics/TemporalRules.lean` -- titled docstring, directory-form lock, new
  `TensePersistence` section with `allFuture_persist_of_tense` and `allPast_persist_of_tense`
- `FormalSystem/Semantics/RankProgress.lean` -- titled docstring, directory-form lock
- `FormalSystem/Semantics/PointTransport.lean` -- docstring sections with the recorded import
  chain, respelled and extended lock, two L⋆ imports, `SameStateNowEnv`, `ShiftedEnv`, both
  `.intro` lemmas, new `Star` section with both factories
- `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` -- `MinusTruth` import and five new rows
- `Tests/BimodalTest/Semantics/PointTransportTest.lean` -- two new rows
- `typst/generated/status.typ` -- regenerated counts
- `README.md` -- regenerated `dir=FormalSystem` inventory totals
- `scripts/nolints.json` -- conditional: one hand-inserted row only if C16 raises
  `unusedArguments` on a new declaration
- `specs/989_pointed_semantic_lemmas_after_merge_followups/summaries/01_pointed-semantic-lemmas-followups-summary.md`

## Rollback/Contingency

Every phase is additive and independently revertible: each lands its own commit with its own
staged generated surfaces, so reverting a phase is `git revert` of that commit, which restores
both the Lean edit and the matching regenerated counts together.

The one case needing care is a working tree that must be discarded mid-phase. That is a genuine
rollback, not a routine checkpoint: take the snapshot first using the invocation shape
`context/contracts/recovery.md`'s rollback rung gives (task number explicit, with its
out-of-scope override flag only where the discard genuinely reaches outside this task's declared
file scope), then run the discard. For an ordinary defensive checkpoint before a risky edit --
Phase 4's lock extension and new imports are the plausible place -- use
`bash .claude/scripts/git-snapshot.sh 989 --no-revert`, which is durable without reverting the
working tree.

Contingency branches, by phase:

- **Phase 1**, if the directory-form lock unexpectedly fails on one of the three generic modules:
  that module keeps its current lock, the failing import chain is recorded in its docstring the
  same way `PointTransport.lean`'s is, and the phase closes `[COMPLETED WITH EXCLUSIONS]` with a
  `#### Reasoned Exclusions` record naming the module. It is not grounds to weaken a lock.
- **Phase 4**, if `check-metalogic-cycles.sh` Assertion B reports surplus: extend its allowlist in
  the same phase and add `scripts/check-metalogic-cycles.sh` to that phase's file scope. Do not
  defer it, and do not drop the imports to keep the gate quiet.
- **Phase 5**, if a gate is red only for pre-existing, untouched-file reasons: that is a recorded
  PASS for the phase, with the pre-existing findings enumerated by name and per-touched-file
  evidence attached. It is not a blocker, and it is not grounds to edit an out-of-scope file to
  force a repo-wide count to zero.
