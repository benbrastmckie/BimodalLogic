# Implementation Plan: Task #900

- **Task**: 900 - Bridge: ZTime-valid L formulas yield TM-plus theorems under PlusFormula substitution
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None live (899 `[COMPLETED]`; no artifact of it is read by this plan)
- **Research Inputs**: specs/900_linear_ztime_validity_tm_plus_substitution_bridge/reports/01_ztime-validity-tm-plus-substitution-bridge.md
- **Artifacts**: plans/01_ztime-validity-substitution-bridge.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/context/workflows/tasks.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Land the two-step bridge from ℤ-time validity of an L formula to TM⁺ theoremhood of every
`substPlus` instance of it, plus the box-free corollary that linear validity over bi-infinite
Z-words yields the same TM⁺ theorems. Both proof bodies are already compiled sorry-free at axiom
profile `[propext, Classical.choice, Quot.sound]`, so the work is transcription, siting, and
generated-surface bookkeeping rather than discovery. The bridge is sited in a new Metalogic-root
module, **not** in `FormalSystem/PlusLanguage/Substitution.lean` as the task description names,
because that siting fails a compiled gate; `Substitution.lean` is left untouched and supplies
`plusDerivable_substPlus_nil` unchanged. Definition of done: five declarations landed and
axiom-pinned, the two library roots and three generated/ledger surfaces reconciled, and the
repository's own gate battery green on every file this task touches.

### Research Integration

Four findings from the research report drive this plan's structure:

1. **The task description's named home is gate-blocked, measured.**
   `FormalSystem/PlusLanguage/Substitution.lean` is layer 0 in `LANGUAGE_FILE_LAYERS`
   (`scripts/measure-refactor-partitions.py`). Adding `import FormalSystem.Metalogic.StrongCompleteness`
   there fails `scripts/check-metalogic-cycles.sh` Assertion B (exit 1); adding
   `import FormalSystem.Semantics.Validity` fails Assertions B and C (exit 1). Baseline is exit 0.
   The plan therefore sites the bridge at `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean`,
   whose four-import set was measured at exit 0.
2. **Both headline statements are already proved.** The report carries verbatim compiled bodies for
   all five declarations. This plan pins their signatures under `## Lean Challenge Statements`
   below (re-compiled this dispatch — see Decisions) and the implementation transcribes the bodies
   from the report's Recommendation 4.
3. **The linear fragment already exists in the tree.** `IntStructure` (a valuation `Atom → Set ℤ`,
   i.e. a bi-infinite Z-word) and `IntTruth` live in
   `FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean`; `isBoxFree` lives one file up in
   `Separation/SemanticBridge.lean`. Relocating `isBoxFree` down into `Defs.lean` is what lets the
   bridge import `Separation.Defs` instead of `Separation.SemanticBridge`, keeping
   `Expressiveness.Table` and `Expressiveness.MonadicFO` out of its closure. No `IntTruth` ↔
   `TruthAt` bridge existed anywhere; the new truth lemma is the first.
4. **New-module bookkeeping is the plan's real bulk.** C6 reachability, C33 library-root
   regeneration, the copyright header, two module-inventory blocks, the `typst/generated/status.typ`
   line-count surface, `docs/theorem-index.md` rows under C15, and the C14 axiom pins are each
   explicit phase work here rather than a wrap-up afterthought.

### Prior Plan Reference

No prior plan. This is plan round 01 for this task.

### Roadmap Alignment

`roadmap_path` was not supplied in this dispatch's delegation context, but `specs/ROADMAP.md`
was consulted on a specific question raised by the task description (below) and bears directly on
this plan:

- `specs/ROADMAP.md` names this task as **item 9 of 879's ingredient table — "the linear bridge"**
  — one of the last two compiled ingredients of that table, alongside 899's cut product lemma, and
  places it in its own sanctioned dispatch line. Landing this bridge closes item 9 and, with 899
  already `[COMPLETED]`, closes the compiled remainder of that table.
- The roadmap also records that 900 is "edged behind 899 on `docs/theorem-index.md`" — the shared
  ledger file is why the two were ordered. 899 is `[COMPLETED]`, so that ordering constraint is
  already discharged and no live territory conflict remains on that file.
- **The §§7–15 ruling is adjacent but does not bar this work**, and the distinction is load-bearing
  enough to be a Decision below rather than a passing remark. The roadmap carries a standing ruling
  barring a Lean formalization of any part of Reynolds 2001 §§7–15, enumerating what stays a paper
  proof: the two-sided chronicle, ban preservation, lulls and hue scheduling, universal
  non-acceptance, the two-sided truth lemma, and the final-frame assembly. None of this plan's five
  declarations is any of those, none mentions a Reynolds object in its statement, and the same
  roadmap sanctions this task by number as the linear bridge. See Decisions.

