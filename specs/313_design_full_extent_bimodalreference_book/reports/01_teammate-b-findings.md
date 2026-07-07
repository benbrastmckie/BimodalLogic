# Teammate B Findings: Alternatives, Prior Art, and the Counterfactual/Logos Dimension

**Task**: 313 - Design the full extent of the BimodalReference book
**Teammate**: B (Alternative Approaches and Prior Art)
**Date**: 2026-07-06
**Sources**: `/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex`,
`/home/benjamin/Projects/Logos/Theory/typst/manual/` (LogosManual.typ + chapters + template + notation),
`/home/benjamin/Projects/Logos/Theory/Logos/Foundations/` (Lean),
`/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/typst/` (current BimodalReference),
prior-art literature (from training knowledge, flagged below).

---

## Key Findings

### F1. The counterfactual chapter does not need to be written from scratch — it exists in two mature, mutually consistent forms

The "next chapter adding constitutive structure" is already drafted twice:

1. **The paper** (`counterfactual_worlds.tex`, 2277 lines) contains the complete mathematical
   content: imposition defined away (§2.2, lines 624-679), task-space construction of possible
   worlds (§3, lines 686-836), bilateral propositions (§3.3, lines 843-864), the full semantics
   and three-layer logic **CL ⊂ CML ⊂ CTL** (§4, lines 872-1076), twelve interpreted
   countermodels (§4.3, lines 1082-1211), and the Vlach store/recall analysis of tensed
   counterfactuals (§5, lines 1220-1370). An Appendix (lines 1495+) derives Fine's imposition
   constraints (Inclusion/Actuality/Incorporation/Completeness) and soundness elements.

2. **The Logos manual** (`Logos/Theory/typst/manual/chapters/`) has already *transcribed this
   into Typst* with theorem environments and Lean cross-references:
   - `02-constitutive.typ` (1623 lines): task frame as complete lattice + duration group +
     duration-parameterized task relation (lines 236-295), state modality definitions with
     possible/maximal/world/necessary states *defined* rather than primitive (lines 328-422),
     Parthood/Containment/Maximal constraints (lines 428-461), dynamical model with
     verifier/falsifier functions (lines 467-533).
   - `03-dynamics.typ` (475 lines): the exact operator stack the book arc needs — H/G tense,
     Since/Until, **store/recall (Vlach) operators** (lines 325-357), counterfactual conditional
     via alternative worlds/maximal compatible parts (lines 359-382), stability operator
     (lines 384-399), derived □/◇ with S5 remark (lines 405-425), bivalence-for-world-histories
     theorem (lines 449-456).
   - `07-proof-theory.typ` (127 lines): CL axioms C1-C7 + closure rule R1 in Typst form
     (lines 53-77), perpetuity principles P1-P6 (lines 85-94), derived S5 (T, M1-M5,
     lines 100-114), soundness statement + open completeness remark (lines 116-125).

   The Lean grounding for these chapters lives in
   `Logos/Theory/Logos/Foundations/{Constitutive,Dynamical,Combined}/` (Frame.lean,
   Semantics.lean, Syntax.lean, Context.lean, ConstitutiveTense.lean), referenced from the Typst
   via `#leansrc(...)` calls (e.g., `02-constitutive.typ:295,461,533`; `03-dynamics.typ:99,357,475`).

