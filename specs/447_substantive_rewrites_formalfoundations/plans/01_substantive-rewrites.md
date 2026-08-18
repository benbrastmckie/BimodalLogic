# Implementation Plan: Task #447

- **Task**: 447 - Substantive rewrites in FormalFoundations.typ: proof repair, axiom presentation, section restructure
- **Status**: [IMPLEMENTING]
- **Effort**: 8.5 hours
- **Dependencies**: 446 (complete)
- **Research Inputs**: `specs/447_substantive_rewrites_formalfoundations/reports/01_substantive-rewrites-research.md`
- **Artifacts**: plans/01_substantive-rewrites.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: false

## Overview

Six substantive `FIX:` directives in `typst/FormalFoundations.typ` require new mathematical
exposition transcribed from `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`.
The work decomposes into a source-transcription phase, seven bounded editing phases (each ending at
a green `typst compile`), and a closing verification sweep. Every editing phase locates its target
by **FIX-tag content anchor**, never by line number, because sibling task 446 has already shifted
all line numbers cited in the task description and the research report.

The plan replaces prose-compressed axiom lists with formalized `#items` blocks, adds the seven-link
lemma ladder the Extension proof needs, gives the proof-systems section a system-by-system account
with every axiom stated in full, and replaces the section introduction with a concrete walk of what
the section covers.

### Line-Number Drift Notice (read before Phase 1)

All `:NNN` references in the task description and in the research report are **stale**. Sibling
task 446 restored eight commented blocks in this same file, shifting everything downward. The six
substantive FIX tags are the *only* FIX tags remaining in the file (the bare `// FIX:` tags 446
consumed are gone). Their positions as of this plan's authoring:

| Task-description ref | Current line | Anchor text (grep target) |
|---|---|---|
| `:244` | 260 | `FIX: this proof is inadequate` |
| `:267` | 282 | `FIX: this needs to be expanded to be easier to read` |
| `:353` | 375 | `FIX: indent the axioms and formalize all of them` |
| `:362` | 384 | `FIX: this is unreadable and needs to be expanded` |
| `:369` | 391 | `FIX: everything in the remainder of this section` |
| `:393` | 417 | `FIX: some introduction would be good` |

These six numbers are themselves a hypothesis; Phase 1 re-confirms them and every later phase
re-greps before editing.

### Research Integration

The research report is Tier-1 reference-grounded: every claim about paper content carries a `\label`
anchor and tex line number, and the report already transcribes the S5 and BX axiom sets in full.
This plan consumes the report's Findings 1 (Extension lemma ladder), Findings 2 (Task Topology six
sub-items), Findings 3 (S5 five keys + BX seventeen keys, with the glyph-to-macro mapping table),
Findings 4 (ten proof systems, containment lattice, frame-class axioms in full), and Findings 5
(the five topics `sec:key-theorems` actually covers).

Two research decisions are adopted verbatim and are binding on the implementer:
- **Decision 2** — the `:369` rewrite transcribes proof-system *definitions* only. It must not
  import `cor:tm-completeness`'s claims; the typ document's own completeness accounting
  (`== Completeness`, currently line 470ff) stays authoritative for what is proved.
- **Decision 3** — the current table's "*Reynolds triple* Prior-U, Prior-S, Sep" is a transcription
  error. The paper postulates **Prior-U and Sep** only; the since-direction follows by TD.

The research recommended the *condensed* transcription for `:244` (option (b), Findings 1). This
plan adopts it: four new blocks (Constraints, Directedness, Admissibility, Step) rather than the
seven-link ladder, with nesting/nonempty folded into Directedness's proof and `lem:fibers` folded
into Admissibility's.

### Effect of Sibling Task 446 on `:362` and `:369`

The delegation asked whether 446's newly-live text changes what these rewrites must say. It does,
in two concrete ways:

1. **`#definition("Validity and Consequence")` is now live** (line 356), defining `⊨` and frame
   validity. The document therefore now defines the semantic turnstile but still nowhere defines
   the derivability relation `⊢` — even though the Soundness theorem (line 430) is stated as
   "If ⊢ φ then ⊨ φ". This is a genuine self-containedness gap that the `:369` directive's
   "each clearly defined" language covers. **Phase 6 adds `#definition("Derivability")`**,
   transcribed from `def:derivability` (tex:3602-3604).
2. **The `#remark[...]` at line 300 is now live**, asserting that "the order taken here keeps
   *Spherical* visible at the single site where it is used" — and the restored prose at line 274
   asserts "The Step Lemma is the sole application site of *Spherical*... and Extension is the
   sole consumer of the Step Lemma." Both sentences currently name a lemma the document never
   states. Phase 8 makes them true by putting a live `#lemma("Step")` in the document, and must
   re-read and knit both passages rather than leaving them dangling.

