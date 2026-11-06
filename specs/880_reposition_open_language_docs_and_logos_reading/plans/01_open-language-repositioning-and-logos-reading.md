# Implementation Plan: Task #880

- **Task**: 880 - Reposition L^▷ in the prose surfaces as an extension under exploration, with
  L⁺ as the front, and record the Logos reading of the stability modal
- **Status**: [IMPLEMENTING]
- **Effort**: 2.25 hours
- **Dependencies**: 856 (complete), 871 (complete)
- **Research Inputs**: `specs/880_reposition_open_language_docs_and_logos_reading/reports/01_open-language-repositioning-and-logos-reading.md`
- **Artifacts**: plans/01_open-language-repositioning-and-logos-reading.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Five prose surfaces need L^▷ repositioned as an extension under exploration with L⁺ as the
pursuit front, and `PlusLanguage/README.md` needs a new prose section recording the Logos
reading of `⊡`. Research established that the dispatch's items (1) and (2) are **already
substantially satisfied by the tree** — task 856's final phase corrected every contradiction the
transfer ledger enumerated, and none of the three "end state" files presents L^▷ as an end state
or L⁺ as an internal layer. What is actually missing is an explicit cross-link in three files
stating that TM⁺ is the pursuit target and that L^▷ inherits a landed TM⁺ result at `.ZTime` and
`.RTime` by translation. This plan therefore executes item (1) as a **re-verification with
edit-only-what-contradicts**, item (2) as **three additive cross-reference sentences**, and item
(3) as the one substantive new section. Done when the four edited files carry the repositioned
framing and the new section, and the bare `scripts/check-module-invariants.sh` is green.

### Research Integration

The research report is the authority for `OpenLanguage/README.md`'s **current** state, not the
transfer ledger it re-verified: the ledger was pinned at `4c52993c1`, nine commits before task
856's phase 15 commits that fixed all three of its enumerated contradictions. Phase 1 below
re-confirms that independently rather than trusting either document, because the dispatch names
item (1) explicitly and an attestation is cheaper than a wrong no-op.

Research also grounded item (3) word-for-word against `03-dynamics.typ`, confirming
`def-derived-operators-dyn` (`□φ := ⊤ □→ φ`, `stably φ := ¬⊥ □→ φ`),
`lem-stability-semantics` (the null state is the unique verifier of `¬⊥`, and any true sentence
with that same unique verifier — a true propositional identity among them — serves equally), and
`def-agreement-classes` / `def-open-future-past` (ray-agreement by the identical construction, but
with primitive truth and falsity clauses rather than a counterfactual unfolding, because no
Constitutive-Foundation antecedent reaches a ray of times rather than a single evaluation-time
state). Its drafted section text is the starting point for Phase 2 and needs only light editing.

