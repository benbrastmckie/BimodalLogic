# Implementation Plan: Extend the Lean appendix to semantics, a derived theorem, the metalogic map, and the decision procedure

- **Task**: 647 - extend_lean_appendix_semantics_metalogic_coverage
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: None upstream. Tasks 648 and 649 are ordered after this task and must not be pre-empted by it.
- **Research Inputs**: specs/647_extend_lean_appendix_semantics_metalogic_coverage/reports/01_extend-lean-appendix-coverage.md
- **Artifacts**: plans/01_extend-lean-appendix-coverage.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`typst/chapters/ax-lean-appendix.typ` today teaches a reader to read the syntax layer and the
proof system in Lean, and stops there. This plan extends it to the semantic layer, a worked
derived theorem and its semantic counterpart, functions on derivations, the metalogic result map,
the decision procedure, and a project overview, by threading the new material into the existing
arc in dependency order rather than appending it. Eight phases author prose against
live-verified signatures, one phase extends `scripts/typst-status-counts.sh` and
`scripts/typst-sync-check.sh` Check 2 together so no cited figure can drift, and a final phase
inspects every rendered page and sweeps all four acceptance gates. Done means: `typst compile`
exit 0, `typst-sync-check.sh` PASS, `typst-element-lint.sh` PASS, no prose semicolon, every
quoted signature diffed against live source, every rendered appendix page inspected, and the
dated `typst/SYNC-MAP.md` appendix entry rewritten to describe the new coverage.

### Research Integration

The research report verified all ten dispatch coverage items against live source and is the
signature ledger this plan builds on. Findings that change what implementation writes:

- **Two name corrections.** `Conservativity.Plus.plusDerivable_ofFormula_iff` does not exist; the
  live name is `FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff` (the directory
  is `Plus/`, the namespace is not). `contraposition` is ambiguous between
  `Theorems.Propositional` and `Theorems.Perpetuity`, so item (4) must write
  `Perpetuity.contraposition`.
- **`PlusLanguage` belongs in the import-layer list** for item (10), per
  `FormalSystem/README.md`'s own Layer 0, against the dispatch's six-directory list.
- **Four of five non-resolving backtick spans are avoidable** by using the source's own spelling.
  Only `searchDepth := 10` and `tableauFuel := 1000` need whitelist entries.
- **Check 2 polices only an explicitly named field list**, so a new `#let` in `status.typ`
  without a matching `scalar_fields`/`live_map` entry is a silent-drift bug. The generator and
  the check must change in one commit.
- **All twenty candidate didactic snippets compile** and all four acceptance gates are green at
  baseline, so any post-change failure is attributable.
- **Fifteen of thirty-six ledger rows exceed 71 columns** at the source's own line breaking and
  need re-breaking under the appendix's stated convention.

### Prior Plan Reference

No prior plan. This is the first planning round for this task.

### Roadmap Alignment

No roadmap context was supplied in this dispatch and no roadmap phases are included.

### Working-Tree Precondition

`typst/chapters/ax-lean-appendix.typ` carries a substantial uncommitted delta at plan time
(HEAD has 231 lines, the working tree has 440). The research report measured the **working
tree**, and every line reference, gate baseline and section number in this plan is against the
working tree. The implementer MUST NOT revert, stash or discard that delta: it is the version
this task extends. The file is in this task's scope, so the first phase commit that touches the
appendix legitimately carries that pre-existing delta along with the phase's own work. No
`git-snapshot.sh` default-mode (reverting) call is warranted at any point in this plan.

## Goals & Non-Goals

**Goals**:

- Cover all ten dispatch items in `typst/chapters/ax-lean-appendix.typ`, each Lean concept
  introduced once, on a real declaration, in dependency order.
- Reorganize the appendix arc (five new sections, three extended in place) rather than appending
  a block of additions at the end.
- Keep every cited figure generator-derived: extend `scripts/typst-status-counts.sh` and
  `scripts/typst-sync-check.sh` Check 2 in one atomic change.
- Keep all four acceptance gates green at the close of every phase, not only at the end.
- Rewrite the dated appendix entry in `typst/SYNC-MAP.md` to describe the new coverage and to
  drop its stale "byte-exact" claim and archived scratch-file path.

**Non-Goals**:

- Renaming the appendix title or the `lean-appendix` label. Task 648 item (1) owns that decision
  and every existing `lean-appendix-*` label must stay byte-identical.
- Editing `typst/chapters/p2-decidability-practice.typ`, whose stale `DecisionResult` description
  is owned by task 648 item (4).
- Defining a shared Lean code environment in `typst/template.typ`. Task 649 owns that; this plan
  only keeps every `#leansrc` call site compatible with the current two-argument signature.
