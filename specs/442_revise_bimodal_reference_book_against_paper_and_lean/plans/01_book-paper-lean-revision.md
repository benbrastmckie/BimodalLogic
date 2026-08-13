# Implementation Plan: Revise BimodalReference Against the Paper and the Lean Tree

- **Task**: 442 - revise_bimodal_reference_book_against_paper_and_lean
- **Status**: [IMPLEMENTING]
- **Effort**: 21 hours
- **Dependencies**: None (the 414/415/417/419/420 gate is LIFTED per the task description's binding
  section 1; exposure to those three in-flight tasks is managed by the marker convention in Phase 2,
  not by waiting)
- **Research Inputs**: `specs/442_revise_bimodal_reference_book_against_paper_and_lean/reports/01_book-paper-lean-sync-audit.md`
- **Artifacts**: plans/01_book-paper-lean-revision.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

The BimodalReference book fails on two axes at once: it is factually out of sync with both the
paper (`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`) and the live Lean
tree, and it is thin as exposition. This plan fixes both. The correctness work is driven by two
failing gates — `typst-sync-check.sh` Check 1 (25 unresolvable backtick spans) and Check 2 (3 stale
generated counts) — plus three content corrections the gates cannot see: the completeness story is
epistemically *reversed* (the book says "open problem"; the paper says provably incomplete), the
conservative-extension theorem has been deleted from the paper, and `02-semantics.typ` is missing
two of the paper's four frame axioms entirely. The expository work — a real introduction, six named
reader-stumble remarks, five cetz diagrams, and a resolving bibliography — is half the task, not a
garnish.

Definition of done is the task description's five-item acceptance list: sync-check fully clean with
no dead path whitelisted, a clean `typst compile` with no unresolved references or citations,
`check-paper-definitions.sh` at case (a) or (b), a new dated verdict section in
`typst/SYNC-MAP.md`, and a findings note in `reports/`.

### Research Integration

The research report is the disposition authority for the 25 Check-1 violations and is integrated
phase-by-phase below. Findings that materially shape this plan:

- **Report §2b resolves two "violations" that are not violations.** `FMP.assignmentSpace_card` and
  `FMP.filtered_world_bound` are real, live, sorry-free theorems at
  `FormalSystem/Metalogic/Decidability/FMP/FMP.lean:190` and `:209`. The checker does a literal
  `grep -F` and the source never spells the `FMP.` prefix. Fix by dropping the prefix in the book,
  not by deleting a claim.
- **Report §2a establishes the delete-don't-repoint rule for the ConservativeExtension cluster.**
  The whole module now lives only under `FormalSystem/Boneyard/`, and the paper deleted
  `thm:ConservativeExtension` in the same restructure. Boneyard citation is a non-goal.
- **Report §5 confirms the Dedekind class sits strictly above Dense**, not as a fourth incomparable
  leaf. `FormalSystem/ProofSystem/Axioms.lean` already carries the correct lattice as ASCII art in a
  doc comment; the diagram must mirror that shape.
- **Report §4 supplies the exact paper derivations** (the discrete-or-dense dichotomy proof, the
  (DD) derivation via TMP-NB and M5, the Halldén clarification, the named Lean obligations) so the
  corrected prose can be written without a further paper pass.
- **Report §8 supplies five print-ready BibTeX entries** copied from the paper's own
  `possible_worlds.bib`.
- **Report §11 proposes the `LEAN-ANCHOR-MAY-MOVE` marker convention** adopted in Phase 2.

Two of the research report's own open flags were closed during planning and are recorded here so
the implementer does not re-derive them:

- **`Bridge.lean` (05-theorems.typ) is a clean repoint, not an unsourced citation.** The report
  flagged it as "needing fresh sourcing." It is cited in the context of `Theorems/Perpetuity/`
  (05-theorems.typ:39 and :191, the P6 infrastructure claim). The live directory
  `FormalSystem/Theorems/Perpetuity/` contains `Helpers.lean`, `MonotonicityDuality.lean`,
  `Principles.lean`, `README.md` — no `Bridge.lean`. `MonotonicityDuality.lean`'s own module
  docstring reads "Perpetuity Monotonicity and Duality Lemmas, and P6" and it carries a
  "## Bridge Lemmas for P6 Derivation" section plus the `perpetuity6` proof itself. **Repoint
  `Bridge.lean` -> `MonotonicityDuality.lean` at both sites.** Confirm at implement time.
- **`Metalogic/BXCanonical/Completeness.lean` does exist.** The report could not confirm it from a
  `-maxdepth 2` walk. A direct `find FormalSystem/Metalogic/BXCanonical -maxdepth 1 -name "*.lean"`
  returns it alongside `CanonicalChain.lean`, `CanonicalModel.lean`, `CompletenessDedekind.lean`,
  `Frame.lean`, `OrderedSeedConsistency.lean`, `TruthLemma.lean`. The `06-notes.typ` citation of it
  is live and needs no repoint.

### Prior Plan Reference

No prior plan. This task absorbs and supersedes `sync_typst_book_with_refactored_paper`, which was
marked [EXPANDED] on this task's creation and never reached the planning stage; its binding content
is carried forward verbatim inside this task's own description (sections 3 and 9), not in a prior
plan artifact.

### Roadmap Alignment

`roadmap_path` was not supplied in the delegation context, so no roadmap consultation was performed
as a plan input. `specs/ROADMAP.md` does exist and carries a "Documentation Track: BimodalReference
Living Monograph" section describing the book's part structure and its two mechanical gate scripts;
this plan is consistent with that track. **ROADMAP.md is not modified by this task.**

## Goals & Non-Goals

**Goals**:
- Drive `scripts/typst-sync-check.sh` to Check 1 TOTAL_VIOLATIONS=0, Check 2 MISMATCH_COUNT=0,
  Check 3 clean — with every whitelist addition carrying a one-line reason and **no dead path
  whitelisted**.
- Replace the reversed completeness story everywhere it appears: TM is sound but **provably
  incomplete** over its own frame classes; completeness is carried by the machine-checked BL^+
  systems; the (DD) split validity is the witness; TM is semantically — not Halldén — incomplete.
- Rewrite the conservativity passages to the four-part status (backward unconditional; forward
  fails for base case and unconditionally for discrete; open for dense and complete). Do not
  repoint — there is no live module.
- Bring `02-semantics.typ` up to the paper's current four-axiom `def:frame` (Compositionality,
  Seriality, Limit, Spherical) with Nullity as a derived lemma and the positive-cone / converse-
  convention presentation.
- Correct "three frame classes" to four everywhere, and rebuild `04-metalogic.typ`'s `Metalogic/`
  module table against the live tree.
- Meet the expository mandate: a real introduction, six named remarks, five cetz diagrams, and a
  bibliography where every `@`-citation resolves.
- Leave behind a mechanical re-sync path: one `LEAN-ANCHOR-MAY-MOVE` marker token, every occurrence
  listed in `typst/README.md`, so the follow-up sweep after the three in-flight Lean tasks land is
  a grep and not a re-audit.

