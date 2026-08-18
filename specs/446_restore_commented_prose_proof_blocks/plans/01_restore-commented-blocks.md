# Implementation Plan: Task #446

- **Task**: 446 - Restore or retire 6 commented-out prose/proof blocks in FormalFoundations.typ
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: 445, 456 (both already landed; no blocking work remains)
- **Research Inputs**: specs/446_restore_commented_prose_proof_blocks/reports/01_restore-fix-tagged-blocks.md
- **Artifacts**: plans/01_restore-commented-blocks.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: false

## Overview

`typst/FormalFoundations.typ` carries 6 bare `// FIX:` tags, each sitting above a block of
commented-out prose or proof text. Research verified every block against the current live
definitions, labels, and bibliography and recommends restoring all 6 verbatim: each is
mathematically correct, every `@label` and `@citekey` inside them resolves, and each uses markup
conventions already in active use elsewhere in the document. The work is therefore mechanical
uncommenting plus two scope decisions this plan settles explicitly (below), executed in
region-ordered phases so that each edit is compile-verified before the next begins. Done means:
all 6 bare tags gone, their content live, `typst compile typst/FormalFoundations.typ` exiting 0,
and the 6 *explanatory* FIX tags (which belong to other tasks) untouched.

### Research Integration

- The 6 bare tags are at current lines 228, 275, 281, 295, 345, 370 (line numbers drifted ~+14
  from the task description; the mapping is one-to-one by content, per the report's table).
- Research independently re-derived the two restored proofs (Nullity at 228, Separation/T1 at 295)
  against the live Frame, Cone/Fiber, `*Limit*`, and converse-convention definitions. Both check
  out. The implementer does not need to re-derive them, only to transcribe faithfully.
- Baseline `typst compile typst/FormalFoundations.typ` currently exits 0 with only two harmless
  `thmbox` "unknown font family" warnings. Those warnings are pre-existing and are not a
  regression signal.
- Confirmed at plan time: `FormalFoundations.typ` is a standalone root document, `#include`d by no
  other Typst file (line 11 states this explicitly, and a repo-wide grep confirms it). Its
  single-file compile is therefore the complete build surface, which is why the editing phases
  below are tiered `local` rather than `interface`.
- Confirmed at plan time: `remark` is imported from `template.typ` (line 27), so the commented
  `#remark[...]` block at 304-315 will elaborate when uncommented.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no `roadmap_flag` was set, so no
roadmap phases are included. `specs/ROADMAP.md` exists in the repository but was deliberately not
consulted or modified by this plan.

## Scope Decisions

Two commented-out blocks adjacent to the 6 tagged sites carry no FIX tag of their own. Research
flagged both and declined to decide. This plan decides both explicitly rather than leaving them
silent.

**Decision 1 - the untagged `#remark[...]` at lines 304-315: IN SCOPE, restore.**
The abstract (line 120) promises the document covers "the separation result that bear[s] on
whether a partial history should be identified with a restriction of a possible world." A
repo-wide grep at plan time found that this discussion appears **nowhere live** in the document —
lines 305, 308, and 309, all inside this commented remark, are its only occurrences. Leaving it
commented leaves the abstract making a promise the body does not deliver. That is a defect of the
same kind and in the same region as the 6 enumerated sites, not unrelated scope creep, so it is
restored here. It is isolated in its own phase (Phase 3, second half) so it can be dropped
independently without disturbing the other five sites if the implementer finds contrary evidence.

**Decision 2 - the untagged fragment at lines 362-363 inside the live "Validity and Consequence"
definition: IN SCOPE, restore — because site 5 is incoherent without it.**
This is not a cosmetic call. Site 5 (line 370) opens "By Occurrence $H_(#taskframe)$ is never
empty, so **frame validity** is never vacuous and $#taskframe #notsatisfies bot$ for every frame."
Frame validity ($#taskframe #satisfies phi.alt$) is defined **only** in the commented fragment at
362-363; the live definition defines just $Gamma #satisfies phi.alt$ and unary validity. Restoring
site 5 alone therefore introduces prose resting on an undefined notion — and `typst compile` will
**not** catch it, because `#satisfies`/`#notsatisfies` are notation macros defined in
`notation/bimodal-notation.typ:78` that typeset happily regardless of whether the notion is
defined in the text. The commented fragment is evidently a *prefix clause of the same sentence*,
not superseded material: it ends with a trailing "And" that chains directly into the live
$Gamma #satisfies phi.alt$ clause. Restoring it yields one coherent two-part definition and makes
site 5 well-founded. This is what the task's own verification criterion ("consistent with the
surrounding definitions") requires.

**Explicitly OUT OF SCOPE**: the 6 *explanatory* FIX tags (lines 261, 285, 381, 390, 397, 423),
which describe different problems — an inadequate Extension proof, readability expansions, a
missing section introduction — and are owned by task 447. They must be left byte-for-byte
untouched by this task.

## Goals & Non-Goals

**Goals**:
- Restore all 6 bare-`// FIX:`-tagged blocks as live document text, verbatim, deleting the tag
  lines and the `// ` comment markers while preserving paragraph breaks.
- Restore the untagged `#remark[...]` at 304-315 (Decision 1) and the untagged frame-validity
  clause at 362-363 (Decision 2).
- Keep `typst compile typst/FormalFoundations.typ` at exit 0 throughout, verified after each
  editing phase, not only at the end.
- Leave the 6 explanatory FIX tags and their surrounding content untouched.

**Non-Goals**:
- Rewriting, tightening, or re-deriving any restored mathematics. Research verified it; the job is
  faithful transcription.
- Any change addressing the 6 explanatory FIX tags (task 447's territory).
- Any change to `FormalSystem/**` Lean sources, or verification of the backticked Lean-identifier
  pointers (`lem:step`, `cor:spherical-finite`, `thm:extension`) against Lean. Those are informal
  prose pointers, not `#leansrc(...)` calls, and the same unchecked convention is already in live
  use at line 723.
- Fixing the pre-existing `thmbox` font warnings.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restoring site 5 verbatim leaves "frame validity" undefined; compile passes anyway, so the defect ships silently | M | H (certain, absent action) | Decision 2 above: restore the 362-363 clause in the same phase as site 5, and verify by reading the assembled definition, not by trusting the compile |
| Line numbers in this plan drift as earlier phases add lines (each restoration grows the file) | M | H | Every phase locates its site by **quoted content anchor**, never by line number. Line numbers below are informational starting points only, and are stated as of the pre-change file |
| An edit accidentally touches one of the 6 explanatory FIX tags, silently stealing task 447's work | H | L | Phase 5 asserts exactly 6 `FIX:` matches remain and diffs them against the recorded pre-change explanatory set |
| Uncommenting mangles indentation or drops a line inside a `#proof[...]` body, producing valid-but-wrong output | M | M | Per-phase `typst compile` plus a read-back of each restored block against the report's Appendix raw content |
| Comment markers stripped inconsistently (e.g. leaving a stray `//` where a blank paragraph break belongs) | L | M | Site 1's block contains a bare `//` line that must become a genuine blank line separating the proof from the following paragraph — called out in Phase 2's tasks |
| This task's additions shift line numbers for task 447, whose description cites line numbers | L | M | Non-blocking and expected; 447's own research already anchors by content. Note the shift in the summary; do not attempt to renumber anything |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every editing
phase mutates the same single file, so parallel execution would conflict.

---

### Phase 1: Baseline and Content-Anchored Site Confirmation [COMPLETED]

**Goal**: Establish the pre-change compile baseline and confirm all 8 edit sites (6 tagged + 2
untagged from the Scope Decisions) by content anchor, so later phases never rely on a stale line
number.

**Tasks**:
- [x] Run `typst compile typst/FormalFoundations.typ /tmp/ff-baseline-446.pdf`; record exit code
      and full stderr. Expect exit 0 with two `thmbox` font warnings. *(completed: exit 0, two
      thmbox unknown-font-family warnings)*
- [x] Run `grep -n "FIX:" typst/FormalFoundations.typ` and record the full output verbatim in the
      progress notes. Classify each of the 12 matches as bare (in scope) or explanatory (out of
      scope), producing the pre-change explanatory-tag set that Phase 5 will diff against.
      *(completed: bare at 228, 275, 281, 295, 345, 370; explanatory at 261, 285, 381, 390, 397,
      423)*
- [x] Confirm the 6 bare tags number exactly 6, and that their commented content matches the
      report's Appendix ("Full raw content of the 6 bare-tagged blocks") block for block.
      *(completed)*
- [x] Confirm the two untagged blocks from the Scope Decisions are present and still commented:
      the `#remark[` block following the Separation proof, and the two-line
      `$#taskframe #satisfies phi.alt$` fragment inside the "Validity and Consequence" definition.
      *(completed)*
- [x] If the bare-tag count is anything other than 6, or any block's content differs from the
      report's Appendix, STOP and report rather than proceeding on a stale premise. *(completed:
      count matched, no stop needed)*

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This plan asserts exactly 6 bare `// FIX:` tags and exactly 6 explanatory
ones (12 total), and asserts 2 additional untagged in-scope blocks (8 edit sites total). Confirm
by the `grep -n "FIX:"` count and the two content greps in this phase's tasks before any edit. A
count mismatch invalidates Phases 2-4's site enumeration and must be reported, not absorbed.

**Files to modify**:
- None. This phase is read-only.

**Verification**:
- Baseline compile exit code is 0 and recorded.
- `grep -n "FIX:"` returns 12 lines, 6 bare and 6 explanatory, and the classification is recorded.

---

### Phase 2: Restore Sites 1-3 (Nullity Proof, Step Lemma Prose, Cones/Basis Prose) [COMPLETED]

**Goal**: Restore the three blocks in the Frame/Histories region — the Nullity lemma proof and the
two short prose paragraphs following the Occurrence corollary.

**Tasks**:
- [x] **Site 1** (anchor: the bare `// FIX:` immediately after
      `#leansrc("Semantics.TaskFrame", "nullity")`, pre-change line 228). Delete the `// FIX:`
      line. Uncomment the `#proof[...]` block and the following "Nullity is derived, not
      postulated..." paragraph. The lone `//` line between them must become a **genuine blank
      line**, not a stray `//` and not nothing — it is the paragraph break separating the proof
      from the prose. *(completed)*
- [x] **Site 2** (anchor: the bare `// FIX:` immediately after
      `#leansrc("Semantics.PartialHistory", "occurrence")`, pre-change line 275). Delete the tag
      line and uncomment the "The Step Lemma is the sole application site of *Spherical*..."
      paragraph, including its inline `#footnote[...]`. Preserve the footnote's single-line form —
      it is one long line in the source and must not be reflowed in a way that breaks the
      `#footnote[` bracket balance. *(completed)*
- [x] **Site 3** (anchor: the bare `// FIX:` above
      `// The cones are a basis for a topology on world states`, pre-change line 281). Delete the
      tag line and uncomment the single sentence. Keep the blank line separating it from Site 2's
      paragraph above and from the `#definition("Task Topology")` below. *(completed)*
- [x] Read back all three restored blocks against the report's Appendix Sites 1, 2a, 2b and
      confirm character-level fidelity of the mathematics (`arrow.r.double.long_(0)`,
      `inter.big_(x>0)`, `subset.eq`). *(completed: verified verbatim match)*
- [x] Compile and commit. *(completed: exit 0, baseline warnings only)*

**Timing**: 0.6 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - three bare FIX tags deleted; Nullity proof, Step Lemma
  paragraph, and cones/basis sentence restored as live text.

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0 with no new warnings beyond the two baseline
  `thmbox` font warnings.
- The restored `@sec:histories`, `@sec:representation`, and `@brastmckie2026possibleworlds`
  references resolve — Typst hard-errors on an unresolved `@`, so a clean exit 0 is the proof.
- Bare-tag count has dropped from 6 to 3; explanatory-tag count still 6.

---

### Phase 3: Restore Site 4 (Separation Proof) and the Adjacent Remark [COMPLETED]

**Goal**: Restore the Separation theorem's T1/R0 proof, and — per Scope Decision 1 — the untagged
`#remark[...]` immediately following it, which is the document's only coverage of a claim the
abstract makes.

**Tasks**:
- [x] **Site 4** (anchor: the bare `// FIX: ` — note the trailing space — immediately after
      `#theorem("Separation")[...]`, pre-change line 295). Delete the tag line and uncomment the
      `#proof[...]` block. Transcribe the math exactly:
      `${u} subset.eq overline({u})$`, `$w arrow.r.double.long_(y) u$`,
      `$u arrow.r.double.long_(-y) w$`, `$inter.big_(x>0)(u)_x = {u}$`. *(completed)*
- [x] Optional, implementer's discretion (research flagged it as cosmetic, not a defect): the
      proof references "the converse convention" in plain text, whereas the term was introduced as
      "the *converse convention*" earlier in the document and this same proof bold-emphasizes
      `*Limit*`. Emphasizing it here would match house style. Either choice is acceptable; do not
      spend time deliberating. *(completed: left as plain text per discretion clause)*
- [x] **Remark block** (anchor: the commented `// #remark[` beginning
      `Extension makes every partial history a restriction of a possible world`, pre-change lines
      304-315). Uncomment the whole block. There is no FIX tag to delete here. Preserve the
      internal line breaks and the two-space body indentation that the other `#remark`/`#proof`
      blocks in this file use. *(completed)*
- [x] Confirm the restored remark now delivers the abstract's line-120 promise: grep for
      `restriction of a possible world` and verify it appears live (not behind `//`) in the body,
      not only in the abstract. *(completed: live matches at restored lines 301, 304)*
- [x] Compile and commit. *(completed: exit 0, baseline warnings only)*

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - Separation proof and the adjacent `#remark[...]` restored; one
  bare FIX tag deleted.

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `#remark[` renders — it is imported from `template.typ` (line 27), so a successful compile
  confirms elaboration.
- `grep -n "restriction of a possible world" typst/FormalFoundations.typ` shows at least one match
  outside the abstract that is **not** prefixed by `//`.
- Bare-tag count has dropped from 3 to 2.

---

### Phase 4: Restore Sites 5-6 and the Frame-Validity Clause [NOT STARTED]

**Goal**: Restore the box-modality/S5 paragraph and the general-frame contrast paragraph, together
with the frame-validity clause that Scope Decision 2 established the latter depends on.

**Tasks**:
- [ ] **Site 5** (anchor: the bare `// FIX:` above
      `// The semantic clause for $square.stroked$ quantifies over all possible worlds`,
      pre-change line 345). Delete the tag line and uncomment the three-sentence paragraph.
- [ ] **Frame-validity clause** (anchor: the two commented lines beginning
      `// $#taskframe #satisfies phi.alt$ just in case` inside the live
      `#definition("Validity and Consequence")[`, pre-change lines 362-363). Uncomment both lines.
      They form the definition's first clause and end in a trailing "And" that must chain into the
      existing live `$Gamma #satisfies phi.alt$ just in case ...` sentence. After uncommenting,
      **read the assembled definition end-to-end as one sentence** and confirm it is grammatical
      and non-duplicative. If the join reads badly, prefer the smallest repair that keeps both
      clauses (e.g. adjusting capitalization at the seam) over dropping either.
- [ ] **Site 6** (anchor: the bare `// FIX:` above
      `// By Occurrence $H_(#taskframe)$ is never empty`, pre-change line 370). Delete the tag line
      and uncomment the full paragraph including the `@blackburnderijkevenema2001` citation.
- [ ] Confirm the coherence this phase exists to secure: the phrase "frame validity" and the
      notation `$#taskframe #notsatisfies bot$` in Site 6 must now both be backed by the
      frame-validity clause restored above. Verify by reading, not by compiling — the compile
      cannot detect this class of defect.
- [ ] Compile and commit.

**Timing**: 0.6 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the *only* live definitional home for frame validity
($#taskframe #satisfies phi.alt$) is the commented 362-363 fragment. Confirm before editing with
`grep -n 'taskframe #satisfies\|frame validity\|frame-valid' typst/FormalFoundations.typ`. If a
live definition turns out to exist elsewhere, skip the frame-validity restoration (it would be a
duplicate) and restore Site 6 alone, recording the finding.

**Files to modify**:
- `typst/FormalFoundations.typ` - two bare FIX tags deleted; box-modality paragraph, frame-validity
  clause, and general-frame contrast paragraph restored.

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0; the `@sec:objective-modality` and
  `@blackburnderijkevenema2001` references resolve (a clean compile proves it).
- Reading the "Validity and Consequence" definition top to bottom yields a coherent statement
  defining frame validity, consequence, and validity, with no dangling "And" and no duplicated
  clause.
- Bare-tag count is now 0.

---

### Phase 5: Final Verification and Deliverable Accounting [NOT STARTED]

**Goal**: Prove the task's stated verification criteria are met and that no out-of-scope territory
was disturbed.

**Tasks**:
- [ ] Run `typst compile typst/FormalFoundations.typ /tmp/ff-final-446.pdf` and confirm exit 0.
      Compare stderr against the Phase 1 baseline: the only warnings permitted are the same two
      `thmbox` "unknown font family" warnings. Any new warning is a regression to investigate.
- [ ] Run `grep -n "FIX:" typst/FormalFoundations.typ`. Assert **exactly 6 matches remain**, and
      diff their text against the explanatory set recorded in Phase 1. All 6 must be
      explanatory-with-text; **zero** bare tags may remain. Any deviation in either direction is a
      failure.
- [ ] Run `grep -c "^// \|^//$" typst/FormalFoundations.typ` over the edited regions and confirm no
      orphaned comment markers or stray `//` lines were left behind inside the restored blocks.
- [ ] Open the produced PDF (or inspect page count and the relevant pages) and sanity-check that
      the two restored proofs render inside proof environments and the restored remark renders
      inside a remark environment, rather than leaking as raw body text.
- [ ] Confirm no file outside `typst/FormalFoundations.typ` and `specs/446_*/` was modified
      (`git status --short`).
- [ ] Write the implementation summary to
      `specs/446_restore_commented_prose_proof_blocks/summaries/01_restore-commented-blocks-summary.md`,
      recording: the 6 restored sites, the two Scope Decisions and how each was resolved, the
      final compile result, and a note that this task's additions shift downstream line numbers for
      task 447 (expected, non-blocking, no renumbering attempted).
- [ ] Final commit.

**Timing**: 0.4 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts exactly 6 `FIX:` matches remain post-change, all
explanatory. Confirm against the Phase 1 recorded classification — the assertion is only meaningful
as a diff against that baseline, not as a bare count.

**Files to modify**:
- `specs/446_restore_commented_prose_proof_blocks/summaries/01_restore-commented-blocks-summary.md`
  - new implementation summary.

**Verification**:
- Compile exits 0 with no new warnings versus baseline.
- Exactly 6 explanatory FIX tags remain, byte-identical to the Phase 1 record; 0 bare tags.
- PDF renders the restored proofs and remark in their proper environments.
- `git status --short` shows no unexpected modified files.

---

## Testing & Validation

- [ ] `typst compile typst/FormalFoundations.typ` exits 0 after every editing phase (Phases 2, 3,
      4) and at final verification (Phase 5).
- [ ] Warning set after the change is identical to the Phase 1 baseline (two `thmbox` font
      warnings, nothing new).
- [ ] All 6 bare `// FIX:` tags removed; all 6 explanatory FIX tags preserved byte-for-byte.
- [ ] Every `@label` and `@citekey` inside restored text resolves — guaranteed by a clean compile,
      since Typst hard-errors on unresolved references rather than failing silently.
- [ ] The restored Site 6 paragraph's "frame validity" reference is backed by a live definition
      (checked by reading; the compile cannot detect this).
- [ ] The abstract's line-120 promise about partial histories and restrictions of possible worlds
      is delivered by live body text.
- [ ] No modification to `FormalSystem/**`, to other `typst/` files, or to the regions owned by the
      6 explanatory FIX tags.

## Artifacts & Outputs

- `typst/FormalFoundations.typ` - 6 bare FIX tags removed, 8 blocks restored as live text
  (6 tagged + 2 untagged per the Scope Decisions).
- `specs/446_restore_commented_prose_proof_blocks/summaries/01_restore-commented-blocks-summary.md`
  - implementation summary including both scope decisions and their rationale.
- `/tmp/ff-baseline-446.pdf` and `/tmp/ff-final-446.pdf` - transient compile artifacts, not
  committed.

## Rollback/Contingency

Every change is confined to one file and every phase commits separately, so rollback is a
per-phase `git revert` of that phase's commit — no cross-file coordination is needed. If the
compile breaks mid-phase, fix forward by re-reading the offending restored block against the
research report's Appendix (the most likely cause is a dropped closing `]` on a `#proof[`,
`#remark[`, or `#footnote[`). Do not discard uncommitted work to reach a green compile.

If Scope Decision 1 or 2 proves wrong at implementation time — for example if a live definition of
frame validity is found elsewhere, or if the remark's content turns out to be covered live in a
section not examined here — drop just that restoration, restore the corresponding tagged site
alone, and record the finding in the summary. Neither decision is load-bearing for the other six
sites, which is why each is isolated in its own phase task rather than interleaved.