## Goals & Non-Goals

**Goals**:

- `wordOf` -- the bi-infinite Z-word read off a model and a world history over the carrier ℤ.
- `truthAt_iff_intTruth_of_boxFree` -- box-free task-frame truth is a datum of that Z-word alone.
- `validZTime_of_boxFree_intTruth` -- a box-free formula true on every bi-infinite Z-word is
  ℤ-time valid.
- `plusDerivable_substPlus_of_validZTime` -- the bridge: a ℤ-time-valid L formula yields a TM⁺
  theorem at every substitution.
- `plusDerivable_substPlus_of_boxFree_intTruth` -- the corollary: linear validity over bi-infinite
  Z-words yields TM⁺ theorems at every substitution.
- Every generated surface and ledger row the new module obliges lands in this same task: the
  generated library root, the convenience re-export aggregator, the two module-inventory blocks,
  the typst line-count surface, the axiom pins, and the per-theorem ledger rows.

**Non-Goals**:

- Editing FormalSystem/PlusLanguage/Substitution.lean. Its existing transfer theorem is exactly
  the half the bridge consumes and needs no change; the siting it names fails a compiled gate.
- Formalizing any part of the Reynolds engine's sections 7 through 15 -- the two-sided chronicle,
  ban preservation, lulls and hue scheduling, universal non-acceptance, the two-sided truth lemma,
  and the final-frame assembly all stay a paper proof under a standing ruling. This bridge is the
  generic import route those arguments would consume, not any of them.
- Adding an omega-word (one-sided, future-only) linear semantics. None exists in this tree and none
  should be added for this purpose; the bridge runs over the existing two-sided semantics.
- Weakening or discharging the box-free hypothesis. It is load-bearing, not cosmetic (see Risks).
- Repairing the stale directory-wide invariant sentence in Substitution.lean's own module
  docstring. The research flagged it as a source-comment defect, but it belongs to a file this
  plan deliberately leaves untouched.
- Correcting any pre-existing red finding in a repo-wide gate that names a file outside this
  task's own touched set.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `IntTruth`'s `box _ => True` arm is a deliberately degenerate semantics, so the `isBoxFree` hypothesis on `validZTime_of_boxFree_intTruth` is load-bearing: without it the statement is false (`IntTruth W t (□⊥→⊥)` holds on every word while `□⊥→⊥` is not ℤ-time valid) | H | L | Signature pinned verbatim under `## Lean Challenge Statements`; `rules/plan-compliance.md`'s Statement Fidelity makes a same-named weaker restatement a blocker, not a deviation; one docstring sentence must say the hypothesis may never be weakened, defaulted, or discharged by a `simp` lemma |
| The pre-commit hook (`.githooks/pre-commit`) blocks any commit staging a `.lean` path while `typst/generated/status.typ` has drifted — it is blocking, not auto-regenerating | M | H | Both Lean-touching phases carry `typst/generated/status.typ` in their own file scope and run the regeneration in the same phase, never deferred to the reconciliation phase |
| A repo-wide gate (`check-module-invariants.sh`, `check-metalogic-cycles.sh`) reports a red finding that is pre-existing and unrelated to this task | M | M | Every gate criterion below is stated as a touched-files scope or a baseline delta, never an absolute exit 0; a gate whose only failures name out-of-scope files is a recorded PASS with those findings enumerated |
| `import FormalSystem.Metalogic.StrongCompleteness` makes the bridge a heavy closure that every future consumer inherits | L | H | Keep the module small and single-purpose so a later split into a light `derivable_of_validZTime` core plus a `completeness_ztime`-named alias stays cheap; recorded as a Decision, not an oversight |
| Adding the module to `FormalSystem/Metalogic.lean` was not among the research's three measured gate probes | M | L | Phase 2 re-runs `check-metalogic-cycles.sh` after that edit; its Scope Hypothesis names the unmeasured edit explicitly |
| A `docs/theorem-index.md` row whose Axioms cell reads `pinned:C14` while the C14 baseline does not actually assert it would be a dishonest ledger row that no check catches | M | M | Phase 3 orders the work pin-first, row-second, and verifies by a `check-module-invariants.sh` run that names each new declaration in C14's own PASS note |
| A sibling task is dispatched this same cycle on this shared working tree | L | M | Sibling's declared scope is two `specs/**` files, disjoint from everything here; re-read `FormalSystem.lean` immediately before regenerating it; stage explicit file lists only, never a directory or glob add; never run `git-snapshot.sh` in its reverting default mode |
| The Reynolds markdown extraction's formula OCR is unreliable | L | M | The docstring's load-bearing use of the source is structural (which step supplies theoremhood), not formula-level; any later step needing Claim 1's formula verbatim reads the PDF |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
reads a state the previous one produces.

