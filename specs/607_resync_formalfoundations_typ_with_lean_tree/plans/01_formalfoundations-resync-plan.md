# Implementation Plan: Task #607

- **Task**: 607 - Resync typst/FormalFoundations.typ with the current Lean tree and paper vocabulary
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: None (task 584, which deferred this work, is complete)
- **Research Inputs**: specs/607_resync_formalfoundations_typ_with_lean_tree/reports/01_formalfoundations-typst-resync.md
- **Artifacts**: plans/01_formalfoundations-resync-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

`typst/FormalFoundations.typ` (1577 lines) has no leftover pre-rename Lean identifiers, and its
Some/All Past/Future labels are already current. Three kinds of stale content remain. (1) The
"Machine-Checked Status" remark (around lines 1034-1045) gives wrong constructor counts: it says 22
explicit Since/Until constructors and 5 uniformity constructors. The correct counts are 11
future-direction constructors, with the past mirrors derived by TR, and 4 uniformity constructors,
where only NP's past mirror is derived. (2) The axiom keys `TB` and `TA` should be the paper's `TS`
and `TC`. There are 14 sites. (3) The document uses the system names backwards against the
repository's permanent language correspondence. Its bare "TM" (over `#BL`, with primitive H/G) is
the repository's **TM⁻**, which has no paper counterpart. Its `TM^+` (over `#BLplus`, with
Until/Since primitive) is the paper's and the repository's **TM**.

The plan fixes the small items first. Next, a specs-only work file records how each ambiguous `TM`
and `BL` site should be classified. The renames are then applied section by section against that
file. After that come the provenance remarks, and finally every mechanical gate (typst compile,
`typst-sync-check.sh`, `check-paper-definitions.sh`, a `#leansrc` target-existence check, and
residual greps).

### Decision: resolving the TM / TM^+ naming collision (research left this open)

The research report's options were: (a) keep the document's own bare-`TM` name for the `#BL`-level
system and add a disclaimer, or (b) rename the `+` family to bare `TM`. **This plan adopts (b), in
a variant that keeps the `#BL`-level material under the name TM⁻.** The `#BL`-level material is
not deleted.

Rationale: this is not a question of taste. The codebase has already settled it.
`docs/reference/paper-definitions-of-record.md` § "Language correspondence (2026-09-08)" records
it as a **permanent** fact: repository **L / TM** = manuscript 𝓛 / TM (`def:TMplus`), and
repository **L⁻ / TM⁻** = the withdrawn H/G fragment, with no paper counterpart. The Lean tree
already follows this. `FormalSystem/Syntax/MinusLanguage/Axioms.lean` names the `#BL`-level system
"TM⁻", uses keys TS/TC, and says that "these system names are Lean-only and have no paper
counterpart". Option (a) would leave this report as the only artifact where bare "TM" means the
non-paper system. Because the codebase convention already decides the question, it is not a
`user_decision`.

Concretely:
- The `#BL` macro becomes a `#BLminus` macro, rendering `op("BL")^-`.
- The `#BLplus` macro becomes a `#BL` macro, rendering `op("BL")`.
- `op("TM")^+` and its subscripted forms become `op("TM")` and the matching subscripted forms.
- The bare `#BL`-level "TM" and `op("TM")_x` become `op("TM")^-` and `op("TM")^-_x`, through a new
  `#TMminus` macro or inline notation.

### Research Integration

- The correct counts for the axiom-count remark come from `FormalSystem/ProofSystem/Axioms.lean`'s
  module docstring and `docs/reference/axiom-reference.md` § Paper Key Correspondence. Phase 1
  quotes these files directly and does not re-derive the counts. This avoids repeating the
  opposite-direction error that task 584 introduced.
- `TB`->`TS` and `TA`->`TC` are needed whatever the naming decision. Both the `def:BX` block and the
  `#BL`-level block use the same two formulas under the wrong keys.
- `TK`/`T4` stay in the TM⁻ block. TM⁻ does have these keys: `MinusLanguage/Axioms.lean` lists MK,
  MT, M5, MF, TK, T4, TS, TC and TL. They are not paper keys, and the new provenance remark says
  so.