Neither change affects the BX axiom list itself; `:362` is unchanged in substance by 446.

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` supplied in the delegation context and no ROADMAP.md consulted.

## Reference-Grounding Approach

**Authoritative source**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
(4174 lines; verified readable during research).

**Sections to transcribe from, per target**:

| Target | Source anchors | tex lines |
|---|---|---|
| `:244` Extension | `def:constraints`, `lem:nesting`, `lem:nonempty`, `lem:constraint`, `lem:fibers`, `lem:admissible`, `lem:step`, `cor:spherical-finite`, `thm:extension` + proof | 2749-2867 |
| `:267` Task Topology | `def:task-topology` | 2633-2643 |
| `:353` S5 | `def:S5` | 3799-3812 |
| `:362` BX | `def:BX` | 3817-3861 |
| `:369` (BL+ level) | `def:TMplus-f`, `def:TMplus-d`, `def:TMplus-c`, `def:TMplus` | 3866-3940 |
| `:369` (BL level) | `sub:Logic` (TM), `sub:Extension` (TM_f/d/c/dc), `def:derivability` | 1148-1172, 1244-1255, 3602-3604 |
| `:393` intro | none — derived from the typ document's own §2 content | typ 415-570 |

**How faithfulness is checked**:

1. **Phase 1 builds a transcription record** at
   `specs/447_substantive_rewrites_formalfoundations/reports/02_source-transcription.md`. For every
   named key it records three columns: the tex line number, the LaTeX source string verbatim, and
   the intended Typst rendering. Nothing is rendered from memory at edit time.
2. **The notation mapping table is normative** (research Findings 3):
   `\Box`→`square.stroked`, `\Diamond`→`diamond.stroked`, `\Future` (G, universal)→`#allfuture`,
   `\future` (F, existential)→`#somefuture`, `\Past` (H)→`#allpast`, `\past` (P)→`#somepast`,
   `\until` (▷)→`#until`, `\since` (◁)→`#since`, `\Next`→`#Nxt`, `\Previous`→`#Prev`,
   `\always`→`#always`, `\sometimes`→`#sometimes`. Case inversion between universal and
   existential tense operators is the single most likely transcription error; the record makes it
   checkable line by line.
3. **Count invariants** are asserted and re-checked in Phase 9: S5 = 5 keys (MK, MT, M5, MP, MN);
   BX = 17 keys (TN, TD; TB, TL, CN; TA, UE, UT, UI, UC, UF, UG, SU; NP, NF, NA, NB);
   BX_f = 2 (UZ, Z1); BX_d = 2 (DN, NN); BX_c = 2 postulated (Prior-U, Sep) + 1 derived (CO);
   TM (BL level) = 3 rules (MP, MN, TD) + 9 axioms (MK, MT, M5, MF, TK, T4, TB, TA, TL).
4. **Scope guards**: no phase may cite `cor:tm-decidability` (commented out in the live paper,
   tex:3995). No phase may import `cor:tm-completeness`'s completeness claims (contradiction C-1).
5. **Citation-integrity rule**: every lemma named in the repaired Extension proof must resolve to a
   `#lemma`/`#definition` block live in this document, or to an explicitly cited paper anchor in a
   footnote. Phase 9 audits this by grepping each cited name against the document's own block names.

## Goals & Non-Goals

**Goals**:
- Remove all six substantive `FIX:` tags from `typst/FormalFoundations.typ`, each by satisfying its
  directive rather than by deletion.
- Make the Extension proof self-supporting: every lemma it cites is stated live in the document.
- State every named axiom of S5, BX, BX_f, BX_d, BX_c, TM+, TM+_f/d/c, and BL-level TM in full
  formalized form, in indented `#items` blocks matching the house style.
- Define the derivability relation `⊢`, closing the gap left by 446's now-live `⊨` definition.
- Keep `typst compile typst/FormalFoundations.typ` green at the end of every phase.

**Non-Goals**:
- Touching any of task 445's 39 footnote FIX tags (a separate task; those tags are absent from this
  file's current FIX inventory anyway).
- Revising the document's completeness or decidability *claims* (research Decision 2); only
  definitions are transcribed into the proof-systems section.
- Editing `possible_worlds.tex` in any way — it is read-only source.
- Adding or changing any `#leansrc` reference, or touching any Lean file.
- Reconciling the paper's `cor:tm-completeness` against the typ document's Lean-grounded accounting
  (flagged in research as contradiction C-1; out of scope here).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Line-number drift causes an edit at the wrong site | H | H | Every phase re-greps its FIX-tag anchor text immediately before editing; Phase 1 re-establishes the full anchor map |