### Phase 1: Relocate `isBoxFree` into `Separation/Defs.lean` [NOT STARTED]

**Goal**: `isBoxFree` is declared in `Separation/Defs.lean` instead of `Separation/SemanticBridge.lean`,
with no signature change and no call-site edit, so the bridge module can import the light
`Separation.Defs` rather than the heavy `Separation.SemanticBridge`.

**Tasks**:

- [ ] Re-read both Separation files immediately before editing (a sibling task is live on this tree).
- [ ] Move the `/-! ## Box-Free Formulas -/` section marker and the `def isBoxFree : Formula → Bool`
      declaration, with its doc comment, verbatim out of `SemanticBridge.lean` and into
      `Defs.lean`. Place it after `IntTruth` and before the purity predicates. Do not change the
      signature, the arm order, the name, or the doc comment text.
- [ ] Confirm no `import` line needs to be added to `Defs.lean`: it already imports
      `FormalSystem.Syntax.Formula`, which is all `isBoxFree` needs.
- [ ] Confirm `SemanticBridge.lean`'s own `isBoxFree` call sites still resolve with no edit —
      it imports `Separation.Defs` and both files share the namespace
      `FormalSystem.Metalogic.Expressiveness.Separation`.
- [ ] Update the one prose cross-reference that names `isBoxFree`'s old home: the `##
      box/stab-freeness` subsection of `FormalSystem/PlusLanguage/Subformulas.lean`'s module
      docstring says `isBoxFree` is "in `Metalogic/Expressiveness/Separation/SemanticBridge.lean`".
      Change the named file to `Defs.lean`; change nothing else in that paragraph. If the sentence
      is not found at implementation time (a sibling or a later edit having already moved it),
      re-grep `FormalSystem/` for `isBoxFree` outside the two Separation files and repair whatever
      prose reference the grep returns instead, recording the substitution in the phase notes —
      do not skip the step and do not invent a target.
- [ ] Verify the move by the guarded build in Verification below.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`. A pure relocation should leave every
      tree total unchanged; if it reports drift, run `bash scripts/typst-sync-check.sh --fix` and
      stage `typst/generated/status.typ` in this same phase's commit.
- [ ] Commit the phase as one atomic change (see Commit Mode).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: exactly one prose cross-reference to `isBoxFree`'s declaring file exists
outside the two Separation files (`FormalSystem/PlusLanguage/Subformulas.lean`, in the
`box`/`stab`-freeness subsection of its module docstring), and exactly one Lean module imports
`Separation.SemanticBridge` (`Separation/KampTranslation.lean`). Both figures are carried from a
`grep -rn isBoxFree` / `grep -rln "import …Separation.SemanticBridge"` sweep re-run during this
plan's authoring, not from the research report. Confirm at implementation time by re-running both
greps over `FormalSystem/` and `Tests/` before editing, and widen the phase's file list if either
returns more than the figure above.

**Tier Justification**: `suite_selection_select` over this phase's `Files to modify` paths returns
`__FULL_SWEEP__` (no agent-system suite maps any of them), so the covering check is the
repository-specific unmappable criterion run directly — a guarded `lake build` of
`…Separation.Defs`, `…Separation.SemanticBridge` and `…Separation.KampTranslation`, which is the
complete enumerated set of modules that resolve `isBoxFree`.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean` - receives the `isBoxFree` section marker and declaration verbatim
- `FormalSystem/Metalogic/Expressiveness/Separation/SemanticBridge.lean` - loses them; call sites unchanged (exists; confirmed at authoring time)
- `FormalSystem/PlusLanguage/Subformulas.lean` - the one prose cross-reference naming the old declaring file (exists at authoring time; fallback step above covers its absence)
- `typst/generated/status.typ` - conditional: regenerated only if `--counts-only` reports drift

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.Separation.KampTranslation`
  succeeds. Building the one direct dependent elaborates `Defs` and `SemanticBridge` on the way,
  covering all three modules in one invocation.
- `grep -c "def isBoxFree" FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean` is 1 and the
  same grep against `SemanticBridge.lean` is 0.
- `grep -rn "SemanticBridge" FormalSystem/PlusLanguage/Subformulas.lean` returns nothing.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 (after the conditional `--fix`, if one
  was needed).

---

### Phase 2: Land `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` [NOT STARTED]

