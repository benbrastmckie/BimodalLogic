# Implementation Plan: Revise `<sec:representation>` with Literature

- **Task**: 503 - revise_representation_section_with_literature
- **Status**: [IMPLEMENTING]
- **Effort**: 8.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md`
- **Artifacts**: plans/01_revise-representation-section.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

Rewrite `= Toward a Representation Theorem <sec:representation>` in
`typst/FormalFoundations.typ` (currently lines 1151-1318) so that it says accurately what a
representation theorem for TM would be, which rungs of the ladder toward it are already
discharged, which are available off the shelf from the literature, and which are blocked or
provably out of reach. The research report supplies the literature grounding: the target theorem
is the Goldblatt/Esakia duality between `BAO_tau` and descriptive general frames, not
Jonsson-Tarski; the *Spherical* obstruction is a compactness condition that fails to descend to
the bare ultrafilter frame because TM's similarity type contains no duration-indexed operator;
and first-order representation is impossible for the `TM_f` and `TM_c` classes because
Archimedeanness and Dedekind completeness are not elementary. This is a documentation task: no
Lean code is written, but every Lean-anchored claim in the section must be re-verified against
live source before it is restated, and two factual errors already identified must be corrected.

Definition of done: the section compiles, `scripts/typst-sync-check.sh` passes, every new
citation resolves against `typst/bibliography.bib`, every `#leansrc` pointer and backticked Lean
name resolves against live `FormalSystem/` source, and no claim flagged PROVISIONAL or
UNVERIFIED in the research report has entered the prose without independent confirmation.

### Research Integration

The plan is organized around the 12-element structure proposed in the report's §5.1, compressed
into four prose phases. Specific findings driving the work:

- **Report §3.1 / Risk 1**: Jonsson-Tarski yields `V_L subset HSPCmK`, an inclusion, not the
  equality completeness needs. The section's current framing of the route as "blocked" is wrong;
  it is *insufficient*, and the missing ingredient is canonicity.
- **Report §3.4**: *Spherical* (`FormalSystem/Semantics/TaskFrame.lean:362`) is shape-identical
  to BdRV Definition 5.65's `compact` condition on a general frame, and BdRV Proposition 5.83(v)
  proves the corresponding statement outright for every descriptive general frame. It fails for
  TM because fibers `Fib(w,x) = R_x[w]` are duration-indexed and no operator of `{box, G, H}`
  denotes `R_x`, so nothing forces `R_x` point-closed on the dual space.
- **Report §3.3 + §5.2**: successor-Archimedean discreteness and Dedekind completeness are not
  first-order, so Fine's theorem supplies no canonicity for `TM_f`/`TM_c` and the shift-set
  programme's first-order payoff is unavailable there. Three of the four frame axioms are
  first-order expressible; only *Spherical* is second-order.
- **Report §1.2 / Risk 2**: the current `#definition("The Lindenbaum--Tarski Algebra")` block
  asserts that `#allpast` and `#allfuture` act as interior operators. `InteriorOperators.lean`
  and `FormalSystem/Metalogic/Algebraic/README.md` say the opposite, and no `G` operator exists
  on the quotient at all. This is a factual error sitting next to a `#leansrc` pointer.
- **Report §3.5**: TA (`phi -> G P phi`) makes the algebra a *tense algebra*, which by
  Venema 2007 Theorem 8.4 yields complete additivity for free — a live asset the section does not
  currently mention.