**Non-Goals** (from the task description's section 10, binding):
- No edits under `/home/benjamin/Philosophy/Papers/` — the paper is read-only ground truth.
- No Lean changes. A Lean/paper divergence is **recorded** in the findings note and raised with the
  user, never fixed here.
- No changes to `latex/` — separately stale, separately owned.
- No citing anything under `FormalSystem/Boneyard/`.
- No hand-editing `typst/generated/` — regenerate via `scripts/typst-status-counts.sh`.
- No task numbers anywhere in `typst/**`.
- No use of `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/metalogic.tex` as a source.
- No modification of the separate Lean conservativity-bridge task, whose premise this revision
  invalidates — record the finding only.
- Do not touch `p3-decidability-frontier.typ`'s `// SLOT-IN:` anchors (`ladder-table`,
  `complexity-map`, `case-study` at lines 57, 67, 78) — they hold embargoed content.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Whitelisting a dead path to silence Check 1 — the exact failure mode the checker exists to catch | H | M | Phase 9 admits a whitelist entry only for the five spans the research report classified as expository (§2c). Every other violation must be closed by a repoint or a deletion. Phase 16 re-reads the whitelist diff and rejects any entry naming a `.lean` path. |
| Rewriting the completeness story into a *new* error — conflating semantic incompleteness with Halldén-incompleteness | H | M | Phase 5 transcribes the report §4 clarification close to verbatim: TM is nowhere shown Halldén-incomplete; TM + (DD) *would* create it; Halldén-incompleteness of Log(all task frames) is a theorem and a correct signature, not a defect. |
| Deleting the *correct* "open problem" statement along with the wrong ones | M | M | Report §6 isolates the one correctly-scoped instance: `p2-decidability-practice.typ:27,33` describes the still-open filtration-to-semantic-validity Lean bridge. Phase 7 preserves it explicitly and Phase 5's sweep is scoped to exclude that file. |
| Quoting a paper definition that has drifted since the audit | H | L | Re-run `scripts/check-paper-definitions.sh` at the start of Phase 1 and again in Phase 16; STOP on case (c). Cite by `\label`/`\aitem` key with verbatim text alongside, never by line number. |
| `cor:tm-completeness`, `cor:tm-decidability`, `def:TMplus` are NOT among the 26 tracked anchors in `specs/paper-definitions-of-record.md` | M | H (already true) | Phase 5 re-verifies these three by direct grep against the live paper before quoting, and records in the findings note that they are untracked. Extending the tracked set is optional and out of scope. |
| The three in-flight Lean tasks move an anchor the book cites, silently re-staling it | M | H | The `LEAN-ANCHOR-MAY-MOVE` marker convention (Phase 2), applied in Phase 15 and enumerated in `typst/README.md`. Prose is written to survive the anchor moving; the marker is maintainer metadata, invisible in the PDF. |
| Hand-writing a count from a naive `grep -c sorry` (returns a much larger number: it counts commentary and Boneyard) | M | M | `scripts/typst-status-counts.sh` is the sole authority for every count the book states. Phase 1 regenerates; no phase hand-writes a count. |
| Diagram work balloons past its budget | M | M | Phases 13 and 14 reuse the existing `00-introduction.typ` light-cone cetz idiom (`pt(ang, r)` helper, `cetz.draw.line(..., close: true)`) rather than starting fresh. A diagram that merely restates a formula is cut, not polished. |
| Multi-file phases colliding on the same chapter file | M | M | The wave map below is built on file territory, not just logical dependency: no two phases in the same wave write the same file. Territory is listed per phase. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4, 5, 7 | 2, 3 |
| 3 | 6, 8 | 5 |
| 4 | 9 | 6, 7, 8 |
| 5 | 10 | 9 |
| 6 | 11, 12 | 10 |
| 7 | 13, 14 | 12 |
| 8 | 15 | 11, 13, 14 |
| 9 | 16 | 15 |

Phases within the same wave can execute in parallel. **Territory is disjoint within every wave** —
no two phases in the same wave write the same file, and several `Depends on` edges exist for
territory reasons rather than logical ones (Phase 10 waits on Phase 9 because Phase 9 owns
`p3-vlach-blstar.typ`, where the Vlach citation lands; Phases 11 and 12 wait on Phase 10 because it
may insert `@`-citations into any chapter). File territory per phase is listed under each phase's
"Files to modify".

---

### Phase 1: Baseline Gates and Generated-Count Refresh [COMPLETED]

**Goal**: Establish a re-verified baseline and close Check 2 mechanically, so all later phases work
against known-good numbers.

**Tasks**:
- [ ] Run `bash scripts/check-paper-definitions.sh`. Record the exit case and checksum. **STOP and
      re-issue if case (c)** names a drifted anchor.
- [ ] Run `bash scripts/typst-sync-check.sh` and capture the full Check 1 violation list and Check 2
      mismatch list verbatim into the task's scratch notes as the pre-state.
- [ ] Run `bash scripts/typst-status-counts.sh` to regenerate `typst/generated/status.typ`. Do not
      hand-edit it.
- [ ] Re-run `bash scripts/typst-sync-check.sh` and confirm Check 2 MISMATCH_COUNT=0.
- [ ] Run `cd typst && typst compile BimodalReference.typ build/BimodalReference.pdf` to confirm the
      regenerated counts compile.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The audit expects Check 1 TOTAL_VIOLATIONS=25 and Check 2 MISMATCH_COUNT=3,
with live counts `sorry_total=5`, `sorry_total_excl_boneyard=1`. Confirm by reading the actual
script output at implement time; if the counts differ from the audit, the tree has moved and the
Phase 9 disposition table must be re-checked before use.

**Files to modify**:
- `typst/generated/status.typ` - regenerated (never hand-edited)

**Verification**:
- Check 2 MISMATCH_COUNT=0 in a fresh `typst-sync-check.sh` run
- `typst compile` succeeds
- `check-paper-definitions.sh` exits case (a) or (b)

---

### Phase 2: Marker Convention and typst/README.md De-numbering [COMPLETED]

**Goal**: Fix the live task-number rule violation in `typst/README.md` and establish the single
marker token later phases will apply.

**Tasks**:
- [ ] Rewrite `typst/README.md`'s "Follow-Up Tasks" table to name each remaining in-progress chapter
      by **filename and scope**, with no task numbers. Move the number mapping, if it is worth
      keeping at all, into this task's own `specs/442_.../` directory as an internal note.
- [ ] Add a "Marker Convention" section to `typst/README.md` documenting the token
      `LEAN-ANCHOR-MAY-MOVE`, its per-source suffix form, and the sweep command
      (`grep -rn "LEAN-ANCHOR-MAY-MOVE" typst/chapters/`). Suffixes name the **scope** that will
      move it, not a task number: `canonical-completeness`, `semantic-fmp`, `co-reynolds-independence`.
      Leave the occurrence list as an explicitly-empty placeholder to be filled in Phase 15.