| Tense-glyph case inversion (G/F, H/P) in transcription | H | M | Normative mapping table above; Phase 1 transcription record pairs LaTeX source with Typst rendering per key; Phase 9 re-diffs every key against the record |
| Extension proof cites a lemma that is still not live | H | M | Phase 8 introduces all four blocks before restoring the proof; Phase 9 citation-integrity audit greps each cited name |
| 446's restored prose at line 274 / remark at line 300 left dangling | M | H | Phase 8 explicitly re-reads and knits both passages; Phase 9 read-through covers the region |
| Importing overstated completeness claims from the paper | M | M | Research Decision 2 encoded as a Non-Goal and as a Phase 5 constraint |
| Citing the dead anchor `cor:tm-decidability` | M | L | Named scope guard; Phase 9 greps for it |
| Long `#items` blocks inside thmbox environments break compilation | M | L | Existing definitions already do this (e.g. `#definition("Frame")`, line 209); compile after every phase catches it |
| `:369` region grows past one agent run | M | M | Split across Phases 5 and 6 with disjoint content contracts |
| Table's "Prior-S" error silently reproduced | L | M | Research Decision 3 encoded as an explicit Phase 5 task item |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

The chain is strictly linear by construction. Phases 2-8 are content-independent of one another and
would otherwise parallelize, but all seven edit the **same file**, so they are serialized to avoid
write conflicts and compounding line drift. No phase may be run concurrently with another.

---

### Phase 1: Re-anchor and Build Source Transcription Record [COMPLETED]

**Goal**: Establish the authoritative anchor map against the current working tree and produce the
per-key transcription record that every later phase edits from, so that no editing phase reads
`possible_worlds.tex` under time pressure or renders notation from memory.

**Tasks**:
- [x] Run `grep -n "FIX:" typst/FormalFoundations.typ` and confirm exactly six tags remain; record
      the current line number and full anchor text of each.
- [x] Record the current line number of each landmark the later phases key off:
      `#theorem("Extension")`, the commented Extension proof block, `#corollary("Occurrence")`,
      the Step-Lemma prose paragraph, `#definition("Task Topology")`, `#theorem("Separation")`,
      the `#remark[` following it, `#definition("Validity and Consequence")`,
      `== Proof Systems`, `#definition("S5")`, `#definition("BX")`, the `#figure(table(...))`
      of frame-class extensions, the Hölder paragraph, and `= Completeness and Decidability`.
- [x] Read `possible_worlds.tex` at 2633-2643, 2749-2867, 3799-3861, 3866-3940, 1148-1172,
      1244-1255, 3602-3604.
- [x] Write `reports/02_source-transcription.md` with one row per named key: `key | tex line |
      LaTeX source verbatim | Typst rendering`. Cover all of: the six Task-Topology sub-items;
      Constraints / Nesting / Nonempty / Constraint / Fibers / Admissible / Step /
      spherical-finite statements and the Extension proof's four steps; S5's 5 keys; BX's 17 keys;
      UZ, Z1, DN, NN, Prior-U, Sep, CO, and the K⁺/K⁻ abbreviations; MF; BL-level TM's 3 rules and
      9 axioms; DF, DN, CO for TM_f/d/c; the derivability relation.
- [x] Confirm the macro inventory is sufficient for every rendering (`#allpast`, `#allfuture`,
      `#somepast`, `#somefuture`, `#since`, `#until`, `#Nxt`, `#Prev`, `#always`, `#sometimes`,
      `#BL`, `#BLplus`, `#items`); note any key whose rendering needs a construct not yet present.
- [x] Run `typst compile typst/FormalFoundations.typ` to record the pre-edit baseline (expected:
      exit 0 with two pre-existing "new computer modern sans" font warnings from thmbox). *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This plan asserts exactly six remaining FIX tags at lines 260, 282, 375, 384,
391, 417, and asserts the key counts listed under "Reference-Grounding Approach" item 3. The
implementer confirms all of these against the working tree and against `possible_worlds.tex` in
this phase, and records any divergence in the transcription record before Phase 2 begins.

**Files to modify**:
- `specs/447_substantive_rewrites_formalfoundations/reports/02_source-transcription.md` - new;
  the per-key transcription record

**Verification**:
- The transcription record exists and has a row for every key named in the task list above.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 6.
- `typst compile typst/FormalFoundations.typ` exits 0 (baseline unchanged; no `.typ` edit in this
  phase).

---

### Phase 2: Replace the Section Introduction (`:393`) [COMPLETED]

