# Implementation Plan: Task #443

- **Task**: 443 - formal_foundations_report_completeness_and_representation
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: 442 (completed)
- **Research Inputs**: `specs/443_formal_foundations_report_completeness_and_representation/reports/01_formal-foundations-research.md`
- **Artifacts**: plans/01_formal-foundations-report.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Author a new standalone ~10-page Typst research report at `typst/FormalFoundations.typ`
(compiled to `typst/build/FormalFoundations.pdf`) presenting the formal foundations of bimodal
logic TM: a compressed system overview, three pain points (temporal-axiom contingency, TM's
semantic incompleteness via split validity, and the axiomatization of the strongest objective
modality), the completeness construction as actually implemented in `FormalSystem/Metalogic/`,
and a reasoned outline of the way forward to a general representation theorem. The report imports
`typst/notation/bimodal-notation.typ` and `typst/template.typ`, cites `typst/bibliography.bib`,
is NOT `#include`d by `BimodalReference.typ`, and adds its own build entry to `typst/README.md`.
Definition of done: the document compiles clean with no unresolved references, `typst-sync-check.sh`
still passes with the new file present, `check-paper-definitions.sh` exits case (a) or (b) at the
final citation pass, every Lean status claim is freshly measured and dated, and every open question
is marked open and every target marked target.

### Research Integration

The research report (`reports/01_formal-foundations-research.md`) is integrated throughout and
supplies: (i) a complete citation package for every anchor the task description's section 7 lists,
with tracked/untracked classification against `specs/paper-definitions-of-record.md`; (ii) the
measured Lean architecture of the completeness construction (three-way discreteness-indicator
split, `mcs_mixed_case_absurd`, dense/discrete/Dedekind paths, D-parametric algebraic truth lemma);
(iii) measured sorry/axiom counts at 2026-08-13 commit `f231a8775`; (iv) three diagram content
sketches; (v) a per-section punch list (its section 10) which this plan's content phases follow
directly.

Three research findings materially change what the report must say relative to the task
description's own narration, and are encoded as binding constraints in the phases below:

1. **Status correction, section 3.7** (the most consequential): of the three "early representation
   work" items, only the algebraic layer (`Metalogic/Algebraic/`) is live. The shift-set
   representation programme is **not started** (no `ShiftSet`/`shiftSet` identifier exists anywhere
   under `FormalSystem/`; what exists is a design document), and the Jönsson–Tarski programme is
   **archived to `Boneyard/`** with revival tracked only as an unstarted future item. Both must be
   written as **targets, not existing work**. The task description's own 3.7 framing ("what
   actually exists here as early representation work") is known-wrong for these two items and must
   be corrected, not transcribed.
2. **Two paper sentences are commented out** in the live source: the "S5-hood cannot single out
   Box" generalization (at `sub:Extension`) and the "broadened operator is displaced from
   `Str^O_L(Box)`" sentence (immediately after the irregular-worlds footnote). Neither may be
   quoted as live paper prose. The report states both conclusions in its own voice, grounded in the
   live `Stability` footnote plus `def:strongest`/`thm:exist`.
3. **`UltrafilterMCS.lean`'s docstring is stale** ("Contains sorries pending MCS helper lemmas");
   the file has zero `sorry` occurrences and `sorry_algebraic = 0`. Report the measured fact; do
   not repeat the stale prose and do not edit the Lean file (non-goal).

### Prior Plan Reference

No prior plan for this task. The predecessor task 442's plan and its completed execution are
relevant only as calibration: a 16-phase book revision at comparable citation discipline, whose
recurring difficulty was paper/Lean drift *during* execution (gate scripts had to be re-run
repeatedly rather than measured once). That lesson is encoded here as Phase 10's mandatory
re-measurement immediately before the final citation pass, and as risk R1 below.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and `roadmap_flag` is not set, so no
roadmap phases are added and `specs/ROADMAP.md` is not modified by this task. Read-only
consultation confirms the roadmap's "Completeness programme: strong vs weak terminology and
per-class targets" section and its Base/Dense strong-completeness **GATING RULE** independently
corroborate the research report's section 8 material (shift-set representation is the gate; the
downstream ultraproduct steps are deliberately not authorized) and its per-class table
(Dedekind strong completeness IMPOSSIBLE — non-compact; Base/Dense open). The report's section 3.7
way-forward outline should agree with that table. Note that `ROADMAP.md` states these facts using
task numbers; the report must restate them using durable anchors only (see risk R6).

## Goals & Non-Goals

**Goals**:
- A standalone, compiling `typst/FormalFoundations.typ` of ~10 pages of body text at the book's
  existing type settings, importing `bimodal-notation.typ` and `template.typ`.
- Faithful, compressed coverage of all seven content areas (task description sections 3.1–3.7),
  with no pain point dropped.
- The two proofs the task designates "in full, briefly": the discrete-or-dense dichotomy and the
  (DD) two-fibre countermodel.
- Three diagrams in the book's cetz idiom: two-fibre ℤ/ℝ countermodel, three-way
  discreteness-indicator case split, representation-theorem landscape with live/target/archived
  status labels.
- Every Lean status claim MEASURED at authoring time and dated in text or footnote.
- Every "open" marked open, every "target" marked target, with the shift-set and Jönsson–Tarski
  programmes written as targets.
- `typst/README.md` documents the new build target as its own entry.
- All four gate scripts green at completion.

**Non-Goals**:
- No Lean implementation or Lean file edits of any kind, including the stale
  `UltrafilterMCS.lean` docstring — formalization gaps are recorded, not closed.
- No edits under `/home/benjamin/Philosophy/Papers/` — the paper is read-only ground truth and
  `metalogic.tex` is read-only AND superseded.
- No changes to `BimodalReference.typ`, `typst/chapters/`, or `latex/`. A book defect found here
  is recorded in this task's `reports/`, not fixed across the boundary.