- Restating the mathematics of *TM*. The appendix cross-references the Part I chapters.
- Changing any `FormalSystem/` source. Scratch probe files live outside `FormalSystem/` and
  `Tests/` and are never committed.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A prose semicolon slips into fifteen-plus new paragraphs | H | H | Per-phase gate, not a final one: `grep -n ';' typst/chapters/ax-lean-appendix.typ \| grep -v 'apply DerivationTree.axiom'` must return empty before any phase closes |
| A new `status.typ` figure goes stale silently (Check 2 names its fields) | H | M | Phase 8 extends generator and Check 2 in one atomic-batch commit and proves the coupling by perturbing one figure and confirming Check 2 fails |
| A quoted signature drifts from live source | H | M | Every excerpt re-derived with `lean_declaration_file`/`Read` at authoring time and diffed token-by-token before the phase closes; never transcribed from the research ledger alone |
| Re-broken wide lines change the token sequence | M | M | Re-break only at whitespace, then diff the token sequence (not the byte sequence) against source |
| The file outgrows its formatting block: wrapped code, orphaned `#leansrc` labels, block/paragraph collisions | M | M | 71-column budget enforced at authoring time, `sticky: true` label override left intact, and Phase 10 renders every appendix page to PNG with `pdftoppm` and inspects it |
| Label churn breaks cross-references (`@lean-appendix` from `00-introduction.typ`) | H | L | Existing labels byte-identical, new sections get new `lean-appendix-*` labels only; verified by grep before Phase 10 closes |
| Overlap with task 648 produces a double edit of `SYNC-MAP.md` or the whitelist | M | M | This task owns the `SYNC-MAP.md` appendix entry and the two whitelist additions; it touches nothing else 648 or 649 own |
| Quoting `Metalogic/Conservativity.lean` invites conflating the TM⁻/TM forward direction with TM⁺ conservativity | M | M | Item (10) prose names both files and says which result lives where, and never repeats the do-not-attempt warning as if it applied to TM⁺ |
| The uncommitted working-tree delta is discarded by a reflexive rollback | H | L | Working-Tree Precondition above: no default-mode `git-snapshot.sh`, no reset, no stash |
| A didactic snippet is written without being compiled first | M | M | Phase 1 builds one scratch file carrying every snippet the later phases use, and each authoring phase re-runs it before closing |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 8 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 9 | 7, 8 |
| 9 | 10 | 9 |

Phases within the same wave can execute in parallel. Phases 2 through 7 and 9 are serialized
because they all edit the same file in document order. Phase 8 touches only `scripts/` and
`typst/generated/status.typ` and is independent of the prose phases.

### Standing Per-Phase Gate

Every phase that touches `typst/` closes by running all four of these from the repository root,
and does not close until all four pass:

```
(cd typst && typst compile --root .. BimodalReference.typ)
bash scripts/typst-sync-check.sh
bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/ax-lean-appendix.typ
grep -n ';' typst/chapters/ax-lean-appendix.typ | grep -v 'apply DerivationTree.axiom'
```

The last command must produce no output. Commit the phase with
`task 647 phase {P}: {phase name}` and the session ID in the body, staging only the files the
phase declares.

### Standing Authoring Constraints

These apply to every authoring phase below and are not repeated per phase:

- No semicolons in prose anywhere in the file, new or existing. The only permitted semicolon is
  inside the literal Lean macro body `apply DerivationTree.axiom; refine ?_`.
- One sentence per source line. Short sentences. Lists and tables in the style the file already
  uses. Bold for introduced terms.
- Two snippet kinds only: `#leansrc` excerpts (verbatim up to whitespace, docstrings omitted,
  lines re-broken to at most 71 columns) and didactic examples (no `#leansrc` line, compiled
  first with `lake env lean` in a scratch file outside `FormalSystem/` and `Tests/`).
- `#leansrc` takes the **namespace**, not the file path, as its first argument, and keeps its
  current two-argument call shape.
- Keep the file-local formatting block (A.n numbering, 8pt unbreakable code blocks, sticky
  `#leansrc` labels, list and figure spacing) unchanged.
- Existing `lean-appendix` and `lean-appendix-*` labels stay byte-identical. New sections get new
  `lean-appendix-*` labels.
- No task numbers and no `specs/` paths in the file.
- Every backticked span must resolve under Check 1 of `scripts/typst-sync-check.sh`, including
  backticks inside comments.
- Open items are phrased durably and point at where the book states them as open problems
  (`@sec:fmp-resolution`, `@sec:decidability-practice`), never as dated progress notes.

---

