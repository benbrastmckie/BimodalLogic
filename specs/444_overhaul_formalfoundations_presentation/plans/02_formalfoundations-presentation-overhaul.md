# Implementation Plan: Overhaul FormalFoundations.typ Presentation

- **Task**: 444 - Overhaul FormalFoundations.typ presentation
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None
- **Research Inputs**: `specs/444_overhaul_formalfoundations_presentation/reports/01_team-research.md` (plus teammate findings `01_teammate-a-findings.md` through `01_teammate-d-findings.md`)
- **Artifacts**: plans/02_formalfoundations-presentation-overhaul.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

`typst/FormalFoundations.typ` is a single standalone 390-line Typst document (it is *not* a chapter
of `BimodalReference.typ` and includes no chapter files; it imports only `typst/template.typ` and
`typst/notation/bimodal-notation.typ`). It must be rewritten so that Dana Scott, reading it cold,
receives three payloads at advanced-textbook formality: the core mechanics of the existing
completeness results, the current state of decidability, and the best direction for a
representation theorem. The rewrite fixes one genuine mathematical error, discharges all 11 `FIX:`
tags, reorders seven sections into five, and replaces the document's self-referential register with
definition/theorem/remark environments. Definition of done: the five-section document compiles,
passes `scripts/typst-sync-check.sh`, contains zero `FIX:` tags, zero banned-register hits, and
every mathematical claim is traceable either to a verbatim anchor in
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` or to a live, named Lean
declaration under `FormalSystem/` (excluding `Boneyard/`).

### File-layout grounding

The plan's phases are sections *within one file*, not separate chapter files. This was verified:
`typst/BimodalReference.typ:173-222` `#include`s the 16 files under `typst/chapters/`;
`typst/FormalFoundations.typ` `#include`s none of them and states its independence at `:11-15`.
Consequently every content phase edits the same file and the phases are strictly sequential — there
is no parallel territory to hand out. Material from `typst/chapters/p3-vlach-blstar.typ` and
`typst/chapters/p2-frame-classes.typ` is *read and adapted*, never `#include`d.

### Research Integration