**Goal**: all five declarations exist, compile sorry-free, and are reachable from the library root;
the import-graph gate and the commit-blocking line-count surface are both green in this same phase.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` with the five-line Apache
      copyright header this tree uses verbatim (copy the block from
      `Separation/Defs.lean`), then the four imports, in this order and no others:
      `FormalSystem.Metalogic.StrongCompleteness`, `FormalSystem.PlusLanguage.Substitution`,
      `FormalSystem.Semantics.IntTransfer`,
      `FormalSystem.Metalogic.Expressiveness.Separation.Defs`.
- [ ] Write the module docstring as the first command after the imports (the header linter requires
      this ordering). It must state, in its own prose: what the two-step bridge is; that the
      box-free hypothesis is load-bearing because `IntTruth`'s `box` arm is deliberately degenerate,
      and may never be weakened, defaulted, or discharged by a `simp` lemma; and the ω-word /
      Z-word asymmetry — Reynolds' `⊢_L` is PLTL over one-sided ω-sequences with `G`/`X`, whereas
      this bridge runs `completeness_ztime` over two-sided bi-infinite Z-words with `U` and `S`,
      which is the whole point of the two-sided transposition. Do **not** describe the module as
      "the PLTL bridge". Cite `reynolds2001` (the BibKey in `references.bib`), Lemma 7 Claim 1,
      p. 1030. State in one sentence that the module is not a formalization of any part of that
      paper's §§7–15. Reference no task number anywhere in the file.
- [ ] Open `namespace FormalSystem.Metalogic` and the five namespaces the pinned block below uses.
- [ ] Transcribe the five declarations with the bodies recorded verbatim in the research report's
      Recommendation 4, in the report's order: `wordOf`, `truthAt_iff_intTruth_of_boxFree`,
      `validZTime_of_boxFree_intTruth`, `plusDerivable_substPlus_of_validZTime`,
      `plusDerivable_substPlus_of_boxFree_intTruth`. Their signatures must match
      `## Lean Challenge Statements` below character-for-character modulo whitespace. Note the arm
      order in `isBoxFree`: its `untl`/`snce` arms read `isBoxFree φ && isBoxFree ψ`, the *second*
      constructor argument first, which is why `hbf.1` feeds `ih2` and `hbf.2` feeds `ih1`.
- [ ] Give each of the four theorems (and `wordOf`, if the convention covers definitions) a doc
      comment carrying a `Paper: — (reason)` line — the shape C15's second assertion requires for a
      ledger row whose Paper label is `—`. This is cheaper to write now than to retrofit in Phase 3.
- [ ] Build the module scoped and confirm zero diagnostics.
- [ ] Re-read `FormalSystem.lean` immediately before regenerating it (sibling task live), then
      regenerate the library root:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- exe mk_all --lib FormalSystem`.
      If the guard refuses a non-`build` subcommand, fall back to `lake exe mk_all --lib FormalSystem`
      and note the bypass. Confirm the diff is exactly one added `import` line.
- [ ] Add `import FormalSystem.Metalogic.ZTimeSubstitutionBridge` to `FormalSystem/Metalogic.lean`,
      beside the `ZTimeProvability` and `AuxiliaryAtoms` lines. Add **no** prose bullet to that
      file's module docstring (see Decisions: a SORRY-FREE bullet there would create a second,
      independent C14 obligation and is a C18 duplication source).
- [ ] Run `bash scripts/check-metalogic-cycles.sh` and confirm all three assertions PASS, exit 0.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; on the expected drift (one new file,
      ~120 new lines) run `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` in this same phase's commit. This surface is enforced by
      `.githooks/pre-commit` and cannot be deferred to Phase 3.
- [ ] Run `bash scripts/check-copyright-headers.sh --strict FormalSystem` (or the invocation its
      `--help` documents) and confirm the new file passes.
- [ ] Commit the phase as one atomic change (see Commit Mode).

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: the new module is roughly 120 lines (proof bodies plus docstring), its
four-import set passes `check-metalogic-cycles.sh` at exit 0, and the `FormalSystem.lean` diff is
exactly one added line. The ~120-line figure and the four-import gate result are carried from the
research report's Effort line and Recommendation 1 respectively, not re-derived here; the
`FormalSystem/Metalogic.lean` import edit was **not** among the research's three measured probes.
Confirm at implementation time by `wc -l` on the new file, by the gate run this phase already
schedules (run it *after* the `Metalogic.lean` edit, not before), and by `git diff --stat
FormalSystem.lean`. If the gate reports a surplus upward edge, extend the allowlist in
`scripts/check-metalogic-cycles.sh` in this same phase and add that script to the phase's file list
— per the equality-not-containment mechanism of its Assertion B, a correct import can still
produce surplus.

**Files to modify**:

- `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` - new module: copyright header, four imports, docstring, five declarations
- `FormalSystem.lean` - regenerated library root; exactly one added import line (C6 reachability, C33)
- `FormalSystem/Metalogic.lean` - one added convenience re-export import line, no docstring change
- `typst/generated/status.typ` - regenerated line-count surface; commit-blocking, so same phase

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.ZTimeSubstitutionBridge`
  succeeds with zero diagnostics — no error, no warning, no `declaration uses 'sorry'`. CI builds
  with `--wfail`, so a warning is a failure here too.