### Phase 1: Verification harness, signature re-derivation, and whitelist [COMPLETED]

**Goal**: Produce one compiled scratch file carrying every didactic snippet the later phases
need, one re-derived and re-broken excerpt set for every declaration those phases quote, and the
whitelist additions, so no authoring phase has to stop and verify.

**Tasks**:

- [ ] Record the baseline: run all four gates and confirm the research report's green baseline
      still holds on the current working tree.
- [ ] Create one scratch Lean file in the session scratchpad (outside `FormalSystem/` and
      `Tests/`) and populate it with every didactic snippet the plan's later phases use: the
      `CoeSort` coercion (`(t : F.Duration)` used at `F.Duration.carrier`), the `WorldHistory`
      subtype projections and `states_eq_state`, `Iff.rfl` on the box clause of `TruthAt`, the
      set-builder valuation reading, the three binder forms, `perpetuity2` applied at an inferred
      `fc`, the MF instance closed by `modal_search`, `DerivationTree.lift (by decide) d`, the
      four `FrameClass` order facts by `decide`, `ValidIn FrameClass.Base = Valid` by `rfl`,
      `strongCompleteness_of_compact compactBase completeness_base`, `decide φ` and
      `decide φ 10 1000 .Base`.
- [ ] Run `lake env lean` on that file and require zero errors.
- [ ] Re-derive every excerpt the later phases quote directly from live source (never from the
      research ledger), and stage each one re-broken to at most 71 columns with docstrings
      omitted, into a scratchpad notes file. Diff each re-broken form's token sequence against
      source.
- [ ] Re-confirm the two name corrections by elaboration: that
      `FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff` resolves and the
      dispatch's `...Conservativity.Plus....` spelling does not, and that `contraposition` is
      ambiguous unqualified.
- [ ] Add the two optional-parameter spans to `typst/sync-check-whitelist.txt` under a new
      category comment (for example
      `# --- Optional-parameter illustrations (source spells the full binder) ---`), matching the
      file's existing comment-block style.
- [ ] Run `bash scripts/typst-sync-check.sh` and confirm PASS with the whitelist addition in
      place.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The research report asserts twenty compiling didactic snippets, thirty-six
