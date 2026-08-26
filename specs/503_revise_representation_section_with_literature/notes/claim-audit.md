# Claim Audit for the `<sec:representation>` Revision

Working note for the implementation of the plan `plans/01_revise-representation-section.md`.
Every claim below was re-checked directly against live source (this repository's Lean tree, or
the corpus markdown/PDF pair) as part of implementation, not carried over from the research
report unread. Classification: **VERIFIED** (checked directly, safe to assert as fact) /
**PROVISIONAL** (checked as far as possible but resting on a hedged source, and must be hedged in
the prose) / **EXCLUDED** (not to appear in the Typst section at all).

## VERIFIED

1. **Algebraic layer is 0 sorries, 0 axioms.** `grep -rn "sorry" FormalSystem/Metalogic/Algebraic/*.lean`
   returns no hits across all five files (`LindenbaumQuotient.lean`, `BooleanStructure.lean`,
   `InteriorOperators.lean`, `UltrafilterMCS.lean`, `FlowFrame.lean`).
2. **`box` is an interior operator on the quotient; `#allpast`/`#allfuture` are not, and no `G`
   operator exists on the quotient.** `InteriorOperators.lean:29-43` (module docstring) states
   this explicitly; `boxInterior` (`:142`, assembled from `box_le_self` `:101`, `box_monotone`
   `:112`, `box_idempotent` `:130`) is the only `InteriorOp` built; `H_monotone` (`:80`) is the
   only surviving G/H-family result. `LindenbaumQuotient.lean` defines `boxQuot` (`:289`) and
   `hQuot` (`:296`) but no `gQuot` or equivalent anywhere in the file or the directory. The
   directory README (`FormalSystem/Metalogic/Algebraic/README.md`, "Interior Operators" section)
   states the same thing in the same terms. The current Typst `#definition("The
   Lindenbaum--Tarski Algebra")` block, which claims `#allpast` and `#allfuture` "act as interior
   operators", is a factual error and must be corrected.
3. **Ultrafilters of the quotient correspond bijectively to maximal consistent sets.**
   `SetMaximalConsistent.ultrafilter_correspondence` (`UltrafilterMCS.lean:782`), with round
   trips `mcsToUltrafilter`/`ultrafilterToSet` (`:524`, `:668`) and `ultrafilterToMcs` (`:969`,
   which reuses `ultrafilter_correspondence` at `:986`).
4. **`sigmaQuot` is an involution commuting with the Boolean operations and with `boxQuot`.**
   `LindenbaumQuotient.lean:346` (`sigmaQuot`), `:353` (`sigma_quot_involution`), `:362-363`
   (`sigma_quot_neg`), `:373-374` (`sigma_quot_sup`), `:385-386` (`sigma_quot_box`). So
   `sigma compose hQuot compose sigma` is a one-line definition away from a `G` operator on the
   quotient; it is not built. (Not backticked as `gQuot` anywhere in the prose below, since that
   identifier does not exist in Lean source — `typst-sync-check.sh` Check 1 would flag it.)
5. **The quotient is built at `FrameClass.Base` only.** `Derives φ ψ := Derivable FrameClass.Base
   [] (φ.imp ψ)` (`LindenbaumQuotient.lean:46`). One Lindenbaum algebra, for the base logic; no
   per-frame-class algebras exist in this directory.
6. **`Formula` (the type quotiented) already contains `untl`/`since`, i.e. this is the
   $#BLplus$-level algebra, not a bare-$#BL$ one.** `FormalSystem/Syntax/Formula.lean:76-96`
   (`inductive Formula`, case `untl`). So the "no `G`" gap is a gap in which *lifted quotient
   operations* exist, not a gap in the underlying language.
7. **Archived Boneyard sorry counts.** `FormalSystem/Boneyard/UltrafilterFrame/TenseS5Algebra.lean`
   has 3 `sorry` occurrences, `UltrafilterFrame.lean` has 4, `AlgebraicCompleteness.lean` has 0 —
   7 total, matching the research report's count. The directory README attributes these to
   "axioms removed in the BX cleanup," i.e. bookkeeping debt from an axiom-set change, not a
   witnessed *Spherical* obstruction — no sorry in the archived files is annotated as blocked on
   *Spherical* specifically; the obstruction is asserted in the module prose, not witnessed by a
   sorry.