**Goal**: Replace the FIX tag and the commented-out "platitude" remark under
`= Completeness and Decidability` with a concrete 3-5 sentence overview of what the section
actually covers.

**Tasks**:
- [x] Re-grep `FIX: some introduction would be good` to locate the target.
- [x] Read the whole section end to end, from `= Completeness and Decidability` to the next `= `
      heading, to confirm the five topics it covers.
- [x] Write a replacement paragraph that walks, concretely and without platitude: soundness for TM
      and its four frame-class extensions; the three correspondences (DF↔Discrete, DN↔Dense,
      CO↔Complete); the perpetuity collapse of mixed modal-tense prefixes; the completeness picture
      with its BL/BL+ asymmetry (nothing positive at the BL level, three machine-checked weak
      results at the BL+ level, base case outstanding); and decidability open, with the failed
      uniform-FMP premise and the `Log(all) = Log(Discrete) ∩ Log(Dense)` reduction as the live
      strategy rather than a result.
- [x] Delete the FIX tag and the commented-out `#remark[...]` block entirely.
- [x] Make no claim the section does not itself substantiate; do not cite `cor:tm-decidability`.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - replace the FIX tag and commented remark following
  `= Completeness and Decidability` with the new introduction

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 5.
- The commented `// #remark[` block under the section heading is gone.
- Every claim in the new paragraph maps to a named theorem or remark later in the same section.

---

### Phase 3: Formalize the S5 Axioms (`:353`) [COMPLETED]

**Goal**: Rewrite `#definition("S5")` so all five keys are stated in full inside an indented
`#items` block, in the house style.

**Tasks**:
- [x] Re-grep `FIX: indent the axioms and formalize all of them` to locate the target.
- [x] Replace the run-on prose body of `#definition("S5")` with the paper's framing sentence
      ("the smallest extension of classical propositional logic CPL closed under the following
      schemata, rule, and metarule") followed by an `#items[...]` block with one
      `+ *KEY*: $...$` entry per key: MK, MT, M5, MP, MN.
- [x] Render each from the Phase 1 transcription record; keep the paper's own distinction that
      MK/MT/M5 are axiom schemata, MP a rule, MN a metarule.
- [x] Match the style of `#definition("Defined Operators")` and `#definition("Frame")` for
      indentation and item phrasing.
- [x] Delete the FIX tag.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: S5 has exactly five named keys (MK, MT, M5, MP, MN). The implementer confirms
against `def:S5`, tex:3799-3812, via the Phase 1 record before writing.

**Files to modify**:
- `typst/FormalFoundations.typ` - body of `#definition("S5")`

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 4.
- The rendered PDF shows five indented, numbered items under the S5 definition.
- Each of MK, MT, M5, MP, MN appears with a full formal statement, matching the Phase 1 record.

---

### Phase 4: Formalize the Seventeen BX Keys (`:362`) [COMPLETED]

**Goal**: Expand `#definition("BX")` from a bare name-list into a self-contained definition stating
all seventeen keys in full, grouped as the paper groups them.

**Tasks**:
- [x] Re-grep `FIX: this is unreadable and needs to be expanded` to locate the target.
- [x] Open with the paper's preamble, defining the ⟨S|U⟩-swap notation ("φ_⟨S|U⟩ denotes the result
      of swapping occurrences of `#since` and `#until` in φ") **before** TD uses it.
- [x] State all seventeen keys in `#items` blocks, in the paper's four groups: rules (TN, TD);
      seriality/linearity/connectedness (TB, TL, CN); primary Since/Until (TA, UE, UT, UI, UC, UF,
      UG, SU); uniformity (NP, NF, NA, NB).
- [x] Retain the paper's closing framing ("the smallest extension of CPL closed under all instances
      of the above") and the sentence that the past/since direction of each axiom is derived by TD,
      not postulated. The existing trailing footnote already says this — reconcile so the point is
      made once, not twice.
- [x] Transcribe NB (`Next⊤ → □Next⊤`) as stated even though `□` is only interpreted once S5 is
      fused in; it belongs to BX in the paper.
- [x] Note in the uniformity group that these hold vacuously unless the order is discrete.
- [x] Delete the FIX tag.

**Timing**: 1.0 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: BX has exactly seventeen named keys, partitioned 2 + 3 + 8 + 4. The
implementer confirms the partition and each statement against `def:BX`, tex:3817-3861, via the
Phase 1 record before writing.

**Files to modify**:
- `typst/FormalFoundations.typ` - body of `#definition("BX")` and its trailing footnote

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 3.
- Counting the item entries under the BX definition yields exactly 17.
- Each of TN, TD, TB, TL, CN, TA, UE, UT, UI, UC, UF, UG, SU, NP, NF, NA, NB appears with a full
  statement matching the Phase 1 record; universal-vs-existential tense operators spot-checked on
  TB (`#somefuture top`), UE (existential F in the consequent), and TA (universal G).

---

### Phase 5: Systematic Account of the BL+ Proof Systems (`:369`, part 1) [COMPLETED]

**Goal**: Replace the compressed remainder of the Proof Systems section with system-by-system
definitions of TM+, BX_f, BX_d, BX_c, and TM+_f/d/c, every additional axiom stated in full.

**Tasks**:
- [x] Re-grep `FIX: everything in the remainder of this section` to locate the target region; its
      lower bound is the Hölder paragraph, its upper bound the FIX tag.
- [x] Add `#definition("TM+")`: the smallest extension of S5 and BX including all instances of MF
      (`□φ → □Gφ`), displayed, named as the sole bimodal-interaction axiom. Keep the existing
      framing that it is the base logic for `#BLplus`.
- [x] Add `#definition("BX_f")` (*Discrete Burgess--Xu Tense Logic*) = BX + UZ, Z1, both stated in
      full, with the paper's glosses (UZ: nearest future witness with ¬φ throughout the intervening
      interval; Z1: backward induction, characteristic of successor-Archimedean frames).