**Implication**: the BimodalReference next chapter is an *adaptation and re-staging* job
(propositional restriction + narrative repositioning as "the next dimension after the bimodal
core"), not new mathematical writing.

### F2. What the constitutive/counterfactual chapter needs, precisely staged

The clean conceptual delta from the bimodal TM core to the counterfactual layer is a
**replacement of one primitive by structure**, which is exactly the arc-(4) story:

| Bimodal core (current BimodalReference) | Constitutive extension (next chapter) |
|---|---|
| Primitive type of world-states `W` | Complete lattice of states ⟨S, ⊑⟩; world-states *defined* as maximal possible states (`02-constitutive.typ:363-366`; paper lines 644-653) |
| Task relation on world-states, duration-indexed | Task relation on *all* states; Parthood/Containment/Maximal interaction constraints (paper lines 750-807; `02-constitutive.typ:428-461`) |
| Possibility built into `W` | Possible states *defined* via the task relation (paper: connectedness, line 731; Logos: `s ⇒₀ s`, `02-constitutive.typ:333-337` — a small divergence to reconcile, see F5) |
| Valuation: atoms → sets of world-states | Bilateral propositions ⟨V,F⟩: closed, exclusive, exhaustive verifier/falsifier sets (paper lines 855-864) |
| □ primitive (quantify over histories) | □A := ⊤ □→ A **derived** from the counterfactual (paper line 1014); S5 derived, not imposed (paper lines 1046-1048; `03-dynamics.typ:423-425`) |
| Vlach ↑/↓ for cross-trace/time reference | Same operators reused to regiment tensed counterfactuals: forward (n), temporally-specific (n′, n″), backwards, backtracking (paper lines 1233-1341) |

Key theorems/definitions the chapter must contain, in dependency order:
1. State space, fusion, null/full state (paper lines 627-633).
2. Task space + Restricted Reflexivity, Parthood (L/R), Nullity, Maximality (paper lines 737-807).
3. Derived: Possibility, Nonempty, World Space (Fine's primitives now theorems — paper's
   Appendix items, lines 762, 779, 797).
4. Compatible part, maximal compatible parts, **imposition defined** (paper lines 656-663) +
   derivation of Fine's four constraints (Appendix, lines 1663+).
5. World histories/possible worlds as maximal possible evolutions; Containment equivalence
   (paper lines 819-832, 1435-1455; `03-dynamics.typ:103-122` `thm-containment`).
6. Bilateral propositions + exact inclusive semantics ⊗/⊕ clauses (paper lines 914-936).
7. Truth clauses incl. □→ in both imposition form and basic mereological form (paper lines
   938-956) — presenting *both* forms is pedagogically valuable and already the paper's practice.
8. Logics CL → CML → CTL with the derivation ladder D1-D11, and the twelve countermodels
   #1-#12 (paper lines 1089-1104) — countermodels are the book's "deterministically checkable"
   hook: each is ModelChecker-reproducible (paper line 1106 note: `"disjoint" = True`).
9. Extensions/limitations section: extensional-antecedent restriction and why iterated
   modalities need ⊤/⊥ (paper lines 1012-1014), events/processes, continuous time
   (paper lines 1399-1487) — these make honest "future work" boundaries.

### F3. Prior art in reference-book design for combined/extended temporal logics

*(From training knowledge; not re-verified online this session — confidence medium, titles/structure well-established.)*

1. **Gabbay, Kurucz, Wolter, Zakharyaschev, *Many-Dimensional Modal Logics: Theory and
   Applications* (2003)** is the canonical reference for exactly TM's shape: combinations like
   PTL × S5 (temporal-modal products). Two adaptable devices:
   - The **fusion vs. product distinction** as an organizing narrative: TM is presented most
     honestly as (approximately) a *product* — commuting modalities, perpetuity principles as
     the interaction axioms — which explains both the expressive gain and the metalogic cost.
   - **Decidability/complexity tables per fragment**, with undecidability frontiers marked.
     A "fragment lattice" figure (which operator subsets stay decidable) would directly serve
     book-arc item (1): decidable fragments for automated reasoning vs. proof-theoretic training.
2. **Demri, Goranko, Lange, *Temporal Logics in Computer Science* (2016)** models the
   **operator-by-operator build-up**: BT → LTL(F) → LTL(U/S) → branching. Its recurring
   "expressiveness comparison" sections (e.g., U strictly more expressive than F/G; Kamp's
   theorem for FO-completeness of U/S over Dedekind-complete orders) suggest a comparison table:
   *vanilla LTL → +S5 □ → +Vlach ↑/↓ → +□→*, each row citing what becomes expressible
   (Kamp's theorem is already implicated in the Lean Kamp work under
   `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`).
3. **Hybrid logic literature** is the right prior art for the Vlach operators:
   - Vlach 1973 ("Now" and "Then"), Kamp 1971 (formal "now"), and Cresswell,
     *Entities and Indices* (1990) — storage operators progressively approach full explicit
     quantification over times.
   - Hybrid logic's ↓ binder and @ operator (Blackburn's "hybrid logic manifesto" 2000;
     Areces & ten Cate, Handbook of Modal Logic ch. 14) are the modern systematization; the
     known cost (↓ generally breaks decidability, while bounded/@-only fragments stay decidable)
     gives the book a principled way to discuss Vlach-operator fragments in the decidability
     chapter. Presenting ↑ⁱ/↓ⁱ as "hybrid-style binders over the time coordinate, with a fixed
     finite register vector" both situates the design in known territory and explains why the
     bounded-register version is tamer than full hybrid binding.