ledger rows of which fifteen need re-breaking, and exactly two required whitelist entries.
Confirm at implementation time by compiling the actual snippet set this plan's phases reference
(the count may differ once each phase's prose is fixed), by measuring each re-derived excerpt's
widest line rather than trusting the ledger's column figures, and by running
`scripts/typst-sync-check.sh` after the whitelist edit rather than by inspecting the whitelist.
If a third span fails Check 1, prefer the source's own spelling over a third whitelist entry.

**Files to modify**:

- `typst/sync-check-whitelist.txt` - two optional-parameter spans under a new category comment.
- Scratch files in the session scratchpad only (never committed, never under `FormalSystem/` or
  `Tests/`).

**Verification**:

- `lake env lean` on the scratch snippet file exits 0 with no errors.
- `bash scripts/typst-sync-check.sh` PASS.
- The re-broken excerpt set exists in the scratchpad, each entry token-identical to source.

---

### Phase 2: Semantic structures in `lean-appendix-structures` [COMPLETED]

**Goal**: Extend the existing structures section (item 1) so a reader meets the binder forms
once, then instance-bracket fields and the `CoeSort` coercion on `TemporalOrder`, then
`FrameOver` and `TaskFrame` with their accessors and the reflection convention.

**Tasks**:

- [ ] Introduce the three binder forms once, explicitly: explicit `( )`, implicit `{ }`, instance
      `[ ]`. Place this before any signature that shows one, so later sections can refer back.
- [ ] Add `TemporalOrder` as a bundled structure with its four instance-bracket fields
      (`addCommGroup`, `linearOrder`, `isOrderedAddMonoid`, `nontrivial`).
- [ ] Add the `CoeSort TemporalOrder Type` instance and the `attribute [instance]` re-export
      line, and state plainly that this is why `#check` on soundness prints
      `F.Duration.carrier` and why `[DenselyOrdered F.Duration]` elaborates at all. This closes
      the existing defect in the soundness walkthrough.
- [ ] Add `FrameOver` with `WorldState`, `worldNonempty`, `PosRel` over `D.PositiveCone`, and the
      `comp` / `serial` / `limit` / `saturation` fields, stated over `TaskFrame.reflect PosRel`
      exactly as the source states them.
- [ ] State the reflection convention using the source's own spelling
      `FrameOver.TaskRel := TaskFrame.reflect PosRel`, and say that reflection is a derived
      theorem (`FrameOver.reflection`) rather than a field.
- [ ] Add `TaskFrame` packaging `Duration` with `toFibre`, and the `F.Duration`, `F.WorldState`,
      `F.TaskRel` accessors.
- [ ] Mention the `worldNonempty` re-export as the same pattern one level down, briefly.
- [ ] Cross-reference `@sec:truth` and `@sec:frame-classes` for the mathematics instead of
      restating it.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts a seven-field `FrameOver` and a four-field
`TemporalOrder`. Confirm by reading the live structure declarations at authoring time and
quoting what is there, not what this list says. `FrameOver` is nearly all docstring, so the
docstring-omitted excerpt should be about nine short lines; if it is materially longer, quote
only the fields the prose discusses and say so.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - `== Structures and Classes <lean-appendix-structures>`.

**Verification**:

- Standing per-phase gate, all four commands.
- Every new backtick span resolves under Check 1 with no further whitelist additions.
- The `F.Duration.carrier` explanation precedes the soundness walkthrough in document order.

---

### Phase 3: Dependent fields, subtypes, and histories [NOT STARTED]

**Goal**: Add a new section (item 2) introducing dependent fields, subtypes, and the
predicate-versus-structure design choice, on `PartialHistory`, `IsConvex`/`IsTotal`,
`WorldHistory` and `TaskModel`.

**Tasks**:

- [ ] Create a new section with a new `lean-appendix-*` label (for example
      `<lean-appendix-dependent-fields>`), placed after the structures section.
- [ ] Add `PartialHistory` with its dependent `states` field, and explain what a dependent field
      buys: no junk values off the domain.
- [ ] Add `nonempty_domain` and `respects_task`, noting that `respects_task` is stated
      unconditionally and the guarded form is derived as `respects_task_le`.
- [ ] Add `IsConvex` and `IsTotal` as predicates rather than separate structures, and explain the
      design choice.
- [ ] Add `WorldHistory` as the subtype `{τ // τ.IsTotal}`, with `.val` and `.property`, and note
      that it is a `def` rather than an `abbrev`.
- [ ] Add `WorldHistory.state` and show why it needs no domain proof.
- [ ] Add the valuation reading of `TaskModel`: the set of states where `valuation w p` holds,
      written `{w | M.valuation w p}`.
- [ ] Cross-reference `@sec:convex-histories` for the mathematics.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts a four-field `PartialHistory`. Confirm against the live
declaration at authoring time.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - new section after `lean-appendix-structures`.

**Verification**:

- Standing per-phase gate, all four commands.
- The new label does not collide with any existing `lean-appendix-*` label.
- `TaskModel` is not excerpted twice: the existing excerpt in the structures section is reused by
  cross-reference, or moved, but not duplicated.

---

### Phase 4: Definition by structural recursion [NOT STARTED]

**Goal**: Add a new section (item 3) showing `TruthAt` clause by clause beside the `Formula`
constructors, then `PlusFormula.stab` and its one added `PlusTruthAt` clause.

**Tasks**:

- [ ] Create a new section with a new `lean-appendix-*` label (for example
      `<lean-appendix-recursion>`), placed after the dependent-fields section.
- [ ] Show `TruthAt`'s six clauses beside the six `Formula` constructors, and explain pattern
      matching on an inductive type.
- [ ] Introduce constructor patterns once, contrasting `TruthAt`'s fully qualified
      `Formula.atom p` with `PlusTruthAt`'s dot form `.atom p`.
- [ ] State the box clause as quantifying over all world histories.
- [ ] State the `untl` and `snce` clauses with their strict `<`, and state the guard-first
      argument order explicitly: the first argument is the guard and the second is the event.
- [ ] Add `PlusFormula` with `stab` as its seventh constructor and the single added `PlusTruthAt`
      clause (histories in the same state at `t`), as the worked example of extending a language
      by one constructor.
- [ ] Cross-reference `@sec:truth` and `@ch:vlach-blstar`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts six `TruthAt` clauses, seven `PlusFormula` constructors
and seven `PlusTruthAt` clauses. Confirm by reading each declaration at authoring time; the
clause-to-constructor correspondence is the section's whole point, so an off-by-one is a content
defect, not a formatting one.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - new section after the dependent-fields section.

**Verification**:

- Standing per-phase gate, all four commands.
- The `PlusTruthAt` excerpt is re-broken to 71 columns and token-identical to source.

---

### Phase 5: A derived theorem, its semantic counterpart, and derivations as data [NOT STARTED]

**Goal**: Add three new sections (items 4, 5, 6): `perpetuity2` as a worked `def`,
`timeShift_preserves_truth` as the semantic counterpart obtained by generic transport, and
`DerivationTree.lift` with the `FrameClass` order.

**Tasks**:

- [ ] Create the derived-theorem section (new `lean-appendix-*` label, for example
      `<lean-appendix-derived-theorem>`), placed after the tactics section.
- [ ] Walk `perpetuity2`: the implicit `{fc : FrameClass}` binder giving one proof term for all
      four frame classes, the `have` and `exact` steps, reuse of `perpetuity1`, and the
      `⊢[fc]` notation. Refer back to the binder forms introduced in Phase 2 rather than
      re-introducing them.
- [ ] Write `contraposition` qualified as `Perpetuity.contraposition`, and say why: two live
      declarations share the short name, exactly as `Axiom.modal_t` already requires.
- [ ] Show the MF instance `⊢ φ.box.imp φ.allFuture.box` closed by `modal_search`.
- [ ] Create the semantic-counterpart section (for example
      `<lean-appendix-semantic-counterpart>`). Present `timeShift_preserves_truth` as an `iff`
      obtained from the generic transport `truthAt_of_truthCorr` at `shiftCorr`, not by a bespoke
      induction, and note that no shift-closure hypothesis is required.
- [ ] Add `modal_future_valid`, and the remark that soundness is what makes the syntactic and
      semantic routes agree, with the MF case of the soundness proof being where time-shift
      invariance is used.
- [ ] Optionally contrast the light axiom footprints (`perpetuity2` at `[propext]`,
      `timeShift_preserves_truth` at `[propext, Quot.sound]`) with the three-axiom standard set
      already quoted in the trust-reading subsection, to make the point that the audit reports
      what a proof actually used.
- [ ] Create the derivations-as-data section (for example
      `<lean-appendix-derivations-as-data>`). Show `DerivationTree.lift` by structural recursion:
      `le_trans` in the axiom case, the same recursion elsewhere, and the fact that only the
      `axiom` constructor checks `minFrameClass`.
- [ ] State the `FrameClass` partial order as `FrameClass.Base ≤ FrameClass.Dense`,
      `FrameClass.Dense ≤ FrameClass.RTime` and `FrameClass.Base ≤ FrameClass.ZTime` (qualified
      spellings, to resolve under Check 1), mirroring the `by decide` order-shape examples the
      source already carries.
- [ ] State that derivations being data is what lets `decide` return them, `height` recurse on
      them, and the dataset pipeline export them, cross-referencing `@sec:dataset-pipeline`.
- [ ] Cross-reference `@sec:perpetuity` and `@sec:frame-classes`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that `lift` has seven pattern-match arms of which only
`.axiom` does work, and that `perpetuity2`'s body is two lines. Confirm both against live source
at authoring time; if the arm count differs, the prose claim about "only the axiom constructor"
must be re-checked, not just the number.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - three new sections.

**Verification**:

- Standing per-phase gate, all four commands.
- `contraposition` appears nowhere unqualified.
- The three new labels are distinct from each other and from every existing label.

---

### Phase 6: The metalogic result map [NOT STARTED]

**Goal**: Add the metalogic result map (item 7) to `lean-appendix-reading-source` as one table
per frame class, with the proof routes named and the refutations stated as theorems.

**Tasks**:

- [ ] Add a new subsection inside `lean-appendix-reading-source` carrying four tables, one per
      result family (soundness, weak completeness, compactness, strong completeness), each with a
      row per frame class and columns *statement*, *declaration*, *status*. Four four-row tables
      make the Base/Dense versus ZTime/RTime asymmetry visible at a glance.
- [ ] Populate soundness: `soundness`, `soundness_dense`, `soundness_ztime`, `soundness_rtime`.
- [ ] Populate weak completeness: `completeness_base`, `completeness_dense`,
      `completeness_ztime`, `completeness_rtime`. Note that `ValidIn FrameClass.Base = Valid`
      holds by `rfl`, so `completeness_base` and the appendix's existing
      `BXCanonical.completeness` excerpt state the same thing. Say this rather than leaving an
      apparent duplication.
- [ ] Populate compactness and strong completeness: `compactBase`, `strongCompletenessBase`,
      `compactDense`, `strongCompletenessDense` as proved.
- [ ] State `notCompactZTime`, `notStrongCompletenessZTime`, `notCompactRTime`,
      `notStrongCompletenessRTime` as machine-checked refutations: refutations are theorems, one
      finitely satisfiable and unsatisfiable witness set per class. Name the two distinct
      witnesses and say why the ZTime witness does not port to the dense carrier.
- [ ] Show `strongCompletenessBase` as the one-line term proof
      `strongCompleteness_of_compact compactBase completeness_base`, whose statement is a named
      `Prop`-valued `def` (`StrongCompletenessBase`).
- [ ] Show `notCompactZTime` with the anonymous-constructor atom, written as the bare
      `⟨"p", none⟩` with `Atom` named separately in prose so the span resolves under Check 1.
- [ ] Name the proof routes and where they live: the chronicle canonical model in
      `Metalogic/BXCanonical/`, the Kamp-Reynolds and algebraic routes beside it, and compactness
      by an ultraproduct over finite sublists with strong completeness following uniformly.
- [ ] Cross-reference `@sec:metalogic`, `@sec:completeness-theorems` and `@sec:dichotomy`.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts four tables of four rows and sixteen named declarations.
Confirm every declaration resolves before writing the table, and drop or re-label any row whose
declaration does not exist at the asserted frame class rather than padding the table for
symmetry.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - new subsection inside `lean-appendix-reading-source`.

**Verification**:

- Standing per-phase gate, all four commands.
- Every declaration named in the four tables resolves under Check 1.
- The refutation rows read as theorems, never as missing proofs.

---

### Phase 7: A name is not a proof, and the decision procedure's types [NOT STARTED]

**Goal**: Extend the Trust-Reading Practice subsection with item (8) and add the decision
procedure's types (item 9) with an honest established-versus-open split.

**Tasks**:

- [ ] Extend Trust-Reading Practice with the lesson that a reader audits the statement, never the
      name.
- [ ] Quote the retired classical disjunction `(⊨ φ) ∨ ¬(⊨ φ)`, note it is provable by
      `Classical.em` and is no decision procedure at all, and say that this is why such a
      declaration was retired and why `Decidable (⊨ φ)` is the statement that matters. Quote the
      retired statements verbatim from the retirement note in the source rather than paraphrasing
      them.
- [ ] Add a decision-procedure subsection with `DecisionResult` and its four constructors
      (`valid` carrying `⊢ φ`, `invalid` carrying `SimpleCountermodel`, `fuelExhausted`,
      `extractionFailed`).
- [ ] Show `decide` with its default arguments as the worked example of optional parameters,
      quoting the full binder form the source uses and relying on the Phase 1 whitelist entries
      only for the abbreviated spans.
- [ ] Add `sound_of_isValid`, re-broken to 71 columns.
- [ ] Write the honest split: established is that valid verdicts carry proof terms, rule
      soundness, termination measures and the countermodel bridge; open is the converse
      `⊨ φ → isValid`, hence `Decidable (⊨ φ)`, and totality against a formula-dependent budget.
- [ ] Phrase every open item durably and point at `@sec:fmp-resolution` and
      `@sec:decidability-practice` where the book states them as open problems. No dated progress
      notes.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts four `DecisionResult` constructors and three `decide`
default arguments. Confirm both against live source; the `p2-decidability-practice.typ` chapter
carries a stale three-constructor description, which is evidence that this particular count has
drifted before and must not be taken from memory.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - Trust-Reading Practice subsection plus a new
  decision-procedure subsection.

**Verification**:

- Standing per-phase gate, all four commands.
- No `specs/` path and no task number anywhere in the file.
- No sentence describing an open item reads as a dated progress note.

---

### Phase 8: Generator and Check 2 extension for scale and version figures [NOT STARTED]

**Goal**: Extend `scripts/typst-status-counts.sh` and `scripts/typst-sync-check.sh` Check 2
together so the repository-scale and version figures item (10) cites are generator-derived and
cannot drift silently.

**Tasks**:

- [ ] Add the new figures to `typst-status-counts.sh`: the Lean toolchain pin (from
      `lean-toolchain`), the Mathlib requested tag (from `lakefile.toml`), the Mathlib resolved
      commit (from `lake-manifest.json`), and per-tree file and line counts for `FormalSystem/`,
      `Tests/` and `BimodalTools/`. Report any archived-tree figure separately or not at all,
      never folded into a live figure.
- [ ] Emit every new figure in the `--json` branch as well as in the `status.typ` write path.
      `--json` is what Check 2 consumes and it must run without a build, so every new figure must
      be a filesystem or git read.
- [ ] Keep the `FormalSystem.lean` import-count cross-check in the generator: the root is
      produced by `lake exe mk_all` and checked by `--check`, so a mismatch between the import
      count and the file count is a real inconsistency.
- [ ] Add the same keys to `typst-sync-check.sh` Check 2's `scalar_fields` and `live_map`.
- [ ] Widen Check 2's comparison to handle string-valued fields (the version pins), or keep the
      string fields on a separate comparison path. The current path matches `(\d+)` only, so a
      string field added naively will report `MISSING` on every run.
- [ ] Regenerate `typst/generated/status.typ`.
- [ ] Prove the coupling by perturbation: change one committed figure by hand, confirm
      `typst-sync-check.sh` FAILS naming that field, then restore it and confirm PASS. Record
      both outcomes in the phase commit message or the implementation summary.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts nine new figures across three files. The names in the
research report are illustrative, not fixed; choose names consistent with the existing
`#let`-binding style and confirm the final set by running the perturbation test on at least one
integer field and one string field, not by counting the keys.

**Files to modify**:

- `scripts/typst-status-counts.sh` - new figures in both the `--json` payload and the
  `status.typ` write path.
- `scripts/typst-sync-check.sh` - matching `scalar_fields` and `live_map` keys, plus the
  string-field comparison path.
- `typst/generated/status.typ` - regenerated, never hand-edited.

**Verification**:

- `bash scripts/typst-status-counts.sh --json` runs without a build and emits every new key.
- `bash scripts/typst-sync-check.sh` PASS after regeneration.
- The perturbation test fails loudly on a changed figure and passes again once restored, for both
  an integer field and a string field.

**Atomic-batch note**: the generator, the check and the regenerated `status.typ` are one
objective. An intermediate state where the generator emits a key the check does not know is
expected red and is not committed on its own.

---

### Phase 9: Project overview, directory tour, and the section map [NOT STARTED]

**Goal**: Extend `lean-appendix-lake` and the directory tour with item (10), consuming Phase 8's
generated figures, and bring the appendix's opening section map into line with the new arc.

**Tasks**:

- [ ] Add the import-layer order of the top-level directories, following `FormalSystem/README.md`
      rather than the dispatch's six-directory list: Layer 0 (`ForMathlib`, `Tactic`, `Syntax`,
      `ProofSystem`, `PlusLanguage`), Layer 1 `Semantics`, Layer 2 `Metalogic`, Layer 3
      `Theorems`, Layer 4 `Automation`, Layer 5 `Examples`.