- No decidability theorem proposed or asserted; decidability is stated faithfully as open.
- No restatement of `metalogic.tex`'s completeness claims in any form.
- No task-number citations anywhere under `typst/**`.
- This task does not adjudicate predecessor finding 1b (BX-level completeness theorems vs.
  `cor:tm-completeness`'s TM_d/TM_f status); it states the cross-reference as open.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1: Paper drifts mid-task; `check-paper-definitions.sh` returns case (c) FAIL on a quoted anchor | H | M | STOP on case (c) rather than quoting a drifted anchor; re-resolve the anchor via `--resolve`, re-quote, re-hash, and only then continue. Never reuse Phase 2's checksum as a substitute for the Phase 10 re-run. |
| R2: Lean tree drifts; sorry counts or axiom profiles in the drafted text go stale before completion | H | M | All numeric status claims are written as placeholders during content phases and stamped only at Phase 10 from a fresh `typst-status-counts.sh --json` run, with the measurement date in the text. |
| R3: `typst-sync-check.sh` Check 1 fails on backticked spans in the new file | M | H | Every backticked span must be a real identifier under `FormalSystem/` (excl. `Boneyard/`) or whitelisted with a one-line reason. Shift-set names (`ShiftSet`, `sh`, `Omega`-as-shift-carrier) do NOT exist in Lean and must be rendered as ordinary math/prose, never backticked. Run the check per content phase, not only at the end. |
| R4: Length overrun past ~10 pages of body text | M | H | Per-phase page budgets stated as Scope Hypotheses; Phase 10 carries an explicit compression pass with named cut candidates (correspondence-theorem proofs to statement + one-line idea; `thm:sym`'s ~15-line chain to result-and-cite). |
| R5: Status overstatement — a target or archived item narrated as live work | H | M | Phase 9 writes shift-set and Jönsson–Tarski as targets by construction; Phase 10 runs a dedicated status-marking audit over every status-bearing sentence. One overstatement destroys the report's value (acceptance criterion 5). |
| R6: Task-number leakage into `typst/**` | M | M | Sources that would tempt it (`ROADMAP.md`, the design document, `Boneyard/` READMEs) all carry task numbers. Phase 10 greps the new file for task-number patterns; describe items by durable anchor (module path, design-document name, "an unstarted future item") instead. |
| R7: Accidentally lifting `metalogic.tex` material | H | L | The file is read once for defect-naming only (Phase 9); its four named defects are the only thing that may appear, and only if it is cited at all. No definition, theorem statement, or proof step is lifted. |
| R8: cetz diagram authoring consumes disproportionate time | M | M | Diagrams are authored inline in their own section's phase with the book's `04-metalogic.typ` canvases as the structural model (two of the three targets already exist there in book form and can be visually rhymed, not copied by reference since this document is standalone). Timebox each to 30 minutes; a diagram that only restates a formula is cut. |
| R9: Silently identifying BX-system Lean theorems with the paper's TM-family systems | H | M | Section 3.6 states the Lean architecture in `Metalogic/`'s own BX vocabulary throughout (`FrameClass.Dense`/`Discrete`/`Base`), never renaming `completeness_dense` as "TM_d's completeness"; the cross-reference is stated as open. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |
| 9 | 10 | 9 |

Phases within the same wave can execute in parallel. Phases 3–10 are serialized because they all
write the single file `typst/FormalFoundations.typ`; Phase 2 is parallel to Phase 1 only because it
touches disjoint files (`specs/paper-definitions-of-record.md` and a measurement note).

---

### Phase 1: Scaffold the standalone document and its build target [COMPLETED]

**Goal**: A compiling skeleton of `typst/FormalFoundations.typ` with correct imports, document
configuration matching the book's type settings, section headings for all seven content areas, and
a documented build command — so every later phase has a green baseline to add to.

**Tasks**:
- [ ] Create `typst/FormalFoundations.typ` with the copyright header convention used by
      `typst/BimodalReference.typ`, `#import "@preview/cetz:0.3.4"`,
      `#import "notation/bimodal-notation.typ": *`, and the needed `template.typ` exports
      (`thmbox-show`, `URLblue`, `definition`, `theorem`, `lemma`, `axiom`, `remark`, `proof`,
      `corollary`, `proposition`).
- [ ] Match the book's type settings verbatim (`New Computer Modern` 11pt, heading numbering
      `"1.1"`, the same `#set par(...)` block) so "~10 pages at the book's existing type settings"
      is measured on the same scale.
- [ ] Set `#set document(title: ..., author: "Benjamin Brast-McKie")`; add a title block and a
      one-paragraph abstract stating the document's purpose ("what exactly is proved here, what is
      not, and what would it take to close the gap").
- [ ] Add `#bibliography("bibliography.bib")` at the end, styled as the book does; confirm the
      nine keys the research report names all resolve (`burgess1982axioms`, `reynolds1992`,
      `doets1987`, `kamp1971formalproperties`, `prior1967pastpresentfuture`, `dorr2020diamonds`,
      `rumberg2019firstorder`, `bacon2022necessities`, `walsh2016predicativity`) — no new
      bibliography entries are needed.
- [ ] Add placeholder `=` headings for the seven content areas in report order.
- [ ] Add a new, separate build-target entry to `typst/README.md` — NOT folded into the existing
      book-build section — documenting
      `cd typst && typst compile FormalFoundations.typ build/FormalFoundations.pdf` and stating
      explicitly that this document is standalone and not part of the book.
- [ ] Verify `BimodalReference.typ` contains no `#include` of the new file and that none is added.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - new file, scaffold
- `typst/README.md` - new standalone build-target entry

**Verification**:
- `cd typst && typst compile FormalFoundations.typ build/FormalFoundations.pdf` exits 0 with no
  unresolved-reference or unresolved-citation warnings.
- `bash scripts/typst-sync-check.sh` still passes with the new file present.
- `grep -c 'FormalFoundations' typst/BimodalReference.typ` returns 0.

---

### Phase 2: Extend the definitions-of-record file and take the gate baseline [COMPLETED]

**Goal**: Every paper anchor whose definition text the report will quote verbatim is tracked in
`specs/paper-definitions-of-record.md`, and the measured Lean status baseline is recorded, dated,
and reproducible.

**Tasks**:
- [ ] Run `bash scripts/check-paper-definitions.sh` and record the case letter. STOP and resolve
      before proceeding on case (c).
- [ ] Enumerate the anchors the report will quote verbatim but that are untracked, per the research
      report's section 3: `def:S5`, `def:BX`, `def:TMplus`, `def:TMplus-f`, `def:TMplus-d`,
      `def:TMplus-c`, `thm:M5-valid`, `thm:TM-soundness`, `app:discrete`, `app:dense`,
      `app:complete`, `def:frame-properties`, `cor:spherical-finite`, `cor:tm-completeness`,
      `cor:tm-decidability`, `def:id`, `def:strongest`, `thm:exist`, `lem:uniq`, `thm:s4`,
      `thm:sym`. Confirm each against the manifest before adding — some may have been tracked since
      the research pass.
- [ ] For each genuinely untracked anchor, follow the record file's own four-step extension
      protocol: resolve via `scripts/check-paper-definitions.sh --resolve "ANCHOR|KIND|ENCLOSING|LOCATOR"`,
      add a `### \`ANCHOR\`` prose entry quoting the text verbatim, add the manifest row with the
      printed sha256, and re-run the script bare to confirm a case-(a) pass.
- [ ] Re-pin the provenance table (checksum, line count, UTC timestamp, base commit) per the file's
      existing convention if the extension run moves the pin.
- [ ] Run `bash scripts/typst-status-counts.sh --json` and record the full output, including
      `stamp_commit` and `stamp_date`.
- [ ] Record `#print axioms` profiles for the flagship results the report will cite by status
      (`completeness`, `completeness_dense`, `completeness_discrete`, `countermodel_dense`,
      `completeness_dedekind_engine`), using the measurement method the repository already uses
      rather than a naive grep.
- [ ] Write `specs/443_formal_foundations_report_completeness_and_representation/reports/02_measured-status.md`
      capturing the above with the measurement date and commit, as the traceable source for the
      report's dated status footnotes. Note explicitly that this note is a baseline, and that
      Phase 10 re-measures rather than carrying it forward.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The research pass identified 21 untracked anchors requiring record-file
extension (listed above). Confirm at implementation time by checking each anchor ID against the
`MANIFEST:BEGIN` block in `specs/paper-definitions-of-record.md`; the real count may be lower if
predecessor work tracked some since 2026-08-13, and any anchor the report ends up citing by key
only (without quoting its text) does not require tracking.

**Files to modify**:
- `specs/paper-definitions-of-record.md` - new anchor entries + manifest rows + provenance re-pin
- `specs/443_formal_foundations_report_completeness_and_representation/reports/02_measured-status.md` - new measurement note

**Verification**:
- `bash scripts/check-paper-definitions.sh` exits reporting case (a) after the extension.
- Every anchor listed in the task description's section 7 is either present in the manifest or
  documented in the measurement note as cite-by-key-only.
- `bash scripts/typst-sync-check.sh` still passes (the record file is outside its scan, but confirm
  no incidental breakage).

---

### Phase 3: Section 1 — the system, compressed [COMPLETED]

**Goal**: A ~2-page formally precise compression of the languages, task-frame semantics, and proof
systems, using the notation module so nothing drifts from the book.

**Tasks**:
- [ ] Languages: BL = ⟨SL, ⊥, →, □, Past, Future⟩ and BL⁺ = ⟨SL, ⊥, →, □, Since, Until⟩
      (`def:BLplus-language`), the defined operators (`def:BLplus-defined`), the Past/Future
      reduction (`thm:BLplus-PastFuture`), and Next/Previous over discrete frames
      (`thm:BLplus-NextPrevious`).
- [ ] Task-frame semantics: `def:temporal-order`, `def:task-relation` with the converse convention
      and the fiber/cone/segment apparatus, `def:directed`, and the FOUR axioms of `def:frame`
      (Compositionality biconditional, Seriality, Limit, Spherical) — stating explicitly that
      Nullity is a LEMMA (`lem:nullity`), not an axiom.
- [ ] The partial/world/total history layering (`def:world-history`), `def:BL-semantics`, and
      `def:logical-consequence`.
- [ ] Proof systems: S5 (`def:S5`), base Burgess–Xu tense logic BX (`def:BX`),
      TM⁺ = S5 + BX + (TMP-MF) (`def:TMplus`), and the three extensions BX_f/TM⁺_f
      (`def:TMplus-f`), BX_d/TM⁺_d (`def:TMplus-d`), BX_c/TM⁺_c (`def:TMplus-c`).
- [ ] State the BL-level TM axiomatization too, since the pain points are about it.
- [ ] Use the notation module's exports throughout (`#allpast`/`#allfuture`/`#somepast`/
      `#somefuture`, `#always`/`#sometimes`, `#taskframe`/`#Dur`/`#worldstate`/`#taskrel`/
      `#taskto(x)`, `#history`/`#domain`/`#histories`, `#satisfies`, `#truthat`, `#derivable`,
      `#valid`, `#framevalid`); invent no new `#let` bindings that duplicate existing ones.