- [ ] Grep the whole of `typst/**` for any remaining task-number references and remove them.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The audit locates the violating table at `typst/README.md:112-121` with four
rows. Confirm by reading the file; a `grep -rn` sweep of `typst/**` for task-number patterns is the
authoritative scope, not the four known rows.

**Files to modify**:
- `typst/README.md` - de-numbered follow-up table; new Marker Convention section

**Verification**:
- `grep -rn` over `typst/**` finds no task-number references
- `typst/README.md` documents the marker token and its sweep command
- The occurrence-list placeholder is present and explicitly marked as pending

---

### Phase 3: Rewrite the Task Frames Section of 02-semantics.typ [COMPLETED]

**Goal**: Bring the book's frame definition up to the paper's current four axioms. This is the
largest single content gap in the book and is invisible to the sync checker.

**Tasks**:
- [ ] Replace the current axiom list (`02-semantics.typ:34-49`: Nullity, Reflection,
      Compositionality) with the paper's four: **Compositionality** (stated for x, y >= 0),
      **Seriality**, **Limit**, **Spherical** — quoting `\label{def:frame}` verbatim per the task
      description's section 3.
- [ ] State **Nullity as a derived lemma**, not an axiom, citing `\label{lem:nullity}` and noting it
      is derived choice-free from Seriality at x = 0 plus Limit.
- [ ] Remove Reflection as an axiom; negative durations come from the **converse convention**
      `w =>_{-x} u := u =>_x w` for x >= 0, per `\label{def:task-relation}`.
- [ ] Add the supporting definitions the frame definition presupposes: `\label{def:temporal-order}`
      (nontrivial totally ordered abelian group with positive cone), `\label{def:task-relation}`
      (Fiber, Cone, Segment), `\label{def:directed}`.
- [ ] **Invert the divergence framing.** The current gloss presents the Lean structure's
      positive-cone Compositionality plus converse lemma as a Lean/paper divergence needing
      justification. The paper *adopted* that presentation — rewrite to record **agreement**.
- [ ] Honor the three notation traps: segments written `[w, v]_x^y` (never the retired `\Seg`
      function-application form); **Spherical** ranging over directed families of nonempty **fibers
      and segments as two separate classes** (never the retired one-sided-fibers-among-segments
      device); and the vocabulary "task-constrained function" retired entirely.
- [ ] Any explicit converse operation is written with a superscript inverse
      (`=>^{-1}` / `R^{-1}`), never the relation-algebra breve/smile. Introduce no operator symbol
      unless genuinely needed — the paper introduces none.
- [ ] Re-derive the cited `TaskFrame` Lean line number against the live tree; it has moved once
      already. Cite by name where possible rather than by line.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The audit asserts the chapter has *no* Limit clause and *no* Spherical clause
(`grep -n "Limit"` and `grep -n "Spherical"` both empty). Re-run both greps at implement time
before assuming the scope; do not trust any prior enumeration of stale sites, including the audit's.

**Files to modify**:
- `typst/chapters/02-semantics.typ` - Task Frames section rewritten against `def:frame`

**Verification**:
- `grep -n "Limit"` and `grep -n "Spherical"` in the file both return hits
- `grep -n "Reflection"` returns no axiom-list hit
- No occurrence of "task-constrained function" anywhere in the file
- `typst compile` succeeds

---

### Phase 4: Re-audit the World Histories Section of 02-semantics.typ [COMPLETED]

**Goal**: Bring the world-history layering into line with `\label{def:world-history}`, which the
frame section's staleness makes likely to be equally stale.

**Tasks**:
- [ ] Read `02-semantics.typ` from roughly line 51 (the "World Histories" section) in full and audit
      it against `def:world-history` as recorded in `specs/paper-definitions-of-record.md`.
- [ ] Establish the three-level layering precisely: a **partial history** is a function tau : X -> W
      on a **nonempty** X subset-of D with tau(x) =>_{y-x} tau(y) — nonempty domain required,
      convexity **not** required; a **world history** is a partial history whose domain is
      **convex**; a world history is **total** — equivalently a **possible world** — just in case
      X = D. The set of all total world histories over F is `H_F`.
- [ ] If the book states the existence machinery, present it in the paper's current shape:
      `def:constraints`, `lem:constraint` (Constraint Lemma), `lem:fibers`, `lem:admissible`,
      `lem:step` (Step Lemma, applies Spherical), `thm:extension` (Zorn over partial histories),
      and `cor:occurrence` — noting that `cor:occurrence` is a **merged** anchor (the former
      `thm:occurrence` and `app:nonempty` no longer exist). Include
      `\label{cor:spherical-finite}`: every frame with finite W satisfies Spherical, choice-free.
- [ ] Check the semantics clauses against `\label{def:BL-semantics}` (evaluation at a possible world
      tau in `H_F` and a time; box quantifies over all sigma in `H_F`; the atom clause carries **no**
      domain conjunct) and `\label{def:logical-consequence}`.

**Timing**: 1.0 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `typst/chapters/02-semantics.typ` - World Histories and semantics sections

**Verification**:
- The partial / world / total layering appears in that order with convexity attached only to
  "world history"
- No reference to the deleted `thm:occurrence` or `app:nonempty` anchors
- `typst compile` succeeds

---

### Phase 5: Correct the Completeness Story [COMPLETED]

**Goal**: Replace the book's "completeness remains an open problem" framing with the paper's actual
claim — TM is sound but **provably incomplete** — at every site, starting with the abstract.

**Tasks**:
- [ ] Re-verify the three governing anchors by direct grep against the live paper before quoting:
      `\label{cor:tm-completeness}`, `\label{cor:tm-decidability}`, `\label{def:TMplus}`. **These
      three are not among the 26 anchors tracked in `specs/paper-definitions-of-record.md`** —
      `check-paper-definitions.sh` will not protect them. Record that fact for the findings note.
- [ ] Rewrite `typst/BimodalReference.typ`'s abstract (around line 140) first and most carefully —
      the highest-visibility site. Headline: TM and its extensions TM_f, TM_d, TM_c, TM_dc are sound
      over their respective frame classes but **none is complete**; completeness is carried by the
      BL^+ systems.
- [ ] State the BL^+ completeness status precisely: **TM^+_d** weakly complete over the full Dense
      class, machine-checked and sorry-free; **TM^+_f** weakly complete over Z-time, machine-checked
      directly over the successor-Archimedean class; **TM^+_c** weakly complete over the
      dense-and-complete class (exactly R), machine-checked directly; **TM^+** weak completeness over
      all task frames is the stated Lean-formalization target with **one proof obligation
      outstanding** — not yet an established theorem. Carry that hedge; do not drop it.
- [ ] Write the *reason* TM is incomplete, because it is one of the most interesting things in the
      system: every nontrivial totally ordered abelian group is either discrete or dense and never
      both (translation invariance globalizes any local gap or density witness; the dichotomy
      **fails** for bare linear orders — a copy of Z followed by a copy of the rationals). Hence
      Log(all task frames) = Log(Discrete) intersect Log(Dense), and the class of all task frames is
      **not** closed under disjoint union.
