# Implementation Plan: Task #984

- **Task**: 984 - Promote next_iff_covBy and prev_iff_covBy to the generic next_iff/prev_iff
- **Status**: [COMPLETED]
- **Effort**: 4.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/984_promote_next_prev_covby_to_generic_lemmas/reports/01_promote-next-prev-covby-generic.md
- **Artifacts**: plans/01_promote-next-prev-covby-generic.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`FormalSystem/Semantics/TemporalRules.lean` already states the covBy characterization of `X`/`Y`
generically over the clause layer; the base language restates it, and a third `succ`-form copy
sits in `FormalSystem/Metalogic/DiscreteNonCompactness.lean`. This plan adds the one missing
generic lemma pair (`next_iff_succ`/`prev_iff_pred`, over `TruthEnv` + `UntlClause`/`SnceClause`),
then re-bodies all five base-language declarations as one-line applications of the generic pair
while keeping every name and statement byte-identical. The prose that currently records the
duplication as deliberate and unresolved is rewritten to state the resulting design, and the
generated surfaces the line-count changes disturb are regenerated.

Nothing downstream changes shape: no declaration is renamed or deleted, no statement is altered,
no attribute is added, and no new import is needed anywhere except one line in
`SentenceTruth.lean`.

### Research Integration

Four findings from the report drive the structure rather than being rediscovered:

1. **The succ form must be promoted alongside the covBy form, and it is free.** The covBy lemma
   alone cannot discharge `Metalogic.truthAt_next_iff`, which is a `succ`-form statement, so a
   plan covering only the covBy form cannot close the task's third deliverable. A generic
   `next_iff_succ`/`prev_iff_pred` pair compiles with `FormalSystem.Semantics.TemporalRules` as
   its only import — every order lemma it consumes is already in that module's closure. Phase 1
   therefore promotes both forms.
2. **Removal-and-repoint-uses is not available.** `scripts/check-module-invariants.sh` pins
   `FormalSystem.Metalogic.truthAt_next_iff` and `FormalSystem.Metalogic.truthAt_next_iterate`
   by fully qualified name at lines 2316-2317 against an exact `#print axioms` string, and
   `SourceLanguage.sat_iff` consumes `next_iff_covBy`/`prev_iff_covBy` as *simp lemmas* whose LHS
   shape the generic statement does not have. Every phase below re-bodies and keeps the name.
3. **`readme-lint.sh` is already red** with 7 new stale findings in seven directories this task
   never touches, so the acceptance criterion in Phase 5 compares the finding SET, not the exit
   code.
4. **Repointing improves the axiom profile.** `next_iff_covBy`/`prev_iff_covBy` lose `Quot.sound`
   (`[propext, Quot.sound]` to `[propext]`); the succ forms stay at
   `[propext, Classical.choice, Quot.sound]`, matching the C14 pin byte for byte. No pinned
   baseline covers the covBy names, so the improvement breaks nothing.

Two further mechanical facts were measured at plan-authoring time and are not in the report:

5. **`FormalSystem/NomicLanguage/README.md` is a second fresh, ungrandfathered README.** It is
   stamped `2026-10-15`, equal to its directory's last commit date, and is absent from
   `scripts/readme-date-baseline.txt`. The report singled out `SourceLanguage/README.md` as "the
   one mandatory bump"; because the doc sweep also touches
   `FormalSystem/NomicLanguage/NomicTruth.lean`, there are **two** mandatory bumps, and skipping
   this one takes `readme-lint.sh` from 7 new stale findings to 9, not 8.
6. **Every phase of this task is commit-blocked on `typst/generated/status.typ`.**
   `.githooks/pre-commit` refuses any commit staging a `.lean` path while that file has drifted,
   and `scripts/typst-sync-check.sh --fix` is build-requiring. Every phase below edits at least
   one `.lean` file — including the docstring-only sweep, since a docstring edit still moves line
   counts — so each phase carries its own guarded `lake build` plus `--fix` run and declares
   `typst/generated/status.typ` in its own file scope. This is
   `context/project/lean4/patterns/plan-authoring-gate-collisions.md` Condition 1, surface (b),
   and it is the reason the phases are serialized rather than run as parallel waves.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in this dispatch.

## Goals & Non-Goals

**Goals**:

- One generic `succ`/`pred` characterization pair in `FormalSystem/Semantics/TemporalRules.lean`,
  serving L, L⁺ and L⋆ from a single statement.
- All four `SourceLanguage` declarations (`next_iff_covBy`, `prev_iff_covBy`, `next_iff_succ`,
  `prev_iff_pred`) re-bodied as one-line applications of the generic lemmas, names and statements
  unchanged.
- `Metalogic.truthAt_next_iff` re-bodied likewise, name, statement and axiom profile unchanged.
- Every documentation surface that records the duplication as deliberate and unresolved rewritten
  to state the resulting design, with no supersession narration.
- Zero `sorry`, zero new axiom, zero new attribute, no statement change visible to any downstream
  consumer.