- [ ] Quote tracked definition text from `specs/paper-definitions-of-record.md` directly rather
      than re-reading the paper; cite by `\label`/`\aitem` key only, never by line number.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This section is budgeted at ~2 of the report's ~10 body pages. Confirm at
implementation time by compiling and reading the page count of the section; if over budget, cut
the fiber/cone/segment apparatus to a one-sentence statement before cutting any `def:frame` axiom.

**Files to modify**:
- `typst/FormalFoundations.typ` - section 1 body

**Verification**:
- Compile succeeds, no unresolved references.
- `bash scripts/typst-sync-check.sh` passes (every backticked span resolves or is whitelisted).
- Every quoted definition's text matches the record file verbatim; every citation is by key.

---

### Phase 4: Section 2 — key theorems, completeness status, decidability as open [COMPLETED]

**Goal**: A ~2-page statement-and-anchor treatment of the load-bearing theorems, the exact
completeness status from `cor:tm-completeness` unsoftened, and a faithful open-status account of
decidability.

**Tasks**:
- [ ] Existence and occurrence: `lem:step`, `thm:extension` (Zorn), `cor:occurrence`,
      `cor:spherical-finite` — including the Lean-vs-ZF mismatch note: "choice-free" in the paper's
      sense means no AC given classical logic, whereas Lean's `Classical.choice` is the single axiom
      yielding both excluded middle and choice, so `#print axioms` cannot express the paper's
      distinction; this repository has machine-checked that Spherical on a finite carrier implies
      weak excluded middle, so no `Classical.choice`-free Lean proof can exist.
- [ ] Soundness: `thm:TM-soundness` for TM and its extensions, `thm:M5-valid`.
- [ ] Correspondence: `app:discrete` (DF), `app:dense` (DN), `app:complete` (CO) — compressed to
      statement plus one-line proof idea each; these are explicitly NOT the "give in full"
      exceptions.
- [ ] Perpetuity principles P1–P6 and derived TF, with the MF/MT classical derivation chain.
- [ ] The modal-temporal collapses, citing the correct anchors verified by research:
      `Pthm:13` (▽□φ ↔ □φ), `Pthm:14` (△□φ ↔ □φ), `Pthm:18` (□△φ ↔ □φ), `Pthm:20` (◇φ ↔ ◇▽φ);
      one or two sentences on what they suggest about the language's real expressive complexity.
- [ ] Order-theoretic facts that do real work: by Hölder, a nontrivial discrete Archimedean totally
      ordered abelian group is isomorphic to ℤ, and a nontrivial Dedekind-complete one is
      Archimedean hence isomorphic to ℤ or ℝ — so the complete class is exactly {ℤ, ℝ} up to
      isomorphism, and the dense-and-complete class is exactly ℝ. Match the paper's own practice on
      whether Hölder gets a bibliography entry (it currently does not).
- [ ] COMPLETENESS, stated exactly and unsoftened: TM, TM_f, TM_d, TM_c, TM_dc are sound over their
      classes but NONE is complete; completeness is carried by the BL⁺ systems — TM⁺_d weakly
      complete over the full Dense class (machine-checked, sorry-free); TM⁺_f weakly complete over
      ℤ-time (machine-checked over the successor-Archimedean class); TM⁺_c weakly complete over the
      dense-and-complete class, exactly ℝ (machine-checked); TM⁺ weak completeness over all task
      frames is the stated formalization TARGET with one obligation outstanding, NOT an established
      theorem. Strong completeness is the aim for TM⁺ and TM⁺_d with no known obstruction; it
      PROVABLY FAILS for ℤ-time and for ℝ, where compactness fails. Assert nothing about
      compactness of the full discrete class in either direction.
- [ ] Record the deletion of the conservative-extension theorem and the four-part replacement
      status at `def:TMplus`'s footnote (backward unconditional; forward fails for base via (DD)
      and for discrete via (TMP-Z1) over ℤ ×_lex ℤ; open for dense and complete).