- [ ] Add the four proof systems TM, TM⁻, TM⁺ and TM⋆ with their directories, each over the four
      frame classes. Note `OpenLanguage/` as a fifth, semantics-only component with no proof
      system.
- [ ] Add TM⁺ soundness and its conservativity over TM, citing
      `Conservativity.plusDerivable_ofFormula_iff` (not the dispatch's non-existent `Plus`-nested
      spelling). Name both `Metalogic/Conservativity.lean` (the TM⁻/TM bridge) and
      `Metalogic/Conservativity/Plus.lean` (the four-class-complete TM⁺ result) and say which
      result lives where, so the two are not conflated.
- [ ] Add the pinned Lean and Mathlib versions and the repository-scale figures, every one read
      from `typst/generated/status.typ` via an `#import` addition. No hand-typed count anywhere.
- [ ] Update the existing directory tour entries that the new material makes incomplete or
      inaccurate.
- [ ] Rewrite the appendix's opening paragraph and four-bullet section map so the stated section
      count and the grouping match the final arc. The current text says "nine short sections".
- [ ] Confirm the `#import "../generated/status.typ"` line names every binding the file now uses.

**Timing**: 1.5 hours

**Depends on**: 7, 8

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts a six-layer import order, four proof systems plus one
semantics-only component, and a final section count for the opening map. Derive the section count
by counting `==` headings in the finished file rather than from this plan, and derive the layer
list from `FormalSystem/README.md` at authoring time.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - `lean-appendix-lake`, the directory tour, the `#import`
  line, and the opening section map.