**Non-Goals**:

- `Metalogic/AuxiliaryAtoms.lean`'s `plusTruthAt_next_iff_succ`. The same generic lemma serves it
  and the opportunity is compile-verified real, but it is outside the task's declared deliverable
  and sits in a heavily pinned module. Its docstring's promotion note is updated in Phase 4; its
  body is not touched. Record it as a follow-up.
- `NomicLanguage/NomicTruth.lean`'s own `next_iff_succ`. That module has no `TruthEnv` instance
  and evaluates over a different point shape, so no generic lemma can reach it. Its docstring
  reference is repointed in Phase 4; the transcription stays.
- Adding any attribute (`@[simp]`, `@[truth_norm]`) to the new generic lemmas. Two independent
  recorded reasons forbid it.
- Chasing `readme-lint.sh` to exit 0, or editing any of the seven unrelated directories whose
  stale stamps make it red today.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A phase commit is refused because `typst/generated/status.typ` drifted | H | H | Every phase below schedules the guarded `lake build` then `scripts/typst-sync-check.sh --fix` and declares `typst/generated/status.typ` in its own file scope. Never deferred. |
| `@[simp]` attached to the new generic lemmas out of habit (L's own wrappers carry `@[simp, truth_norm]`) | H | M | Phase 1's task list states the prohibition and names both recorded reasons; Phase 1's verification greps the new section for any attribute. |
| `next_iff_covBy`/`prev_iff_covBy` deleted instead of re-bodied, breaking `sat_iff`'s simp set | H | M | Phase 2 states the reason inline; `sat_iff` is re-proved verbatim in the same phase's build. |
| `truthAt_next_iff`/`truthAt_next_iterate` renamed or removed, breaking C14's exact-string pin at `scripts/check-module-invariants.sh:2316-2317` | H | L | Phase 3's task list forbids it and its verification re-measures both axiom lines against the pinned strings. |
| `readme-lint.sh`'s pre-existing red read as this task's regression | M | H | Phase 5 captures the baseline finding set *before* editing and compares sets, not exit codes. The seven pre-existing directories are enumerated there. |
| The `NomicLanguage/README.md` stamp is overlooked because the report named only `SourceLanguage` | M | H | Phase 4 carries the bump as named work, with the measurement that distinguishes the fresh from the grandfathered READMEs. |
| A grandfathered stamp is bumped "for tidiness", permanently un-grandfathering that row | L | M | Phase 4 and Phase 5 both state that `FormalSystem/README.md`, `FormalSystem/Semantics/README.md` and `FormalSystem/Metalogic/README.md` stamps are left alone, and why the change is one-way. |
| Documentation prose drifts into supersession narration ("no longer deliberate", "previously unresolved") | M | M | Phases 2-5 each restate the `no-record-versioning-in-deliverables.md` constraint; the `## Not formalized` row is *removed*, not amended with a status change. |
| A mistake in `TemporalRules.lean` is expensive to discover (it sits in a 347-module closure) | M | L | Phase 1's edit is purely additive, carries no attribute and introduces no import; the build is scoped to that module plus its test before any wider build runs. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

The chain is fully serial by necessity, not by conservatism. Phases 2, 3 and 4 are logically
independent of one another — none consumes another's output — but all three must write
`typst/generated/status.typ` (finding 6 above), and all three regenerate inventory blocks through
the same `scripts/check-module-invariants.sh --emit-inventory` pass. Two of them running
concurrently would race on those shared generated files. There is therefore no parallelism to
claim here, and each wave holds exactly one phase.

---

### Phase 1: Promote the generic succ/pred pair into TemporalRules.lean [COMPLETED]

**Goal**: `FormalSystem.Semantics.TemporalRules` gains `next_iff_succ` and `prev_iff_pred`,
stated over the clause layer, with per-language test rows exercising them.

**Tasks**:

- [ ] Add a new `section DiscreteCollapse` to `FormalSystem/Semantics/TemporalRules.lean`,
  placed after `end NextPrev` (before `section Persistence`), opening with
  `variable {L : Type} [TruthEnv L] [BotClause L] {F : TaskFrame}` mirroring the `NextPrev`
  block.
- [ ] State `next_iff_succ [UntlClause L] [SuccOrder F.Duration] [NoMaxOrder F.Duration]`
  taking `(M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (φ : L)`
  and concluding `TruthEnv.T M τ t e (next φ) ↔ TruthEnv.T M τ (Order.succ t) e φ`. Prove it by
  `rw [next_iff]` followed by the same two-branch argument
  `SourceLanguage.SentenceTruth.next_iff_succ` uses today (`Order.succ_le_of_lt`,
  `lt_or_eq_of_le`, `Order.lt_succ`, `Order.le_of_lt_succ`, `not_lt`, `absurd`). Reuse that
  route unchanged rather than deriving a new one.
- [ ] State the dual `prev_iff_pred [SnceClause L] [PredOrder F.Duration]
  [NoMinOrder F.Duration]` concluding
  `TruthEnv.T M τ t e (prev φ) ↔ TruthEnv.T M τ (Order.pred t) e φ`, proved by `rw [prev_iff]`
  and the dual branch argument (`Order.le_pred_of_lt`, `Order.pred_lt`, `Order.le_of_pred_lt`).
- [ ] Attach **no attributes** to either lemma. `TruthClauses.lean`'s extension contract forbids
  attributes on a generic lemma outright, and `DiscreteNonCompactness.lean` independently records
  that a simp-normal `next` rewrite would fire inside the proof-theoretic reasoning in
  `Theorems/DiscreteUnfolding.lean`. Both reasons agree; honour both.
- [ ] Add no import. Every order lemma consumed is already in the module's closure via
  `FormalSystem.Semantics.TruthClauses`; confirm by not adding one and letting the scoped build
  decide.
- [ ] Give each lemma a doc comment saying it is the discrete collapse of the covBy
  characterization, and that the covBy form is the theorem while this is the corollary. Do not
  add a `Paper:` line — no theorem-index row names these declarations, and C15 resolves
  index-row-to-declaration, not the reverse.
- [ ] Add both names to the module docstring's `## Main Results` list, after the `next_at`/
  `prev_at` bullet.
- [ ] Add test rows to `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` following that file's
  existing `example` pattern: one at `Formula` with `(e := PUnit.unit)`, one at `PlusFormula`
  with `(e := PUnit.unit)`, and one at `StarFormula` passing the file's own `regs` so the
  `Env`-threading obligation is exercised at the one language whose `Env` is not `PUnit`. Add
  `[SuccOrder F.Duration] [NoMaxOrder F.Duration]` (resp. `Pred`/`NoMin`) per example rather than
  to the shared `variable` block, so the existing examples keep their current instance context.
- [ ] Run `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Semantics.TemporalRules` then the same for
  `BimodalTest.Semantics.TemporalRulesTest`, observing both green.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` (build-requiring; the guarded build above
  satisfies it) and stage `typst/generated/status.typ` with this phase's commit.

**Timing**: 1.0 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: this phase is expected to add roughly 40-50 lines to `TemporalRules.lean`
and 3 examples to the test file, with zero new import lines in either. The implementer confirms
by checking that the scoped build of `FormalSystem.Semantics.TemporalRules` succeeds with no
`import` line added, and reports the actual added line count — if an import turns out to be
needed, that contradicts the report's measured zero-new-imports probe and should be recorded
before proceeding.

**Tier Justification**: the edit is purely additive — two new theorem names, no attribute, no
import, no existing declaration touched — so the cheapest covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Semantics.TemporalRules` plus the one enumerated direct dependent that is also this
phase's second edited file, `BimodalTest.Semantics.TemporalRulesTest`.

**Files to modify**:

- `FormalSystem/Semantics/TemporalRules.lean` - new `DiscreteCollapse` section with
  `next_iff_succ`/`prev_iff_pred`; two bullets added to `## Main Results`
- `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` - three new `example` rows at `Formula`,
  `PlusFormula` and `StarFormula`
- `typst/generated/status.typ` - regenerated `formalsystem-line-count` and companion counts
  (commit-blocking surface; see finding 6)

**Verification**:

- Scoped guarded build of `FormalSystem.Semantics.TemporalRules` is green with no `sorry` and no
  new `import` line in the file.
- Scoped guarded build of `BimodalTest.Semantics.TemporalRulesTest` is green, with all three new
  examples elaborating.
- `grep -nE '^@\[' FormalSystem/Semantics/TemporalRules.lean` returns nothing inside the new
  section — no attribute was attached.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 after the `--fix` run, so the
  pre-commit hook will not refuse this phase's commit.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean --run` is not
  required; axiom measurement for the new lemmas is informational only, since no baseline pins
  them.

---

### Phase 2: Re-body the four SourceLanguage declarations [COMPLETED]

**Goal**: `next_iff_covBy`, `prev_iff_covBy`, `next_iff_succ` and `prev_iff_pred` in
`FormalSystem/SourceLanguage/SentenceTruth.lean` become one-line corollaries of the generic
lemmas, with every statement byte-identical and `sat_iff` re-proving verbatim.

**Tasks**:

- [ ] Add `import FormalSystem.Semantics.TemporalRules` to `SentenceTruth.lean`'s import block.
  This grows its 13-module closure by exactly one module, because `TemporalRules` imports only
  `TruthClauses`, which `SentenceTruth` already reaches through `Semantics.Truth`. The edge is
  lateral (layer 1 to layer 1) under `LANGUAGE_FILE_LAYERS`, so it cannot enter
  `check-metalogic-cycles.sh`'s upward allowlist and that gate's frozen set is untouched.
- [ ] Replace `next_iff_covBy`'s tactic body with the term
  `TemporalRules.next_iff (L := Formula) M τ t PUnit.unit φ`. Leave the `theorem` line, the
  binders and the statement **byte-identical**.
- [ ] Replace `prev_iff_covBy`'s body with `TemporalRules.prev_iff (L := Formula) M τ t
  PUnit.unit φ`, statement unchanged.
- [ ] Replace `next_iff_succ`'s body with `TemporalRules.next_iff_succ (L := Formula) M τ t
  PUnit.unit φ`, keeping the `[SuccOrder F.Duration] [NoMaxOrder F.Duration]` binders and the
  statement unchanged.
- [ ] Replace `prev_iff_pred`'s body with `TemporalRules.prev_iff_pred (L := Formula) M τ t
  PUnit.unit φ`, statement unchanged.
- [ ] Do **not** delete any of the four names and repoint uses. `sat_iff`'s `next`/`prev` cases
  consume `next_iff_covBy`/`prev_iff_covBy` as simp lemmas, and the generic lemma's LHS
  (`TruthEnv.T … (TemporalRules.next φ)`) will not syntactically match
  `TruthAt … (Formula.next …)` in a simp set.
- [ ] Leave `sat_iff` itself untouched — both its `next` and `prev` cases must re-prove verbatim
  against the re-bodied corollaries.
- [ ] Rewrite the `## CovBy is the theorem; succ/pred are corollaries` section's closing
  paragraph (currently lines 56-61) to state the resulting design: the covBy and succ facts are
  proved once generically in `FormalSystem/Semantics/TemporalRules.lean` over the clause layer,
  and the four declarations here are the `Formula` instances of that pair. Keep the
  dense-carrier argument and the dependency-order argument above it, which remain true and are
  the reason the covBy form is the theorem. State the current design only — no "no longer", no
  "previously", no supersession framing (`no-record-versioning-in-deliverables.md`).
- [ ] Rewrite the `## References` bullet currently reading
  "`FormalSystem/Metalogic/DiscreteNonCompactness.lean` `truthAt_next_iff` — the pre-existing
  `succ`-form characterization, duplicated here for the reason above" to point at
  `FormalSystem/Semantics/TemporalRules.lean`'s generic pair as the shared source, and add
  `FormalSystem/Semantics/TemporalRules.lean` as a reference entry.
- [ ] Update the `Sat` docstring's `next`/`prev` bullet only if it asserts something the re-body
  changes; it currently names `next_iff_succ`/`prev_iff_pred` as corollaries on a discrete
  carrier, which stays true, so no edit is expected there.
- [ ] Rewrite `FormalSystem/SourceLanguage/README.md`'s `## next/prev` section (around lines
  79-81) to state that the two readings are the `Formula` instances of the generic clause-layer
  pair, and **remove** the `## Not formalized` table row
  "Consolidation with `../Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff`" entirely
  — remove the row, do not amend it with a status change.