- `lean_verify` (or `#print axioms`) on `FormalSystem.Metalogic.plusDerivable_substPlus_of_validZTime`
  and `…plusDerivable_substPlus_of_boxFree_intTruth` reports exactly
  `[propext, Classical.choice, Quot.sound]` and no `sorryAx`.
- `bash scripts/check-metalogic-cycles.sh` exits 0 with all three assertions PASS, run after the
  `FormalSystem/Metalogic.lean` edit.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `bash scripts/check-copyright-headers.sh` reports the new file as conforming.
- This phase declares the `full` tier. Because the repository's own gate battery — not the
  agent-system deploy aggregator — is what covers Lean library correctness here, the gates named
  above plus Phase 4's complete battery are the `full` set this phase and the final phase between
  them discharge. No path under `.claude/**` or an extension source store is in this task's scope,
  so `bash .claude/scripts/verify-deploy.sh` has nothing of this task's to check; it runs once in
  Phase 4 as a baseline-delta observation only.

---

### Phase 3: Reconcile the ledger and the generated surfaces [NOT STARTED]

**Goal**: the new declarations are axiom-pinned by the C14 baseline, carry their per-theorem ledger
rows, and the two module-inventory blocks are regenerated with a real description.

**Tasks**:

- [ ] Add matched C14 pairs for the declarations that will carry a `pinned:C14` ledger cell. Each
      pair is two edits to `scripts/check-module-invariants.sh`: a `#print axioms <fully qualified
      name>` line in the `C14LEAN` probe-source heredoc, and the corresponding
      `'<name>' depends on axioms: [propext, Classical.choice, Quot.sound]` line in the
      `C14_BASELINE` heredoc. The two heredocs are compared by exact string equality, so the
      ordering of the added lines must correspond. Both heredocs exist in that script at authoring
      time; if either is absent or restructured at implementation time, stop and record it rather
      than inventing a pin location.
- [ ] Run `bash scripts/check-module-invariants.sh` and confirm C14 passes with each new
      declaration named in its own PASS note. Do this **before** writing any ledger row, so no row
      claims a pin that does not exist.
- [ ] Add one `docs/theorem-index.md` row per pinned declaration: Paper label `—`, Statement one
      line, Lean name fully qualified, File the path with no line number, Frame class `ZTime` for
      the two `PlusDerivable` results and `validZTime_of_boxFree_intTruth`, `—` for
      `truthAt_iff_intTruth_of_boxFree` (it is stated at a frame, not a frame class), Axioms
      `pcq pinned:C14`.
- [ ] Confirm each new row's declaration site carries a `Paper: — (reason)` line in its own `/--`
      doc comment — C15's second assertion requires exactly that shape for a `—` label. If Phase 2
      already wrote them, this is a read-only confirmation.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate the registered
      inventory blocks in `README.md` (`dir=FormalSystem rows=totals`) and
      `FormalSystem/Metalogic/README.md` (`dir=FormalSystem/Metalogic rows=loose
      filter=non-aggregators`).
- [ ] Replace the `<!-- TODO: add description -->` cell the regeneration inserts for the new module's
      inventory row with a one-line description. Keep it distinct in wording from the module
      docstring's own sentences: C18 reports duplicated sentences across `README.md`,
      `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and `FormalSystem/Metalogic.lean`.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory --check` and confirm a rewrite
      would change no byte.
- [ ] Commit each green sub-step as it lands (see Commit Mode).

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: four declarations warrant a `pinned:C14` ledger row and a C14 matched pair —
the three theorems plus `wordOf` if `docs/theorem-index.md`'s own convention covers definitions
(the page carries rows for type declarations, so it is not theorem-only). This figure is carried
from the research report's Recommendation 6, which wrote "four rows (one per landed theorem, plus
`wordOf` if the convention covers definitions)" without settling the `wordOf` question. Confirm at
implementation time by reading the page's "How to read a row" table and its existing non-theorem
rows, and record the count actually landed; a row count of three or five is a correct outcome, not
a deviation, provided every row that reads `pinned:C14` is in fact pinned.