- [x] Add `#definition("BX_d")` (*Dense Burgess--Xu Tense Logic*) = BX + DN, NN, both stated in
      full, noting DN coincides with TM's DN and NN is specific to the BL+ level.
- [x] Add `#definition("BX_c")` (*Complete Burgess--Xu Tense Logic*) = BX + Prior-U, Sep, both
      stated in full, with the K⁺/K⁻ abbreviations defined first
      (`K⁺φ := ¬(¬φ ▷ ⊤)`, `K⁻φ := ¬(¬φ ◁ ⊤)`) and their readings given. State that CO is a
      **derived theorem** of BX_c from Prior-U and the BX base, not a further axiom.
- [x] State TM+_f, TM+_d, TM+_c as TM+ plus the axioms that distinguish BX_f, BX_d, BX_c
      respectively.
- [x] Retain the summary `#figure(table(...))` but correct the TM+_c row: replace "the *Reynolds
      triple* Prior-U, Prior-S, Sep" — the paper postulates Prior-U and Sep only, the since
      direction following by TD. Adjust the trailing footnote about CO accordingly if it presupposes
      the triple.
- [x] Retain the Hölder paragraph unchanged; it is accurate against tex:3877 and tex:3916-3918.
- [x] Keep the existing `#leansrc("ProofSystem", "FrameClass")` reference in place.
- [x] **Constraint (research Decision 2)**: transcribe definitions only. Do not import any
      completeness claim from `cor:tm-completeness`; do not cite `cor:tm-decidability`.
- [x] Delete the FIX tag.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: The BL+ level comprises exactly the systems S5, BX, BX_f, BX_d, BX_c, TM+,
TM+_f, TM+_d, TM+_c, with additional-axiom counts 2 / 2 / 2 (+1 derived). The implementer confirms
against `def:TMplus-f/d/c` and `def:TMplus`, tex:3866-3940, via the Phase 1 record.

**Files to modify**:
- `typst/FormalFoundations.typ` - the region from the `:369` FIX tag through the frame-class
  extensions table and its footnote

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 2.
- `grep -c "Prior-S" typst/FormalFoundations.typ` returns 0.
- Each of UZ, Z1, DN, NN, Prior-U, Sep, CO, MF appears with a full formal statement.
- `grep "cor:tm-completeness\|cor:tm-decidability" typst/FormalFoundations.typ` shows no new
  occurrence introduced by this phase.
- The Hölder paragraph is byte-identical to its pre-phase text.

---

### Phase 6: BL-Level TM, Its Extensions, and the Derivability Relation (`:369`, part 2) [COMPLETED]

**Goal**: Close the two remaining self-containedness gaps in the proof-systems section: the
document names TM and TM_f/TM_d/TM_c/TM_dc throughout §2 without ever defining them, and it defines
`⊨` (live since task 446) without defining `⊢`.

**Tasks**:
- [x] Append, after the Hölder paragraph and before `= Completeness and Decidability`, a
      `#definition("TM")`: the *Logic of Tense and Modality* for `#BL`, the smallest extension of
      CPL closed under all instances of — rules MP, MN, TD (here TD swaps `#allpast` and
      `#allfuture`); modal axioms MK, MT, M5; the interaction axiom MF; temporal axioms TK, T4, TB,
      TA, TL. All stated in full in an `#items` block.