- [ ] DECIDABILITY, faithfully as open per `cor:tm-decidability`: state the open status; give the
      anatomy (recursive axiomatization ⇒ theorems r.e. regardless of completeness; decidability
      additionally needs non-theorems r.e., standardly via an FMP); record that the former blanket
      FMP-over-D=ℤ premise is RETRACTED AS FALSE, with both witnesses (DF a non-theorem of TM, TM_d,
      TM_c, TM_dc yet valid in every model over D = ℤ; CO a non-theorem of TM_f, witnessed by
      ℤ ×_lex ℤ, yet likewise valid over D = ℤ), and that a repaired FMP must be CLASS-SPECIFIC and
      range over effective non-Archimedean carriers such as ℤ ×_lex ℤ. State what exists (a verified
      sound tableau procedure; ongoing formalization of the semantic, truth-connected FMP for the
      ℤ-time discrete case) and what would suffice (the two intersection reductions), marking the
      intersection reduction as a target STRATEGY, not a result. Propose no decidability theorem.
- [ ] Leave all sorry-count and axiom-profile numerals as clearly-marked placeholders for Phase 10.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Scope Hypothesis**: Budgeted at ~2 of ~10 body pages, and asserts the completeness-status list
covers exactly the five TM-family systems and four BL⁺ results named in `cor:tm-completeness`.
Confirm at implementation time against the record-file entry for `cor:tm-completeness` (Phase 2),
not against memory; if over page budget, compress the perpetuity derivation chain to its statement
before touching the completeness or decidability paragraphs, which are non-negotiable in detail.

**Files to modify**:
- `typst/FormalFoundations.typ` - section 2 body

**Verification**:
- Compile succeeds; `typst-sync-check.sh` passes.
- The completeness paragraph contains no softening qualifier on "none is complete" and marks TM⁺
  weak completeness as a target with an outstanding obligation.
- The decidability paragraph asserts no theorem and contains the word "open" on the headline claim.
- Every numeral that will be measured carries a visible placeholder marker for Phase 10.

---

### Phase 5: Section 3 — pain point one, the contingency of the temporal axioms [COMPLETED]

**Goal**: The report's most carefully written prose: the contingency worry at full strength, the
paper's irregular-worlds response with its exact price, the paper's defense presented fairly and
evaluated, and the residual question stated rather than resolved.

**Tasks**:
- [ ] The three frame conditions (Discrete, Dense, Complete) and their characterizing axioms (DF,
      DN, CO), with the systems TM_f, TM_d, TM_c, TM_dc.
- [ ] No temporal order is both discrete and dense, so TM cannot consistently contain both DF and
      DN.
- [ ] The bite: since every possible world is defined over the frame's own temporal order D, the
      structure D has — discrete or dense, Dedekind complete or not — holds OF METAPHYSICAL
      NECESSITY for that system; if D is dense then DN and its necessitation □(FFφ → Fφ) are both
      valid over that frame.
- [ ] The worry at its strongest, citing Dorr and Goodman (2020, p. 656) via `dorr2020diamonds` —
      presented as a real cost, not a strawman.
- [ ] The irregular-worlds response, quoting the paper's footnote verbatim (available in the
      research report's section 3.6): coset domains, τ : X → W with X = G + c a translate of a
      nontrivial subgroup, τ(x) ⇒_{y−x} τ(y) throughout, consequence defined over irregular and
      possible worlds alike; cosets rather than subgroups because a family of translates is closed
      under ambient translation and so preserves MF and the perpetuity principles.
- [ ] THE PRICE, stated exactly: every nontrivial ordered abelian group contains a discrete cyclic
      subgroup, so DN is valid over NO frame whatever; DF fails over discrete orders possessing a
      dense subgroup, such as ℚ ×_lex ℤ; `app:discrete`, `app:dense`, `app:complete` LAPSE
      TOGETHER; and the broadened operator, while still factive, normal, and closed under
      necessitation relative to the broadened consequence relation, is DISPLACED from its standing
      as the strongest objective modality. **Write the displacement claim in the report's own
      voice** — the paper's sentence asserting it is commented out in the live source and must not
      be quoted as paper prose; ground it in `def:strongest`/`thm:exist` plus the observation that
      broadening consequence changes which operator is ⪯-least.
- [ ] The paper's defense, presented fairly then evaluated: necessity-if-true of density is an
      instance of the general fact that frame validity is closed under necessitation, with the
      Kripke B/symmetry precedent; structural disputes about metaphysical accessibility (S4 vs S5,
      closure under converses) are already conducted as questions about which frame class and logic
      are correct, never as claims that transitivity or symmetry is metaphysically contingent;
      since possible worlds are only ever defined over a single frame, no modality quantifies
      across frames. This paragraph is live paper text and may be quoted directly.
- [ ] What irregular worlds do and do not deliver: contingency in the structure and cardinality of
      the time series, but NOT composition contingency of the catastrophe or proper-initial-segment
      kind, since a difference-closed domain is a subgroup (or a translate of one) and so unbounded
      in both directions either way.
- [ ] Close with the residual question, stated not resolved: is there a semantics recovering
      temporal-structure contingency without lapsing the correspondence results? Name the paper's
      target of a semantic class CLOSED UNDER DISJOINT UNION, under which the Halldén phenomenon
      dissolves structurally, and forward-reference section 5.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Budgeted at ~1.5 of ~10 body pages. Confirm by compiling and reading the
section's page extent; this is the section the user singled out, so if compression is needed
overall, take it from elsewhere.

**Files to modify**:
- `typst/FormalFoundations.typ` - section 3 body

**Verification**:
- Compile succeeds; `typst-sync-check.sh` passes.
- The price paragraph names all four consequences (DN valid over no frame; DF fails over ℚ ×_lex ℤ;
  all three correspondence results lapse; Box displaced).
- No sentence attributes the displacement claim to the paper as a quotation.

---

### Phase 6: Section 4 — pain point two, split validity and TM's semantic incompleteness [COMPLETED]

**Goal**: The sharpest formal result among the pain points, with both designated proofs given in
full and briefly, the taxonomy kept unblurred, and diagram 1.

**Tasks**:
- [ ] The dichotomy with its two-line proof in full: no least positive element ⇒ for x < y some
      positive e < y − x exists, giving x < x + e < y by translation invariance; a least positive e
      forbids anything strictly between x and x + e. State explicitly that the dichotomy depends
      essentially on the GROUP structure — it fails for bare linear orders such as a copy of ℤ
      followed by a copy of the rationals — and is exhaustive precisely because translation
      invariance globalizes any local witness.
- [ ] Hence Log(all task frames) = Log(Discrete) ∩ Log(Dense), and the class of all task frames is
      NOT closed under disjoint union.
- [ ] Hence (DD): the schema □φ_DF ∨ □ψ_DN for arbitrary instances of DF and DN (no
      variable-disjointness restriction; TD supplies the past mirrors), valid over every task frame
      yet TM-unprovable, refuted on the two-fibre structure — one fibre over ℤ, one over ℝ, Box read
      globally over both — which is TM-sound because no TM axiom or rule constrains how Box
      interacts across fibres. Give this proof in full, briefly.
