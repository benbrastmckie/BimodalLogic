# Research Report: Prior Art and Alternative Expository Models for `FormalFoundations.typ`

**Task**: 444 — overhaul `typst/FormalFoundations.typ` for Dana Scott as reader
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
**Scope**: prior-art/exemplar expositions, alternative document architectures, reusable in-repo
material, representation-theorem direction, Typst mechanics. Research only — no source edits made.

---

## Key Findings

1. **The repo's own Lean architecture is already named after its prior art.** The dense/discrete
   split in `BXCanonical/Completeness.lean` uses `countermodel_discrete_reynolds_v2`
   (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`) — a direct implementation of the
   step-by-step canonical-model technique from Gabbay–Hodkinson–Reynolds, *Temporal Logic:
   Mathematical Foundations and Computational Aspects* (1994) and Reynolds (1992), **both already
   in `typst/bibliography.bib`** (`gabbayhodkinsonreynolds1994`, `reynolds1992`). This is the
   single strongest "cite the source of your own method" opportunity in the document and is
   currently unexploited — §6 of the current draft names the Lean construction without crediting
   the technique's ancestry.
2. **Dana Scott is not a generic expert reader here — he is cited inside the companion paper as
   the historical source for `Next`/`Previous`** (`possible_worlds.tex:1308`: "Citing Dana Scott,
   Prior [1967, p.66] introduces operators for *tomorrow* and *yesterday*") and is thanked by name
   in the acknowledgments (`possible_worlds.tex:395`). The rewrite should exploit this: Scott is
   present in the paper's own genealogy, and §1.1's Next/Previous material
   (`FormalFoundations.typ` "Over discrete frames... additionally defines Next/Previous") is a
   natural, low-cost place for a one-line personal anchor — not required, but available and apt
   for a document addressed to him specifically.
3. **BDRV and GHR are already cited; Goldblatt, Chagrov–Zakharyaschev, Jónsson–Tarski, Stone, and
   Scott's own papers are not.** `bibliography.bib` currently has 46 entries including
   `blackburnderijkevenema2001` and `gabbayhodkinsonreynolds1994`, but no Goldblatt *Logics of
   Time and Computation*, no Chagrov–Zakharyaschev, no Jónsson–Tarski (1951/52), no Stone (1936),
   no Scott 1970 "Advice on Modal Logic." Any of these the rewrite wants to cite must be added to
   `typst/bibliography.bib` first (shared bib file, `ieee` style per `BimodalReference.typ:230`).
4. **The representation-theorem "target with a stated obstruction" is already fully diagnosed in
   the repo** (confirmed independently against task 443's own research, `specs/443_.../reports/
   01_formal-foundations-research.md` §0): the algebraic layer (`Metalogic/Algebraic/`,
   Lindenbaum quotient → Boolean algebra → ultrafilter–MCS bijection) is live and sorry-free;
   the Jónsson–Tarski completion of that path (`TenseS5Algebra`, `UltrafilterFrame` — the R_G/R_H/
   R_□ accessibility relations on ultrafilters) is archived in `FormalSystem/Boneyard/
   UltrafilterFrame/` with a named, unstarted revival task (task 125) in its own README; the
   shift-set route is a design document with no Lean code. The document's §7 should present
   exactly this three-tier structure (proved / archived-with-named-obstruction / designed-only)
   rather than a flat list.
5. **Kamp's theorem is already given a textbook-quality treatment in `typst/chapters/
   p3-vlach-blstar.typ`** ("Kamp's Theorem, Correctly Scoped" and "The Formalization Frontier"
   sections) that is *directly reusable* for Dana's third question (metric tense operators /
   representation theorem). It states the theorem with both scope conditions (strict operators,
   Dedekind-complete flow) explicit, corrects the standard miscitation (1971 vs. 1968 dissertation
   vs. Rabinovich's model-theoretic proof), and gives the exact Lean status
   (`kampPriorExpressiveCompleteness`, target only, `Metalogic/WeakCanonical/Kamp/`). This should
   be adapted into `FormalFoundations.typ` §7 rather than written from scratch.
6. **`p2-frame-classes.typ`'s "Duration Groups and the Four Classes" section is Scott-grade
   exposition already sitting in the repo** — worked validity arguments for the density schema and
   the discreteness/Prior-Z1 layer, the $\mathbb{Z} \times_{\text{lex}} \mathbb{Z}$
   non-density/non-discreteness witness, and the precise statement of the unfillable gap
   ($\mathrm{Th}(\mathbb{Z}) \cap \mathrm{Th}(\mathbb{R})$ has no `FrameClass` constructor). This
   is exactly the kind of "necessity of the temporal axioms" material Dana's email asks about
   (density/discreteness necessitated once the frame class is fixed) and can be compressed and
   ported rather than re-derived.

---

## Recommended Approach

### On document architecture

Propose **semantics-first, single-thread, with a results-ledger table doing the work of a proofs
appendix** — not a literal appendix. Concretely:

- **Reject "axiomatics-first."** Scott's own methodological signature (neighborhood semantics,
  domain theory) is to distrust axioms that aren't yet known to correspond to anything, and the
  email itself is *semantics-first* in its own reasoning — Dana is asked to weigh in on frame
  definitions (T1 topology, total-history extension) before axioms are mentioned. Opening with
  §1's language/axioms before task-frame semantics (current structure) inverts the order the
  reader will find most natural and the order the source paper itself uses
  (`possible_worlds.tex` reaches the axiomatization only after building frames, task relations,
  and the extension/occurrence lemmas). **Recommendation: semantics (frames, task relation,
  world-history extension) before or tightly interleaved with the axioms that correspond to it**,
  contrary to the current file's language-then-frames-then-axioms order.
- **Reject "algebra-first."** The algebraic route is real but partial (finding 4 above); leading
  with it would overpromise relative to what §7 can actually claim, and Scott would notice the
  overreach immediately. Algebra belongs in the closing "way forward" section, framed as *one of
  two* live representation routes (the other being the shift-set/direct-semantic route), not as
  the document's spine.
- **Single-thread over results-then-proofs-appendix.** The existing three "pain point" sections
  (contingency of temporal axioms, split-validity incompleteness, axiomatizing the strongest
  objective modality) are themselves proof sketches embedded in exposition — moving proofs to an
  appendix would sever exactly the pain-point-to-proof connection that makes each section land.
  A ~10-page report for an expert reader who will read linearly does not need the
  results/proofs separation a longer monograph would.
- **What changes**: order Sections so the arc matches Dana's three questions in the order his
  email raises them modulo one swap — (1) semantics/frame-definition mechanics answering his
  T1/extension/occurrence question, (2) the contingency-of-temporal-axioms pain point answering
  his second question, (3) completeness+decidability status, (4) the representation-theorem way
  forward answering his third question. This reads as a direct reply to the email rather than a
  generic system report that happens to share a topic.

### On the representation-theorem section (§7)

State the three-tier structure from finding 4 as a compact table (proved / archived-with-named-
obstruction / designed-only), then make the case — using the Kamp material already in
`p3-vlach-blstar.typ` — that **Dana's own suspicion is likely correct**: Since/Until alone will
not suffice for a representation theorem in the Jónsson–Tarski or algebraic-duality sense, because
Kamp expressive completeness (the closest existing "this basis suffices" result) is scoped to
Dedekind-complete flows and to the *first-order* theory of linear order — a genuinely different
target from a *representation* theorem, which needs a duality (algebra ≅ points-of-a-space), not
an expressiveness result. Recommend the document say explicitly that metric/Since-Until-plus
operators are a plausible next step precisely *because* the current basis is shown adequate for
expressiveness over one frame class but the duality direction is untouched — matching Dana's own
hedge in the email ("I suspect it may be necessary to include more than this").

### On prose register

Emulate BDRV's and Goldblatt's convention of a **boxed theorem stating scope conditions in the
theorem head, not buried in prose** (the existing `p3-vlach-blstar.typ` Kamp theorem already does
this correctly: "Over Dedekind-complete flows... in their strict readings..."). The current
`FormalFoundations.typ` mixes this — some claims are stated as flowing prose with the scope
condition mid-sentence (e.g., the extended-language paragraph). Standardize on box-with-explicit-
hypotheses for every load-bearing claim, prose only for motivation/transition.

---

## Evidence / Examples

### Exemplar expositions and their structural lessons

| Source | What it does structurally | Where it's directly reusable here |
|---|---|---|
| Blackburn–de Rijke–Venema, *Modal Logic* (2001), Ch. 4–5 | Canonical-model completeness stated as a template (canonical MCS → canonical frame → truth lemma), then filtration as a *separate*, reusable machine for FMP/decidability — never conflated with completeness. Ch. 5 gives BAO algebraic semantics as the dual picture. | Already cited (`blackburnderijkevenema2001`). The completeness/decidability separation this text insists on is exactly what task 443's report flags as a discipline the current draft must maintain (BX-system vs. TM-family, §1 of 443's report) — cite BDRV as the methodological warrant for keeping that split sharp. |
| Gabbay–Hodkinson–Reynolds, *Temporal Logic: Mathematical Foundations…* Vol. 1 (1994) | Step-by-step ("labelled") construction of models for linear-time completeness, staged per flow class (discrete, dense, general linear). | Already cited (`gabbayhodkinsonreynolds1994`). This is the direct ancestor of `ReynoldsBridge.lean`'s discrete-branch construction (finding 1) — name it explicitly in §6 rather than describing the construction as if it were sui generis. |
| Chagrov–Zakharyaschev, *Modal Logic* (1997) | Systematic treatment of non-finitely-axiomatizable and Halldén-incomplete logics via canonical/general frames; the standard reference for the taxonomy task 443's report insists on (§4: "TM is semantically incomplete, not Halldén-incomplete"). | **Not currently in `bibliography.bib` — add if cited.** Best fit for grounding the split-validity pain-point section's taxonomy claim in a citable authority rather than asserting it de novo. |
| Goldblatt, *Logics of Time and Computation* (CSLI, 2nd ed. 1992) | Stages canonical-model completeness explicitly per flow class (ℕ, ℤ, ℚ, ℝ) with a dedicated chapter on Dedekind-completeness's special role — structurally the closest published analogue to this repo's `FrameClass` (`Base`/`Dense`/`Discrete`/`Dedekind`) hierarchy. | **Not currently in `bibliography.bib` — add if cited.** Strongest single external analogue for §2's "load-bearing theorems by frame class" table; citing it tells Dana the frame-class stratification is a recognized pattern, not an ad hoc device. |
| Jónsson–Tarski, "Boolean Algebras with Operators I/II" (1951/1952) | Canonical extension of a BAO is the point-set dual of its ultrafilter space; the representation theorem is exactly "every BAO embeds in the complex algebra of its canonical frame." | **Not currently in `bibliography.bib` — add if cited.** This is the precise theorem the archived `Boneyard/UltrafilterFrame/` work targets (`TenseS5Algebra`'s Lindenbaum instance + `UltrafilterFrame`'s R_G/R_H/R_□ relations *are* the canonical-frame construction for this BAO). Citing it lets §7 state precisely which theorem the archived work is *for*, rather than gesturing at "algebraic representation." |
| Thomason, "Combinations of Tense and Modality" (*Handbook of Philosophical Logic* II, 1984) | Surveys general-frame duality for combined tense-modal systems specifically — the closest published treatment of *this system's* representation-theorem question (bimodal tense+alethic), as opposed to monomodal BAO duality. | **Already cited** (`thomason1984`) but currently unused for this purpose per the grep of `FormalFoundations.typ` — redirect its citation toward §7 rather than (or in addition to) wherever it is currently used, since it is the one source in the bib that is about *this exact* combination. |
| Kamp 1968 dissertation / Rabinovich 2014 (model-theoretic proof) | Expressive completeness of Until/Since for FO(<), strict readings, Dedekind-complete flows only. | Already fully worked up in `typst/chapters/p3-vlach-blstar.typ:108-128` ("Kamp's Theorem, Correctly Scoped", "The Formalization Frontier") — port directly into `FormalFoundations.typ` §7, compressed, rather than re-deriving. |
| Dana Scott, "Advice on Modal Logic" (1970); Scott–Montague neighborhood semantics | Minimal/neighborhood models generalize Kripke frames precisely to separate "which operators are S5" from "which operator is metaphysical necessity" — structurally the same distinction the current draft's §5 (axiomatizing the strongest objective modality) is making when it shows S5-hood alone doesn't pick out `□` (cf. the `Stability` operator footnote already surfaced in task 443's report §3.5, `possible_worlds.tex:1080-1082`). | **Not currently in `bibliography.bib` — add if cited.** This is the one source in this list chosen specifically *for the reader*: Scott's own neighborhood-semantics framing is the most natural external validation for §5's central move, and citing his own methodological precedent back at him is rhetorically strong for this specific audience. Use with restraint — one citation, not a detour into neighborhood semantics as a competing framework. |

### Alternative document architectures considered

1. **Semantics-first, single-thread, results-ledger table** (recommended above).
2. **Axiomatics-first** (current draft's structure: language → axioms → frames → pain points →
   completeness → representation). Rejected: inverts the paper's own order and Dana's own
   reasoning order in the email; also front-loads notation before motivation, which is part of
   why the current draft reads as having "no narrative arc" (task description's own diagnosis).
3. **Algebra-first** (open with the Lindenbaum/ultrafilter/BAO picture, derive completeness as a
   corollary, close with the syntactic BX-canonical-model construction as "the concrete case").
   Rejected as primary structure (overpromises relative to finding 4's three-tier status) but
   **worth one clearly-marked subsection** in §7 precisely because it is the more Scott-native
   register (Scott's own domain-theoretic and lattice-theoretic instincts) — a short "for the
   algebraically-minded reader" aside naming Jónsson–Tarski explicitly could serve as a bridge
   without restructuring the whole document around it.
4. **Results-then-proofs-appendix.** Rejected (see Recommended Approach) — proofs are load-bearing
   motivation for the pain-point sections, not a payload to defer.

### Reusable material inventory (file:line)

- `typst/chapters/p3-vlach-blstar.typ:108-128` — Kamp's theorem, correctly scoped, and the
  formalization-frontier status (`kampPriorExpressiveCompleteness`, `Metalogic/WeakCanonical/
  Kamp/`). Directly portable into §7.
- `typst/chapters/p3-vlach-blstar.typ:94-106` — "Prior Art: From 'Now' to Hybrid Binders" gives a
  five-item lineage (Kamp 1971 → Vlach 1973 → Cresswell 1990 → hybrid logic → Goranko) that is a
  model for how to write a *compressed* prior-art paragraph; useful as a style template even where
  its specific content (store/recall operators) is out of scope for `FormalFoundations.typ`.
- `typst/chapters/p2-frame-classes.typ:105-179` — "Duration Groups and the Four Classes":
  worked validity proofs for the density schema and the discrete/Prior-Z1 layer, the
  $\mathbb{Z}\times_{\text{lex}}\mathbb{Z}$ non-density/non-discreteness witness frame, and the
  precise unfillable-gap statement ($\mathrm{Th}(\mathbb{Z})\cap\mathrm{Th}(\mathbb{R})$ has no
  `FrameClass` constructor). Directly relevant to Dana's second email question (necessity of
  temporal axioms once a frame class is fixed) and portable with compression.
- `FormalSystem/Metalogic/Algebraic/README.md` — a ready-made "Mathematical Overview" (5-step
  Lindenbaum → Boolean algebra → interior operators → ultrafilter-MCS correspondence →
  representation-via-ultrafilters) and an explicit "Future Extension Opportunities" list (Stone
  duality, algebraic topology, coalgebraic methods) that already reads as draft prose for part of
  §7's way-forward material.
- `FormalSystem/Boneyard/UltrafilterFrame/README.md` — states the exact archival reason
  (elaboration interference with `BXCanonical/Completeness.lean`), file/sorry counts, and names
  task 125 as the revival point. This is the honest "obstruction" §7 needs to state precisely
  rather than vaguely (per the task's demand for "no vague glosses").
- `possible_worlds.tex:899-1070` (`\subsection{Possible Worlds}`) — the source paper's own
  semantics-first exposition (world states → temporal order → task relation → frame axioms →
  partial/total histories → extension/occurrence → possible worlds as equivalence classes →
  truth clauses → logical consequence → perpetuity as the first payoff). This is close to a
  ready-made outline for the recommended semantics-first architecture and should anchor §1's
  reorganization directly, not just its notation.
- `possible_worlds.tex:1308` and `:395` — Dana Scott's own presence in the paper's genealogy
  (Prior's Next/Previous citation; acknowledgments). Low-cost, high-relevance personal anchor.

### Typst mechanics available but currently underused

- `typst/template.typ:97-98` — `#leansrc(module, name)` renders a blockquote-style citation into
  actual Lean source (e.g. `#leansrc("FormalSystem.Syntax.Formula", "next")`, used in
  `p2-frame-classes.typ:163-179`). `FormalFoundations.typ` currently cites Lean constructs only in
  running prose (e.g. "`mcs_mixed_case_absurd`" as inline code) — using `leansrc` for the
  headline theorems in §6 would visually distinguish "this is machine-checked" from "this is
  paper-side" in a way plain inline code cannot, which matters given the report's own stated goal
  of being unsoftened about what is and isn't proved.
- `typst/template.typ:89-90` — `proposition` and `corollary` environments exist
  (`thmbox.proposition`/`thmbox.corollary` with the theorem-style italics) and are already
  imported into `FormalFoundations.typ`'s header line but, per a scan of the current body, are not
  yet used — `cor:tm-completeness`/`cor:tm-decidability`-style claims in §2 are good candidates for
  the `corollary` environment rather than plain `theorem`, matching the paper's own labeling
  (`cor:`-prefixed anchors).
- `typst/BimodalReference.typ:230` — `#bibliography("bibliography.bib", style: "ieee")` is the
  only bibliography call in the project; `FormalFoundations.typ` currently has no visible
  `#bibliography(...)` call in the region read (worth Teammate A confirming it exists near the
  document's end) — if new sources (Goldblatt, Jónsson–Tarski, Chagrov–Zakharyaschev, Scott) are
  cited, they must be added as entries to the *shared* `bibliography.bib`, not a local file, to
  avoid drift with `BimodalReference.typ`.
- Cross-referencing convention already established project-wide: `<sec:label>` on headings, cited
  via `@sec:label`; footnote-based citation of the paper's own internal anchors via `#footnote[
  \`key\`. @brastmckie2026possibleworlds]` (used pervasively in the current `FormalFoundations.typ`
  §1). This convention should be preserved as-is — it's already the load-bearing citation
  mechanism connecting this report to the paper's `\label`s.

---

## Confidence Level

**High** for: the bibliography gap inventory (mechanically verified via `grep`), the reusability
of `p3-vlach-blstar.typ`'s Kamp section and `p2-frame-classes.typ`'s duration-groups section
(read in full), the three-tier representation-theorem status (cross-checked against task 443's
own independently-verified research report), and the Typst mechanics inventory (read directly from
`template.typ`/`BimodalReference.typ`).

**Medium** for: the specific recommendation to lead with Scott's personal genealogical connection
(`possible_worlds.tex:1308`/`:395`) — this is a judgment call about tone for this specific reader,
not a structural fact, and Teammate A or the user may reasonably prefer a more austere register
that omits it.

**Medium** for: the claim that axiomatics-first is the current draft's principal structural
problem — based on a read of the first third of `FormalFoundations.typ` (through §1) plus the
abstract and section headings; Teammate A's closer section-by-section read may surface additional
or different structural issues.