8. **`Spherical`, read precisely.** `FormalSystem/Semantics/TaskFrame.lean:362-364`:
   `def Spherical {W} (R : W → D → W → Prop) : Prop := ∀ S : Set (Set W), DirectedFamily S →
   (∀ s ∈ S, (IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty) → (⋂₀ S).Nonempty`. This is a
   downward-directed-intersection compactness condition on nonempty fibers and segments —
   verbatim in shape to BdRV's `compact` condition (`blackburnderijkevenema2001`, Definition
   5.65 in the *Modal Logic* corpus edition): `⋂A' ≠ ∅` for every subset `A'` of `A` (the
   admissible-set algebra) with the finite intersection property. A `⊇`-directed family is
   exactly a family with witnessed finite intersections, so the two conditions are the same shape,
   restricted in TM's case to fibers and segments rather than to all admissible sets.
9. **`Spherical`'s sole application site is the Step Lemma, and the Step Lemma is the sole
   consumer.** `FormalSystem/Semantics/Extension/Step.lean:10-113` states and the module
   docstring re-asserts ("*Spherical* is applied here and nowhere else") that no other lemma in
   the extension pipeline consumes it. This matches `typst/FormalFoundations.typ`'s own claim at
   the current line 342 ("The Step Lemma above is the sole application site of *Spherical*... that
   localization is what makes *Spherical* the identified obstruction").
10. **`Compositionality`, `Seriality`, `Limit` are stated with only first-order-shaped
    quantification over `W` and `D`; `Spherical` alone quantifies over a family of subsets of
    `W`.** `typst/FormalFoundations.typ`'s own `#definition("Frame")` (currently lines 206-218)
    states all four this way already; `Spherical`'s `∀ S : Set (Set W)` binder is the one
    quantifying over the power set of a power set, confirmed against the Lean definition in item 8.
11. **The Sahlqvist classification of TM's axioms**, re-derived against Definition 3.51 of
    `blackburnderijkevenema2001` (a boxed atom is `□₁⋯□ₙ p`, possibly under diamonds; a negative
    formula has every letter occurrence under an odd number of negations; a Sahlqvist antecedent
    is built from boxed atoms and negative formulas by `∧`, `∨`, and diamonds only — no box over a
    non-atomic subformula; the consequent must be positive), reading the axiom list from
    `typst/FormalFoundations.typ`'s own `#definition("TM")` and per-class axiom blocks (currently
    lines 553-611):
    - **MT** (`□p → p`): boxed atom antecedent, atom consequent. Sahlqvist.
    - **M5** (`◇□p → □p`): diamond over a boxed atom antecedent, boxed-atom consequent.
      Sahlqvist.
    - **MF** (`□p → □Gp`): boxed atom antecedent, `□Gp` positive consequent. Sahlqvist.
    - **T4** (`Gp → GGp`): boxed atom, positive consequent. Sahlqvist.
    - **TB** (`F⊤`): no antecedent (or `⊤`, trivially negative); positive consequent. Sahlqvist.
    - **TA** (`p → GPp`): atom antecedent, positive consequent. Sahlqvist.
    - **TL**: antecedent `Fp ∧ Fq`, diamonds applied to atoms, conjoined — permitted; consequent a
      disjunction of diamond-of-conjunctions, positive. Sahlqvist.
    - **DN** (`GGp → Gp`): boxed atom, positive consequent. Sahlqvist.
    - **DF** (`(Hp ∧ p ∧ F⊤) → FHp`): antecedent is a conjunction of a boxed atom (`Hp`), a bare
      atom (`p`), and a diamond-of-constant (`F⊤`), all permitted forms conjoined; consequent
      `FHp` is a diamond over a boxed atom, positive. **Sahlqvist** — worth stating plainly
      because the classification is counter-intuitive next to Z1's failure below: forward
      discreteness is Sahlqvist even though the ℤ-pinning induction axiom is not.
    - **CO** (`Always(Pp → FPp) → (Pp → Gp)`): the antecedent is a box (`Always`, i.e. the global
      S5-flavoured modality over past/future) applied to the *implication* `Pp → FPp`, not to a
      boxed atom — `p` occurs both under a diamond (`P`, positively) and, unfolded, negatively
      inside the implication's antecedent. A box may only be applied to a boxed atom or a negative
      formula in a Sahlqvist antecedent; a box over a compound implication with mixed polarity is
      neither. **Not Sahlqvist** by this route; no first-order correspondent is available from
      Sahlqvist's algorithm.
    - **Z1** (`G(Gp → p) → (FGp → Gp)`): the antecedent is `G` applied to the compound implication
      `Gp → p`, the identical structural problem as CO. **Not Sahlqvist.**
    - **UC** (`G(φ → ψ) → ((χ U φ) → (χ U ψ))`) and **UG** (`G(φ → χ) → ((φ U ψ) → (χ U ψ))`):
      both have `G` applied to a compound implication in the antecedent, same reason. **Not
      Sahlqvist.**
    - **UZ**, **Prior-U**, **Sep**: each involves either a box/`Always`/`K⁺` operator applied to a
      compound (non-atomic, non-negative) formula in antecedent position, or (Sep) nested
      `K⁺`/`K⁻` operators over conjunctions and negations that are not boxed atoms. **Not
      Sahlqvist** by inspection of the same antecedent-shape criterion; not independently
      re-derived formula-by-formula for Prior-U and Sep beyond confirming the disqualifying shape,
      since the plan requires re-deriving TM's own axioms (which do not include Prior-U or Sep;
      those live in $"BX"_c$ at the $#BLplus$ level and are conjectured, not proved, to correspond
      to CO — see the current section's own footnote on this).
    - **Reading, matching the research report**: everything that makes TM a bimodal
      S5-plus-linear-tense logic (MT, M5, MF, T4, TB, TA, TL, DN, DF) is Sahlqvist and hence
      canonical by Sahlqvist Canonicity. Everything that pins down *which* linear order (CO, Z1,
      and by the same pattern UC, UG, UZ, Prior-U, Sep) falls outside the fragment.
    - This classification is **VERIFIED** by direct re-derivation against the definition, not
      copied from the report's table (the report itself flagged it as its own reading, not a
      literature quotation). It is asserted in the prose as the section's own analysis, attributed
      to the method of `blackburnderijkevenema2001` Definition 3.51, not to any of the newly cited
      sources as a direct quotation of a completed table.