4. **Baier & Katoen, *Principles of Model Checking* (2008)** for the automated-reasoning
   framing: LTL syntax → semantics → fragments → automata → complexity, always with the
   "checkable artifact" (automaton/counterexample) as the deliverable. The analogue here:
   Lean proof certificates on the proof-theory side, ModelChecker countermodels on the semantic
   side — the "dual verification" framing that `LogosManual` chapter 01 already articulates
   (`01-introduction.typ:69-95`, "Proof Certificates" / "Counterexamples" / "Soundness
   Guarantees") and which the BimodalReference book can adopt wholesale as its arc-(1) chapter.

### F4. Typst infrastructure: LogosManual template is a strict superset — port, don't fork

`BimodalLogic/Theories/Bimodal/typst/template.typ` (74 lines) is an early subset of
`Logos/Theory/typst/manual/template.typ` (254 lines). Same thmbox\@0.3.0 base, same AMS
no-background styles. The Logos template adds, all directly reusable:

- `proposition`, `corollary`, `example`, `notation-env` environments (`template.typ:54-60`) —
  the Bimodal template lacks all four; `example` is essential for the paper's interpreted
  countermodels (#1-#12) and `notation-env` for register conventions.
- `chapter-header(description, dependencies, connections)` (`template.typ:111-130`) — gives
  each chapter a dependency preamble; ideal for the book's layered arc (each chapter states
  which operator/structure layer it assumes).
- `principles`/`principle`/`pr()` auto-labeled axiom lists (`template.typ:183-216`) — exactly
  right for C1-C7, M1-M5, TK/TD/GP/TR/LN/DF/NF/FN/UF axiom blocks with stable cross-references.
- `leansrc(module, name)` / `leanref(name)` (`template.typ:93-96`) — the Lean-anchor idiom used
  throughout LogosManual chapters; BimodalReference currently hand-rolls Lean identifier `#let`s
  in `notation/bimodal-notation.typ:88-99`. Adopting `leansrc` composes with BimodalLogic's
  own **SYNC-MAP.md discipline** (`Theories/Bimodal/typst/SYNC-MAP.md`, task 312), which is the
  more rigorous of the two conventions (claim-level verification against a stamped commit).
  Recommendation: port `leansrc` for presentation, keep SYNC-MAP for verification, and extend
  SYNC-MAP to any new chapter that cites Lean (Logos Lean modules would be cited as
  external-project references until/unless the counterfactual layer is formalized in this repo).
- `items`/`item` styled lists, `doc-entry`, fletcher `extension-node` dependency-diagram
  helpers (`template.typ:136-171, 219-250`) — the extension-dependency diagram in
  `01-introduction.typ:111-241` is a ready-made model for a "book map" figure showing
  bimodal core → constitutive → counterfactual → full Logos.
- Heading `supplement: "Chapter"` + custom `ref` show rule (`LogosManual.typ:40-51`) so
  `@sec-...` renders "Chapter N" — BimodalReference lacks this.
- A `bibliography.bib` + `#bibliography` block (`LogosManual.typ:195-197`) — BimodalReference
  currently has *no* bibliography apparatus; a book-length reference needs one (the prior-art
  comparisons in F3 all need citations).

**Notation alignment**: mostly compatible, three collision/divergence points to resolve
deliberately:
1. `Dur = $cal(D)$` is defined in both `bimodal-notation.typ:37` and Logos
   `basic-notation.typ:94` (harmless, same meaning) — but Bimodal's task arrow is
   `taskto(x) = $arrow.r.double.long_#x$` (`bimodal-notation.typ:42`) while Logos uses a
   `taskrel` symbol with duration subscript (`02-constitutive.typ:252,257`). Pick one glyph
   family for the book.
2. Bimodal uses `H/G/P/F` + `triangle.stroked.t/b` for always/sometimes
   (`bimodal-notation.typ:18-26`); Logos `03-dynamics.typ:75-76` uses the same triangles —
   already aligned.
3. Logos `logos-notation.typ` adds the bilattice/state-space layer (`stateT/F/B/N`, `infmeet`,
   `fusion`, `parthood`, `compat`, `maxcompat`, `nullstate`, `fullstate`) that the new
   constitutive chapter needs; import it (or copy the needed subset into a new
   `notation/constitutive-notation.typ` beside `bimodal-notation.typ`, mirroring the existing
   `shared-notation.typ` split).

### F5. Divergences between the paper and the Logos manual the chapter must reconcile

Whoever writes the chapter must choose a presentation on four points where the two sources differ:

1. **Duration-parameterized vs. bare task relation.** Paper: `s → t` unparameterized, times as ℤ
   (lines 722-731, 819-822). Logos/Bimodal Lean: `s ⇒_d t` with a quantity group and
   compositionality (`02-constitutive.typ:248-258`). Since BimodalReference's semantics chapter
   already presents the duration-indexed relation (`chapters/02-semantics.typ`, Task Frames),
   the book should use the parameterized form and note the paper's simplification.
2. **Definition of possible state.** Paper: connected-to-something (line 731, allowing
   "transient" states, lines 740-743). Logos: `s ⇒₀ s` (`02-constitutive.typ:333-337`).
   These coincide given Restricted Reflexivity but differ in edge cases; the Lean source is
   the ground truth for the book (SYNC-MAP discipline).
3. **Propositional vs. first-order.** The paper and BimodalReference are propositional; the
   Logos manual is first-order with lambda binding (`02-constitutive.typ:36-234`,
   `03-dynamics.typ:200-256`). Recommendation: the BimodalReference book stays propositional
   (matching its Lean formalization) and points to LogosManual for the FOL generalization —
   this keeps the book arc clean: bimodal core → +constitutive/counterfactual (still
   propositional) → full Logos (FOL, plugins) as the "vastly expanding" horizon of arc (3).
4. **Until/Since primitives.** BimodalReference's TM is axiomatized Burgess-Xu over
   Until/Since (`BimodalReference.typ:116`); the paper's CTL uses only H/G (plus defined
   P/F/always). The Logos manual has both H/G and Since/Until (`03-dynamics.typ:301-323`).
   The new chapter should state CTL over the book's existing Until/Since basis (H/G being
   derived in `chapters/01-syntax.typ`), noting the paper's weaker basis.

