# Implementation Plan: Task #639

- **Task**: 639 - README accuracy and entry point fixes
- **Status**: [IMPLEMENTING]
- **Effort**: 6.75 hours
- **Dependencies**: task 631 (README.md Logos/ProofChecker naming, latex/ retirement) — confirmed already landed
- **Research Inputs**: specs/639_readme_accuracy_and_entry_point_fixes/reports/01_readme-accuracy-entry-points.md
- **Artifacts**: plans/01_readme-accuracy-entry-points.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The repository documents two *different but both legitimate* axiom quantities — 29 primitive
`inductive Axiom` constructors (23 Base / 2 Dense / 2 ZTime / 2 RTime) and 45 total named
schemata (29 primitives + 16 `DerivedAxioms` theorems, partitioned 37/40/39/42 by minimum frame
class) — without ever naming which convention any given number uses. This plan fixes that by
first writing the derivation down once, in `docs/reference/axiom-reference.md` (already the clean
reference), then sweeping every other file to use the primitive-constructor count as the headline
figure with the 45-total figure retained but explicitly labelled. The same sweep repairs the
navigational defects: the Project Structure tree's wrong nesting for the object-language
directories, the missing `MainResults.lean` entry-point link, the stale
`../ProofChecker/Theorems/Perpetuity.lean` relative links, the `<!-- TODO: add description -->`
row, and the inconsistent in-text citation. Items 5 and 6 need no work (already resolved).

### Research Integration

The research report supplies the arithmetic that makes the two conventions reconcilable
(37 = 23 primitives + 14 base-tier derived mirrors; 45 = 29 + 16; the 8 non-Base names are
exactly `prior_UZ, prior_SZ, z1, density, dense_indicator, prior_U_gap, prior_S_gap, sep`), and
three findings that reshape the work:

1. **C14 is blind to the defects.** `check-module-invariants.sh`'s stale-count regex is
   `\b(14|21|42|44|45)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)`, scoped to
   `docs/**/*.md` + `README.md` and `FormalSystem/**/*.lean` (minus `Boneyard/`, requiring
   `axiom` on the line, excluding lines containing `covers`). None of the offending strings
   ("| **Base** | 37 |", "37 axioms", "Base + 3 axioms = 40", "The **45** axiom constructors")
   match it. "C14 stays green" is therefore NOT evidence of correctness for this task, and the
   converse risk is live: new prose of the shape "45 axiom"/"42 schemata" *will* newly fail an
   already-green check. Every phase below carries this as a verification constraint.
2. **Items 5 and 6 are already satisfied** on tracked files — README.md points exclusively at
   `typst/`, and both README.md:372 and docs/README.md:333 carry plain-text
   "BimodalHarness (private repository, not yet released)". The dispatch's third named path,
   `docs/training/PIPELINE.md`, does not exist; the only `PIPELINE.md` is the gitignored
   `training/PIPELINE.md`, invisible to an anonymous clone. No phase touches either item.
