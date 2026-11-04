# Implementation Plan: Task #854

- **Task**: 854 - Land the positive open-future elimination result as a library module
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md`; `specs/854_open_future_modal_lplus_definability/probes/01_ofut-elimination-and-translation.lean` (341 lines, compiled-live, sorry-free)
- **Artifacts**: plans/01_open-future-elimination-module.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research verdict is settled and must not be reopened: the open-future modal `▷` is
L⁺-definable at `.ZTime` and `.RTime`, by Gabbay separation plus the elimination of a disjunction
under the modal. The Lean half of that verdict is already machine-checked in probe 01; this task
moves it out of a disposable task directory and into the library as
`FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`, so the result survives
archival. Everything else in the plan is the ledger work a new library module owes: an aggregator
import, a directory-README row, theorem-index rows stating the **conditional** form honestly, and
a re-measured C14 axiom baseline.

The work is transcription plus ledger discipline, not proof development: the probe's proofs are
carried over unweakened, and the only Lean-level changes are namespacing, docstrings that satisfy
C15's `Paper:` round trip, and the removal of one genuinely unused instance binder that would
otherwise be a new, gated C16 `unusedArguments` finding.

### Research Integration

Findings carried directly into the plan:

- **F1/F2** supply the exact declaration set to land: the determinedness predicates
  (`PastDet`, `FutDet`) with their syntactic bridges, the `▷`/`◁` readings at the L⁺ level
  (`OfutP`, `OpastP`), the single-clause eliminations, their CNF forms, the separation hypothesis
  `SeparationOver`, the translation `tr`, and the two class-validity instances.
- **F3** is why the module must keep the **semantic** `PastDet`/`FutDet` and must not be
  "simplified" onto `IsPurePast`/`IsPureFuture`: the Dedekind-complete separated forms are
  future-determined without being syntactically pure, so the syntactic version would not serve
  the `.RTime` instantiation. This is a load-bearing design decision, not a stylistic one.
- **F2's axiom reading** fixes what the ledger may claim: `[propext, Classical.choice,
  Quot.sound]` for the eliminations and the translation (choice is forced by the disjunctive
  statement and by choosing a separated form), `[propext, Quot.sound]` for the split-free
  pure-future instance. Every value is re-measured in Phase 2 rather than typed from here.
- **The report's own honesty line** (`SeparationOver` is an explicit named hypothesis standing for
  cited, unformalized literature) is what drives the row discipline in Phase 3 and the docstring
  split in Phase 1: the conditional theorems are rows, the unconditional verdict is docstring
  prose with a GHR citation.
- **R2/R4** are recorded in the module docstring as what is *not* claimed, so a future reader does
  not mistake the conditional landing for a machine-checked unconditional verdict, and knows that
  formalizing GHR 10.2.1-10.2.8 is the route that would remove the hypothesis.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap flag is set, so no roadmap phases
are added. The report's routing decisions (D3) name the consumers this result affects; recording
them in `specs/ROADMAP.md` is a separate concern and is **out of scope** here.

## Goals & Non-Goals

**Goals**:

- Land `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` carrying the probe's
  content as library code: public, documented, sorry-free, no new axiom, no vacuous definition.
- Keep `PastDet`, `FutDet`, `OfutP` and `OpastP` public and documented — the companion
  non-definability task imports this shared vocabulary from here rather than redefining it.
- Make `lake build` compile the module, by adding its import to the Expressiveness aggregator.
- Record the result on the three ledger surfaces it owes: the directory README's module table,
  `docs/theorem-index.md`, and the C14 axiom baseline in `scripts/check-module-invariants.sh`.
- State the conditional form in every pinned row, and confine the unconditional "definable at
  ZTime/RTime" claim to the module docstring, cited to GHR.

**Non-Goals**:

- Re-deriving, re-litigating or hedging the verdict. The research is done.
- Formalizing Gabbay separation (GHR Lemmas 10.2.1-10.2.8). `SeparationOver` stays an explicit
  hypothesis; discharging it is the report's R4 and is a separate, sizeable task.
- Any negative/undefinability result, and any edit under
  `FormalSystem/Metalogic/Independence/` — the companion task owns that directory.
- Editing `scripts/check-metalogic-cycles.sh`'s recorded upward-edge allowlist. The new import is
  a downward edge (Metalogic is layer 3, OpenLanguage layer 0-1) and that script counts only
  upward edges, so the allowlist needs no change and must not be touched.
- Adding anything to `FormalSystem/MainResults.lean`. The headline claim here is conditional on
  unformalized literature; the main-results page is not where that belongs.
- Any completeness or decidability claim for L^▷ or L⁺, in Lean or in prose.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A pinned row reads as the unconditional verdict, overclaiming what is machine-checked | H | M | Every row's Statement cell opens with the conditional ("Given separation over ...", "for `α` past-determined and `β` future-determined"). Phase 3 re-reads all six rows against this test before closing, and Phase 5 re-reads them again |
| The module docstring cites the task's own report or probe path, which `/todo` archival will delete | H | M | C9 (FormalSystem/, README.md, scripts/) and C9D (docs/) both **gate** task-number citations at zero, and `specs/854_...` is exactly that shape. The docstring cites GHR by `references.bib` key and states the paper-level step in its own prose; no `specs/` path appears in any landed file. Phase 1 and Phase 5 both check this explicitly |
| `ofutP_of_pastDet` keeps the probe's `[F.IsRegular]` binder, which its proof does not use, producing a NEW gated C16 `unusedArguments` finding | M | M | Drop the binder in Phase 1. Removing an unused hypothesis **strengthens** the theorem, so it is not a weakening; the statement is otherwise verbatim. Phase 5 asserts the C16 finding list is byte-identical to the one-finding baseline |
| A C15 failure because a rowed declaration has no `Paper:` line at its declaration site | M | M | Every rowed declaration gets a `/-- ... Paper: — (reason) -/` comment in Phase 1, modelled on `openValid_reflectTime` in `OpenReversal.lean`. C15's second assertion is run in Phase 3 and again in Phase 5 |
| The C14 baseline is typed from the report's F2 reading instead of re-measured, and silently diverges | M | L | Phase 2 writes both heredoc halves **from `#print axioms` output**, matched pair by matched pair in the same trailing position, and the dispatch's own instruction ("re-measured, never typed by hand") is restated as a task step. A value that differs from F2's reading is recorded as measured and investigated, not forced |
| Simplifying `PastDet`/`FutDet` away in favour of `IsPurePast`/`IsPureFuture` during transcription | H | L | F3 says why that breaks the `.RTime` instantiation. Both the plan and the module docstring record the reason; `plan-compliance.md` forbids substituting an alternative decomposition on `.lean` files |
| Generated README inventory blocks go stale (the aggregator gains a line, `Expressiveness/` gains a file), failing the gated INV check | M | M | Phase 4 runs `--emit-inventory` and then `--emit-inventory --check`, rather than hand-editing a generated block |
| `check-module-invariants.sh` exits 1 on a pre-existing C16 finding and the nonzero exit is read as this task's failure | M | M | Phase 5 asserts **per-check**, not by exit code, and the pre-existing finding is named in its Scope Hypothesis as a figure to re-derive, not to trust |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: The `OpenFutureElimination` module and its aggregator import [COMPLETED]