- [ ] State the split validity **(DD)**: the schema Box phi_DF or Box psi_DN, for arbitrary instances
      of `\aitem{DF}` and `\aitem{DN}`, is valid over every task frame yet TM-unprovable, refuted on
      a **two-fibre countermodel** (one fibre over Z, one over R, Box read globally over both) over
      which every TM axiom and rule remains sound.
- [ ] State the Halldén clarification without conflation: TM is **semantically** incomplete, **not**
      Halldén-incomplete. TM + (DD) *would* create Halldén-incompleteness. Halldén-incompleteness of
      Log(all task frames) itself is a **theorem** and the correct formal signature of a union of two
      incompatible kinds — not a defect.
- [ ] State that in BL^+, (DD) is already a theorem with no added axiom, via `\aitem{TMP-NB}` and
      `\aitem{M5}` giving Box Next-top or Box not-Next-top — inheriting TM^+'s own outstanding
      base-case obligation, which the book must carry.
- [ ] Quote the paper's Lean-status footnote close to verbatim in `06-notes.typ`: the remaining
      obligations are the frame-axiom alignment of the Lean task-frame structure and the
      formalization of TM's own BL-language and proof system; Occurrence implies Seriality so that
      check comes free; Spherical holds automatically for finite W by `\ref{cor:spherical-finite}`;
      an infinite-W frame would raise a genuine further obligation.
- [ ] Correct `00-introduction.typ:138`'s "Soundness (proven for all three frame classes)... a
      canonical-model construction toward completeness (which remains an open problem)".
- [ ] **Do not touch `p2-decidability-practice.typ`** in this phase. Its "open problem" language is
      correctly scoped to the filtration-to-semantic-validity Lean bridge and is handled in Phase 7.

**Timing**: 2.0 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: The audit enumerates eight "open problem" / TM-completeness sites across five
files: `BimodalReference.typ:140`, `00-introduction.typ:138`, `04-metalogic.typ:14-15,:112,:140`,
`06-notes.typ:16-17,:35`. Treat this as a hypothesis: run a fresh
`grep -rn "open problem\|remains open" typst/` before starting and reconcile against the list; the
grep result, not this enumeration, is the work scope.

**Files to modify**:
- `typst/BimodalReference.typ` - abstract
- `typst/chapters/00-introduction.typ` - the Metalogic/ project-structure line
- `typst/chapters/04-metalogic.typ` - completeness sections
- `typst/chapters/06-notes.typ` - completeness and Lean-status discussion

**Verification**:
- `grep -rn "open problem"` over `typst/` returns hits only in `p2-decidability-practice.typ` (the
  FMP-bridge instance, correct) and any newly-written text where "open" is genuinely accurate
  (dense/complete conservativity, CO-vs-triple, decidability)
- The abstract states sound-but-incomplete, not open
- `typst compile` succeeds

---

### Phase 6: Rewrite the Conservativity Passages [NOT STARTED]

**Goal**: The conservative-extension theorem is **deleted from the paper**. Every book passage
presenting conservativity as an established result must be rewritten to the four-part status — and
the dead `Metalogic/ConservativeExtension/` citations deleted, never repointed.

**Tasks**:
- [ ] Rewrite each conservativity passage to the four-part status: the **backward** direction (every
      BL-theorem of TM etc. survives in TM^+ etc.) holds **unconditionally**; the **forward**
      direction **fails** for the base case (witnessed by (DD)) and **fails unconditionally** for the
      discrete extension (witnessed by `\aitem{TMP-Z1}`, unsound over Z x_lex Z); and remains
      **open** for dense and complete. `\label{def:TMplus}`'s footnote replaces the deleted theorem
      and makes no conservativity claim.
- [ ] Delete every citation of `Metalogic/ConservativeExtension/`,
      `Metalogic/ConservativeExtension/Lifting.lean`,
      `Metalogic/ConservativeExtension/Lifting.lean:683-695`, and bare `ConservativeExtension/`. The
      module lives only under `FormalSystem/Boneyard/ConservativeExtension/`; citing Boneyard is a
      non-goal. **Do not whitelist these paths.**
- [ ] Delete the claims resting on `ExtFormula.lean`, `exists_fresh_atom`, `liftDerivationWith`, and
      `lift_derivation_qfree` — all live exclusively inside the boneyarded
      `ConservativeExtension/ExtFormula.lean`.
- [ ] Confirm the three expository spans `L.map embedFormula`, `embedFormula φ`, and `⊥ U φ` in
      `p2-frame-classes.typ` disappear with the deleted prose. If any survives, it needs a
      Phase 9 whitelist entry — flag it forward rather than inventing one here.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: The audit places the conservativity cluster at `03-proof-theory.typ:213`,
`06-notes.typ`, `p2-frame-classes.typ:133-139`, and `p3-ltl-to-tm.typ:130`. Confirm with a fresh
`grep -rn "ConservativeExtension\|conservativ" typst/` — that grep, not the line list, is the scope.

**Files to modify**:
- `typst/chapters/03-proof-theory.typ`
- `typst/chapters/06-notes.typ`
- `typst/chapters/p2-frame-classes.typ`
- `typst/chapters/p3-ltl-to-tm.typ`

**Verification**:
- `grep -rn "ConservativeExtension" typst/` returns nothing
- `grep -rn "conservativ" typst/` returns only four-part-status prose, no established-result claim
- `typst compile` succeeds

---

### Phase 7: Correct the Decidability Status [COMPLETED]

**Goal**: Decidability of TM and its extensions is **open**. Fix the retracted FMP-over-Z premise,
repoint the two false-negative FMP theorem citations, and delete the dead per-class FMP file
citations — while preserving the one correctly-scoped "open problem" statement.

**Tasks**:
- [ ] State `\label{cor:tm-decidability}` as it now reads: whether TM, TM_f, TM_d, TM_c, and TM_dc
      are decidable is **OPEN**. The former blanket finite-model-property-over-D=Z premise was
      retracted as **false**.
- [ ] Give the paper's two witnesses precisely: `\aitem{DF}` is a non-theorem of TM, TM_d, TM_c,
      TM_dc yet valid in every model over D = Z; `\aitem{CO}` is a non-theorem of TM_f (witnessed by
      Z x_lex Z) yet likewise valid in every model over D = Z. A repaired FMP would have to be
      **class-specific**, ranging over effective non-Archimedean carriers such as Z x_lex Z rather
      than Z alone; none of this is established.
- [ ] State what *is* true: each system is recursively axiomatized, hence its theorems are r.e.
      regardless of completeness; a verified **sound** tableau procedure exists in this repository;
      the semantic, truth-connected FMP for the Z-time discrete case is the target of ongoing
      formalization; and decidability of Log(all task frames) = Log(Discrete) intersect Log(Dense)
      would **follow** from decidability of the two factor logics — the intersection reduction is the
      target **strategy**, not a result.
