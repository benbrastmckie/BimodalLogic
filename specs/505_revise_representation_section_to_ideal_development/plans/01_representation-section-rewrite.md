# Implementation Plan: Task #505

- **Task**: 505 - Revise representation section to ideal development
- **Status**: [IMPLEMENTING]
- **Effort**: 7.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/505_revise_representation_section_to_ideal_development/reports/01_representation-theorem-ideal-development.md`
- **Artifacts**: plans/01_representation-section-rewrite.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

Replace `<sec:representation>` in `typst/FormalFoundations.typ` (currently the five-part
"Toward a Representation Theorem": lines ~1153-1581) with a positive development of the
representation theorem for TM⁺: statement, proof architecture, and per-class refinements, as
prescribed by the research report's §R1 outline and §R2 style rules. The rewrite is a document
edit only — no Lean source changes. Done when the section carries the new title, the four
prescribed subsections, no item on the cut list, an updated abstract sentence, four repaired
cross-references, the new bibliography entries, and both Typst documents compile with
`scripts/typst-sync-check.sh` passing.

### Research Integration

The research report fixes every substantive decision, so implementation is transcription plus
verification rather than design:

- **Theorem statement** (report §3.1): every TM⁺-algebra embeds point-completely into a product
  of complex algebras of shift-set flows, one per □-component, each temporal order discrete or
  dense according to `n = N1`.
- **Proof architecture** (report §3.2): six steps — components, free presentation, model
  existence, descent, one flow per component by saturation, factorization `h = π⁻¹ ∘ η_JT`.
- **Section outline** (report §R1): opening paragraph, then `== Algebras and Complex Algebras`,
  `== Shift Sets`, `== The Ultrafilter Frame`, `== The Representation Theorem`, plus at most one
  optional status table.
- **Cut list** (report §5): eighteen named items, all of which fall inside lines 1153-1581 and
  therefore go with the wholesale excision in Phase 2.
- **Style rules** (report §R2) and **bibliography additions** (report §R3).

Two corrections to the report's Appendix module paths were established during planning and are
folded into the phases below: `multiFamTaskFrameGen` lives in
`Metalogic.BXCanonical.CompletenessDedekind` (not `Metalogic.Algebraic`), `multiFamGen_spherical`
in `Metalogic.Algebraic.FlowFrame`, `completeness_discrete` in `Metalogic.WeakCanonical`,
`soundness_dense`/`soundness_discrete` in `Metalogic.BaseLanguageSoundness`, and
`soundness_linear`/`soundness_Int` in `FrameConditions.Soundness`.

### Prior Plan Reference

No prior plan. The sibling task's report
(`specs/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md`)
is an input to this task's research report, not a plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no ROADMAP.md consultation was
requested; `roadmap_flag` is absent, so no roadmap phases are added.

## Goals & Non-Goals

**Goals**:

- State the representation theorem for TM⁺ positively, with its proof architecture and per-class
  refinements, in `<sec:representation>`.
- Treat strict Since/Until and G/H as primitive-derived per the report; state positively that only
  normality, transitivity, seriality, linearity, and tense conjugacy are used; remove the
  interior-operator framing entirely.
- Remove every item on the report's cut list, including the `<sec:duality>` subsection and label.
- Confine Lean status to `#leansrc` tags and at most one compact table; no meta-commentary.
- Update the abstract sentence and the four out-of-section cross-references.
- Add the missing bibliography entries.
- Keep `typst/FormalFoundations.typ` and `typst/BimodalReference.typ` compiling and
  `scripts/typst-sync-check.sh` passing.

**Non-Goals**:

- Any change to Lean source under `FormalSystem/`. This task writes prose only.
- Re-targeting the sibling algebraic tasks (report §4 records what they need; a separate revision
  handles it).
- Topological duality, decidability, or a representation theorem for BL-level TM (one sentence
  suffices for the last).