**Goal**: Land `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` carrying the
probe's content as namespaced library code with full docstrings, and add its import to
`FormalSystem/Metalogic/Expressiveness.lean` so `lake build` compiles it.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` with the
      repository's standard copyright header (copy the four-line form from
      `FormalSystem/Metalogic/Expressiveness/PriorExpressiveness.lean`), then
      `import FormalSystem.OpenLanguage` as the sole import. That one import is what the probe
      compiled against; it reaches `FormalSystem.Init` transitively through
      `FormalSystem/Semantics/TemporalOrder.lean`, which is what C24 requires.
- [ ] Open `namespace FormalSystem.Metalogic.Expressiveness` and close it with the matching
      `end FormalSystem.Metalogic.Expressiveness`, following `PriorExpressiveness.lean`. Do
      **not** introduce a per-file namespace segment: the two existing headline results in this
      directory sit directly in `...Expressiveness`, and the companion task imports this
      vocabulary by that path.
- [ ] Open the needed namespaces (`FormalSystem.Syntax`, `FormalSystem.Semantics`,
      `FormalSystem.PlusLanguage`, `FormalSystem.OpenLanguage`) and declare
      `variable {F : TaskFrame}`, as the probe does.
- [ ] Transcribe, in the probe's order and with the probe's proofs unchanged: `PastDet`,
      `FutDet`, `pastDet_of_isPurePast`, `futDet_of_isPureFuture`, `OfutP`, `OpastP`,
      `ofutP_iff`, `opastP_iff`, `ofutP_and`, `opastP_and`, `ofutP_top`, `opastP_top`,
      `ofutP_or_iff`, `opastP_or_iff`, `sepForm`, `ofutElim`, `opastElim`, `SepClauses`,
      `ofutP_sepForm_iff`, `opastP_sepForm_iff`, `SeparationOver`, `tr`, `openTruthAt_iff_tr`,
      `openValidOnFrames_iff_tr`, `openValidIn_ztime_iff_tr`, `openValidIn_rtime_iff_tr`,
      `ofutP_of_pastDet`, `ofutP_of_futDet`.
- [ ] **Keep the semantic `PastDet`/`FutDet` exactly as stated.** Do not replace either by
      `PlusFormula.IsPurePast`/`IsPureFuture`, and do not add a purity hypothesis to any
      elimination: the Dedekind-complete separated forms are future-determined without being
      syntactically pure, so a syntactic version does not serve the `.RTime` instantiation at all.
      The two bridge lemmas are the only place the syntactic predicates appear.
- [ ] **Drop the `[F.IsRegular]` instance binder from `ofutP_of_pastDet`.** Its proof uses only
      `agreeUpTo_equivalence` and `PastDet`, so the binder is unused and is a gated C16
      `unusedArguments` candidate. Removing it strengthens the theorem; the statement is otherwise
      verbatim. Every other `[F.IsRegular]` binder stays — `ofutP_or_iff`, `opastP_or_iff`, both
      CNF lemmas, `openTruthAt_iff_tr` and `ofutP_of_futDet` all route through `paste`, which is
      where regularity enters and the only place it enters.
- [ ] Give **every** declaration a `/-- ... -/` doc comment. `docBlame` is inside C16's gated
      batch, so an undocumented public declaration is a new failure; the probe leaves
      `ofutP_iff`, `opastP_iff`, `ofutP_and`, `opastP_and`, `ofutP_top` and `opastP_top`
      undocumented and those six are the ones to write from scratch.
- [ ] Give each of the six declarations that will carry a theorem-index row in Phase 3 —
      `ofutP_or_iff`, `opastP_or_iff`, `ofutP_sepForm_iff`, `opastP_sepForm_iff`,
      `openValidIn_ztime_iff_tr`, `openValidIn_rtime_iff_tr` — a doc comment whose last line is
      `Paper: — (reason)`, modelled on `openValid_reflectTime` in `OpenReversal.lean`. C15's
      second assertion requires the value to start with `— (`; the reason clause is
      formalization-native (the manuscript sets the restricted modals aside and states no
      elimination or translation for them).
- [ ] Write the module docstring (`/-! ... -/`) with these parts, and no others:
      (a) what is proved — the elimination, its CNF form, and the translation conditional on
      `SeparationOver`;
      (b) **the verdict, unconditionally, as prose**: `▷` and `◁` are L⁺-definable at `.ZTime`
      and `.RTime`, by Gabbay's Separation Theorem (GHR vol. 1, Thm 10.2.9 over the integer flow;
      Thm 10.3.20 over Dedekind-complete flows) applied with `□ψ`/`⊡ψ` and atoms as propositional
      leaves — legitimate because each such leaf is a function of the time alone or of the present
      state alone, hence both past- and future-determined;
      (c) **what is not proved here**: the separation hypothesis itself is cited literature, not
      formalized in this tree, so every theorem below it is conditional; the paper-level
      bookkeeping (leaf abstraction, CNF rearrangement, order-isomorphism invariance of U/S
      truth) is UNVERIFIED in Lean;
      (d) **where it does not apply**: the hypothesis is **false** for U/S over `ℚ`, hence over
      the `.Dense` and `.Base` classes, so nothing here transfers there;
      (e) why the determinedness predicates are semantic rather than syntactic (the `.RTime`
      forms are not syntactically pure);
      (f) a `## Main Results` bullet list naming the identifiers, in the style of the existing
      aggregator docstring;
      (g) a `## References` block citing `[gabbay1994]` and `[rabinovich2014]` by their
      `references.bib` keys — confirm both keys exist in `references.bib` before writing them.
- [ ] **No `specs/` path and no task number anywhere in the file.** Do not cite the research
      report or the probe by path: C9 gates task-number citations under `FormalSystem/` at zero,
      and both artifacts are disposable by design once this lands. The docstring must stand on its
      own with the GHR citation.
- [x] Add `import FormalSystem.Metalogic.Expressiveness.OpenFutureElimination` to
      `FormalSystem/Metalogic/Expressiveness.lean`, in the existing import block.
      *(deviation: altered — one additional file, `FormalSystem.lean`, had to be regenerated. The
      plan's six-path scope omits the generated library root, but check C33 asserts
      `FormalSystem.lean` is byte-for-byte the `mk_all --lib FormalSystem` output, one `import`
      line per `.lean` file under `FormalSystem/`. A new module therefore adds a seventh changed
      path by construction. Regenerated with C33's own render algorithm, not hand-inserted; C33
      re-verified green in Phase 5.)*
- [ ] Extend that aggregator's own docstring: add a numbered **Architecture** entry for the new
      module, and one sentence under **Main Exports** stating that the open-future elimination is
      landed **conditional on a named separation hypothesis**. Do not describe it as a headline
      unconditional result beside `kampPriorExpressiveCompleteness`.
- [ ] Run the scoped guarded build and confirm green with no new warnings:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      FormalSystem.Metalogic.Expressiveness`. Never bare `lake`; read the verdict from the guard's
      exit status or its `result` subcommand, never from a pipe's exit code.
- [ ] Confirm zero `sorry` and zero vacuous definitions in the new file: `grep -c sorry` on the
      path returns 0, and no declaration has a `:= True` / `:= trivial` / `:= Unit` body.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: One new file of roughly 380-420 lines carrying 28 declarations (4 `def`
predicates/readings, 3 `def` CNF constructors, 1 `def` hypothesis, 1 `noncomputable def`
translation, 19 theorems), plus one added import line and two docstring edits in the sibling
aggregator; the probe is 341 lines at plan time and the growth is docstrings and namespacing, not
new mathematics. Confirm at implementation time by `wc -l` on the new path, by `lean_verify`
resolving each fully-qualified name under `FormalSystem.Metalogic.Expressiveness`, and by
`git diff --stat` on the aggregator showing a single-digit insertion count and no deletions.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Metalogic.Expressiveness` elaborates the new module together with the one existing
file that imports it, and the phase changes no existing signature — every edit is additive — so
no other module in the tree can break.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` - new module: the
  determinedness predicates, the L⁺-level `▷`/`◁` readings, the eliminations and their CNF forms,
  `SeparationOver`, `tr`, the two class-validity instances, and the two split-free sanity
  instances, all documented
- `FormalSystem/Metalogic/Expressiveness.lean` - one import line; one Architecture entry and one
  Main Exports sentence in the module docstring

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Metalogic.Expressiveness` — exit 0, no new warnings.
- `grep -c sorry FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` returns 0; no
  vacuous-definition body anywhere in the file.
- Every declaration carries a `/-- ... -/` doc comment; the six future-rowed declarations each end
  theirs with a `Paper: — (` line.
- `grep -n 'specs/\|854' FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean
  FormalSystem/Metalogic/Expressiveness.lean` returns nothing.
- `ofutP_of_pastDet` takes no `[F.IsRegular]` binder; every other regularity binder is retained.

---

### Phase 2: Re-measure the axiom profiles and pin the C14 baseline [COMPLETED]

**Goal**: Measure `#print axioms` on each landed declaration against the built library and pin the
measured values as matched heredoc pairs in `scripts/check-module-invariants.sh`, so the module's
axiom profile is asserted on every run rather than claimed in prose.

**Tasks**:

- [ ] Run the unscoped guarded build first, so `import FormalSystem` elaborates for the
      measurement: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
- [ ] **Measure, do not type.** Obtain `#print axioms` output (via `lean_verify` or a
      `lake env lean` snippet importing `FormalSystem`) for each of these eight fully-qualified
      names:
      `FormalSystem.Metalogic.Expressiveness.ofutP_or_iff`,
      `...opastP_or_iff`,
      `...ofutP_sepForm_iff`,
      `...opastP_sepForm_iff`,
      `...openTruthAt_iff_tr`,
      `...openValidIn_ztime_iff_tr`,
      `...openValidIn_rtime_iff_tr`,
      `...ofutP_of_futDet`.
- [ ] Compare the measured values against the research report's F2 reading — `[propext,
      Classical.choice, Quot.sound]` for the eliminations, CNF lemmas and translation, and
      `[propext, Quot.sound]` for the split-free `ofutP_of_futDet`. A divergence is a finding to
      record and investigate, **not** a reason to force either side: record the measured value and
      state the divergence in the handoff.
- [ ] A measured `sorryAx` anywhere is a hard stop: mark the phase `[BLOCKED]` and report. Do not
      pin a baseline containing `sorryAx`.
- [ ] Append the measured lines to `C14_BASELINE` (the `C14BASE` heredoc) as a contiguous block,
      immediately after the four existing `FormalSystem.OpenLanguage.*` lines — the natural
      position, since this block is the L^▷/open-modal neighbourhood of the baseline.
- [ ] Append the matching `#print axioms <name>` lines to the `C14LEAN` heredoc **in the same
      order and the same relative position**. The two heredocs are compared by exact string
      equality, so a position or order mismatch fails even when every value is right.