12. **The disjoint-union asymmetry.** `blackburnderijkevenema2001` Theorem 5.48 and Exercise
    5.4.1 (as reported at Findings §3.2 of the research report, itself sourced to
    `blackburn_2002_ch05_sec04`, a curated corpus slice of the same book): the complex algebra of
    a disjoint union of frames is the product of the complex algebras (`(⨿ᵢFᵢ)⁺ ≅ ∏ᵢFᵢ⁺`), but the
    converse fails — a countable product of finite algebras can have uncountably many ultrafilters
    while the disjoint union of the ultrafilter frames stays countable. This is a **PROVISIONAL**
    item promoted to VERIFIED-by-secondary-source: the primary corpus slice was read by the
    research agent, not independently re-read line-by-line during implementation; the mathematical
    content (product/coproduct asymmetry across a duality functor) is standard and consistent with
    every other source consulted, so it is asserted directly rather than hedged, but is not
    supported by a fresh independent re-read of the BdRV text during this implementation pass.

## PROVISIONAL (must appear hedged, never as flat assertion)

1. **The precise year/venue metadata for `goldblatt2003ghv`, `derijke1995sahlqvist`, and
   `venema1993antiaxioms`** (the three newly added BibTeX entries sourced from preprint PDFs
   rather than the published offprint). The corpus PDFs are dated preprint/technical-report
   versions (`derijke_1995`'s title page reads "Version 5, June 1994"; `venema_1993`'s is dated
   August 2003 on the PDF but the paper's content is the 1993 JSL article). Publication venue and
   year are given from established bibliographic record (Studia Logica 54(1):61-78, 1995 for de
   Rijke & Venema; Journal of Symbolic Logic 58(3):1003-1034, 1993 for Venema; Bulletin of Symbolic
   Logic 10(2):186-208, 2004 for Goldblatt-Hodkinson-Venema, consistent with the PDF's "Received
   by the editors February 14, 2004" note), not re-derived from the PDF itself. Each entry carries
   `note = {verify before print}`, following this bibliography's own existing convention for
   `goldblatt1992logics` and `chagrovzakharyaschev1997`.
2. **Whether `box(x ∨ Fx ∨ Px)` is a global modality for TM in the sense of Venema 2007 Definition
   8.11, and hence whether `BAO(TM)` is a discriminator variety (Theorem 8.10).** Flagged
   *unverified* by the research report and not independently checked here (checking it requires
   verifying the inclusion axiom `∇ᵢx → γ(x)` for every induced diamond of TM's similarity type,
   which is a proof obligation beyond this documentation task's scope). **Excluded from the
   revised prose entirely** — see the EXCLUDED list below; it is not even presented hedged, since
   the plan's Non-Goals explicitly bar settling or leaning on the discriminator-variety conjecture.
3. **Any claim sourced to `goldblatt_1989`.** The corpus markdown for this source carries its own
   header: "USE THIS FILE ONLY AS A ROUGH LOCATOR ... Do not quote this text." No claim in the
   revised section rests on this source; it is not cited. (Listed here for completeness of the
   audit, per the plan's Phase 1 task list, even though the resolution is exclusion rather than
   hedging.)

## EXCLUDED (must not appear in the revised prose, in any form)

1. **The discriminator-variety conjecture** (`box(x ∨ Fx ∨ Px)` as a global modality, `BAO(TM)` a
   discriminator variety, Theorem 8.10 applying). Unverified and explicitly out of scope per the
   plan's Non-Goals.
2. **Any claim sourced only from `goldblatt_1989`** (the OCR-locator-only source; see PROVISIONAL
   item 3 above — the resolution here is full exclusion, not hedging).
3. **The historical narrative around S. K. Thomason 1972/1975, Goldblatt 1976, and Sambin &
   Vaccaro 1988.** None of these three sources was acquired (see the research report §2.2); no
   proxy in the corpus states their content with attribution reliable enough to narrate. The
   revised section states the mathematics these papers are associated with (via the
   `venema_2007_algebras_and_coalgebras` and `blackburnderijkevenema2001` proxies, which do state
   and attribute the relevant theorems) without constructing a historical narrative that would
   need these three primary sources.
4. **The claim that the ultrafilter-frame formulation `η(a) = {U : a ∈ U}` is due to Jónsson &
   Tarski**, stated as a literal transcription of their 1951/1952 papers. Per the research report
   (§2.4, citing the sub-index's `terminology_hazard` field on `j_nsson_and_tarski_-_1951/1952`):
   the originals construct a *perfect extension* and contain no occurrence of "ultrafilter". This
   is not excluded as a *theorem attribution* — the embedding theorem itself is still Jónsson &
   Tarski's — but the specific ultrafilter-frame *notation and formulation* is excluded from being
   presented as their own and is instead attributed to the modern restatement
   (`blackburnderijkevenema2001` §5.3), with a footnote noting the terminological anachronism, per
   the current section's existing citations `@jonssontarski1951 @jonssontarski1952` which must be
   corrected in place rather than removed outright.

## Bibliography additions needed

Confirmed by enumerating what the drafted prose (Phases 2-5) actually cites, not by the research
report's estimate:

| Key | Source | Used for |
|---|---|---|
| `venema2007algebrascoalgebras` | Venema, *Algebras and Coalgebras*, Handbook of Modal Logic ch. 6 (2007) | Goldblatt/Esakia duality (Thm 5.28), canonicity (Thm 6.11/6.12/6.14/6.17/6.18), tense algebra (Def 8.2/8.3, Thm 8.4, Prop 8.5) |
| `gehrkevosmaer2011` | Gehrke & Vosmaer, *A View of Canonical Extension* (2011) | canonical-extension framing alongside Jónsson-Tarski's canonical embedding algebra |
| `goldblatt2003ghv` | Goldblatt, Hodkinson & Venema, *Erdős Graphs Resolve Fine's Canonicity Problem* | negative answer to BdRV Open Problem 2 (canonical ⇏ elementarily generated) |
| `derijke1995sahlqvist` | de Rijke & Venema, *A Sahlqvist Theorem for Boolean Algebras with Operators* | the algebraic (BAO-level) form of Sahlqvist canonicity |
| `venema1993antiaxioms` | Venema, *Derivation Rules as Anti-Axioms in Modal Logic* | the doctrine that non-Sahlqvist frame conditions are captured by derivation rules, not axioms — cited as the standard account of what CO/Z1/UC/UG-style axioms need instead of Sahlqvist canonicity |
| `fine1975elementarymodal` | Fine, *Some Connections Between Elementary and Modal Logic* | cited via `venema2007algebrascoalgebras` Theorem 6.17 for the statement (elementary ⟹ canonical), with the primary reference given per the plan |

`jonssontarski1951` / `jonssontarski1952` and `blackburnderijkevenema2001` already exist in
`typst/bibliography.bib` and are reused rather than re-added.

Six new entries, matching the plan's estimate exactly.