- Regenerating `typst/generated/` (sync-check checks 2 and 3 are unaffected by prose edits).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A backticked Lean name in the new prose fails sync-check Check 1 | M | H | Check 1 greps every backticked span in `typst/**/*.typ` against live Lean source excluding `Boneyard/`. Before writing any backticked identifier, confirm `grep -rl --include=*.lean --exclude-dir=Boneyard -F "$name" FormalSystem/` is non-empty; otherwise use `#leansrc` (whose arguments are NOT backticks and so are not scanned) or prose. Add to `typst/sync-check-whitelist.txt` only as a last resort, with a comment. |
| Line numbers drift as edits land | M | H | Anchor every edit to unique surrounding text, never to a line number. The line numbers in this plan are provenance, not addresses. |
| A dangling `@sec:duality` survives the excision and breaks compilation | H | L | Phase 7 greps for `sec:duality` repo-wide after the rewrite; expected result is zero hits. |
| Over-claiming Lean status (base-class `completeness` carries one `sorryAx`; the ultraproduct chain is planned, not landed) | M | M | State the theorem as mathematics with proof. The optional table records status; no sentence asserts the theorem itself is machine-checked. |
| The ℤ-group / divisible-group clause misread as a claim that `Cm` of such flows validates Z1 or CO | M | M | State explicitly that the embedding is into a subalgebra and that `Cm(S_k)` need not lie in the subvariety. |
| Adding bibliography entries breaks `BimodalReference.typ` | H | L | Only cited entries render; Phase 1 compiles both documents immediately after the bib edit. |
| Style-rule violations (meta-commentary) creep back in during composition | M | M | Phase 8 runs a dedicated grep-and-read audit against the report's §R2 banned-vocabulary list. |

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

Phases within the same wave can execute in parallel. This plan is fully sequential by design:
every phase edits the same file (`typst/FormalFoundations.typ`), so parallel dispatch would
produce write conflicts rather than speedup.

---

### Phase 1: Ground Truth and Bibliography [COMPLETED]

**Goal**: Establish that every Lean anchor the new section will cite resolves, fix the module
paths, and land the bibliography additions with both documents still compiling.

**Tasks**:

- [x] Confirm each `#leansrc` anchor resolves in live Lean source, and record the correct module
      path for each: `Semantics.ShiftSet` (`ShiftSet`, `frame`, `ofModel`, `forward_repr`,
      `reverse_repr`, `sep_not_derivable`); `Metalogic.Algebraic.LindenbaumQuotient`
      (`LindenbaumAlg`); `Metalogic.Algebraic.UltrafilterMCS` (`mcsToUltrafilter`,
      `ultrafilter_correspondence`); `Metalogic.Algebraic.FlowFrame` (`multiFamGen_spherical`);
      `Metalogic.BXCanonical.CompletenessDedekind` (`multiFamTaskFrameGen`,
      `completeness_dedekind_engine`); `Metalogic.WeakCanonical` (`completeness_discrete`);
      `Metalogic.SetConsequence` (`StrongCompletenessBase`, `CompactBase`, `ModelExistenceBase`,
      `discrete_consequence_not_compact`); `FrameConditions.Soundness` (`soundness_linear`,
      `soundness_Int`); `Metalogic.BaseLanguageSoundness` (`soundness_dense`,
      `soundness_discrete`); plus `completeness_dense` and `BFMCS`. *(completed: all 23 names
      confirmed against live source; `LindenbaumAlg` def-site is
      `Metalogic.Algebraic.LindenbaumQuotient` per plan)*
- [x] Use `bash -c 'grep -rl --include=*.lean --exclude-dir=Boneyard -F "<name>" FormalSystem/'`
      as the resolution test, matching sync-check Check 1's own predicate. *(completed)*
- [x] Write the confirmed module/name table into the phase's progress record so Phases 3-6 cite
      from it rather than re-deriving. *(completed: see progress/phase-1-progress.json)*
- [x] Add to `typst/bibliography.bib`: Halmos, *Algebraic Logic* (Chelsea, 1962) or "Algebraic
      logic I: monadic Boolean algebras", *Compositio Math.* 12 (1956); Chang & Keisler,
      *Model Theory*, 3rd ed. (North-Holland, 1990); Robinson & Zakon, "Elementary properties of
      ordered abelian groups", *Trans. AMS* 96 (1960). Optionally Kowalski, "Varieties of tense
      algebras", *Rep. Math. Logic* 32 (1998). *(completed: all four entries added, including the
      optional Kowalski)*