- **Report Risks 4, 8, 9**: three classes of claim must not reach the Typst file unverified —
  anything sourced from `goldblatt_1989` (OCR locator only), the report's own Sahlqvist
  classification table (the author's reading, not a quotation), and the discriminator-variety
  conjecture about `box(x or Fx or Px)`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `specs/ROADMAP.md` found; no roadmap phases included.

## Goals & Non-Goals

**Goals**:
- Replace the section's single undifferentiated notion of "representation theorem" with the
  explicit four-way distinction (algebraic embedding / duality / task-frame representation /
  first-order axiomatization) and the six-rung ladder, marking each rung's real status.
- Correct the two factual errors in the section: the interior-operator claim about `#allpast`
  and `#allfuture`, and the anachronistic attribution of the ultrafilter-frame formulation to
  Jonsson & Tarski 1951/1952.
- Add the literature the revision cites to `typst/bibliography.bib` and cite it accurately.
- State the *Spherical* obstruction as the diagnosed compactness/similarity-type mismatch it is,
  and re-pose the section's Open Question over the descriptive general frame rather than the bare
  ultrafilter frame.
- State the negative results plainly and per class, including the re-scoping of the project's
  declared gate.
- Name the smallest concrete next step (`gQuot` on the quotient plus normality/additivity) so
  the section ends with a way forward rather than only an impasse.

**Non-Goals**:
- No Lean code is written. Defining `gQuot` or proving normality/additivity is named as the next
  step, not executed here.
- No new literature acquisition. The sources the report could not acquire (Sambin-Vaccaro 1988,
  S. K. Thomason 1972/1975, Goldblatt 1976, Fine 1975, Gehrke-Jonsson 2004) stay unacquired; the
  section is written to the proxies that are in the corpus and does not build a historical
  narrative it cannot source.
- No revision of `typst/BimodalReference.typ` or of sections other than `<sec:representation>`,
  except for the minimum needed to keep cross-references consistent.
- The discriminator-variety conjecture is not settled here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An unverified report claim (Sahlqvist table, `goldblatt_1989` sourcing, discriminator variety) reaches the prose as fact | H | M | Phase 1 is a dedicated audit that classifies every candidate claim VERIFIED / PROVISIONAL / EXCLUDED before any prose is written; PROVISIONAL claims may appear only with explicit hedging, EXCLUDED ones not at all |
| A backticked Lean name or `#leansrc` pointer introduced by the rewrite does not resolve, failing `typst-sync-check.sh` Check 1 | M | M | Phase 1 collects the exact resolving names from live source; Phase 6 runs the check; the whitelist is used only for genuine non-Lean nouns, never to paper over a stale name |
| A malformed or duplicate BibTeX key breaks both `FormalFoundations.typ` and `BimodalReference.typ` | M | L | Phase 1 compiles both documents after the bibliography edit (`interface` tier) |
| The section grows into a literature survey and loses its role as an honest status report on this project | M | M | Every literature statement must be immediately cashed out as a status claim about TM; the ladder table is the spine and each element attaches to a rung |
| Cross-references to `@sec:representation` elsewhere in the file (lines 338, 896, 1003, 1094) become inaccurate as the section is restructured | M | M | Phase 6 re-reads each referring site and confirms the referenced content still exists in the revised section |
| Equations transcribed from the two newly ingested `unverified_conversion` documents are corrupted by linearized display math | M | L | Any equation taken from `venema_2007_algebras_and_coalgebras` or `gehrke_vosmaer_2011_view-of-canonical-extension` is checked against the sibling PDF before transcription; prefer prose statements over transcribed display math |
| Scope creep into rewriting `@sec:construction` or `@sec:system` | M | L | Non-Goals fix the boundary; edits outside lines 1151-1318 are limited to the bibliography and to cross-reference repair |

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

Phases within the same wave can execute in parallel. This plan is fully sequential: phases 2-5
all edit overlapping prose in one contiguous region of `typst/FormalFoundations.typ`, and each
later phase's prose depends on the framing established by the earlier ones.

---

### Phase 1: Ground-Truth Audit and Bibliography Groundwork [COMPLETED]

**Goal**: Establish exactly which claims may be asserted, which must be hedged, and which are
excluded; and put every source the revision will cite into `typst/bibliography.bib` with a
compiling key.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Algebraic/README.md`, `InteriorOperators.lean`,
      `LindenbaumQuotient.lean`, `BooleanStructure.lean`, `UltrafilterMCS.lean` and record: which
      operators exist on the quotient (`boxQuot`, `hQuot`, `sigmaQuot`, and the absence of any
      `G`), which are interior operators, and the exact declaration names to cite. *(completed:
      see claim-audit.md VERIFIED items 2, 4, 5, 6)*
- [x] Confirm the sorry/axiom counts for `FormalSystem/Metalogic/Algebraic/` and the archived
      sorry inventory under `FormalSystem/Boneyard/UltrafilterFrame/`, so the section's status
      claims are current rather than inherited from the report. *(completed: 0 sorries in
      Algebraic/, 3+4=7 in Boneyard/UltrafilterFrame/, matches report — claim-audit.md items 1, 7)*
- [x] Re-read `FormalSystem/Semantics/TaskFrame.lean` (the `Spherical` definition) and
      `FormalSystem/Semantics/Extension/Step.lean` (its sole consumption site) and confirm the
      identification of *Spherical* as a directed-intersection compactness condition consumed by
      the Step Lemma. *(completed: claim-audit.md items 8, 9, 10)*
- [x] Re-derive the Sahlqvist classification of TM's axioms against BdRV Definition 3.51 /
      Venema 2007 Definition 6.13 rather than copying the report's table. Pay particular
      attention to the DF row (forward discreteness classified Sahlqvist) and to CO, Z1, UC, UG,
      Sep (classified non-Sahlqvist). Mark each row VERIFIED or PROVISIONAL. *(completed:
      claim-audit.md item 11, re-derived against TM's own axiom list in `@sec:system` rather than
      the report's table; all rows VERIFIED)*
- [x] Classify every remaining candidate claim as VERIFIED / PROVISIONAL / EXCLUDED. At minimum,
      EXCLUDE: anything sourced only from `goldblatt_1989`; the conjecture that
      `box(x or Fx or Px)` is a global modality making `BAO(TM)` a discriminator variety; the
      historical narrative around Thomason 1972/1975, Goldblatt 1976 and Sambin-Vaccaro 1988.
      *(completed: claim-audit.md EXCLUDED list, 4 items)*
- [x] Write the audit as a working note at
      `specs/503_revise_representation_section_with_literature/notes/claim-audit.md` (create the
      directory) so phases 2-5 have one place to consult and phase 6 has something to check
      against. *(completed)*
- [x] Add BibTeX entries to `typst/bibliography.bib` for the sources the revision will cite.
      Expected set: Venema 2007 *Algebras and Coalgebras* (Handbook of Modal Logic ch. 6);
      Gehrke & Vosmaer *A View of Canonical Extension*; Goldblatt, Hodkinson & Venema 2003
      *Erdos Graphs Resolve Fine's Canonicity Problem*; de Rijke & Venema 1995 *A Sahlqvist
      Theorem for Boolean Algebras with Operators*; Venema 1993 *Derivation Rules as
      Anti-Axioms*; Fine 1975 *Some Connections Between Elementary and Modal Logic* (cited via
      Venema 2007 Theorem 6.17 for the statement, with the primary reference given). Confirm the
      keys are unique and follow the file's existing naming style. *(completed: 6 new keys —
      `venema2007algebrascoalgebras`, `gehrkevosmaer2011`, `goldblatt2003ghv`,
      `derijke1995sahlqvist`, `venema1993antiaxioms`, `fine1975elementarymodal` — no duplicates;
      `jonssontarski1951`/`1952` and `blackburnderijkevenema2001` already existed and are reused)*
- [x] Compile both `typst/FormalFoundations.typ` and `typst/BimodalReference.typ` to confirm the
      bibliography edit breaks neither. *(completed: both exit 0, only pre-existing font warnings)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The bibliography needs roughly six new entries and the Sahlqvist table has
roughly fourteen rows. Both are estimates from the research report, not counts. Confirm at
implementation time by enumerating exactly which sources the drafted prose actually cites (add
no entry that will go uncited) and by enumerating TM's axiom schemas from `@sec:system` in
`typst/FormalFoundations.typ` rather than from the report's table.

**Files to modify**:
- `typst/bibliography.bib` - add the new source entries
- `specs/503_revise_representation_section_with_literature/notes/claim-audit.md` - new working
  note (created, not modified)

**Verification**:
- `typst compile typst/FormalFoundations.typ` succeeds
- `typst compile typst/BimodalReference.typ` succeeds
- No duplicate BibTeX keys: every key added appears exactly once in `typst/bibliography.bib`
- The audit note classifies every claim the later phases intend to make

---

### Phase 2: Reframe the Opening — What "Representation" Would Mean [COMPLETED]

**Goal**: Replace the section's opening paragraphs, the three-route table and the route diagram
with an explicit statement of the four distinct things "representation theorem" has been naming,
plus the six-rung ladder and each rung's real status.

**Tasks**:
- [x] Rewrite the opening so it distinguishes (i) an algebraic representation `A >-> Em A`,
      (ii) a duality `BAO ~= DGF^op`, (iii) a task-frame representation, and (iv) a first-order
      (shift-set) axiomatization, and says which of the four the strong-completeness motivation
      actually requires. *(completed)*
- [x] Replace the three-route table with the six-rung ladder table: Lindenbaum-Tarski algebra
      (done in Lean, sorry-free); BAO for the full similarity type (not done); Jonsson-Tarski
      (off the shelf, Lean half done); full duality with descriptive general frames (off the
      shelf); dual Kripke reduct is a task frame (blocked at *Spherical*); per-class discrete /
      dense / Dedekind-complete (elementary and reachable for dense, out of first-order reach for
      `TM_f` and `TM_c`). *(completed; old three-route table and the paragraph that followed it,
      inside `== The Algebraic Layer`, removed as redundant with the new ladder)*
- [x] Update the `cetz` route diagram so its endpoint is no longer labelled "Jonsson-Tarski
      duality". Either relabel the endpoints to match the ladder or replace the diagram with a
      ladder rendering. Preserve the existing visual convention (solid arrows = completed, dashed
      = gap) and the green/orange/red status colouring. *(completed: replaced with a vertical
      5-box ladder diagram for rungs 1-5, rung 6 left to the table since its status splits by
      frame class; same solid/dashed and green/orange/red convention)*
- [x] Keep the existing footnote about the superseded unpublished draft, which remains accurate.
      *(completed, unchanged content, reattached to the new opening paragraph)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - the section opening, route table, and route diagram (currently
  circa lines 1151-1215)

**Verification**:
- `typst compile typst/FormalFoundations.typ` succeeds and the diagram renders without overflow
- The word "representation theorem" no longer appears in the section without a nearby
  disambiguation to one of the four senses
- The ladder table's six status entries each match the audit note's classification

---

### Phase 3: Rewrite The Algebraic Layer [COMPLETED]

**Goal**: Make the subsection factually correct about what the Lean layer contains, state the
three concrete gaps between it and a BAO for TM, and add the tense-algebra structure the section
currently omits.

**Tasks**:
- [x] Correct the `#definition("The Lindenbaum--Tarski Algebra")` block: `box` is an interior
      operator on the quotient; `#allpast` and `#allfuture` are not, under strict temporal
      semantics; and no `G` operator exists on the quotient at all. Cite the module that says so
      alongside the existing `#leansrc` pointers. *(completed)*
- [x] State the three gaps between `LindenbaumAlg` and a BAO for TM's similarity type: no `G`;
      no normality/additivity statement (which is exactly the hypothesis Jonsson-Tarski
      consumes); and one algebra for the base logic only, with no per-frame-class algebras.
      *(completed, as an `#items` list with a `Derives` #leansrc pointer)*
- [x] Name the smallest concrete next step: `sigmaQuot` is already present and involutive, so
      `gQuot := sigmaQuot . hQuot . sigmaQuot` is one definition away, leaving normality and
      additivity as the remaining obligations. Present it as the next step, not as done.
      *(completed; the composite is written in math notation, not backticked, since `gQuot` is
      not a live Lean identifier and would fail `typst-sync-check.sh` Check 1)*
- [x] Add the tense-algebra observation: TA (`phi -> G P phi`) and its TD-dual are exactly the
      tense-algebra axioms, and a tense algebra's diamonds are *complete* operators, preserving
      all existing joins. Attribute the statement to the literature and state the payoff (this is
      what makes the atom-structure duality work) without over-claiming that it has been used.
      *(completed, as a `#remark`, attributed to `@venema2007algebrascoalgebras`)*
- [x] Keep the ultrafilter/MCS correspondence claim, which is verified, and keep its `#leansrc`
      pointer. *(completed, unchanged)*
- [x] Fix the anachronistic attribution: the `eta(a) = {U : a in U}` ultrafilter-frame
      formulation is the modern restatement and should be attributed as such, with the theorem
      attributed to Jonsson & Tarski. Note in a footnote that the 1951/52 papers construct a
      *perfect extension* and contain no occurrence of "ultrafilter". *(completed, footnote citing
      `@blackburnderijkevenema2001` §5.3 for the modern notation)*

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Three gaps between the Lean layer and a BAO are asserted (no `G`, no
normality/additivity, base class only). Confirm each at implementation time by grepping
`FormalSystem/Metalogic/Algebraic/` for a `G`-operator definition on the quotient, for any
additivity or normality lemma, and for the `FrameClass` argument in `Derives`, rather than
relying on the research report's enumeration.

**Files to modify**:
- `typst/FormalFoundations.typ` - the `== The Algebraic Layer` subsection

**Verification**:
- `typst compile typst/FormalFoundations.typ` succeeds
- `scripts/typst-sync-check.sh` Check 1 passes for every backticked name added
- No sentence in the subsection contradicts `FormalSystem/Metalogic/Algebraic/README.md`
- The definition block's claims match `InteriorOperators.lean`

---

### Phase 4: New Subsection — Duality, Canonicity, and the Obstruction Diagnosed [COMPLETED]

**Goal**: Introduce the material that is the new centre of gravity of the section: what
Jonsson-Tarski leaves undone, what canonicity is, what the Goldblatt/Esakia duality gives, and
the diagnosis of *Spherical* as a compactness condition that cannot descend to the bare
ultrafilter frame.

**Tasks**:
- [x] State Jonsson-Tarski precisely and then state what it does not give: an embedding yields
      `V_L subset HSPCmK`, an inclusion, where completeness needs an equality. Replace the
      current "route is blocked" framing with "route is insufficient, and the missing ingredient
      is canonicity". *(completed)*
- [x] Introduce canonicity: a canonical variety, canonical formulas, Sahlqvist canonicity, and
      the fact that canonical implies complete. Include the axiom-by-axiom Sahlqvist
      classification re-derived in Phase 1, with the reading stated plainly: everything making TM
      a bimodal S5-plus-linear-tense logic is Sahlqvist and hence canonical; everything pinning
      down *which* linear order (CO, Z1, Sep) falls outside the fragment. *(completed; table
      condensed from claim-audit.md's 14-row classification to a 4-row grouped table, since the
      per-axiom detail is already in the audit note and the section's role is the status claim,
      not a literature survey)*
- [x] Introduce descriptive general frames (differentiated, tight, compact) and the
      Goldblatt/Esakia dual equivalence between `BAO_tau` and `DGF_tau`, noting that this gives
      soundness and strong completeness with respect to general frames off the shelf. *(completed)*
- [x] State the diagnosis: *Spherical* is a directed-intersection compactness condition, the
      corresponding statement is a theorem for every descriptive general frame, and it fails to
      transfer to TM's bare Kripke reduct because fibers are indexed by durations and no operator
      of TM's similarity type denotes the duration-indexed relation. The algebra therefore
      carries no information about it. *(completed, as the "Spherical, diagnosed" remark)*
- [x] Re-pose the section's Open Question: condition (c) — preservation under the passage to the
      ultrafilter frame — is the wrong requirement, because that passage discards the topology
      where compactness lives. The question should be asked over the descriptive general frame
      instead. *(completed)*
- [x] Present the two routes that follow — the topological route (aim at the descriptive general
      frame, accepting that the dual object is not a task frame) and the metric-operator route
      (put each duration-indexed relation into the similarity type) — and say that the second is
      the standard mechanism for exactly this obstruction, not a stylistic proposal. *(completed:
      Route T / Route M)*
- [x] Scope the existing "this is not a general frame" claim rather than deleting it: it is true
      over the world-state carrier, but the operators act on the two-dimensional point set where
      the admissible propositions form a proper subalgebra, which is precisely why the
      descriptive duality is the right target. *(completed, as a closing remark; the original
      claim at the current line ~428 outside `<sec:representation>` is left unedited, since it
      remains true as stated and the plan's Non-Goals restrict edits outside the section)*

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `typst/FormalFoundations.typ` - new subsection(s) between `== The Algebraic Layer` and
  `== The Shift-Set Target`, plus revision of the `== The Obstruction` material

**Verification**:
- `typst compile typst/FormalFoundations.typ` succeeds
- Every citation in the new subsection resolves against `typst/bibliography.bib` (no unresolved
  reference warnings in the compile output)
- The Sahlqvist table in the prose matches the Phase 1 audit note row for row
- No EXCLUDED claim from the audit note appears

---

### Phase 5: Rewrite The Shift-Set Target and What Is Foreclosed [NOT STARTED]

**Goal**: State honestly what the shift-set programme can and cannot deliver, per frame class,
and re-scope the project's declared gate accordingly.

**Tasks**:
- [ ] Keep the shift-set definition and the statement of the target, but qualify the
      first-order-axiomatizability claim: *Compositionality*, *Seriality* and *Limit* are
      expressible in the two-sorted signature; *Spherical* is second-order, since it quantifies
      over families of subsets of the carrier. The whole difficulty of the shift-set programme is
      the same axiom, for the same reason, as the whole difficulty of the algebraic programme.
- [ ] Add the two non-elementarity facts, stated as standard model theory rather than attributed
      to a corpus source: successor-Archimedean discreteness is not first-order (there are
      non-Archimedean discrete ordered abelian groups), and Dedekind completeness is not
      first-order. Draw the three consequences: it is why compactness fails there, why Fine's
      theorem supplies no canonicity there, and why the shift-set programme's first-order payoff
      cannot be had there.
- [ ] Say per class what the target amounts to: a genuine target for the base class; the best
      prospect for the dense class; and impossible as a first-order result for `TM_f` and `TM_c`,
      where any shift-set theorem could only characterize the class up to elementary equivalence.
- [ ] Re-scope the declared gate. As currently stated the gate authorizes the semantic-
      compactness programme only once a shift-set representation lands sorry-free in both
      directions for *the* class; for `TM_f` and `TM_c` that gate can never open. State the gate
      per class.
- [ ] Settle the disjoint-union aside: the complex algebra of a disjoint union is the product of
      the complex algebras, but the converse fails, so disjoint-union closure is available on the
      frame-to-algebra side and provably unavailable on the algebra-to-frame side.
- [ ] Revise the closing remark: keep the open question that survives (whether the algebraic and
      shift-set routes are the same theorem twice) and record the literature's suggestion that
      they are not, since one is a topological duality and the other a first-order definability
      claim, and they diverge precisely at *Spherical*. Keep the metric-operator discussion but
      cross-reference it to the diagnosis of Phase 4 rather than leaving it as a free-standing
      aside.
- [ ] Add a short closing inventory of what remains genuinely unsettled, so the section ends with
      an honest statement of the way forward rather than only an impasse.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Four frame axioms are asserted (*Compositionality*, *Seriality*, *Limit*,
*Spherical*), with exactly one second-order. Confirm at implementation time by reading the frame
axioms as stated in `@sec:system` of `typst/FormalFoundations.typ` and their Lean definitions in
`FormalSystem/Semantics/TaskFrame.lean`, checking the quantifier structure of each.

**Files to modify**:
- `typst/FormalFoundations.typ` - the `== The Shift-Set Target` subsection and the closing
  remarks of `== The Obstruction`

**Verification**:
- `typst compile typst/FormalFoundations.typ` succeeds
- The per-class statements are consistent with the existing non-compactness claims elsewhere in
  the document (the footnote at the current line 1094 region and the `@reynolds1992` citation)
- The gate statement is per class, with no remaining unqualified "the class" phrasing

---

### Phase 6: Integration, Cross-Reference Audit, and Full Verification [NOT STARTED]

**Goal**: Confirm the revised section is internally coherent, that the rest of the document still
refers to it accurately, and that all repository checks pass.

**Tasks**:
- [ ] Read the revised section end to end for flow and for redundancy introduced by phase-by-
      phase editing; remove duplicated statements of the same point.
- [ ] Re-read each site that cross-references `@sec:representation` (currently near lines 338,
      896, 1003, 1094) and confirm each referring sentence still describes content present in the
      revised section. Repair any that no longer do.
- [ ] Confirm every `#leansrc` pointer in the section names a live declaration in
      `FormalSystem/` outside `Boneyard/`.
- [ ] Run `scripts/typst-sync-check.sh` and resolve every reported violation. Add a whitelist
      entry only for a genuine non-Lean proper noun or exposition-only type signature, never to
      suppress a stale identifier.
- [ ] Compile `typst/FormalFoundations.typ` and `typst/BimodalReference.typ` and confirm both
      succeed with no unresolved-reference warnings.
- [ ] Cross-check the finished prose against the Phase 1 audit note: no EXCLUDED claim present,
      every PROVISIONAL claim hedged in the text.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- `typst/FormalFoundations.typ` - cross-reference repairs and coherence edits
- `typst/sync-check-whitelist.txt` - only if a genuine non-Lean noun was introduced

**Verification**:
- `scripts/typst-sync-check.sh` exits 0
- `typst compile typst/FormalFoundations.typ` succeeds
- `typst compile typst/BimodalReference.typ` succeeds
- Every `@sec:representation` referring site verified by reading

## Testing & Validation

- [ ] `typst compile typst/FormalFoundations.typ` succeeds after every phase
- [ ] `typst compile typst/BimodalReference.typ` succeeds after the bibliography change and at
      the end
- [ ] `scripts/typst-sync-check.sh` exits 0 at the end
- [ ] No BibTeX key added to `typst/bibliography.bib` is duplicated or uncited
- [ ] Every `#leansrc` pointer and backticked Lean name in the revised section resolves against
      live `FormalSystem/` source (not `Boneyard/`)
- [ ] The revised section contains no claim classified EXCLUDED in the Phase 1 audit note
- [ ] Every claim classified PROVISIONAL appears hedged, never as flat assertion
- [ ] Each of the four cross-referencing sites elsewhere in the document still describes content
      that exists in the revised section

## Artifacts & Outputs

- `typst/FormalFoundations.typ` - revised `<sec:representation>` (currently lines 1151-1318) plus
  any cross-reference repairs
- `typst/bibliography.bib` - new BibTeX entries for the cited literature
- `specs/503_revise_representation_section_with_literature/notes/claim-audit.md` - working audit
  note classifying every candidate claim VERIFIED / PROVISIONAL / EXCLUDED
- `typst/sync-check-whitelist.txt` - only if a genuine non-Lean noun is introduced
- `specs/503_revise_representation_section_with_literature/summaries/01_{slug}-summary.md` -
  implementation summary

## Rollback/Contingency

All changes are confined to `typst/FormalFoundations.typ`, `typst/bibliography.bib`, and
optionally `typst/sync-check-whitelist.txt`, all tracked in git with no build artifacts or
generated files involved. Each phase commits separately, so any single phase can be reverted with
`git revert` of its commit without disturbing the others. If the restructuring proves unworkable
mid-way, reverting phases 2-6 restores the original section while leaving the Phase 1
bibliography additions in place (they are purely additive and harmless). Recovering the original
section text alone is `git show <pre-task-sha>:typst/FormalFoundations.typ`. Take a snapshot with
`bash .claude/scripts/git-snapshot.sh 503` before any destructive git operation.