- [ ] Repoint `FMP.assignmentSpace_card` -> `assignmentSpace_card` and `FMP.filtered_world_bound` ->
      `filtered_world_bound`, dropping the namespace prefix the Lean source never writes literally.
      These are real, live, sorry-free theorems at `FormalSystem/Metalogic/Decidability/FMP/FMP.lean`
      — **not dead claims**. Confirm both still exist and are sorry-free before editing.
- [ ] Delete or rewrite the claims citing `FMP/DenseFMP.lean` and `FMP/DiscreteFMP.lean`. Neither
      exists; the live `FMP/` tree is `ClosureMCS.lean`, `Filtration.lean`, `FiniteModel.lean`,
      `FMP.lean`, `TruthPreservation.lean`, `README.md` with no per-class split. Read
      `FiniteModel.lean` / `TruthPreservation.lean` to describe how dense/discrete refinement is
      actually organized, or delete the claim if it has no live counterpart.
- [ ] **Preserve** `p2-decidability-practice.typ:27,33` — that "open problem" language correctly
      describes the still-open filtration-to-semantic-validity bridge and is a different claim from
      TM-completeness. Do not conflate the two.
- [ ] Audit `p3-decidability-frontier.typ` against the corrected status. **Do not touch its
      `// SLOT-IN:` anchors** (`ladder-table`, `complexity-map`, `case-study`).

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts a five-file live listing of
`FormalSystem/Metalogic/Decidability/FMP/` and two theorem locations in `FMP.lean`. Confirm both by
`ls` and `grep` at implement time before writing prose that depends on them.

**Files to modify**:
- `typst/chapters/p2-decidability-practice.typ`
- `typst/chapters/p3-decidability-frontier.typ` (prose only; SLOT-IN anchors untouched)

**Verification**:
- `grep -n "DenseFMP\|DiscreteFMP" typst/` returns nothing
- The two FMP theorem spans no longer carry the `FMP.` prefix
- `p2-decidability-practice.typ`'s FMP-bridge "open problem" sentence is still present
- The three `// SLOT-IN:` anchors in `p3-decidability-frontier.typ` are byte-identical to before
- `typst compile` succeeds

---

### Phase 8: Rebuild the Module Table and Correct the Frame-Class Count [NOT STARTED]

**Goal**: There are **four** frame classes, not three, and `04-metalogic.typ`'s `Metalogic/` module
table is wrong in five rows. Rebuild both against the live tree.

**Tasks**:
- [ ] Rebuild `04-metalogic.typ`'s `Metalogic/` module table from the live tree — a rebuild, not a
      patch. Verified live subtree: `Algebraic/`, `Bundle/`, `BXCanonical/` (with `Chronicle/`,
      `Filtration/`, `Quasimodel/`), `Core/` (with `RestrictedMCS/`), `Decidability/` (with `FMP/`,
      `Propositional/`, `Verified/`), `SoundnessLemmas/`, `WeakCanonical/` (with
      `DenseModelSurgery/`, `EFGames/`, `Expressiveness/`, `IntegerModel/`, `Kamp/`, `RealModel/`,
      `Separation/`). Re-run `find FormalSystem/Metalogic -type d` before writing.
- [ ] Delete the dead rows: `DenseSoundness.lean`, `DiscreteSoundness.lean`, `Completeness.lean` (as
      a direct `Metalogic/` child), and `ConservativeExtension/`.
- [ ] Repoint the soundness prose to the live unified modules `Metalogic/Soundness.lean` and
      `Metalogic/SoundnessLemmas.lean` (plus the `SoundnessLemmas/` directory). This is **not** a 1:1
      filename swap — the module structure itself changed from per-class files to a single unified
      soundness module, and the prose must reflect that.
- [ ] Correct "three frame classes" / "all three frame-class variants" to **four**: `Base`, `Dense`,
      `Discrete`, `Dedekind`, as defined in `FormalSystem/ProofSystem/Axioms.lean`. Minimum-class
      assignment maps `density`/`dense_indicator` -> Dense, `prior_UZ`/`prior_SZ`/`z1` -> Discrete,
      and `prior_U_gap`/`prior_S_gap`/`sep` -> Dedekind.
- [ ] Add the Dedekind path to the module table: `BXCanonical/CompletenessDedekind.lean`,
      `StrongCompleteness.lean` (theorems `completeness_dedekind`,
      `consequence_completeness_dedekind`), and the `RealModel/` subtree. **Verify these exact
      theorem names exist before quoting them** — the research pass did not confirm them
      line-by-line.
- [ ] Record the lattice shape correctly in prose: `Dedekind` sits **strictly above `Dense`**, not as
      a fourth incomparable leaf. `Discrete` is incomparable to both Dense and Dedekind.
- [ ] Do not hand-count axiom constructors. The count comes from
      `typst/generated/status.typ` (Phase 1).

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts the module table is wrong in exactly five rows and that
"three frame classes" appears at `04-metalogic.typ:154` and `p4-dual-verification.typ:26`. Confirm
with `grep -rn "three frame class" typst/` and a fresh `find FormalSystem/Metalogic -type d`; the
five-row figure is a hypothesis, and the table is being rebuilt wholesale regardless.

**Files to modify**:
- `typst/chapters/04-metalogic.typ` - module table rebuilt; frame-class count corrected
- `typst/chapters/00-introduction.typ` - "all three frame classes" in the project-structure section
- `typst/chapters/p4-dual-verification.typ` - "all three frame classes"

**Verification**:
- `grep -rn "three frame class" typst/` returns nothing
- Every path in the rebuilt module table resolves against a live `find FormalSystem/Metalogic`
- `Dedekind` appears in the table and in the frame-class prose
- `typst compile` succeeds

---

### Phase 9: Remaining Repoints, Whitelist, and Check 1 to Zero [NOT STARTED]

**Goal**: Close the last Check-1 violations and drive TOTAL_VIOLATIONS to 0 with no dead path
whitelisted.

**Tasks**:
- [ ] Repoint `Bridge.lean` -> `MonotonicityDuality.lean` at both sites in `05-theorems.typ`
      (line ~39, the P6-infrastructure sentence, and line ~191, the `Perpetuity/` table row).
      Confirm first: `FormalSystem/Theorems/Perpetuity/` contains `Helpers.lean`,
      `MonotonicityDuality.lean`, `Principles.lean`, `README.md`, and `MonotonicityDuality.lean`
      carries the "Bridge Lemmas for P6 Derivation" section and the `perpetuity6` proof.
- [ ] Fix `rabinovich_translate` in `p3-vlach-blstar.typ`. It lives only under
      `WeakCanonical/Kamp/Boneyard/RabinovichTranslation.lean` — boneyarded. The same chapter already
      correctly says at line ~128 that "A machine-checked Kamp theorem is an open problem"; the
      `rabinovich_translate` citation **contradicts** that sentence. Delete it, or rewrite to state
      the Rabinovich-style translation is a paper-side result and **not** machine-checked.
