// ============================================================================
// p3-decidability-frontier.typ
// Part I chapter -- The Decidability Frontier
//
// Written at a Lk-abstracted level (no Lk-specific results until TACAS
// acceptance).
//
// EMBARGO (user decision 2): this file may NEVER cite, attribute,
// or lift Lk-specific results (BL*-ladder table, L_k complexity theorems,
// hardware case study) until the Lk paper (anonymous TACAS 2027 double-blind
// submission) is accepted. The // SLOT-IN: anchors below are the ONLY
// sanctioned insertion points for that content, reserved for the
// post-TACAS-acceptance follow-up.
// ============================================================================

#import "../template.typ": *

= The Decidability Frontier <sec:decidability-frontier>

#chapter-header(
  description: [What expressive extensions of a temporal-modal logic cost, surveyed from published results: the linear-temporal floor, the product zone one modal dimension up, the cross-referencing ceiling, and the descents that linear flows and bounded disciplines buy back.],
  dependencies: [@ch:vlach-blstar for the store/recall operators; @sec:decidability-practice for *TM*'s own decision procedure.],
)


== The Question

The two preceding chapters expanded the language twice: from the tense basis to Until/Since, and from there to the store/recall operators and the stability modality of BL#super[⋆].
Each expansion is well motivated, and each raises the same question: what does the added expressive power cost?
For temporal-modal logics the currency is decidability and complexity of the satisfiability problem, and the published literature prices the neighborhood well enough to chart a frontier before any new result is stated.

== The Floor and the Product Zone

The floor is the linear-temporal base itself: LTL satisfiability is PSPACE-complete @sistlaClarke1985 -- hard, but comfortably decidable, and the benchmark every extension is measured against.

Adding one S5-like modal dimension moves into the territory of products of modal logics @gabbay2003manyvalued.
The bimodal products of a linear tense logic with S5 remain decidable, but the price is already steep: complexity for such products rises to EXPSPACE-hard territory @marx1999, and the complete axiomatizations for knowledge-and-time logics in the same zone reflect the same jump @hmv2004.
The ceiling _within_ the product landscape is sharp: three-dimensional products in the vicinity of S5 × S5 × S5 are undecidable and non-finitely-axiomatizable @hirschHodkinsonKurucz2002.
The published pattern, then, positions one modal dimension over linear time as the safe zone: expensive, but on the right side of the line.

== The Cross-Referencing Ceiling -- and the Linear Descent

Cross-referencing devices price differently, and higher.
The hybrid binder $arrow.b$, which names the current evaluation point for later recall, makes satisfiability undecidable over arbitrary frames @arecesBlackburnMarx2001 @tenCateFranceschet2005.
But the ceiling has a descent: over _linear_ structures, hybrid logics with binders become decidable again, at non-elementary cost @franceschetEtAl2003.
Freeze quantifiers and registers tell the same story in a metric register: LTL with one freeze register over the future is decidable but non-primitive-recursive, while two registers -- or one register with past operators -- tips into undecidability @demriLazic2009; the clock discipline of timed temporal logic is the tamer alternative that keeps real-time reasoning decidable @alurHenzinger1994.
Trace quantification prices highest of all: HyperLTL satisfiability is undecidable @finkbeiner2016, its model checking is decidable with cost rising by an exponential per quantifier alternation @finkbeiner2015, and the logic embeds into a proper fragment of first-order logic with an equal-level predicate @finkbeiner2017 -- the line of work originating with @clarkson2014.
Goranko's reference pointers, the direct ancestor of the store/recall formulation, come with their own expressiveness hierarchies @goranko1996.

The published pattern is consistent: unrestricted cross-referencing over rich frame classes costs decidability; linearity of the flow, bounded registers, anchoring disciplines, and quantifier restrictions buy it back at elevated complexity.

== Where BL#super[⋆] Sits

BL#super[⋆]'s indexed store/recall families range over _both_ times and worlds, giving the language hybrid-binder-like power in two coordinates simultaneously.
By the pattern above, the expectation from prior art is clear: undecidability at the top of the tower, with decidable fragments only under register bounds, anchoring disciplines, or quantifier restrictions.
That is an expectation, not a theorem -- no result about the tower is stated or attributed here, and the paper's own boundary (no axiomatization of BL#super[⋆], @ch:vlach-blstar) applies with equal force to its computational theory.

// SLOT-IN: ladder-table
// Reserved for post-TACAS-acceptance: the BL* ladder table from
// Lk 07-related-work.tex (tab:bl-star-ladder). Do not populate before the
// embargo lifts.

== Charting the Tower

A complexity map for the BL#super[⋆] tower would need to chart, at minimum: satisfiability for each register budget, in each coordinate separately and in both together; the effect of restricting recall to anchored (utterance-point) reference in the style of _now_; the interaction of the stability modality with the store/recall families; and which fragments inherit the linear-flow descent that @franceschetEtAl2003 established for hybrid binders.
Until such a map is published, the safe summary is the sectional pattern above: every cell of the map has a published analogue predicting its rough altitude, and none of the analogues predicts a free lunch.

// SLOT-IN: complexity-map
// Reserved for post-TACAS-acceptance: the complexity map (L1 = PTL x S5
// EXPSPACE-complete; L_k undecidable for k >= 2; alternation-freedom does
// not restore decidability (Theorem F-B); forall-AF-L_k PSPACE-complete
// flagship (Theorem F-A)). Do not populate before the embargo lifts.

== Applications Outlook

The practical stakes mirror those of the model-checking tradition @baierkatoen2008: specification languages earn their keep when their verification problems are mechanizable, and every expressive extension that survives the frontier with decidability intact widens the class of systems whose temporal-modal properties can be checked rather than argued.
Cross-referencing operators are attractive for exactly the specifications that motivate them in natural language -- properties relating the evolving present to a remembered reference point, or one possible evolution to another -- and the frontier surveyed here determines when such specifications remain checkable.

// SLOT-IN: case-study
// Reserved for post-TACAS-acceptance: the hardware case study (constant-time
// as forall-forall, reset convergence, SVA/Logos-Hardware bridge,
// Lk 06-case-study.tex). Do not populate before the embargo lifts.

== TM's Own Position

*TM* itself is the intended floor beneath this frontier, but decidability is not yet established for it either: `cor:tm-decidability` states that whether *TM* and its extensions are decidable is *open*, retracting an earlier blanket finite-model-property-over-$ZZ$ premise as false (@sec:decidability-practice gives the two witnesses and the precise statements).
In this repository, the tableau procedure's soundness is proven (`decide_sound`), and the finite-filtration FMP statement is sorry-free (`fmp_completeness`) as a statement about the filtration structure, with its semantic-validity bridge to task-frame validity an open problem.
The expressive ascent charted in this part therefore starts from ground that is *conjectured*, not yet established, decidable, and the frontier above marks how far the ascent could go were that ground secured.