**Tier Justification**: `suite_selection_select` over this phase's `Files to modify` paths returns
`__FULL_SWEEP__` (no agent-system suite maps any of them), so the covering check is the
repository-specific unmappable criterion run directly — one `bash scripts/check-module-invariants.sh`
run plus one `--emit-inventory --check` run, which together are the only consumers of every surface
this phase edits.

**Files to modify**:

- `scripts/check-module-invariants.sh` - C14 matched pairs: one `#print axioms` line per declaration in the `C14LEAN` heredoc, one expected-output line per declaration in the `C14_BASELINE` heredoc (both heredocs exist; confirmed at authoring time)
- `docs/theorem-index.md` - new rows, one per pinned declaration (exists; confirmed at authoring time)
- `README.md` - regenerated `dir=FormalSystem rows=totals` inventory block (file and line totals)
- `FormalSystem/Metalogic/README.md` - regenerated non-aggregator inventory row plus its hand-written description cell

**Verification**:

- `bash scripts/check-module-invariants.sh` reports C14 PASS, with each newly pinned declaration
  appearing in C14's own PASS note, and C15's second assertion PASS ("all N theorem-index row(s)
  carry their anchor (or `Paper: —`) at the declaration").
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `grep -c "TODO: add description" FormalSystem/Metalogic/README.md` is 0 for the new module's row.
- Every finding either gate reports that names a file outside this task's touched set is recorded
  as pre-existing, enumerated in the phase notes, and left unrepaired — these criteria are a
  touched-files scope, not an absolute repo-wide zero.

---

### Phase 4: Final verification [NOT STARTED]

**Goal**: the repository's complete gate battery is green on every file this task touched, with any
remaining red finding demonstrably pre-existing and out of scope.

**Tasks**:

- [ ] Run the full guarded project build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. Detach as a
      shell-level background job and block on it with the bounded single-call idiom if it does not
      plausibly fit one foreground call.
- [ ] Run `bash scripts/check-module-invariants.sh` in full (not `--no-build`) and read C6, C14,
      C15, C26, the inventory assertion, and the `FAIL INV` class specifically.
- [ ] Run `bash scripts/check-metalogic-cycles.sh` and confirm exit 0.
- [ ] Run `bash scripts/typst-sync-check.sh` in full and confirm Check 2 is green.
- [ ] Run `bash scripts/check-copyright-headers.sh` over the Lean scope.
- [ ] Run `bash .claude/scripts/verify-deploy.sh` once, read its findings as a baseline delta
      against the pre-task commit rather than as an absolute pass, and record that no path under
      `.claude/**` or an extension source store is in this task's scope — so any finding it reports
      is by construction pre-existing and not this task's to repair.
- [ ] Re-confirm the two headline axiom profiles by `lean_verify` on the fully qualified names.
- [ ] Confirm `grep -rn "sorry" FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` returns
      nothing, and that no `def X := True`-class vacuous declaration was introduced.
- [ ] Enumerate, in the phase notes, every gate finding that names a file outside this task's
      touched set, with the evidence that each touched file passes individually.
- [ ] Commit the phase.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:

- `typst/generated/status.typ` - conditional: re-regenerated only if the full `typst-sync-check.sh` reports residual drift
- `README.md` - conditional: re-regenerated only if `--emit-inventory --check` reports residual drift

**Verification**:

- The complete gate set for this repository is green on this task's touched files: the full guarded
  `lake build`; `bash scripts/check-module-invariants.sh` (C6, C14, C15, C26, inventory, `FAIL INV`);
  `bash scripts/check-metalogic-cycles.sh` (Assertions A, B, C, exit 0);
  `bash scripts/typst-sync-check.sh` (Check 2); `bash scripts/check-copyright-headers.sh`; and
  `bash .claude/scripts/verify-deploy.sh` read as a baseline delta.
- `lean_verify` on `FormalSystem.Metalogic.plusDerivable_substPlus_of_validZTime` and
  `FormalSystem.Metalogic.plusDerivable_substPlus_of_boxFree_intTruth` reports
  `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.
- The sorry inventory for this task is empty, as recorded in the research report: there are no
  strategic sorries, no `[BLOCKED]` phase, and no deferred proof obligation.
- Every red finding that remains is named, attributed to a file outside this task's touched set,
  and shown pre-existing against the pre-task commit.

## Lean Challenge Statements

The identifier set below is exactly the set named under `- **Goals**:` above: `wordOf`,
`truthAt_iff_intTruth_of_boxFree`, `validZTime_of_boxFree_intTruth`,
`plusDerivable_substPlus_of_validZTime`, `plusDerivable_substPlus_of_boxFree_intTruth`.

The import set in this block is chosen so the block type-checks standalone **both before and after
Phase 1's relocation**: it imports `Separation.SemanticBridge`, which resolves `isBoxFree` today
and continues to resolve it after the relocation (`SemanticBridge` imports `Separation.Defs`). It
is deliberately *not* the landed module's four-import set, which Phase 2 pins separately and which
reaches `Separation.Defs` directly.

```lean
import FormalSystem.Metalogic.StrongCompleteness
import FormalSystem.PlusLanguage.Substitution
import FormalSystem.Semantics.IntTransfer
import FormalSystem.Metalogic.Expressiveness.Separation.SemanticBridge

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.Metalogic.Expressiveness.Separation

def wordOf {F : FrameOver intOrder} [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) : IntStructure := sorry

theorem truthAt_iff_intTruth_of_boxFree {F : FrameOver intOrder} [F.IsRegular]
    (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) :
    ∀ (φ : Formula), isBoxFree φ = true → ∀ t : ℤ,
      (TruthAt M τ t φ ↔ IntTruth (wordOf M τ) t φ) := sorry

theorem validZTime_of_boxFree_intTruth {φ : Formula} (hbf : isBoxFree φ = true)
    (h : ∀ (W : IntStructure) (t : ℤ), IntTruth W t φ) : ValidZTime φ := sorry

theorem plusDerivable_substPlus_of_validZTime {φ : Formula} (σ : Atom → PlusFormula)
    (h : ValidZTime φ) : PlusDerivable FrameClass.ZTime [] (substPlus σ φ) := sorry

theorem plusDerivable_substPlus_of_boxFree_intTruth {φ : Formula} (σ : Atom → PlusFormula)
    (hbf : isBoxFree φ = true) (h : ∀ (W : IntStructure) (t : ℤ), IntTruth W t φ) :
    PlusDerivable FrameClass.ZTime [] (substPlus σ φ) := sorry

end FormalSystem.Metalogic
```

## Decisions

- **Host module.** A new Metalogic-root file, not an append to `ZTimeProvability.lean` or
  `AuxiliaryAtoms.lean`. `ZTimeProvability.lean` is tightly scoped to decidability and pulls the
  whole `Decidability/WitnessFamily/Compression/Assembly` closure the bridge does not need;
  `AuxiliaryAtoms.lean` is 903 lines of soundness machinery for one rule. Both were checked for
  import weight during research; neither is a better fit than a fresh small module, and the gate
  accepts the fresh module at exit 0.
- **Completeness engine.** `completeness_ztime` (from `Metalogic.StrongCompleteness`), as the task
  description names, rather than the more primitive `BXCanonical.derivable_of_validZTime`. The gate
  accepts both (both measured exit 0), so description fidelity decides. Recorded as a deliberate
  choice: `derivable_of_validZTime` would shrink the import closure slightly and a future task may
  revisit it on that ground, but it is a different declaration from the one the task names.
- **Linear semantics.** Reuse the existing `IntStructure`/`IntTruth` pair rather than defining a
  fresh Z-word semantics inside the bridge. One linear semantics in the tree, and reuse keeps the
  door open to composing existing Separation results with the bridge. The cost is the dependency on
  `IntTruth`'s degenerate `box` arm, which is why the `isBoxFree` hypothesis is load-bearing (Risks).
- **`isBoxFree` is relocated, not duplicated.** Duplicating a syntactic predicate that already
  exists would create two names for one concept and invite drift.
- **No SORRY-FREE prose bullet is added to `FormalSystem/Metalogic.lean`'s module docstring.** That
  docstring's SORRY-FREE claim set is itself a C14 obligation — every declaration it calls
  SORRY-FREE must be pinned in the C14 baseline — and it is one of the four surfaces C18 scans for
  duplicated prose. The import line alone gives the convenience re-export; the per-theorem claim
  lives in `docs/theorem-index.md`, which is the repository's single per-theorem ledger.
- **The §§7–15 ruling does not bar this task, and the reasoning is recorded rather than escalated.**
  The task description cites Reynolds 2001 Lemma 7 Claims 1–2, Lemma 17 and Lemma 23, which sits
  inside the span a standing roadmap ruling keeps out of Lean. Two facts settle it without a user
  decision: (i) the ruling enumerates what stays a paper proof — the two-sided chronicle, ban
  preservation, lulls and hue scheduling, universal non-acceptance, the two-sided truth lemma, and
  the final-frame assembly — and none of this plan's five declarations is any of them, nor mentions
  a Reynolds object in its statement; they are repository-general facts about this tree's own TM and
  TM⁺ systems and its own two semantics. (ii) The same roadmap names this task by number as item 9
  of 879's ingredient table, "the linear bridge", and places it in its own sanctioned dispatch line.
  The bridge is the generic import route a paper argument of that shape would consume, not a
  formalization of the argument. The mitigation that keeps this true is in the plan rather than
  only in this note: the Non-Goals name the six components explicitly, and Phase 2 requires the
  module docstring to disclaim being a formalization of any part of §§7–15.
- **Pinned statements were re-compiled during this plan's authoring, not carried on trust.** The
  `## Lean Challenge Statements` block above was run through a standalone compile this dispatch:
  it type-checks with exactly five `declaration uses 'sorry'` warnings and no other diagnostic. One
  carried figure was corrected in the process: the research report describes `ValidZTime` as "a
  plain abbreviation", whereas it is a `def` (`FormalSystem/Semantics/Validity.lean`). The
  consequence is nil — `completeness_ztime φ h` still applies to a `ValidZTime` hypothesis by
  definitional unfolding, which both the research probes and this dispatch's compile confirm — but
  the plan records the correction rather than repeating the report's wording.

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` succeeds for the
      whole project.
- [ ] Zero diagnostics on `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` — no error, no
      warning, no `sorry` (CI builds with `--wfail`, so a warning is a failure).
- [ ] `lean_verify` reports `[propext, Classical.choice, Quot.sound]` and no `sorryAx` for both
      headline theorems.
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0, all three assertions PASS.
- [ ] `bash scripts/check-module-invariants.sh` reports C6, C14, C15 and the inventory assertion
      green for every file this task touched.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `bash scripts/typst-sync-check.sh` Check 2 is green, and every `.lean`-touching commit was
      made with that surface already regenerated.
- [ ] `bash scripts/check-copyright-headers.sh` passes for the new module.
- [ ] The declared signatures match `## Lean Challenge Statements` character-for-character modulo
      whitespace; no hypothesis added, no quantifier specialised, no same-named weaker restatement.
- [ ] Every remaining red gate finding is enumerated and attributed to a file outside this task's
      touched set.

## Artifacts & Outputs

- `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` — new module, five declarations, sorry-free.
- `FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean` — now declares `isBoxFree`.
- `FormalSystem/Metalogic/Expressiveness/Separation/SemanticBridge.lean` — no longer declares it.
- `FormalSystem/PlusLanguage/Subformulas.lean` — one corrected prose cross-reference.
- `FormalSystem.lean` — regenerated library root with one added import.
- `FormalSystem/Metalogic.lean` — one added convenience re-export import.
- `scripts/check-module-invariants.sh` — C14 matched pairs for the new declarations.
- `docs/theorem-index.md` — new per-theorem ledger rows.
- `README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks plus one new
  description cell.
- `typst/generated/status.typ` — regenerated line-count surface.
- `specs/900_linear_ztime_validity_tm_plus_substitution_bridge/summaries/01_*-summary.md` — the
  completion summary.

## Rollback/Contingency

Every change here is additive or a pure relocation, so rollback is bounded and does not touch any
landed result.

- **Per-phase.** Each phase is one commit (Phase 3 is several green sub-step commits), so reverting
  a phase is reverting its commits. No phase leaves a half-applied state behind: Phases 1 and 2 are
  pre-declared `atomic-batch` objectives precisely so their intermediate red states are never
  committed.
- **Whole task.** Delete `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean`, re-run
  `lake exe mk_all --lib FormalSystem`, drop the `FormalSystem/Metalogic.lean` import line, revert
  the C14 heredoc pairs and the `docs/theorem-index.md` rows, re-run
  `check-module-invariants.sh --emit-inventory` and `typst-sync-check.sh --fix`, and move
  `isBoxFree` back into `SemanticBridge.lean` with its one prose cross-reference. Nothing else in
  the tree depends on any of it.
- **If a rollback must discard uncommitted work**, take the snapshot first — see
  `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
  including its out-of-scope override flag for the deliberate whole-tree case. Do not emit the
  bare reverting form as a routine start-of-phase checkpoint; an ordinary defensive checkpoint uses
  `--no-revert`.
- **If Phase 2's gate run reports a surplus upward import edge**, the contingency is in-scope, not a
  rollback: extend the allowlist in `scripts/check-metalogic-cycles.sh` in that same phase and add
  the script to the phase's file list, per its Assertion B's equality-not-containment mechanism.
- **If a declaration cannot be landed as pinned**, mark the phase `[BLOCKED]` with what was tried
  and the goal state reached. Do not substitute a vacuous placeholder, a `sorry`, or a same-named
  weaker statement — `rules/plan-compliance.md`'s Statement Fidelity makes the last of those a
  blocker rather than a sanctioned deviation.