---

## Recommended Approach

**Stage the counterfactual dimension as two chapters adapted from existing sources, plus
book-level infrastructure ported from LogosManual:**

1. **Chapter "Constitutive Structure" (new, adapted from `02-constitutive.typ` §§Task Frame →
   Task Relation Constraints + paper §§2.2-3.2).** Motivation via Totality/Restriction and the
   Nixon example (paper §1 — the book's best-motivated entry point); state lattice; task
   relation over all states; possible/world states derived; imposition defined; Fine's
   constraints as theorems; worlds as maximal possible evolutions (Containment). End with a
   comparison figure: "the bimodal frame of Part I is the world-state shadow of this structure."
2. **Chapter "Counterfactual Logic" (new, adapted from paper §4-5 + `03-dynamics.typ`
   §§Truth Conditions → Consequence + `07-proof-theory.typ` §§Counterfactual Logic →
   Soundness).** Bilateral propositions; exact semantics; □→ clause (imposition + basic form);
   CL/CML/CTL axiom ladder using `principle` lists; **□A := ⊤ □→ A and the S5 derivation as the
   chapter's headline theorem** (metaphysical modality *derived*, completing arc (4));
   perpetuity re-derivation; countermodels #1-#12 as `example` environments with a
   ModelChecker-reproducibility note; Vlach-operator regimentation of forward/backward/
   backtracking counterfactuals (n, n′, n″, d/u/l examples) — explicitly presented as *reusing
   the Part-I Vlach operators*, which is the cross-referencing payoff of arc (2).
3. **Presentation devices from prior art (arc items 1-3):**
   - An **expressiveness ladder table** (vanilla LTL → +S5 → +Vlach → +□→), each row with a
     natural-language claim only expressible at that level (Demri-Goranko-Lange style).
   - A **fragment/decidability lattice figure** in the metalogic/automation part
     (Gabbay-et-al. style), marking which fragments the Lean decidability procedure covers.
   - Vlach ops framed via hybrid-logic binders (bounded register vector ⇒ tameness), with
     Kamp/Vlach/Cresswell/Blackburn citations in a new bibliography.
   - A "dual verification" chapter or section (proof certificates vs. countermodels) adapted
     from `01-introduction.typ:69-95` — this is the arc-(1) framing chapter.
4. **Infrastructure tasks (small, mechanical):** port `proposition/corollary/example/
   notation-env`, `chapter-header`, `principles/principle/pr`, `items`, `leansrc/leanref`,
   Chapter-supplement show rule, and fletcher helpers from
   `Logos/Theory/typst/manual/template.typ` into `Theories/Bimodal/typst/template.typ`;
   add `bibliography.bib`; add `notation/constitutive-notation.typ`; resolve the three notation
   divergences in F4; extend SYNC-MAP.md to new chapters.

---

## Evidence / Examples

- Vlach store/recall in the paper: syntax and clauses at `counterfactual_worlds.tex:1251-1270`;
  identical (modulo notation) Typst clauses at `03-dynamics.typ:325-344`; tensed-counterfactual
  example `↑¹P(φ □→ ↓¹ψ)` at `03-dynamics.typ:346-355`; backtracking regimentations d/u/l at
  `counterfactual_worlds.tex:1324-1328`.
- Metaphysical modality derived: `□A := ⊤ □→ A` at `counterfactual_worlds.tex:1014` and
  `03-dynamics.typ:70`; S5 consequence at `counterfactual_worlds.tex:1046-1048` and
  `07-proof-theory.typ:111-114`.
- Imposition defined (the anti-primitive move): `counterfactual_worlds.tex:656-663`; Typst
  remark form at `03-dynamics.typ:379-382`.
- Template superset relation: compare `Theories/Bimodal/typst/template.typ:39-74` with
  `Logos/Theory/typst/manual/template.typ:17-216` (identical styles through `remark`, then
  Logos-only additions).
- Existing BimodalReference chapter map (what the new chapters slot after):
  `BimodalReference.typ:142-148` (00-introduction … 06-notes).
- Lean grounding for the counterfactual layer (external repo):
  `Logos/Theory/Logos/Foundations/Constitutive/{Frame,Semantics,Syntax}.lean`,
  `Foundations/Dynamical/{Context,Semantics,Syntax}.lean`, `Foundations/Combined/ConstitutiveTense.lean`.
- Open problem to state honestly: completeness for the counterfactual layer is open
  (`07-proof-theory.typ:122-125`); soundness is claimed with Appendix elements
  (`counterfactual_worlds.tex:1847+`).

## Risks / Cautions

- The paper's antecedent restriction (extensional φ only, `counterfactual_worlds.tex:886-899`)
  must be carried into the chapter's grammar or the axiom schemata are ill-formed; the paper
  itself flags that ModelChecker implements an unrestricted extension (line 1013 footnote) —
  do not silently import that extension.
- LogosManual chapters 04-06/08 (epistemic, normative, spatial, agential) are stubs or
  out-of-scope for this book; only 02, 03, 07 (and the 01 dual-verification framing) are
  reuse-ready.
- Prior-art specifics in F3 are from training knowledge (titles, chapter organization,
  standard results); verify exact page/chapter numbers before citing in print.

## Confidence Level

- F1, F2, F4, F5 (file-based): **high** — all claims are read directly from the cited files this session.
- F3 (external prior art): **medium** — well-established literature, but not re-verified online this session; treat citation details as to-be-confirmed.