**Verification**:

- Standing per-phase gate, all four commands.
- Every cited figure traces to a `#let` in `typst/generated/status.typ`; `grep` finds no
  hand-typed count in the section.
- The stated section count equals the actual `==` heading count.

---

### Phase 10: Render inspection, SYNC-MAP, and the acceptance sweep [NOT STARTED]

**Goal**: Inspect every rendered appendix page, update the dated `SYNC-MAP.md` entry, and run the
full acceptance set.

**Tasks**:

- [ ] Compile the book and render every appendix page to PNG with `pdftoppm`, using `pdfinfo` to
      locate the appendix's page range in the grown document.
- [ ] Inspect each rendered page for wrapped code lines, `#leansrc` labels orphaned from their
      blocks, and collisions between code blocks and the paragraphs around them. Fix any finding
      and re-render.
- [ ] Diff every quoted signature in the finished file against live source one final time, as a
      single pass over the whole file rather than per phase.
- [ ] Confirm `grep` finds no prose semicolon: only the permitted
      `apply DerivationTree.axiom; refine ?_` remains.
- [ ] Confirm every existing `lean-appendix` and `lean-appendix-*` label is byte-identical to its
      pre-task form, and that `@lean-appendix` still resolves from `00-introduction.typ`.
- [ ] Confirm no task number and no `specs/` path appears in the file.
- [ ] Rewrite the dated appendix entry in `typst/SYNC-MAP.md`: describe the new coverage, replace
      the stale "byte-exact" claim with the appendix's own stated policy (verbatim up to
      whitespace, docstrings omitted, lines re-broken), and drop the archived scratch-file path.