- [ ] Bump `FormalSystem/SourceLanguage/README.md`'s `*Last verified:*` stamp (currently
  `2026-09-27`) to the implementation date. **Mandatory, not hygiene**: that stamp equals its
  directory's last commit date, so the README is currently fresh and is absent from
  `scripts/readme-date-baseline.txt`. Touching `FormalSystem/SourceLanguage/` without the bump
  creates a genuine new `readme-lint.sh` finding.
- [ ] Run `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.SourceLanguage`, which builds `SentenceTruth` plus its only non-root direct
  dependent.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` to refresh
  `FormalSystem/SourceLanguage/README.md`'s generated `SentenceTruth.lean | 253` row, whose line
  count this phase moves.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: this phase is expected to change exactly four proof bodies, add exactly one
import line, and alter no `theorem` signature line in `SentenceTruth.lean`. The implementer
confirms with `git diff -- FormalSystem/SourceLanguage/SentenceTruth.lean` showing no `+`/`-`
pair on any line beginning `theorem `, and with `sat_iff` re-proving with no edit to its own
body.

**Tier Justification**: the four statements stay byte-identical so no downstream signature
changes, but the bodies feed `sat_iff`'s simp set, so the covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.SourceLanguage` — the changed module plus its one enumerated direct dependent
roll-up, the library root being deferred to Phase 5.