- [ ] Add a short comment block above the new pair, in the style of the existing per-block
      comments, recording what these declarations pin and — explicitly — what they do **not**:
      they pin axiom profiles of results **conditional on `SeparationOver`**, an explicit
      hypothesis standing for cited literature that is not formalized in this tree. No
      unconditional definability claim is asserted by their presence. Write this comment with no
      task number and no `specs/` path (C9 gates `scripts/` too).
- [ ] Run `bash scripts/check-module-invariants.sh` and confirm the C14 `#print axioms` half
      reports PASS at the new baseline (the first, markdown-scanning half of C14 and the other
      checks are Phase 5's business).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Eight matched pairs of lines (eight in `C14BASE`, eight in `C14LEAN`) plus
one comment block, in the single file `scripts/check-module-invariants.sh`; the baseline currently
carries four `FormalSystem.OpenLanguage.*` lines immediately before the insertion point. Confirm
at implementation time by `grep -c 'Expressiveness.ofutP\|Expressiveness.opastP\|Expressiveness.openTruthAt_iff_tr\|Expressiveness.openValidIn_'`
returning the same count on each side of the pair, and by the C14 half passing.

**Tier Justification**: `bash scripts/check-module-invariants.sh`'s C14 `#print axioms` half
compares the two heredocs against live `#print axioms` output by exact string equality, which is
precisely the edit this phase makes and the only thing it can break.

**Files to modify**:

- `scripts/check-module-invariants.sh` - eight matched lines appended to the `C14BASE` and
  `C14LEAN` heredocs in the same relative position, plus one explanatory comment block recording
  that these pin conditional results

**Verification**:

- `bash scripts/check-module-invariants.sh` — the C14 `#print axioms` half reports
  `PASS C14 every pinned declaration matches its axiom baseline`.
- Every pinned line's value is the measured `#print axioms` output, with no `sorryAx` in any of
  them.
- `grep -n '854\|specs/' scripts/check-module-invariants.sh` shows no new occurrence introduced by
  this phase.

---

### Phase 3: Theorem-index rows, in the conditional form [COMPLETED]

**Goal**: Add six rows to `docs/theorem-index.md`'s `### Expressiveness` table recording the
elimination machinery and the two class-validity transfers, each stating the conditional form and
none claiming the unconditional verdict is machine-checked.

**Tasks**:

- [ ] Add the six rows to the `### Expressiveness` table, after the two existing rows, in the
      table's exact six-column shape
      (`| Paper label | Statement | Lean name | File | Frame class | Axioms |`):
      `ofutP_or_iff`, `opastP_or_iff`, `ofutP_sepForm_iff`, `opastP_sepForm_iff` (Frame class
      `—`, these are stated at every regular frame), and `openValidIn_ztime_iff_tr` (`ZTime`),
      `openValidIn_rtime_iff_tr` (`RTime`).
- [ ] Paper-label cell: `—` for all six (formalization-native; the manuscript states no
      elimination or translation for the restricted modals). C15 then requires the declaration's
      own `Paper:` line to read `— (reason)`, which Phase 1 wrote.
- [ ] Lean-name cells: **fully qualified**, `FormalSystem.Metalogic.Expressiveness.<name>`. A bare
      base identifier is not a row key.
- [ ] File cells: `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`, **path
      only, no line numbers** (C20 tier 2).
- [ ] Axioms cells: `pcq pinned:C14` where the measured value is `[propext, Classical.choice,
      Quot.sound]`; anything else written out literally, exactly as measured in Phase 2. The column
      is generated from the baselines, never typed independently of them.
- [ ] **Statement cells state the conditional.** Each of the four machinery rows opens with its
      hypothesis — "for `α` past-determined and `β` future-determined, on every regular task
      frame" — and each of the two transfer rows opens with "Given separation over ℤ-time
      (resp. the dense Dedekind-complete) frames". No row may read as "`▷` is L⁺-definable at
      ZTime" full stop.
- [ ] Do **not** add a row for the unconditional verdict, and do not add `SeparationOver` as a row
      claiming it holds. The unconditional claim lives only in the module docstring, cited to GHR.
- [ ] Add two or three sentences of orienting prose immediately above the `### Expressiveness`
      table (or extend the section's existing lead if one is added) stating that the new rows are
      **conditional on an unformalized separation hypothesis** and that the hypothesis is false
      over `ℚ`, so nothing here transfers to `.Dense` or `.Base`. Model the shape on the
      `### L^▷ — the open-future and open-past language` section's own lead paragraph.
- [ ] **No `specs/` path and no task number** in any added row or sentence: C9D gates `docs/` at
      zero, and C12 requires every slash-shaped source path in `docs/` to resolve — a `specs/854_...`
      path fails the moment the task directory is archived.
- [ ] Run `bash scripts/check-module-invariants.sh` and confirm C15's second assertion
      (`all N theorem-index row(s) carry their anchor`) PASSes with the row count increased by
      six, and that C12 and C13 PASS.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Six new rows plus one short lead paragraph in the single file
`docs/theorem-index.md`, whose `### Expressiveness` table carries exactly two rows at plan time.
Confirm at implementation time by `git diff --stat` on that one path and by C15's second assertion
reporting a row total exactly six higher than its pre-phase reading.

**Tier Justification**: `bash scripts/check-module-invariants.sh`'s C15 second assertion plus C12
and C13 lint this one markdown file's rows, source paths and relative links, which is the entire
blast radius of a rows-only edit to the ledger.

**Files to modify**:

- `docs/theorem-index.md` - six rows added to the `### Expressiveness` table, plus a short lead
  paragraph stating the conditionality and the ℚ non-transfer

**Verification**:

- `bash scripts/check-module-invariants.sh` — C15's second assertion PASSes at a row total six
  higher than before; C12 and C13 PASS.
- Every added row: Paper label `—`, fully qualified Lean name, path-only File cell, Axioms cell
  equal to the Phase 2 measurement with its `pinned:C14` token.
- Read-through: no added row or sentence asserts the unconditional verdict is machine-checked, and
  none claims anything at `.Dense` or `.Base`.
- `grep -n '854' docs/theorem-index.md` shows no new occurrence.

---

### Phase 4: The directory README row and the regenerated inventories [COMPLETED]

**Goal**: Record the module in `FormalSystem/Metalogic/Expressiveness/README.md` in that file's
existing row shape, re-measure its hand-written content counts, and regenerate every machine-owned
inventory block the new file changes.

**Tasks**:

- [ ] Add a row to the README's `## Modules` table in its existing three-column shape
      (`| File | Lines | Description |`), inserted in the table's existing alphabetical position
      among the loose modules (between `NormalForm.lean` and `PriorDefs.lean`). The Lines cell is
      the measured `wc -l` of the new file; the Description cell is one line naming the
      elimination and the conditional translation.
- [ ] Re-measure and update the hand-written sentence `Measured live contents: **9 loose modules
      and 4 subdirectories**, 141 modules in total.` — the loose-module count rises by one and the
      total by one. **Re-derive both figures** rather than incrementing on trust: the README's own
      instruction is to run `scripts/check-module-invariants.sh` rather than an ad-hoc `find`, and
      the generated `Expressiveness/` row in `FormalSystem/Metalogic/README.md` records a
      different file count (143) than this sentence does (141), so the two are already not
      measuring the same thing and a blind `+1` would propagate that.
- [ ] Add one bullet to the README's `## Key Results` list naming the landed result, stating it as
      **conditional on a separation hypothesis that this tree does not formalize**, and naming the
      shared vocabulary (`PastDet`, `FutDet`, `OfutP`, `OpastP`) as public and owned here. Also
      name the bridge and sanity-instance identifiers (`pastDet_of_isPurePast`,
      `futDet_of_isPureFuture`, `ofutP_of_pastDet`, `ofutP_of_futDet`) so the advisory C17
      dead-declaration scan sees them referenced outside their declaring lines.
- [ ] Add the new module to the README's `## Architecture` tree block, as a sibling of the other
      loose modules.
- [ ] Update the README's trailing `*Last verified: ...*` date to the implementation date
      (`readme-lint.sh` Check 4 reports a date older than the directory's last commit).
- [ ] Regenerate the machine-owned inventory blocks, which the new file and the aggregator's extra
      import line both change: `bash scripts/check-module-invariants.sh --emit-inventory`. This
      rewrites the `Expressiveness.lean` line-count row and the `Expressiveness/` file/line row in
      `FormalSystem/Metalogic/README.md`. **Do not hand-edit a block between
      `<!-- BEGIN GENERATED -->` and `<!-- END GENERATED -->`.**
- [ ] Confirm the regeneration is idempotent and the gated INV check is clean:
      `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] Run `bash scripts/readme-lint.sh FormalSystem` and confirm exit 0 (Checks 1 and 3 are the
      gated ones; a `NOT LISTED` or stale-date report for an untouched directory is pre-existing
      and not this phase's to fix).
- [ ] **No task number and no `specs/` path** in any README edit: C9 gates `README.md` and
      `FormalSystem/` at zero and C5 requires every module-shaped path in non-specs markdown to
      resolve.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: One table row, one re-measured counts sentence, one Key Results bullet, one
Architecture-tree line and one date in `FormalSystem/Metalogic/Expressiveness/README.md`, plus
whatever `--emit-inventory` rewrites inside the generated blocks of
`FormalSystem/Metalogic/README.md` (expected: the `Expressiveness.lean` loose-module row, 77 lines
at plan time, and the `Expressiveness/` subdirectory row, 143 files / 104,211 lines at plan time).
Confirm at implementation time by `git diff --stat` on exactly those two paths and by
`--emit-inventory --check` exiting 0 on a second run.

**Tier Justification**: `bash scripts/check-module-invariants.sh --emit-inventory --check` plus
`bash scripts/readme-lint.sh FormalSystem` together cover every markdown surface this phase
touches — the generated blocks by byte equality and the hand-written ones by link and
README-presence lint — and the phase elaborates no Lean at all.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/README.md` - module-table row, re-measured content
  counts, Key Results bullet, Architecture-tree entry, `Last verified` date
- `FormalSystem/Metalogic/README.md` - generated inventory blocks only, rewritten by
  `--emit-inventory`; no hand edit

**Verification**:

- `bash scripts/check-module-invariants.sh --emit-inventory --check` — exit 0 (a second run would
  change no byte).
- `bash scripts/readme-lint.sh FormalSystem` — exit 0.
- The new module's row is present in the `## Modules` table with a measured Lines cell; the
  content-count sentence matches a re-derived measurement, not an increment.
- `grep -n '854' FormalSystem/Metalogic/Expressiveness/README.md FormalSystem/Metalogic/README.md`
  shows no new occurrence.

---

### Phase 5: Full verification and axiom audit [COMPLETED]

**Goal**: Establish on the whole repository that the module is landed and compiled, sorry-free and
axiom-pinned at its measured profile, that every gate holds at its re-derived baseline, and that
no surface overclaims the verdict.

**Tasks**:

- [ ] Run the unscoped guarded build: `bash .claude/scripts/lake-build-guard.sh build --timeout
      1800 -- build`. Never bare `lake`. Read the verdict from the guard's exit status or its
      `result` subcommand, never from a pipe's exit code.
- [ ] Re-measure axioms on all eight pinned fully-qualified names with `lean_verify` (or
      `#print axioms`) and confirm each matches the value Phase 2 pinned. A declaration that has
      acquired `sorryAx` is a hard stop: mark the phase `[BLOCKED]` and report. A declaration that
      has acquired `Classical.choice` where Phase 2 measured none is a regression to investigate,
      not a new baseline.
- [ ] Run `bash scripts/check-module-invariants.sh` and assert **per-check, not by exit code**:
      INV PASS, C2 PASS, C3 (zero structural `sorry`) PASS, C4/C5 PASS, C9 PASS, C9D PASS, C12
      PASS, C13 PASS, both C14 halves PASS, both C15 assertions PASS, C21 PASS, C24 PASS, and the
      C16 finding list byte-identical to its pre-task baseline. The script's nonzero exit on a
      pre-existing C16 finding is not this task's to fix; a NEW finding is.
- [ ] Run `bash scripts/check-metalogic-cycles.sh` and require **exit 0** with the upward import
      set still exactly the recorded 8 lines. This task's import is a downward edge
      (Metalogic layer 3 -> OpenLanguage layer 0-1), so the allowlist must be **unchanged**; a
      nonzero exit here means the import landed the wrong way round. Do not edit the allowlist.
- [ ] Run `bash scripts/check-copyright-headers.sh` and confirm the new module's header is
      accepted.
- [ ] Confirm `git status --short` shows changes in exactly the six intended paths and nothing
      under `FormalSystem/Metalogic/Independence/` or in
      `scripts/check-metalogic-cycles.sh`.
- [ ] Confirm zero `sorry`, zero `axiom` declarations and zero vacuous definitions in the new
      module: `grep -n 'sorry\|^axiom ' FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`
      returns nothing, and no declaration body is of the `:= True` / `:= trivial` / `:= Unit`
      shape.
- [ ] Re-read every landed prose surface — the module docstring, the aggregator docstring edits,
      the README row and Key Results bullet, the six theorem-index rows and their lead paragraph,
      and the invariants-script comment block — against the overclaim test: **no pinned row or
      generated cell may state the unconditional verdict as machine-checked**, no surface may claim
      anything at `.Dense` or `.Base`, no surface may make a completeness or decidability claim for
      L^▷ or L⁺, and no surface may suggest `SeparationOver` is formalized here.
- [ ] Confirm no landed file cites a `specs/` path or a task number:
      `grep -rn '854\|specs/854' FormalSystem/ docs/theorem-index.md scripts/check-module-invariants.sh`
      returns nothing.
- [ ] Run `bash .claude/scripts/validate-artifact.sh
      specs/854_open_future_modal_lplus_definability/plans/01_open-future-elimination-module.md plan`
      and confirm no errors.

**Timing**: 1.25 hours

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Six changed paths in all (one new Lean module, the Expressiveness
aggregator, that directory's README, `FormalSystem/Metalogic/README.md`'s generated blocks,
`docs/theorem-index.md`, `scripts/check-module-invariants.sh`), with gate baselines carried from
the preceding round: `check-metalogic-cycles.sh` exit 0 at exactly 8 recorded upward lines, and
`check-module-invariants.sh` exiting nonzero only on a pre-existing C16 finding. Both gate figures
are **re-derived in this phase by running the commands**, never trusted from this sentence.

**Files to modify**:

- none planned - this phase runs verification commands only and edits no file; any repair it
  triggers is made in the phase that owns the file (Phase 1, 2, 3 or 4)

**Verification**:

**Batch-aware deferral (recorded at execution time).** This dispatch ran inside a multi-task
`/orchestrate` batch, so the declared `full` tier was discharged against a scoped tier and the
complete harness gate set was deferred to the batch stage rather than independently re-run here.
The named narrowing invocations (`agent-system/extensions/core/scripts/tests/run-all.sh --only`,
`verify-deploy.sh --only-gate`) were unavailable and inapplicable: this repository carries no
`agent-system/` source store, and every file this task modified is project-domain
(`FormalSystem/**`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`, the generated
library root, four READMEs, `typst/generated/status.typ`) rather than harness-domain, so no
harness suite covers any of them. The scoped tier that does cover them is the repository
Lean/ledger gate set below, which was run in full and observed green in this dispatch. The
deferral is of the harness set only, and it is deferred, not forgiven.

This phase's complete gate set for this task's surfaces, all of which must be observed green in
this dispatch and none of which may be trusted on sight:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — unscoped, exit 0.
- `lean_verify` on all eight pinned fully-qualified names, each matching the Phase 2 measurement,
  with no `sorryAx` anywhere.
- `bash scripts/check-module-invariants.sh` — INV, C2, C3, C4, C5, C9, C9D, C12, C13, both C14
  halves, both C15 assertions, C21 and C24 all PASS; C16 finding list byte-identical to its
  pre-task baseline.
- `bash scripts/check-metalogic-cycles.sh` — exit 0, upward import set unchanged at 8 lines, the
  allowlist file untouched.
- `bash scripts/check-copyright-headers.sh` — the new module accepted.
- `bash scripts/readme-lint.sh FormalSystem` — exit 0.
- Zero `sorry`, zero `axiom`, zero vacuous definitions in the new module.
- The overclaim read-through passes on all six surfaces, and no landed file cites a `specs/` path
  or a task number.

## Lean Challenge Statements

These are the signatures the module must land, pinned before implementation. The bodies are
`sorry` here **only** so the signatures are machine-comparable; the probe proves every one of them
in full, and the implementation transcribes those proofs. The `[F.IsRegular]` binder is present on
exactly the declarations that route through `paste` — note its deliberate **absence** on
`ofutP_of_pastDet`, which the probe carried unused.

```lean
import FormalSystem.OpenLanguage

open FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.PlusLanguage FormalSystem.OpenLanguage

namespace FormalSystem.Metalogic.Expressiveness

def PastDet (F : TaskFrame) (phi : PlusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration), AgreeUpTo τ σ t →
    (PlusTruthAt M τ t phi ↔ PlusTruthAt M σ t phi)

def FutDet (F : TaskFrame) (phi : PlusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration), AgreeFrom τ σ t →
    (PlusTruthAt M τ t phi ↔ PlusTruthAt M σ t phi)

def OfutP {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (phi : PlusFormula) : Prop :=
  ∀ σ : WorldHistory F, AgreeUpTo τ σ t → PlusTruthAt M σ t phi

def OpastP {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (phi : PlusFormula) : Prop :=
  ∀ σ : WorldHistory F, AgreeFrom τ σ t → PlusTruthAt M σ t phi

def sepForm : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => (c.1.or c.2).and (sepForm L)

def ofutElim : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => (c.1.or (.stab c.2)).and (ofutElim L)

def opastElim : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => ((PlusFormula.stab c.1).or c.2).and (opastElim L)

def SepClauses (F : TaskFrame) (L : List (PlusFormula × PlusFormula)) : Prop :=
  ∀ c ∈ L, PastDet F c.1 ∧ FutDet F c.2

def SeparationOver (P : TaskFrame → Prop) : Prop :=
  ∀ phi : PlusFormula, ∃ L : List (PlusFormula × PlusFormula),
    ∀ (F : TaskFrame), F.IsRegular → P F → SepClauses F L ∧
      ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
        PlusTruthAt M τ t phi ↔ PlusTruthAt M τ t (sepForm L)

theorem pastDet_of_isPurePast {F : TaskFrame} {phi : PlusFormula}
    (h : PlusFormula.IsPurePast phi) : PastDet F phi := sorry

theorem futDet_of_isPureFuture {F : TaskFrame} {phi : PlusFormula}
    (h : PlusFormula.IsPureFuture phi) : FutDet F phi := sorry

theorem ofutP_or_iff {F : TaskFrame} [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) {α β : PlusFormula} (hα : PastDet F α) (hβ : FutDet F β) :
    OfutP M τ t (α.or β) ↔ PlusTruthAt M τ t (α.or (.stab β)) := sorry

theorem opastP_or_iff {F : TaskFrame} [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) {α β : PlusFormula} (hα : PastDet F α) (hβ : FutDet F β) :
    OpastP M τ t (α.or β) ↔ PlusTruthAt M τ t ((PlusFormula.stab α).or β) := sorry

theorem ofutP_sepForm_iff {F : TaskFrame} [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (L : List (PlusFormula × PlusFormula)) (hL : SepClauses F L) :
    OfutP M τ t (sepForm L) ↔ PlusTruthAt M τ t (ofutElim L) := sorry

theorem opastP_sepForm_iff {F : TaskFrame} [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (L : List (PlusFormula × PlusFormula)) (hL : SepClauses F L) :
    OpastP M τ t (sepForm L) ↔ PlusTruthAt M τ t (opastElim L) := sorry

theorem openTruthAt_iff_tr {P : TaskFrame → Prop} (hsep : SeparationOver P)
    {F : TaskFrame} [hF : F.IsRegular] (hP : P F) (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (phi : OpenFormula) :
    OpenTruthAt M τ t phi ↔ PlusTruthAt M τ t (tr hsep phi) := sorry

theorem openValidOnFrames_iff_tr {P : TaskFrame → Prop} (hsep : SeparationOver P)
    (phi : OpenFormula) :
    OpenValidOnFrames (fun F => F.IsRegular ∧ P F) phi ↔
      PlusValidOnFrames (fun F => F.IsRegular ∧ P F) (tr hsep phi) := sorry

theorem openValidIn_ztime_iff_tr (hsep : SeparationOver TaskFrame.IsZTime) (phi : OpenFormula) :
    OpenValidIn FormalSystem.ProofSystem.FrameClass.ZTime phi ↔
      PlusValidIn FormalSystem.ProofSystem.FrameClass.ZTime (tr hsep phi) := sorry

theorem openValidIn_rtime_iff_tr (hsep : SeparationOver TaskFrame.IsRTime) (phi : OpenFormula) :
    OpenValidIn FormalSystem.ProofSystem.FrameClass.RTime phi ↔
      PlusValidIn FormalSystem.ProofSystem.FrameClass.RTime (tr hsep phi) := sorry

theorem ofutP_of_pastDet {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {α : PlusFormula} (hα : PastDet F α) : OfutP M τ t α ↔ PlusTruthAt M τ t α := sorry

theorem ofutP_of_futDet {F : TaskFrame} [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) {β : PlusFormula} (hβ : FutDet F β) :
    OfutP M τ t β ↔ PlusTruthAt M τ t (.stab β) := sorry

end FormalSystem.Metalogic.Expressiveness
```

`tr` is a `noncomputable def` by recursion on `OpenFormula`, homomorphic on the seven shared
constructors and sending `.ofut phi` to `ofutElim (Classical.choose (hsep (tr hsep phi)))` and
`.opast phi` to `opastElim (...)`; it is written out in the probe and is transcribed unchanged. It
is omitted from the block above only because a `sorry`-bodied definition would not pin a
recursion.

`ofutP_sepForm_iff` and `opastP_sepForm_iff` are stated above with `L` and `hL` as ordinary
arguments; the probe proves them by structural recursion on `L` with `L` after the colon. Either
elaborated form is the same statement, and the probe's recursion shape is the one to transcribe.

## Testing & Validation

- [ ] The new module compiles under the guarded build with 0 errors and 0 new warnings, both
      scoped (`-- build FormalSystem.Metalogic.Expressiveness`) and unscoped (`-- build`).
- [ ] No `sorry`, no `axiom` declaration, and no vacuous-definition pattern anywhere in the new
      module (grep count 0 for each).
- [ ] All eight pinned declarations measure the axiom sets Phase 2 recorded, with no `sorryAx`.
- [ ] `scripts/check-module-invariants.sh`: INV, C2, C3, C4, C5, C9, C9D, C12, C13, both C14
      halves, both C15 assertions, C21 and C24 PASS; C16 finding list byte-identical to the
      pre-task baseline.
- [ ] `scripts/check-metalogic-cycles.sh` exits 0 with its recorded upward-edge allowlist
      unchanged and unedited.
- [ ] `scripts/check-copyright-headers.sh` accepts the new module.
- [ ] `scripts/readme-lint.sh FormalSystem` exits 0, and
      `scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `PastDet`, `FutDet`, `OfutP` and `OpastP` are public, documented, and resolvable as
      `FormalSystem.Metalogic.Expressiveness.*` — the companion non-definability task imports them
      from here.
- [ ] Every one of the six theorem-index rows states the conditional form; no landed surface claims
      the unconditional verdict is machine-checked, and none claims anything at `.Dense`/`.Base`.
- [ ] Nothing under `FormalSystem/Metalogic/Independence/` changed, and
      `scripts/check-metalogic-cycles.sh` is untouched.
- [ ] No landed file cites a `specs/` path or a task number.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` — the new library module
  (the task's deliverable).
- `FormalSystem/Metalogic/Expressiveness.lean` — one import line plus two docstring edits.
- `FormalSystem/Metalogic/Expressiveness/README.md` — module-table row, re-measured counts, Key
  Results bullet, Architecture entry, refreshed `Last verified` date.
- `FormalSystem/Metalogic/README.md` — regenerated inventory blocks.
- `docs/theorem-index.md` — six conditional rows plus a lead paragraph.
- `scripts/check-module-invariants.sh` — eight matched C14 baseline pairs plus one comment block.
- `specs/854_open_future_modal_lplus_definability/summaries/01_*-summary.md` — the execution
  summary written at implementation completion.

## Rollback/Contingency

Every phase is additive and confined to the six paths above, so rollback is per-phase revert with
no migration to undo.

- **Phase 1 fails to compile**: the module is one new file plus one import line. Remove the import
  line from the aggregator first (restoring a green `lake build`), then repair the file. Do not
  weaken a statement, add a hypothesis, or insert a `sorry` to get a green build — mark the phase
  `[BLOCKED]` and report, per the escalation protocol for `.lean` files.
- **Phase 2 measures an unexpected axiom set**: record the measured value, pin it, and state the
  divergence from the report's F2 reading in the handoff. A measured `sorryAx` is a hard stop:
  `[BLOCKED]`, no baseline pinned.
- **Phase 3 or 4 fails a lint**: revert that single markdown file and re-apply. For a generated
  block, never hand-repair — re-run `--emit-inventory`.
- **Phase 5 finds a new C16 finding or a nonzero `check-metalogic-cycles.sh`**: the second means
  the import landed as an upward edge, which is a Phase 1 defect to repair in Phase 1, not an
  allowlist entry to add. The allowlist stays untouched in every scenario.
- **Whole-task abandonment**: reverting the six paths returns the tree to its pre-task state; the
  research report and probe remain in the task directory, so the verdict is not lost by a
  rollback — only its durable landing is.