Independent verification done at plan time, beyond the report: `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`
exists and its transfer corollaries are `decidableOpenValidInOfTranslation`, `openDecider`,
`openDecider_correct`, `exists_translation_ztime`, `exists_translation_rtime`, routed through
`openValidIn_ztime_iff_tr` / `openValidIn_rtime_iff_tr` and all conditional on
`SeparationOver` — **an undischarged hypothesis everywhere in this tree**. That conditionality is
load-bearing for the wording of all three Phase 3/4 sentences and is called out per phase below.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals**:
- `FormalSystem/OpenLanguage/README.md` states what L^▷ is — a sound proof system, conservative
  over TM⁺ in both directions, definability split by frame class, no completeness claim — with
  every claim re-verified against the tree.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Conservativity/Open/README.md` and
  the top-level `README.md` each state, in one place and in their own words, that completeness
  and decidability are pursued for L⁺ and that L^▷ inherits a landed result at `.ZTime` and
  `.RTime` by translation — naming the reduction file and the separation hypothesis it rests on.
- `FormalSystem/PlusLanguage/README.md` carries a short prose section giving the Logos reading of
  `⊡` as the trivial-constitutive-antecedent fragment of the counterfactual, with the open-future
  and open-past modals' need for the event-level clause stated, labelled explicitly as a reading
  of the manual's clauses and not a formalized theorem.
- The bare `scripts/check-module-invariants.sh` is green afterwards.

**Non-Goals**:
- **Any `.lean` edit.** The task is `markdown`-typed and no new Lean declaration is proposed.
- **Any hand-edit inside a `<!-- BEGIN GENERATED -->` / `<!-- END GENERATED -->` block.** The 24
  `<!-- TODO: add description -->` inventory rows that exist repo-wide (one of them
  `PlusLanguage/README.md`'s `Subformulas.lean` row, flagged by the transfer ledger) are owned by
  `bash scripts/check-module-invariants.sh --emit-inventory` and are a separate, repo-wide
  cleanup with no bearing on the L^▷ framing this task is about. Explicitly out of scope.
- **Formalizing the Logos reading.** No Lean theorem, no claim that either system proves the
  correspondence. Section (3) is prose cross-reference only.
- **Rewriting prose that does not currently contradict anything.** Where research found the
  framing already correct, the edit is additive, not corrective.
- Editing any Logos-repository file.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The implementer reads the transfer ledger's enumerated contradictions and re-applies its now-stale fix to `OpenLanguage/README.md`, producing a spurious diff or reverting correct text | M | M | Phase 1 is an explicit re-verification gate that must run before any edit to that file, and cites the research report (not the ledger) for current state |
| The three cross-reference sentences overclaim: stating that L^▷ *inherits* completeness/decidability at `.ZTime`/`.RTime` without the undischarged `SeparationOver` hypothesis | **H** | M | Every one of the three sentences must name the conditionality. `exists_translation_ztime` / `exists_translation_rtime` both take `SeparationOver` as an explicit hypothesis discharged nowhere in the tree; `OpenLanguage/README.md` already models the honest phrasing ("states *conditional reductions* … but each takes the L⁺ fact as an undischarged hypothesis"). Phase 3's verification requires matching that register |
| Near-identical sentences land in both the top-level `README.md` and `FormalSystem/Metalogic/README.md`, tripping C18's cross-README duplicated-prose scan (whole paragraphs, and sentences of 15+ words) | L | M | Phase 4 depends on Phase 3 specifically so the implementer reads the landed Metalogic wording and deliberately differs. C18 is REPORTED, never gated, so this degrades the report rather than failing the gate |
| The Logos reading drifts from `03-dynamics.typ`, a live file in a sibling repository actively edited the same day as the research dispatch | M | M | Phase 2 re-greps the four Typst labels (`def-derived-operators-dyn`, `lem-stability-semantics`, `def-agreement-classes`, `def-open-future-past`) rather than trusting the report's line numbers, and cites by label, never by line |
| A new prose sentence names a path or a relative link that does not resolve, failing C5 / C12 / C13 | M | L | Every phase's in-phase check is `bash scripts/check-module-invariants.sh --no-build`, which runs C5, C9, C12, C13 and C18 |
| Draft-history or task-number language leaks into a deliverable file | M | L | All four target files are outside `specs/**`, so `no-task-references-in-deliverables.md` and `no-record-versioning-in-deliverables.md` both bind. C9 gates task-number citations under `README.md` and `FormalSystem/`; the record-version rule has no mechanical gate, so Phase 5 includes a manual read-through of the full diff for "no longer", "previously", "formerly", "used to", and version labels |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Re-verify `OpenLanguage/README.md` against the tree [COMPLETED]

**Goal**: Establish, by reading the live file and the tree, whether any claim in
`FormalSystem/OpenLanguage/README.md` still contradicts what the tree proves — and edit only
what does.

**Tasks**:
- [x] Read `FormalSystem/OpenLanguage/README.md` in full. *(completed)*
- [x] Re-verify each of the three contradictions the transfer-ledger report
      (`specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md`,
      finding "`OpenLanguage/README.md` now contradicts the tree") enumerates, against the
      current tree rather than against the ledger's pinned commit:
      (a) the "L^▷ is semantic only: it has no proof system" claim — confirm the file now states
      the proof system's scope (`OpenAxiom`, the seven-rule `OpenDerivationTree`, `eraseOpen`);
      (b) the generated inventory's file count — confirm the `BEGIN GENERATED` table's row count
      equals `ls FormalSystem/OpenLanguage/*.lean | wc -l`;
      (c) agreement between the README and
      `FormalSystem/Metalogic/Conservativity/Open.lean`'s module docstring.
      *(completed: all three resolved — (a) the README's third paragraph states the proof
      system's exact scope; (b) 9 generated rows = 9 `.lean` files via `ls`; (c) the docstring
      and README state the same soundness/conservativity/no-completeness/class-split claims)*
- [x] Confirm the four positive claims the dispatch requires are present and accurate: sound
      proof system; conservative over TM⁺ in both directions; definability split by frame class
      (`.ZTime`/`.RTime` definable, `.Base`/`.Dense` not); no completeness claim at any class.
      *(completed: all four already present and accurate)*
- [x] Edit **only** a claim that still contradicts the tree. If none does — the expected
      outcome — make no edit and record the attestation in the phase's handoff and via
      `issue-record.sh --kind win`. *(completed: no contradiction found; zero-diff attestation
      recorded via issue-record.sh)*
- [x] Do not touch the file's `BEGIN GENERATED` block under any outcome; a row-count mismatch at
      step (b) is reported, not hand-fixed. *(completed: no row-count mismatch; block untouched)*

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: The phase's expected outcome is zero bytes changed and its worst case is
a prose-only correction inside a markdown file with no compile surface, covered by
`bash scripts/check-module-invariants.sh --no-build` (C5 module-path resolution, C9 task-number
citations, C12 slash-path resolution, C13 relative-link resolution) plus the `prose` row's diff
read-through.

**Scope Hypothesis**: Research asserts zero edits are needed here, because task 856's phase 15
commits (`9a1165793`, `5d741bc8c`) already fixed all three enumerated contradictions. The
implementer confirms this by the per-item re-verification above, not by citing the report —
and if a contradiction *has* survived, the edit is in scope for this phase.

**Files to modify**:
- `FormalSystem/OpenLanguage/README.md` - expected unchanged; corrected only where a claim still
  contradicts the tree

**Verification**:
- Each of the three enumerated contradictions is explicitly resolved or explicitly corrected,
  with the evidence named (file line, or the command whose output settles it).
- `bash scripts/check-module-invariants.sh --no-build` exits 0.
- Diff read-through confirms every changed hunk (if any) lies in prose, outside
  `BEGIN GENERATED`.

---

### Phase 2: The Logos reading section in `PlusLanguage/README.md` [COMPLETED]

**Goal**: Add a short prose section to `FormalSystem/PlusLanguage/README.md` giving the Logos
reading of `⊡` as the trivial-constitutive-antecedent fragment of the counterfactual, with the
open-future and open-past modals' need for the event-level clause stated.

**Tasks**:
- [x] Re-grep the four Typst labels in
      `~/Projects/Logos/Theory/typst/manual/chapters/03-dynamics.typ` and confirm each still
      names the content the research report attributes to it, reading the surrounding clause
      rather than trusting the report's line numbers:
      `def-derived-operators-dyn` (`□φ := ⊤ □→ φ`; `stably φ := ¬⊥ □→ φ`),
      `lem-stability-semantics` (null state the unique verifier of `¬⊥`; the generalization to
      any true sentence with that unique verifier, a true propositional identity among them),
      `def-agreement-classes` and `def-open-future-past` (ray-agreement, with their own primitive
      truth *and* falsity clauses). *(completed: all four labels present and content confirmed
      against the live file — lines 91, 1744, 1771, 1788)*
- [x] If a label has moved or its content changed, adjust the section's prose to the manual as
      it now stands and note the divergence from the report via `issue-record.sh`.
      *(completed: no divergence found; no note needed)*
- [x] Insert a `## Logos Reading` section into `FormalSystem/PlusLanguage/README.md`
      immediately after the existing `## \`⊡\` as a quantifier over a product of two path
      spaces` section (which ends just before `## Why the TM schemata are re-declared`) — that
      section already discusses what `⊡`'s quantification domain *is*, so the reading of where
      that domain comes from in the Logos theory belongs directly after it. *(completed)*
- [x] Base the section on the research report's drafted text (report, Findings §(3), "Suggested
      content for `PlusLanguage/README.md`'s new section"), editing for this file's register.
      Required content: both abbreviations; why each clause collapses (every state verifies `⊤`;
      the null state is the *unique* verifier of `¬⊥`); the "or any true identity"
      generalization; the conclusion that `⊡` is the fragment of the counterfactual at a trivial
      Constitutive-Foundation antecedent rather than a modality built from new frame structure;
      and the open-future/open-past asymmetry with its structural reason (a
      Constitutive-Foundation formula's event-verifiers are pinned to the single evaluation time,
      so no such antecedent reaches a whole ray). *(completed: all required content present)*
- [x] State explicitly, in the section itself, that this is a reading of the manual's clauses and
      that no claim in it is a formalized theorem of either system. *(completed)*
- [x] Cite the manual by Typst label, never by line number, matching the paper-label citation
      convention `FormalSystem/OpenLanguage/README.md` already uses. *(completed)*
- [x] Leave the file's `BEGIN GENERATED` inventory block (lines 33-53) untouched, including the
      `Subformulas.lean` TODO row. *(completed: block untouched, confirmed via diff hunk headers)*
- [x] Update the file's trailing `*Last verified: …*` line to the implementation date.
      *(completed: set to 2026-11-05)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: A new prose section in a markdown file with zero compile surface; the
cross-reference risk it introduces is unresolvable paths and links, covered by
`bash scripts/check-module-invariants.sh --no-build` (C5, C12, C13) plus the `prose` row's diff
read-through.

**Scope Hypothesis**: The research report asserts its drafted section text is ready "with minimal
further editing" and that all four Typst labels are stable. The implementer confirms the labels
by the re-grep above before reusing any of the drafted wording.

**Files to modify**:
- `FormalSystem/PlusLanguage/README.md` - new `## Logos Reading` section after the
  `⊡`-as-a-quantifier section; `Last verified` date refreshed

**Verification**:
- All four Typst labels re-grepped and confirmed (or divergence recorded).
- The section names both abbreviations, both collapse reasons, the true-identity
  generalization, and the open-future/open-past event-level-clause asymmetry.
- The section says in its own text that it is a reading, not a formalized theorem.
- No line number from `03-dynamics.typ` appears in the section.
- `git diff FormalSystem/PlusLanguage/README.md` shows no hunk inside lines 33-53's generated
  block.
- `bash scripts/check-module-invariants.sh --no-build` exits 0.

---

### Phase 3: The pursuit-target cross-link in the two Metalogic surfaces [COMPLETED]

**Goal**: State in `FormalSystem/Metalogic/README.md` and
`FormalSystem/Metalogic/Conservativity/Open/README.md` that the pursuit target is TM⁺ and that
L^▷ inherits a landed TM⁺ result at `.ZTime` and `.RTime` by translation — conditionally.

**Tasks**:
- [x] `FormalSystem/Metalogic/README.md`: add one or two sentences immediately after the
      paragraph closing the `### The TM⁺ metatheory rows` section's discussion of its two
      **OPEN** rows ("completeness of any extension of the TM⁺ axiom set, at any class" and
      "TM⁺ decidability"; the paragraph beginning "The two open rows are stated nowhere in the
      tree"). The sentences must say: the pursuit target named by those two OPEN rows is TM⁺,
      not a separate L^▷ engine; and because L^▷ is conservative over TM⁺ and `▷` is
      L⁺-definable at `.ZTime` and `.RTime`, a landed TM⁺ result at either class would transfer
      to L^▷ validity there through `Metalogic/Expressiveness/OpenFutureElimination.lean`'s
      conditional reductions. *(completed)*
- [x] **State the conditionality.** Those reductions (`exists_translation_ztime`,
      `exists_translation_rtime`, `decidableOpenValidInOfTranslation`, `openDecider_correct`)
      each take `SeparationOver` — Gabbay's Separation Theorem over the relevant flow — and/or
      the corresponding L⁺ fact as an **explicit hypothesis discharged nowhere in this tree**.
      The sentence must not read as though the transfer is already available. Match the register
      `FormalSystem/OpenLanguage/README.md` already uses for the same reductions. *(completed)*
- [x] `FormalSystem/Metalogic/Conservativity/Open/README.md`: add one or two sentences
      immediately after the existing "**No completeness is claimed here, at any frame class, in
      any form.**" paragraph (ending "…exactly as it is in L⁺."). The sentences must name the
      same reduction file, state that `.Base` and `.Dense` have **no such route** because `▷` is
      not L⁺-definable there, and carry the same conditionality. *(completed)*
- [x] Verify every path and declaration name written into either file resolves: the reduction
      file's path, and each declaration named. *(completed: all four declaration names
      grep-confirmed in OpenFutureElimination.lean; check-module-invariants.sh --no-build green)*
- [x] Record, for Phase 4, the exact sentences landed in `FormalSystem/Metalogic/README.md`, so
      Phase 4 can deliberately differ from them. *(completed: C18 confirms zero duplicated
      paragraphs/15+-word sentences across the four top-level READMEs after this phase's edit)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Two prose insertions into markdown files with no compile surface, whose
only mechanical failure mode is an unresolvable module path or link, covered by
`bash scripts/check-module-invariants.sh --no-build` (C5 module-shaped `FormalSystem.*` paths,
C12 slash-shaped source paths, C13 relative links) plus the `prose` row's diff read-through.

**Scope Hypothesis**: Research asserts neither file currently presents L^▷ as an end state or L⁺
as an internal layer, so both edits are purely additive — one insertion point per file, at the
two anchors named above. The implementer confirms by reading each anchor paragraph before
inserting, and if either file *does* contain end-state framing, correcting it is in scope for
this phase.

**Files to modify**:
- `FormalSystem/Metalogic/README.md` - pursuit-target and conditional-inheritance sentences after
  the two OPEN rows' discussion
- `FormalSystem/Metalogic/Conservativity/Open/README.md` - the same link plus the
  `.Base`/`.Dense` no-route statement, after the "No completeness is claimed here" paragraph

**Verification**:
- Both files state the TM⁺ pursuit target and the `.ZTime`/`.RTime` translation route.
- Both state the conditionality on the undischarged `SeparationOver` / L⁺ hypothesis; neither
  reads as an available transfer.
- `Conservativity/Open/README.md` states that `.Base` and `.Dense` have no such route.
- Every path and declaration name written into either file resolves on disk / in the tree.
- `bash scripts/check-module-invariants.sh --no-build` exits 0.

---

### Phase 4: Tighten the top-level `README.md` L^▷ bullet [NOT STARTED]

**Goal**: Make the top-level `README.md`'s L^▷ bullet name the pursuit target and the reduction
route explicitly, rather than leaving "notational variant" to carry the inheritance claim.

**Tasks**:
- [ ] Read the landed Phase 3 wording in `FormalSystem/Metalogic/README.md` first, and word this
      bullet's addition differently — C18 scans `README.md`,
      `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and
      `FormalSystem/Metalogic.lean` for duplicated whole paragraphs and for duplicated sentences
      of 15+ words.
- [ ] Tighten the final clause of the **L^▷** bullet in the "seven object languages" list (the
      bullet beginning "**L^▷ extends L⁺ by the two operators of the manuscript's subsection
      *Restricted Modalities***", whose clause currently reads "…so the system extends TM⁺
      genuinely at the first two classes and is a notational variant of it at the last two"):
      name TM⁺ as where completeness and decidability are pursued, and name
      `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` as the route by which a
      landed TM⁺ result at `.ZTime` or `.RTime` would reach L^▷.
- [ ] Carry the same conditionality as Phase 3: the reductions' hypotheses are undischarged.
- [ ] Keep the bullet's existing correct content — "**No completeness is claimed for it, at any
      frame class**", the class-split, and the Ockhamist "what it is for" passage — intact. This
      is a tightening of one clause, not a rewrite of the bullet.
- [ ] Verify the reduction file's path resolves as written (C12 gates slash-shaped source paths
      in `README.md`).

**Timing**: 0.25 hours

**Depends on**: 3

**Verification Tier**: prose

**Tier Justification**: A single-clause prose edit in a markdown file with no compile surface,
whose only mechanical risk is an unresolvable slash-shaped source path, covered by
`bash scripts/check-module-invariants.sh --no-build` (C12, plus C13 and C18 over `README.md`)
plus the `prose` row's diff read-through.

**Scope Hypothesis**: Research asserts exactly one clause in one bullet needs tightening, with
the rest of the bullet already correct. The implementer confirms by reading the whole bullet
before editing, and keeps the diff to that clause.

**Files to modify**:
- `README.md` - the L^▷ bullet's final clause, naming the TM⁺ pursuit target and the reduction
  file

**Verification**:
- The bullet names TM⁺ as the pursuit target and the reduction file as the route, with the
  conditionality stated.
- The bullet's "No completeness is claimed for it, at any frame class", the class-split, and the
  Ockhamist passage are unchanged.
- The addition's wording is not a near-copy of Phase 3's; no 15+-word sentence is shared with
  `FormalSystem/Metalogic/README.md`.
- `bash scripts/check-module-invariants.sh --no-build` exits 0, and its C18 output reports no new
  duplication row naming `README.md`.

---

### Phase 5: The full gate and the constraint sweep [NOT STARTED]

**Goal**: Confirm the whole change set is green under the repository's full phase gate and that
every dispatch constraint holds across the complete diff.

**Tasks**:
- [ ] Review the complete diff for this task: `git diff -- README.md FormalSystem/OpenLanguage/README.md FormalSystem/PlusLanguage/README.md FormalSystem/Metalogic/README.md FormalSystem/Metalogic/Conservativity/Open/README.md`.
- [ ] Confirm **no `.lean` file is modified**: `git status --short` shows no `.lean` path.
- [ ] Confirm **no hunk falls inside a `BEGIN GENERATED` … `END GENERATED` block** in any edited
      file.
- [ ] Sweep the diff for task-number references ("task N", "tasks N-M", "(task N)"). All four
      edited files are outside `specs/**`, so `no-task-references-in-deliverables.md` binds; C9
      gates this under `README.md` and `FormalSystem/`.
- [ ] Sweep the diff manually for record-versioning language — there is no mechanical gate for
      this rule. Forbidden in these files: "no longer", "previously", "formerly", "used to",
      "supersedes", version labels on the document, and any phrasing relative to an unstated
      past. Deliverables state the current design only.
- [ ] Confirm every claim added across the four files is accurate against the tree, with
      particular attention to the three conditional-inheritance sentences: none may read as an
      available transfer when `SeparationOver` is discharged nowhere.
- [ ] Run the bare `bash scripts/check-module-invariants.sh` (no flags — the dispatch's explicit
      constraint; this form includes C1 `lake build`, C2 and C14's `#print axioms` halves, C16,
      C24, C25 and C36b, which `--no-build` skips) and leave it green.
- [ ] If the gate is red, repair forward; never discard uncommitted work to reach green.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Files to modify**:
- none planned (repair-forward edits to the four files above only if the gate is red)

**Verification**:
- `bash scripts/check-module-invariants.sh` (bare, all checks, build included) exits 0. This is
  the dispatch's named gate and this repository's complete phase gate for a non-`specs` markdown
  change set: C5 (module-shaped `FormalSystem.*` paths in non-specs markdown resolve), C9 (zero
  task-number citations under `FormalSystem/`, `README.md`, `scripts/`, `lakefile.toml`), C12
  (slash-shaped source paths in `docs/` + `README.md` resolve), C13 (relative markdown links
  resolve), C14 (documented axiom/sorry counts match the tree, including in markdown), C18
  (cross-README duplicated prose, reported), and the build-dependent checks `--no-build` skips.
- `git status --short` lists no `.lean` path.
- No hunk inside any `BEGIN GENERATED` block.
- No task-number reference and no record-versioning language anywhere in the diff.

---

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` (bare) exits 0.
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0 after each of Phases 1-4.
- [ ] No `.lean` file modified (`git status --short`).
- [ ] No hunk inside a `BEGIN GENERATED` … `END GENERATED` block.
- [ ] No task-number reference in any edited file (C9, plus manual diff sweep).
- [ ] No record-versioning language in any edited file (manual diff sweep; no mechanical gate).
- [ ] The three conditional-inheritance sentences each state the undischarged hypothesis.
- [ ] The `## Logos Reading` section states that it is a reading, not a formalized theorem, and
      cites `03-dynamics.typ` by Typst label only.

## Artifacts & Outputs

- `FormalSystem/OpenLanguage/README.md` — re-verified; expected unchanged.
- `FormalSystem/PlusLanguage/README.md` — new `## Logos Reading` section.
- `FormalSystem/Metalogic/README.md` — pursuit-target and conditional-inheritance sentences.
- `FormalSystem/Metalogic/Conservativity/Open/README.md` — the same link plus the
  `.Base`/`.Dense` no-route statement.
- `README.md` — tightened L^▷ bullet clause.
- `specs/880_reposition_open_language_docs_and_logos_reading/summaries/01_open-language-repositioning-and-logos-reading-summary.md`
  — implementation summary.

## Rollback/Contingency

Every change is an additive prose edit to one of five markdown files, each phase committed on its
own. Reverting any single phase is `git revert` of that phase's commit, with no build or proof
consequence — no `.lean` file is touched, so no `#print axioms` baseline, import graph or proof
obligation can move.

If `bash scripts/check-module-invariants.sh` is red at Phase 5 for a reason this change set
introduced, repair forward by correcting the offending prose; never discard uncommitted work to
reach a green gate (`.claude/rules/error-handling.md`, "Write-Gating Constraint"). If the gate is
red for a pre-existing, unrelated reason, record it via `issue-record.sh` and report it rather
than absorbing an unrelated repair into this task.

A genuine rollback of uncommitted work, if one is ever needed, goes through
`context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape
and its out-of-scope override flag — not a bare precautionary checkpoint.
