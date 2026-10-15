# Implementation Plan: Task #793

- **Task**: 793 - Prove lem:after-negation and the cut cor:after-negation-stable for the event operators of def:event-operators
- **Status**: [IMPLEMENTING]
- **Effort**: 6.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/793_after_operator_negation_equivalence/reports/01_after-operator-negation-equivalence.md
- **Artifacts**: plans/01_after-operator-negation-equivalence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`def:event-operators` defines `After`, `Release`, `Before` in BL; the tree has `Formula.release`
but no `after`/`before`, and no next-time uniqueness lemma at the semantic layer. The plan adds
the two missing syntactic operators, proves the mathematics **once** in the language-generic
clause tier of `FormalSystem/Semantics/TruthClauses.lean` (next-time uniqueness, then the
pointwise negation equivalence under the `After(φ,⊤)` guard), and then instantiates that one
result twice: as `after_negation_valid` over every task frame at L, and as both readings of
`cor:after-negation-stable` at L⁺. Definition of done: the five pinned theorems compile, `lake
build` is green across all four libraries with no new `sorry` and no new axiom, and the paper's
`% PORT:` marker under `lem:after-negation` is replaced by a `\leanproof` line.

**The dispatch's open question — answer.** `cor:after-negation-stable` is stated **natively in
L⁺ in this task**, not through the embedding and not recorded as a follow-up. The embedding
cannot carry it: `plusValid_ofFormula_iff` transports only formulas in the range of `ofFormula`,
`⊡`/`⟐` are provably outside that range (`ofFormula_ne_stab`), and the paper's corollary is
schematic over arbitrary L⁺ `φ`, `ψ` which may themselves contain `⊡`. Proving the pointwise
biconditional in the generic tier instead makes the L⁺ statement a transcription rather than a
second proof.

### Research Integration

- Every declaration in this plan was compiled end-to-end as a standalone probe during research
  (`probe_generic.lean`, run with `lake env lean` against the built tree); the three top results
  reported `[propext, Classical.choice, Quot.sound]` only. This plan transcribes that probe into
  the tree's module layout; it is not a fresh derivation.
- **`Formula.release`'s arguments are swapped relative to the paper's `Release`.**
  `Formula.release a b = ¬(¬b U ¬a)` = paper `Release(b,a)`. So the paper's
  `Before(φ,ψ) := Release(ψ,¬φ) ∧ future φ` ports as
  `(Formula.release φ.neg ψ).and (Formula.someFuture φ)`, with the swap pinned by `rfl` rather
  than described in a comment.
- **No `reflect_time_*` entry is needed or wanted** — this answers the dispatch's explicit check.
  The attribute block in `FormalSystem/Syntax/Formula.lean` lists exactly eleven lemmas and
  `release`, `trigger`, `weakUntil`, `weakSince` have no entry; `after`/`before` have no past
  dual anywhere in the paper, so an entry would require inventing one.
- **No `complexity` arm and no dataset-tooling change.** `after φ ψ` already falls under the
  existing `strongRelease` complexity arm (measured `4` at atoms, `12` for `before`) and is
  classified `none` by both `Formula.matchBinaryDerived` and `Formula.foldedBinaryTag`.
  Registering the operators with `BimodalTools/FormulaEnumerator.lean` would break the three
  exact counts pinned in `Tests/BimodalToolsTest/EnumeratorCountsTest.lean` (`7852`, `75914`,
  `45111`), so the enumerator is left alone — this plan does not update that tooling, therefore
  it does not register with it.
- **Placement avoids `FormalSystem/Semantics.lean`**, which is in a concurrent sibling's declared
  `file_scope`. The L-level validity goes into a new
  `FormalSystem/Metalogic/SoundnessLemmas/EventOperators.lean` on the `CoValidity.lean`
  precedent (the same shape of object: a semantic validity of a derived operator, not a
  soundness case), and the L⁺ corollaries append to `FormalSystem/PlusLanguage/PlusValidity.lean`,
  which is already in the `PlusLanguage` aggregator.
- Caller traps measured during research and carried into the phase tasks: `PlusTruth.stab_iff`
  and `PlusTruth.dstab_iff` take `M τ t φ` all explicit, so write
  `(PlusTruth.dstab_iff M τ t _)`; `rw [PlusTruth.and_iff]` does not fire on a
  `PlusFormula.iff` goal until `PlusFormula.iff` is unfolded; `isNextTime_unique` trips the
  `unusedSectionVars` linter unless prefixed with
  `omit [BotClause L] [ImpClause L] [UntlClause L] in`.
- `Formula` has no `iff`, so the L-level biconditional uses the house encoding
  `(A.imp B).and (B.imp A)`. `PlusFormula.iff` does exist and is used at L⁺.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no `roadmap_flag` was set, so no roadmap