- [x] Add the BL-level extensions: TM_f := TM + DF (`(Hφ ∧ φ ∧ F⊤) → F Hφ`), TM_d := TM + DN,
      TM_c := TM + CO, TM_dc := the minimal extension of TM_d and TM_c. State DF, DN, CO in full —
      the document currently uses these three names in the Correspondence subsection without ever
      stating them as axioms.
- [x] Note the paper's point that TM cannot include both DF and DN consistently, since no temporal
      order is both discrete and dense. Do not overstate this as a claim about the systems' mutual
      inconsistency beyond what the paper says.
- [x] Add `#definition("Derivability")` transcribing `def:derivability` (tex:3602-3604): `⊢` is the
      smallest relation closed under the axioms and rules for TM. Place it so the Soundness theorem
      in the next section ("If ⊢ φ then ⊨ φ") has a live referent, and so it reads as the
      proof-theoretic counterpart to the now-live `#definition("Validity and Consequence")`.
- [x] Note that TM's TL and BX's TL list the same three disjuncts in different orders; this is the
      paper's own presentation and is **not** a discrepancy to normalize.

**Timing**: 1.0 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: BL-level TM comprises 3 rules (MP, MN, TD) and 9 axioms (MK, MT, M5, MF, TK,
T4, TB, TA, TL), with four extensions via DF, DN, CO. The implementer confirms against `sub:Logic`
(tex:1148-1172) and `sub:Extension` (tex:1244-1255) via the Phase 1 record.

**Files to modify**:
- `typst/FormalFoundations.typ` - append TM, TM extensions, and Derivability definitions at the end
  of the `== Proof Systems` section

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `grep -c "FIX:" typst/FormalFoundations.typ` still returns 2 (this phase removes no tag; the
  `:369` tag was removed in Phase 5).
- DF, DN, CO each appear with a full formal statement at their point of definition, before their
  first use in the Correspondence subsection.
- `⊢` has a definition earlier in the document than the Soundness theorem that uses it.

---

### Phase 7: Expand the Task Topology Definition (`:267`) [NOT STARTED]

**Goal**: Break the compressed three-sentence Task Topology definition into indented sub-items in
the same style as the definitions above it.

**Tasks**:
- [ ] Re-grep `FIX: this needs to be expanded to be easier to read` to locate the target.
- [ ] Rewrite the body of `#definition("Task Topology")` as an `#items[...]` block with five
      `+ *Name*: ...` entries: **Basic Opens** (`B_F := {(w)_x : w ∈ W, x ∈ D, x > 0}`),
      **Topology** (`T_F := (W, O_F)` with `O_F` the closure of `B_F` under arbitrary union and
      finite intersection), **Closure** (`S̄`), **T1**, **R0**.
- [ ] Follow the style of `#definition("Task Relation")` (Fiber/Cone/Segment items) and
      `#definition("Frame")` (Compositionality/Seriality/Limit/Spherical items).
- [ ] Omit the paper's sixth sub-item **Discrete** — nothing live in this document or in the live
      paper consumes it (its sole consumer `app:topology-nondiscrete` is commented out in the
      paper), and the typ document elsewhere prunes paper content it does not use. Record this
      omission decision in the Phase 9 sweep notes.
- [ ] Do not restate the cone notation `(w)_x`; it is already defined in `#definition("Task
      Relation")`.