The research report's nine recommendations map onto phases as follows: R1 (atom-interpretation
error + faithfulness pass) -> Phases 3 and 10; R2 (five-section reorder) -> Phase 2; R3 (execute
FIX-231 by folding, not deleting) -> Phases 2 and 5; R4 (rewrite the construction at book-chapter
formality) -> Phases 5 and 6; R5 (restructure the representation section) -> Phase 8; R6 (strip the
self-referential register) -> every content phase, swept in Phase 9; R7 (thread machine-verification
discipline per result) -> editorial bar item E4, checked in every content phase; R8 (bibliography
additions before citing) -> Phase 1; R9 (re-stamp, do not re-derive, the status counts) -> Phases 1
and 6. Decisions D1-D5 are adopted as written: D1 fixes the top-level order (Phase 2) with a
semantics-first section 1 (Phase 3); D2 splits the Kamp material between the construction section
and a one-remark note in the representation section (Phases 6 and 8); D3 opens the representation
section with the live algebraic layer (Phase 8); D4 gives Dana's partial-history question an
explicit treatment rather than silent omission (Phase 3); D5 caps the Scott personal anchor at one
sentence (Phase 9). Gaps G1 (BX/paper-BX identification) and G2 (Since/Until argument order) are
closed in Phase 1 before any prose depends on them; G3 (topology depth) is decided in Phase 1 and
executed in Phase 3; G4 (out-of-scope acknowledgment) is executed in Phase 9.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md:44-54` gates the expensive strong-completeness programme (ultraproduct carrier,
Los lemma, compactness, per-class strong completeness) behind the shift-set representation theorem
landing sorry-free in both directions. Section 5 of this document is the only prose account of that
gate's candidate routes, so Phase 8 sits on the roadmap's critical path rather than beside it. This
plan does not modify `specs/ROADMAP.md`.

## Goals & Non-Goals

**Goals**:
- Correct the atom-interpretation clause and run a line-by-line faithfulness pass over every
  paraphrase of model structure against `possible_worlds.tex`.
- Reorder the document from seven sections to five, promoting the completeness construction ahead
  of the philosophical costs.
- Present the whole document in the extended language, with Since/Until as the only primitive tense
  operators, per FIX-231 and FIX-113.
- Discharge all 11 `FIX:` tags and remove them from the source.
- Rewrite the completeness construction and the representation section at advanced-textbook
  formality, with definitions, theorems, and named literature credits.
- Hold the document at roughly its existing page budget while adding the topology material.

**Non-Goals**:
- No edits to `FormalSystem/**` (no Lean proofs are written, repaired, or restated).
- No edits to `typst/chapters/**` or `typst/BimodalReference.typ`. Lifting the rewritten
  construction section into `typst/chapters/04-metalogic.typ` is a downstream opportunity, not part
  of this task.
- No edits to `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`.
- No new Lean status claims. Status counts are re-stamped, never re-derived by hand.
- No upgrade of the general Base-frame `completeness` theorem's "outstanding" framing — it carries
  `sorryAx` and must continue to say so.

## Editorial Bar

This is the checkable standard the task's "advanced textbook" mandate reduces to. Every content
phase's Verification block cites these by number; a phase is not complete until each holds over the
region that phase touched.

- **E1 (Everything formal is in an environment).** Every mathematical object the phase introduces
  appears inside `#definition`, `#theorem`, `#lemma`, `#proposition`, `#corollary`, or a displayed
  equation that defines a symbol. No object is introduced only in running prose.
- **E2 (Zero self-referential register).**
  `grep -nE "this report|stated exactly|[Uu]nsoftened|at full strength|kept unblurred|worth flagging|single most|[Ff]aithfully|Pain Point" typst/FormalFoundations.typ`
  returns no hit inside the phase's region. Baseline at plan time: 20 matching lines document-wide.
  Section headings carry a plain noun phrase and no em-dash qualifier.
- **E3 (Remarks are bounded and substantive).** Every paragraph in the region is either a
  definition/theorem/proof body or a `#remark` of at most four sentences stating a mathematical
  fact, a dependency between results, or an open question. No motivational prose outside these two
  forms.
- **E4 (Every status claim is traceable).** Each assertion that something is proved, open,
  retracted, or archived carries either a paper anchor footnote citing
  `@brastmckie2026possibleworlds` or a Lean reference (`#leansrc(module, name)` from
  `typst/template.typ:98`, or a backticked `Module.declaration`). No bare status adjectives.
- **E5 (No vague glosses).**
  `grep -nE "\b(quite|rather|somewhat|arguably|genuinely|essentially|of course|clearly|simply|honest|measured)\b" typst/FormalFoundations.typ`
  produces no hit inside the region that is not part of a quoted passage.
- **E6 (No task-number references).** Per `.claude/rules/no-task-references-in-deliverables.md`,
  nothing under `typst/**` may cite a task number. The roadmap gate is stated by its content ("the
  shift-set representation theorem landing sorry-free in both directions"), never by task number.

## Fidelity Bar

Compiling is not correctness. Every content phase additionally satisfies:

- **V1.** Each definition restated from the paper is diffed against its labelled anchor in
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` and the anchor is
  recorded in `specs/444_overhaul_formalfoundations_presentation/definitions-of-record-444.md`
  (Phase 1's output). A restatement that cannot be matched to an anchor is not written.
- **V2.** Each Lean-backed claim names a declaration that exists under `FormalSystem/` excluding
  `Boneyard/`, at the file and line recorded in the research report's Lean verification table, and
  its sorry/axiom status is quoted as measured, never inferred.
- **V3.** Every backticked span the phase introduces either resolves under `FormalSystem/` or is
  added to `typst/sync-check-whitelist.txt` with a one-line reason, and
  `scripts/typst-sync-check.sh` exits 0.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting the split-validity section silently breaks the arguments at `:227` and `:317` that depend on it | H | H | Phase 2 folds rather than deletes; Phase 5 restates (DD) for the extended language inside the construction section; Phase 11 sweeps every cross-reference |
| Correspondence claims dropped along with the compressed table (FIX-174), stranding the contingency argument that presupposes them | H | M | Phase 4 compresses the table but keeps the three correspondence statements as claims; Phase 7 re-checks that the contingency argument's premises are still present |
| New backticked identifiers fail `scripts/typst-sync-check.sh` | M | H | V3 makes the whitelist update part of every content phase, not a final cleanup |
| Adding the topology material overruns the page budget | M | M | The budget freed by FIX-231, FIX-337, and the register strip is measured in Phase 2 and reconciled against actual page count in Phase 11 |
| A rewrite phrase upgrades a hedged status claim by accident (especially the Base-frame `completeness` sorryAx) | H | M | V2 plus the explicit non-goal; Phase 10 is a dedicated adversarial audit against the research report's verification table |
| Same-file sequential editing loses earlier phases' work through a stale read | M | L | Each phase re-reads the current file region before editing and commits on green |
| The Since/Until argument-order gloss is corrected in the wrong direction | H | M | Phase 1 closes G2 against the Lean `snce`/`untl` constructors *and* the paper footnote before any prose depends on it |

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
| 10 | 10 | 9 |
| 11 | 11 | 10 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every content
phase edits distinct regions of the single file `typst/FormalFoundations.typ`, and concurrent edits
to one file are not safe.

---

### Phase 1: Ground Truth, Scope Lock, and Bibliography [NOT STARTED]

**Goal**: Fix every fact the rewrite depends on before a single sentence is rewritten: the paper's
verbatim definitions, the two unresolved research gaps, the re-stamped Lean status counts, the
FIX-tag disposition table, and the bibliography entries for sources about to be cited.

**Tasks**:
- [ ] Extract verbatim, into `specs/444_overhaul_formalfoundations_presentation/definitions-of-record-444.md`,
      the paper text at `def:temporal-order`, `def:task-relation`, `def:frame`, `def:world-history`,
      `def:BL-model` (`possible_worlds.tex:2876-2878`), `def:BL-semantics` (atomic clause `:2892`,
      Box clause `:2899`), `def:frame-validity`, `def:logical-consequence`, `def:BLplus-language`,
      `def:BLplus-semantics` (`:3820-3823`), `def:task-topology` (`:2622-2632`), `app:topology-t1`
      (`:2653-2666`), `app:topology-r0` (`:2673-2680`). Cross-check against the existing
      `specs/paper-definitions-of-record.md` mechanism and note any anchor that has moved.
- [ ] Close G2: read the `snce`/`untl` constructor signatures and semantic clauses in the Lean
      source directly, and record whether the paper's `S`/`U` is guard-first (the paper's own
      footnote at `:3816-3817` says it is) and the Lean convention event-first. Record the decision
      on whether the Lean-convention footnote is kept at all.
- [ ] Close G1: compare the Lean `FrameClass.Dense` axiom set against the paper's `def:BX` list
      (17 named keys vs `typst/SYNC-MAP.md`'s 22 BX Temporal constructors) and record the decision:
      either state the identification argument in one sentence, or hedge it exactly as the TM case
      is hedged. Record which, with the reason.
- [ ] Close G3: decide and record the depth of the topology treatment (remark / subsection /
      definition-plus-theorem) that Phase 3 will write.
- [ ] Re-run `scripts/typst-status-counts.sh --json` at the current commit and record the counts and
      the commit hash for Phase 6's status table. Do not hand-derive any count.
- [ ] Build the FIX disposition table (tag line, verbatim text, owning phase, resolution) covering
      every `FIX:` occurrence returned by `grep -n "FIX:" typst/FormalFoundations.typ`.
- [ ] Add to `typst/bibliography.bib` only those sources Phases 3-8 will actually cite, drawn from
      the research report's absent list: Goldblatt *Logics of Time and Computation*,
      Chagrov-Zakharyaschev *Modal Logic*, Jonsson-Tarski (1951/52), Stone (1936), Scott "Advice on
      Modal Logic" (1970). Do not add an entry that will not be cited.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The current source contains exactly 11 `FIX:` tags, at lines 93, 113, 123,
126, 135, 174, 189, 208, 231, 285, 337. Confirm at implementation time with
`grep -c "FIX:" typst/FormalFoundations.typ` and `grep -n "FIX:" typst/FormalFoundations.typ`; if
the count or the line set differs, the disposition table records the actual set and the phase map
below is amended before Phase 2 begins.

**Files to modify**:
- `specs/444_overhaul_formalfoundations_presentation/definitions-of-record-444.md` - new: verbatim
  paper anchors, G1/G2/G3 decisions, re-stamped counts, FIX disposition table
- `typst/bibliography.bib` - add only the entries that will be cited

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0 (bibliography still parses).
- `typst compile typst/BimodalReference.typ` exits 0 — `bibliography.bib` is shared with the book,
  which is why this phase is `interface` rather than `local`.
- The definitions-of-record file contains a verbatim quotation for each of the 13 anchors listed,
  each with a `possible_worlds.tex` line reference.
- G1, G2, G3 each have a recorded decision with a stated reason.

---

### Phase 2: Structural Reorder to the Five-Section Skeleton [NOT STARTED]

**Goal**: Move the document into the target section order and heading set, relocating existing
content blocks without rewriting them, so that every later phase rewrites in place against a stable
skeleton and the compile stays green throughout.

**Tasks**:
- [ ] Rewrite the top-level headings to the five-section skeleton: (1) The System; (2) What Is
      Proved: Completeness and Decidability; (3) The Completeness Construction; (4) Two Costs of the
      Semantics; (5) Toward a Representation Theorem.
- [ ] Move the current section 6 (`<sec:construction>`, `:283-333`) ahead of the current sections 3
      and 5, per research decision D1.
- [ ] Merge the current section 3 (contingency, `<sec:contingency>`) and section 5 (objective
      modality, `<sec:objective-modality>`) into the single section 4 shell, as two subsections,
      content unrewritten.
- [ ] Fold, do not delete, the current section 4 (`<sec:split-validity>`): move the (DD) theorem,
      its proof, and the two-fibre `cetz` figure into a holding subsection at the end of the new
      section 3, marked for rewrite by Phase 5. Retire the `<sec:split-validity>` label and repoint
      every `@sec:split-validity` reference (`:227`, `:314`, `:317`, `:378`) at its new home.
- [ ] Rename every remaining `<sec:...>` label to match the new numbering and repair every `@sec:`
      reference. Typst errors on an unresolved label, so the compile is the gate.
- [ ] Delete the "Pain Point One/Two/Three" heading language and the em-dash heading qualifiers
      ("Stated Exactly, Unsoftened", "Faithfully Open") as part of the move (FIX-189 partial).
- [ ] Record the page count before and after the move for the Phase 11 budget reconciliation.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: The reorder is confined to `typst/FormalFoundations.typ` and touches no
shared module. Confirm with `git status --short` before commit: `typst/template.typ` and
`typst/notation/bimodal-notation.typ` must be unmodified. If the reorder turns out to require a
change to either, this phase's tier escalates to `interface` and
`typst compile typst/BimodalReference.typ` joins its verification set.

**Files to modify**:
- `typst/FormalFoundations.typ` - section headings, section order, label and reference repair

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0, which proves every `@sec:` reference resolves.
- `grep -n "^= " typst/FormalFoundations.typ` lists exactly the five target headings in order.
- `grep -n "Pain Point\|Unsoftened\|Faithfully Open" typst/FormalFoundations.typ` returns nothing.
- The (DD) theorem, its proof, and the two-fibre figure are all present in the new section 3
  (nothing was dropped in the fold).
- Editorial bar: E2 holds for the heading set; E6 holds document-wide.

---

### Phase 3: Section 1 — The System, Rewritten Semantics-First [NOT STARTED]

**Goal**: Rebuild the system layer as the paper states it: extended language primary, one definition
per notion, the atom-interpretation error corrected, and the topology result that motivates the
total-history restriction stated. Discharges FIX-113, FIX-123, FIX-126, FIX-135.

**Tasks**:
- [ ] Replace `|p| subset.eq H_(F) times D` with the paper's `|p_i| subset.eq W` and the atomic
      truth clause with `M, tau, x |= p_i` iff `tau(x) in |p_i|`, matching `def:BL-model` and
      `def:BL-semantics` verbatim per the definitions-of-record file.
- [ ] Re-check line by line every remaining paraphrase of model structure, atom valuation, the Box
      clause, frame validity, and logical consequence against the recorded anchors. Correct any
      further drift found; record each correction.
- [ ] Split the run-on definitions at `:124` into separate environments: Temporal Order; Task
      Relation with Fiber, Cone, and Segment as indented labelled clauses; and the converse
      convention as its own definition or definition-clause.
- [ ] Expand the Frame definition's four axioms (Compositionality, Seriality, Limit, Spherical) into
      an indented list using the existing `items`/`item` helpers in `typst/template.typ:126-139`.
      Check `typst/chapters/02-semantics.typ` and `typst/chapters/04-metalogic.typ` for the
      established list styling before inventing new styling.
- [ ] Expand the world-history definition (currently one dense sentence at `:133`) into separate
      clauses for partial history, world history, total history / possible world, and `H_F`.
- [ ] Make the extended language the primary exposition, with Since/Until as the only primitive
      tense operators and the paper's own argument-order convention per Phase 1's G2 decision.
      Demote the base language to a single footnote citing the paper anchor and the link
      `https://benbrastmckie.com/publications/possible_worlds.pdf`, written for a reader assumed
      unfamiliar with the paper.
- [ ] Add the topology material at the depth decided in Phase 1: the task topology generated by the
      cones, its T1 and R0 status, and the partial-history-as-restriction question stated as a live
      definitional question rather than settled silently (research decision D4). If the depth
      decision was "out of scope", state that in one explicit sentence instead of omitting it.
- [ ] Remove the FIX comments at lines 113, 123, 126, 135.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- `typst/FormalFoundations.typ` - section 1 body
- `typst/sync-check-whitelist.txt` - new paper anchors (`def:task-topology`, `app:topology-t1`,
  `app:topology-r0`, and any other new backticked span), each with a one-line reason

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `scripts/typst-sync-check.sh` exits 0 (V3).
- `grep -n "H_(#taskframe) times D\|times D" typst/FormalFoundations.typ` shows the erroneous atom
  clause is gone.
- Fidelity: V1 — each of the section's definitions is diffed against its recorded anchor, and the
  diff result is stated in the phase's commit message.
- Editorial bar: E1 (Temporal Order, Task Relation, converse convention, Frame, world history,
  model, and the topology each live in an environment); E2, E3, E4, E5 over section 1.
- `grep -n "FIX:" typst/FormalFoundations.typ` no longer lists lines from section 1.

---

### Phase 4: Section 2 — What Is Proved, Stated Per System [NOT STARTED]

**Goal**: Replace the single dump-everything completeness theorem and the vague framing prose with
per-system statements, and state the decidability position as formal fact rather than narration.
Discharges FIX-174 and FIX-189.

**Tasks**:
- [ ] Rewrite the soundness statement as one theorem covering the systems in scope, compressed.
- [ ] Compress the three correspondence statements (discreteness, density, Dedekind-completeness)
      to statement plus one-line idea, keeping the *claims* while removing the confusing framing
      prose. The contingency argument in section 4 presupposes these, so they are compressed, not
      dropped.
- [ ] Break the current one-sentence completeness theorem (`:192-194`) into per-class statements:
      which system is complete over which frame class, each with its machine-checked status quoted
      as measured. The general Base-frame result keeps its "outstanding obligation" framing.
- [ ] Rewrite the decidability subsection: state the r.e.-theorems / FMP argument formally, state
      the retraction of the blanket FMP premise with both witnesses as formal facts, and state the
      two intersection reductions as a target strategy rather than a result.
- [ ] Add a bridging remark of at most four sentences connecting the system layer to what
      completeness would buy, closing the section-1-to-section-2 gap the research diagnosed.
- [ ] Use `#leansrc(module, name)` for the headline machine-checked results so machine-checked and
      paper-side claims are visually distinct.
- [ ] Remove the FIX comments at lines 174 and 189.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `typst/FormalFoundations.typ` - section 2 body
- `typst/sync-check-whitelist.txt` - only if new non-Lean anchors are introduced

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `scripts/typst-sync-check.sh` exits 0.
- Fidelity: V2 — every per-class completeness status matches the research report's Lean
  verification table exactly; in particular the general Base-frame result still reads as carrying
  `sorryAx` and is not upgraded.
- Editorial bar: E1 (every completeness and decidability claim is a theorem or proposition, not a
  prose sentence); E2, E3, E4, E5 over section 2.
- The three correspondence claims are still present in the compressed table.

---

### Phase 5: Section 3, Part I — Canonical Machinery and the Discreteness Split [NOT STARTED]

**Goal**: Open the construction section at book-chapter formality: consistency and maximal
consistent sets, Lindenbaum, the three-way discreteness case split with the mixed case eliminated,
and the truth-lemma mechanism that the Box case actually uses. Discharges FIX-231 and the first half
of FIX-285.

**Tasks**:
- [ ] Write the MCS / Lindenbaum layer as definitions plus a lemma, naming `set_lindenbaum` in
      `FormalSystem/Metalogic/Core/MaximalConsistent.lean` and the finitary set-level layer.
- [ ] State the three-way case split as a theorem: on the discreteness indicator, the dense branch
      and the discrete branch, with the mixed branch eliminated by `mcs_mixed_case_absurd`
      (`FormalSystem/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean:42`).
- [ ] Restate the (DD) phenomenon compactly for the extended language directly, via the sentence
      naming discreteness, as the motivation for why the split is the right move — the fold decided
      in Phase 2, now rewritten. It appears here as a motivating result, not as a named pain point,
      satisfying FIX-231.
- [ ] Rewrite the structural-rhyme observation as a bounded `#remark` stating the mathematical
      fact (the extended language has a sentence naming discreteness; the base language does not),
      with the self-referential praise removed.
- [ ] State the bundled-MCS coherence machinery (`Metalogic/Bundle/BFMCS.lean`,
      `modal_forward`/`modal_backward`) as an actual definition plus the Box-case obligation it
      discharges in the truth lemma, rather than naming the module and moving on.
- [ ] State the D-parametric algebraic truth lemma (`Metalogic/Algebraic/FlowFrame.lean`,
      `multiFamTaskFrameGen`) and its Spherical discharge as a third named discharge pattern; this
      is the fact Phase 8's way-forward argument depends on.
- [ ] Retain or redraw the three-way case-split `cetz` figure so it illustrates the theorem just
      stated. Retire the two-fibre figure or repurpose it for the (DD) restatement, whichever the
      rewritten text actually needs.
- [ ] Remove the FIX comment at line 231.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- `typst/FormalFoundations.typ` - section 3, opening subsections
- `typst/sync-check-whitelist.txt` - only if a new backticked span does not resolve under
  `FormalSystem/`

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0, including both `cetz` figures.
- `scripts/typst-sync-check.sh` exits 0 — this phase introduces the most new Lean identifiers of any
  phase, so this gate is load-bearing here.
- Fidelity: V2 — `set_lindenbaum`, `mcs_mixed_case_absurd`, `modal_forward`, `modal_backward`, and
  `multiFamTaskFrameGen` each confirmed to exist at the cited module before being cited.
- Editorial bar: E1 (MCS, Lindenbaum, the case split, BFMCS coherence, and the truth lemma are all
  environments); E3 (the structural-rhyme remark is at most four sentences); E2, E4, E5.

---

### Phase 6: Section 3, Part II — The Three Canonical Constructions and Status [NOT STARTED]

**Goal**: Give each completeness branch its own definition-plus-theorem treatment with the actual
construction named and credited, then close the section with the re-stamped machine-status table.
Discharges the second half of FIX-285.

**Tasks**:
- [ ] Dense branch: the Burgess-style chronicle construction, stated as a definition (the chain from
      the singleton chronicle through the omega-chain to the limit chronicle) plus the completeness
      theorem it yields, with the eventuality-filling obligation stated. Credit Burgess 1982 at the
      construction itself.
- [ ] Discrete branch: the Reynolds/Doets pipeline, stated as a definition plus theorem, with the
      Kamp-theorem-based expressive-completeness step stated as the step it is. Credit Reynolds 1992,
      Doets 1987, Kamp 1971, and Gabbay-Hodkinson-Reynolds at the construction, per research finding
      F7's uncredited-citation observation.
- [ ] Adapt, with compression, the correctly-scoped Kamp treatment from
      `typst/chapters/p3-vlach-blstar.typ:108-128` (strict operators, Dedekind-complete flows, the
      standard miscitation corrected). Adapt by reading and rewriting; do not `#include` and do not
      edit that chapter file.
- [ ] Dedekind branch: the engine and the real-model subtree, stated as definition plus theorem on
      the Reynolds-triple basis, with the order-isomorphism step named.
- [ ] Rewrite the machine-status paragraph as a table: declaration, module, axiom set, sorry status,
      using Phase 1's re-stamped counts and commit hash. Keep the dead-code observation about the
      superseded discrete countermodel, since it is what makes the Base-frame `sorryAx` framing
      precise.
- [ ] Delete the "Terminology, settled project-wide" paragraph; if the finite-context fact is worth
      keeping, fold it into a single parenthetical at first use of consequence completeness.
- [ ] Keep the discipline note that the Lean-side frame-class vocabulary is not silently renamed to
      the paper's system names, at the hedging posture decided in Phase 1 (G1).
- [ ] Remove the FIX comment at line 285.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: The status counts recorded in Phase 1 are asserted to be unchanged from the
document's existing claims apart from the commit stamp (research finding F2: `sorry_total=5`,
`sorry_total_excl_boneyard=1`, `sorry_algebraic=0`, `sorry_bxcanonical=0`, `sorry_bundle=0`).
Confirm by re-running `scripts/typst-status-counts.sh --json` at this phase's own commit and
diffing against Phase 1's record; if any count moved, the table reports the new measurement and the
surrounding prose is re-checked for a claim that the change invalidates.

**Files to modify**:
- `typst/FormalFoundations.typ` - section 3, construction subsections and status table
- `typst/sync-check-whitelist.txt` - if required by new spans

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `scripts/typst-sync-check.sh` exits 0.
- `scripts/typst-status-counts.sh --json` output matches the table written into the document.
- Fidelity: V2 — each of the three branch theorems names a declaration confirmed present at the
  file and line in the research report's verification table.
- Editorial bar: E1 (each branch is a definition-plus-theorem pair, not a bulleted module tour);
  E2 (no "measured", "honest", or self-praising register survives); E3, E4, E5.
- Every literature credit sits at the construction it credits, not only in a trailing footnote.

---

### Phase 7: Section 4 — Two Costs of the Semantics [NOT STARTED]

**Goal**: Rewrite the contingency and objective-modality material through a formal lens: definitions
where there were block quotes, propositions where there were stage directions. Discharges FIX-208.

**Tasks**:
- [ ] Formalize irregular worlds and coset domains as an actual `#definition`, currently present
      only inside a block quote. Keep the paper's own quoted passage only where the exact wording is
      load-bearing.
- [ ] State the necessity-if-true argument as a one-line formal fact (frame validity is closed under
      necessitation) plus the symmetry precedent, in a bounded remark — not as a paragraph of prose.
- [ ] State the price of irregular worlds as a proposition with its parts enumerated: density is
      valid over no frame; the discreteness axiom fails over a discrete order with a dense subgroup;
      the three correspondences lapse together; the strongest-objective-modality standing is
      displaced. Keep the existing discipline that distinguishes the report's own analysis from
      quotable paper text.
- [ ] Rewrite the strongest-objective-modality subsection: the identity and predicativity apparatus
      compressed to what the definition needs; the strongest-objective-normal-operator definition,
      the existence result, and the uniqueness/S4/B chain as stated results; the orthogonality point
      (a strictly narrower accessibility relation can carry a strictly stronger logic) as a
      proposition with the Stability operator as the witness.
- [ ] Add a bounded remark stating why exactly these two costs remain and how they interact — the
      displacement of the strongest modality is the point of contact, and the research's structural
      diagnosis says the ordering logic must be stated rather than left implicit.
- [ ] Address Dana's second question directly at the register of the rest of the section: whether
      the necessity-if-true of temporal structure is a genuine problem or an instance of an ordinary
      necessitation phenomenon.
- [ ] Remove the FIX comment at line 208.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Files to modify**:
- `typst/FormalFoundations.typ` - section 4 body

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `scripts/typst-sync-check.sh` exits 0.
- Fidelity: V1 — the quoted irregular-worlds passage is re-verified verbatim against the live paper
  at this phase's authoring pass, since it is quoted from an unlabelled site and cannot be pinned by
  anchor.
- Fidelity: the commented-out paper sentences remain uncited as paper text; report-side analysis
  stays marked as such.
- Editorial bar: E1 (irregular worlds, the price, the strongest-modality definition, and the
  orthogonality point are all environments); E2 (no "The worry, at full strength", "The price,
  stated exactly", "The pain, stated plainly", "kept unblurred"); E3, E4, E5.
- The correspondence claims Phase 4 preserved are still the premises this section uses.

---

### Phase 8: Section 5 — Toward a Representation Theorem [NOT STARTED]

**Goal**: Restructure the representation section to open with what is live, present the three-tier
status honestly, commit to a recommended route, and close with one precisely-posed open question.
Discharges FIX-337.

**Tasks**:
- [ ] Cut the superseded-waypoint subsection from a four-point defect list to at most one sentence
      plus a footnote, stating only that an earlier sketch is superseded and the one substantive way
      the live architecture differs.
- [ ] Open the section with the live algebraic layer as a definition-plus-remark pair: the
      Lindenbaum-Tarski algebra, its ultrafilters, and the interior-operator treatment of the
      modalities, with the measured sorry-free status cited. Adapt the five-step overview in
      `FormalSystem/Metalogic/Algebraic/README.md` as source material.
- [ ] Present the three-tier status table (live algebraic; archived Jonsson-Tarski with its named
      revival gate; design-only shift-set) with the labels kept explicit, per research decision D3.
- [ ] State the shift-set target formally: the structure, the induced task model in both directions,
      and the first-order axiomatizability payoff. Keep shift-set names as ordinary mathematics, not
      backticked Lean identifiers, since no such identifier exists.
- [ ] State the roadmap gate by its content — the shift-set representation theorem landing sorry-free
      in both directions with a clean axiom report gates the expensive ultraproduct programme — with
      no task number anywhere in the file (E6).
- [ ] Compress the six lettered forks to the two substantive arguments: the Spherical
      discharge-pattern analysis (three known patterns; whether a weaker saturation condition
      suffices for the Step Lemma) and the group-structure-as-crux argument (the discrete-or-dense
      dichotomy is a theorem about ordered abelian groups and fails for bare linear orders, so
      weakening the group structure dissolves the obstruction at a stated cost). The remaining
      points collapse into one closing remark.
- [ ] Add a short note, per research decision D2, on why expressive completeness (the Kamp
      machinery used inside the discrete branch) is not a representation theorem — a duality is a
      different target. This is what earns Dana's own hedge about metric tense operators its place.
- [ ] Close with one precisely-posed open question rather than an enumeration: whether Spherical
      admits a reformulation surviving infinite carriers.
- [ ] Address Dana's third question directly, including the metric-tense-operator suggestion, at the
      section's register.
- [ ] Retain or redraw the landscape `cetz` figure so it matches the restructured tiering.
- [ ] Remove the FIX comment at line 337.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Files to modify**:
- `typst/FormalFoundations.typ` - section 5 body
- `typst/sync-check-whitelist.txt` - the section's deliberately-non-Lean shift-set spans are already
  whitelisted at `typst/sync-check-whitelist.txt:128`; extend only if new spans appear

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0, including the landscape figure.
- `scripts/typst-sync-check.sh` exits 0.
- `grep -nE "task [0-9]+|task-[0-9]+" typst/FormalFoundations.typ` returns nothing (E6).
- Fidelity: V2 — the live/archived/design-only labels match the actual tree state; nothing under an
  archived subtree is described as live.
- Editorial bar: E1, E2 ("this report's single most valuable analysis" and kin are gone), E3, E4, E5.
- The section closes with exactly one posed open question, not a list.

---

### Phase 9: Abstract, Front Matter, and Document-Wide Register Sweep [NOT STARTED]

**Goal**: Fix the abstract's typography, rewrite the abstract to describe the new five-section
document, and sweep any register violation that survived the per-section passes. Discharges FIX-93.

**Tasks**:
- [ ] Add a local `#let abstract-block(body)` at the top of `typst/FormalFoundations.typ` setting no
      first-line indent and a body size one point below the document's, and wrap the abstract in it.
      Keep this local to the standalone report; do not modify `typst/template.typ`.
- [ ] Rewrite the abstract to describe the five-section document and its three payloads, in the
      target register, replacing the section-by-section tour of the old seven-section structure.
- [ ] Update the file's header comment block to describe the new structure.
- [ ] Run the E2 and E5 greps over the whole file and repair every remaining hit.
- [ ] Optionally add the one-sentence Scott anchor (research decision D5), at the author's register;
      one sentence maximum, or none.
- [ ] Add the one-line acknowledgment that complexity, interpolation, and finite axiomatizability
      are known-open and out of scope (research gap G4).
- [ ] Remove the FIX comment at line 93 — after this phase, `grep -c "FIX:"` must be 0.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: local

**Scope Hypothesis**: The E2 register grep matched 20 lines at plan time. After Phases 3-8, the
residual count is expected to be small and confined to the abstract and header comment. Confirm by
running the E2 grep at the start of this phase; if the residual is large, the phase reports which
section leaked and that section's owning phase is re-opened rather than patched over here.

**Files to modify**:
- `typst/FormalFoundations.typ` - abstract block helper, abstract text, header comment, residual
  register repairs

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0 and the abstract renders unindented at the
  smaller size.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 0.
- The E2 grep and the E5 grep both return no hit outside quoted passages, document-wide.
- `git status --short` confirms `typst/template.typ` is unmodified, which is why this phase is
  `local` and not `interface`.

---

### Phase 10: Mathematical Fidelity Audit [NOT STARTED]

**Goal**: Verify that the rewritten document is faithful to the paper and to the Lean development,
independently of whether it compiles. This is an adversarial read, not a repair pass; repairs it
finds are made here, but the audit is conducted first as a read against sources.

**Tasks**:
- [ ] Diff every definition in the finished document against its anchor in the definitions-of-record
      file produced in Phase 1. Record a per-definition verdict.
- [ ] Re-check the atom-interpretation clause and every downstream paraphrase of model structure,
      atom valuation, the Box clause, frame validity, and logical consequence — the propagation the
      research report says is bounded but must be checked line by line rather than assumed.
- [ ] Re-check every Lean-backed claim against the research report's verification table: declaration
      exists, at the named module, with the sorry/axiom status as stated. Confirm in particular that
      the general Base-frame result is still described as carrying an outstanding obligation.
- [ ] Re-check every "open", "retracted", "archived", and "not started" label against the actual tree
      state; confirm no archived content is described as live.
- [ ] Re-check that the hedging posture chosen in Phase 1 for the frame-class/system identification
      (G1) is applied consistently everywhere the identification appears — an inconsistent posture is
      worse than either choice.
- [ ] Re-check the Since/Until argument-order presentation against Phase 1's G2 finding.
- [ ] Re-verify the two verbatim quoted passages against the live paper.
- [ ] Repair every discrepancy found, and record the audit verdicts.

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: full

**Files to modify**:
- `typst/FormalFoundations.typ` - repairs arising from the audit
- `specs/444_overhaul_formalfoundations_presentation/definitions-of-record-444.md` - audit verdicts
  appended

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `scripts/typst-sync-check.sh` exits 0.
- `scripts/typst-status-counts.sh --json` still matches the document's status table.
- Every definition in the document has a recorded verdict against a paper anchor.
- Every Lean-backed claim has a recorded verdict against the verification table.
- Zero discrepancies remain open; anything unresolved is stated in the document as an open question
  rather than silently asserted.

---

### Phase 11: Consistency, Cross-Reference, and Narrative Read-Through [NOT STARTED]

**Goal**: Read the finished document end to end as a reader would, and fix what only a whole-document
read exposes: cross-references, notation uniformity, section-to-section flow, and the page budget.

**Tasks**:
- [ ] Verify every `@sec:` and `@` reference resolves and points at the intended target — the compile
      proves resolution, but a reference resolving to the wrong section is invisible to the compiler
      and must be read.
- [ ] Sweep notation uniformity across all five sections: one symbol per notion, consistent use of
      the macros from `typst/notation/bimodal-notation.typ`, consistent naming for the systems and
      frame classes, consistent Since/Until argument order per the G2 decision.
- [ ] Verify environment numbering reads sensibly and that `#proposition` and `#corollary` — imported
      but unused in the original — are used where they are the right environment.
- [ ] Read the narrative arc: each section opens by stating what it establishes and closes by
      handing off to the next; the reason the two costs follow the construction is stated; no section
      is a list of separate worries.
- [ ] Reconcile the page count against the budget recorded in Phase 2, and compress the section that
      overruns rather than trimming uniformly.
- [ ] Verify the document reads for a reader assumed unfamiliar with the paper: every symbol is
      defined before use, and the base-language footnote carries the paper link.
- [ ] Run the full gate set one final time.

**Timing**: 1.5 hours

**Depends on**: 10

**Verification Tier**: full

**Scope Hypothesis**: The finished document is asserted to hold at roughly its existing page budget
(the file's own header states a "~10 pages of body text" target). Confirm by comparing the compiled
page count against the Phase 2 measurement; if it overruns, name the overrunning section and
compress it rather than reporting the overrun as acceptable.

**Files to modify**:
- `typst/FormalFoundations.typ` - cross-reference, notation, transition, and length repairs

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- `typst compile typst/BimodalReference.typ` exits 0 (proves no shared module was disturbed across
  the whole task).
- `scripts/typst-sync-check.sh` exits 0.
- `scripts/typst-status-counts.sh --json` matches the document.
- `grep -c "FIX:" typst/FormalFoundations.typ` returns 0.
- E2 and E5 greps return no hit outside quoted passages; E6 grep returns nothing.
- Every reference read and confirmed to point at its intended target.
- Page count reconciled against the Phase 2 measurement.

---

## FIX Tag Ownership Map

Every `FIX:` tag in the source is discharged by exactly one phase. Confirm the tag inventory against
Phase 1's Scope Hypothesis before relying on this table.

| Line | Subject | Owning phase |
|------|---------|--------------|
| 93 | Abstract indent and font; needs an environment | 9 |
| 113 | Align notation to the paper; make the extended language primary | 3 |
| 123 | Converse convention and neighbours each need their own definition | 3 |
| 126 | Frame definition is scrunched; expand into indented elements | 3 |
| 135 | Atom-interpretation clause is wrong; full faithfulness pass required | 3 (write), 10 (audit) |
| 174 | Correspondence table poorly stated; drill to the Henkin constructions | 4 (compress table), 5-6 (constructions) |
| 189 | Remove self-referential meta-commentary; no substance in the section | 4 (rewrite), 2 (headings), 9 (sweep) |
| 208 | Contingency section poor; introduce every issue through a formal lens | 7 |
| 231 | Drop the base-language split-validity focus; extended language only | 2 (fold), 5 (restate) |
| 285 | Rewrite the construction section in precise formal detail with citations | 5 and 6 |
| 337 | Same treatment for the representation section; mechanics only | 8 |

## Testing & Validation

- [ ] `typst compile typst/FormalFoundations.typ` exits 0 at the end of every phase.
- [ ] `typst compile typst/BimodalReference.typ` exits 0 at the end of Phases 1 and 11 (shared-module
      integrity).
- [ ] `scripts/typst-sync-check.sh` exits 0 at the end of every content phase.
- [ ] `scripts/typst-status-counts.sh --json` agrees with the document's status table.
- [ ] `grep -c "FIX:" typst/FormalFoundations.typ` returns 0.
- [ ] E2 register grep returns no hit outside quoted passages.
- [ ] E5 vague-gloss grep returns no hit outside quoted passages.
- [ ] E6 task-number grep returns nothing under `typst/`.
- [ ] `git status --short` shows no modification to `FormalSystem/**`, `typst/chapters/**`, or
      `typst/BimodalReference.typ`.
- [ ] Every definition has a recorded fidelity verdict against a paper anchor (Phase 10).
- [ ] Every Lean-backed claim has a recorded fidelity verdict (Phase 10).

## Artifacts & Outputs

- `typst/FormalFoundations.typ` - the overhauled five-section document (primary deliverable)
- `typst/FormalFoundations.pdf` - recompiled output
- `typst/bibliography.bib` - new entries for newly cited sources
- `typst/sync-check-whitelist.txt` - new whitelist entries with reasons
- `specs/444_overhaul_formalfoundations_presentation/definitions-of-record-444.md` - paper anchors,
  G1/G2/G3 decisions, re-stamped counts, FIX disposition table, Phase 10 audit verdicts
- `specs/444_overhaul_formalfoundations_presentation/summaries/02_{short-slug}-summary.md` -
  execution summary
- `specs/444_overhaul_formalfoundations_presentation/plans/02_formalfoundations-presentation-overhaul.md` -
  this plan

## Rollback/Contingency

- The pre-rewrite state is commit `6e19c48d2`; `typst/FormalFoundations.typ` and its compiled PDF are
  both tracked there, so any phase can be reverted with a targeted
  `git checkout 6e19c48d2 -- typst/FormalFoundations.typ` after snapshotting per
  `.claude/rules/git-workflow.md`.
- Each phase commits on green, so a failed phase reverts to the last green phase boundary without
  losing earlier work.
- If Phase 2's reorder cannot be made to compile, revert it and execute Phases 3-8 as in-place
  rewrites in the original section order, deferring the reorder to a final move phase — the content
  work does not depend on the order, only the cross-references do.
- If Phase 1 finds that the paper has moved such that the recorded anchors no longer match, stop and
  mark the task `[BLOCKED]` rather than rewriting against stale definitions; the whole rewrite's
  value is its fidelity.