- [ ] Run the four acceptance gates one final time and record each result verbatim in the
      implementation summary.

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: The research report measured the appendix at rendered pages 88-98 of 107
and expects roughly 20-24 pages after this work. Determine the actual post-change page range with
`pdfinfo` and the rendered output, and inspect every page in that range rather than a sampled
subset.

**Files to modify**:

- `typst/SYNC-MAP.md` - the dated appendix entry, rewritten.
- `typst/chapters/ax-lean-appendix.typ` - render-driven fixes only.

**Verification**:

- `(cd typst && typst compile --root .. BimodalReference.typ)` exits 0. The two pre-existing
  `unknown font family` warnings from `thmbox` are expected and are owned by task 648.
- `bash scripts/typst-sync-check.sh` PASS, 3/3.
- `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/ax-lean-appendix.typ` PASS.
- `grep -n ';' typst/chapters/ax-lean-appendix.typ | grep -v 'apply DerivationTree.axiom'`
  returns nothing.
- Every appendix page rendered and inspected, with findings either fixed or recorded.

---

## Lean Challenge Statements

None. This plan adds no Lean declarations: it authors Typst prose about declarations that already
exist, and every Lean snippet it introduces is either an excerpt from live source or a didactic
`example` compiled in a throwaway scratch file that is never committed. The `- **Goals**:` bullets
above therefore name no Lean identifiers to prove, and this section's identifier set is
correspondingly empty.