- DF/DN/CO stay unchanged. They are live paper keys (`app:discrete`, `app:dense`,
  `app:complete`).
- `#leansrc` citations were not checked one by one during research. Phase 6 adds an existence
  check.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted. None was provided in the delegation context.

## Goals & Non-Goals

**Goals**:
- Correct the axiom-count remark: 11 BX-temporal constructors (future direction only; past mirrors
  derived by TR), 4 uniformity constructors (NP/NF/NA/NB; only NP's mirror is derived).
- Rename `TB`->`TS` and `TA`->`TC` at every site.
- Rename the systems throughout to match the repository and paper correspondence. The paper's
  system becomes `TM`, and the `#BL`-level system becomes `TM⁻`, with a provenance remark saying it
  has no paper counterpart.
- Rename the language macros to match: `#BL` becomes `#BLminus`, and `#BLplus` becomes `#BL`.
- Make every result statement name the system it actually concerns. Soundness, incompleteness,
  decidability and conservativity are the main ones.
- Leave the document compiling, and leave `typst-sync-check.sh` and `check-paper-definitions.sh`
  green.

**Non-Goals**:
- Renaming the frame-class subscripts `f/d/c` -> `z/d/r`. This is not a pure relabel. The paper's
  `BX_r` extends `BX_d`, while the document's `BX_c` extends BX. For the TM⁻ family, Lean routes CO
  to `.RTime` (`TM⁻_r`), while the document's `TM_c` means CO-only. Changing these needs a
  mathematical review, not a sweep. The existing "Naming provenance" remark already covers the old
  subscripts; it is updated but kept. This is a candidate follow-up task.
- Editing `typst/BimodalReference.typ` and its chapters. For example,
  `chapters/p2-decidability-practice.typ` uses the same old bare-`TM` / `op("TM")_f` family. Record
  this as a follow-up.
- Promoting the "Language correspondence" table to a standalone doc. This is the research report's
  suggestion for a separate task.
- Any change to `typst/generated/**`. It is regenerated mechanically.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Macro rename collision: renaming `#BL`->`#BLminus` and `#BLplus`->`#BL` in the wrong order merges the two | H | M | Rename in the fixed order `#BL` -> `#BLminus` first, then `#BLplus` -> `#BL`. Match on word boundaries (`#BL\b` must not match `#BLplus`). Confirm by counts before and after. |
| A bare "TM" site is misclassified: a plain "TM" in prose (abstract, header comment, `#show "TM": strong`) refers to the paper system, not the `#BL`-level one | H | M | Phase 2's classification inventory gives a verdict and a reason for every site before any rename. The abstract/title "Bimodal TM Logic" is the paper's TM and stays. |
| A result is re-attributed to the wrong system (e.g. "Incompleteness at the base level" is about TM⁻, while completeness results are about TM) | H | M | Phase 5 re-reads each theorem statement against its `#leansrc` target and the Lean module (e.g. `Metalogic/Conservativity.lean`'s docstring maps the two name families). |
| A backticked span removed from the file was the last one keeping a `sync-check-whitelist.txt` entry alive, or a new span becomes a whitelist candidate | M | M | Per the stored memory: before and after the edits, grep each touched backticked span across all `.typ` files. Run `typst-sync-check.sh` in Phase 6, and add or remove whitelist entries only where the check requires it. |
| The count remark is re-transcribed wrongly a second time | M | L | Phase 1 quotes the numbers from the `Axioms.lean` docstring and `axiom-reference.md`, and cites both files in the remark. |
| Line numbers drift between phases | L | H | Phase 2's inventory is keyed by content pattern and section heading, not only by line number. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases in the same wave can run in parallel. Phase 2 writes only a specs work file and reads
`FormalFoundations.typ`, so it does not conflict with Phase 1's edits. Phases 3-5 all edit the same
file and must run in sequence.

### Phase 1: Axiom-key renames and count-remark correction [COMPLETED]

**Goal**: Fix the self-contained factual errors: the wrong keys and the wrong constructor counts.

**Tasks**:
- [x] Replace `TB` with `TS` and `TA` with `TC` at every site. The expected sites are the `def:BX`
      items and the list in its footnote (`Seventeen named keys ...`), the `#BL`-level definition
      block's items and its summary sentence, the §Algebras derivation remark, and the Ultrafilter
      Frame lemma. Use whole-word matching only. *(completed: 7 TB->TS, 8 TA->TC, 15 sites total, whole-word sed)*
- [x] Update the `def:BX` footnote's category phrase so the keys read "(TS, TL, CN)" and "(TC, UE,
      ...)". The total of seventeen keys stays the same. *(completed: satisfied automatically by the whole-word TB/TA rename above)*
- [x] Rewrite the remark in `== Machine-Checked Status` (the one starting "The vocabulary above is
      the development's own"). It should say that the development states the **11** primary
      Since/Until axioms in the future direction only, and that their past mirrors are
      machine-checked derived theorems (`FormalSystem.ProofSystem.DerivedAxioms`), obtained by TR
      (`DerivationTree.time_reflection`). It should say that the uniformity layer has exactly
      **4** constructors, NP/NF/NA/NB, one per paper key. Only NP's past mirror is TR-derived; NA
      is the paper's NA itself, not the mirror of NF. Keep the closing sentences about textual,
      not machine-checked, correspondence and the pointer to `docs/reference/axiom-reference.md`.
      At this phase, leave the system names in the remark (`op("TM")^+` etc.) as they are. Phase 4
      renames them. *(completed)*
- [x] Before writing the counts, re-read the `Axioms.lean` module docstring ("BX Temporal (11,
      future direction only ...)", "Total: 29 ...") and `axiom-reference.md`'s "Derived schemata"
      table. *(completed)*

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 7 `TB` sites and 7 `TA` sites (research grep). Confirm with
`grep -nwE 'TB|TA' typst/FormalFoundations.typ` before editing. The count after editing must be 0.

**Files to modify**:
- `typst/FormalFoundations.typ` - key renames and remark rewrite

**Verification**:
- `grep -nwE 'TB|TA' typst/FormalFoundations.typ` returns nothing.
- `grep -n 'twenty-two\|five constructors' typst/FormalFoundations.typ` returns nothing.
- `cd typst && typst compile FormalFoundations.typ /tmp/ff-check.pdf` (or a scratchpad path)
  succeeds.

---

### Phase 2: Classification inventory of TM / BL sites [COMPLETED]

**Goal**: Before any rename, decide for every ambiguous system or language reference whether it
means the `#BL`-level system (TM⁻/L⁻) or the Until/Since system (TM/L), and why.

**Tasks**:
- [x] Enumerate these patterns in `typst/FormalFoundations.typ`, including comment lines:
      whole-word `TM` in prose, `op("TM")_` (no `^+`), `op("TM")^+`, `#BL` (not `#BLplus`),
      `#BLplus`, `"BL"`, `TM^+` or `TM+` in comments, and the header and title strings.
      *(completed: 98 distinct matched lines, union of all patterns)*
- [x] Write the inventory to
      `specs/607_resync_formalfoundations_typ_with_lean_tree/working/tm-site-inventory.tsv`. Use the
      columns `line`, `section`, `pattern`, `excerpt`, `verdict` (`TM`, `TMminus`, `L`, `Lminus`,
      `keep`) and `reason`. *(completed: 98 rows, one per matched line; a handful of lines that
      mix a TM occurrence and a TM^+ occurrence in a deliberate contrast sentence use a compound
      verdict, e.g. `TM+TMminus`, documented in the row's reason)*
- [x] Apply these default rules, and flag any exception in `reason`:
      - Sites in the `#BL`-level `definition("TM")` block and the DF/DN/CO paragraph after it,
        `Derivability`, §2's `#BL`-level results (Soundness for the `_f/_d/_c/_(d c)` family,
        Incompleteness at the base level, Decidability, Failure of a uniform FMP), and
        §Contingency's `op("TM")_f/d/c` get verdict `TMminus`.
      - Sites for `op("TM")^+*` and for the paper's TM in the title, abstract and §Representation
        ("TM-algebra") get verdict `TM`. *(completed)*
- [x] For each theorem-level site, check the attribution against the `#leansrc` target it cites.
      For example, `Metalogic.Soundness.soundness` is over which formula type? Also check
      `FormalSystem/Metalogic/Conservativity.lean`'s docstring, which maps the two families of
      names. *(completed: Metalogic.Soundness.soundness/soundness_dense/soundness_ztime/soundness_rtime
      confirmed over `Formula` (until/since-primitive, paper TM) per Soundness.lean:185's own
      docstring; Conservativity.lean's "System names, and how they map onto the paper" docstring
      confirmed the plan's TM/TM⁻ naming decision verbatim. Two apparent pre-existing #leansrc
      citation-target defects were found in the process (line 635's Soundness theorem citing the
      Formula-level family instead of `minus_soundness*`, and line 1275's Algebraic-soundness
      proposition citing `minus_soundness*` under a stale module path instead of the Formula-level
      family) -- both out of this plan's explicit renaming scope, left untouched, and recorded as
      follow-ups in the TSV and the implementation summary rather than fixed)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: about 79 lines with whole-word `TM`, 35 `op("TM")^+` sites, 13
`op("TM")_x` lines without `^+`, and 22 `#BL`/`#BLplus` sites (grep counts at plan time). Confirm
the counts when writing the inventory, and record the actual totals at the top of the TSV.

**Files to modify**:
- `specs/607_resync_formalfoundations_typ_with_lean_tree/working/tm-site-inventory.tsv` - new
  inventory file (specs-only)

**Verification**:
- Every grep hit for the patterns above has one row with a non-empty verdict.
- The row count matches the grep totals recorded at the top of the file.

---

### Phase 3: Macro renames and §1 (The System) system names [COMPLETED]

**Goal**: Apply the language-macro swap across the whole file and the system renames in §1.

**Tasks**:
- [x] In the macro block (around line 85), rename `#let BL = $op("BL")$` to
      `#let BLminus = $op("BL")^-$`, then rename `#let BLplus = $op("BL")^+$` to
      `#let BL = $op("BL")$`. Add `#let TMminus = $op("TM")^-$` next to them if inline use is
      clearer. *(completed)*
- [x] Across the whole file, rewrite every `#BL` use (whole word, not `#BLplus`) to `#BLminus`
      **first**. Then rewrite every `#BLplus` use to `#BL`. Check the counts after each step
      against the Phase 2 totals. *(completed: 13 #BLminus, 15 #BL (was #BLplus), 0 #BLplus remaining)*
- [x] In §1 (`= The System`, up to `= Completeness and Decidability`), apply the Phase 2 verdicts.
      The `#BL`-level `definition("TM")` title and body become TM⁻ (title "TM⁻" or
      `$op("TM")^-$`), and "TM's TL lists ..." becomes "TM⁻'s TL". The DF/DN/CO paragraph's
      `op("TM")_x` becomes `op("TM")^-_x`, and `Derivability` names TM⁻. `op("TM")^+*` in the
      paragraph after `def:BX_c` and in the table figure become `op("TM")*`. *(completed; also
      renamed the two forward self-references "TM's DN below" -> "TM⁻'s DN below" and "CO from TM
      below" -> "CO from TM⁻ below", matching the same TM⁻ self-reference pattern as the given
      "TM's TL" example)*
- [x] Fix `#BL`-level prose that the macro swap alone would make wrong. An example is the
      guard-first footnote near line 163: "The paper's base language `#BL` takes ... as primitive
      instead". After the macro swap it must say that the repository's L⁻ (with H/G primitive)
      has no paper counterpart. Another example is the `NN is specific to the #BLplus level`
      phrasing. *(completed: footnote rewritten to "This repository's own $#BLminus$ ... with no
      paper counterpart"; the NN sentence needed no extra fix beyond the mechanical token swap,
      confirmed correct as-is per MinusLanguage/Axioms.lean's DF/DN/CO table, which lists no NN
      for TM⁻)*
- [x] Also update the `def:BX_f` sentence "its TM extension". It already means the paper's TM, so
      check it against the inventory. *(completed: verified against the inventory, verdict TM,
      left unchanged since already correct)*

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - macro block, all `#BL`/`#BLplus` uses, §1 system names

**Verification**:
- `grep -c '#BLplus' typst/FormalFoundations.typ` returns 0.
- The number of `#BLminus` uses equals the old `#BL` count from Phase 2.
- In §1, no `op("TM")^+` remains.
- `typst compile FormalFoundations.typ` succeeds.

---

### Phase 4: §2-§5 system renames [NOT STARTED]

**Goal**: Apply the Phase 2 verdicts to `= Completeness and Decidability` and the sections after
it.

**Tasks**:
- [ ] §2: rename the Soundness theorem, the section intro ("nothing positive is known at the ...
      level"), `Incompleteness at the base level`, the paragraph after it, `Decidability`, and
      `Failure of a uniform finite model property`. Their `#BL`-level system names become TM⁻ /
      `op("TM")^-_x`. `op("TM")^+*` in the weak-completeness lead-in, the strong-completeness
      paragraph and the conservativity remark become `op("TM")*`. The conservativity remark
      should read "No conservativity claim is made for TM over TM⁻".
- [ ] §3 (`= The Completeness Construction`): rename the `Machine-Checked Status` remark from
      Phase 1 (`op("TM")^+`, `op("TM")^+_d`, ... -> `op("TM")`, `op("TM")_d`, ...), and every other
      `op("TM")^+` site.
- [ ] §4 (`= Two Costs of the Semantics`): rename the §Contingency `op("TM")_f/d/c` family to
      `op("TM")^-_x` where the inventory says so. Rename `op("TM")^+` sites to `op("TM")`.
- [ ] §5 (`= The Representation Theorem`): rename the TM^+-algebra definitions, lemmas, and the
      `TS`/`TC` derivation remark to plain `TM`, following the verdicts.
- [ ] Check each theorem statement against its `#leansrc` target, as Phase 2 recorded, so that the
      named system is the one the Lean declaration is about.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - §2-§5 system names

**Verification**:
- `grep -cF 'op("TM")^+' typst/FormalFoundations.typ` returns 0.
- `grep -nF 'TM^+' typst/FormalFoundations.typ` returns nothing, except inside a deliberate
  provenance sentence added in Phase 5.
- Every inventory row with verdict `TM`/`TMminus` is applied. Tick off the TSV rows or add an
  `applied` column.
- `typst compile` succeeds.

---

### Phase 5: Provenance remarks and narrative consistency [NOT STARTED]

**Goal**: Make the document state its naming scheme explicitly and read consistently after the
renames.

**Tasks**:
- [ ] Add a provenance remark right after the TM⁻ definition block. It should say that TM⁻ over
      L⁻ (H/G primitive) is this repository's own transposition, and that it has no paper
      counterpart because the H/G fragment was withdrawn. It should also say that its keys TK and
      T4 are not paper keys, while TS, TC and TL are shared with BX. Cite
      `FormalSystem/Syntax/MinusLanguage/Axioms.lean` and
      `docs/reference/paper-definitions-of-record.md` § "Language correspondence". Follow the
      memory's rule: paper anchors in comments must not be backticked. In remark prose, backtick
      only spans that `typst-sync-check.sh` can resolve.
- [ ] Update the existing "Naming provenance" remark. It should say that the TM family is now
      written without the `+` superscript, in line with `def:TMplus`, and that the `f/d/c`
      subscripts are still the paper's old ones. Keep the `f -> z`, `c -> r` reading note, and
      add that `c -> r` is not a pure relabel (`BX_r` extends `BX_d`).
- [ ] Update the file header comments (lines 1-20) and any `// ...` maintainer comments that name
      TM/TM^+/BL/BL+.
- [ ] Read through the section-opening paragraphs of §1-§5 and the abstract for sentences that the
      renames made inconsistent. An example is "Completeness itself is asymmetric: nothing
      positive is known at the L⁻ level, ...".

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - provenance remarks, header comments, section intros

**Verification**:
- The new remark is present and compiles.
- A read-through of each `=`-level section opening shows no leftover mention of "TM^+", "BL^+" or
  "BLplus".

---

### Phase 6: Gates, `#leansrc` existence check, and follow-up recording [NOT STARTED]

**Goal**: Run the full gate set and confirm there is no citation drift.

**Tasks**:
- [ ] `cd typst && typst compile FormalFoundations.typ` must produce no errors. Look at the new
      PDF pages that contain the renamed definition blocks, to check that `op("TM")^-` and
      `op("BL")^-` render cleanly.
- [ ] `bash scripts/typst-sync-check.sh` must pass. If Check 1 flags a backticked span that is
      new or was removed, fix the span or adjust `typst/sync-check-whitelist.txt` only when it is
      really needed. Before removing any whitelist entry, grep `` grep -rF '`entry`' --include='*.typ' typst/ ``.
- [ ] `bash scripts/check-paper-definitions.sh` must report no new drift.
- [ ] `#leansrc` existence check: extract every `#leansrc("Module", "decl")` pair (about 60) and
      confirm that each module file exists under `FormalSystem/` and declares `decl`. Use a
      scratchpad script (grep for `theorem|lemma|def|structure|inductive|abbrev|class|instance`
      followed by `decl`), or `lean_local_search`. Fix any stale target to its current name, or
      record why the target cannot be fixed.
- [ ] Run the residual greps: `grep -nwE 'TB|TA'`, `grep -cF 'op("TM")^+'`, `grep -c '#BLplus'`,
      `grep -n 'twenty-two\|five constructors'`. Each must return 0 or nothing.
- [ ] Run `bash .claude/scripts/check-task-references.sh typst/FormalFoundations.typ` (or the
      repo-wide lint) to confirm no task-number references were added.
- [ ] Record these follow-ups in the implementation summary: the `f/d/c`->`z/d/r` subscript
      review, the same naming resync for `typst/chapters/p2-decidability-practice.typ` and the
      rest of `BimodalReference.typ`, and promoting the language-correspondence table.

**Timing**: 45 minutes

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: about 60 `#leansrc` citations (research estimate). Confirm with
`grep -c '#leansrc(' typst/FormalFoundations.typ`.

**Files to modify**:
- `typst/FormalFoundations.typ` - only if a gate finds a defect
- `typst/sync-check-whitelist.txt` - only if Check 1 requires it

**Verification**:
- All listed gates pass, and each command's result is recorded in the summary.

## Testing & Validation

- [ ] `typst compile typst/FormalFoundations.typ` succeeds with no errors.
- [ ] `bash scripts/typst-sync-check.sh` exits 0.
- [ ] `bash scripts/check-paper-definitions.sh` reports no new drift.
- [ ] Every `#leansrc` target resolves to a live declaration.
- [ ] The residual greps for `TB`/`TA`, `op("TM")^+`, `#BLplus`, `twenty-two` and `five constructors` are empty.
- [ ] The count remark states 11 future-direction BX-temporal constructors and 4 uniformity
      constructors, with only NP's mirror derived.

## Artifacts & Outputs

- `typst/FormalFoundations.typ` (edited)
- `typst/sync-check-whitelist.txt` (only if needed)
- `specs/607_resync_formalfoundations_typ_with_lean_tree/working/tm-site-inventory.tsv`
- `specs/607_resync_formalfoundations_typ_with_lean_tree/summaries/01_formalfoundations-resync-summary.md`

## Rollback/Contingency

Each phase is committed on its own when green (`task 607 phase {P}: ...`), so a bad phase can be
reverted with `git revert` of that commit. Phases 1-2 are independent of the naming decision. If
the TM/TM⁻ rename in phases 3-5 turns out to be wrong during review, revert those commits. Phase 1's
fixes stay, and option (a) can be applied instead: keep bare TM for the `#BL`-level system and add
a disclaimer. That fallback is a single remark added to Phase 1's result.