**Files to modify**:

- `FormalSystem/SourceLanguage/SentenceTruth.lean` - one import added; four proof bodies replaced
  by one-line terms; module docstring's duplication paragraph and `## References` bullet rewritten
- `FormalSystem/SourceLanguage/README.md` - `## next/prev` section rewritten; `## Not formalized`
  row removed; `*Last verified:*` stamp bumped; generated inventory row refreshed
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.SourceLanguage` is green, with `sat_iff` re-proved and no `sorry`.
- `git diff -- FormalSystem/SourceLanguage/SentenceTruth.lean` shows no change to any `theorem`
  signature line, and all four declaration names still present.
- `bash scripts/check-metalogic-cycles.sh` still PASSes all three assertions with its upward set
  unchanged — the new import is lateral, so Assertion B's frozen-equality set must be untouched.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports the inventory blocks
  current.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `grep -n 'no longer\|previously\|superseded\|used to' FormalSystem/SourceLanguage/SentenceTruth.lean
  FormalSystem/SourceLanguage/README.md` returns nothing in the rewritten prose.

---

### Phase 3: Re-body Metalogic.truthAt_next_iff [COMPLETED]

**Goal**: `FormalSystem/Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff` becomes a
one-line application of the generic succ lemma, with its name, statement and pinned axiom profile
all unchanged.

**Tasks**:

- [ ] Replace `truthAt_next_iff`'s tactic body (currently the `constructor` /
  `rintro` / `rcases` block) with the term
  `TemporalRules.next_iff_succ (L := Formula) M τ t PUnit.unit φ`. Keep the `theorem` line, the
  `[SuccOrder F.Duration] [NoMaxOrder F.Duration]` binders and the statement byte-identical.
- [ ] **Add no import.** `FormalSystem.Semantics.TemporalRules` is already in this module's
  347-module closure via the `FormalSystem.Semantics` roll-up. Confirm by not adding one; if the
  build demands an import, that contradicts the report's measured closure and must be recorded.
- [ ] Do **not** rename or delete `truthAt_next_iff` or `truthAt_next_iterate`. Both are pinned
  by fully qualified name at `scripts/check-module-invariants.sh:2316-2317` against the exact
  strings `'FormalSystem.Metalogic.truthAt_next_iff' depends on axioms: [propext,
  Classical.choice, Quot.sound]` and the same for `truthAt_next_iterate`, matched by string
  equality. Re-bodying is the only available route.
- [ ] Leave `truthAt_next_iterate` untouched. Its body
  (`rw [Function.iterate_succ_apply, ih, Function.iterate_succ_apply']; exact truthAt_next_iff M
  τ _ φ`) must re-prove verbatim against the re-bodied `truthAt_next_iff`, and the asymmetric-
  rewrite comment above it stays accurate.
- [ ] Rewrite the module docstring's `## Note on truthAt_next_iff / truthAt_next_iterate` section
  (around lines 39-48). State the resulting design: these two lemmas are the `Formula` instances
  of the generic clause-layer pair in `FormalSystem/Semantics/TemporalRules.lean`, which serves
  L, L⁺ and L⋆ from one statement. Drop the paragraph naming
  `FormalSystem/Semantics/Truth.lean` as the intended home and the "promotion is the right move
  once a second consumer appears" sentence — `Truth.lean` is `Formula`-specific and would have
  served only L, which is why `TemporalRules.lean` is the home. **Keep** the second paragraph on
  why they are deliberately not `@[simp]`: the `Theorems/DiscreteUnfolding.lean` hazard it names
  is one of the two reasons the generic lemmas carry no attribute either, and it is still live.
  State the current design only, with no supersession framing.
- [ ] Update `FormalSystem/Metalogic.lean`'s `DiscreteNonCompactness.lean` bullet phrase
  "the first semantic characterisation of `Formula.next`" (around line 252) — that claim stops
  being true once the generic lemma exists upstream. Point it at the generic pair instead.
- [ ] Run `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Metalogic.DiscreteNonCompactness`.
- [ ] Run `bash scripts/check-module-invariants.sh` and read the C14 block, confirming both
  pinned axiom lines still match.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` to refresh
  `FormalSystem/Metalogic/README.md`'s `DiscreteNonCompactness.lean | 322` row and
  `FormalSystem/README.md`'s `Metalogic.lean | 307` row, both of which this phase moves.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: this phase is expected to change exactly one proof body, add zero imports,
and leave both pinned `#print axioms` strings byte-identical. The implementer confirms by
reading `check-module-invariants.sh`'s C14 output directly and comparing against lines 2316-2317
of that script, not by assuming the report's measurement still holds.

**Tier Justification**: the statement is byte-identical and the one consumer
(`truthAt_next_iterate`) sits in the same module, so the covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Metalogic.DiscreteNonCompactness` plus the C14 block of
`bash scripts/check-module-invariants.sh`, which is the gate of record for the axiom pin no
build can observe.

**Files to modify**:

- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` - `truthAt_next_iff` body replaced by a
  one-line term; `## Note on …` docstring section rewritten
- `FormalSystem/Metalogic.lean` - the `DiscreteNonCompactness.lean` bullet's "first semantic
  characterisation" phrase repointed
- `FormalSystem/Metalogic/README.md` - generated `DiscreteNonCompactness.lean` inventory row
  refreshed (stamp left alone; see Phase 4)
- `FormalSystem/README.md` - generated `Metalogic.lean` inventory row refreshed (stamp left
  alone)
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Metalogic.DiscreteNonCompactness` is green, with `truthAt_next_iterate` re-proved
  and no `sorry`.
- `bash scripts/check-module-invariants.sh` C14 reports both
  `FormalSystem.Metalogic.truthAt_next_iff` and
  `FormalSystem.Metalogic.truthAt_next_iterate` at `[propext, Classical.choice, Quot.sound]`,
  matching `scripts/check-module-invariants.sh:2316-2317` exactly.
- Both declaration names are still present and no import line was added.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports the inventory blocks
  current.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 4: Documentation sweep on the remaining surfaces [COMPLETED]

**Goal**: every remaining surface that records the duplication as unresolved, or names a home the
generic lemma supersedes, states the resulting design instead — and the one other fresh,
ungrandfathered README stamp is bumped.

**Tasks**:

- [ ] `FormalSystem/SourceLanguage.lean` — update the `## Semantic modules` bullet that names
  `next_iff_covBy`, `prev_iff_covBy`, `next_iff_succ`, `prev_iff_pred` (around line 38) to say
  they are the `Formula` instances of the generic clause-layer pair.
- [ ] `FormalSystem/NomicLanguage/NomicTruth.lean` — repoint the `## References` bullet and the
  `next_iff_succ` docstring, both of which currently name
  `Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff` as the transcription source, at
  `FormalSystem/Semantics/TemporalRules.lean`'s generic pair instead. **Keep** the recorded
  reason the clause layer is unusable here — this module has no `TruthEnv` instance and evaluates
  `NomicTruthAt` over `NomicModel`/`NomicFrame`, a different point shape — so the transcription
  stays and the reader can still see why.
- [ ] `FormalSystem/Metalogic/AuxiliaryAtoms.lean` — update `plusTruthAt_next_iff_succ`'s
  docstring promotion note, whose named eventual home (`PlusTruth.lean`) is superseded by the
  generic lemma being available. Say the generic pair in
  `FormalSystem/Semantics/TemporalRules.lean` serves this statement at `PlusFormula` and that
  re-bodying it is available follow-up work. **Do not touch the body** — that is out of this
  task's declared scope (see Non-Goals).
- [ ] `FormalSystem/Semantics/README.md` — update the `TemporalRules.lean` row's description
  (line 50) to include the discrete collapse pair alongside the order-cover, persistence and
  witness-composition content it already names.
- [ ] Bump `FormalSystem/NomicLanguage/README.md`'s `*Last verified:*` stamp (currently
  `2026-10-15`) to the implementation date. **Mandatory, same mechanism as Phase 2's bump**: that
  stamp equals its directory's last commit date and the path is absent from
  `scripts/readme-date-baseline.txt`, so touching `FormalSystem/NomicLanguage/` without the bump
  creates a genuine new `readme-lint.sh` finding.