- [x] Follow the file's existing entry style and key convention (lowercase author-year, e.g.
      `halmos1962`, `changkeisler1990`, `robinsonzakon1960`, `kowalski1998`). *(completed)*
- [x] Compile both documents: `cd typst && typst compile FormalFoundations.typ
      build/FormalFoundations.pdf` and `typst compile BimodalReference.typ
      build/BimodalReference.pdf`. *(completed: both exit 0)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Planning verified that all 22 spot-checked Lean names above resolve against
live source outside `Boneyard/`, and that four of the report's Appendix module paths were wrong
(corrected in this phase's task list). The implementer must re-run the grep predicate for every
name actually used rather than trusting this list, since the set of cited names is fixed only in
Phases 3-6.

**Files to modify**:

- `typst/bibliography.bib` — three (optionally four) new entries.

**Verification**:

- Every name that will appear inside backticks in the new section has a non-empty grep result, or
  a documented whitelist plan.
- Both `typst compile` invocations exit 0.

---

### Phase 2: Excise the Old Section and Erect the Scaffold [NOT STARTED]

**Goal**: Remove the whole of the current `<sec:representation>` body and leave a compiling
skeleton with the new title, the opening paragraph, and four empty subsection headings.

**Tasks**:

- [ ] Delete everything from immediately after the section heading through the end of
      `== The Obstruction` — i.e. the current opening four-way distinction and its footnote, the
      six-rung table, the cetz ladder figure, `== The Algebraic Layer`,
      `== Duality, Canonicity, and the Obstruction Diagnosed <sec:duality>`,
      `== The Shift-Set Target`, and `== The Obstruction` — stopping before
      `#bibliography("bibliography.bib")`.
- [ ] Change the section heading to `= The Representation Theorem <sec:representation>`, keeping
      the label unchanged.
- [ ] Write the opening paragraph (3-4 sentences, report §R1.1): what the theorem says; that the
      representable algebras are exactly the TM⁺-algebras; that point-completeness is model
      existence, hence strong completeness, per class. No meta-commentary, no ladder, no
      four-way distinction.
- [ ] Insert the four empty subsection headings in order: `== Algebras and Complex Algebras`,
      `== Shift Sets`, `== The Ultrafilter Frame`, `== The Representation Theorem`.
- [ ] Remove the now-unused `cetz` import from the preamble ONLY if no other `cetz.canvas` call
      remains in the file; grep before deciding.
- [ ] Compile `FormalFoundations.typ`.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The section to excise is asserted to span lines 1153-1581 of the current
file, with the cut list's eighteen items entirely inside it and `#bibliography(...)` as the only
content after it. Confirm at implementation time by locating the heading and the
`#bibliography` call by text, not by line number, and by checking that no cut-list item survives
a grep of the whole file.

**Files to modify**:

- `typst/FormalFoundations.typ` — section heading rewritten; body replaced by scaffold; possibly
  the `cetz` import removed.

**Verification**:

- `typst compile FormalFoundations.typ build/FormalFoundations.pdf` exits 0.
- `grep -n 'sec:duality\|six-rung\|Route T\|Route M\|Sahlqvist\|Descriptive General Frame\|sigmaQuot\|boxInterior' typst/FormalFoundations.typ` returns only hits outside the section (expected: the abstract sentence at ~line 128, repaired in Phase 7).

---

### Phase 3: Write `== Algebras and Complex Algebras` [NOT STARTED]

**Goal**: Define TM⁺-algebras and complex algebras, state algebraic soundness, Lindenbaum–Tarski,
and weak completeness stated algebraically.

**Tasks**:

- [ ] `#definition("TM⁺-algebra")` — report §2.1: Boolean algebra with □, U, S; derived
      `F, G, P, H, N, △`; the S5 equations for □; `□a ≤ □Ga`, `□a ≤ □Ha`; each BX schema and its
      mirror as an inequality; `G1 = H1 = □1 = 1`; the four subclasses (base, `TM⁺_d`, `TM⁺_f`,
      `TM⁺_c`) as varieties. Footnote: TD as closure under the U/S swap automorphism, not an
      operation; `sigma` is not in the signature.
- [ ] `#remark` — report §1.1 in prose: the operator properties actually used are normality and
      multiplicativity, transitivity, seriality, weak linearity, tense conjugacy, and the
      □-interactions. State positively that T for G and H is not among them and that
      irreflexivity is neither expressible nor needed, strictness living in the order on the
      duration sort. One sentence that F and P are conjugate and hence complete operators
      (`@venema2007algebrascoalgebras`). One sentence that U and S are additive in the event
      argument only, hence not Jónsson–Tarski operators. No occurrence of "interior operator".
- [ ] `#definition("Complex algebra")` — report §2.2: `Cm(S) := 𝒫(Ω)` for a shift set with the □
      and U/S clauses; `Cm(F) := Cm(ofModel F)` for a task frame; the note that world states and
      possible worlds coincide on a shift-set-induced frame, so the proposition algebra is the
      full powerset. `#leansrc("Semantics.ShiftSet", "ofModel")` and
      `#leansrc("Semantics.ShiftSet", "reverse_repr")`.
- [ ] `#proposition("Algebraic soundness")` — `Cm(F)` is a TM⁺-algebra, and a `TM⁺_d`/`TM⁺_f`/
      `TM⁺_c`-algebra under the corresponding condition on D; `Cm(S)` is □-simple. Tag with the
      four `soundness_*` anchors at their Phase 1-confirmed module paths.
- [ ] `#lemma("Lindenbaum–Tarski")` — the Lindenbaum algebra is the free TM⁺-algebra; its
      ultrafilters are the maximal consistent sets; every TM⁺-algebra is a quotient of a free one.
      `#leansrc` for `LindenbaumAlg` and `ultrafilter_correspondence`/`mcsToUltrafilter`.
- [ ] `#proposition("Weak completeness, algebraically")` — `Fr(ω) ∈ SP Cm(K)` iff TM⁺ is weakly
      complete over K; name the three proved instances by `#leansrc` tag.
- [ ] One sentence carrying the Stone attribution (`@stone1936`).
- [ ] Compile `FormalFoundations.typ`.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:

- `typst/FormalFoundations.typ` — the `== Algebras and Complex Algebras` subsection.

**Verification**:

- Compiles clean.
- No occurrence of "interior operator", `boxInterior`, `sigmaQuot`, or `hQuot` in the subsection.
- Every backticked span in the new text resolves under the Phase 1 predicate.
- Every `@`-citation key used exists in `typst/bibliography.bib`.

---

### Phase 4: Write `== Shift Sets` [NOT STARTED]

**Goal**: Present shift sets as a two-sorted first-order class, the standard translation, the
equivalence with task models, and the compactness situation per class.

**Tasks**:

- [ ] `#definition("Shift set")` — report §2.4: the two-sorted signature
      `(Ω, D; <, +, 0, sh, (A_p))`, D a nontrivial ordered abelian group, the `sh_zero`,
      `sh_add`, and separation (Limit) axioms, Ω nonempty, valuation A.
      `#leansrc("Semantics.ShiftSet", "ShiftSet")`.
- [ ] `#definition("Standard translation")` — `φ ↦ φ*(w, t)` with the atom, □, and U/S clauses;
      note each `φ*` is first-order in the two-sorted language.
- [ ] `#theorem("Task models are shift sets")` — both directions, with `#leansrc` for
      `forward_repr` and `reverse_repr`.
- [ ] `#corollary` — the classes of all shift sets, of dense ones, and of discrete ones are
      elementary; ℤ-time and the Dedekind class are not; the elementary hulls are the ℤ-groups
      (models of `Th(ℤ, +, <)`) and the nontrivial divisible ordered abelian groups (models of
      `Th(ℝ, +, <)`), citing Robinson–Zakon. State this positively as a fact about elementary
      hulls, not as a lament.
- [ ] `#proposition("Compactness")` — Łoś for the standard translation over the elementary
      classes; failure over ℤ and ℝ named by the two witnesses
      (`#leansrc` for `discrete_consequence_not_compact`; `@reynolds1992`). Cite Chang–Keisler for
      Łoś and ultraproducts of two-sorted structures.
- [ ] One sentence noting that the frames induced by shift sets are deterministic, so
      *Spherical*, *Compositionality*, *Seriality* and *Nullity* hold outright and *Limit* is the
      separation axiom; cross-reference `@sec:construction`'s third discharge pattern. No
      "obstruction" framing.
- [ ] Compile `FormalFoundations.typ`.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:

- `typst/FormalFoundations.typ` — the `== Shift Sets` subsection.

**Verification**:

- Compiles clean.
- Backtick and citation-key checks as in Phase 3.
- No sentence stating that shift sets "are not names in the development" or any status prose.

---

### Phase 5: Write `== The Ultrafilter Frame` [NOT STARTED]

**Goal**: Give the ultrafilter frame, its relational correspondents, the Jónsson–Tarski embedding
of the (□, F, P)-reduct, and the component decomposition.

**Tasks**:

- [ ] `#definition("Ultrafilter frame")` — `Uf(A)` with `R_□`, `R_F`, `R_P` (report §2.5). State
      plainly that `Uf(A)` is not, and need not be, a task frame — as a definition, not as a
      concession.
- [ ] `#lemma("Relational correspondents")` — the five items of report §2.5: `R_□` an equivalence
      relation; `R_F` transitive, serial, weakly linear; `R_P = R_F⁻¹`; `R_F, R_P ⊆ R_□`; hence
      each `R_□`-class closed under `R_F` and `R_P`. Note explicitly that no reflexivity or
      irreflexivity condition appears.
- [ ] `#proposition("Jónsson–Tarski")` — `η(a) = {U : a ∈ U}` is an injective homomorphism of the
      (□, F, P)-reduct into the relational complex algebra of `Uf(A)`
      (`@jonssontarski1951`, `@jonssontarski1952`, `@blackburnderijkevenema2001`). Footnote: the
      1951/1952 papers construct a perfect extension and the modern successor framework organizes
      it as the canonical extension (`@gehrkevosmaer2011`). No "fixing an inaccuracy" framing.
- [ ] `#proposition("Components")` — report §2.6: `F_U := {a : □a ∈ U}`; the congruence `θ_U`
      (compatibility with U and S via UC, UG composed with MF); `A/θ_U` □-simple; `θ_U = θ_V` iff
      `U R_□ V`; `⋂_U θ_U` the identity, so A is a subdirect product of □-simple quotients; `n`
      □-fixed hence in `{0, 1}` in a □-simple algebra. Cross-reference `@sec:dichotomy`'s Case
      Split as the syntactic form of the last clause.
- [ ] Compile `FormalFoundations.typ`.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:

- `typst/FormalFoundations.typ` — the `== The Ultrafilter Frame` subsection.

**Verification**:

- Compiles clean.
- Backtick and citation-key checks as in Phase 3.
- No descriptive-general-frame vocabulary, no canonicity definition, no Sahlqvist material.

---

### Phase 6: Write `== The Representation Theorem` [NOT STARTED]

**Goal**: State the theorem, give its six-step proof, the canonical-construction remark, the
per-class proposition, and the two closing one-sentence remarks; optionally one status table.

**Tasks**:

- [ ] `#theorem("Representation")` — report §3.1 in the document's notation: per `R_□`-class a
      shift set over a discrete or dense `D_k`; injectivity of `h = (h_k)`; point-completeness as
      surjectivity of `π_k` onto the class; the induced task frame and model; the □-simple
      headline case; the converse that every `Cm(S)` is a □-simple TM⁺-algebra; the per-class
      clause (dense and divisible; ℤ-groups; divisible ordered abelian groups). State explicitly
      that the embedding is into a subalgebra and that `Cm(S_k)` itself need not lie in the
      subvariety (Risk R-3).
- [ ] `#proof` — the six steps of report §3.2, one paragraph each, each naming the ingredient it
      consumes and its `#leansrc` where one exists: components; free presentation; model existence
      (weak completeness plus compactness over the elementary class, `completeness`,
      `completeness_dense`, `completeness_discrete`, `completeness_dedekind_engine`,
      `StrongCompletenessBase`/`CompactBase`/`ModelExistenceBase`); descent through the Collapse
      proposition; one flow per component by `|A|⁺`-saturation, citing Chang–Keisler and naming
      the bundled-family construction (`BFMCS`, `multiFamTaskFrameGen`) as the constructive
      alternative in the same paragraph (Risk R-2); factorization `h̄ = π⁻¹ ∘ η_JT`.
- [ ] `#remark("The canonical construction")` — report §3.4: chronicles over `Uf(A)` with C0-C5';
      the Step Lemma discharged by compactness of the Stone space, `R_F[U] = ⋂{η(a) : Ga ∈ U}`
      closed; the flow itself needing no *Spherical*. Cross-reference `@sec:system`'s Extension
      and `@sec:construction`'s third discharge pattern. One sentence on the `n = 1` case being
      forced stepwise, which is why discrete components are represented over ℤ-groups.
- [ ] `#proposition("ℤ-time and ℝ")` — report §3.5, positively: no point-complete representation
      over ℤ-flows or ℝ-flows; what holds there is the SP-representation of the Lindenbaum
      algebra, i.e. weak completeness; what holds point-completely is the theorem's per-class
      clause. No "gate", no "foreclosed", no "wrong on arrival".
- [ ] `#remark` — two sentences: BL-level TM has no theorem of this kind, by incompleteness; a
      product of complex algebras is not the complex algebra of one frame, which is why the
      theorem ranges over a family of flows (this answers `@sec:contingency`'s disjoint-union
      question).
- [ ] Optional `#figure(table(...))` — at most one compact table of declarations consumed by the
      proof and their status, with a caption and no surrounding prose. Skip it if the `#leansrc`
      tags already carry the information.
- [ ] Compile `FormalFoundations.typ`.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:

- `typst/FormalFoundations.typ` — the `== The Representation Theorem` subsection.

**Verification**:

- Compiles clean.
- Backtick and citation-key checks as in Phase 3.
- At most one table in the whole section; no status prose outside it and the `#leansrc` tags.
- No sentence asserts the theorem itself is machine-checked (Risk R-1).

---

### Phase 7: Abstract and Cross-References [NOT STARTED]

**Goal**: Repair the four out-of-section references and the abstract so the document describes the
section that now exists.

**Tasks**:

- [ ] Abstract (~line 128): replace "Section 5 lays out a six-rung ladder toward a representation
      theorem, distinguishing the algebraic embedding, the topological duality, the task-frame
      representation, and the first-order axiomatization that 'representation theorem' has been
      asked to name, and diagnoses the single obstruction --- the second-order shape of
      *Spherical* --- shared by the two routes that reach it." with a sentence stating the
      theorem: every TM⁺-algebra embeds point-completely into a product of complex algebras of
      shift-set flows, one per □-component, with the per-class refinement. Preserve the
      surrounding sentence flow and the paragraph's register.
- [ ] Line ~340: "That localization is what makes *Spherical* the identified obstruction of
      `@sec:representation`." becomes a statement that the representing frames of
      `@sec:representation` are deterministic, so the localization is what lets them discharge
      *Spherical* outright.
- [ ] Line ~1005: "The algebraic layer of `@sec:representation` measures zero sorries." — keep, or
      name the modules; either is acceptable, but it must remain true of what the section now
      cites.
- [ ] Line ~1096: the disjoint-union remark now points at the component decomposition —
      "represented over a family of frames, one temporal order per component".
- [ ] Line ~898 footnote: verify it still reads correctly ("this third pattern is what
      `@sec:representation` returns to") — the new §5 does return to it, so no edit is expected.
- [ ] `grep -rn 'sec:duality' typst/` must return zero hits.
- [ ] Compile both documents.

**Timing**: 0.5 hours

**Depends on**: 6

**Verification Tier**: interface

**Scope Hypothesis**: Planning found exactly six `@sec:duality` references, all inside the excised
section, and four out-of-section `@sec:representation` references at lines 340, 898, 1005, 1096
plus the abstract sentence at 128. Confirm by re-running `grep -n 'sec:duality\|sec:representation'
typst/*.typ typst/chapters/*.typ` after Phase 6 rather than trusting these numbers; any additional
reference discovered must be repaired in this phase.

**Files to modify**:

- `typst/FormalFoundations.typ` — abstract paragraph and the cross-reference sentences.

**Verification**:

- Zero `sec:duality` hits repo-wide.
- Both `typst compile` invocations exit 0 with no unresolved-reference warnings.

---

### Phase 8: Style Audit and Full Verification [NOT STARTED]

**Goal**: Confirm the section obeys the report's §R2 style rules and that every mechanical gate
passes.

**Tasks**:

- [ ] Grep the section for banned vocabulary (report §R2): "ladder", "rung", "gap", "next step",
      "gate", "not claimed", "candidly", "honestly", "re-posed", "retracting", "scoping",
      "draft", "README", "obstruction", "Route T", "Route M", "interior operator", "descriptive
      general frame", "Sahlqvist", "metric operator". Every hit inside `<sec:representation>` is a
      defect to fix; hits elsewhere in the document are out of scope.
- [ ] Confirm no task-number reference appears anywhere in `typst/` (repository rule
      `no-task-references-in-deliverables.md`).
- [ ] Confirm every cut-list item of report §5 is absent from the file.
- [ ] Read the section end-to-end once: definitions precede use; every theorem has a proof sketch
      or a citation; every citation key exists in `bibliography.bib`.
- [ ] Run `bash scripts/typst-sync-check.sh` and confirm exit 0 across all three checks.
- [ ] Compile both documents one final time.

**Timing**: 1 hour

**Depends on**: 7

**Verification Tier**: full

**Files to modify**:

- `typst/FormalFoundations.typ` — corrective edits only, if the audit finds defects.
- `typst/sync-check-whitelist.txt` — only if a genuinely unresolvable backticked span remains,
  with an explanatory comment in the file's existing category style.

**Verification**:

- `bash scripts/typst-sync-check.sh` exits 0.
- `typst compile FormalFoundations.typ build/FormalFoundations.pdf` exits 0.
- `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0.
- Banned-vocabulary grep returns zero hits inside the section.

---

## Testing & Validation

- [ ] `bash scripts/typst-sync-check.sh` exits 0 (Check 1 name resolution, Check 2 count
      freshness, Check 3 machine appendix).
- [ ] `cd typst && typst compile FormalFoundations.typ build/FormalFoundations.pdf` exits 0.
- [ ] `cd typst && typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0.
- [ ] `grep -rn 'sec:duality' typst/` returns nothing.
- [ ] No banned-vocabulary hit inside `<sec:representation>`.
- [ ] No task-number reference anywhere under `typst/`.
- [ ] Every `@`-citation key used in the new section exists in `typst/bibliography.bib`.
- [ ] No Lean source under `FormalSystem/` is modified.

## Artifacts & Outputs

- `typst/FormalFoundations.typ` — rewritten `<sec:representation>` (title, opening, four
  subsections, optional single status table), updated abstract, four repaired cross-references.
- `typst/bibliography.bib` — three to four new entries (Halmos; Chang–Keisler; Robinson–Zakon;
  optionally Kowalski).
- `typst/build/FormalFoundations.pdf`, `typst/build/BimodalReference.pdf` — recompiled.
- `typst/sync-check-whitelist.txt` — modified only if strictly necessary.
- `specs/505_revise_representation_section_to_ideal_development/summaries/01_*-summary.md` —
  execution summary at completion.

## Rollback/Contingency

All changes are confined to `typst/`. Reverting is `git checkout -- typst/FormalFoundations.typ
typst/bibliography.bib typst/sync-check-whitelist.txt` from a clean-index state, or
`git revert` of the phase commits. Because Phase 2 excises the whole old section in one edit, the
pre-Phase-2 commit is the natural restore point for the old text; the phase commits from 3 onward
are additive within the scaffold and can be reverted individually. If a phase fails verification,
mark it `[PARTIAL]` and stop rather than proceeding — later phases assume a compiling document at
each boundary.