phases are added and no roadmap item is claimed.

## Goals & Non-Goals

**Goals**:
- `isNextTime_unique`, `after_negation`, `after_negation_valid`, `after_negation_stable_dstab`,
  `after_negation_stable_stab`
- Add `Formula.after` and `Formula.before` beside `Formula.release`, each with the paper's
  equation pinned by an `example … := rfl` against its literal primitive expansion
- Add the generic next-time predicate and the two intermediate clause lemmas the uniqueness
  argument needs (`IsNextTime`, `after_top_iff`, `after_iff_of_isNextTime`) in the
  language-generic tier, so the mathematics exists once and is instantiated twice
- Mirror `after` into `PlusFormula` and extend the `ofFormula` `rfl` pin block
- Clear the `% PORT:` marker under `lem:after-negation` and close the proof with `\leanproof`
- Record the derived-binary argument-order mapping in the architecture decision record that
  already owns the `untl`/`snce` order question

**Non-Goals**:
- `PlusFormula.release` / `PlusFormula.before` — the corollary does not mention `Before`
- Any `reflect_time_*` lemma, `complexity` arm, `formula_unfold` lemma, `EnrichedFormula`
  constructor, or `FormulaEnumerator` registration for the new operators
- Adding `Formula.iff` (a repo-wide convention change, not this task's business)
- Extending the "Temporal Operators" table in `docs/reference/operators.md`, which today omits
  all six existing binary derived operators; adding two rows to it would make it less coherent,
  not more
- Any edit to `FormalSystem/Semantics.lean`, `docs/reference/paper-definitions-of-record.md`, or
  any other file in a concurrent sibling's declared `file_scope` *(deviation: altered — `docs/reference/paper-definitions-of-record.md` WAS edited. C15 in check-module-invariants.sh requires a manifest or KNOWN-ANCHORS row for every `def:`/`lem:`/`cor:` anchor cited under FormalSystem/ Tests/ BimodalTools/ typst/ docs/ README.md, and this plan's own Phase 7 gate list requires C15 to exit 0; three rows added (def:event-operators and lem:after-negation LIVE-UNPINNED, cor:after-negation-stable DANGLING on the thm:nomic-primitive cut-material precedent). The Non-Goal's stated rationale was concurrent-sibling territory, and every sibling in the batch had completed and committed before this edit.)*
- A proof-theoretic (derivation-level) counterpart of either result; both deliverables are
  semantic validities

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer reads `Formula.release`'s docstring literally and writes `Formula.release ψ φ.neg` for the paper's `Release(ψ,¬φ)`, silently defining the wrong `before` | H | M | Phase 1's `rfl` pin against the paper's literal primitive expansion fails to elaborate if the arguments are swapped — it is the test, not a comment; Phase 7 records the mapping in the decision record |
| Territory collision: concurrent siblings hold `FormalSystem/Semantics.lean` and friends, and two siblings declare no `file_scope` at all | M | M | No phase touches any file in the declared sibling scope; re-read each target immediately before editing, stage explicit file lists only, never a directory or glob add, and treat a build failure outside this task's own files as possibly a sibling's in-flight edit |
| Additions to `Semantics/TruthClauses.lean` trigger a wide rebuild (imported by both language families) | M | H | Additions are new `abbrev`/`def`/`theorem`s with no attribute tags, so nothing existing re-elaborates differently; no file in the tree opens the `TruthClauses` namespace (grep at planning), so the new `abbrev after` cannot shadow a bare name anywhere; the one unavoidable whole-tree build is deferred to Phase 7 |
| `unusedSectionVars` linter fails the build on `isNextTime_unique` | L | H | Observed during research; prefix with `omit [BotClause L] [ImpClause L] [UntlClause L] in` |
| New module misses a repo module gate (copyright header, module docstring, generated README inventory row) | M | M | Phase 3 writes the header and docstring on the `CoValidity.lean` pattern and regenerates the README table with `bash scripts/check-module-invariants.sh --emit-inventory`; Phase 7 re-runs the gates |
| Lean build wall-clock exceeds the foreground tool cap, livelocking on a killed module | H | H | Every `lake` invocation routes through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- …` detached via `Bash(run_in_background: true)`, with the guard's exit captured un-piped — never a bare foreground `lake build` |
| `lean-challenge-snapshot.sh --check` reports drift because the pinned statements below spell `After(φ,ψ)` as its primitive expansion while the implementation spells it `Formula.after φ ψ` | L | H | Expected and advisory only: the two are definitionally equal by `rfl`. A drift finding on that spelling alone is not grounds to fail a phase; a drift finding on the *logical content* of any pinned statement is, and is escalated per `plan-compliance.md` rather than quietly re-pinned |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4, 6 | 1, 2 |
| 3 | 5 | 2, 4 |
| 4 | 7 | 3, 5, 6 |

Phases within the same wave can execute in parallel.

Build discipline for every phase: route each `lake` invocation through
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <Module>` detached via
`Bash(run_in_background: true)`, capturing the guard's exit un-piped or reading its own `result`
subcommand; never a bare foreground `lake build`. Commit mode is the default `per-substep`
everywhere — each phase is independently green, so each closes with its own commit.

---

### Phase 1: `Formula.after` and `Formula.before` [COMPLETED]

**Goal**: Add the two missing event operators beside `Formula.release` in
`FormalSystem/Syntax/Formula.lean`, with the paper's equations machine-checked.

**Tasks**:
- [ ] Add `def after (φ ψ : Formula) : Formula := Formula.untl φ.neg (φ.and ψ)` immediately after
      `release`, with a docstring giving the paper's `After(φ,ψ) := ¬φ U (φ ∧ ψ)` and the closing
      remark that `After(φ,⊤) = ¬φ U φ` says there is a next `φ`-time
- [ ] Add `def before (φ ψ : Formula) : Formula := (Formula.release φ.neg ψ).and (Formula.someFuture φ)`,
      with a docstring recording that `Formula.release` takes the paper's `Release` arguments
      **swapped**, so the paper's `Release(ψ,¬φ)` is `Formula.release φ.neg ψ`
- [ ] Pin both equations with `example`s that fail to elaborate if an argument order is wrong:
      `example (φ ψ : Formula) : after φ ψ = Formula.untl φ.neg (φ.and ψ) := rfl` and
      `example (φ ψ : Formula) : before φ ψ = ((Formula.untl ψ.neg φ.neg.neg).neg).and (Formula.someFuture φ) := rfl`
- [ ] Leave the double negation `φ.neg.neg` in the `before` pin unsimplified — it is exactly what
      substituting `¬φ` into `Release` produces
- [ ] Add **no** `reflect_time_*` lemma, **no** `complexity` arm, and **no** entry to the
      `reflect_time_norm` attribute block
- [ ] Confirm the new names break nothing downstream: grep `FormalSystem/`, `Tests/`,
      `BimodalTools/` for a bare `after`/`before` used under an `open Formula`

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts that **zero** derived-operator table entries are needed
(no `reflect_time_*`, no `complexity` arm). Confirm at implementation time by re-reading the
`reflect_time_norm` attribute block and checking that `release`/`trigger`/`weakUntil`/`weakSince`
still have no entry, and by `#eval`-ing `(Formula.after p q).complexity` and
`(Formula.before p q).complexity` to the values Phase 6 pins. If either check fails, stop and
escalate rather than inventing a past dual for `after`.

**Tier Justification**: the edit is additive to one module and changes no existing signature, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Syntax.Formula`
plus the in-phase `rfl` pins cover it, and the bare-name grep above rules out the one downstream
break a single-module build could miss.

**Files to modify**:
- `FormalSystem/Syntax/Formula.lean` - add `after` and `before` after `release`, each with a docstring and an `rfl` pin

**Verification**:
- Guarded scoped build of `FormalSystem.Syntax.Formula` exits 0
- Both `rfl` pins elaborate
- Bare-name grep returns no shadowing use

---

### Phase 2: Generic next-time tier in `TruthClauses.lean` [COMPLETED]

**Goal**: Prove the mathematics once, language-generically: next-`φ`-time uniqueness and the
pointwise negation equivalence under the `After(φ,⊤)` guard, over any `L` with the Boolean and
`untl` clauses.

**Tasks**:
- [ ] Open a new section in the generic derived-operator tier of
      `FormalSystem/Semantics/TruthClauses.lean`, over
      `{L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L] {F : TaskFrame}`,
      placed with the other derived tiers (after the `Future` section)
- [ ] `abbrev after (φ ψ : L) : L := UntlClause.untl (neg φ) (and φ ψ)` with a docstring naming
      `def:event-operators`
- [ ] `def IsNextTime (M τ t e φ) (z : F.Duration) : Prop` — `t < z`, `φ` true at `z`, and `φ`
      false at every `r` with `t < r < z`; this is the `untl` witness plus its open-interval
      guard, named because the uniqueness and transfer lemmas both quantify over it
- [ ] `isNextTime_unique`: two next-`φ`-times coincide. Proof: `rcases lt_trichotomy z z'` and
      `absurd` in each strict branch — the earlier would lie strictly between `t` and the later.
      Prefix the declaration with `omit [BotClause L] [ImpClause L] [UntlClause L] in` to clear
      the `unusedSectionVars` linter. Consumes no frame constraint; linearity of `F.Duration`
      is the only order-theoretic input
- [ ] `after_top_iff`: `after φ top` holds at `(τ,t)` iff some `z` is a next `φ`-time. Proof:
      `rw [after, UntlClause.untl_clause]` then `and_iff`/`neg_iff`, with `top_true` discharging
      the `⊤` conjunct on the `←` direction
- [ ] `after_iff_of_isNextTime`: given `IsNextTime … z`, `after φ χ` holds at `(τ,t)` iff `χ`
      holds at `z`. Proof: `rw` through the clause, then `isNextTime_unique` plus `▸` to identify
      the witness with `z`
- [ ] `after_negation`: under the guard `after φ top`, `¬ T (after φ ψ) ↔ T (after φ (neg ψ))`.
      Proof: `rw [neg_iff, after_iff_of_isNextTime, after_iff_of_isNextTime, neg_iff]` against
      the `z` obtained from `after_top_iff`
- [ ] Touch no existing declaration in the file; tag nothing with an attribute

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **six** new declarations — one `abbrev` (`after`), one
`def` (`IsNextTime`), and four theorems (`isNextTime_unique`, `after_top_iff`,
`after_iff_of_isNextTime`, `after_negation`) — and **zero** modifications to existing
declarations. Confirm at implementation time with `git diff --stat` on the file showing additions
only, and by `lean_verify` on each new theorem's fully qualified name.

**Tier Justification**: additive new declarations in one module with no attribute tag, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.TruthClauses`;
no file in the tree opens the `TruthClauses` namespace (verified by grep at planning), so the new
`abbrev after` cannot shadow a bare name in any dependent.

**Files to modify**:
- `FormalSystem/Semantics/TruthClauses.lean` - new generic section: `after`, `IsNextTime`, `isNextTime_unique`, `after_top_iff`, `after_iff_of_isNextTime`, `after_negation`

**Verification**:
- Guarded scoped build of `FormalSystem.Semantics.TruthClauses` exits 0
- `lean_verify` on each new theorem reports no `sorryAx` and no axiom beyond
  `[propext, Classical.choice, Quot.sound]`
- No linter warning on `isNextTime_unique`

---

### Phase 3: `after_negation_valid` at L [COMPLETED]

**Goal**: Instantiate the generic result at `Formula` as a validity over every task frame, in a
new `SoundnessLemmas` leaf module on the `CoValidity.lean` precedent.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/SoundnessLemmas/EventOperators.lean` with the repo copyright
      header and a module docstring on `CoValidity.lean`'s pattern: what `lem:after-negation`
      says, why it lives here (a semantic validity of a *derived* operator, not a soundness
      case — nothing in the soundness induction consumes it), and its position in the layering
- [ ] `import FormalSystem.Semantics.Validity` only; add no import of `FormalSystem/Semantics.lean`
- [ ] State `after_negation_valid (φ ψ : Formula)` as
      `Valid ((Formula.after φ Formula.top).imp ((((Formula.after φ ψ).neg).imp (Formula.after φ ψ.neg)).and ((Formula.after φ ψ.neg).imp ((Formula.after φ ψ).neg))))`,
      using the house biconditional encoding `(A.imp B).and (B.imp A)` since `Formula` has no
      `iff`
- [ ] Prove by `Valid.of_forall`, then `Truth.imp_iff` / `Truth.and_iff` around
      `TruthClauses.after_negation (L := Formula) M τ t PUnit.unit φ ψ`
- [ ] Add the one import line to `FormalSystem/Metalogic/SoundnessLemmas.lean`, in alphabetical
      position, and the matching bullet to that file's `## Contents` list
- [ ] Regenerate the generated inventory table in
      `FormalSystem/Metalogic/SoundnessLemmas/README.md` with
      `bash scripts/check-module-invariants.sh --emit-inventory`, then write the hand-owned
      description column for the new row (the script preserves it)

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: interface

**Tier Justification**: the new module enters the build graph through the `SoundnessLemmas`
aggregator, so the covering check is the guarded scoped build of
`FormalSystem.Metalogic.SoundnessLemmas` together with its one direct dependent
`FormalSystem.Metalogic.Soundness`, which no single-module build would reach.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/EventOperators.lean` - new module carrying `after_negation_valid`
- `FormalSystem/Metalogic/SoundnessLemmas.lean` - one import line and one `## Contents` bullet
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` - regenerated inventory row plus its description

**Verification**:
- Guarded scoped builds of `FormalSystem.Metalogic.SoundnessLemmas` and
  `FormalSystem.Metalogic.Soundness` exit 0
- `lean_verify FormalSystem.Metalogic.SoundnessLemmas.after_negation_valid` reports no `sorryAx`
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- `bash scripts/check-copyright-headers.sh` exits 0

---

### Phase 4: `PlusFormula.after` mirror [COMPLETED]

**Goal**: Mirror `after` into L⁺ with `Formula.after`'s right-hand side verbatim, and extend the
`ofFormula` `rfl` pin block so the commutation is machine-checked.

**Tasks**:
- [ ] Add `def after (φ ψ : PlusFormula) : PlusFormula := PlusFormula.untl φ.neg (φ.and ψ)` to
      `FormalSystem/PlusLanguage/Formula.lean`, placed with the other mirrored derived operators,
      with a docstring stating that it mirrors `Formula.after`
- [ ] Extend the `### `rfl` pins` block with
      `example (φ ψ : Formula) : ofFormula (Formula.after φ ψ) = PlusFormula.after (ofFormula φ) (ofFormula ψ) := rfl`
- [ ] Do **not** add `PlusFormula.release` or `PlusFormula.before` — out of scope per Non-Goals
- [ ] Update the module docstring's operator inventory if it enumerates the mirrored derived
      operators by name

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: additive def plus one `example` in a single module, changing no existing
signature, fully covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.Formula`
(the `rfl` pin is itself the correctness check and fails at elaboration if the mirror diverges).

**Files to modify**:
- `FormalSystem/PlusLanguage/Formula.lean` - `PlusFormula.after` and one `rfl` pin

**Verification**:
- Guarded scoped build of `FormalSystem.PlusLanguage.Formula` exits 0
- The new `rfl` pin elaborates

---

### Phase 5: `cor:after-negation-stable`, both readings, at L⁺ [COMPLETED]

**Goal**: State and prove the cut corollary natively in L⁺ in both its existential (`⟐`) and
universal (`⊡`) readings.

**Tasks**:
- [ ] Append to `FormalSystem/PlusLanguage/PlusValidity.lean` a short section whose docstring
      records that `cor:after-negation-stable` is CUT from the live paper and kept verbatim in the
      cut-material appendix, i.e. a specification implemented here, not a theorem cited from the
      published text, and that the embedding cannot carry it (`⊡`/`⟐` lie outside `ofFormula`'s
      range by `ofFormula_ne_stab`, and the schema ranges over arbitrary L⁺ formulas)
- [ ] `after_negation_stable_dstab (φ ψ : PlusFormula)`:
      `PlusValid ((PlusFormula.after φ PlusFormula.top).stab.imp (PlusFormula.iff (PlusFormula.dstab (PlusFormula.after φ ψ).neg) (PlusFormula.dstab (PlusFormula.after φ ψ.neg))))`
- [ ] `after_negation_stable_stab (φ ψ : PlusFormula)`: the same with `.stab` in place of both
      `dstab` occurrences
- [ ] Prove both by `PlusValid.of_forall`, deriving the per-`σ` biconditional
      `hbi σ hσ := TruthClauses.after_negation (L := PlusFormula) M σ t PUnit.unit φ ψ (hg σ hσ)`
      and then quantifying over `⟨τ⟩_t` — which is the plain state equation
      `τ.state t = σ.state t`
- [ ] Unfold the biconditional with
      `rw [PlusFormula.iff, PlusTruth.and_iff, PlusTruth.imp_iff, PlusTruth.imp_iff]`; `and_iff`
      does not fire before `PlusFormula.iff` is unfolded
- [ ] Write `(PlusTruth.dstab_iff M τ t _)` with `M τ t` explicit — `(PlusTruth.dstab_iff _)`
      fills only `M` and the `.mp` projection then fails
- [ ] Do not invoke `⊡χ → χ` separately: the `stab` clause is
      `∀ σ, τ.state t = σ.state t → …`, so `hg σ hσ` yields the guard at each `σ` directly and
      the reflexive instance is never needed

**Timing**: 1 hour

**Depends on**: 2, 4

**Verification Tier**: local

**Tier Justification**: two additive theorems at the end of one module with no existing
declaration touched, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.PlusValidity`,
the terminal module of the `PlusLanguage` validity layer.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusValidity.lean` - `after_negation_stable_dstab` and `after_negation_stable_stab`, plus the section docstring

**Verification**:
- Guarded scoped build of `FormalSystem.PlusLanguage.PlusValidity` exits 0
- `lean_verify` on both theorems reports no `sorryAx` and no axiom beyond
  `[propext, Classical.choice, Quot.sound]`

---

### Phase 6: Test pins [COMPLETED]

**Goal**: Pin the measured complexity values and the census non-classification so a later change
to the `strongRelease` complexity arm or the `matchBinaryDerived` guard cannot silently reclassify
the new operators.

**Tasks**:
- [ ] Add to the binary-derived block of `Tests/BimodalTest/Syntax/FormulaTest.lean`:
      `#guard (Formula.after pCmplx qCmplx).complexity == 4` and
      `#guard (Formula.before pCmplx qCmplx).complexity == 12`
- [ ] Add construction pins in the file's existing `example … := rfl` style:
      `after φ ψ = Formula.untl φ.neg (φ.and ψ)` and the `before` expansion
- [ ] Add to `Tests/BimodalTest/Automation/NormalizationTest.lean`, beside the existing
      `release` folding rows: `#guard (Formula.after pCmplx qCmplx).matchBinaryDerived == none`
      and the `foldedBinaryTag == none` companion, pinning that `after` is **not** picked up by
      the `strongRelease` arm (its guard is `φ.neg` while the inner conjunct is `φ`, so the
      arm's `if ψ == ψ'` equality fails)
- [ ] Add **no** row to `Tests/BimodalToolsTest/EnumeratorCountsTest.lean` and make no change to
      `BimodalTools/FormulaEnumerator.lean`

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts the two measured complexity values `4` and `12` and the
two `none` census classifications. All four were measured during research by compiled `#eval` /
`#guard` probes; confirm at implementation time by letting the `#guard` rows elaborate — a wrong
value fails the build rather than passing silently. If a value differs, do **not** adjust the
pin to match: that would mean the `complexity` arm analysis in Phase 1's Scope Hypothesis is
wrong, which is an escalation.

**Tier Justification**: test-only edits in two leaf test modules with no library code touched,
covered by the guarded scoped builds of `BimodalTest.Syntax.FormulaTest` and
`BimodalTest.Automation.NormalizationTest` — the `#guard` rows are themselves the assertions, so
compiling those two modules is the whole check.

**Files to modify**:
- `Tests/BimodalTest/Syntax/FormulaTest.lean` - complexity `#guard`s and construction `rfl` pins
- `Tests/BimodalTest/Automation/NormalizationTest.lean` - census non-classification `#guard`s

**Verification**:
- Guarded scoped builds of `BimodalTest.Syntax.FormulaTest` and
  `BimodalTest.Automation.NormalizationTest` exit 0 with every `#guard` green

---

### Phase 7: Documentation, paper marker, and full gate sweep [COMPLETED WITH EXCLUSIONS]

**Goal**: Record the argument-order landmine where the tree's decision record already owns that
question, close the paper's `% PORT:` marker with `\leanproof`, and verify the whole repository.

**Tasks**:
- [x] Add a "Derived binary operators" section to
      `docs/architecture/untl-snce-argument-order.md` stating that `Formula.release a b` is the
      paper's `Release(b,a)` (and the same reversal for `trigger`), that `Formula.before` is
      therefore `(Formula.release φ.neg ψ).and (Formula.someFuture φ)`, and naming the `rfl` pin
      added in Phase 1 as the evidence. State the current mapping only — no draft-history or
      supersession framing, and no task-number citation
- [ ] In `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, delete the
      `% PORT: uniqueness of the next phi-time gives the negation equivalence under the guard`
      line under `lem:after-negation` and close its proof with a `\leanproof` line in the
      established style, underscores escaped:
      `\leanproof{\texttt{SoundnessLemmas.after\_negation\_valid}}` *(deviation: skipped — out-of-tree paper edit, dropped by recorded user decision; see .decisions.json cycle 3)*
- [ ] In `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`, add a
      matching `\leanproof` under `cor:after-negation-stable`'s proof naming both L⁺ theorems.
      Traceability only — the cut file is not typeset into the live paper *(deviation: skipped — out-of-tree paper edit, dropped by recorded user decision; see .decisions.json cycle 3)*
- [x] Re-read each file immediately before editing (concurrent siblings are live on this tree)
      and stage explicit file lists only, never a directory or glob add
- [x] Run the full gate set and record each exit status

**Timing**: 1.25 hours

**Depends on**: 3, 5, 6

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that the gate set enumerated below is the complete one
for this change class. Confirm at implementation time by running every listed gate and recording
its exit status individually; a gate that errors for an unrelated, pre-existing reason is
reported as such with its output, never silently dropped from the list.

**Files to modify**:
- `docs/architecture/untl-snce-argument-order.md` - new "Derived binary operators" section
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` - remove the `% PORT:` marker, add `\leanproof` under `lem:after-negation`
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` - add `\leanproof` under `cor:after-negation-stable`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project,
  detached, un-piped exit capture) exits 0, and the same for `-- build BimodalTest`,
  `-- build BimodalTools`, `-- build BimodalToolsTest`
- No new `sorry` and no new axiom: `lean_verify` on all five pinned theorems
- `bash scripts/check-module-invariants.sh` exits 0
- `bash scripts/check-copyright-headers.sh` exits 0
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-paper-definitions.sh` exits 0 (run without tail-truncation, so a drift list
  longer than the terminal is not hidden)
- `bash scripts/check-phantom-citations.sh` exits 0
- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete aggregated gate set for the
  repository, named here in full per the `full` tier
- `bash agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh --check` run and its
  verdict reported (advisory only; a spelling-level drift against the primitive expansions pinned
  below is expected, a content-level drift is escalated)

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| Delete the `% PORT:` marker under `lem:after-negation` in `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` and add `\leanproof{\texttt{SoundnessLemmas.after\_negation\_valid}}` | Out-of-tree paper edit. Recorded user decision: keep all paper edits out of scope; implement agents touch only this repository. Deferred to the paper's own owner, not incomplete work | `specs/793_after_operator_negation_equivalence/.decisions.json`, cycle 3, answered 2026-10-14T22:11:54Z; relayed verbatim in `.dispatch/21.md`'s "Prior Decisions" |
| Add a matching `\leanproof` under `cor:after-negation-stable` in `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` | Same decision, same file family. Traceability only; the cut file is not typeset into the live paper | Same decision record. The in-tree substitute is the `PlusValidity.lean` section docstring, which names both L⁺ theorems and records that the corollary is cut material |
| `bash scripts/check-paper-definitions.sh` exits 0 | Exits 1 on ten anchors that were already drifted before this task began: `CO`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:TMplus`, `app:discrete`, `def:id`, `def:strongest`, `thm:exist`, `lem:uniq`. Inherited, not absorbed, and no sentinel re-pinned | Run without tail-truncation; the complete `--- anchor:` list was read, and none of this task's three anchors appears in it. The three new anchors resolve cleanly, confirmed by C15 at `PASS  C15  all 81 paper-anchor citation(s) resolve` |
| `lean-challenge-snapshot.sh --check` run and its verdict reported | Not runnable: no Challenge manifest exists at `specs/793_after_operator_negation_equivalence/challenge/manifest.json`, so there is nothing to diff. Advisory only by its own file header | A stronger substitute was run instead: a compiled probe stating all five pinned Challenge statements verbatim in their primitive spelling and discharging each with the implemented theorem. All five elaborate (`lake env lean`, exit 0), so no implemented statement is weaker than its pinned one |


---

## Lean Challenge Statements

The pinned statements spell `After(φ,ψ)` as its primitive expansion `untl (¬φ) (φ ∧ ψ)` rather
than as `Formula.after φ ψ` / `PlusFormula.after φ ψ` / `TruthClauses.after φ ψ`, so this block
type-checks against the tree as it stands before Phase 1. The two spellings are definitionally
equal by `rfl`; the implementation uses the named operators.

```lean
import FormalSystem.Semantics.Validity
import FormalSystem.PlusLanguage.PlusValidity

open FormalSystem.Syntax
open FormalSystem.Semantics

namespace FormalSystem.Semantics.TruthClauses

/-- Next-`φ`-time uniqueness: the hypotheses spell out `IsNextTime` inline. -/
theorem isNextTime_unique {L : Type} [TruthEnv L] [UntlClause L] {F : TaskFrame}
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (e : TruthEnv.Env L F) (φ : L)
    {z z' : F.Duration}
    (hz : t < z ∧ TruthEnv.T M τ z e φ ∧
      ∀ r : F.Duration, t < r → r < z → ¬ TruthEnv.T M τ r e φ)
    (hz' : t < z' ∧ TruthEnv.T M τ z' e φ ∧
      ∀ r : F.Duration, t < r → r < z' → ¬ TruthEnv.T M τ r e φ) :
    z = z' := sorry

/-- `lem:after-negation`, pointwise and language-generic. -/
theorem after_negation {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]
    {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L)
    (hg : TruthEnv.T M τ t e (UntlClause.untl (neg φ) (and φ top))) :
    (¬ TruthEnv.T M τ t e (UntlClause.untl (neg φ) (and φ ψ)))
      ↔ TruthEnv.T M τ t e (UntlClause.untl (neg φ) (and φ (neg ψ))) := sorry

end FormalSystem.Semantics.TruthClauses

namespace FormalSystem.Metalogic.SoundnessLemmas

/-- `lem:after-negation` as an L validity over every task frame. -/
theorem after_negation_valid (φ ψ : Formula) :
    Valid ((Formula.untl φ.neg (φ.and Formula.top)).imp
      ((((Formula.untl φ.neg (φ.and ψ)).neg).imp (Formula.untl φ.neg (φ.and ψ.neg))).and
        ((Formula.untl φ.neg (φ.and ψ.neg)).imp ((Formula.untl φ.neg (φ.and ψ)).neg)))) := sorry

end FormalSystem.Metalogic.SoundnessLemmas

namespace FormalSystem.PlusLanguage

/-- `cor:after-negation-stable`, existential (`⟐`) reading. -/
theorem after_negation_stable_dstab (φ ψ : PlusFormula) :
    PlusValid ((PlusFormula.untl φ.neg (φ.and PlusFormula.top)).stab.imp
      (PlusFormula.iff
        (PlusFormula.dstab (PlusFormula.untl φ.neg (φ.and ψ)).neg)
        (PlusFormula.dstab (PlusFormula.untl φ.neg (φ.and ψ.neg))))) := sorry

/-- `cor:after-negation-stable`, universal (`⊡`) reading. -/
theorem after_negation_stable_stab (φ ψ : PlusFormula) :
    PlusValid ((PlusFormula.untl φ.neg (φ.and PlusFormula.top)).stab.imp
      (PlusFormula.iff
        (PlusFormula.untl φ.neg (φ.and ψ)).neg.stab
        (PlusFormula.untl φ.neg (φ.and ψ.neg)).stab)) := sorry

end FormalSystem.PlusLanguage
```

## Testing & Validation

- [ ] All five pinned theorems compile and pass `lean_verify` with no `sorryAx` and no axiom
      beyond `[propext, Classical.choice, Quot.sound]`
- [ ] `Formula.after`/`Formula.before` and `PlusFormula.after` carry `rfl` pins against the
      paper's literal primitive expansions, and `ofFormula` commutation is pinned for `after`
- [ ] `#guard (Formula.after pCmplx qCmplx).complexity == 4` and the `before` companion `== 12`
      are green, and the census rows pin `matchBinaryDerived == none` /
      `foldedBinaryTag == none`
- [ ] Guarded full builds of `FormalSystem`, `BimodalTest`, `BimodalTools`, `BimodalToolsTest`
      exit 0
- [ ] The three pinned enumerator counts in `Tests/BimodalToolsTest/EnumeratorCountsTest.lean`
      (`7852`, `75914`, `45111`) are unchanged — the enumerator was deliberately not touched
- [ ] `check-module-invariants.sh`, `check-copyright-headers.sh`, `readme-lint.sh`,
      `check-paper-definitions.sh`, `check-phantom-citations.sh`, `verify-deploy.sh` all exit 0
- [ ] No `reflect_time_*` entry, `complexity` arm, `formula_unfold` lemma, `EnrichedFormula`
      constructor, or `FormulaEnumerator` registration was added for the new operators
- [ ] The `% PORT:` marker under `lem:after-negation` is gone and replaced by a `\leanproof` line

## Artifacts & Outputs

- `FormalSystem/Syntax/Formula.lean` — `Formula.after`, `Formula.before`, two `rfl` pins
- `FormalSystem/Semantics/TruthClauses.lean` — generic `after` tier: `IsNextTime`,
  `isNextTime_unique`, `after_top_iff`, `after_iff_of_isNextTime`, `after_negation`
- `FormalSystem/Metalogic/SoundnessLemmas/EventOperators.lean` (new) — `after_negation_valid`
- `FormalSystem/Metalogic/SoundnessLemmas.lean`,
  `FormalSystem/Metalogic/SoundnessLemmas/README.md` — import line, contents bullet, inventory row
- `FormalSystem/PlusLanguage/Formula.lean` — `PlusFormula.after` and its `ofFormula` pin
- `FormalSystem/PlusLanguage/PlusValidity.lean` — `after_negation_stable_dstab`,
  `after_negation_stable_stab`
- `Tests/BimodalTest/Syntax/FormulaTest.lean`,
  `Tests/BimodalTest/Automation/NormalizationTest.lean` — complexity and census pins
- `docs/architecture/untl-snce-argument-order.md` — "Derived binary operators" section
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`,
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` — marker
  cleared, `\leanproof` lines added
- `specs/793_after_operator_negation_equivalence/summaries/01_after-operator-negation-equivalence-summary.md`
  at completion

## Rollback/Contingency

Every phase is additive and independently green, so the ordinary contingency is to revert the
single phase's own commit with `git revert <sha>` — no working-tree rollback is involved and no
snapshot is needed.

Before Phase 7's cross-repository edits (the two `.tex` files live outside this repository and
are not covered by this repo's history), take a durable, non-reverting checkpoint:
`bash .claude/scripts/git-snapshot.sh 793 --no-revert`. Never the default reverting form — a
concurrent sibling is live on this same working tree and would lose its uncommitted work.

If a genuine rollback of uncommitted work becomes necessary, follow
`context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
out-of-scope override flag; do not improvise a `git reset --hard` or `git clean` on this shared
tree.

Per-deliverable fallback, if a phase proves unlandable as written: mark the phase `[BLOCKED]`
and escalate rather than substituting a different decomposition — `plan-compliance.md` applies
to every `.lean` file here, and the whole proof set was already compiled during research, so an
unlandable step signals a transcription error to be found, not a strategy to be replaced.