3. **Two adjacent staleness pockets** sit inside files item (1) already names:
   `FormalSystem/README.md`'s Logic Variants section uses `FrameClass.Discrete`/`Dedekind`
   (nonexistent; live enum is `Base | Dense | ZTime | RTime`) and cites nonexistent declarations;
   `docs/reference/API_REFERENCE.md`'s inline `inductive Axiom : Formula → Prop` block is a stale
   snapshot (wrong universe, constructors that are now derived theorems, whole layers missing).
   Both are **in scope** — see Decisions.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` supplied to this dispatch; ROADMAP.md was not consulted and is not modified.

## Goals & Non-Goals

**Goals**:
- One stated counting convention, applied consistently: primitive `Axiom` constructors are the
  headline figure everywhere; the 45-name total is retained only where explicitly labelled as
  including derived mirrors.
- A single canonical derivation of 29-vs-45 (and of 37/40/39/42) that every other file links to
  instead of restating.
- Every count in README.md, FormalSystem/README.md, docs/reference/API_REFERENCE.md,
  docs/user-guide/architecture.md, BenchmarkAnchorsMain.lean and RationalWitness.lean agrees with
  `FormalSystem/ProofSystem/Axioms.lean` and `Axiom.minFrameClass`.
- `FormalSystem/MainResults.lean` linked as a top-matter entry point; every README link resolves
  for an anonymous reader with no private-repo access.
- `check-module-invariants.sh --no-build` and `readme-lint.sh` green, with no newly-introduced
  C14 regex match.

**Non-Goals**:
- Changing any Lean *code* — every `.lean` edit in this plan is confined to comments and
  docstrings.
- Item 5 (latex/ retirement) and item 6 (BimodalHarness de-linking): already done; no edits.
- Fixing the gitignored `training/PIPELINE.md`, which no anonymous reader can see.
- Widening C14's regex or otherwise changing `scripts/check-module-invariants.sh`. Its blind spot
  is recorded here and left for a separate task; this plan verifies by direct comparison instead.
- Rewriting `FormalSystem/Syntax/PlusLanguage/README.md`, which is already correct — its "45 TM
  schemata" usage is legitimately about `PlusAxiom`'s re-declared total.
- Running `lake build`. The stated acceptance gate is `--no-build`; no phase requires elaboration.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| New prose trips C14's regex, turning an already-green check red | M | H | Phrase every retained 45/42 figure to avoid `<digit> [word] axiom/constructor/schema` adjacency (e.g. "45 names in all", "45 total"); Phase 7 greps the diff for the regex before declaring green |
| C14 green is mistaken for count correctness | H | M | Phase 7 verifies by direct comparison against `Axioms.lean`/`Axiom.minFrameClass`/`scripts/typst-status-counts.sh`, never by the script's exit code alone |
| Partial fix of FormalSystem/README.md leaves right numbers beside wrong `FrameClass` names | M | M | Phase 4 scopes the Discrete/Dedekind rename into the same pass as the count fix (Decision 2) |
| Re-typing a corrected axiom code block in API_REFERENCE.md re-creates the drift | M | H | Phase 5 replaces the block with a pointer to source + `axiom-reference.md` rather than a corrected transcription |
| A `.lean` comment edit crosses out of the comment region | H | L | Phase 6 verification is an explicit hunk-boundary diff audit; the edits are pure text inside `/-! -/`, `/-- -/`, `--` |
| Two phases editing README.md concurrently conflict | M | M | Phases 2 and 3 are serialized (3 depends on 2), never in the same wave |
| BibTeX year/key convention is a preference the repo cannot settle | L | H | Proceed on the recommended option, record as a non-blocking `user_decision` (see Decisions) |

## Decisions

1. **Counting convention**: primitive constructors are headline. Every count column, graph node
   and prose figure leads with the `inductive Axiom` constructor count (Base 23, Dense +2,
   ZTime +2, RTime +2, total 29). The 37/40/39/42 figures are retained only as an explicitly
   labelled secondary figure ("including derived past-mirrors"), never as a bare number.
2. **`FormalSystem/README.md` Discrete/Dedekind naming is IN SCOPE** (research left this open).
   The stale `FrameClass.Discrete`/`FrameClass.Dedekind` names and the nonexistent
   `completeness_discrete`/`completeness_dedekind`/`soundness_dedekind` citations sit in the same
   section as the count fix; correcting numbers beside wrong class names would be a net loss of
   reader trust.
3. **`docs/reference/API_REFERENCE.md`'s inline axiom code block is replaced, not patched**
   (research left this open) — replaced with a pointer to `ProofSystem/Axioms.lean` plus
   `axiom-reference.md`, matching the generated-not-typed philosophy already used by
   `scripts/typst-status-counts.sh`.
4. **BibTeX year**: the in-text "(Brast-McKie, 2025)" at README.md:103 is unambiguously wrong and
   is fixed to "forthcoming" regardless. The key-vs-`year`-field direction is a genuine
   preference the artifacts cannot infer; the plan proceeds on aligning `year` to `{2025}` to
   match the existing `brastmckie2025construction` key (preserving any external citations of that
   key) and records a non-blocking `user_decision` for the alternative (rename key to
   `brastmckie2026construction`, keep `year = {2026}`).
5. **No task-number references** are introduced into any edited file — all eight targets live
   outside `specs/**`, where `.claude/rules/no-task-references-in-deliverables.md` applies. Cite
   filenames and section headings instead.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4, 5, 6 | 1 |
| 3 | 3 | 2 |
| 4 | 7 | 2, 3, 4, 5, 6 |

Phases within the same wave can execute in parallel. Phases 2 and 3 both edit README.md and are
deliberately serialized.

---

### Phase 1: Canonical "Two axiom counts" reference [COMPLETED]

**Goal**: Write the 29-vs-45 derivation down exactly once, in the file every other phase will
link to, so no later file has to restate the arithmetic.

**Tasks**:
- [x] Re-derive the ground truth before writing anything: count `inductive Axiom` constructors in
      `FormalSystem/ProofSystem/Axioms.lean` and read `Axiom.minFrameClass`
      (`Axioms.lean:606-613`) for the per-class assignment; cross-check against
      `bash scripts/typst-status-counts.sh` output and check C22's reported name-list length.
      *(completed: confirmed 29/23/2/2/2 via direct count, `Axiom.minFrameClass` and
      `typst-status-counts.sh`; confirmed the 16-derived/45-total figure by isolating
      `axiom-reference.md`'s existing 19-row "Derived schemata" table minus its 3 legacy-alias
      rows — `serialFutureImp`, `tempLinearityLegacy`, `linearUntilLegacy` — leaving exactly 16,
      of which 14 are Base-tier and one each ZTime/RTime-tier; all figures agree with the plan)*
- [x] Add a `## Two axiom counts` subsection to `docs/reference/axiom-reference.md` (place it
      immediately after `## Axiom Categories`, before `### Base Axiom Categories (23)`) stating:
      (a) the primitive convention — 29 constructors, 23 Base / 2 Dense / 2 ZTime / 2 RTime;
      (b) the total-names convention — 29 primitives + 16 `DerivedAxioms` theorems = 45 names;
      (c) the per-class partition under convention (b) with a derived mirror inheriting its
      primitive's tier: Base 37, Dense 39 (37+2), ZTime 40 (37+3), RTime 42 (39+3), and the
      8 non-Base names enumerated by name. *(completed)*
- [x] Name, in that subsection, the three files that legitimately use convention (b) —
      `FormalSystem/Automation/BenchmarkAnchorsMain.lean`,
      `FormalSystem/Syntax/PlusLanguage/README.md`, and this README's own secondary column — so a
      future editor does not "correct" them to 29. *(completed)*
- [x] Re-read the written subsection and confirm no line matches C14's regex (see Verification).
      *(completed: grep returned no matches; `readme-lint.sh` PASS)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts 29 primitives (23/2/2/2), 16 derived schemata, 45 total,
and the 37/39/40/42 partition. Confirm at implementation time by direct constructor count in
`Axioms.lean`, by reading `Axiom.minFrameClass`, by `scripts/typst-status-counts.sh`, and by
`BenchmarkAnchorsMain.lean`'s own `nonBaseAxiomNames` list (expected: exactly 8 names). If any
figure disagrees, the source wins — amend this plan's later phases to the observed numbers rather
than writing the planned ones.

**Files to modify**:
- `docs/reference/axiom-reference.md` - add a `## Two axiom counts` subsection with the
  derivation table and the enumerated 8 non-Base names

**Verification**:
- Every figure in the new subsection matches `Axioms.lean` / `Axiom.minFrameClass` directly
- `grep -rniE '\b(14|21|42|44|45)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)' docs/reference/axiom-reference.md`
  returns nothing
- `bash scripts/readme-lint.sh` still passes

---

### Phase 2: README.md axiom counts and derived-mirror labelling [NOT STARTED]

**Goal**: Make the README's Axiom Systems table, mermaid graph and surrounding prose state the
primitive-constructor convention, with the derived-mirror totals retained but labelled — closing
dispatch items (1) and (2).

**Tasks**:
- [ ] Rewrite the mermaid graph nodes (README.md ~lines 179-188): `Base` shows the primitive
      count 23 (not "37 axioms"); `Dense` shows "Base + 2 primitives"; `ZTime` shows
      "Base + 2 primitives"; `RTime` shows "Dense + 2 primitives". Keep node labels free of the
      `<digit> [word] axiom` adjacency.
- [ ] Rewrite the Axiom Systems table (~lines 191-197): rename the `Axioms` column to make the
      convention explicit (primitive constructors), set Base 23 / ZTime 25 / Dense 25 / RTime 27
      cumulative-primitive values *or* keep per-class deltas — whichever the implementer confirms
      reads unambiguously against `Axiom.minFrameClass`; add a second labelled column or a
      single footnote giving the with-derived-mirrors totals (37/40/39/42, 45 in all) pointing at
      `docs/reference/axiom-reference.md`'s `Two axiom counts` section.
- [ ] Fix the `Additional Axioms` column (item 2): ZTime lists only the two primitives
      (`prior_UZ`, `z1`) with `Pφ → S(φ,¬φ)` moved to a parenthetical naming it `prior_SZ`, the
      TR-derived past-mirror of `prior_UZ`; RTime lists only `prior_U_gap` and `sep` as primitives
      with `prior_S_gap` noted as `prior_U_gap`'s derived mirror. Rename the column header so it
      no longer calls derived theorems axioms.
- [ ] Verify the "**29 constructors in nine layers**" paragraph (~line 199) now agrees with the
      table above it rather than contradicting it; adjust its wording only if the table's new
      column naming requires it.
- [ ] Check the remaining count-bearing prose in the Metalogical Results section for any figure
      the rewrite has orphaned.

**Timing**: 1.25 hours

**Depends on**: 1

**Scope Hypothesis**: Asserts the count occurrences live at README.md ~179-188 (graph),
~191-197 (table), ~199 (prose). Confirm with
`grep -n '\b\(23\|29\|37\|39\|40\|42\|45\)\b' README.md` before editing; treat any occurrence
outside those ranges as in-scope for this phase too.

**Verification Tier**: prose

**Files to modify**:
- `README.md` - mermaid graph node labels, Axiom Systems table (count column, Additional Axioms
  column, header naming), adjacent count prose

**Verification**:
- Every headline number in the table and graph equals a figure derivable from
  `Axiom.minFrameClass`; every retained 37/40/39/42/45 figure is adjacent to an explicit
  "including derived mirrors" label and a link to `docs/reference/axiom-reference.md`
- No cell or node text asserts a derived theorem is an `Axiom` constructor
- `grep -rniE '\b(14|21|42|44|45)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)' README.md`
  returns nothing
- The mermaid block still parses (fenced ```mermaid, `graph TD`, unchanged edge lines)

---

### Phase 3: README.md navigation, structure tree and citation [NOT STARTED]

**Goal**: Close dispatch items (3), (4) and (7) on README.md — correct directory nesting, a
top-matter `MainResults.lean` entry point, and one citation convention.

**Tasks**:
- [ ] Project Structure tree (item 3): move `MinusLanguage/` and `PlusLanguage/` from direct
      children of `FormalSystem/` to children of `Syntax/`, and add the missing `StarLanguage/`
      alongside them. Keep the box-drawing characters and comment-column alignment consistent with
      the surrounding tree.
- [ ] Confirm the tree's `ProofSystem/` comment ("Axioms (29 constructors, nine layers)") still
      agrees with Phase 2's convention; leave it if so.
- [ ] Main Results link (item 4): add a `**Main Results**:
      [MainResults.lean](FormalSystem/MainResults.lean)` line to the top matter alongside the
      existing Paper / Bimodal Reference Manual / Demo lines (README.md:15-19), with a one-line
      description drawn from `MainResults.lean`'s own header. Keep the existing Demo link — it is
      a complementary artifact, not a replacement.
- [ ] Citation (item 7): change README.md:103's "(Brast-McKie, 2025)" to the same "forthcoming"
      phrasing used at README.md:15. Set the BibTeX `year` field (README.md:430-437) to `{2025}`
      to match the `brastmckie2025construction` key, leaving `note = {Forthcoming}` in place.
      Leave the separate `@software{brastmckie2026bimodallogic}` entry untouched — its 2026 is
      the software's own year, not the paper's.
- [ ] Sweep the whole README for any other in-text year citation of the paper and align it.

**Timing**: 0.75 hours

**Depends on**: 2

**Scope Hypothesis**: Asserts the tree lines sit at README.md ~115-116, the top matter at 15-19,
the in-text citation at 103, and the BibTeX entry at 430-437. Re-derive each with `grep -n`
immediately before editing — Phase 2's edits shift line numbers in this same file.

**Verification Tier**: prose

**Files to modify**:
- `README.md` - Project Structure tree nesting, top-matter Main Results link, in-text citation,
  BibTeX `year` field

**Verification**:
- Every path shown in the Project Structure tree exists: check each with
  `ls` / `test -d`, in particular `FormalSystem/Syntax/{Minus,Plus,Star}Language/`
- `bash scripts/readme-lint.sh` passes (link resolution)
- Every relative link in README.md resolves from the repo root for a reader with no private-repo
  access; no remaining occurrence of "(Brast-McKie, 2025)"
- The BibTeX key, its `year` field and every in-text citation tell one story

---

### Phase 4: FormalSystem/README.md counts, frame-class naming and TODO row [NOT STARTED]

**Goal**: Bring `FormalSystem/README.md` into agreement with the live `FrameClass` enum and the
primitive-count convention, and fill the empty `MainResults.lean` inventory description
(item 8).

**Tasks**:
- [ ] Layer table (~lines 96-118): replace the `Frame Class` column's `Discrete` with `ZTime` and
      `Dedekind` with `RTime` (rows 6, 7, 9); fix the "Frame classification" paragraph's
      "2 Discrete-only … 2 Dedekind-only. Cumulatively (`Dense ≤ Dedekind`) …" to the live class
      names and to figures confirmed against `Axiom.minFrameClass`.
- [ ] Logic Variants section (~lines 158-219): retitle `### TM Base (37 constructor axioms)` to
      the primitive count; retitle `### TM Discrete` → `### TM ZTime` and `### TM Dedekind` →
      `### TM RTime` with corrected constructor arithmetic; correct their `Additional Axioms`
      bullets so derived mirrors (`prior_SZ`, `prior_S_gap`) are labelled derived rather than
      listed as primitives.
- [ ] Replace every citation of a nonexistent declaration in that section —
      `completeness_discrete`, `completeness_dedekind`, `soundness_dedekind` — with the live names
      (`completeness_ztime`, `completeness_rtime`, `soundness_rtime`); confirm each replacement
      exists with `grep -rn` under `FormalSystem/` (excluding `Boneyard/`) before writing it.
      If a live counterpart does not exist, remove the claim rather than inventing a name.
- [ ] `### Variant Incompatibility` (~lines 215-219) and the `Key Results Proven` table
      (~line 228, "Discrete Completeness"): same rename pass.
- [ ] Line ~252: replace `<!-- TODO: add description -->` in the generated inventory row for
      `MainResults.lean` with a one-line description. Check whether the row sits inside a
      `<!-- BEGIN GENERATED -->` block that a script regenerates — if so, fix the generator's
      description source rather than the rendered row, and note which was done.
- [ ] Add a pointer from the layer table to `docs/reference/axiom-reference.md`'s
      `Two axiom counts` section instead of restating the derivation here.

**Timing**: 1.25 hours

**Depends on**: 1

**Scope Hypothesis**: Asserts the stale `Discrete`/`Dedekind` occurrences are confined to
`FormalSystem/README.md` lines ~104-107, 116-117, 160-219 and 228, and that exactly one
`<!-- TODO: add description -->` remains at ~252. Confirm with
`grep -n 'Discrete\|Dedekind\|TODO: add description' FormalSystem/README.md` and treat the grep
output, not this list, as the work set.

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/README.md` - layer table frame-class column, frame-classification paragraph,
  Logic Variants section (headings, counts, declaration names), Variant Incompatibility, Key
  Results table, MainResults.lean inventory description

**Verification**:
- `grep -n 'Discrete\|Dedekind' FormalSystem/README.md` returns only legitimate uses (e.g.
  "Dedekind-complete" as a mathematical property, "DedekindDerived.lean" as a real filename), no
  `FrameClass.Discrete` / `FrameClass.Dedekind`
- Every declaration name cited in the file resolves under `FormalSystem/` outside `Boneyard/`
- No `<!-- TODO: add description -->` remains in the file
- Counts agree with `Axiom.minFrameClass`; the regex check from Phase 1 returns nothing for this
  file (note: it is outside C14's markdown scope, so the check must be run explicitly here)

---

### Phase 5: docs/ sibling count fixes and stale API code block [NOT STARTED]

**Goal**: Correct `docs/reference/API_REFERENCE.md` and `docs/user-guide/architecture.md`,
replacing the stale hand-copied axiom block rather than patching it (Decision 3).

**Tasks**:
- [ ] `docs/reference/API_REFERENCE.md` (~line 268): replace "The **45** axiom constructors …
      Base 37, Dense 2, ZTime 3, RTime 3" with the primitive convention, and correct the per-class
      breakdown (RTime extends Dense; it does not stand alone). Link
      `docs/reference/axiom-reference.md`'s `Two axiom counts` section for the 45-name figure.
- [ ] `docs/reference/API_REFERENCE.md` (~lines 272-293): delete the inline
      `inductive Axiom : Formula → Prop` block — the universe is wrong (live type is
      `Formula → Type`), it lists `modal_4`, `modal_b`, `temp_k_dist`, `temp_4`, `temp_a`,
      `temp_l` which are derived theorems today, and it omits the Until/Since, seriality,
      uniformity, Prior, Z1 and Reynolds layers. Replace with a short pointer to
      `FormalSystem/ProofSystem/Axioms.lean` plus the per-layer table already maintained in
      `docs/reference/axiom-reference.md`.
- [ ] Re-check the `#### Axiom Categories` prose that follows the block (~lines 295-316): it names
      M4, MB, TK, T4, TA as axioms. Mark the ones that are derived theorems as derived, or fold
      the list into the pointer.
- [ ] `docs/user-guide/architecture.md:867`: fix "its 37 axioms are valid on all linear temporal
      orders" to the primitive count, phrased to avoid the C14 adjacency.
- [ ] `docs/user-guide/architecture.md:1078`: confirm "29 constructors, 4 layers" — the layer
      count disagrees with the nine layers used elsewhere; align it to whichever the source
      supports.

**Timing**: 1 hour

**Depends on**: 1

**Scope Hypothesis**: Asserts two files and the line anchors above. Confirm first with
`grep -rn '\b\(37\|42\|45\)\b' docs/ | grep -i 'axiom\|constructor\|schema'` — any additional hit
under `docs/` outside these two files belongs to this phase.

**Verification Tier**: prose

**Files to modify**:
- `docs/reference/API_REFERENCE.md` - Axioms section count sentence, stale inline code block
  (replaced by pointer), Axiom Categories prose
- `docs/user-guide/architecture.md` - line ~867 count, line ~1078 layer figure

**Verification**:
- No Lean code block remains in `API_REFERENCE.md`'s Axioms section that transcribes constructors
- `grep -rniE '\b(14|21|42|44|45)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)' docs README.md`
  returns nothing
- Every count agrees with `Axiom.minFrameClass`; every link added resolves
- `bash scripts/readme-lint.sh` passes

---

### Phase 6: Lean docstring counts and stale relative links [NOT STARTED]

**Goal**: Close the `.lean` half of items (1) and (4) — comment-only edits to three files.

**Tasks**:
- [ ] `FormalSystem/Examples/BimodalProofs.lean` lines 40 and 244: change
      `../ProofChecker/Theorems/Perpetuity.lean` to `../Theorems/Perpetuity.lean` in both
      occurrences. `ProofChecker/` is a role name, not a directory — confirm no such directory
      exists and that `FormalSystem/Theorems/Perpetuity.lean` does.
- [ ] Re-grep the whole file (and `FormalSystem/Examples/`) for any further `../ProofChecker/`
      relative link introduced by the same copy-paste.
- [ ] `FormalSystem/Automation/BenchmarkAnchorsMain.lean` (~lines 17-18, 33, 47, 338, 340, 475-476,
      500): the file's 45-name convention is internally consistent and stays, but retitle
      "constructors" to "schemata"/"names" wherever the referenced set includes derived mirrors
      (notably line 338's "Base-class axioms (37 constructors)" and line 340's "non-Base axioms
      (8 constructors: …)"), so `Axiom` constructors are never conflated with `DerivedAxioms`
      theorems. Leave `allAxiomNames`-related references to the 29-name list saying "constructors".
- [ ] `FormalSystem/Metalogic/Independence/RationalWitness.lean:26`: fix "this covers the 37 Base
      axioms" to the primitive count. Note the line contains "covers", which exempts it from C14 —
      keep the word if the claim really is a subset claim, drop it if the corrected figure is a
      total.
- [ ] Add, to the `BenchmarkAnchorsMain.lean` header docstring, a one-line pointer to
      `docs/reference/axiom-reference.md`'s `Two axiom counts` section.

**Timing**: 0.75 hours

**Depends on**: 1

**Scope Hypothesis**: Asserts three `.lean` files, two stale-link occurrences, and the
BenchmarkAnchors line anchors above. Confirm with
`grep -rn 'ProofChecker/' FormalSystem/ --include='*.lean'` and
`grep -rniE '\b(37|42|45)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)' FormalSystem --include='*.lean' | grep -v Boneyard`.

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/Examples/BimodalProofs.lean` - two stale relative links (lines 40, 244)
- `FormalSystem/Automation/BenchmarkAnchorsMain.lean` - docstring terminology and count labelling
- `FormalSystem/Metalogic/Independence/RationalWitness.lean` - line 26 count

**Verification**:
- `git diff` read-through confirming **every** changed hunk in all three files lies inside a
  `/-! … -/`, `/-- … -/`, or `--` comment region — no hunk touches a term, tactic, or declaration
  (this is the `prose` tier's named blind spot and is checked explicitly)
- `test -f FormalSystem/Theorems/Perpetuity.lean` succeeds; `grep -rn 'ProofChecker/'
  FormalSystem/ --include='*.lean'` returns nothing
- `bash scripts/check-module-invariants.sh --no-build` still passes, with C14 in particular still
  clean (these files are inside C14's `.lean` scope, so a bad phrasing here *will* be caught)

---

### Phase 7: Acceptance gate [NOT STARTED]

**Goal**: Verify the stated acceptance criteria end to end, by direct comparison rather than by
trusting a check that is known blind to these defects.

**Tasks**:
- [ ] `bash scripts/check-module-invariants.sh --no-build` — green, and specifically confirm C14,
      C21 and C22 report as expected.
- [ ] `bash scripts/readme-lint.sh` — green.
- [ ] Run C14's own regex over the full changed set as an anti-regression check:
      `grep -rniE '\b(14|21|42|44|45)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)' docs README.md`
      and the `.lean` variant over `FormalSystem` (excluding `Boneyard/`, requiring `axiom`,
      excluding `covers`) — both must return nothing newly introduced.
- [ ] Direct count audit: for each of README.md, FormalSystem/README.md,
      docs/reference/API_REFERENCE.md, docs/user-guide/architecture.md,
      FormalSystem/Automation/BenchmarkAnchorsMain.lean,
      FormalSystem/Metalogic/Independence/RationalWitness.lean — list every axiom-count figure the
      file now states and check it against `Axiom.minFrameClass` / `allAxiomNames` /
      `scripts/typst-status-counts.sh`. Record the audit table in the summary.
- [ ] Anonymous-reader link sweep: resolve every relative link in README.md and
      FormalSystem/README.md from the repo root; confirm no link points into a private or
      gitignored path (BimodalHarness stays plain text; `training/` is gitignored).
- [ ] Confirm no task-number reference was introduced into any file outside `specs/**`
      (`bash scripts/check-task-references.sh` if present).
- [ ] Confirm items 5 and 6 remain satisfied (no `latex/BimodalReference.pdf` reference; the two
      BimodalHarness mentions still plain text).

**Timing**: 0.5 hours

**Depends on**: 2, 3, 4, 5, 6

**Verification Tier**: full

**Files to modify**:
- none (verification only; any defect found is repaired in the owning phase)

**Verification**:
- Both acceptance scripts green
- Zero count disagreements in the audit table
- Zero unresolvable links

---

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0
- [ ] `bash scripts/readme-lint.sh` exits 0
- [ ] No axiom-count figure in any of the eight named files disagrees with
      `FormalSystem/ProofSystem/Axioms.lean`
- [ ] Every relative link in README.md and FormalSystem/README.md resolves from the repo root
- [ ] Every `.lean` diff hunk lies strictly inside a comment region
- [ ] No newly-introduced match for C14's stale-count regex
- [ ] No task-number reference outside `specs/**`

## Artifacts & Outputs

- `docs/reference/axiom-reference.md` — new `Two axiom counts` canonical derivation section
- `README.md` — corrected counts, labelled derived mirrors, corrected structure tree, MainResults
  link, consistent citation
- `FormalSystem/README.md` — live frame-class names, corrected counts, filled inventory row
- `docs/reference/API_REFERENCE.md` — pointer replacing the stale axiom code block
- `docs/user-guide/architecture.md` — corrected counts
- `FormalSystem/Examples/BimodalProofs.lean` — corrected relative links
- `FormalSystem/Automation/BenchmarkAnchorsMain.lean`,
  `FormalSystem/Metalogic/Independence/RationalWitness.lean` — corrected docstring terminology
- `specs/639_readme_accuracy_and_entry_point_fixes/summaries/01_*-summary.md` — execution summary
  carrying the Phase 7 audit table

## Rollback/Contingency

Every change is text-only and confined to comments, docstrings and markdown; no Lean term, tactic
or declaration is touched, so no proof can break. Phases commit per green sub-step
(`per-substep`), so any individual file can be reverted with `git revert` of its own commit
without disturbing the others. If the Phase 4 `FormalSystem/README.md` rewrite proves larger than
estimated, the frame-class rename (Decision 2) can be split into a follow-up task — but the count
fix must not land without it, per that decision; in that case revert Phase 4 wholesale rather
than landing it half-done.