- [ ] **Do not bump** `FormalSystem/README.md` (`2026-10-02`),
  `FormalSystem/Semantics/README.md` (`2026-11-06`) or `FormalSystem/Metalogic/README.md`
  (`2026-10-02`). All three are grandfathered `stale` rows in
  `scripts/readme-date-baseline.txt`, so touching their directories creates no new finding.
  Refreshing a stamp **permanently** un-grandfathers that row, after which the script reports it
  as a `PRUNE:` candidate — a one-way change with no gate benefit here.
- [ ] Across every rewritten passage in this phase, state the current design only. No "no
  longer", "previously", "formerly", "superseded", or supersession table
  (`no-record-versioning-in-deliverables.md`).
- [ ] Run `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.SourceLanguage` and the same for `FormalSystem.NomicLanguage.NomicTruth` and
  `FormalSystem.Metalogic.AuxiliaryAtoms`, confirming no docstring edit crossed out of its
  comment delimiters.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` to refresh the generated
  rows for `SourceLanguage.lean | 79` (in `FormalSystem/README.md`),
  `NomicTruth.lean | 298` (in `FormalSystem/NomicLanguage/README.md`) and
  `AuxiliaryAtoms.lean | 903` (in `FormalSystem/Metalogic/README.md`), all of which this phase's
  docstring edits move.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 1.0 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: five documentation surfaces are expected to need prose edits in this phase
(`SourceLanguage.lean`, `NomicTruth.lean`, `AuxiliaryAtoms.lean`, `Semantics/README.md`, plus the
`NomicLanguage/README.md` stamp), and no proof body or signature anywhere. The implementer
confirms the no-code claim with
`git diff -U0 -- '*.lean' | grep -E '^\+' | grep -vE '^\+\+\+' | grep -vE '^\+\s*(--|/-|\*|-\)|$)'`
returning nothing, and re-greps for `truthAt_next_iff` and `Semantics/Truth.lean` across
`FormalSystem/**` to confirm no sixth surface was missed — if one is found, record it and extend
this phase rather than deferring it.

**Tier Justification**: every hunk in this phase lies inside a module docstring, a doc comment or
a README table cell, with no declaration, signature or proof body touched, so the cheapest
covering check is `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` of the
three edited Lean modules individually, which is exactly what a malformed docstring delimiter
would break.

**Files to modify**:

- `FormalSystem/SourceLanguage.lean` - `## Semantic modules` bullet updated
- `FormalSystem/NomicLanguage/NomicTruth.lean` - `## References` bullet and `next_iff_succ`
  docstring repointed at the generic pair; the unusable-clause-layer reason kept
- `FormalSystem/Metalogic/AuxiliaryAtoms.lean` - `plusTruthAt_next_iff_succ` docstring promotion
  note updated; body untouched
- `FormalSystem/Semantics/README.md` - `TemporalRules.lean` row description updated (stamp left
  alone: grandfathered)
- `FormalSystem/NomicLanguage/README.md` - `*Last verified:*` stamp bumped (mandatory); generated
  `NomicTruth.lean` inventory row refreshed
- `FormalSystem/README.md` - generated `SourceLanguage.lean` inventory row refreshed (stamp left
  alone: grandfathered)
- `FormalSystem/Metalogic/README.md` - generated `AuxiliaryAtoms.lean` inventory row refreshed
  (stamp left alone: grandfathered)
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)

**Verification**:

- Scoped guarded builds of `FormalSystem.SourceLanguage`,
  `FormalSystem.NomicLanguage.NomicTruth` and `FormalSystem.Metalogic.AuxiliaryAtoms` are all
  green with no `sorry`.
- The no-code-change diff check in the Scope Hypothesis above returns nothing.
- `grep -rn 'no longer\|previously\|formerly\|superseded' FormalSystem/SourceLanguage.lean
  FormalSystem/NomicLanguage/NomicTruth.lean FormalSystem/Metalogic/AuxiliaryAtoms.lean
  FormalSystem/Semantics/README.md` returns nothing in the rewritten passages.
- `FormalSystem/NomicLanguage/README.md`'s stamp is the implementation date;
  `FormalSystem/README.md`, `FormalSystem/Semantics/README.md` and
  `FormalSystem/Metalogic/README.md` stamps are byte-unchanged.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports the inventory blocks
  current.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 5: Full-tree reconciliation and gate battery [COMPLETED]

**Goal**: the whole library builds, every generated surface is current, and every gate of record
is either green or shown to be red for reasons this task did not cause.

**Tasks**:

- [ ] **Before any further edit**, capture the `readme-lint.sh` baseline finding set:
  `bash scripts/readme-lint.sh > /tmp/readme-lint-after.txt 2>&1 || true`, and capture the
  pre-task set the same way at the task's base commit for comparison. The pre-existing seven new
  stale findings the research dispatch measured are `Automation/ProofMode`,
  `Metalogic/Conservativity/Star`, `Metalogic/Expressiveness`, `Metalogic/WeakCanonical`,
  `Tactic`, `Theorems/ProofMode` and `Theorems/ProofMode/TemporalComposition`. Treat that list as
  the hypothesis to confirm against the live base-commit run, not as a fact — see the Scope
  Hypothesis below.
- [ ] Run the unscoped guarded build:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. This is the first
  run that observes `FormalSystem.lean` and `Tests/` in full, both of which import the edited
  modules.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` once more against the
  settled tree, then `bash scripts/check-module-invariants.sh --emit-inventory --check` and
  confirm `PASS INV`. Any block still stale here is attributable to this task alone, since the
  check PASSed at the task's base commit.
- [ ] Run `bash scripts/check-module-invariants.sh` in full and confirm C14 still pins both
  `truthAt_next_iff` and `truthAt_next_iterate` at `[propext, Classical.choice, Quot.sound]`,
  and that no other check regressed.
- [ ] Run `bash scripts/check-metalogic-cycles.sh` and confirm all three assertions PASS with the
  upward allowlist set unchanged. Read the count from the script's own header comment rather than
  copying a number from any other document.
- [ ] Run `bash scripts/typst-sync-check.sh` in full (not just `--counts-only`) and confirm all
  four checks pass — Check 1's name resolution matters here because the rewritten docstrings
  changed which declaration names appear in Lean source, and `typst/**` backticked spans resolve
  against a literal scan of that source.
- [ ] Run `bash scripts/readme-lint.sh` and compare the new-stale finding SET against the
  base-commit set captured above. **The acceptance criterion is set equality, not exit 0** — the
  script exits 1 at the task's base commit for reasons in seven directories this task never
  touches. A finding naming `FormalSystem/SourceLanguage/` or `FormalSystem/NomicLanguage/` means
  a Phase 2 or Phase 4 stamp bump was missed and must be fixed here.
- [ ] Measure the axiom profile of the four re-bodied `SourceLanguage` declarations and record
  it. `next_iff_covBy`/`prev_iff_covBy` are expected to drop `Quot.sound`, moving from
  `[propext, Quot.sound]` to `[propext]`; `next_iff_succ`/`prev_iff_pred` and `sat_iff` are
  expected unchanged. No pinned baseline covers these names, so an improvement is a recorded
  result, not a gate.
- [ ] Confirm zero `sorry` across the touched modules and that no new axiom was introduced
  anywhere.
- [ ] Record `Metalogic/AuxiliaryAtoms.lean`'s `plusTruthAt_next_iff_succ` as follow-up work: the
  same generic lemma serves it at `PlusFormula` and would retire the third copy of the succ
  argument, but it was deliberately out of this task's declared scope.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` if the unscoped build moved any count the
  scoped builds did not, and stage `typst/generated/status.typ`.

**Timing**: 1.25 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: the `readme-lint.sh` new-stale finding set at the task's base commit is
expected to be exactly the seven directories enumerated above, and the inventory `--check` is
expected to have PASSed there. The implementer confirms both by running each command at the base
commit (or against a captured baseline) *before* editing, rather than inheriting the research
dispatch's measurement — a baseline is a moving quantity and a sibling task may have moved it
since.

**Files to modify**:

- `FormalSystem/SourceLanguage/README.md` - generated inventory block reconciled against the
  settled tree, if the final pass moves it
- `FormalSystem/Metalogic/README.md` - same
- `FormalSystem/README.md` - same
- `FormalSystem/NomicLanguage/README.md` - same
- `typst/generated/status.typ` - final reconciliation of the generated counts

**Verification**:

- Unscoped `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` is green with
  zero `sorry`.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports
  `PASS INV every generated inventory block is current, every hand-maintained one is exhaustive`.
- `bash scripts/check-module-invariants.sh` C14 matches `scripts/check-module-invariants.sh`
  lines 2316-2317 exactly for both pinned names.
- `bash scripts/check-metalogic-cycles.sh` PASSes all three assertions, upward set unchanged.
- `bash scripts/typst-sync-check.sh` passes all four checks.
- `bash scripts/readme-lint.sh` is invoked through its sanctioned entry point and its exit status
  is read: it must exit `1` (the baseline's own red), never `2` or any usage/crash status, and its
  new-stale finding set must equal the base-commit set, with no finding naming
  `FormalSystem/SourceLanguage/` or `FormalSystem/NomicLanguage/`. Set equality is the acceptance
  criterion here *because* exit 0 is unreachable at this baseline; the exit status is still read,
  to distinguish the expected red from a broken invocation.
- Scoped touched-path check for this dispatch's own in-dispatch obligation:
  `bash .claude/scripts/verify-touched.sh` is green over this task's touched paths. **The
  complete gate set is deferred to the orchestration close** (`/orchestrate`'s once-per-invocation
  batch gate stage), not run independently here. On a standalone, non-orchestrated run with no
  orchestration close to defer to, run `bash .claude/scripts/verify-deploy.sh` directly instead.

## Testing & Validation

- [ ] Three new `example` rows in `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` elaborate
  at `Formula`, `PlusFormula` and `StarFormula`, with the `StarFormula` row threading the file's
  own `regs` so the non-`PUnit` `Env` case is exercised.
- [ ] `SourceLanguage.sat_iff` re-proves verbatim, all 18 cases, with no edit to its own body.
- [ ] `Metalogic.truthAt_next_iterate` re-proves verbatim against the re-bodied
  `truthAt_next_iff`.
- [ ] All five base-language declaration names still resolve, with statements byte-identical to
  their pre-task form.
- [ ] No attribute on either new generic lemma.
- [ ] Zero `sorry` and no new axiom anywhere in the touched modules.
- [ ] Unscoped `lake build` green.

## Artifacts & Outputs

- `FormalSystem/Semantics/TemporalRules.lean` — new `DiscreteCollapse` section with
  `next_iff_succ`/`prev_iff_pred`
- `FormalSystem/SourceLanguage/SentenceTruth.lean` — four one-line corollaries, one new import,
  rewritten duplication prose
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` — one-line `truthAt_next_iff`, rewritten
  `## Note on …` section
- `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` — three new test rows
- Six README/aggregator documentation surfaces updated, two `*Last verified:*` stamps bumped
- `typst/generated/status.typ` and the generated README inventory blocks regenerated
- A recorded follow-up for `Metalogic/AuxiliaryAtoms.lean`'s `plusTruthAt_next_iff_succ`

## Rollback/Contingency

Every phase is additive or body-only, with no declaration renamed or removed, so a failed phase
reverts to a working tree by restoring the files that phase declared. Before any phase whose
build goes unexpectedly red, take a durable checkpoint with
`bash .claude/scripts/git-snapshot.sh 984 --no-revert` — the `--no-revert` form, which is durable
without reverting the working tree; the default reverting form belongs only to a genuine rollback.

If the generic `next_iff_succ`/`prev_iff_pred` pair unexpectedly fails to compile without a new
import, Phase 1 is the only phase that must change: state the lemmas with whatever import the
build demands, record the contradiction with the report's measured zero-new-imports probe, and
re-check that the added import does not create an upward edge under `LANGUAGE_FILE_LAYERS` before
proceeding.

If C14's axiom pin moves for `truthAt_next_iff` or `truthAt_next_iterate` after Phase 3's
re-body, mark Phase 3 `[BLOCKED]` rather than editing the pinned baseline in
`scripts/check-module-invariants.sh`. The baseline is the gate of record; a proof route that
perturbs it is the wrong route, and the original tactic body remains available in git history.