## Testing & Validation

- [ ] `(cd typst && typst compile --root .. BimodalReference.typ)` exits 0 with no new warnings.
- [ ] `bash scripts/typst-sync-check.sh` PASS on all three checks.
- [ ] `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/ax-lean-appendix.typ`
      PASS.
- [ ] `grep -n ';' typst/chapters/ax-lean-appendix.typ | grep -v 'apply DerivationTree.axiom'`
      returns nothing.
- [ ] `lake env lean` on the scratch snippet file exits 0 with zero errors.
- [ ] Every quoted signature diffed against live source.
- [ ] Every rendered appendix page inspected via `pdftoppm` for wrapped code, orphaned labels and
      collisions.
- [ ] Check 2 perturbation test: a hand-changed figure fails the check, and restoring it passes.
- [ ] Every existing `lean-appendix*` label byte-identical, and `@lean-appendix` still resolves.
- [ ] No task number and no `specs/` path in `typst/chapters/ax-lean-appendix.typ`.

## Artifacts & Outputs

- `typst/chapters/ax-lean-appendix.typ` - extended appendix, five new sections and three extended
  in place.
- `typst/sync-check-whitelist.txt` - two optional-parameter spans under a new category comment.
- `scripts/typst-status-counts.sh` - version and scale figures in both output paths.
- `scripts/typst-sync-check.sh` - matching Check 2 keys and a string-field comparison path.
- `typst/generated/status.typ` - regenerated.
- `typst/SYNC-MAP.md` - the dated appendix entry, rewritten.
- `specs/647_extend_lean_appendix_semantics_metalogic_coverage/summaries/01_extend-lean-appendix-coverage-summary.md`

## Rollback/Contingency

Each phase commits independently with all four gates green, so reverting a single phase is a
`git revert` of that phase's commit and nothing else. There is no whole-tree rollback step in
this plan and none is expected to be needed.

The working tree carried a substantial uncommitted delta to
`typst/chapters/ax-lean-appendix.typ` when this plan was written, and that delta is the version
this task extends. Do not run `git-snapshot.sh` in its default reverting form, `git reset --hard`,
`git checkout --`, `git restore` or `git stash` against that file at any point. If a genuine
rollback ever becomes necessary, follow `context/contracts/recovery.md`'s rollback rung, which
names the correct snapshot invocation and its out-of-scope override flag, before running any
destructive command. For an ordinary defensive checkpoint before a risky edit, use
`git-snapshot.sh --no-revert`, which is durable without touching the working tree.

If Phase 8's Check 2 widening proves larger than budgeted, the fallback is to cite only the
version pins (which are short, stable strings) and defer the file and line counts to a follow-up,
rather than to hand-type a count into the appendix. A hand-typed count is not an acceptable
fallback under this task's constraints.