- [ ] **Diagram 1** (cetz, book idiom): two parallel strips, one labeled ℤ with discrete tick
      marks, one labeled ℝ continuous; a global Box spanning both; Next⊤ true only on the ℤ fibre
      and ¬Next⊤ only on the ℝ fibre — visualizing why □φ_DF ∨ □ψ_DN is valid-everywhere but
      unprovable. Author fresh cetz code (the document is standalone and cannot reference the
      book's canvas) that visually rhymes with `typst/chapters/04-metalogic.typ`'s existing
      two-fibre canvas.
- [ ] The taxonomy, unblurred: TM is SEMANTICALLY incomplete (a formula valid but unprovable), NOT
      Halldén-incomplete; TM + (DD) would CREATE Halldén-incompleteness (a provable
      variable-disjoint disjunction with neither disjunct provable, since each fails soundness on
      the complementary subclass); Halldén-incompleteness of Log(all task frames) ITSELF is a
      THEOREM — the correct formal signature of a class that is a union of two incompatible kinds —
      and not a defect.
- [ ] In BL⁺, (DD) is already a theorem with no added axiom ((TMP-NB) and (M5) give □Next⊤ ∨
      □¬Next⊤), which inherits TM⁺'s outstanding base-case obligation — carry that hedge
      explicitly. The schematic form (DD) takes in BL records nothing about the semantics and
      everything about the LANGUAGE: BL has no sentence naming discreteness, so it must disjoin
      schemas where BL⁺ disjoins a sentence with its negation.
- [ ] TM_c fails identically over {ℤ, ℝ}. TM_f's status is DIFFERENT and must not be lumped in: it
      is sound over EVERY discrete frame (DF is valid there), but its completeness over that
      broader class is OPEN — the machine-checked discrete result is for BX_f over ℤ-time
      specifically, a narrower and deductively stronger system than TM + DF, and no counterexample
      to TM_f's completeness over the full discrete class is known.
- [ ] Reuse the predecessor's verbatim quotes for this material rather than re-deriving from the
      paper; the research pass independently re-confirmed they still match the live text.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: Budgeted at ~1.5 of ~10 body pages including diagram 1. Confirm by compiling;
if the diagram pushes the section over, shrink the canvas rather than cutting either proof — both
are designated "give in full".

**Files to modify**:
- `typst/FormalFoundations.typ` - section 4 body + diagram 1

**Verification**:
- Compile succeeds; diagram renders on one page without overflow; `typst-sync-check.sh` passes.
- The taxonomy paragraph states all three distinctions (TM semantically incomplete; TM + (DD)
  Halldén-incomplete; Halldén-incompleteness of the class logic a theorem).
- TM_f is treated separately from TM_c and its completeness over the full discrete class is marked
  open.

---

### Phase 7: Section 5 — pain point three, axiomatizing the strongest objective modality [COMPLETED]

**Goal**: The paper's objective-modality appendix compressed to its load-bearing structure, with
the orthogonality point foregrounded and the pain stated plainly.

**Tasks**:
- [ ] The setup: BL extended with a primitive propositional identity operator and higher-order
      quantifiers (`def:id`, with Ref, Imp, LL); operator variables over an unrestricted domain of
      operations on propositions; the objective modalities AXIOMATIZED by a primitive predicate O
      on operator terms rather than defined outright, following the theory of necessities in Bacon
      (2022) (`bacon2022necessities`).
- [ ] PREDICATIVITY: operator comprehension confined to formulas containing no operator variables
      and no occurrences of O, blocking Russell–Myhill and keeping the system consistent with a
      fine-grained identity; cite Walsh (2016) (`walsh2016predicativity`) for the consistency proof
      of a predicative restriction of Church's intensional logic; note that predicativity could be
      dropped by strengthening the theory of identity, since coarse-grained identity blocks
      Russell–Myhill.
- [ ] `def:strongest`, verbatim in substance: Q is a strongest objective normal modal operator in L
      — Str^O_L(Q) — iff (1) ⊢ O(Q) and (2) ⊢ ∀P[O(P) → (Q ⪯ P)], with ⪯ the dominance ordering;
      objectivity and normality need not be stated separately, since clause (1) already entails
      objectivity, the axiom condition, and normality.
- [ ] `thm:exist`: Str^O_L(Bm) — the meet operator witnesses existence, clause (1) being the second
      conjunct of (O-Meet) and clause (2) following from the first, with T, N, K and closure under
      necessitation obtained by detaching (O-Fac), (O-Ax), and (O-Nec) at Bm.
- [ ] `lem:uniq` (any two strongest objective normal modal operators are provably equivalent,
      ⊢ ∀p(Qp ↔ Pp)); `thm:s4` (Str^O_L(Q) yields ⊢ ∀p(Qp → QQp)); `thm:sym` (Str^O_L(Q) yields
      ⊢ ∀p(p → Q Dual-Q p)) — compress `thm:sym` to result-and-cite; do not reproduce its ~15-line
      chain.
- [ ] The payoff: under Str^O_L(□), `lem:uniq` gives ⊢ ∀p(□p ↔ Bm p), `thm:s4` gives S4, `thm:sym`
      gives B, and factivity and necessitation for the primitive □ follow by detaching (O-Fac) and
      (O-Nec) — together delivering an S5 logic for □.
- [ ] Note that `cor:exists` is a SEPARATE, weaker route to existence buying it at the price of a
      coarse-grained identity the paper does not assume; `thm:exist` replaces reliance on it, and
      the report must not present `cor:exists` as the paper's existence result.
- [ ] THE ORTHOGONALITY POINT, foregrounded: S5-hood alone cannot single □ out. The paper's own
      restricted case is the counterexample — the stability modality is likewise S5 (its
      accessibility partitions H_F into equivalence classes) yet on non-temporal formulas it
      collapses to the trivial modality. A strictly narrower accessibility relation can carry a
      strictly stronger logic; it is ⪯-leastness, not S5-hood, that picks □ out. **Ground this in
      the live `Stability` footnote plus `def:strongest`/`thm:exist` and state the general lesson
      in the report's own voice** — the paper's sentence stating it generally is commented out in
      the live source and must not be quoted as paper prose.
- [ ] THE PAIN, stated plainly: what is axiomatized is a HIGHER-ORDER theory of the objective
      modalities, not a BL-level or BL⁺-level proof system, and the connection between the two
      levels is a hypothesis (Str^O_L(□)) adopted afresh for each system under study rather than a
      theorem of TM or TM⁺. State what this leaves open: whether the leastness characterization is
      expressible or derivable at the propositional level at all; what a propositional
      axiomatization would have to add; whether the frame-relative plurality of □ operators is
      genuinely benign (the paper argues it is, since no cross-frame rival is even formulable within
      the theory and a reader wanting absoluteness may take the universal system); and how the
      irregular-worlds broadening of section 3 interacts, given that it DISPLACES □ from its
      standing as Str^O_L(□) — so the two pain points are not independent, and the report should say
      so explicitly.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: Budgeted at ~1.5 of ~10 body pages. Confirm by compiling; the first cut
candidate if over is further compression of the predicativity paragraph, not the orthogonality
point or the pain paragraph.

**Files to modify**:
- `typst/FormalFoundations.typ` - section 5 body

**Verification**:
- Compile succeeds; `typst-sync-check.sh` passes.
- `cor:exists` is not presented as the paper's existence result.
- No sentence attributes the general orthogonality lesson to the paper as a quotation.
- The section explicitly cross-references section 3's displacement point.

---

### Phase 8: Section 6 — the completeness construction as implemented here [COMPLETED]

**Goal**: An honest, measured, anchor-by-anchor account of what is actually in
`FormalSystem/Metalogic/`, with diagram 2 and the report's strongest structural insight made
explicit.

**Tasks**:
- [ ] The core layer: consistency, maximal consistent sets, negation-completeness, the deduction
      theorem, and Lindenbaum via Zorn (`Metalogic/Core/`, `set_lindenbaum` in
      `Core/MaximalConsistent.lean`); note the set-level `SetConsistent`/`SetMaximalConsistent`
      layer is correctly finitary.
- [ ] The architecture: contraposition (if φ is underivable then {¬φ} is consistent and extends to
      an MCS containing ¬φ), followed by a THREE-WAY CASE SPLIT on the discreteness indicator
      U(⊤,⊥) — i.e. on whether □¬Next⊤ or □Next⊤ is in the MCS — with the mixed case ELIMINATED
      OUTRIGHT by `mcs_mixed_case_absurd`: an MCS cannot be undecided about discreteness.
- [ ] **Diagram 2** (cetz, book idiom): the decision node on □(¬Next⊤)/¬□(¬Next⊤) branching to the
      dense branch (`countermodel_dense_enriched` on ℚ) and the discrete branch
      (`countermodel_discrete_reynolds_v2` on ℤ), with the mixed branch struck through and marked
      `mcs_mixed_case_absurd`. Annotate the figure with the "same dichotomy that breaks BL makes BL⁺
      go through" callout.
- [ ] **The structural rhyme, made explicit** — the report's single most illuminating connection:
      this is the same discrete/dense dichotomy that BREAKS TM at the BL level (section 4); the
      difference is that BL⁺ has a sentence naming discreteness and BL does not, so the very fact
      producing (DD)'s unprovable-but-valid disjunction at the BL level is exactly what the BL⁺
      completeness architecture case-splits on to make the canonical-model construction go through.
- [ ] The dense path: the Burgess-style CHRONICLE construction over ℚ
      (`Metalogic/BXCanonical/Chronicle/`, `ChronicleConstruction.lean`'s
      `singletonChronicle` → `omegaChain` → `limit_chronicle`), filling in Until/Since
      eventualities, with `completeness_dense` in `BXCanonical/Completeness.lean`.
- [ ] The discrete path: the Reynolds/Doets pipeline over ℤ (`Metalogic/WeakCanonical/`,
      `Transfer.lean`), running through a Kamp-theorem-based expressive-completeness argument
      (`WeakCanonical/Kamp/`, `Separation/`, `EFGames/`, `Expressiveness/`).
- [ ] The Dedekind path, which the reference book currently omits entirely:
      `BXCanonical/CompletenessDedekind.lean`, `Metalogic/StrongCompleteness.lean`
      (`completeness_dedekind`, `consequence_completeness_dedekind`), and the `RealModel/` subtree
      (Doets, shuffle, order-iso-to-ℝ), on the Reynolds-triple basis Prior-U + Sep with CO derived.
- [ ] The shared infrastructure: bundled families of MCSs with G/H coherence (`Metalogic/Bundle/`,
      BFMCS, `modal_forward`/`modal_backward`); the D-PARAMETRIC algebraic truth lemma
      (`Metalogic/Algebraic/`, `FlowFrame.lean`) that turns a coherent MCS family into a task model
      — emphasize that this parametricity is exactly what lets one construction serve several
      carriers, and note its Spherical discharge is a third pattern distinct from the finite-W and
      general-Zorn routes; filtration and quasimodels (`BXCanonical/Filtration/`, `Quasimodel/`).
- [ ] STATUS DISCIPLINE: for every headline result, state sorry-status and axiom profile from
      Phase 2's measurements as placeholders to be re-stamped at Phase 10, dated in text or
      footnote. Record that the single live non-`Boneyard/` `sorry` is dead code in
      `WeakCanonical/Transfer.lean`'s `countermodel_discrete`, whose live replacement is
      `countermodel_discrete_reynolds_v2`; report `sorry_algebraic = 0` as measured and do NOT
      repeat `UltrafilterMCS.lean`'s stale "contains sorries" docstring. Describe no `Boneyard/`
      content as live.
- [ ] TERMINOLOGY, settled project-wide: "strong completeness" is reserved for consequence from
      possibly-infinite premise sets; because contexts are finite lists, any finite-context
      consequence statement is inter-derivable with weak completeness through the deduction theorem
      and is called CONSEQUENCE COMPLETENESS, never strong. Paraphrase `Metalogic/StrongCompleteness.lean`'s
      module docstring closely as the in-tree authority.
- [ ] BX/TM DISCIPLINE: state the architecture in `Metalogic/`'s own BX vocabulary throughout
      (`FrameClass.Dense`/`FrameClass.Discrete`/`FrameClass.Base`); never silently rename
      `completeness_dense` as "TM_d's completeness". State the cross-reference question — whether
      the BX-level theorems resolve, contradict, or are orthogonal to `cor:tm-completeness`'s
      TM_d/TM_f status — as explicitly OPEN, and do not adjudicate it.
- [ ] Reuse the book's rebuilt module table as a starting point for any module inventory rather
      than re-deriving it, but confirm the directory list against the live tree before printing it.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: local

**Scope Hypothesis**: Budgeted at ~2 of ~10 body pages including diagram 2, and asserts a module
inventory whose directory list was measured on 2026-08-13. Confirm the inventory at implementation
time with a fresh `find` over `FormalSystem/Metalogic/` rather than transcribing the research
report's listing; the tree is under active development.

**Files to modify**:
- `typst/FormalFoundations.typ` - section 6 body + diagram 2

**Verification**:
- Compile succeeds; diagram renders cleanly; `typst-sync-check.sh` passes with every backticked
  Lean identifier resolving under `FormalSystem/` (excluding `Boneyard/`) or whitelisted.
- Every Lean identifier printed is confirmed to exist at its stated location by direct check.
- The BX/TM cross-reference is marked open; no BX theorem is renamed to a TM-family result.
- The structural-rhyme paragraph is present and explicit.

---

### Phase 9: Section 7 — early representation work and the way forward [COMPLETED]

**Goal**: The report's terminus: the `metalogic.tex` warning heeded, the live algebraic layer
described accurately, the shift-set and Jönsson–Tarski programmes written as TARGETS, a reasoned
way-forward outline answering (a)–(f) with named obstructions, and diagram 3.

**Tasks**:
- [ ] THE WARNING, heeded: if `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/metalogic.tex`'s
      "Representation Theorem" section is cited at all, cite it ONLY as a historical waypoint and
      name its defects explicitly — (1) `def:canonical-temporal-order` hard-codes T^c = ⟨ℤ, +, ≤⟩,
      not D-parametric unlike the live construction; (2) `thm:representation` and
      `cor:frame-characterization` assert TM is sound AND COMPLETE over the class of all task
      semantic frames, directly contradicting `cor:tm-completeness`; (3) the Box case of its Truth
      Lemma assumes global agreement across all canonical histories rather than deriving it from an
      accessibility/modal-saturation construction, where the live architecture routes through BFMCS
      `modal_forward`/`modal_backward` coherence; (4) its weak- and strong-completeness claims for
      TM are exactly what `cor:tm-completeness` and `StrongCompleteness.lean`'s docstring refute.
      Lift NO definition, theorem statement, or proof step. Restate its completeness claims in no
      form. Make no edit under `/home/benjamin/Philosophy/Papers/`.
- [ ] WHAT ACTUALLY EXISTS: the ALGEBRAIC layer, and only it — `Metalogic/Algebraic/BooleanStructure.lean`,
      `LindenbaumQuotient.lean`, `UltrafilterMCS.lean`, `InteriorOperators.lean`, `FlowFrame.lean`:
      the Lindenbaum–Tarski algebra, its ultrafilters, and the interior-operator treatment of the
      modalities, measured sorry-free.
- [ ] THE SHIFT-SET PROGRAMME, written as a TARGET, not existing work: state the intended theorem
      in both directions — that the task-model class is representable by shift sets ⟨Ω, D, sh, A⟩
      with D an ordered abelian group, Ω a nonempty type carrying a D-action, and A : Atom → Ω →
      Prop — and its payoff, that the task-model class is then first-order axiomatizable over the
      two-sorted signature ⟨Ω, D; <, +, 0, sh, (A_p)⟩ BECAUSE the frame's algebraic content reaches
      truth only through the atom clause. State plainly that no such Lean development exists yet:
      what exists is a design document, not a proof. Render shift-set names as ordinary math or
      prose — they are NOT live Lean identifiers and must not be backticked. Note that the design
      document's literal Lean snippets predate the completed total-history refactor and would need
      restatement (the underlying argument survives; the signature does not).
- [ ] THE JÖNSSON–TARSKI PROGRAMME, written as an ARCHIVED target: the complex algebra Cm(F) of a
      task frame, the ultrafilter frame Uf(A) of an abstract algebra, and the embedding
      η(a) = {U : a ∈ U}; record that this material was archived out of the live tree and that its
      revival is tracked only as an unstarted future item, describing no `Boneyard/` content as
      live. Record the important obstruction: *Spherical* for an ultrafilter frame is a genuinely
      nontrivial NEW obligation, and the finite-W discharge pattern (`cor:spherical-finite`) does
      NOT apply to ultrafilter frames, which are typically infinite.
- [ ] THE WAY FORWARD — a reasoned outline with named obstructions, not a wish list, addressing at
      minimum:
  - [ ] (a) WHAT MUST BE WEAKENED: which of `def:frame`'s four axioms are genuinely needed for a
        representation theorem and which are strengthenings that could be dropped or made
        parametric; *Spherical* as prime suspect, being hardest to discharge at infinite carriers
        and exactly where the Jönsson–Tarski route stumbles; whether a weaker
        completeness/saturation condition suffices for the Step Lemma. Use the three known
        Spherical discharge patterns (finite-W, general Zorn, the D-parametric deterministic-fiber
        argument) as concrete evidence for what stays available under weakening.
  - [ ] (b) THE GROUP STRUCTURE AS CRUX, both ways — the report's single most valuable analysis:
        the discrete-or-dense dichotomy is a theorem about ordered abelian GROUPS and fails for bare
        linear orders, so dropping D to a linearly ordered set (or a monoid, or a partially ordered
        group) DISSOLVES the (DD) obstruction outright. Work out honestly what it costs: MF and the
        perpetuity principles depend on translation invariance; the converse convention depends on
        negation; Compositionality is stated in terms of addition. Say what survives each weakening.
  - [ ] (c) DISJOINT-UNION CLOSURE: is the coset-domain construction of section 3 the right route,
        given that its price is precisely a LOSS of the correspondence results a representation
        theorem would want — or is a genuinely multi-frame semantics needed, and what would Box then
        quantify over?
  - [ ] (d) ALGEBRAIC ROUTE VS SHIFT-SET ROUTE: which is likelier to reach a general representation
        theorem, and are they the same theorem twice? The shift-set route's payoff is first-order
        axiomatizability and hence a compactness/ultraproduct argument; the Jönsson–Tarski route's
        payoff is a canonical embedding and duality. State what each would deliver and where each
        currently stops. Ground the shift-set side in the design document's recorded four-step route
        (feasibility gate → bespoke two-sorted ultraproduct → a Łoś lemma for truth → model
        existence/compactness → per-class strong completeness), the rejected single-sorted-encoding
        alternative, and its four named risks (dependent ultraproduct of carriers as the largest
        unknown; the box case of Łoś needing a choice-function argument; a universe constraint that
        must be asserted early; and the honest verdict "promising, not certain").
  - [ ] (e) WHAT WOULD COUNT AS ADEQUATE: quote the in-tree acceptance standard rather than
        paraphrasing it — a sorry-free Lean statement of BOTH directions with `#print axioms`
        reporting no `sorryAx`; a statement that type-checks with a sorry body does not count, one
        direction does not count, a prose argument does not count.
  - [ ] (f) WHAT IS FORECLOSED: genuine strong completeness is IMPOSSIBLE for ℤ-time and for ℝ
        (compactness fails; an explicit non-compactness witness is recorded for the
        successor-Archimedean discrete case, and Reynolds (1992) establishes the analogous failure
        over ℝ). Any way forward promising strong completeness for those classes is wrong on
        arrival. Base and Dense are open, not settled, and the missing piece is a MODEL-EXISTENCE
        theorem (every consistent SET satisfiable in a class frame), which does not follow from the
        single-formula countermodel engines already built.
- [ ] **Diagram 3** (cetz, book idiom): the representation-theorem landscape — two parallel routes
      from "task-model class" toward "representation theorem", the algebraic route (live through
      Lindenbaum–Tarski algebra → ultrafilters → interior operators, terminating at an ARCHIVED
      Jönsson–Tarski stage) and the shift-set route (NOT STARTED: design → feasibility gate →
      ultraproduct pipeline). Label every stage's live/target/archived status explicitly on the
      figure; getting the status marking right matters more here than the geometry.
- [ ] Cite no task numbers anywhere: refer to durable anchors (module paths, the design document by
      name, "an unstarted future item", "the archived subtree") rather than task-management
      metadata.

**Timing**: 2.5 hours

**Depends on**: 8

**Verification Tier**: local

**Scope Hypothesis**: Budgeted at ~2.5 of ~10 body pages including diagram 3, and asserts that
exactly one of the three named representation-work items is live. Confirm at implementation time by
re-checking that no `ShiftSet`/`shiftSet` identifier exists under `FormalSystem/`
(`grep -rln 'ShiftSet\|shiftSet' FormalSystem/`) and that the Jönsson–Tarski files remain under
`Boneyard/`; if either has changed since 2026-08-13, restate the status accordingly rather than
transcribing this plan.

**Files to modify**:
- `typst/FormalFoundations.typ` - section 7 body + diagram 3

**Verification**:
- Compile succeeds; diagram 3 renders with per-stage status labels; `typst-sync-check.sh` passes.
- No shift-set-only name is backticked as a Lean identifier.
- The shift-set and Jönsson–Tarski programmes are described as target and archived-target
  respectively — neither is narrated as existing work.
- No `Boneyard/` content is described as live.
- Way-forward points (a)–(f) are each addressed.
- No task number appears in the file.

---

### Phase 10: Compression pass, fresh measurement, and the full acceptance gate [COMPLETED WITH EXCLUSIONS]

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| ~10-page body-text target | The report's seven mandatory content areas (system, key theorems, three pain points, the construction, the way forward), three required diagrams, two full proofs, four tables, and per-claim status-dated footnotes produce genuinely dense content; a compression pass (converting 7 thmbox environments to inline prose, moving two long proofs out of footnotes into proper `#proof` blocks, shrinking and consolidating all three diagrams into single `#figure` blocks) reduced the count from 18 to 17 pages without cutting any required content, open-marking, or status claim. Further cuts risked violating the "give in full" and status-marking acceptance criteria for marginal page savings. | `typst/build/FormalFoundations.pdf` compiles to 17 pages (measured via `pdfinfo`); every named cut candidate in the plan's Phase 10 task list was applied; the status-marking audit below confirms no content was lost. |

**Goal**: The report lands at ~10 pages of body text, every status numeral is freshly measured and
dated, every status claim is audited, and all acceptance criteria pass.

**Tasks**:
- [ ] Re-run `bash scripts/check-paper-definitions.sh` IMMEDIATELY BEFORE the final pass over
      quoted definitions; confirm case (a) or (b). On case (c), STOP, re-resolve and re-quote the
      drifted anchor, then re-run. Do not substitute Phase 2's earlier run.
- [ ] Re-run `bash scripts/typst-status-counts.sh --json` and re-take `#print axioms` for every
      flagship result the report cites by status. Replace every placeholder numeral with the fresh
      measurement and stamp the measurement date and commit in the text or a footnote.
- [ ] Compression pass to the ~10-page body-text target: measure the compiled page count; apply the
      pre-named cut candidates in order (correspondence-theorem detail; the `thm:sym` chain; the
      perpetuity derivation chain; diagram canvas sizes) before touching designated-in-full
      material or the section-3/section-7 prose.
- [ ] STATUS-MARKING AUDIT (acceptance criterion 5): read every status-bearing sentence and confirm
      each is marked open, target, archived, or measured-established as appropriate. Specifically
      verify: TM⁺ weak completeness over all task frames is a target with one outstanding
      obligation; decidability is open with no theorem asserted; TM_f completeness over the full
      discrete class is open; the BX/TM cross-reference is open; strong completeness for ℤ-time and
      ℝ is foreclosed; Base and Dense strong completeness are open; shift-set representation is a
      target; Jönsson–Tarski is archived.
- [ ] Run `bash scripts/typst-sync-check.sh` and resolve every Check 1 violation either by fixing
      the identifier or by adding a whitelist entry to `typst/sync-check-whitelist.txt` with a
      one-line reason in the existing comment style.
- [ ] Grep the new file for task-number patterns and for any `Boneyard`-as-live phrasing; confirm
      zero hits.
- [ ] Confirm no edits were made to `BimodalReference.typ`, `typst/chapters/`, `latex/`,
      `FormalSystem/`, or anything under `/home/benjamin/Philosophy/Papers/` — verify with
      `git status --short`.
- [ ] Final compile to `typst/build/FormalFoundations.pdf` with no unresolved references or
      citations; confirm `typst/README.md`'s build entry matches the working command.
- [ ] If any book defect was found while writing, record it in this task's `reports/` rather than
      editing the book.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: Asserts a ~10-page body-text target and a full-green four-gate outcome.
Confirm at implementation time by measuring the compiled page count directly (excluding
front/back matter from the body count) and by running all four gates to exit 0 / case (a)-(b);
report the actual page count in the summary rather than asserting the target was met.

**Files to modify**:
- `typst/FormalFoundations.typ` - measured numerals, compression edits
- `typst/sync-check-whitelist.txt` - only if a legitimate non-resolving span requires it
- `specs/443_formal_foundations_report_completeness_and_representation/reports/` - book-defect note, only if one was found

**Verification**:
- `cd typst && typst compile FormalFoundations.typ build/FormalFoundations.pdf` exits 0, no
  unresolved references or citations, body ~10 pages.
- `bash scripts/typst-sync-check.sh` exits 0.
- `bash scripts/check-paper-definitions.sh` exits case (a) or (b), run immediately before the final
  citation pass.
- Every Lean status claim in the file carries a measurement date.
- `git status --short` shows changes confined to `typst/FormalFoundations.typ`, `typst/README.md`,
  `typst/sync-check-whitelist.txt`, `typst/build/`, and `specs/`.

---

## Testing & Validation

- [ ] `cd typst && typst compile FormalFoundations.typ build/FormalFoundations.pdf` succeeds with no
      unresolved references or citations; body is ~10 pages at the book's type settings.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 with the new file present (Check 1: every
      backticked Lean name resolves under `FormalSystem/` excluding `Boneyard/`, or is whitelisted
      with a one-line reason).