- [ ] Add whitelist entries to `typst/sync-check-whitelist.txt`, extending the file's existing
      category-header convention (each with a one-line reason, not appended as unstructured lines):
  - `Nat.card (FilteredWorld φ) ≤ 2^(|op("closure")(φ)|)` and
    `Nat.card (Set ↥(subformulaClosure φ)) = 2^(|op("closure")(φ)|)` — expository renderings of
    `assignmentSpace_card` / `filtered_world_bound` in Typst math notation
  - `allClosed arrow.r "valid"` — Typst-rendered math for the open `valid_iff_allClosed` bridge, not
    a Lean identifier
  - `and True` — describes a historical, now-fixed vacuous-conjunct pattern, not a current Lean
    citation. Prefer reformatting the prose to drop the backticks entirely over whitelisting.
- [ ] Run `bash scripts/typst-sync-check.sh`. Iterate until Check 1 TOTAL_VIOLATIONS=0.
- [ ] **Review the whitelist diff**: reject any entry naming a `.lean` path. A dead path in the
      whitelist is the exact failure mode the checker exists to catch.

**Timing**: 1.0 hours

**Depends on**: 6, 7, 8

**Verification Tier**: full

**Scope Hypothesis**: This phase expects at most five new whitelist entries, three of which the
audit predicts will vanish with Phase 6's deletions. If the residual Check-1 list after Phases 6-8
differs from that prediction, re-derive each remaining violation's disposition (delete / repoint /
whitelist) from evidence before adding any entry.

**Files to modify**:
- `typst/chapters/05-theorems.typ` - two `Bridge.lean` repoints
- `typst/chapters/p3-vlach-blstar.typ` - `rabinovich_translate` deletion or rewrite
- `typst/sync-check-whitelist.txt` - new categorized entries with reasons

**Verification**:
- `bash scripts/typst-sync-check.sh` reports Check 1 TOTAL_VIOLATIONS=0, Check 2 MISMATCH_COUNT=0,
  Check 3 clean
- No whitelist entry names a `.lean` path
- Every new whitelist entry carries a one-line reason under a category header
- `typst compile` succeeds

---

### Phase 10: Bibliography [NOT STARTED]

**Goal**: Every `@`-citation resolves, and the entries actually used are correct.

**Tasks**:
- [ ] Add the five missing entries to `typst/bibliography.bib`, copied verbatim from the paper's own
      `possible_worlds.bib` rather than re-derived: `Prior1967` (Past, Present and Future),
      `Dorr2020` (Diamonds Are Forever), `Bacon2022` (Bacon and Zeng, A Theory of Necessities),
      `Walsh2016` (Predicativity, the Russell-Myhill Paradox, and Church's Intensional Logic),
      `Rumberg2019` (Rumberg and Zanardo, First-Order Definability of Transition Structures). Exact
      BibTeX is in the research report §8.
- [ ] Confirm the four already-cited sources still resolve: `burgess1982axioms`, `reynolds1992`,
      `doets1987`, `kamp1971formalproperties`.
- [ ] `vlach1973nowandthen` already exists in the .bib but appears to be **uncited**. Either cite it
      where the Vlach material warrants (`p3-vlach-blstar.typ` is the natural home) or leave it —
      but confirm the situation rather than assuming.
- [ ] **Hölder's theorem**: the paper names it without a bibliography entry, treating it as a
      standard named result. If the book states the fact (a nontrivial discrete Archimedean totally
      ordered abelian group is isomorphic to Z), match the paper's practice and name it without a
      formal citation. This is a style decision — flag it to the user in the findings note rather
      than silently adding a reference.
- [ ] Do not pad. Add only what the revised text needs.
- [ ] Compile and confirm **no unresolved citations**.

**Timing**: 0.75 hours

**Depends on**: 6, 7, 8, 9

**Verification Tier**: interface

**Scope Hypothesis**: The audit asserts `typst/bibliography.bib` currently has 77 entries and that
exactly five are missing. Confirm the missing set by grepping each key before adding; entries added
in Phases 5-8's prose may have changed what is needed.

**Files to modify**:
- `typst/bibliography.bib` - five new entries
- Chapter files as needed for new `@`-citations

**Verification**:
- `typst compile` emits no unresolved-citation warnings
- Every key cited in `typst/**` resolves in `bibliography.bib`

---

### Phase 11: Rewrite the Introduction [NOT STARTED]

**Goal**: A reader who knows modal logic but not this system should arrive at the frame definition
understanding why the system is built the way it is.

**Tasks**:
- [ ] Answer **why task frames rather than Kripke frames**. The current "What TM Is" section states
      the Until/Since-over-linear-orders-fused-with-S5 characterization and gestures at task frames
      without motivating them.
- [ ] Answer **why the temporal order is an ordered abelian group rather than a bare linear order**.
      Foreshadow the payoff: the discrete-or-dense dichotomy that drives the whole completeness
      architecture depends on exactly this, and **fails** for bare linear orders. This is a genuinely
      illuminating thing to promise early and deliver in Phase 5's material.
- [ ] Explain **what the bimodal interaction axiom MF buys**.
- [ ] Rewrite the **Outline** section to match the book's *actual* current structure. Verify against
      `typst/BimodalReference.typ`'s `#part-divider(...)` calls and `#include` order (Part II runs
      `01-syntax`, `02-semantics`, `03-proof-theory`, `p2-frame-classes`, `04-metalogic`,
      `p2-decidability-practice`, `05-theorems`, `p3-ltl-to-tm`, `p3-vlach-blstar`,
      `p3-decidability-frontier`; then `p4-proof-automation`, `p4-dataset-pipeline`,
      `p4-dual-verification`; then `06-notes`, `ax-machine-appendix`). Several `p3-*` and `p4-*`
      chapters are newer than the current Outline reflects.
- [ ] Update "Project Structure" for the four frame classes and the rebuilt module tree (Phase 8).
- [ ] Preserve and keep the existing light-cone cetz diagram; the introduction's structure
      (`== What TM Is`, `== Why Tense and Modality Together`, `== Outline`, `== How to Read This
      Book`, `== Project Structure`) is a sound skeleton to expand within, not to discard.

**Timing**: 2.0 hours

**Depends on**: 3, 5, 8, 10

**Verification Tier**: local

**Files to modify**:
- `typst/chapters/00-introduction.typ`

**Verification**:
- The Outline's chapter list matches `BimodalReference.typ`'s `#include` order exactly
- The introduction motivates task frames, the ordered-abelian-group choice, and MF
- `typst compile` succeeds

---

### Phase 12: Reader-Stumble Remarks [NOT STARTED]

**Goal**: Add short, clearly-marked remarks at the six points where a reader predictably stumbles.

**Tasks**:
- [ ] **Why the temporal semantics is strict/irreflexive and what that costs**: the temporal
      T-axioms are **not** valid; seriality is supplied axiomatically. (`02-semantics.typ` or
      `03-proof-theory.typ`)
- [ ] **Why Nullity is a lemma and not an axiom** — derived choice-free from Seriality at x = 0 plus
      Limit. (`02-semantics.typ`)
- [ ] **Why Spherical is needed at all**, and what the finite-carrier discharge
      (`cor:spherical-finite`) does and does **not** give. (`02-semantics.typ`)