- [ ] Preserve the existing trailing footnote ("The topology is carried by the world states, not by
      H_F or by D") unchanged.
- [ ] Confirm the newly-live lead-in sentence above ("The cones are a basis for a topology on world
      states, and that topology is separated.") still reads correctly against the expanded
      definition.
- [ ] Delete the FIX tag.

**Timing**: 0.75 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: `def:task-topology` has six labeled sub-items in the paper, of which five are
transcribed here. The implementer confirms the sub-item list against tex:2633-2643 via the Phase 1
record, and confirms the **Discrete** item is genuinely unconsumed before omitting it.

**Files to modify**:
- `typst/FormalFoundations.typ` - body of `#definition("Task Topology")`

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 1.
- The rendered PDF shows five indented numbered items under the Task Topology definition, styled
  identically to the Frame definition's four.
- The `#theorem("Separation")` proof immediately below still refers only to notation the expanded
  definition introduces.

---

### Phase 8: Repair the Extension Proof (`:244`) [NOT STARTED]

**Goal**: Give the Extension proof the lemmas it cites, as live blocks in the document, then restore
the proof so every citation resolves — and knit the result with the two passages task 446 restored
that already presuppose a live Step Lemma.

**Tasks**:
- [ ] Re-grep `FIX: this proof is inadequate` to locate the target; note the commented `// #proof[`
      block it sits inside.
- [ ] Insert, between `#definition("History")` and `#theorem("Extension")`, four new blocks in this
      order (research Findings 1, condensed option (b)):
      1. `#definition("Constraints")` — for a partial history τ : X → W and z ∈ D \ X, the
         constraints on z: the segments `[τ(t), τ(s)]_(z−t)^(s−z)` for t, s ∈ X with t < z < s when
         assignments flank z, and the fibers `Fib(τ(t), z−t)` for t ∈ X otherwise.
         (`def:constraints`, tex:2749-2751.)
      2. `#lemma("Directedness")` — the constraints imposed on z form a directed family of nonempty
         sets (`lem:constraint`, tex:2783-2792), with the nesting argument (`lem:nesting`,
         tex:2753-2764, appealing to Compositionality and the converse convention) and the
         nonemptiness argument (`lem:nonempty`, tex:2770-2777, appealing to Seriality and
         Compositionality) folded into its proof.
      3. `#lemma("Admissibility")` — `τ ∪ {⟨z, u⟩}` is a partial history on X ∪ {z} iff u belongs
         to every constraint on z (`lem:admissible`, tex:2819-2827), with `lem:fibers`
         (tex:2799-2813) folded into its proof, and citing **Nullity** for the zero loop at z
         itself. Nullity's statement and proof are already live above.
      4. `#lemma("Step")` — every partial history extends to a partial history on X ∪ {z} for any
         z ∈ D (`lem:step`, tex:2829-2837), proved from Directedness, *Spherical*, and
         Admissibility, retaining the paper's closing remark that *Spherical* is not needed when the
         family has a ⊆-least member, as nesting provides whenever X contains a nearest assignment
         to z on each occupied side.
- [ ] Uncomment and repair the Extension proof, following tex:2862-2867 in four steps: partial
      histories extending τ are partially ordered by extension; every chain is bounded above by its
      union, which restricts on any pair of times to a single member of the chain and so is itself a
      partial history; Zorn's lemma yields a maximal σ : T → W extending τ; if T ≠ D then the Step
      Lemma extends σ to T ∪ {z} for z ∈ D \ T, contradicting maximality; so T = D and σ ∈ H_F.
- [ ] Handle `cor:spherical-finite` (tex:2843-2852: every frame with finite W satisfies *Spherical*,
      choice-free): it is already the subject of the live footnote in the Step-Lemma prose
      paragraph below. Either add it as a short corollary or leave it at footnote level; do not
      duplicate the claim in both places.
- [ ] Preserve the Extension theorem statement and its `#leansrc` reference unchanged; preserve
      `#corollary("Occurrence")` and its `#leansrc` unchanged.
- [ ] **Knit with task 446's restored text**: re-read the prose paragraph beginning "The Step Lemma
      is the sole application site of *Spherical*..." and the `#remark[` following the Separation
      proof ("...keeps *Spherical* visible at the single site where it is used"). Both now have a
      live referent; adjust their wording only as needed so they read as pointing at the newly
      stated `#lemma("Step")` rather than at an external paper result. Do not restate what the new
      lemma already says.
- [ ] Delete the FIX tag.

**Timing**: 1.75 hours

**Depends on**: 7

**Verification Tier**: interface

**Scope Hypothesis**: The Extension proof's dependency chain has seven links in the paper
(`def:constraints` → nesting → nonempty → constraint → fibers → admissible → step), condensed here
to four live blocks. The implementer confirms the chain and each statement against tex:2749-2867 via
the Phase 1 record, and confirms that none of the four is already live elsewhere in the document
before inserting.

**Files to modify**:
- `typst/FormalFoundations.typ` - insert four blocks before `#theorem("Extension")`; uncomment and
  rewrite the Extension proof; adjust the Step-Lemma prose paragraph and the post-Separation remark

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 0.
- The Extension proof names only: Zorn's lemma, the Step Lemma, and the definition of world history
  — and the Step Lemma is a live `#lemma` block above it.
- The Step Lemma's proof names only Directedness, *Spherical*, and Admissibility, all live above it.
- Admissibility's proof names Nullity, live above it.
- No commented-out `#proof[` block remains in the Histories section.

---

### Phase 9: Verification Sweep and Faithfulness Audit [NOT STARTED]

**Goal**: Confirm every acceptance criterion from the task description holds against the finished
file, and that no transcription drifted from the Phase 1 record.

**Tasks**:
- [ ] `grep -n "FIX:" typst/FormalFoundations.typ` returns nothing.
- [ ] `typst compile typst/FormalFoundations.typ` exits 0; diff the warning set against the Phase 1
      baseline and confirm only the two pre-existing thmbox font warnings remain.
- [ ] **Axiom completeness audit**: for every axiom name appearing anywhere in the document
      (MK, MT, M5, MP, MN, TN, TD, TB, TL, CN, TA, UE, UT, UI, UC, UF, UG, SU, NP, NF, NA, NB, MF,
      UZ, Z1, DN, NN, Prior-U, Sep, CO, DF, TK, T4), confirm a full formal statement exists at its
      point of definition. Grep each name and check.
- [ ] **Faithfulness re-diff**: for every key, compare the rendered Typst against the Phase 1
      transcription record's LaTeX column. Spot-check the universal/existential tense distinction
      on at least TB, UE, TA, UC, UG, Z1, DF.
- [ ] **Citation-integrity audit**: grep every lemma/theorem name cited inside a `#proof[` block and
      confirm it resolves to a live block in the document or to a paper anchor named in a footnote.
- [ ] **Dead-anchor check**: `grep "cor:tm-decidability" typst/FormalFoundations.typ` — confirm no
      *new* citation was introduced by phases 2-8.
- [ ] **Scope-guard check**: confirm the Completeness subsection's claims are unchanged from before
      this task, i.e. no completeness claim migrated from `cor:tm-completeness` into the
      proof-systems section.
- [ ] **Count invariants**: S5 = 5 keys; BX = 17 keys; BX_f = 2; BX_d = 2; BX_c = 2 + 1 derived;
      TM = 3 rules + 9 axioms; Task Topology = 5 sub-items.
- [ ] Read the Histories section and the Proof Systems section end to end for flow, confirming
      task 446's restored prose and the new material read as one text.
- [ ] `git diff --stat typst/FormalFoundations.typ` to record the blast radius; confirm no file
      other than `typst/FormalFoundations.typ` and the two task artifacts changed.

**Timing**: 0.75 hours

**Depends on**: 8

**Verification Tier**: full

**Files to modify**:
- none (audit only; any defect found is fixed in place and re-verified)

**Verification**:
- All nine audit items above pass.
- `typst compile typst/FormalFoundations.typ` exits 0.

---

## Testing & Validation

- [ ] `typst compile typst/FormalFoundations.typ` exits 0 at the end of every phase.
- [ ] Zero `FIX:` tags remain in `typst/FormalFoundations.typ`.
- [ ] Every axiom named anywhere in the document is stated in full at its point of definition.
- [ ] Every lemma cited in the Extension proof is a live block earlier in the document.
- [ ] The derivability relation `⊢` is defined before the Soundness theorem that uses it.
- [ ] The frame-class extensions table names no "Prior-S" axiom.
- [ ] No completeness claim was imported from `cor:tm-completeness`; no citation to
      `cor:tm-decidability` was added.
- [ ] Warning set after the final compile equals the Phase 1 baseline warning set.
- [ ] Only `typst/FormalFoundations.typ` and this task's own artifacts appear in `git diff --stat`.

## Artifacts & Outputs

- `specs/447_substantive_rewrites_formalfoundations/plans/01_substantive-rewrites.md` (this plan)
- `specs/447_substantive_rewrites_formalfoundations/reports/02_source-transcription.md` (Phase 1)
- `typst/FormalFoundations.typ` (modified across Phases 2-8)
- `specs/447_substantive_rewrites_formalfoundations/summaries/01_substantive-rewrites-summary.md`
  (postflight)

## Rollback/Contingency

Every phase is a self-contained edit to a single file ending at a green compile, so recovery is
per-phase rather than all-or-nothing.

- **A phase leaves the file non-compiling**: `git checkout -- typst/FormalFoundations.typ` restores
  the last committed green state. Commit after each phase (`task 447: phase {P}: {name}`) so a
  rollback loses at most one phase.
- **A transcription is found wrong after later phases landed**: fix in place; the transcription
  record in `reports/02_source-transcription.md` is the arbiter, and no later phase depends on an
  earlier phase's *rendering*, only on its region being settled.
- **Phase 8 cannot be made to compile**: the four new blocks can be landed alone (they are
  independent statements) with the Extension proof left commented; that is a `[PARTIAL]` state that
  still satisfies the compile gate, and it is strictly better than the current state, since the
  restored 446 prose then has a live referent.
- **Phase 6 judged out of scope by the user**: it can be dropped without affecting phases 2-5 or
  7-8; the six FIX tags are all removed by Phase 8 regardless. Note this leaves `⊢` undefined and
  the BL-level systems undefined, which the `:369` directive arguably requires.
- **Full abandonment**: `git checkout -- typst/FormalFoundations.typ` at any point; the file has no
  other consumers in the build and `possible_worlds.tex` is never written.