- [ ] `bash scripts/check-paper-definitions.sh` exits case (a) or (b), run immediately before the
      final pass over quoted definitions.
- [ ] Every claim about Lean status is measured at authoring time (`#print axioms`, `lake build`,
      `scripts/typst-status-counts.sh`) and dated in the text or a footnote.
- [ ] Every "open" is marked open and every "target" marked target; the shift-set and
      Jönsson–Tarski programmes appear as targets, never as existing work.
- [ ] `typst/README.md` documents the new build target as a separate entry.
- [ ] No task numbers appear anywhere under `typst/**`.
- [ ] No `Boneyard/` content is described as live.
- [ ] `BimodalReference.typ` does not `#include` the new file.
- [ ] No edits under `FormalSystem/`, `latex/`, `typst/chapters/`, or
      `/home/benjamin/Philosophy/Papers/`.

## Artifacts & Outputs

- `typst/FormalFoundations.typ` - the report source (new)
- `typst/build/FormalFoundations.pdf` - compiled output (new)
- `typst/README.md` - new standalone build-target entry
- `typst/sync-check-whitelist.txt` - new entries only if required
- `specs/paper-definitions-of-record.md` - extended with the anchors this report quotes verbatim
- `specs/443_formal_foundations_report_completeness_and_representation/reports/02_measured-status.md` - dated measurement baseline
- `specs/443_formal_foundations_report_completeness_and_representation/summaries/01_formal-foundations-report-summary.md` - execution summary

## Rollback/Contingency

All work is additive: the report and its build output are new files, and the only edits to existing
files are an appended `typst/README.md` entry, optional `typst/sync-check-whitelist.txt` entries, and
additive `specs/paper-definitions-of-record.md` entries. Reverting means deleting
`typst/FormalFoundations.typ` and `typst/build/FormalFoundations.pdf` and reverting those three
files; nothing in the book, the Lean tree, or the paper depends on any of it, so no downstream
breakage is possible. Per-phase commits keep the rollback granular. If the paper drifts into a
case-(c) FAIL that cannot be resolved within the task, mark the affected phase `[BLOCKED]` with the
failing anchor named, leave prior phases committed, and stop rather than quoting a drifted anchor.