- [ ] **Why S5-hood alone does not single out metaphysical necessity** — the paper's own
      stability-modality case is the counterexample. (`04-metalogic.typ` or `06-notes.typ`)
- [ ] **Why the perpetuity principles follow from MF and MT by classical reasoning alone**.
      (`05-theorems.typ`)
- [ ] **The Since/Until argument-order divergence is known, documented, and deliberate** — state it
      as such rather than as something to be "fixed". The paper's surface notation phi-Since-psi /
      phi-Until-psi is **guard-first** (phi guard, psi event); the repository's `snce`/`untl`
      constructors are **event-first** (Burgess convention). The truth conditions agree once the
      argument order is swapped. The paper's footnote at `\label{def:BLplus-semantics}` states it in
      exactly this direction. An earlier paper version stated it backwards as Pnueli guard-first —
      **if the book repeats the Pnueli framing it is repeating a corrected error.** Check for and
      remove that framing. (`01-syntax.typ` or `02-semantics.typ`)
- [ ] Use the existing `remark` environment from `typst/template.typ`; do not invent a new one.

**Timing**: 1.5 hours

**Depends on**: 3, 4, 5, 6, 8, 10

**Verification Tier**: interface

**Scope Hypothesis**: Six remarks are specified. Their placement files are best guesses; confirm
each by reading the surrounding chapter before inserting, and place the remark where the reader
actually hits the stumble rather than where this plan guessed.

**Files to modify**:
- `typst/chapters/01-syntax.typ`, `typst/chapters/02-semantics.typ`,
  `typst/chapters/03-proof-theory.typ`, `typst/chapters/04-metalogic.typ`,
  `typst/chapters/05-theorems.typ`, `typst/chapters/06-notes.typ` (placement confirmed at
  implement time)

**Verification**:
- Six remarks present, each using the template's `remark` environment
- `grep -rn "Pnueli" typst/` returns no guard-first framing
- `typst compile` succeeds

---

### Phase 13: Semantics Diagrams [NOT STARTED]

**Goal**: Two cetz diagrams in `02-semantics.typ`, matching the existing light-cone idiom.

**Tasks**:
- [ ] **Fiber / cone / segment apparatus** of `def:task-relation`: a world state `w` with
      `Fib(w, x)` as a horizontal slice at duration `x`, the cone `(w)_x` as the union of slices for
      `|y| < x` (a filled wedge), and the segment `[w, v]_x^y` as the intersection of two slices
      anchored at different points `w`, `v`. This can extend the existing light-cone cetz code
      directly — same coordinate idiom, same `pt(ang, r)` helper.
- [ ] **Partial history -> world history (convex) -> total history layering**: a single duration axis
      with three nested domains as intervals of increasing extent — a broken/non-convex domain
      struck through as *not* a world history, a convex-but-partial interval, and the full axis for
      total.
- [ ] Match the established idiom: single `#cetz.canvas`, geometric, labeled with Typst math strings,
      centered via `#align(center)[...]`.
- [ ] Cut any diagram that merely restates a formula.

**Timing**: 1.5 hours

**Depends on**: 12

**Verification Tier**: local

**Files to modify**:
- `typst/chapters/02-semantics.typ`

**Verification**:
- Both diagrams render in the compiled PDF without overlap or clipping
- Notation in the diagrams matches the corrected prose (`[w, v]_x^y`, not the retired `\Seg` form)
- `typst compile` succeeds

---

### Phase 14: Metalogic and Frame-Class Diagrams [NOT STARTED]

**Goal**: Three cetz diagrams, including the single highest-value diagram in the book.

**Tasks**:
- [ ] **Two-fibre Z/R countermodel for (DD)** — highest priority. Two parallel horizontal strips
      (fibre 1 labeled Z with discrete tick marks; fibre 2 labeled R as a continuous line), with a
      dashed crossing arrow labeled Box depicting the modality reading globally across both fibres,
      `Next-top` true only on the Z fibre and `not-Next-top` true only on the R fibre. This makes
      visible why Box phi_DF or Box psi_DN is TM-valid-but-unprovable. The incompleteness argument is
      much easier to see than to read; this diagram's absence is what most costs the reader.
      (`04-metalogic.typ`)
- [ ] **Three-way discreteness-indicator case split** driving the completeness architecture: the
      `U(⊤,⊥)` witness as a decision node branching to the canonical-model constructions.
      `04-metalogic.typ:100` already describes this in prose ("Dense case (`¬U(⊤,⊥)` in M)").
- [ ] **Frame-class lattice** Base / Dense / Discrete / Dedekind. **This is not a diamond.**
      `Dedekind` sits strictly above `Dense`; `Discrete` is incomparable to both.
      `FormalSystem/ProofSystem/Axioms.lean` already renders the correct shape as ASCII art in a doc
      comment — mirror it faithfully. Annotate which axioms enter where (`density`/`dense_indicator`
      -> Dense; `prior_UZ`/`prior_SZ`/`z1` -> Discrete; `prior_U_gap`/`prior_S_gap`/`sep` ->
      Dedekind). (`p2-frame-classes.typ`)

**Timing**: 2.0 hours

**Depends on**: 12

**Verification Tier**: local

**Files to modify**:
- `typst/chapters/04-metalogic.typ` - two-fibre countermodel, case-split diagram
- `typst/chapters/p2-frame-classes.typ` - frame-class lattice

**Verification**:
- The lattice diagram shows Dedekind strictly above Dense, not a four-leaf diamond
- The two-fibre diagram labels both fibres and shows Box reading across them
- All three render without overlap or clipping
- `typst compile` succeeds

---

### Phase 15: Marker Sweep and Occurrence List [NOT STARTED]

**Goal**: Make the follow-up re-sync a grep, not a re-audit.

**Tasks**:
- [ ] Sweep `typst/chapters/` and `typst/BimodalReference.typ` for every claim whose Lean anchor sits
      in territory the three in-flight tasks will move:
  - **canonical-completeness** scope — `Metalogic/BXCanonical/` anchors (canonical-frame and
    completeness)
  - **semantic-fmp** scope — `Metalogic/Decidability/FMP/` anchors
  - **co-reynolds-independence** scope — `ProofSystem/Axioms.lean` Layer 9, immediately above the
    `Axiom.prior_U_gap` constructor. Note that Layer 9's comments already carry a "NOT
    machine-checked" flag today, which that work will either confirm or overturn — **mark that flag
    itself.**
- [ ] Place the marker as a plain Typst line comment immediately above each citing line:
      `// LEAN-ANCHOR-MAY-MOVE: <scope> — see typst/README.md`. It is invisible in the compiled PDF,
      consistent with the existing `// Lean name ground truth: ...` header comments already at the
      top of chapter files.
- [ ] **The prose itself stays plain and confident.** The task description requires the prose to
      survive the anchor moving; the marker is maintainer metadata, not a hedge visible to the
      reader. Paper-anchored content is **not** subject to this hedging — the paper is stable ground
      truth and its claims are written plainly, unmarked.
- [ ] Fill in `typst/README.md`'s Marker Convention occurrence list from
      `grep -rn "LEAN-ANCHOR-MAY-MOVE" typst/`, with a per-scope count.

**Timing**: 0.75 hours

**Depends on**: 11, 13, 14

**Verification Tier**: interface

**Scope Hypothesis**: Candidate sites the audit names are `06-notes.typ:75,83`,
`04-metalogic.typ`'s rebuilt `BXCanonical/` and `Decidability/FMP/` table rows, and the new
corrected-completeness prose. **This list is explicitly not exhaustive** — do the full sweep and let
the grep define the occurrence list.

**Files to modify**:
- `typst/chapters/*.typ` and `typst/BimodalReference.typ` - marker comments
- `typst/README.md` - occurrence list filled in

**Verification**:
- `grep -rn "LEAN-ANCHOR-MAY-MOVE" typst/` output matches the README occurrence list exactly
- Every marker uses one of the three documented scope suffixes
- The compiled PDF is unchanged by the markers (comments only)

---

### Phase 16: Acceptance Gates, SYNC-MAP Verdict, and Findings Note [NOT STARTED]

**Goal**: Satisfy the task description's five-item acceptance list and record what was found but not
fixed.

**Tasks**:
- [ ] Run `bash scripts/typst-sync-check.sh`: Check 1 TOTAL_VIOLATIONS=0, Check 2 MISMATCH_COUNT=0,
      Check 3 clean.
- [ ] Run `cd typst && typst compile BimodalReference.typ build/BimodalReference.pdf`: no unresolved
      references or citations.
- [ ] Run `bash scripts/check-paper-definitions.sh`: exits case (a) or (b).
- [ ] Re-read the whitelist diff end to end and confirm **no dead path** was whitelisted and every
      new entry carries a one-line reason under a category header.
- [ ] Add a **new dated verdict section** to `typst/SYNC-MAP.md`. **Do not rewrite its historical
      tables** — the file's own header states they are a retained historical record of a superseded
      structure.
- [ ] Write the findings note in
      `specs/442_revise_bimodal_reference_book_against_paper_and_lean/reports/` recording:
  - Every Lean/paper divergence found and **not** fixed here (no Lean changes were permitted)
  - The chosen marker string and every site carrying it (cross-reference the README occurrence list)
  - **The conservativity-bridge finding**: the separate Lean task to formalize the TM^+/TM
    conservativity bridge targets `thm:ConservativeExtension`, which **no longer exists in the
    paper** — it appears only inside `%% OLD:` comment blocks and a standalone `%% CHANGE` note
    stating the prose claim "is false in the same way the labeled theorem was". `def:TMplus`'s
    replacement footnote makes no conservativity claim. That task's premise is stale. **Record and
    raise with the user; do not modify that task from here.**
  - That `cor:tm-completeness`, `cor:tm-decidability`, and `def:TMplus` are **not** among the 26
    anchors tracked by `check-paper-definitions.sh`, so that gate does not protect the corrected
    completeness/decidability text against future paper drift
  - The Hölder-citation style decision from Phase 10
- [ ] Note in the findings that the research report
      (`reports/01_book-paper-lean-sync-audit.md`) already covers much of acceptance item 5; the new
      note should reference it rather than duplicate it, and add only what implementation
      discovered.

**Timing**: 1.0 hours

**Depends on**: 15

**Verification Tier**: full

**Files to modify**:
- `typst/SYNC-MAP.md` - new dated verdict section appended (historical tables untouched)
- `specs/442_revise_bimodal_reference_book_against_paper_and_lean/reports/02_revision-findings.md`

**Verification**:
- All three gate scripts pass as specified above
- `git diff typst/SYNC-MAP.md` shows only an added section, no modified historical rows
- The findings note exists and covers all six recorded items

---

## Testing & Validation

- [ ] `bash scripts/typst-sync-check.sh` — Check 1 TOTAL_VIOLATIONS=0, Check 2 MISMATCH_COUNT=0,
      Check 3 clean
- [ ] `cd typst && typst compile BimodalReference.typ build/BimodalReference.pdf` — succeeds with no
      unresolved references and no unresolved citations
- [ ] `bash scripts/check-paper-definitions.sh` — exits case (a) or (b)
- [ ] `grep -rn "ConservativeExtension" typst/` — no hits
- [ ] `grep -rn "three frame class" typst/` — no hits
- [ ] `grep -rn "open problem" typst/` — hits only where genuinely accurate (the FMP bridge,
      dense/complete conservativity, CO-vs-triple, decidability)
- [ ] `grep -rn` for task-number patterns over `typst/**` — no hits
- [ ] No whitelist entry in `typst/sync-check-whitelist.txt` names a `.lean` path
- [ ] `grep -rn "LEAN-ANCHOR-MAY-MOVE" typst/` output matches the `typst/README.md` occurrence list
- [ ] The three `// SLOT-IN:` anchors in `p3-decidability-frontier.typ` are unchanged
- [ ] `git status` shows no modifications under `/home/benjamin/Philosophy/Papers/`,
      `FormalSystem/`, or `latex/`
- [ ] Visual check of the compiled PDF: five new diagrams render without overlap or clipping

## Artifacts & Outputs

- `specs/442_revise_bimodal_reference_book_against_paper_and_lean/plans/01_book-paper-lean-revision.md` (this plan)
- `specs/442_revise_bimodal_reference_book_against_paper_and_lean/reports/02_revision-findings.md` (Phase 16)
- `specs/442_revise_bimodal_reference_book_against_paper_and_lean/summaries/01_book-paper-lean-revision-summary.md`
- Revised `typst/BimodalReference.typ` and thirteen chapter files under `typst/chapters/`
- Regenerated `typst/generated/status.typ`
- Extended `typst/sync-check-whitelist.txt` and `typst/bibliography.bib`
- Updated `typst/README.md` (de-numbered, marker convention documented with occurrence list)
- Appended dated verdict section in `typst/SYNC-MAP.md`
- `typst/build/BimodalReference.pdf` (build output, gate evidence)

## Rollback/Contingency

All work is confined to `typst/**` and `specs/442_.../`; no Lean, paper, or `latex/` files are
touched, so rollback cannot break the build or the formalization.

- **Per-phase**: each phase is a `per-substep` commit boundary. Reverting a single phase is
  `git revert` of its commits, since phase territories are disjoint within each wave.
- **Whole-task**: `git revert` the task's commit range. The only generated file,
  `typst/generated/status.typ`, is reproducible at any time with
  `bash scripts/typst-status-counts.sh` — never restore it by hand.
- **If a phase's gate cannot be met**: mark the phase `[PARTIAL]` or
  `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record and carry the item into the
  findings note. Do **not** reach for a whitelist entry to force Check 1 to zero — a silenced dead
  path is worse than a recorded, open violation.
- **If `check-paper-definitions.sh` returns case (c)** at any point: STOP the phase in progress and
  re-issue. The paper has drifted on a tracked anchor and every quote in flight is suspect.
