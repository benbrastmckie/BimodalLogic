---
next_project_number: 445
---

# TODO

## Task Order

*Updated 2026-08-13. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 125,127,128,193,231,257,298,413,415,417,419,421,423,424,437,440,444 | -- | completeness, decidability, frame-extensions, ... |
| 2 | 178,219,282,296,422,425,436,441 | 193,231,298,421,423,437,440 | decidability, formula-refactor, dataset-enhancement, ... |
| 3 | 169,434 | 422,436 | decidability, strong_completeness |
| 4 | 362,432 | 169,434 | decidability, strong_completeness |
| 5 | 433 | 432 | decidability |
| 6 | 428 | 433 | decidability |
| 7 | 429 | 428 | decidability |
| 8 | 410 | 429 | -- |
| 9 | 411 | 410 | -- |
| 10 | 430 | 411 | decidability |
| 11 | 412 | 430 | -- |
| 12 | 426 | 412 | completeness |
| 13 | 95,177 | 193,426 | completeness, formula-refactor |

**Grouped by Topic** (indented = depends on parent):

### Completeness

413 [NOT STARTED] — Formalize the TM+ over TM conservativity bridge in Lean 4 (paper 
95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me
426 [NOT STARTED] — Settle whether the tableau engine can positively refute (G p) -> 
  └─ 95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me (see above)

### Decidability

437 [RESEARCHED] — Attack the missing fourth termination-measure component from the 
  └─ 436 [BLOCKED] — Resume task 434's implementation plan (specs/434_discharge_mintpa
    └─ 434 [BLOCKED] — Discharge `MintPaysForTime fc U Tmax`, defined at FormalSystem/Me
      └─ 432 [IMPLEMENTING] — Discharge `UniverseClosed fc U`, defined at FormalSystem/Metalogi
        └─ 433 [RESEARCHED] — Discharge `PostBlockingSettles fc`, defined at FormalSystem/Metal
          └─ 428 [BLOCKED] — Engine totality at a quantified branch budget. Owns obstruction O
            └─ 429 [NOT STARTED] — Repair the truth-lemma side conditions. Owns obstructions O2 and 
              └─ 410 [PLANNED] — Track B part 1 for the TM tableau decidability program (parent: t
                └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program (parent: t
                  └─ 430 [NOT STARTED] — The semantic lift and the Track A assembly. Owns obstruction O4 o
                    └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program (parent: t

### Formula Refactor

177 [NOT STARTED] — Update all documentation to match final codebase state after refa
178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Publication Quality

444 [NOT STARTED] — Review the email other/dana.md sent to Dana Scott regarding the p

### Automation

193 [NOT STARTED] — Apply validity-intro and truth-simp macros to the soundness layer

### Dataset Enhancement

231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
  └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
257 [BLOCKED] — large_data_storage_huggingface
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor
  └─ 282 [PARTIAL] — exhaustive_enumeration_by_default
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Paper Refactor

415 [IMPLEMENTING] — RE-ISSUED 2026-08-10 (supersedes the prior maximal-history framin
417 [PLANNED] — RE-ISSUED 2026-08-10 (supersedes the prior maximal-history framin
419 [PLANNED] — RE-ISSUED 2026-08-10 (description rewrite only; status unchanged)
440 [RESEARCHED] — RE-ISSUED 2026-08-12 (description rewrite only; status unchanged)
  └─ 441 [NOT STARTED] — Strengthen `thm:extension` for the finite discrete case into an E

### Strong Completeness

421 [NOT STARTED] — Two deliverables on the Base weak terminus, both small.
  └─ 422 [NOT STARTED] — Construct the discrete-case analogue of the existing dense chroni
    └─ 169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th
      └─ 362 [NOT STARTED] — Implement the completeness capstone under the SETTLED TERMINOLOGY
423 [NOT STARTED] — Create FormalSystem/Metalogic/SetConsequence.lean containing the 
  └─ 425 [NOT STARTED] — Convert the informal argument at FormalSystem/Metalogic/StrongCom
424 [NOT STARTED] — RE-ISSUED 2026-08-10 (description rewrite only; status remains `n

### Uncategorized

## Tasks

### 444. Overhaul formalfoundations presentation
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: publication-quality
- **Dependencies**: None

**Description**: Review the email other/dana.md sent to Dana Scott regarding the paper /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, and systematically overhaul typst/FormalFoundations.typ so it presents, for Dana Scott as reader: the core mechanics of the existing completeness results, the current state of decidability, and the best direction for developing a representation theorem. Carefully review and incorporate the FIX tags already added in the file. The rewrite must adopt the writing style of an advanced textbook -- no vague glosses or platitudes -- with clean, precise definitions and theorems, and terse but informative introductions and remarks only where needed to motivate and explain the flow of results. The current document has virtually no detectable narrative arc; the presentation must be rewritten at a much higher level of formal sophistication, taking the time needed to do so accurately and masterfully.

---

### 443. Formal foundations report completeness and representation
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: paper-refactor
- **Dependencies**: Task 442
- **Plan**: [443_formal_foundations_report_completeness_and_representation/plans/01_formal-foundations-report.md]
- **Summary**: [443_formal_foundations_report_completeness_and_representation/summaries/01_formal-foundations-report-summary.md]
- **Research**: [443_formal_foundations_report_completeness_and_representation/reports/02_measured-status.md]

**Description**: GOAL. Write a NEW, standalone ~10-page Typst report, `typst/FormalFoundations.typ`, presenting the formal foundations of the bimodal logic: a formally precise and compressed overview of the system and its logic, stating key theorems where appropriate; then the PAIN POINTS -- the contingency of the temporal axioms (density, discreteness, Dedekind-completeness) and the axiomatization of the strongest objective modality; then, and most importantly, THE COMPLETENESS CONSTRUCTION AS ACTUALLY IMPLEMENTED IN THIS REPOSITORY together with the early steps toward a representation theorem, closing with an outline of the best way forward to a fully adequate representation theorem and completeness results for a very weak, general base bimodal logic that assumes neither density nor discreteness nor perhaps even Dedekind-completeness.

This is a research-facing document, not a chapter of the reference manual. It should read as the thing you would hand a logician who asks "what exactly is proved here, what is not, and what would it take to close the gap."

=== 1. FORM AND LOCATION -- USER DECISION, 2026-08-13 ===
A STANDALONE document at `typst/FormalFoundations.typ`, compiled to `typst/build/FormalFoundations.pdf`. It IMPORTS `typst/notation/bimodal-notation.typ` and `typst/template.typ` so that notation cannot drift between this report and the book, and cites `typst/bibliography.bib`. It is NOT a chapter of `BimodalReference.typ` and must not be `#include`d by it. Add its build command to `typst/README.md`.

Target length ~10 pages of body text at the book's existing type settings. Compression is a design constraint, not an accident: prefer a stated theorem with an anchor over a rehearsed proof, and prefer one well-chosen diagram over a page of prose. Where a proof genuinely carries the argument -- the two-fibre incompleteness countermodel, the discrete-or-dense dichotomy -- give it in full, briefly.

=== 2. DEPENDENCY AND WHY ===
Depends on the BimodalReference revision task. That task establishes, in one place and against the repository's own guards, which claims about the paper and the Lean tree are currently TRUE -- the completeness reversal, the four frame classes, the deleted conservativity theorem, the open decidability status, the live module structure, and the corrected Since/Until convention. Writing this report first would mean re-deriving all of it and would risk the two documents disagreeing. Consume the predecessor's findings note from its `reports/` directory as settled input; re-verify anything it flags as exposed to the in-flight Lean chain.

=== 3. SECTION PLAN (indicative; a better structure that covers the same ground is acceptable, a shorter one that drops a pain point is not) ===

3.1 THE SYSTEM, COMPRESSED. The languages BL = <SL, bot, ->, Box, Past, Future> and BL^+ = <SL, bot, ->, Box, Since, Until> (\label{def:BLplus-language}), with the defined operators of \label{def:BLplus-defined} and the reduction \label{thm:BLplus-PastFuture} showing Past/Future definable from Since/Until, plus \label{thm:BLplus-NextPrevious} for Next/Previous over discrete frames. Task-frame semantics: \label{def:temporal-order}, \label{def:task-relation} with the converse convention and the fiber/cone/segment apparatus, \label{def:directed}, the FOUR axioms of \label{def:frame} (Compositionality biconditional, Seriality, Limit, Spherical -- Nullity is a LEMMA, \label{lem:nullity}, not an axiom), the partial/world/total history layering of \label{def:world-history}, \label{def:BL-semantics}, and \label{def:logical-consequence}. The proof systems: S5 (\label{def:S5}), the base Burgess-Xu tense logic BX (\label{def:BX}), TM^+ = S5 + BX + \aitem{TMP-MF} (\label{def:TMplus}), and the three extensions BX_f/TM^+_f (\label{def:TMplus-f}), BX_d/TM^+_d (\label{def:TMplus-d}), BX_c/TM^+_c (\label{def:TMplus-c}). State the BL-level TM axiomatization too, since the pain points are about it.

3.2 KEY THEOREMS. Existence and occurrence -- \label{lem:step}, \label{thm:extension} (Zorn), \label{cor:occurrence}, \label{cor:spherical-finite} (finite W satisfies Spherical, choice-free -- and note the Lean-vs-ZF mismatch: choice-free in the paper's sense means "no AC given classical logic", whereas Lean's `Classical.choice` is the single axiom yielding both excluded middle and choice, so `#print axioms` CANNOT express the paper's distinction; this repository has machine-checked that Spherical on a finite carrier implies weak excluded middle, so no `Classical.choice`-free Lean proof can exist). Soundness -- \label{thm:TM-soundness} for TM and its extensions, \label{thm:M5-valid}. Correspondence -- \label{app:discrete} (\aitem{DF}), \label{app:dense} (\aitem{DN}), \label{app:complete} (\aitem{CO}). The perpetuity principles \aitem{P1}--\aitem{P6} and the derived \aitem{TF}, with the derivation from MF and MT by classical reasoning. The modal-temporal collapses \label{Pthm:11}--\label{Pthm:22} (in particular Sometimes-Box phi <-> Box phi, Always-Box phi <-> Box phi, Box-Always phi <-> Box phi, Diamond phi <-> Diamond-Sometimes phi) and what they suggest about the language's real expressive complexity. Order-theoretic facts that do real work: by Hölder, a nontrivial DISCRETE Archimedean totally ordered abelian group is isomorphic to Z, and a nontrivial DEDEKIND-COMPLETE one is Archimedean hence isomorphic to Z or R -- so the complete class is exactly {Z, R} up to isomorphism and the dense-and-complete class is exactly R.

COMPLETENESS. State \label{cor:tm-completeness} exactly as it stands and do not soften it: TM, TM_f, TM_d, TM_c, TM_dc are SOUND over their classes but NONE IS COMPLETE; completeness is carried by the BL^+ systems -- TM^+_d weakly complete over the full Dense class (machine-checked, sorry-free); TM^+_f weakly complete over Z-time (machine-checked over the successor-Archimedean class); TM^+_c weakly complete over the dense-and-complete class, exactly R (machine-checked); TM^+ weak completeness over all task frames is the stated formalization TARGET with one obligation outstanding, NOT an established theorem. Strong completeness is the aim for TM^+ and TM^+_d with no known obstruction; it PROVABLY FAILS for Z-time and for R, where compactness fails. Nothing is asserted about compactness of the full discrete class in either direction. Record also the deletion of the conservative-extension theorem and the four-part replacement status at \label{def:TMplus}'s footnote (backward unconditional; forward fails for base via (DD) and for discrete via \aitem{TMP-Z1} over Z x_lex Z; open for dense and complete).

DECIDABILITY -- USER-CONFIRMED FRAMING, 2026-08-13. State it FAITHFULLY AS OPEN, per \label{cor:tm-decidability}: "Whether TM, TM_f, TM_d, TM_c, and TM_dc are decidable is open." Do NOT present a decidability theorem. Give the honest anatomy: each system is recursively axiomatized so its theorems are r.e. regardless of completeness; decidability additionally needs the non-theorems r.e., standardly via a finite model property; the former blanket FMP-over-D=Z premise is RETRACTED AS FALSE, with two witnesses -- \aitem{DF} is a non-theorem of TM, TM_d, TM_c, TM_dc yet valid in every model over D = Z, and \aitem{CO} is a non-theorem of TM_f (witnessed by Z x_lex Z) yet likewise valid over D = Z; a repaired FMP must be CLASS-SPECIFIC and range over effective non-Archimedean carriers such as Z x_lex Z rather than Z alone. What exists here: a verified SOUND tableau procedure, and ongoing formalization of the semantic, truth-connected FMP for the Z-time discrete case. What would suffice: decidability of Log(all task frames) = Log(Discrete) intersect Log(Dense) follows from decidability of the two factor logics; decidability of Log(complete frames) = Th(Z) intersect Th(R) follows from decidability of Th(Z) and Th(R) separately. That intersection reduction is the target STRATEGY, not a result.

3.3 PAIN POINT ONE -- THE CONTINGENCY OF THE TEMPORAL AXIOMS. This is the section the user singled out and it should be the most carefully written prose in the report.
- The three frame conditions (Discrete, Dense, Complete) and the axioms characterizing them (\aitem{DF}, \aitem{DN}, \aitem{CO}), with the systems TM_f, TM_d, TM_c, TM_dc.
- No temporal order is both discrete and dense, so TM cannot consistently contain both DF and DN.
- The bite: since every possible world is defined over the frame's own temporal order D, the structure D has -- discrete or dense, Dedekind complete or not -- holds OF METAPHYSICAL NECESSITY for that system. If D is dense then \aitem{DN} AND its necessitation Box(FF phi -> F phi) are valid over that frame.
- The worry, stated at its strongest: Dorr and Goodman (2020, p. 656) express sympathy for an account of metaphysical modality able to express theses about the contingency of the structure of time. Present this as a real cost, not a strawman.
- The paper's IRREGULAR WORLDS response and its EXACT price. Relax totality, admitting functions tau : X -> W where X is a COSET DOMAIN -- a translate G + c of a nontrivial subgroup G <= D -- with tau(x) =>_{y-x} tau(y) throughout, and define consequence over the irregular and possible worlds alike. Cosets rather than subgroups, because a family of translates is closed under ambient translation and so preserves \aitem{MF} and the perpetuity principles, which the subgroup formulation loses. THE PRICE IS EXACT AND MUST BE STATED EXACTLY: every nontrivial ordered abelian group contains a discrete cyclic subgroup, so \aitem{DN} is then valid over NO frame whatever; \aitem{DF} fails over discrete orders possessing a subgroup that is itself dense, such as Q x_lex Z; the correspondence results \label{app:discrete}, \label{app:dense}, \label{app:complete} LAPSE TOGETHER; and the broadened operator, while still factive, normal, and closed under necessitation relative to the broadened consequence relation, is DISPLACED from its standing as the strongest objective modality.
- The paper's DEFENSE, which the report should present fairly and then evaluate: necessity-if-true of density is an instance of the completely general fact that frame validity is closed under necessitation, with the Kripke B/symmetry case as precedent (over symmetric frames both B and Box-B are valid, and nobody counts this against the relational treatment of B); structural disputes about metaphysical accessibility -- S4 vs S5, whether the objective modalities are closed under converses -- are already conducted as questions about which frame class and logic are correct, never as claims that transitivity or symmetry is metaphysically contingent. Since possible worlds are only ever defined over a single frame, no modality quantifies across frames.
- What the irregular worlds DO and DO NOT deliver: they express contingency in the structure and cardinality of the time series, but NOT composition contingency of the catastrophe or proper-initial-segment kind, since a difference-closed domain is a subgroup (or a translate of one) and so unbounded in both directions either way.
- Close with the residual question the report should state rather than resolve: is there a semantics that recovers temporal-structure contingency without lapsing the correspondence results? The paper names a semantic class CLOSED UNDER DISJOINT UNION as the natural target, under which the Halldén phenomenon dissolves structurally. Connect this forward to 3.5.

3.4 PAIN POINT TWO -- THE SPLIT VALIDITY AND TM'S SEMANTIC INCOMPLETENESS. Give this its own short section; it is the sharpest formal result among the pain points and it is closely tied to 3.3.
- The dichotomy: every nontrivial totally ordered abelian group is either discrete (least positive element) or dense, never both. Give the two-line proof (if no least positive element then for x < y some positive e < y - x exists, giving x < x + e < y by translation invariance; conversely a least positive e forbids anything strictly between x and x + e). NOTE explicitly that the dichotomy depends essentially on the GROUP structure -- it fails for bare linear orders such as a copy of Z followed by a copy of the rationals -- and is exhaustive precisely because translation invariance globalizes any local witness.
- Hence Log(all task frames) = Log(Discrete) intersect Log(Dense), and the class of all task frames is NOT closed under disjoint union.
- Hence (DD): the schema Box phi_DF or Box psi_DN for arbitrary instances of \aitem{DF} and \aitem{DN} (no variable-disjointness restriction; \aitem{TD} supplies the past mirrors) is valid over every task frame yet TM-unprovable, refuted on a TWO-FIBRE structure -- one fibre over Z, one over R, Box read globally over both -- which is TM-sound because no TM axiom or rule constrains how Box interacts across fibres. DIAGRAM THIS.
- The careful taxonomy, which the report must not blur: TM is SEMANTICALLY incomplete (a formula valid but unprovable), NOT Halldén-incomplete. TM + (DD) would CREATE Halldén-incompleteness (proving a variable-disjoint disjunction while proving neither disjunct, since each fails soundness on the complementary subclass). Halldén-incompleteness of Log(all task frames) ITSELF is a THEOREM -- the correct formal signature of a class that is a union of two incompatible kinds -- and not a defect.
- In BL^+, (DD) is already a theorem with no added axiom (\aitem{TMP-NB} and \aitem{M5} give Box Next-top or Box not-Next-top), which inherits TM^+'s outstanding base-case obligation; carry that hedge. The schematic form (DD) takes in BL records nothing about the semantics and everything about the LANGUAGE: BL has no sentence naming discreteness, so it must disjoin schemas where BL^+ disjoins a sentence with its negation.
- TM_c fails identically over {Z, R}. TM_f's status is DIFFERENT and must not be lumped in: it is sound over EVERY discrete frame (DF is valid there), but its completeness over that broader class is OPEN -- the machine-checked discrete result is for BX_f over Z-time specifically, a narrower and deductively stronger system than TM + DF, and no counterexample to TM_f's completeness over the full discrete class is known.

3.5 PAIN POINT THREE -- AXIOMATIZING THE STRONGEST OBJECTIVE MODALITY. Compress the paper's \label{app:ObjectiveModality} to its load-bearing structure.
- The setup: BL extended with a primitive propositional identity operator and higher-order quantifiers (\label{def:id}, with \aitem{Ref}, \aitem{Imp}, \aitem{LL}); operator variables over an unrestricted domain of operations on propositions; the objective modalities AXIOMATIZED by a primitive predicate O on operator terms rather than defined outright, following the theory of necessities in Bacon (2022). PREDICATIVITY: operator comprehension confined to formulas containing no operator variables and no occurrences of O, blocking Russell-Myhill and keeping the system consistent with a fine-grained identity; cite Walsh (2016) for the consistency proof of a predicative restriction of Church's intensional logic, and note that predicativity could be dropped by strengthening the theory of identity, since coarse-grained identity blocks Russell-Myhill.
- \label{def:strongest}, verbatim in substance: Q is a STRONGEST OBJECTIVE NORMAL MODAL OPERATOR in L -- Str^O_L(Q) -- iff (1) |- O(Q), and (2) |- forall P [O(P) -> (Q <= P)], where <= is the dominance ordering. Objectivity and normality need not be stated separately: clause (1) already entails objectivity, the axiom condition, and normality. \label{thm:exist}: Str^O_L(Bm) -- the MEET operator Bm witnesses existence, clause (1) being the second conjunct of \aitem{O-Meet} and clause (2) following from the first, with T, N, K and closure under necessitation obtained by detaching \aitem{O-Fac}, \aitem{O-Ax}, and \aitem{O-Nec} at Bm. \label{lem:uniq}: any two strongest objective normal modal operators are provably equivalent, |- forall p (Q p <-> P p). \label{thm:s4}: Str^O_L(Q) yields |- forall p (Q p -> Q Q p). \label{thm:sym}: Str^O_L(Q) yields |- forall p (p -> Q Dual-Q p). So under the hypothesis Str^O_L(Box), lem:uniq gives |- forall p (Box p <-> Bm p), thm:s4 gives the S4 axiom, thm:sym gives the B axiom, and factivity and necessitation for the primitive Box follow by detaching \aitem{O-Fac} and \aitem{O-Nec} at Box -- together delivering an S5 logic for Box. Note that \label{cor:exists} is a SEPARATE, weaker route to existence that buys it at the price of a coarse-grained identity the paper does not assume; thm:exist replaces reliance on it, and the report should not present cor:exists as the paper's existence result.
- THE ORTHOGONALITY POINT, which the report should foreground because it is what makes the characterization non-trivial: S5-hood alone CANNOT single Box out. The paper's own restricted case is the counterexample -- the stability modality is likewise S5 (its accessibility partitions H_F into equivalence classes) and yet on non-temporal formulas it collapses to the trivial modality. A strictly narrower accessibility relation can carry a strictly stronger logic; it is <=-leastness, not S5-hood, that picks Box out.
- THE PAIN: what is actually axiomatized here is a HIGHER-ORDER theory of the objective modalities, not a BL-level or BL^+-level proof system, and the connection between the two levels is a hypothesis (Str^O_L(Box)) adopted afresh for each system under study rather than a theorem of TM or TM^+. State plainly what this leaves open: whether the leastness characterization is expressible or derivable at the propositional level at all; what a propositional axiomatization would have to add; whether the frame-relative plurality of Box operators is genuinely benign (the paper argues it is, since no cross-frame rival is even formulable within the theory and a reader wanting absoluteness may take the universal system); and how the irregular-worlds broadening of 3.3 interacts, given that it DISPLACES Box from its standing as Str^O_L(Box) -- so the two pain points are not independent, and the report should say so.

3.6 THE COMPLETENESS CONSTRUCTION AS IMPLEMENTED HERE. This section and 3.7 are, per the user, the most important part of the report. Describe what is actually in `FormalSystem/Metalogic/`, with named anchors and HONEST status for each, verified against the live tree at authoring time.
- The core layer: consistency, maximal consistent sets, negation-completeness, the deduction theorem, and Lindenbaum via Zorn (`Metalogic/Core/`, `set_lindenbaum` in `Core/MaximalConsistent.lean`). Note the set-level `SetConsistent` / `SetMaximalConsistent` layer is correctly finitary.
- The architecture: contraposition -- if phi is underivable then {not phi} is consistent and extends to an MCS containing not phi -- followed by a THREE-WAY CASE SPLIT on the discreteness indicator U(top, bot), i.e. on whether Box-not-Next-top or Box-Next-top is in the MCS, with the MIXED CASE ELIMINATED OUTRIGHT (`mcs_mixed_case_absurd`): an MCS cannot be undecided about discreteness. Diagram this split. Note the structural rhyme with (DD) in 3.4 -- the same discrete/dense dichotomy that BREAKS TM at the BL level is what MAKES the BL^+ construction go through, because BL^+ has a sentence naming discreteness and BL does not. This is the single most illuminating connection in the report; make it explicit.
- The dense path: the Burgess-style CHRONICLE construction over Q (`Metalogic/BXCanonical/Chronicle/`), filling in Until/Since eventualities, with `completeness_dense` in `BXCanonical/Completeness.lean`.
- The discrete path: the Reynolds/Doets pipeline over Z (`Metalogic/WeakCanonical/`, `Transfer.lean`), running through a Kamp-theorem-based expressive-completeness argument (`WeakCanonical/Kamp/`, `Separation/`, `EFGames/`, `Expressiveness/`).
- The Dedekind path, which the reference book currently omits entirely: `BXCanonical/CompletenessDedekind.lean`, `Metalogic/StrongCompleteness.lean` (`completeness_dedekind`, `consequence_completeness_dedekind`), the `RealModel/` subtree (Doets, shuffle, order-iso-to-R), on the Reynolds-triple basis Prior-U + Sep with CO derived.
- The shared infrastructure: bundled families of MCSs with G/H coherence (`Metalogic/Bundle/`, BFMCS); the D-PARAMETRIC algebraic truth lemma (`Metalogic/Algebraic/`) that turns a coherent MCS family into a task model -- this parametricity is exactly what lets one construction serve several carriers and deserves emphasis; filtration and quasimodels (`BXCanonical/Filtration/`, `Quasimodel/`).
- STATUS DISCIPLINE. For every headline result, state sorry-status and axiom profile as MEASURED, not as remembered. Use `#print axioms` and the repository's own count script; `bash scripts/typst-status-counts.sh` is the authority for aggregate sorry counts (a naive grep over `FormalSystem/` overcounts badly, since it catches commentary and `Boneyard/`). Do not describe `Boneyard/` content as live. Where the predecessor task's findings note flags an anchor as exposed to the in-flight Lean chain, re-verify it rather than inheriting it.
- THE TERMINOLOGY IS SETTLED PROJECT-WIDE AND MUST BE USED CORRECTLY: "strong completeness" is reserved for consequence from possibly-INFINITE premise sets; because contexts are finite lists, any finite-context consequence statement is inter-derivable with weak completeness through the deduction theorem and is called CONSEQUENCE COMPLETENESS, never strong. The in-tree authority is the module docstring of `Metalogic/StrongCompleteness.lean`.

3.7 EARLY STEPS TOWARD A REPRESENTATION THEOREM, AND THE WAY FORWARD. The report's terminus, and the reason it exists.
- FIRST, A WARNING THAT MUST BE HEEDED. `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/metalogic.tex` contains a section titled "Representation Theorem" with a canonical model over Z, a Truth Lemma, and Weak/Strong Completeness theorems for TM. It is a SUPERSEDED SCRAP that is NOT part of the current paper (the paper's own preamble forbids \input of other tex files, and possible_worlds.tex does not include it). Its central claims CONTRADICT \label{cor:tm-completeness}: it asserts that TM is sound AND COMPLETE over the class of all task semantic frames and that TM is strongly complete, both of which the current paper REFUTES via (DD). Its Compositionality proof is hand-waved ("we can construct a history..."), its Box case assumes global agreement across all canonical histories, and its Nullity/Compositionality remark asserts frame properties the current four-axiom def:frame handles differently. DO NOT LIFT ANY OF IT. It may be cited only as a historical waypoint, and only with its defects named. If any of its statements are to be salvaged, they must be re-derived against the current def:frame and cor:tm-completeness.
- WHAT ACTUALLY EXISTS HERE AS EARLY REPRESENTATION WORK, and it is real: (a) the ALGEBRAIC layer -- `Metalogic/Algebraic/BooleanStructure.lean`, `LindenbaumQuotient.lean`, `UltrafilterMCS.lean`, `InteriorOperators.lean`, `FlowFrame.lean` -- the Lindenbaum-Tarski algebra, its ultrafilters, and the interior-operator treatment of the modalities; (b) the SHIFT-SET representation programme, which is the live gate for the whole strong-completeness branch: prove in both directions that the task-model class is representable by shift sets <Omega, D, sh, A> with D an ordered abelian group, Omega a nonempty type carrying a D-action sh, and A : Atom -> Omega -> Prop -- the point being that the task-model class is then first-order axiomatizable over the two-sorted signature <Omega, D; <, +, 0, sh, (A_p)> BECAUSE the frame's algebraic content reaches truth only through the atom clause; (c) the JONSSON-TARSKI programme -- complex algebra Cm(F) of a task frame, ultrafilter frame Uf(A) of an abstract algebra, and the embedding eta(a) = {U : a in U} -- with the recorded and important obstruction that *Spherical* for an ultrafilter frame is a genuinely nontrivial NEW obligation, and that the finite-W discharge pattern (subset-least member of a finite directed family, \label{cor:spherical-finite}) does NOT apply to ultrafilter frames, which are typically infinite.
- THE WAY FORWARD -- this is the section the user most wants, and it should be a reasoned OUTLINE with named obstructions, not a wish list. Target: a fully adequate representation theorem and completeness for a very weak, GENERAL base bimodal logic assuming neither density nor discreteness nor perhaps even Dedekind-completeness, abstracting away as much as possible. Address at minimum:
  (a) WHAT MUST BE WEAKENED. Which of def:frame's four axioms are genuinely needed for a representation theorem, and which are strengthenings that could be dropped or made parametric? *Spherical* is the prime suspect -- it is the axiom that is hardest to discharge at infinite carriers, and it is exactly what the Jonsson-Tarski route stumbles on. Is there a weaker completeness/saturation condition that suffices for the Step Lemma?
  (b) THE GROUP STRUCTURE IS THE CRUX, AND IT CUTS BOTH WAYS. The discrete-or-dense dichotomy -- the very thing that makes TM incomplete -- is a THEOREM ABOUT ORDERED ABELIAN GROUPS and fails for bare linear orders. So the most obvious abstraction, dropping D from an ordered abelian group to a linearly ordered set (or a monoid, or a partially ordered group), DISSOLVES the (DD) obstruction outright. What does it cost? \aitem{MF} and the perpetuity principles depend on translation invariance; the converse convention depends on negation; Compositionality is stated in terms of addition. The report should work out, honestly, what survives each weakening -- this is the single most valuable analysis it can contain.
  (c) DISJOINT-UNION CLOSURE. The paper names a semantic class closed under disjoint union as the natural target under which the Halldén phenomenon dissolves structurally, and \S\ref{sub:Extension}'s irregular worlds are its gesture in that direction. Is the coset-domain construction of 3.3 the right route, given that its price (DN valid over no frame; DF failing over Q x_lex Z; correspondence lapsing) is precisely a LOSS of the correspondence results a representation theorem would want? Or is a genuinely multi-frame semantics needed, and what would Box then quantify over?
  (d) THE ALGEBRAIC ROUTE VS THE SHIFT-SET ROUTE. Which is likelier to reach a general representation theorem, and are they the same theorem twice? The shift-set route's payoff is first-order axiomatizability and hence a compactness/ultraproduct argument; the Jonsson-Tarski route's payoff is a canonical embedding and duality. State what each would deliver and where each currently stops.
  (e) WHAT WOULD COUNT AS ADEQUATE. Be explicit about the acceptance standard, since the surrounding project's is: a sorry-free Lean statement of BOTH directions with `#print axioms` reporting no `sorryAx`. A statement that type-checks with a sorry body does not count; one direction does not count; a prose argument does not count.
  (f) WHAT IS FORECLOSED. Genuine strong completeness is IMPOSSIBLE for Z-time and for R (compactness fails; there is an explicit non-compactness witness recorded here for the successor-Archimedean discrete case, and Reynolds (1992) establishes the analogous failure over R). Any "way forward" that promises strong completeness for those classes is wrong on arrival. Base and Dense are open, not settled, and the relevant missing piece is a MODEL-EXISTENCE theorem (every consistent SET satisfiable in a class frame), which does NOT follow from the single-formula countermodel engines already built.

=== 4. DIAGRAMS ===
Use cetz, matching the reference book's existing light-cone-diagram style. At minimum: the two-fibre Z/R countermodel witnessing (DD); the three-way discreteness-indicator case split driving the completeness architecture; and one diagram for the representation-theorem landscape (algebraic route and shift-set route, what each connects, and where each currently stops). Additional candidates if space allows: the fiber/cone/segment apparatus; the frame-class lattice Base/Dense/Discrete/Dedekind. A diagram that only restates a formula does not earn its space.

=== 5. ACCEPTANCE ===
1. `cd typst && typst compile FormalFoundations.typ build/FormalFoundations.pdf` succeeds, no unresolved references or citations, body ~10 pages.
2. `bash scripts/typst-sync-check.sh` still passes with the new file present -- every backticked Lean name in it resolves under `FormalSystem/` (excluding `Boneyard/`), or is whitelisted with a one-line reason.
3. `bash scripts/check-paper-definitions.sh` exits case (a) or (b), run immediately before the final pass over quoted definitions.
4. Every claim about Lean status is MEASURED at authoring time (`#print axioms`, `lake build`, `scripts/typst-status-counts.sh`) and dated in the text or a footnote, not recalled.
5. Every "open" is marked open and every "target" marked target. The report's value is that a reader can trust its status claims; one overstatement destroys that.
6. `typst/README.md` documents the new build target.

=== 6. NON-GOALS ===
NO Lean implementation -- this is a report, and any formalization gap it identifies is recorded, not closed. NO edits under /home/benjamin/Philosophy/Papers/ -- the paper is READ-ONLY ground truth, and `metalogic.tex` is read-only AND superseded (section 3.7). NO changes to `BimodalReference.typ` or `typst/chapters/` -- that is the predecessor task's territory; if this report finds a book defect, record it in this task's `reports/` and raise it rather than editing across the boundary. NO changes to `latex/`. Do NOT cite task numbers anywhere in `typst/**` (repository rule: deliverables carry durable anchors, never ephemeral task-management metadata). Do NOT propose or assert a decidability theorem (section 3.2). Do NOT restate `metalogic.tex`'s completeness claims in any form.

=== 7. CITATION DISCIPLINE ===
Identical to the predecessor task's: run `bash scripts/check-paper-definitions.sh` and read `specs/paper-definitions-of-record.md` before quoting any definition; cite by \label or \aitem key ONLY, never by line number; quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search; STOP on a case-(c) FAIL rather than quoting a drifted anchor. Anchors this report needs that the record file may not yet track (check, and extend the record file per its own four-step protocol if it does not): \label{def:strongest}, \label{thm:exist}, \label{lem:uniq}, \label{thm:s4}, \label{thm:sym}, \label{def:id}, \label{cor:tm-completeness}, \label{cor:tm-decidability}, \label{def:TMplus}, \label{def:TMplus-f}, \label{def:TMplus-d}, \label{def:TMplus-c}, \label{def:BX}, \label{def:S5}, \label{app:discrete}, \label{app:dense}, \label{app:complete}, \label{thm:TM-soundness}, \label{thm:M5-valid}.

---

### 442. Revise bimodal reference book against paper and lean
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: paper-refactor
- **Dependencies**: None
- **Plan**: [442_revise_bimodal_reference_book_against_paper_and_lean/plans/01_book-paper-lean-revision.md]
- **Summary**: [442_revise_bimodal_reference_book_against_paper_and_lean/summaries/01_book-paper-lean-revision-summary.md]
- **Research**: [442_revise_bimodal_reference_book_against_paper_and_lean/reports/02_revision-findings.md]

**Description**: ABSORBS AND SUPERSEDES 427 (`sync_typst_book_with_refactored_paper`), which is marked [EXPANDED] by this task's creation. 427's quote-backed anchor content is carried forward VERBATIM in sections 3 and 9 below and remains binding; nothing in 427 is discarded except its gating and its narrow definitional-only remit. Do not re-read 427 for instructions -- this description is authoritative over it.

GOAL. Revise the BimodalReference book (`typst/BimodalReference.typ` and all of `typst/chapters/`) so that it is (a) FAITHFUL to the paper at /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex and to the Lean tree as it currently stands, and (b) ADEQUATE AS EXPOSITION -- a skillfully written reference with a real introduction, motivating remarks where a reader needs them, diagrams wherever a diagram carries the idea better than prose, and references that resolve. Accuracy is the floor here, not the ceiling. The book currently fails both tests.

=== 1. GATING DECISION -- BINDING, USER-APPROVED 2026-08-13 ===
427 was gated behind 414/415/417/419/420 with the rationale "WHY THIS RUNS LAST." That gate is LIFTED. This task proceeds NOW against the paper as ground truth and the Lean tree as it currently stands. `dependencies` is deliberately empty.

The cost of lifting the gate is accepted and must be MANAGED, not ignored: 415 (`completeness_over_total_history_semantics`, [IMPLEMENTING]) will move canonical-frame and completeness anchors; 417 (`semantic_fmp_finite_worldstate_over_z`, [PLANNED]) will move the FMP anchors; 419 (`machine_check_co_reynolds_independence`, [PLANNED]) will land the CO/Reynolds-triple independence result. Therefore: wherever a claim's Lean anchor sits in territory those three will touch, write the claim so the PROSE survives the anchor moving, and mark the anchor itself in a form a follow-up sweep can find mechanically. Use a single consistent marker string for these (choose one, document it in `typst/README.md`, and list every occurrence there) so the later re-sync is a grep, not a re-audit. Paper-anchored content is NOT subject to this hedging: the paper is stable ground truth and its claims are written plainly.

=== 2. VERIFIED STATE OF PLAY -- MEASURED 2026-08-13, DO NOT RE-DERIVE ===
`bash scripts/check-paper-definitions.sh` -> EXIT 0, case (b): "possible_worlds.tex changed (new checksum c91b9799f124f31c46b9007bcb05b499294cd0faa77f7309193723bd50839762, last-touching commit f56cdea0237d102edbb9c64dcef7617d8d2cbc3e) but all 26 recorded definitions are unchanged -- pass." Proceed; re-run before quoting anything, and STOP on case (c).

`bash scripts/typst-sync-check.sh` -> FAIL. This is the concrete work list and it is not optional. Check 1 reports TOTAL_VIOLATIONS=25; Check 2 reports MISMATCH_COUNT=3; Check 3 is clean.

CHECK 1 -- 25 unresolvable backticked names. These fall into three kinds, and the kinds need different treatment:
  (i) PATHS TO DELETED MODULES -- the book cites Lean files that do not exist. `Metalogic/DenseSoundness.lean` and `DenseSoundness.lean` (04-metalogic.typ); `Metalogic/DiscreteSoundness.lean` and `DiscreteSoundness.lean` (04-metalogic.typ); `ConservativeExtension/` (04-metalogic.typ); `Metalogic/ConservativeExtension/` (03-proof-theory.typ, 06-notes.typ, p2-frame-classes.typ, p3-ltl-to-tm.typ); `Metalogic/ConservativeExtension/Lifting.lean` (06-notes.typ); `Metalogic/ConservativeExtension/Lifting.lean:683-695` (p2-frame-classes.typ); `FMP/DenseFMP.lean` and `FMP/DiscreteFMP.lean` (p2-decidability-practice.typ); `Bridge.lean` (05-theorems.typ); `ExtFormula.lean` (p2-frame-classes.typ).
  (ii) IDENTIFIERS THAT DO NOT EXIST -- `FMP.assignmentSpace_card`, `FMP.filtered_world_bound` (p2-decidability-practice.typ); `exists_fresh_atom`, `liftDerivationWith` (p2-frame-classes.typ); `lift_derivation_qfree` (06-notes.typ, p2-frame-classes.typ, p3-ltl-to-tm.typ); `rabinovich_translate` (p3-vlach-blstar.typ).
  (iii) EXPOSITORY SPANS the checker cannot resolve because they are prose-in-backticks, not names -- `L.map embedFormula`, `embedFormula φ`, `⊥ U φ` (p2-frame-classes.typ); `Nat.card (FilteredWorld φ) ≤ 2^(|op("closure")(φ)|)`, `Nat.card (Set ↥(subformulaClosure φ)) = 2^(|op("closure")(φ)|)`, `allClosed arrow.r "valid"`, `and True` (p2-decidability-practice.typ).
For (i) and (ii), the rule is: find the live replacement and repoint, or -- if the claim itself no longer holds -- DELETE THE CLAIM. Do NOT whitelist a dead path to silence the checker. That is the failure mode the checker exists to catch. For (iii), whitelist deliberately in `typst/sync-check-whitelist.txt` with a one-line reason each, or reformat so the span is no longer backticked as if it were a Lean name.
THE CONSERVATIVE-EXTENSION CLUSTER IS THE LARGEST SINGLE ITEM and is NOT a repointing job -- see section 4.

CHECK 2 -- 3 stale counts in `typst/generated/status.typ`: sorry-total committed=8 live=5; sorry-total-excl-boneyard committed=4 live=1; sorry-table[Core/, Decidability/, SoundnessLemmas/, top-level] committed=3 live=0. Fix by running `bash scripts/typst-status-counts.sh`, never by hand-editing the generated file. `scripts/typst-status-counts.sh` is the AUTHORITY for every count the book states; a naive `grep -c sorry` over `FormalSystem/` returns a much larger number because it counts commentary and Boneyard, and any dispatch that hand-writes a count from such a grep has introduced a defect. Re-run the script and quote it.

=== 3. WHAT THE BOOK MUST SAY ABOUT THE SEMANTICS -- CARRIED FORWARD FROM 427 VERBATIM, STILL BINDING ===
Paper anchor \label{def:frame}, verbatim: "A *frame* is any F = <W, D, =>> where W is a nonempty set of world states, D is a temporal order, and => is a task relation satisfying the following for x, y >= 0: *Compositionality:* w =>_{x + y} v if and only if w =>_x u and u =>_y v for some u in W. *Seriality:* w =>_x u and v =>_x w for some u, v in W. *Limit:* intersection over x > 0 of (w)_x = {w}. *Spherical:* intersection of S is nonempty for any directed family S of nonempty fibers and segments."

FOUR axioms. Nullity is NOT among them: \label{lem:nullity}, verbatim, "w =>_0 w for every world state w in W in every frame F = <W, D, =>>", derived choice-free from *Seriality* at x = 0 plus *Limit*. Reflection is likewise not an axiom -- negative durations come from the converse convention.

Supporting definitions the frame definition presupposes:
- \label{def:temporal-order}: "A *temporal order* is a nontrivial totally ordered abelian group D = <D, +, 0, <=> with *positive cone* D^+ := {x in D : x >= 0}."
- \label{def:task-relation}: a task relation on a NONEMPTY set of world states W over a temporal order D, "extended to negative durations by the *converse convention* w =>_{-x} u := u =>_x w for x >= 0", determining -- Fiber: Fib(w, x) := {u in W : w =>_x u}; Cone: (w)_x := union over |y| < x of Fib(w, y) where x > 0; Segment: [w, v]_x^y := Fib(w, x) intersect Fib(v, -y) where x, y >= 0.
- \label{def:directed}: "A nonempty family of sets S is *directed* just in case S' subset-of S_1 intersect S_2 for some S' in S whenever S_1, S_2 in S."
- \label{def:world-history}: "A *partial history* over a frame F = <W, D, =>> is a function tau : X -> W on a nonempty set X subset-of D where tau(x) =>_{y-x} tau(y) for all times x, y in X. ... A *world history* is any partial history whose domain X is *convex* ... A world history is *total* --- equivalently, a *possible world* --- just in case X = D. ... The set of all total world histories over F is denoted H_F." The layering is partial history, then world history (convex domain), then total. A partial history requires a NONEMPTY domain and does NOT require convexity.
- The existence machinery, if the book states it: \label{def:constraints} defines the constraints a new time imposes; \label{lem:constraint} (Constraint Lemma) shows they form a directed family of nonempty fibers and segments; \label{lem:fibers} and \label{lem:admissible} characterize admissible one-point extensions; \label{lem:step} (Step Lemma) applies *Spherical* and closes via lem:admissible to extend a partial history by one duration; \label{thm:extension} runs Zorn over partial histories and closes via lem:step; \label{cor:occurrence} follows (a MERGED anchor -- the former thm:occurrence and app:nonempty no longer exist), giving tau(x) = w at any prescribed time x and H_F nonempty for every frame. \label{cor:spherical-finite}: "Every frame F = <W, D, =>> with finite W satisfies *Spherical*, choice-free."
- \label{def:BL-semantics} evaluates at "a possible world tau in H_F and time", with the box clause quantifying over all sigma in H_F and the atom clause carrying no domain conjunct; \label{def:logical-consequence} quantifies over models, possible worlds tau in H_F, and times x in D.

THREE VOCABULARY AND NOTATION TRAPS -- writing any of these into the book is precisely the failure this task exists to prevent:
(a) Segments are written [w, v]_x^y with the defining equation above. The paper's old `\Seg` macro is DELETED from its preamble and survives only inside commented-out lines; function-application segment notation is not current notation.
(b) *Spherical* ranges over directed families of nonempty FIBERS AND SEGMENTS as two SEPARATE classes, with directedness per \label{def:directed}. The retired device by which one-sided fibers counted among the segments must not be reintroduced. The lemma formerly cited for the two-sided segment family no longer exists in the paper -- cite lem:constraint and lem:step.
(c) The vocabulary "task-constrained function" is RETIRED paper-wide. Use "partial history", "world history", and "total world history" / "possible world".

GENERATIONAL GAP, carried forward from 427 and now one generation worse again: `typst/chapters/02-semantics.typ` still independently axiomatizes Reflection, has no Limit clause at all, and predates the positive-cone / converse-convention presentation entirely. Its prose gloss repeats the same errors AND frames the mixed-sign Compositionality form as a Lean/paper divergence -- that framing is INVERTED (the paper ADOPTED the positive-cone presentation, so the book should record AGREEMENT). Re-audit the stale-site list against the current four-axiom paper; do not trust any prior enumeration, including this one.

NOTATION (binding user decision, carried forward unchanged): any explicit converse operation on the task relation is written with a superscript inverse -- Rightarrow^{-1} / R^{-1} -- NEVER the relation-algebra breve/smile common in the arrow-logic literature. The paper states the converse convention with subscript negation only and introduces no operator symbol at all; introduce none unless one is genuinely needed.

=== 4. THE COMPLETENESS STORY IS REVERSED, NOT MERELY STALE -- THIS IS THE HEADLINE CORRECTION ===
`typst/chapters/04-metalogic.typ` currently says, in three places, that "the completeness of TM with respect to its frame classes remains an open problem" (and `BimodalReference.typ`'s abstract says the same). That is not what the paper says, and the difference is not one of degree.

Per \label{cor:tm-completeness}, verbatim in substance: "TM and its extensions TM_f, TM_d, TM_c, and TM_dc are sound over their respective classes of all, discrete, dense, complete, and dense-and-complete task frames, but NONE IS COMPLETE; completeness is carried instead by the following BL^+ systems: TM^+_d -- weakly complete over the dense frames, machine-checked, sorry-free, over the full Dense class. TM^+_f -- weakly complete over Z-time, machine-checked directly over the successor-Archimedean class. TM^+_c -- weakly complete over the dense-and-complete class, exactly R, machine-checked directly. TM^+ -- weak completeness over all task frames is the stated Lean-formalization target; one proof obligation remains outstanding, so this is not yet an established theorem."

So TM is not "open"; TM is PROVABLY INCOMPLETE, and the book must say why, because the reason is one of the most interesting things in the system:
- Every nontrivial totally ordered abelian group is either discrete or dense and never both (translation invariance globalizes any local gap or density witness; the dichotomy FAILS for bare linear orders, e.g. a copy of Z followed by a copy of the rationals).
- Hence Log(all task frames) = Log(Discrete) intersect Log(Dense), and the class of all task frames is NOT closed under disjoint union.
- Hence a SPLIT VALIDITY named (DD): the schema Box phi_DF or Box psi_DN, for arbitrary instances of \aitem{DF} and \aitem{DN}, is valid over every task frame yet TM-unprovable, refuted on a TWO-FIBRE countermodel (one fibre over Z, one over R, with Box read globally over both) over which every TM axiom and rule remains sound.
- TM is therefore SEMANTICALLY incomplete, NOT Halldén-incomplete -- the book must not confuse these. TM + (DD) would CREATE Halldén-incompleteness. Halldén-incompleteness of Log(all task frames) itself is a THEOREM and the correct formal signature of a union of two incompatible kinds, not a defect.
- In BL^+, (DD) is already a theorem with no added axiom, via \aitem{TMP-NB} and \aitem{M5} giving Box Next-top or Box not-Next-top. This inherits TM^+'s own outstanding base-case obligation and the book must carry that hedge, not drop it.

THE CONSERVATIVE-EXTENSION THEOREM IS DELETED FROM THE PAPER. `thm:ConservativeExtension` no longer exists; the footnote at \label{def:TMplus} replaces it and makes NO conservativity claim. Backward direction (every BL-theorem of TM etc. survives in TM^+ etc.) holds unconditionally; the FORWARD direction FAILS for the base case (witnessed by (DD)) and unconditionally for the discrete extension (witnessed by \aitem{TMP-Z1}, unsound over Z x_lex Z), and remains open for dense and complete. Every book passage that presents conservativity as an established result -- and there are several, clustered around the dead `Metalogic/ConservativeExtension/` citations in 03-proof-theory.typ, 06-notes.typ, p2-frame-classes.typ, and p3-ltl-to-tm.typ -- must be rewritten to the four-part status above, not repointed to a live module. Note in passing that a separate Lean task exists to formalize a conservativity bridge; its premise is affected by this deletion. Record that as a finding for the user; do NOT modify that task from here.

=== 5. DECIDABILITY IS OPEN -- USER-CONFIRMED FRAMING, 2026-08-13 ===
\label{cor:tm-decidability} now reads: "Whether TM, TM_f, TM_d, TM_c, and TM_dc are decidable is OPEN." The former blanket finite-model-property-over-D=Z premise was retracted as FALSE, and the paper gives two witnesses: \aitem{DF} is a non-theorem of TM, TM_d, TM_c, TM_dc yet valid in every model over D = Z; \aitem{CO} is a non-theorem of TM_f (witnessed by Z x_lex Z) yet likewise valid in every model over D = Z. A repaired FMP would have to be CLASS-SPECIFIC, ranging over effective non-Archimedean carriers such as Z x_lex Z rather than Z alone; none of this is established.

What IS true and should be stated: each system is recursively axiomatized, hence its theorems are r.e. regardless of completeness; a verified SOUND tableau procedure exists in this repository; the semantic, truth-connected FMP for the Z-time discrete case is the target of ongoing formalization; and decidability of Log(all task frames) = Log(Discrete) intersect Log(Dense) would FOLLOW from decidability of the two factor logics -- that intersection reduction is the target strategy, not a result. Audit `p2-decidability-practice.typ` and `p3-decidability-frontier.typ` against this; the latter carries SLOT-IN anchors for embargoed content that must be left alone.

=== 6. FURTHER FACTUAL CORRECTIONS MEASURED IN THE LIVE TREE (2026-08-13) ===
- FOUR frame classes, not three. `FormalSystem/ProofSystem/Axioms.lean` defines `Base`, `Dense`, `Discrete`, AND `Dedekind`, with minimum-class assignment mapping `density`/`dense_indicator` to Dense, `prior_UZ`/`prior_SZ`/`z1` to Discrete, and `prior_U_gap`/`prior_S_gap`/`sep` to Dedekind. The book says "three frame classes" and "all three frame-class variants" in several places, and its `Metalogic/` module table omits the Dedekind path entirely. The Dedekind path is substantial live code: `BXCanonical/CompletenessDedekind.lean`, `StrongCompleteness.lean` (`completeness_dedekind`, `consequence_completeness_dedekind`), and the `RealModel/` subtree.
- The `Metalogic/` module table in 04-metalogic.typ is wrong in five rows. `DenseSoundness.lean`, `DiscreteSoundness.lean`, `Completeness.lean`, and `ConservativeExtension/` do not exist. Rebuild the table from the live tree; `Metalogic/` now also carries `Bundle/`, `Algebraic/`, `WeakCanonical/` (with `Kamp/`, `RealModel/`, `IntegerModel/`, `EFGames/`, `DenseModelSurgery/`, `Expressiveness/`), and `Decidability/Verified/`.
- Axiom-constructor count: read it from `bash scripts/typst-status-counts.sh` into `typst/generated/status.typ`; do not hand-count.
- The Since/Until argument-order mismatch is a KNOWN, DOCUMENTED, DELIBERATE divergence and must be stated as such rather than "fixed": the paper's surface notation phi-Since-psi / phi-Until-psi is GUARD-FIRST (phi guard, psi event), while the repository's `snce`/`untl` constructors are EVENT-FIRST (Burgess convention). The truth conditions agree once the argument order is swapped. The paper's footnote at \label{def:BLplus-semantics} states this in exactly this direction; an earlier version stated it backwards (as Pnueli guard-first), so if the book repeats the Pnueli framing it is repeating a corrected error.
- `BX_c` is re-based on the REYNOLDS TRIPLE, not on CO alone: \aitem{TMP-PU} (Prior-U) and \aitem{TMP-SEP} (Sep), with K^+ phi := not(not-phi Until top) and K^- phi := not(not-phi Since top). \aitem{TMP-CO} is a DERIVED THEOREM of BX_c using only Prior-U and the BX base -- Sep is not needed -- and that derivation is machine-checked here. Whether CO alone axiomatizes the same logic as the full triple is OPEN; the conjectured failure rests on an unformalized pen-and-paper sketch and is explicitly NOT asserted as established.
- `typst/README.md`'s follow-up table lists tasks by number for the in-progress chapters. Deliverable files must not cite task numbers (see NON-GOALS); rewrite those rows to name the scope without the numbers, or move the mapping into this task's own spec directory.

=== 7. THE EXPOSITORY MANDATE -- THIS IS HALF THE TASK, NOT A GARNISH ===
Correctness above is the floor. The user's standard is a book that reads well and teaches. Concretely:
- INTRODUCTION. `00-introduction.typ` already carries one cetz light-cone diagram and sections "What TM Is" / "Why Tense and Modality Together" / "Outline" / "How to Read This Book" / "Project Structure". Rewrite it so a reader who knows modal logic but not this system can arrive at the frame definition understanding WHY task frames rather than Kripke frames, why the temporal order is an ordered abelian group rather than a bare linear order (the discrete-or-dense dichotomy of section 4 depends on exactly this, and it is a genuinely illuminating payoff to foreshadow), and what the bimodal interaction axiom MF buys. The outline must match the book's actual current structure.
- REMARKS. Add short, clearly-marked remarks at the points where a reader predictably stumbles: why the temporal semantics is strict/irreflexive and what that costs (the temporal T-axioms are NOT valid; seriality is supplied axiomatically); why Nullity is a lemma and not an axiom; why *Spherical* is needed at all and what the finite-carrier discharge does and does not give; why S5-hood alone does not single out metaphysical necessity (the paper's own stability-modality case is the counterexample); why the perpetuity principles follow from MF and MT by classical reasoning alone.
- DIAGRAMS. Use cetz, matching the existing light-cone diagram's style. Candidates, in rough priority: the two-fibre Z/R countermodel witnessing (DD) (this is the single highest-value diagram in the book -- the incompleteness argument is much easier to see than to read); the fiber / cone / segment apparatus of def:task-relation; the three-way case split on the discreteness indicator that drives the completeness architecture; the layering of partial history -> world history (convex) -> total history; the frame-class lattice Base / Dense / Discrete / Dedekind with which axioms enter where. Do not add a diagram that merely restates a formula.
- REFERENCES. Every `@`-citation must resolve in `typst/bibliography.bib`, and the entries actually used must be correct. The book cites Burgess 1982, Reynolds 1992, Doets 1987, Kamp 1971; the paper additionally leans on Bacon 2022 (the theory of necessities), Dorr and Goodman 2020, Prior 1967, Vlach 1973, Rumberg and Zanardo 2019, Walsh 2016, and Hölder's theorem. Add what the revised text needs; do not pad. Compile and confirm no unresolved citations.

=== 8. DELIVERABLE AND ACCEPTANCE ===
1. `bash scripts/typst-sync-check.sh` exits with Check 1 TOTAL_VIOLATIONS=0, Check 2 MISMATCH_COUNT=0, Check 3 clean, with every whitelist addition carrying a one-line reason and NO dead path whitelisted.
2. `cd typst && typst compile BimodalReference.typ build/BimodalReference.pdf` succeeds with no unresolved references or citations.
3. `bash scripts/check-paper-definitions.sh` exits case (a) or (b).
4. `typst/SYNC-MAP.md` gains a new dated verdict section for this revision. Do NOT rewrite its historical tables -- the file's own header says they are a retained historical record of a superseded structure.
5. A short findings note in this task's `reports/` recording: every Lean/paper divergence found and NOT fixed here, the marker string chosen for 415/417/419-exposed anchors and every site carrying it, and the conservativity-bridge finding from section 4.

=== 9. CITATION DISCIPLINE -- BINDING ===
Run `bash scripts/check-paper-definitions.sh` and read `specs/paper-definitions-of-record.md` BEFORE quoting any definition. That file, not the paper, is what specs in this repository cite; it pins each definition with verbatim text and content hashes re-derived from the live paper on every run. Case (a) silent pass or case (b) notice -- proceed. Case (c) FAIL naming a drifted anchor -- STOP and re-issue rather than quoting. Cite by \label or \aitem key ONLY; a bare possible_worlds.tex:NNNN is never a citation and this cluster has already burned a full task on line-number drift. Quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search. Re-derive every stale Lean line-number anchor in the book rather than trusting it -- 02-semantics.typ's cited TaskFrame line number has already moved once.

=== 10. NON-GOALS ===
NO edits under /home/benjamin/Philosophy/Papers/ -- the paper is READ-ONLY ground truth. NO Lean changes: if the audit finds a Lean/paper divergence, RECORD it per section 8.5 and raise it with the user rather than fixing it here. NO changes to `latex/` -- the LaTeX mirror is separately stale and separately owned. Do NOT touch `FormalSystem/Boneyard/` or cite anything in it. Do NOT hand-edit `typst/generated/` -- regenerate. Do NOT cite task numbers anywhere in `typst/**` (repository rule: deliverables carry durable anchors -- filenames, headings, verified facts -- never ephemeral task-management metadata). Do NOT use `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/metalogic.tex` as a source for anything -- see the warning in the formal-foundations report task, which applies here identically.

=== 11. SUPERSESSION RECORD ===
427 is marked [EXPANDED] on this task's creation. Everything in 427 that remains binding has been carried into sections 3 and 9 above verbatim. What is DROPPED from 427: its gating on 414/415/417/419/420 (section 1), and its restriction to the definitional/semantic layer (sections 4-7 extend the remit to the completeness story, the decidability status, the module-structure corrections, and the expository mandate). What is CARRIED FORWARD UNCHANGED: the def:frame quote block, the supporting-definition quotes, the three notation traps, the converse-notation user decision, the audit-do-not-trust-prior-enumerations discipline, the paper-snapshot procedure, and the non-goals.

---

### 441. Effective periodic extension over finite frames
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 440

**Description**: Strengthen `thm:extension` for the finite discrete case into an EFFECTIVE result: construct a finitely representable total world history, rather than merely proving one exists. A model checker cannot ship a Zorn appeal as a certificate, and this is the theorem that lets it ship something checkable instead.

WHY. `thm:extension` is an existence result proved by Zorn's lemma; `#print axioms FormalSystem.Semantics.PartialHistory.extension` confirms the `Classical.choice` dependency (verified 2026-08-11). To certify that a bounded countermodel window really is a fragment of a total world history, a checker needs a witness it can write down and re-verify. Over the frame class the ModelChecker's Z3 search produces -- finite `WorldState`, `D = Int`, serial relation -- such a witness exists and is a lasso.

DELIVERABLE 1 -- `extend_periodic`. Given a `FiniteTaskFrame Int` with a serial relation and a partial history `t` on a FINITE domain, construct a total world history `s` in `F.HF` extending `t` that is eventually periodic in both directions: there exist `n0 p0 n1 p1` with `s (x + p1) = s x` for all `x >= n1` and `s (x - p0) = s x` for all `x <= n0`, with `p0` and `p1` bounded by the cardinality of `WorldState`. Construction: extend forward by repeatedly choosing a unit-step successor (licensed by *Seriality*); since `WorldState` is finite the forward orbit must revisit a state, closing a cycle; symmetrically backwards via the converse convention. State the relation to `thm:extension` explicitly -- this STRENGTHENS the finite case, it does not replace the general theorem, which must remain as it is for arbitrary `W` and `D`.

DELIVERABLE 2 -- A FINITE PRESENTATION. A datatype presenting such an `s` as a prefix plus a cycle in each direction, a decoding function to a total history, and a proof that decoding yields the `s` of Deliverable 1. This is the object a model checker emits and re-checks, so it should be plainly serializable -- prefer plain lists and integers over dependent packaging.

DELIVERABLE 3 -- THE AGREEMENT LEMMA, AND ITS LIMITS. Prove that the constructed `s` agrees with `t` on `dom t`, so any property depending only on the window transfers. Then state, PROMINENTLY in the docstring and not merely in passing, what does NOT transfer:
  - truth of `box phi`, which quantifies over ALL of `H_F` and not over the constructed `s`;
  - truth of `Past phi` and `Future phi`, which quantify over ALL of `D` and not over the window.
Deliverable 3 is the theorem ModelChecker 154 consumes, and these limits are exactly why that task cannot claim more than it does. A downstream reader who takes the agreement lemma as licensing the dropping of abundance constraints has misused it; make that hard to do by saying so here.

ON CHOICE. The successor selection is a choice over a finite nonempty set and should be made with decidability or `Finite.exists`-style reasoning rather than `Classical.choice` wherever practical, so the finite construction is visibly cheaper than the general one. Report the actual `#print axioms` result for `extend_periodic` in the docstring. If `Classical.choice` proves unavoidable, state that outright with the obstruction named -- do not leave it implicit and do not quietly claim constructivity the term does not have.

DEPENDENCIES. BimodalLogic 440 (the finite axiom bundle, which supplies *Spherical* and *Limit* for this carrier), and PossibleWorlds 79 Deliverable 2 (the effective-extension remark this transcribes). Downstream: ModelChecker 154.

---

### 440. Finite frame discharge of spherical and limit
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: None
- **Research**: [440_finite_frame_discharge_of_spherical_and_limit/reports/01_finite-spherical-limit-discharge.md]

**Description**: RE-ISSUED 2026-08-12 (description rewrite only; status unchanged) after round-1 research machine-checked the live tree and forced a re-scope that the user has reviewed and approved. THREE of this task's original claims are RETRACTED -- Deliverable 2 in its entirety, the choice-free acceptance test, and the framing of Deliverable 3. See WHAT SURVIVES, WHAT DOES NOT below, which is authoritative over any earlier phrasing. The evidence is in `specs/440_finite_frame_discharge_of_spherical_and_limit/reports/01_finite-spherical-limit-discharge.md`; read it before planning.

GOAL. Land the finite-carrier discharge route for the paper's *Spherical* frame axiom, plus its axiom-free constructive core, plus the documentation and record-keeping that make the result citable. Since the frame-axiom-field refactor landed, `spherical` is a MANDATORY `TaskFrame` field, so this is what makes an arbitrary finite frame constructible as a `TaskFrame` at all. Small, additive, unblocks Z3-backed countermodel certification in the ModelChecker repository.

=== FIRST STEP FOR THE NEXT DISPATCH (do this before reading any definition) ===
Run `bash scripts/check-paper-definitions.sh` and read `specs/paper-definitions-of-record.md`. That file -- not the paper -- is what specs in this repository cite: it pins each definition with verbatim text and content hashes re-derived from the live paper on every run. Lint outcomes: case (a) silent pass and case (b) notice (paper changed but no recorded definition drifted) -- proceed; case (c) FAIL naming each drifted anchor -- STOP and re-issue the affected specs before consuming them. Cite by \label (or \aitem key) only; a bare possible_worlds.tex:NNNN is never a citation. Quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search. Verified 2026-08-12: the lint exits 0 silently (case (a)).

=== STATE OF PLAY -- VERIFIED 2026-08-11, RE-VERIFIED 2026-08-12, DO NOT RE-DERIVE ===
The extension chain is COMPLETE and GREEN. `FormalSystem/Semantics/Extension/{Constraint,Admissible,Step,Extension}.lean` implement `def:constraints` -> `lem:constraint` -> `lem:fibers` -> `lem:admissible` -> `lem:step` -> `thm:extension` -> `cor:occurrence`. `lake build FormalSystem.Semantics.Extension.Extension` succeeds. `#print axioms FormalSystem.Semantics.PartialHistory.extension` reports exactly `[propext, Classical.choice, Quot.sound]` -- no sorries, no custom axioms, `Classical.choice` being the expected Zorn dependency that the paper's own footnote to `thm:extension` predicts. The same holds for `occurrence` and `step`. Nothing in this task re-proves any of that, and any dispatch that starts by re-implementing the extension chain has misread the task.

=== THE FRAME-AXIOM-FIELD REFACTOR HAS LANDED -- "THE GAP" NO LONGER EXISTS ===
This task was originally written against a tree in which `extension`, `occurrence`, `hF_nonempty`, `step`, and `isTotal_of_isMax` each took *Spherical*, *Seriality*, *Interpolates*, and *Limit* as LOOSE HYPOTHESES because `TaskFrame` carried none of them. That is no longer the case, and every deliverable premised on it is void.

`420_align_task_frame_with_positive_cone_axioms` is COMPLETED (commit `649eb75f6`), NOT `[PARTIAL]` as this description previously claimed. `TaskFrame` (`FormalSystem/Semantics/TaskFrame.lean`) now carries `serial`, `limit`, `spherical`, and `comp` (with `interpolates` a theorem projection of `comp`) as structure FIELDS, alongside `nonempty : Nonempty WorldState`, and the `[Nontrivial D]` binder sits on the structure itself. Consequently `extension`, `occurrence`, `step`, `hF_nonempty`, and `isTotal_of_isMax` take ZERO axiom hypotheses. The obligations did not disappear; they MOVED to frame CONSTRUCTION sites. That relocation is precisely why Deliverable 1 gained value and Deliverable 2 lost all of it.

=== DELIVERABLE 1 -- `spherical_of_finite` (SURVIVES; RATIONALE STRENGTHENED) ===
For `{W : Type} [Finite W] (R : W -> D -> W -> Prop)`, prove `TaskFrame.Spherical R` (the predicate already defined at `FormalSystem/Semantics/FrameAxioms.lean`), landing it in `TaskFrame.lean` beside the existing `sInter_nonempty_of_directed_of_univ_or_singleton`.

WHY IT IS NEEDED NOW. With `spherical` a mandatory `TaskFrame` field, every new frame construction must discharge it, and every existing discharge route constrains the RELATION SHAPE: `spherical_of_subsingleton` needs `Subsingleton W`; `spherical_of_permissive` needs `R w d u <-> (d nonzero or w = u)`; `spherical_of_eq` needs `R w d u <-> w = u`; `multiFamGen_spherical` needs a deterministic-shift carrier. NONE of them applies to an arbitrary relation on a finite carrier -- which is exactly what a Z3-produced countermodel is. `spherical_of_finite` is the ONLY route that will discharge the `spherical` field for the frames the downstream consumers actually build. Its value is undiminished by the re-scope; the field refactor raised it.

THE PAPER SOURCE. `cor:spherical-finite`, verbatim (sha256 `76258a4c835d4fa0dde3fd037da52e706d0f20c9d7872ab523d3b81597b99b9d`):
  \begin{Cthm} \label{cor:spherical-finite}
  Every frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$ satisfies \textit{Spherical}, choice-free.
  \end{Cthm}
The argument is the subset-least-member one: a directed family of nonempty subsets of a finite carrier has finitely many DISTINCT members, so directedness yields a subset-least member, which is nonempty and equals the intersection. Finiteness applies to the set of distinct member SETS, not to the index -- the family may be presented as an infinite indexed family. The proof consumes only finiteness, directedness, and member nonemptiness; the `IsFiber R s or IsSegment R s` disjunct is never used, matching the paper's own remark that the finite-`W` argument is indifferent to member kind.

RECORDED PROOF ROUTE (machine-checked green 2026-08-12; use it, do not re-derive). Obtain the minimal member via `exists_minimal_of_wellFoundedLT (alpha := Set W)`. Do NOT use `Set.Finite.exists_minimal` or `Set.Finite.exists_minimal_wrt`: NEITHER EXISTS in this repository's pinned Mathlib (v4.33.0-rc1, `79d0395a`), verified by local search and by grep of the Mathlib source. A prior sibling report presented a snippet calling `Set.Finite.exists_minimal` as "verified green"; it does not compile here and must not be carried forward. Two imports must be added to `TaskFrame.lean`: `Mathlib.Order.Minimal` (for `exists_minimal_of_wellFoundedLT`) and `Mathlib.Data.Fintype.Powerset` (for `Set.instFinite`, without which `WellFoundedLT (Set W)` does not synthesize). Both were confirmed necessary by removal. Note that `FiniteTaskFrame.finite_world` is a plain field and not an instance, so every use site needs `haveI := F.finite_world`; landing an explicit-argument variant beside the instance form is a one-line courtesy worth considering.

Decompose into TWO lemmas, because the decomposition is what makes the paper's claim checkable (see the next section): `sInter_nonempty_of_directed_of_minimal` (the constructive core -- directedness upgrades minimal to least, least is nonempty and equals the intersection) and `spherical_of_finite` (the classical minimal-element step composed with it).

=== THE CHOICE-FREE ACCEPTANCE TEST IS PROVABLY UNSATISFIABLE -- DO NOT CHASE IT ===
This task originally mandated a regression test asserting the ABSENCE of `Classical.choice` from `spherical_of_finite`. That test CAN NEVER PASS, and this is now a machine-checked theorem rather than a guess. RETRACTED; do not reinstate it under any phrasing.

The research constructed a task relation on the two-element carrier `Bool` over `D = Int` and derived WEAK EXCLUDED MIDDLE (`not not P or not P`) from `TaskFrame.Spherical R`, with that derivation itself depending on only `[propext, Quot.sound]` -- no classical reasoning anywhere in it. `Bool` is finite. So if `spherical_of_finite` were provable with axioms `[propext, Quot.sound]`, composing the two would prove WLEM for every `P` in Lean's intuitionistic core, which is impossible. Therefore NO `Classical.choice`-free proof of `spherical_of_finite` can exist.

THE PAPER IS NOT WRONG. Its "choice-free" is a claim about ZF vs ZFC: the argument does not need the axiom of choice, GIVEN classical logic. That is correct, and it is exactly the contrast `thm:extension`'s footnote draws against the Zorn appeal. Lean's `Classical.choice` is a different object: it is the SINGLE axiom from which Lean derives both excluded middle (via Diaconescu) and the axiom of choice, and Lean has no separate `Classical.em` axiom to print. `#print axioms` therefore cannot express the paper's distinction. This is a genuine mismatch between the paper's metatheory and Lean's axiom accounting, not a defect in either, and it must be RECORDED IN THE DOCSTRING rather than papered over. Land the WLEM derivation itself in `Tests/` as a permanent regression test, with its own `[propext, Quot.sound]` profile pinned, so that a future dispatch cannot "fix" the axiom profile by chasing an impossible proof.

WHAT TO ASSERT INSTEAD (the two facts the research verified as assertable):
  1. `sInter_nonempty_of_directed_of_minimal` is AXIOM-FREE -- `#print axioms` reports no dependency at all, not even `propext`. This is the paper's actual mathematical content and it is fully constructive; only the EXISTENCE of a minimal member is classical, and the WLEM result shows that step is irreducibly so.
  2. `spherical_of_finite` carries NO ZORN DEPENDENCY -- in particular no dependence on `PartialHistory.exists_maximal_extension` -- and has exactly `[propext, Classical.choice, Quot.sound]` and no other axiom. THAT is the corollary's actual point and the real contrast with `thm:extension`, which does depend on Zorn.

=== RECORDED CONSTRAINT 1 -- DO NOT RE-DERIVE `spherical_of_subsingleton` ===
`spherical_of_subsingleton` currently has axiom profile `[propext]` -- it is choice-free. It MUST NOT be re-derived through `spherical_of_finite` on the grounds that `Subsingleton W -> Finite W`. Doing so would REGRESS it to `Classical.choice` and propagate that regression to the three consuming frames `trivialFrame`, `intTimeFrame`, and `genericTimeFrame`. The same applies to `spherical_of_permissive` and `spherical_of_eq` at finite carriers. `spherical_of_finite` is an ADDITIONAL route for relations of arbitrary shape, never a replacement for the existing class helpers. State this reason in a docstring line so it is not "helpfully" consolidated by a later dispatch; a sibling plan currently proposes exactly the opposite.

=== RECORDED CONSTRAINT 2 -- `cor:spherical-finite` IS UNTRACKED BY THE LINT ===
`cor:spherical-finite` resolves cleanly against the live paper but is NOT tracked by `scripts/check-paper-definitions.sh`; `specs/paper-definitions-of-record.md` records it as one of three known residual gaps (with `lem:nesting` and `lem:nonempty`), and tracked `thm:extension`'s footnote cross-references it. This task should close the `cor:spherical-finite` third of that gap, because it is the task that transcribes the corollary into Lean -- once a Lean docstring quotes the anchor, undetected drift would silently invalidate a docstring citation. The resolved manifest row is already in hand:
  cor:spherical-finite|env|-|-|76258a4c835d4fa0dde3fd037da52e706d0f20c9d7872ab523d3b81597b99b9d
Follow the record file's own four-step extension protocol: add the prose entry quoting the statement verbatim, add the manifest row, rewrite the residual-gap paragraph to say this cross-reference is now closed while `lem:nesting`/`lem:nonempty` remain open, and re-run the lint expecting a case-(a) pass. Do this BEFORE any Lean docstring quotes the anchor. `lem:nesting` and `lem:nonempty` are not consumed here; leave them alone. COORDINATION RISK: a sibling plan proposes tracking all three anchors, so check the file's current contents before writing.

=== DELIVERABLE 2 -- WITHDRAWN IN FULL ===
The original Deliverable 2 -- "package a finite-Int axiom bundle" discharging *Spherical* and *Limit* for `FiniteTaskFrame Int`, leaving *Seriality* and *Interpolates* as the only remaining obligations, then landing `extension_of_finite` and `occurrence_of_finite` taking just those two hypotheses -- is RETRACTED. Do not plan it, and do not reconstruct it under another name.

Reasons, each verified: (a) `limit` is now a `TaskFrame` FIELD, discharged once at construction and read off thereafter, so a "Limit for finite Int frames" lemma would have no consumer -- a `FiniteTaskFrame Int` ALREADY HAS `F.limit`; (b) `serial` is likewise a field and `interpolates` a theorem projection of the `comp` field, so neither is a "remaining obligation" at any consumer; (c) `FiniteTaskFrame D` EXTENDS `TaskFrame D`, so it inherits all four axioms as fields -- there is nothing to bundle; (d) because `extension` and `occurrence` take only `(F : TaskFrame D)`, the proposed `extension_of_finite` / `occurrence_of_finite` would be contentless coercion wrappers whose entire body is the `toTaskFrame` coercion that the existing `Coe (FiniteTaskFrame D) (TaskFrame D)` instance already provides. Landing them would MISREPRESENT them as discharging something.

If -- and only if -- ModelChecker 153/154 confirm they want a `FiniteTaskFrame`-named citation handle rather than citing `PartialHistory.occurrence` directly, a pair of aliases may be landed, documented explicitly as coercion aliases carrying no content. Absent that confirmation, skip them. The original recipe's mathematics was not wrong -- `limit_of_succOrder` does take exactly the `R w 0 u <-> w = u` biconditional that `nullity_identity` supplies, and `SuccOrder Int` / `NoMaxOrder Int` are both available -- it is simply no longer work that needs doing. Separately worth recording: *Seriality* is NOT automatic over `Int` and finiteness does not rescue it; it remains a genuine obligation at CONSTRUCTION sites, as does *Interpolates*.

=== DELIVERABLE 3 -- STALE-DOCSTRING REPAIR IN `Extension.lean` ===
Reframed. The original instruction was to "record that the finite specialization exists and what it costs, beside the existing note that the FRAME-INTRINSIC form is gated on the frame-axiom-field refactor." THAT GATING NOTE NO LONGER EXISTS -- the refactor replaced it. What is left is repair of four stale passages in `Extension.lean`'s module docstring which now CONTRADICT that same file's own lines 56-64 ("that refactor has landed... `TaskFrame` carries [the four axioms] as structure data", which is correct):
  1. lines 45-48 -- "*Spherical* ... enters only as a hypothesis binder handed straight to `step` ... the four binders are pass-through arguments": STALE, there are no binders;
  2. lines 66-68 -- "the structure carries no `Nonempty WorldState` field yet": STALE, `nonempty` has landed;
  3. lines 239-242 -- "This needs a world state ... which `TaskFrame` does not [supply]": STALE, same reason;
  4. lines 181-182 -- "*Spherical* is not threaded in directly -- it is handed to `step`": borderline, reword.
Then add the cost note: `spherical_of_finite` costs no Zorn but unavoidably costs `Classical.choice`, with the WLEM derivation cited as the reason. FLAG ONLY, do not implement: now that `F.nonempty` exists, `hF_nonempty` could drop its explicit `w` argument -- a real simplification the field refactor enabled but did not take, which changes a signature and is outside this task's additive-only remit.

=== WHAT SURVIVES, WHAT DOES NOT ===
SURVIVES, unchanged: the STATE OF PLAY section in full (extension chain complete, green, `[propext, Classical.choice, Quot.sound]`, no re-implementation); Deliverable 1's existence, with a STRONGER rationale than originally stated; the citation discipline (`specs/paper-definitions-of-record.md` anchors, never a bare line number); the additive-only remit; the explicit non-goals; and the downstream consumer list.
RETRACTED by round-1 research, approved by the user 2026-08-12: (i) the whole of "THE GAP" and Deliverable 2, because the frame-axiom fields landed and the loose-hypothesis architecture they described is gone; (ii) the mandated choice-free regression test on `spherical_of_finite`, because it is provably unsatisfiable in Lean; (iii) Deliverable 3's framing as a note beside a gating note, because that gating note was deleted -- it is now stale-docstring repair; (iv) the claim that `420_align_task_frame_with_positive_cone_axioms` is `[PARTIAL]` -- it is COMPLETED.
CARRIED FORWARD IN CORRECTED FORM: the non-dependency reasoning about the frame-axiom-field refactor. The original argument was that this work is independent of that refactor and must not be blocked on it. That conclusion still holds, for the now-simpler reason that the refactor has already landed: the only new code here is two lemmas plus two imports, beside the existing results, changing no `TaskFrame` field.

=== EXPLICIT NON-GOALS ===
Do NOT do the frame-axiom-field refactor here -- it is done and COMPLETED. Do NOT change the extension chain's proofs. Do NOT change any `TaskFrame` field. Do NOT touch `Boneyard`. NO edits under /home/benjamin/Philosophy/Papers/ -- the paper is READ-ONLY ground truth. The remit is additive only, and is now easy to honour.

=== DEPENDENCIES ===
PossibleWorlds 79 supplies the citable corollary; `specs/paper-definitions-of-record.md` must be re-pinned (see RECORDED CONSTRAINT 2). Downstream consumers: BimodalLogic 441, and ModelChecker 153 and 154 -- consult 153/154's actual citation needs before deciding the fate of the withdrawn wrappers.

---

### 439. Guard paper definition drift with definitions of record
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: general
- **Topic**: paper-refactor
- **Dependencies**: None
- **Research**: [439_guard_paper_definition_drift_with_definitions_of_record/reports/01_paper-definition-drift-guard.md]
- **Plan**: [439_guard_paper_definition_drift_with_definitions_of_record/plans/01_paper-definition-drift-guard.md]
- **Summary**: [439_guard_paper_definition_drift_with_definitions_of_record/summaries/01_paper-definition-drift-guard-summary.md]

**Description**: PAPER-DEFINITION DRIFT GUARD. Build a definitions-of-record file plus a local lint so that a change to the JPL paper's basic semantic definitions is DETECTED mechanically instead of being discovered by an agent mid-dispatch. This is infrastructure for the paper-refactor cluster, not cluster work: it does not restate, re-derive, or implement any definition, it only records the current ones and detects when they move.

MOTIVATION (measured, not speculative): /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex moved through FIVE definitional waves between 2026-08-08 and 2026-08-10, two of them WHILE a dispatch against it was in flight. The cluster re-issue that fixed waves 1-3 was itself overtaken by wave 4 during its own execution (it re-verified at the new snapshot and continued), and by wave 5 within an hour of finishing. `git log --since='3 days ago' -- possible_worlds.tex` showed 20+ commits. Every wave silently invalidates task specifications that quote the paper, and the failure mode is always the same: an agent consumes a superseded definition, does correct work against a wrong target, and the error is only caught by a later human read.

AUTHORITATIVE SOURCE: the paper is READ-ONLY input. Cite by \label and quote verbatim; never by bare line number -- line numbers in this cluster have gone stale repeatedly. Note also that some axioms are \aitem KEYS resolved by \aref (CO, TMP-CO), not \label{} names; the record must handle both anchor kinds.

DELIVERABLE 1 -- specs/paper-definitions-of-record.md. A single file recording, for each definitional clause the repo depends on: the anchor (\label name, or \aitem key plus its enclosing \label), the verbatim quoted text, and a content hash of the quoted block. Cover at minimum: def:frame and each of its four axioms (Compositionality as a biconditional, Seriality, Limit, Spherical) plus its supporting machinery (fiber, cone, segment, converse convention, positive cone, nonempty W, nontrivial D); lem:nullity and thm:occurrence as DERIVED results; def:world-history including totality and the extension order; thm:extension; the truth clauses (especially the box clause's quantifier domain); logical consequence; validity; satisfiability. Head the file with the pinned paper commit SHA, file checksum, and line count at the time of recording. This file is the thing specs cite instead of re-quoting the paper themselves.

DELIVERABLE 2 -- scripts/check-paper-definitions.sh. A local lint that re-reads the paper and reports drift against deliverable 1. It must distinguish THREE outcomes, because they carry different costs: (a) paper unchanged (SHA matches) -- silent pass; (b) paper changed but every recorded definition block still hashes identical -- pass with a notice naming the new SHA, since prose elsewhere moved but no recorded definition did (this is the common case and must NOT be reported as drift); (c) at least one recorded definition block changed -- FAIL, naming each drifted anchor and printing the old and new text. Exit non-zero only in case (c). Anchor resolution must be by \label / \aitem, never by line number, so that the lint survives the reflowing that has broken every previous line-based citation.

PLACEMENT CONSTRAINT (verified, do not get this wrong): the script goes in scripts/, alongside its existing siblings check-copyright-headers.sh, check-module-invariants.sh, readme-lint.sh, and typst-sync-check.sh, which is the closest analogue. It must NOT go in .claude/scripts/ -- `/.claude` is listed in .gitignore at line 81 and is a disposable deploy artifact regenerated from an external source store, so a script written there is silently wiped on the next redeploy. This repo has no agent-system/extensions/ tree of its own, so .claude/ has no in-repo source-store alternative; scripts/ is the correct and only durable home.

CI CONSTRAINT (verified): .github/workflows/ci.yml runs NONE of the scripts/ lints today, and the paper lives in a different repository (/home/benjamin/Philosophy/Papers/) that CI cannot see. A CI-enforced guard is therefore structurally impossible without vendoring or submoduling the paper. Do not attempt CI wiring as part of this task. The lint is a local, manually-invoked check in the same family as its siblings; decide and RECORD whether it should additionally be invoked from a skill preflight or a git hook, but do not implement that here.

DELIVERABLE 3 -- audit task 424 for exposure to the TruthAt change. 424 (prove_shift_set_representation_theorem_compactness_feasibility_gate, file_scope FormalSystem/Semantics/ShiftSet.lean) carries topic strong_completeness, so it sat outside the paper-refactor cluster re-issue and its description was never checked against the current definitions. Determine whether it assumes the Omega-parameterized TruthAt or the pre-totality consequence relation; if it does, rewrite the affected part of its description the same way the cluster's six were rewritten (state the current definition as a settled input, name explicitly which of its own prior research survives and which is superseded, and preserve all still-valid scope boundaries and non-goals). If it does not, record the negative verdict explicitly rather than leaving it unstated. Do NOT perform 424's underlying work.

NON-GOALS (hard boundaries): do NOT edit anything under /home/benjamin/Philosophy/Papers/ -- the paper is read-only. Do NOT edit any file under FormalSystem/, latex/, or typst/. Do NOT restate, re-derive, or "improve" any definition -- deliverable 1 records what the paper says, verbatim, and nothing more. Do NOT perform any paper-refactor cluster task's underlying work. Do NOT wire the lint into CI. Do NOT write to .claude/.

SEQUENCING: this task has no hard dependency edges, but it is most valuable BEFORE the cluster runs -- 420, 414, 415, 417, 419, and 427 all consume paper-quoted specs that a sixth drift wave would invalidate. Consider running it first; add explicit dependency edges only if you want that enforced rather than advised.

VERIFICATION: run the lint against the paper's CURRENT state and confirm it reports case (a) immediately after recording; then confirm it reports case (c) correctly by testing against an older paper commit known to differ (for instance c3da9852, the snapshot the cluster re-issue pinned, which differs from the post-re-issue state by 309 changed lines) and checking that each drifted anchor is named. Confirm every recorded anchor actually resolves in the current paper (no dangling \label or \aitem). Confirm the script is executable, passes `bash -n`, and exits 0 on the unchanged case and non-zero only on case (c).

---

### 438. Reconcile semantic definitions with jpl paper
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: None
- **Research**:
  - [438_reconcile_semantic_definitions_with_jpl_paper/reports/01_team-research.md]
  - [438_reconcile_semantic_definitions_with_jpl_paper/reports/02_logical-consequence-discrepancy-audit.md]
- **Plan**: [438_reconcile_semantic_definitions_with_jpl_paper/plans/03_reissue-paper-refactor-cluster.md]
- **Summary**: [438_reconcile_semantic_definitions_with_jpl_paper/summaries/03_reissue-paper-refactor-cluster-summary.md]

**Description**: DEFINITIONAL RECONCILIATION AND CLUSTER RE-ISSUE. The paper's basic semantic definitions have changed AGAIN since the paper-refactor cluster was specified, and every task in that cluster now carries a stale specification. This task has TWO parts: (A) establish from the authoritative source exactly which definitions are current, and (B) APPLY the resulting corrections to the existing cluster tasks so the whole cluster is back in sync. Part B is a required deliverable, not a recommendation -- this task is not finished while any cluster task still describes a superseded definition. What this task must NOT do is perform the cluster's underlying Lean, LaTeX, or typst work; see NON-GOALS.

AUTHORITATIVE SOURCE (user decision, 2026-08-09): /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex is the single source of truth for the basic semantic definitions; the Lean tree, this repo's latex/ prose, and this repo's typst/ book are ALL downstream and must be refactored to match it faithfully. Any conflict resolves in the paper's favour. Cite the paper by \label and quote verbatim; do NOT cite bare line numbers, which have already gone stale repeatedly in this cluster (task 420 phase 1 had to re-anchor 7 citations; task 427's spec carries stale anchors for both the Lean structure and the paper range; task 419 cites possible_worlds.tex:3250 for the CO formula and must be re-anchored the same way).

THE TWO CHANGES, AS ALREADY VERIFIED AGAINST THE PAPER (starting facts, not conclusions -- the audit re-verifies and completes them):

(A) def:frame now carries FOUR axioms, and Nullity is NOT one of them:
  - Compositionality is now a BICONDITIONAL: "w =>_{x+y} v if and only if w =>_x u and u =>_y v for some u in W". This REVERSES the settled decision recorded in task 420's description and repeated in task 427's, both of which adopted the LAX inclusion-only law and stated that equality "would additionally assert interpolation, NOT adopted". Interpolation is now asserted.
  - Seriality (NEW): for every w and x in D+, w =>_x u for some u, and v =>_x w for some v.
  - Limit: intersection over x > 0 of the cones (w)_x equals {w}. (Formerly named "Limit Nullity" in the cluster specs.)
  - Spherical (NEW): every superset-directed family of nonempty segments has nonempty intersection -- condition Sd1 from the ball-space literature (Cmiel2021), applied to the ball space of segments.
  - Nullity is DEMOTED to a derived lemma (lem:nullity), obtained from Seriality together with Limit, choice-free. The Occurrence condition, formerly required of every frame, is likewise now DERIVED (thm:occurrence, which appeals to Zorn and hence to AC).
  - NEW primitive-level machinery the axioms consume: the segment Seg(w, v; a, b) := {u : w =>_a u and u =>_b v}, with the fibers {u : w =>_a u} and {u : u =>_b v} included among the segments as one-sided cases. Unchanged: positive-cone task relation on D+ and the definitional converse convention.

(B) Logical consequence quantifies over TOTAL world histories, i.e. POSSIBLE WORLDS:
  - def:world-history: a world history over F is a function tau : X -> W where X is a nonempty convex subset of D, task-constrained. It is TOTAL -- equivalently, a POSSIBLE WORLD -- just in case X = D. H_F denotes the set of all TOTAL world histories over F. The extension order is defined here too (sigma extends tau iff dom tau subset dom sigma and they agree on dom tau).
  - The logical-consequence definition quantifies over "possible worlds tau in H_F", i.e. over TOTAL histories.
  - thm:extension: every task-constrained function on a nonempty subset of D is extended by SOME total world history. This is what makes the totality restriction non-vacuous, and per the app:gluing footnote the DIRECTED case of gluing rests on Spherical rather than on Compositionality alone -- so change (A)'s Spherical axiom and change (B)'s totality restriction are coupled, not independent.
  - CONSEQUENCE FOR TASK 414: 414's researched target is MAXIMAL histories (Mathlib IsMax under the extension order, reached by Zorn). The paper's target is TOTAL histories. These are NOT the same predicate, and totality is the paper's. 414's ~85-line machine-checked prototype (Preorder instance, timeShift_mono, isMax_timeShift, chainSup, exists_maximal_extension) is PARTIALLY reusable as the mathematical engine behind thm:extension, but the predicate appearing in TruthAt/valid/SemanticConsequence must be totality, not IsMax.

CURRENT REPO STATE (verified 2026-08-09; re-verify before relying on any of it):
  - FormalSystem/Semantics/TaskFrame.lean structure TaskFrame has exactly THREE fields beyond the carrier: nullity_identity (iff form, still an AXIOM -- paper has demoted it), forward_comp (with 0 <= x, 0 <= y hypotheses -- the lax law the paper has replaced with a biconditional), and converse (the definitional convention carried as structure data). ABSENT: Limit, Seriality, Spherical, segments, fibers. Also absent, and already flagged in-file as known gaps: a Nonempty WorldState field and a [Nontrivial D] structure binder, both of which def:frame requires.
  - FormalSystem/Semantics/WorldHistory.lean has domain : D -> Prop, convex, states (dependent on the domain proof), respects_task. NO totality predicate, NO extension order, NO maximality notion. Repo-wide, every "maximal" hit is maximal-consistent-set vocabulary, not histories.
  - FormalSystem/Semantics/Validity.lean and Truth.lean quantify over an arbitrary shift-closed Omega : Set (WorldHistory F): TruthAt takes Omega, the box clause reads "for all sigma in Omega", and valid/SemanticConsequence bind (Omega) (ShiftClosed Omega) (tau in Omega). Blast radius measured: 1194 occurrences of Omega across 45 files; ShiftClosed referenced in 32 files; 92 TaskFrame instantiation sites tree-wide; 519 Lean files / ~333k lines total.
  - This repo's OWN prose is stale on BOTH counts and is NOT a valid secondary source: latex/subfiles/02-Semantics.tex and typst/chapters/02-semantics.typ state the PREVIOUS three-axiom frame and define logical consequence over "history tau in H_F" with no totality or maximality qualifier at all. Both must be re-derived from the paper, not patched. This matters especially for task 427, whose spec instructs the implementer to use the LaTeX subfile as the model for the typst restatement -- that instruction is now wrong and must be corrected as part of Part B.

THE CLUSTER TO BE RE-ISSUED -- SIX TASKS, topic paper-refactor (this is the full set; confirm by re-querying topic == "paper-refactor" in specs/state.json before starting, since tasks may have been added):
  - 414 refactor_semantics_to_maximal_history_validity [researched] -- target predicate is wrong (maximal vs total); its very name is now misleading.
  - 415 completeness_over_maximal_history_semantics [researched] -- written explicitly against 414's maximal-history semantics; inherits the error transitively. Its bundleFlowFrame construction must additionally discharge Seriality and Spherical, not just Limit.
  - 417 semantic_fmp_finite_worldstate_over_z [researched] -- also written against 414's maximal-history semantics; its target signatures name tau.IsMaximal.
  - 419 machine_check_co_reynolds_independence [not_started] -- assess whether the new frame axioms disturb the independence argument. Compositionality becoming biconditional adds interpolation as a frame condition, and Seriality and Spherical are new constraints on admissible countermodels, so the Q-flow countermodel sketch must be re-checked for conformance to the new def:frame. Also re-anchor its possible_worlds.tex:3250 citation.
  - 420 align_task_frame_with_positive_cone_limit_nullity [blocked] -- phases 1-5 landed and green (5 commits); its phase 6 target field and its phase 5 rewrite of latex/subfiles/02-Semantics.tex are both stale. Its title now names only one of four axioms.
  - 427 sync_typst_book_with_refactored_paper [not_started] -- DOUBLY stale: it enumerates the previous-generation axioms as the CORRECT target to write into the typst book, and it directs the implementer to copy from the now-superseded LaTeX subfile. Left unrevised it would actively write wrong definitions into the book.

PART A DELIVERABLES (research report):
  1. A three-way reconciliation table with one row per definitional clause, columns: paper (verbatim + \label anchor) | current Lean (declaration + file) | current repo prose (file + section) | verdict (match / stale / absent). Cover at minimum: every def:frame axiom and its supporting machinery (cone, segment, fiber, converse convention, positive cone, nonempty W, nontrivial D), def:world-history including totality and the extension order, the truth clauses (especially the box clause's quantifier domain), logical consequence, validity, and satisfiability.
  2. An explicit statement of the target Lean signatures for the changed definitions -- the TaskFrame structure fields and the TruthAt / valid / SemanticConsequence binder lists -- so downstream research has one unambiguous target. Do not implement them.
  3. A coupling analysis of (A) and (B): which frame axioms are load-bearing for the totality restriction. In particular determine whether thm:extension (and hence a nonempty H_F) is derivable in Lean from the four axioms as stated, and what Spherical costs to state over a Lean TaskFrame given that segments must be introduced first. Flag any axiom whose Lean transcription is not routine.
  4. A per-task staleness verdict for all six cluster tasks, each saying explicitly which parts of the existing research survive, which are refuted, and what the re-issued description must say. Known starting points, to be confirmed rather than assumed: 420's three helper theorems (limit_nullity_of_succOrder, limit_nullity_of_shift, exists_uniform_radius_of_finite) are stated against a bare relation rather than a frame field, so they plausibly survive verbatim; and 414's Omega-excision reachability analysis (of ~110 Omega-affected declarations: ~88 dead, 16 live-and-portable, 8 live-and-unportable) concerns Omega and is plausibly orthogonal to the totality-vs-maximality change.
  5. A resolution for the dependency cycle 420 -> 415 -> 414 -> 420 currently in specs/state.json. Prior analysis found the cycle is an artifact of task-level rather than phase-level edges (420's helpers are already landed, so only 420's phase 6 genuinely waits on 415). Note that generate-todo.sh does NOT report this cycle: it currently places 415 in wave 1 with "Blocked by: --" despite three unmet dependencies, because Kahn's algorithm cannot assign cycle members. Propose the corrected edge set.

PART B DELIVERABLES (apply the corrections -- this is what puts the cluster back in sync):
  6. Rewrite the description field of each of the six cluster tasks in specs/state.json so that every one states the CURRENT definitions. Each rewritten description must: state the four-axiom def:frame and the totality-based consequence as settled inputs; carry \label-based paper anchors rather than bare line numbers; name explicitly which of its own prior research survives and which is superseded, so the next agent does not silently re-consume a refuted finding; and preserve all still-valid content (scope boundaries, non-goals, binding user notation decisions such as the superscript-inverse convention for the converse operation). Do not shorten a description merely to make it tidy -- these descriptions are the specs.
  7. Rename any task whose project_name now misdescribes it. At minimum 414 ("maximal_history_validity") and 415 ("over_maximal_history_semantics") name a predicate the paper does not use, and 420 ("positive_cone_limit_nullity") names one of four axioms. Renaming a task means updating project_name in state.json AND renaming its specs/{NNN}_{SLUG}/ directory AND updating the artifacts paths that reference it; if that proves to have wide reference surface, record the rename decision and its cost rather than doing a partial rename that leaves dangling paths.
  8. Set each cluster task's status to reflect the corrected spec. Rule: where a task's TARGET definition changed, its existing research was conducted against the wrong target and the task returns to not_started so research re-runs; where only anchors or peripheral details changed, the existing status stands. Task 420 is the exception requiring care -- phases 1-5 are landed, green, and committed, so it must NOT be reset in any way that presents landed work as undone; choose between blocked, partial, and a revised description that inventories what has landed versus what is stale, and justify the choice. Never delete or overwrite an existing report file: superseded reports stay on disk as history, and the re-issued description says which are superseded.
  9. Apply the corrected dependency edges from deliverable 5, and add any new edges the re-issue implies (for instance 427 must remain last). Verify afterwards that the graph is acyclic by running .claude/scripts/generate-task-order.sh --print and confirming every task lands in a wave with its true blockers listed -- in particular that 415 is no longer shown in wave 1 with no blockers.
  10. Regenerate specs/TODO.md via .claude/scripts/generate-todo.sh and commit the state.json + TODO.md changes together with the research report.

NON-GOALS (hard boundaries): do NOT add, remove, or alter any field of TaskFrame; do NOT touch TruthAt, valid, SemanticConsequence, or any Omega binder; do NOT edit any file under FormalSystem/; do NOT edit latex/ or typst/ content; do NOT edit anything under /home/benjamin/Philosophy/Papers/ (the paper is read-only input); do NOT perform any of the six cluster tasks' underlying work. Part B changes task SPECIFICATIONS in specs/, nothing else. An output consisting of a reconciliation report plus rewritten specs and a corrected dependency graph IS the complete and correct deliverable -- this is deliberately a scoping-and-re-issue task, and analysis plus specification is the right outcome here rather than a deflection from implementation.

VERIFICATION: every paper claim quoted verbatim with its \label; every Lean claim carrying file plus declaration name and confirmed against the current tree (re-run the greps -- the 18-site inventory in 420's report predates 415, and the counts in this description predate this task); every "unchanged" verdict positively checked rather than assumed; after Part B, every one of the six descriptions re-read end to end to confirm no superseded axiom statement survives anywhere in it -- grep the rewritten descriptions for the superseded vocabulary ("Limit Nullity", "lax", "maximal-history", "IsMaximal", "NOT adopted") and justify every remaining hit.

---

### 437. Repair time index reuse in identification plus nexttime bookkeeping
- **Effort**: 16-22 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**:
  - [436_fourth_termination_measure_component/reports/02_spawn-analysis.md]
  - [437_repair_time_index_reuse_in_identification_plus_nexttime_bookkeeping/reports/01_spawn-analysis-pointer.md]

**Description**: Attack the missing fourth termination-measure component from the identification-plus-maxTime side rather than the measure side, per task 436's roadmap item 2. Root cause: Branch.identifyTime (FormalSystem/Metalogic/Decidability/SignedFormula.lean:364-367) relabels every formula at time src to tgt and erases duplicates, so src disappears from Branch.knownTimes (SignedFormula.lean:349-350) whenever no other formula independently sits at tgt. Branch.maxTime (SignedFormula.lean:373-374, foldl max 0 over the live branch) and Branch.nextTime (SignedFormula.lean:380-381, maxTime + 1) are both recomputed from the current branch on every call, with no memory of a previously-larger retired value. TimeOrdering.identifyTime (SignedFormula.lean:705-710) does the analogous constraint substitution. The decided consequence is nextTime_reissues_retired_time (MintBound.lean:7321): firstIncomparablePair merges away the branch's current maximum time, maxTime drops, and post-identification nextTime re-issues the retired value; reuse_driven_through_engine (MintBound.lean:7363) confirms the live engine actually drives through this path. The accumulated renaming sigma (composed from rhoSF src tgt at each identification) is constructed so it can never land on a retired source time -- rhoSF_time_ne_src (MintBound.lean:7299) proves (rhoSF src tgt sf).label.time != src for every sf -- so mint_not_in_rhoSF_image (MintBound.lean:7307) and, by extension, register entries 15 and 17 (MintBound.lean:7866-7938) refute every measure-side candidate whose decrease is witnessed anywhere on the trigger's label, formula or time. This task's goal is to make Branch/TimeOrdering time issuance monotone across a run -- nextTime must never again hand out an index a prior identification retired -- so the reuse configuration nextTime_reissues_retired_time decides today stops occurring at all, rather than continuing to search for a measure component robust to it. REQUIRED SHAPE: refute-first gate as phase 1, in the same spirit as this task's own predecessor plan (specs/436_fourth_termination_measure_component/plans/01_self-guard-potential.md) -- prototype the monotone-time-issuance mechanism (e.g. a highwater-mark tracked on TimeOrdering, which is already threaded alongside Branch at every rule call site, or an equivalent run-level counter) against the SAME witness configuration used by nextTime_reissues_retired_time and gate_is_reissue_hazard, and decide, before touching any live engine file, both (a) whether reissue is actually prevented, and (b) whether RunInvariant, OrdTimesKnown (the settled repair for the adjacent register entry 7 refutation of OrdTimesLeMaxTime across identification, MintBound.lean entry 7), and UniverseClosedAt-style confinement to U survive the change. Only if the gate passes should later phases thread the repair through the live engine. WIDENED BLAST RADIUS (do not assume additive-only-in-MintBound.lean; explicitly confirmed by grep): Branch.nextTime is called at 9 sites in FormalSystem/Metalogic/Decidability/Tableau.lean (lines 761, 801, 834, 878, 924, 971, 1069, 1168, 1370 -- one per freshTimeRules member, not only the two self-guarded rules the predecessor task touched); Branch.identifyTime/TimeOrdering.identifyTime are called together at Tableau.lean:1520 and consumed in proofs at FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean lines 1948, 1959, 1973, 1991, 2445-2457 that already reason about identifyTime's effect on knownTimes cardinality and must be re-verified (not necessarily rewritten) against any redefinition; FormalSystem/Metalogic/Decidability/Saturation.lean does NOT reference nextTime or identifyTime (confirmed by grep) and should stay untouched; the definitions themselves live in SignedFormula.lean:349-381 and 671-710. DO NOT RE-ATTEMPT (per C9 register, MintBound.lean:7694-7944, all 17 entries read): entry 14's two measure-side repairs (re-indexing mintPotential on freshTimeRules; dropping disjunct 1's cardinality conjunct); entry 17's whole family (any fourth measure component whose decrease is witnessed anywhere on the trigger's label, time or formula). This task is not a measure-side route at all, so none of entries 14/15/17's refutations apply directly to it, but entries 7 and 16 name OrdTimesKnown as a settled repair this task's bookkeeping change must not silently re-break. Must be sorry-free and axiom-free; lake build must be green at completion. Land any newly-refuted route as a fresh C9 register entry (18) following the file's existing convention if the gate or a later phase decides a sub-route false.

---

### 436. Fourth termination measure component
- **Effort**: 10-14 hours
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 435, Task 437
- **Research**:
  - [434_discharge_mintpaysfortime_residual/reports/02_spawn-analysis.md]
  - [436_fourth_termination_measure_component/reports/01_fourth-measure-component.md]
- **Plan**: [436_fourth_termination_measure_component/plans/01_self-guard-potential.md]
- **Summary**: [436_fourth_termination_measure_component/summaries/01_self-guard-potential-summary.md]

**Description**: Resume task 434's implementation plan (specs/434_discharge_mintpaysfortime_residual/plans/01_mintpaysfortime-time-analogue.md) at Phase 7. Before starting, read the full do-not-re-attempt register (MintBound.lean section C9, 16 entries) and in particular entry 14, which records both refuted repair routes for MintPaysForTime: (1) re-indexing mintPotential on freshTimeRules instead of freshLabelRules -- refuted by witnessPresent_eq_false_of_not_freshLabel, whose match has exactly eight arms so the three added columns are permanently false; (2) dropping disjunct 1's cardinality conjunct and relying only on the ordering-rank conjunct -- refuted by splitOrderedRank_lt_of_knownTimes_lt plus mintPaysForTime_rank_repair_false, since splitOrderedRank's base Tmax^2+1 is by construction one more than incompPairs' range so any new known time raises the rank regardless of the pair count. Neither route may be re-attempted. Design a fourth measure component that pays for the three self-guarded minting rules -- untlNeg/snceNeg (guarded by futureOf/pastOf emptiness plus ord.timeCount < 4) and densityRule (guarded by the maximal-unfilled-gap set) -- and that is also preserved across TimeOrdering.identifyTime, which can lower ord.timeCount (the same maxTime-lowering mechanism Phase 6's verdict in the existing plan turns on; see nextTime_reissues_retired_time and reuse_driven_through_engine). Run this task with --lit against the sub-index populated by the literature-curation task, drawing specifically on: caleiro_2013's mosaic-method decidability treatment for combined tense-and-modal logics (sections 6-7, mosaic-based tableau systems and complexity bounds) as a structural analogue for a combined-logic termination measure; venema_2001 section 5's interval-based temporal logic treatment for the density/gap-guarded densityRule component; gerth_1995 and baier_katoen_2008's closure-set LTL tableau termination argument as a model for a measure over an evolving, non-monotonically-changing time set; and massacci_2000's rule-bounding technique. Once a candidate measure is validated, land it in MintBound.lean following the plan's existing Phase 7-8 task lists: define the repaired predicate (e.g. MintPaysForTimeAt, mirroring UniverseClosedAt's naming), prove its direction lemma relative to MintPaysForTime (weakening or strengthening, stated explicitly), confirm it leaks no new hypothesis into the terminus, restate the two seed-level termini at the repaired shape, and discharge the repaired predicate at a concrete instantiation (U = signedUniverse C L). All work must be sorry-free, axiom-free, and additive only (Saturation.lean, Fuel.lean, Tableau.lean remain untouched, and no previously-landed declaration in MintBound.lean is altered). Full lake build must be green at completion, and the new do-not-re-attempt register entries (if any further route is refuted along the way) must be recorded in section C9 following the existing convention.

---

### 434. Discharge mintpaysfortime residual
- **Effort**: 10-15 hours
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 431, Task 435, Task 436
- **Research**: [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
- **Plan**: [434_discharge_mintpaysfortime_residual/plans/01_mintpaysfortime-time-analogue.md]

**Description**: Discharge `MintPaysForTime fc U Tmax`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:3945, the open mathematical core among the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). Two disjuncts to establish. First disjunct ('a step that does not raise the known-time count does not raise the rank'): the naive reading 'non-ruleMintsFreshLabel implies no new time' is FALSE -- `densityRule` interpolates a fresh time while deliberately absent from `ruleMintsFreshLabel` (it carries its own `existingIntermediates` guard), and the active-mode arms of `untlNeg`/`snceNeg` introduce times without being witness-guarded; the correct test is the ordering-length one `expandOnceNoFresh` already uses (`newOrd.constraints.length`), not the rule list. Establishing this disjunct means proving a time-dimension analogue of `applyRule_emitted_world_mem` keyed on that ordering-length test. Second disjunct (cashed at the once-only bound, carrying the sigma-hit obligation from `mintPotential_lt_of_pick_linear` / `_branching`): the formula the rule fires on must be `sigma sf` for some `sf in U`; this is entangled with the time-reuse question -- `Branch.nextTime = maxTime + 1` while `Branch.identifyTime` can LOWER `maxTime`, so whether the engine can re-issue a time an earlier identification retired is genuinely open (the live-times reformulation carries the identical obligation, confirming it is intrinsic rather than an artifact of the measure). Done means: a theorem proving `MintPaysForTime fc U Tmax` for a concrete, useful instantiation, landed sorry-free and axiom-free in MintBound.lean, with `lake build` green. Do not re-attempt anything in the do-not-re-attempt register at MintBound.lean:4455-4510 (eight entries; read before starting) -- in particular do not re-litigate `witnessPresent_identifyTime`'s unconditional form (entry 5, refuted by `witnessPresent_identifyTime_unconditional_false`) or `OrdTimesLeMaxTime` preservation across the identification arm (entry 7, refuted by `ordTimes_identifyTime_arm3_false`; the settled repair is `OrdTimesKnown`).

---

### 433. Discharge postblockingsettles residual
- **Effort**: 6-10 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 431, Task 432, Task 434
- **Research**: [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]

**Description**: Discharge `PostBlockingSettles fc`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:4344, one of the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). It states that the post-blocking pass leaves a branch the blocking-aware saturation test certifies -- i.e. `findUnexpandedUnblockedWith satBr satOrd fc (blockedTimes satBr satOrd fc (armTracker satBr)) = none` whenever `saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd))`. It subsumes `resolveOpenArm`'s own `none` arm via `armSettlement_of_postBlockingSettles` (MintBound.lean:4354) -- `ArmSettlement` alone is proved strictly too weak (`resolveOpenArm` tests `findClosure satBr` before its saturation test; `buildTableauAt` does not), so do not attempt to discharge via `ArmSettlement` instead. The relevant definitions are frozen (md5-pinned) in Saturation.lean (`saturateBlocked`, :431) and Tableau.lean (`blockedTimes`, :2104; `findUnexpandedUnblockedWith`, :2115) -- do not edit either file; the residual's own docstring states the gap ('whether the fuel-vs-condition gap can be closed by fuel alone') is exactly what Saturation.lean leaves open using only its existing public interface. Done means: either (a) a proof of `PostBlockingSettles fc` for the frame classes the terminus is meant to be used at, using only the public interface of the frozen files, landed sorry-free and axiom-free with `lake build` green; or (b), if (a) turns out to be genuinely impossible without touching the frozen files, a return to [BLOCKED] with the specific counterexample or obstruction found, analogous to the parent task's own refutation-driven repairs (e.g. `ordTimes_identifyTime_arm3_false`, MintBound.lean:1217) -- do not paper over with a vacuous definition (`lean4.md`'s Vacuous Definitions prohibition applies).

---

### 432. Discharge universeclosed residual
- **Effort**: 4-6 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 431, Task 434
- **Research**: [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
- **Plan**: [432_discharge_universeclosed_residual/plans/01_universeclosed-clause2-verdict-instantiation.md]
- **Summary**: [432_discharge_universeclosed_residual/summaries/01_universeclosed-clause2-verdict-instantiation-summary.md]

**Description**: Discharge `UniverseClosed fc U`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:3901, one of the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). The definition has two conjuncts: (1) closure of `U` under the engine's unblocked-expansion step `expandOnceUnblocked` -- a familiar shape already required by the unsplit totality theorem's `hU` obligation -- and (2) closure of `U` under an ordered split's identification arm `Branch.identifyTime`, which relabels the branch; this second clause is genuinely new. For `U = signedUniverse C L` (Fuel.lean:382, DO NOT edit Fuel.lean -- it is md5-pinned frozen), clause (2) reduces to a statement about the label set `L` being closed under time-merging. Done means: a theorem proving `UniverseClosed fc U` for a concrete, useful instantiation `U = signedUniverse C L` under an explicit closure condition on `L` (state and prove that condition too, if it is not already available), landed sorry-free and axiom-free in MintBound.lean, with `lake build` green. Do not re-attempt anything in the do-not-re-attempt register at MintBound.lean:4455-4510 (eight entries; read before starting), and in particular do not attempt route (a), entry 6 (a lower bound on `(b.identifyTime t2 t1).toFinset.card` from below -- dead by definition).

---

### 430. Semantic lift and track a assembly valid iff allclosed
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428, Task 429, Task 411

**Description**: The semantic lift and the Track A assembly. Owns obstruction O4 of the Phase 7.3 deadlock, then delivers what Phase 7.3 of task 165 was for. Grounding: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

THIS TASK CARRIES THE WORK MOVED OUT OF TASK 165's PHASE 7.3. Task 165 terminated with Phase 7 scoped to what it delivered (the truth lemma and Track A's conditional results); 7.3 -- `valid_iff_allClosed` and the `Decidable` instances -- was moved here rather than closed, because it is blocked on prerequisites no task owned.

O4 HAS TWO DISTINCT PIECES, per Verified/Decidable.lean:3062-3067: "It is not yet `valid_iff_allClosed` (7.3), which additionally needs the fuel/termination side and the truth-lemma gate, and it says nothing about the two rules scheduled outside `allRulesForFC` -- `serialityRule` and `timeLinearity` run as stages 2 and 3 of `expandOnce` and need their own obligations at the point where `expandOnce`, rather than `applyRule`, is the object."

(a) Two more `RuleSound`-analogues at the `expandOnce` level, for `serialityRule` and `timeLinearity`. These are deliberately outside `allRulesForFC`, so `ruleSound_of_mem_allRulesForFC` (landed, 34/34) does NOT cover them.
(b) THE SEMANTIC LIFT: the induction lifting single-step satisfiability preservation to the whole recursion, so that `.allClosed` yields a contradiction. This is the LARGER of the two and is comparable in weight to a landed sub-phase, not to a wrapper. Naming it inside "the two outside rules" understates it.

THEN, and only after (a), (b) and both predecessors: `valid_iff_allClosed` plus the four `Decidable` instances for validity over Base, Dense, Discrete and Dedekind.

WHAT IS ALREADY LANDED (do not re-prove): the rule half is done -- `ruleSound_of_mem_allRulesForFC` is a single landed induction over `mem_allRulesForFC_iff`, ledger complete at 34/34, from task 165 Phase 7.2.

PLAN AGAINST SIX ROWS, NOT EIGHT: the truth-lemma gate hypothesis hTW is discharged on SIX accepted TemporalWitnessProbe rows (A, B, C, D, E, F), not the historical eight -- rows I and K left when the PASSIVE arms of untlNeg/snceNeg were retired. See the banner at the head of Tests/BimodalTest/TemporalWitnessProbe.lean.

DO NOT write a conditional `valid_iff_allClosed` carrying hTW as an explicit hypothesis. Correctness.lean:98-105 refuses exactly this shape, and the O4(b) hypothesis would BE the conclusion's forward direction, making the theorem vacuous. Four vacuous theorems were deleted in 165's Phase 8; do not land a fifth.

DONE WHEN: `valid_iff_allClosed` and the four `Decidable` validity instances are landed unconditionally, sorry-free and axiom-clean outside Boneyard, lake build green.

---

### 429. Repair truth lemma side conditions boxanchored and temporalwitness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428

**Description**: Repair the truth-lemma side conditions. Owns obstructions O2 and O3 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md. THIS IS THE TASK WITH GENUINE OPEN MATHEMATICS IN IT and should be budgeted accordingly.

READ FIRST: specs/418_*/artifacts/boxanchored-finding.md -- it carries the measurement, the full carrier list, and the repair options. Then TruthLemma.lean:399-404 and BoxSaturation.lean:430-435, :574-580.

O2 -- `hBA` (`boxAnchoredCheck`) is no longer dischargeable on multi-world branches. BoxSaturation.lean:430-435: the two copy blocks "have since been removed as unsound ... They were the ONLY route by which T(G phi)/T(H phi) could reach a freshly minted world ... `boxAnchoredCheck` is therefore expected to compute `false` on multi-world branches now." :574-580: "a caller can no longer expect to discharge that hypothesis from a real run." TruthLemma.lean:399-404 names the repair as "an open design decision with its own soundness obligations" and lists THREE candidate routes: (a) propagate T(box phi) itself; (b) copy T(G phi)/T(H phi) only when box-derived; (c) restructure the `box` case to need no anchor.

CRITICAL CONSTRAINT: this was caused by task 418 (completed) removing a GENUINE UNSOUNDNESS. It is the cost of a correct fix, not a regression to revert. TruthLemma.lean:404 says "Do NOT reinstate the removed copies." Any repair must re-establish the anchor WITHOUT reinstating them.

O3 -- `hTW` (`temporalWitnessCheck`) is no longer dischargeable on any branch carrying a negative until with a known future time. TemporalWitnessProbe.lean:66-73: `untlNegFuture` demands F(event) at every known future time of every negative until; the PASSIVE arm's branch 1 was the ONLY producer of `not event` at an EXISTING time; that arm was retired as unsound (user-authorized rank 2), so the producer is gone. Measured cost: fourteen probe rows moved check=true -> check=false; the accepted set went from EIGHT rows to SIX (rows A, B, C, D, E, F; I and K left). :86-88: "it was already `false` on the branches the engine actually builds. What it removes is the last set of hand-built branches on which the hypothesis was discharged."

DO NOT REOPEN (settled by 165): guardWitnessed in any variant; restoring sat_untl_neg / sat_snce_neg (they are FALSE against the current engine, not merely unproved); reinstating the retired PASSIVE arms or the removed box copy blocks.

GOAL: choose among the three documented BoxAnchored repair routes and land it with its soundness obligations discharged; and re-establish a producer for `not event` at existing future times. Both must hold on branches the engine ACTUALLY builds, measured by the probes, not on hand-built branches.

DONE WHEN: `boxAnchoredCheck` and `temporalWitnessCheck` are dischargeable on real engine output for the relevant branch classes, evidenced by probe rows moving back to check=true; no unsound copy block or retired arm is reinstated; lake build green.

---

### 428. Engine totality at a quantified branch budget
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 431, Task 432, Task 433, Task 434
- **Plan**:
  - [428_engine_totality_at_a_quantified_branch_budget/plans/02_lexicographic-splitordered-measure.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md]
- **Summary**: [428_engine_totality_at_a_quantified_branch_budget/summaries/02_lexicographic-splitordered-measure-summary.md]
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md]

**Description**: Engine totality at a quantified branch budget. Owns obstruction O1 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md section "The four obstructions" (read it first; do not re-derive the refutation).

THE REFUTED THEOREM, SETTLED: `buildTableau_isSome` in unconditional form is FALSE, not merely unproved, and is on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine SIGNATURE, not a proof difficulty: `buildTableau` (Saturation.lean:928-951) calls `expandBranchWithFuel` at the default `maxBranches := 50000` (Saturation.lean:590), whose first line is `if branchesUsed >= maxBranches then none` (:594). A formula exploring more than 50000 branches returns `none` at ANY fuel whatsoever. Independently, `buildTableau`'s last arm returns `none` on a still-unsaturated branch (:950). Neither is fuel exhaustion, so no fuel figure rules them out. DO NOT attempt the unconditional form.

WHAT LANDED INSTEAD, and why it is unusable as-is: Verified/Termination/Fuel.lean:1587-1598 carries two hypotheses -- `(hP : NoSplit P fc)` and `(hbud : branchesUsed + fuel <= maxBranches)`. `NoSplit` excludes impPos, orPos, untlPos, untlNeg, sncePos, snceNeg, orderTrichotomy and every frame-class-gated splitting rule, i.e. it holds only on non-branching runs. 165's plan:1467-1468 records "Residual 2 (branching arms) -- isolated, not discharged."

GOAL: add a `maxBranches`-parameterised entry point ALONGSIDE `buildTableau` -- an ADDITION, never an edit to the existing default, because `maxBranches = 50000` is a deliberate runtime guard -- and prove totality against a quantified budget. Target shape:

  theorem buildTableau_isSome_of_budget (phi : Formula) (fc : FrameClass)
      (maxBranches : Nat) (hmb : <bound in phi> <= maxBranches) :
      (buildTableauAt phi (soundFuel' phi) fc maxBranches).isSome = true

THREE SUB-OBLIGATIONS:
1. Discharge the branching-arm residual that `NoSplit` currently hypothesises (Fuel.lean:1587, Saturation.lean:661-664, :686-689).
2. Supply the missing WORLD-COUNT dimension. 165's plan:1484-1488: "T1 bounds formulas and T2 bounds times; neither bounds worlds ... as defined, `soundFuel' = 2*n*2^(2n)` has no world factor at all." A branch bound that ignores worlds cannot bound branches.
3. Establish the `<bound in phi> <= maxBranches` side condition in a form callers can actually discharge.

COORDINATION: overlaps task 426's hypothesis (b) on the same file (Fuel.lean). Sequence with 426 or merge; do not both edit Fuel.lean concurrently. Task 412 consumes this theorem in place of the refuted `buildTableau_isSome`.

DONE WHEN: the budget-parameterised totality theorem is landed sorry-free with no `NoSplit` hypothesis, lake build green, and the world dimension is either supplied or its absence is proved harmless.

RETARGET DECISION (user-approved, post-research): the specified unconditional target shape is refuted (see reports/01_budget-totality-refuted-and-repair.md). Task WIDENED to own the validated certificate repair: swap findUnexpanded -> findUnexpandedUnblocked at resolveOpenArm's two decision points, discharge the accompanying soundness obligation on what .hasOpen certifies (shared with O2/O3), lift the proved saturateBlocked_isSome asset, close the world dimension via worldFuel'/WorldWitness, and land the budget-parameterised totality theorem against the repaired engine. The per-path budget finding (maxBranches >= 3*fuel linear invariant) supplies the side condition.

SECOND RETARGET DECISION (user-approved, post-research 03). The per-step framing of Phase 11 cannot be closed: reports/03_phase11-potential-obstruction.md section 4 is a proof about the SHAPE of the argument, not a report of a failed attempt. Route (a) (a lower bound on branch cardinality after identification) is DEAD by definition -- `Branch.identifyTime = (b.map relabel).eraseDups`, so all shrinkage comes from eraseDups and is bounded only by |U|. Route (b) (an independent mint bound) is the APPROVED path.

THE CHEAPER ALTERNATIVE IS EXPLICITLY REJECTED BY THE USER: do NOT carry the mint bound as a hypothesis in the shape `hT` has, and do NOT push the discharge obligation onto task 412. Do it the right way.

APPROVED WORK (route (b), ~6-7 phases, comparable in size to everything landed so far):
1. WITNESS PRESERVATION (~3 phases): the eight-rule case analysis of report 03 section 3 step 4, resting on the three lemmas already machine-checked in that report's section 1 (`mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`, `identifyTime_no_collapse`).
2. RESTATEMENT (~1 phase): give `expandBranchWithFuel_isSome_of_budget` an explicit MINT-BUDGET PARAMETER, in the shape `branchesUsed`/`maxBranches` already establishes. This is what converts route (b)'s amortized bound into something the induction can carry; a per-step potential over (b, ord) provably cannot express it (report 03 section 4), and `maxTime` was checked and is not a usable proxy (arm 3 can lower it).
3. AMORTIZED INDUCTION (~2-3 phases): #mints <= 8*|U|; #identifications <= |knownTimes|_0 + #mints; total shrinkage <= #identifications * |U|; #extensions <= |U| + total shrinkage; then the terminus `buildTableauAt_isSome_of_budget`.

RESEARCH GATE -- MACHINE-CHECK BEFORE PLANNING. Report 03 marks two load-bearing claims UNCERTAIN, and the whole mint bound rests on both:
  (i) section 3 step 4, witness preservation across `.splitOrdered` arm 3 -- ARGUED, NOT MACHINE-CHECKED. The two modal rules are trivial (their witness sits at the same time as `sf`, so identification moves both together); THE SIX TEMPORAL ONES NEED THE REACHABILITY TRANSPORT and were not verified.
  (ii) section 3 step 3, "formulas are never deleted" -- read off the rule shapes, consistent with the landed `expandOnceUnblocked_card_lt` / `expandOnceUnblocked_split_card_lt`, but NOT PROVED.
Machine-check BOTH before any plan is written. This task has twice had a plan rest on an unverified lemma that later turned out FALSE (the unconditional `buildTableau_isSome`; then the `.splitOrdered` cardinality twin). A third occurrence is not acceptable. If witness preservation fails for any temporal rule, ROUTE (b) IS DEAD and that is a THIRD retarget decision requiring human approval -- report it plainly, do not work around it and do not substitute a weaker statement.

PRESERVED, DO NOT RE-PROVE: phases 1-10 of plans/02_lexicographic-splitordered-measure.md are landed, sorry-free, axiom-free, and green repo-wide. Consume those declarations. `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000` default stay BYTE-IDENTICAL. No `NoSplit` reintroduction; no admitted `WorldWitness` or `hT`; no `sorry`; no narrowing a statement into vacuity. The refuted unconditional `buildTableau_isSome` and the refuted `.splitOrdered` cardinality twin stay on the do-not-re-attempt register. `resolveOpenArmCancellable` in CancellableExpansion.lean remains a DECLARED, deliberately-unrepaired out-of-scope divergence. Task 412 must not be planned against `buildTableauAt_isSome_of_budget` until it lands; the Phase 3 assets (`BudgetedTableau`, `buildTableauAt`, `BudgetedTableau.upgrade`) are available and sorry-free meanwhile.

RESUME SEQUENCE: `/research 428` first (discharge the two uncertain claims above), then `/orchestrate 428`. The stale loop guard from the prior invocation has been removed so a restart gets a fresh cycle budget.

---

### 427. Sync typst book with refactored paper
- **Effort**: large
- **Status**: [EXPANDED]
- **Task Type**: typst
- **Topic**: paper-refactor
- **Dependencies**: Task 414, Task 415, Task 417, Task 419, Task 420, Task 438, Task 439

**Description**: SUPERSEDED 2026-08-13 by project 442 (`revise_bimodal_reference_book_against_paper_and_lean`), which ABSORBS this task in full. 427's binding content -- the def:frame quote block, the supporting-definition quotes, the three notation traps, the converse-notation user decision, the audit discipline, the paper-snapshot procedure, and the non-goals -- was carried into 442's description VERBATIM. What 442 drops from this task: the gating on 414/415/417/419/420 (lifted by user decision 2026-08-13) and the restriction to the definitional/semantic layer (442 extends the remit to the completeness story, the decidability status, the module-structure corrections, and the expository mandate). Do not dispatch this task; dispatch 442.

=== ORIGINAL DESCRIPTION, RETAINED FOR THE RECORD ===

RE-ISSUED 2026-08-10 (description rewrite only; status unchanged). Bring the BimodalReference typst book back into sync with the paper at /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, and with the Lean tree as it stands once the paper-refactor task chain has landed. This is the typst-side counterpart of the LaTeX work in latex/subfiles/; it was deliberately deferred and declared out of scope there, so the typst chapters currently contradict both the paper and the corrected LaTeX.

=== 1. THE MODEL TO COPY FROM -- CORRECTED, THIS IS THE POINT OF THE RE-ISSUE ===
DO NOT use latex/subfiles/02-Semantics.tex as the model for the typst restatement. The prior description instructed exactly that, and the instruction is now WRONG: that subfile was rewritten by task 420 phase 5 against the THREE-axiom frame, which the paper has since superseded. Copying it today would write the same superseded definition into the typst book that the LaTeX subfile currently carries -- the precise failure mode this task exists to prevent.

Instead, model the typst restatement DIRECTLY on the paper, the same way task 420 phase 5 originally modeled the LaTeX subfile on the paper. Treat latex/subfiles/02-Semantics.tex as a FELLOW DOWNSTREAM CONSUMER, not a second source of truth: it is task 420's remaining work to re-correct it, and it may still be mid-sync when this task runs. If the two disagree, the paper wins.

GENERATIONAL GAP (this is asymmetric, and the asymmetry matters): latex/ and typst/ are stale by DIFFERENT amounts. latex/subfiles/02-Semantics.tex is one generation behind (it matches Lean's one-directional Compositionality and omits Seriality and Spherical entirely), while typst/chapters/02-semantics.typ is two further generations behind (it still independently axiomatizes Reflection, has no Limit clause at all, and predates even the positive-cone / converse-convention presentation the paper now uses in full). Neither directory has had a commit since 2026-08-08, so BOTH are now an additional generation behind again -- they also predate the partial-history restatement and the segment-notation change described below.

=== 2. WHAT THE TYPST BOOK MUST SAY (quote-backed, so the anchors stay recoverable) ===
Paper anchor \label{def:frame}, verbatim: "A *frame* is any F = <W, D, =>> where W is a nonempty set of world states, D is a temporal order, and => is a task relation satisfying the following for x, y >= 0: *Compositionality:* w =>_{x + y} v if and only if w =>_x u and u =>_y v for some u in W. *Seriality:* w =>_x u and v =>_x w for some u, v in W. *Limit:* intersection over x > 0 of (w)_x = {w}. *Spherical:* intersection of S is nonempty for any directed family S of nonempty fibers and segments."

FOUR axioms. Nullity is NOT among them: \label{lem:nullity}, verbatim, "w =>_0 w for every world state w in W in every frame F = <W, D, =>>", derived choice-free from *Seriality* at x = 0 plus *Limit*. Reflection is likewise not an axiom -- negative durations come from the converse convention.

Supporting definitions the frame definition presupposes:
- \label{def:temporal-order}: "A *temporal order* is a nontrivial totally ordered abelian group D = <D, +, 0, <=> with *positive cone* D^+ := {x in D : x >= 0}."
- \label{def:task-relation}: a task relation on a NONEMPTY set of world states W over a temporal order D, "extended to negative durations by the *converse convention* w =>_{-x} u := u =>_x w for x >= 0", determining -- Fiber: Fib(w, x) := {u in W : w =>_x u}; Cone: (w)_x := union over |y| < x of Fib(w, y) where x > 0; Segment: [w, v]_x^y := Fib(w, x) intersect Fib(v, -y) where x, y >= 0.
- \label{def:directed}: "A nonempty family of sets S is *directed* just in case S' subset-of S_1 intersect S_2 for some S' in S whenever S_1, S_2 in S."
- \label{def:world-history}: "A *partial history* over a frame F = <W, D, =>> is a function tau : X -> W on a nonempty set X subset-of D where tau(x) =>_{y-x} tau(y) for all times x, y in X. ... A *world history* is any partial history whose domain X is *convex* ... A world history is *total* --- equivalently, a *possible world* --- just in case X = D. ... The set of all total world histories over F is denoted H_F." The layering is partial history, then world history (convex domain), then total. A partial history requires a NONEMPTY domain and does NOT require convexity.
- The existence machinery, if the book states it: \label{def:constraints} defines the constraints a new time imposes; \label{lem:constraint} (Constraint Lemma) shows they form a directed family of nonempty fibers and segments; the new \label{lem:fibers} and \label{lem:admissible} characterize admissible one-point extensions; \label{lem:step} (Step Lemma) applies *Spherical* and closes via lem:admissible to extend a partial history by one duration; \label{thm:extension} runs Zorn over partial histories and closes via lem:step; \label{cor:occurrence} follows (a MERGED anchor -- the former thm:occurrence and app:nonempty no longer exist), giving tau(x) = w at any prescribed time x and H_F nonempty for every frame.
- \label{def:BL-semantics} evaluates at "a possible world tau in H_F and time", with the box clause quantifying over all sigma in H_F and the atom clause carrying no domain conjunct; \label{def:logical-consequence} quantifies over models, possible worlds tau in H_F, and times x in D.

THREE VOCABULARY AND NOTATION TRAPS -- writing any of these into the typst book is precisely the failure this task exists to prevent:
(a) Segments are written [w, v]_x^y with the defining equation above. The paper's old `\Seg` macro is DELETED from its preamble and survives only inside commented-out lines; function-application segment notation is not current notation.
(b) *Spherical* ranges over directed families of nonempty FIBERS AND SEGMENTS as two SEPARATE classes, with directedness per \label{def:directed}. The retired device by which one-sided fibers counted among the segments must not be reintroduced. The lemma formerly cited for the two-sided segment family no longer exists in the paper -- cite lem:constraint and lem:step.
(c) The vocabulary "task-constrained function" is RETIRED paper-wide (the extension theorem, the occurrence theorem, and the gluing footnote were all recast). Use "partial history", "world history", and "total world history" / "possible world".

=== 3. KNOWN STALE SITES -- RE-AUDIT, DO NOT TRUST THIS LIST ===
The prior description's stale-site enumeration for typst/chapters/02-semantics.typ (one-way Nullity rather than the iff, Reflection as a substantive axiom, unrestricted mixed-sign Compositionality, and a missing Limit clause) is itself now INCOMPLETE: it predates Seriality, Spherical, the interpolation direction of Compositionality, and the fiber/segment apparatus all becoming required def:frame content. The prose gloss in the same chapter repeats the same errors and frames the mixed-sign form as a Lean/paper divergence -- that framing was already inverted (the paper ADOPTED the positive-cone presentation, so it should record AGREEMENT), and is now stale on top of being inverted.

Re-audit the stale-site enumeration against the CURRENT four-axiom paper rather than trusting either the prior description or the LaTeX subfile.

STALE LINE ANCHORS, to be re-derived rather than trusted: 02-semantics.typ cites a Lean line number for the TaskFrame structure that has already moved once; typst/SYNC-MAP.md records the 02-semantics verdict against a pre-refactor paper line range. Re-derive both. Anchor paper claims by \label, never by line number -- this cluster has already burned a full task on line-number drift, and the paper file changes intra-day.

=== 4. SCOPE ===
Audit ALL of typst/chapters/ against the current paper and the post-chain Lean tree, not just 02-semantics.typ. Chapters carrying paper-anchored claims the refactor chain plausibly touches: 02-semantics.typ (frame and semantics), 04-metalogic.typ (completeness, FMP, decidability), p2-frame-classes.typ (the DF/DN/CO paper correspondence), p3-ltl-to-tm.typ and p3-vlach-blstar.typ (paper clause ranges). Update typst/SYNC-MAP.md verdict rows for every claim re-verified, and refresh typst/sync-check-whitelist.txt if paper labels changed -- note that def:temporal-order, def:task-relation, and def:directed are NEW labels that did not exist when the whitelist was last written, and the segment-lemma label was DELETED; also NEW since then are def:constraints, lem:fibers, lem:admissible, and lem:step, while thm:occurrence and app:nonempty were MERGED into the NEW cor:occurrence. Verify with scripts/typst-sync-check.sh (backtick name resolution plus count freshness) and a full typst compile of typst/BimodalReference.typ.

=== 5. WHY THIS RUNS LAST ===
Each predecessor changes what the typst book must say: 420 fixes the frame definition itself (its phase 6, re-scoped to add Seriality, Spherical, and the interpolation direction together, phase-waits on 415); 414 refactors the semantics to total-history validity; 415 replaces the canonical frame and reworks completeness; 417 moves FMP to a finite WorldState over Z; 419 machine-checks the CO-Reynolds independence result. Syncing typst before these land would guarantee a second full re-sync.

=== 6. WHAT SURVIVES, WHAT DOES NOT ===
SURVIVES: the overall charter (the typst book is stale and must be resynced last); the audit scope in section 4, which is a process statement and not definitional content; the stale-line-anchor discipline the prior description already called for, which is more urgent now, not less.
SUPERSEDED by round 1 (the team research): the instruction to model the typst restatement on latex/subfiles/02-Semantics.tex; the completeness of the stale-site enumeration; the three-axiom framing throughout.
SUPERSEDED by round 2 (round-1 findings that no longer hold): round 1's quotes of def:world-history, thm:extension, and the *Spherical* axiom; its citation of the now-deleted segment lemma; its function-application segment notation; its "task-constrained function" vocabulary; and every parenthetical possible_worlds.tex:NNNN locator. Round 2 also re-measured the latex/typst staleness and found both a further generation behind (section 1). Round 1 remains authoritative for everything round 2 did not touch.

=== 7. NON-GOALS ===
No edits under /home/benjamin/Philosophy/Papers/ -- the paper is READ-ONLY ground truth. No changes to latex/subfiles/ -- re-correcting 02-Semantics.tex is task 420's remaining work, not this task's. No Lean changes: if the audit finds a Lean/paper divergence, record it and raise a separate task rather than fixing it here.

NOTATION (binding user decision, 2026-07-28, carried forward unchanged): any explicit converse operation on the task relation is written with a superscript inverse -- $Rightarrow^{-1}$ / $R^{-1}$ -- NEVER the relation-algebra breve/smile ($breve{R}$, $R^{smallsmile}$) common in the arrow-logic literature. The paper itself states the converse convention with subscript negation only and introduces no operator symbol at all; the corrected LaTeX subfile followed suit, so the typst restatement should also introduce none unless a symbol is genuinely needed.

=== 8. PAPER SNAPSHOT DISCIPLINE (superseded baseline procedure; do this before quoting any definition) ===
Run `bash scripts/check-paper-definitions.sh` and read specs/paper-definitions-of-record.md. That file -- not the paper -- is what specs in this repository cite: it pins every definition this cluster depends on (def:temporal-order, def:task-relation, def:directed, def:frame and each of its four axioms individually, lem:nullity, def:world-history, def:constraints, lem:constraint, lem:fibers, lem:admissible, lem:step, thm:extension, cor:occurrence, def:BL-model, def:BL-semantics, def:frame-validity, def:logical-consequence, and the CO / TMP-CO aitem anchors) with verbatim text and content hashes re-derived from the live paper on every run. Lint outcomes: case (a) silent pass and case (b) notice (paper changed but no recorded definition drifted) -- proceed; case (c) FAIL naming each drifted anchor -- STOP and re-issue the affected specs before consuming them. The md5/HEAD-baseline diff procedure this section formerly prescribed is RETIRED (its baselines were already three drift waves stale). Cite by \label (or \aitem key) only; a bare possible_worlds.tex:NNNN is never a citation. Quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search.

---

### 426. Settle anchor row countermodel or nontermination for g p box g p
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 165, Task 412, Task 428
- **Research**: [archive/418_fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos/artifacts/after-verdicts.md]

**Description**: Settle whether the tableau engine can positively refute (G p) -> square (G p), or whether that branch provably never saturates. Context: the cross-world temporal-copy unsoundness in boxNeg/diamondPos is fixed and the engine is sound, but the fix moved this formula from a WRONG answer to NO answer rather than to the intended positive refutation. Measured post-fix: decide returns .fuelExhausted (not .invalid), getCountermodel?.isSome = false, and buildTableau returns none at fuel 30, 60, 400 and 1000 -- so the fuel ceiling is not bracketed from above and there is no evidence a larger budget helps. Pre-fix the same formula returned .extractionFailed, which under this codebase R7 semantics asserts VALIDITY of an invalid formula; the current .fuelExhausted is the only constructor isUndecided recognises, so the present state is honest-but-incomplete rather than wrong. Two hypotheses to discriminate: (a) budget -- the branch does saturate but needs more fuel, in which case find and record the ceiling; (b) non-termination -- the branch never saturates, in which case this is a termination question for FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean, not a budget one, and the honest deliverable is a proof or argument that no finite fuel suffices. Discriminating between (a) and (b) is the primary deliverable; producing the countermodel is the secondary one and only applies under (a). The corpus already pins this outcome directly: CrossWorldPropagationProbe row F asserts the decide constructor and builds green at (false, false, true, false, true) -- update that row if the verdict moves. Do NOT reintroduce any temporal-copy propagation block into boxNeg/diamondPos to make the branch close; that is the exact unsoundness that was removed, and reverting it would restore a false claim of validity. Note the related but SEPARATE inheritance also recorded for the parent task: the decidable-branch-gate family (boxAnchoredCheck, boxGridCheck, regionGate, regionLabelCheck, rayUpOk/rayDnOk) now computes false on every multi-world branch; that is the truth-lemma side-condition problem and is not this task.

---

### 425. Machine check discrete non compactness witness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 423

**Description**: Convert the informal argument at FormalSystem/Metalogic/StrongCompleteness.lean:56-62 into a machine-checked theorem: the FrameClass.Discrete consequence relation is not compact, hence strong completeness is refuted for that class.

The witness is the premise set {F p} union {not X^n p : n in N} where X phi = Formula.next phi. Every finite subset is satisfiable over Z (place p beyond the largest n used); the whole set is unsatisfiable over any Archimedean discrete carrier, because the F p witness would lie at some finite successor distance, contradicting the corresponding not X^n p.

The load-bearing ingredient is already in the tree: Formula.next phi = Formula.untl phi Formula.bot (FormalSystem/Syntax/Formula.lean:490) genuinely is a next-step operator — through the untl clause of TruthAt, "exists s > t, phi(s) and for all r in (t,s), false" says exactly that s is the immediate successor. No extra hypothesis is needed for this. The "not satisfiable" half is where IsSuccArchimedean does its work, via Order.succ_iterate-style reachability lemmas in Mathlib.

This is the negative half of the per-class split and is independent of the compactness gate — it is not affected by whether Route B succeeds. It depends only on the set-based layer's vocabulary (SatisfiableDiscreteSet / CompactDiscrete are the Discrete analogues of SatisfiableDenseSet / CompactDense).

Explicitly out of scope: an analogous Dedekind non-compactness witness. That belongs to task 408 and the class's non-compactness is already established; duplicating it here would create scope overlap with an in-flight task for no gain.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md, section "Discrete non-compactness witness".

Acceptance: archWitness_finitely_satisfiable, archWitness_not_satisfiable, and discrete_consequence_not_compact all land sorry-free; #print axioms clean on each; lake build green.

---

### 424. Prove shift set representation theorem compactness feasibility gate
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 414, Task 439

**Description**: RE-ISSUED 2026-08-10 (description rewrite only; status remains `not_started` -- no work on the gate itself has been touched by this re-issue). AUDITED FOR EXPOSURE TO THE TruthAt / TOTAL-HISTORY REFACTOR under the paper-definition drift guard infrastructure (definitions-of-record: specs/paper-definitions-of-record.md; lint: scripts/check-paper-definitions.sh).

=== 1. EXPOSURE VERDICT: YES -- this task's governing design is built on Lean vocabulary a sibling task plans to eliminate ===

This task carries topic `strong_completeness`, not `paper-refactor`, so it sat outside the six-task paper-refactor cluster re-issue and was never checked against that cluster's findings. The check was overdue: task 424's governing design document states its whole Representation Theorem (both directions -- the entire content of this gate) in terms of `TruthAt (M : TaskModel F) (Omega : Set (WorldHistory F)) ...`, i.e. the CURRENT Lean signature where `Box` quantifies over an explicitly-supplied `Omega : Set (WorldHistory F)` parameter (`FormalSystem/Semantics/Truth.lean:128`, `Formula.box φ => ∀ σ ∈ Omega, TruthAt M Omega σ t φ`), and the reverse direction of the representation theorem literally sets `Ω := Omega` -- identifying the shift-set carrier with that Lean parameter directly. `valid`, `SemanticConsequence`, and `satisfiable` (`FormalSystem/Semantics/Validity.lean:77-139`) are quantified/witnessed the same way: over an arbitrary shift-closed `Omega`, not fixed to the full total-history set.

Task 414 (`refactor_semantics_to_total_history_validity`, re-issued 2026-08-10, same day as this audit) states its charter as: "make totality-based validity THE validity of the repo, eliminating the Omega parameter from the semantics core," matching the paper's current `def:BL-semantics` box clause exactly -- `Box` ranges over `H_F` (the full set of total world histories), with no externally-supplied `Omega`. This is a real, named, imminent architectural change to the exact vocabulary this task's design document manipulates directly, not a hypothetical.

**This is NOT the same failure mode as the paper-refactor cluster's six** (paper prose moving under a task that quotes it verbatim) -- this task's design document does not quote the paper at all; it cites Lean source (`Truth.lean:128-137`, `Validity.lean:77`) directly. The exposure here is one hop removed: task 424 depends on Lean-side vocabulary that task 414 (itself a paper-alignment task) is about to delete. It would not have been caught by the cluster's own re-issue process, which is exactly why this audit exists as a separate check.

=== 2. WHAT IS CURRENTLY TRUE OF THE TREE (settled fact as of this audit -- not a stale assumption, yet) ===

As of this audit, task 414 has NOT landed (`status: not_started`), so task 424's design document is currently an ACCURATE description of the live tree: `TruthAt` does take an `Omega` parameter today, and `valid`/`SemanticConsequence`/`satisfiable` are quantified over it today. Nothing in this task's description is presently wrong. The risk is entirely forward-looking: if 414 lands before 424 starts (or completes), 424's construction needs to be re-derived against whatever post-refactor `TruthAt` looks like, at cost proportional to how much of S1 has already been built against the Omega-parameterized signature.

=== 3. WHAT SURVIVES vs WHAT IS AT RISK ===

**Survives**: the underlying MODEL-THEORETIC ARGUMENT -- that the task-model class is first-order axiomatizable over the two-sorted signature `<Ω, D; <, +, 0, sh, (A_p)>` because the frame's algebraic content reaches `TruthAt` only through the atom clause -- does not depend on whether `Box`'s quantifier domain is an explicit parameter or a fixed total-history set. Fixing `Omega := H_F` (all total histories) is a special case of the general argument, not a different argument; Q1's structural evidence (design doc section "Q1 -- the compactness argument") and the four-step Route B plan (S1-S4) both survive intact.

**At risk**: the LITERAL Lean statement of both directions of the representation theorem, which is this task's actual, sole acceptance criterion. The reverse direction's `Ω := Omega` identification and the forward direction's `Omega := Set.range (fun σ => h_σ)` construction are stated directly against the current Lean parameter name and type; if task 414 removes that parameter, both directions' STATEMENTS (not just their proofs) need restating against whatever replaces it (most likely: `Omega` is simply dropped and `Box` is hard-coded to quantify over `{σ : WorldHistory F // σ.IsTotal}` or equivalent). This is a restatement cost paid once, not a refutation of the route -- Q1's verdict ("likely, not proved") and Route B's four-step plan are expected to survive under totality-fixed semantics, since `Omega = H_F` is the totality-fixed case already covered by the general argument above.

=== 4. RECOMMENDATION APPLIED: dependency edge added on task 414 ===

Because this task's SOLE deliverable (the gate for the entire ultraproduct/strong-completeness branch) is stated directly against vocabulary task 414 is actively eliminating, and because 424 is `effort: high` (a costly restatement to redo if 414 lands mid-flight or just after), this re-issue adds `414` to this task's `dependencies` array (previously `[361]`, now `[361, 414]`). This is a judgment call made under this audit's authority, not a cluster-wide policy -- reviewable/revertable by the user or a future orchestration pass if the sequencing cost is judged acceptable. Rationale: `414`'s own charter is explicitly to make the paper-aligned totality semantics "THE validity of the repo," so building this gate against the pre-refactor signature and then discovering the rug pulled out from under it is the exact wasted-work failure mode the paper-definition drift guard infrastructure (of which this audit is a part) exists to prevent -- generalized here from paper drift to a Lean-architecture drift originating in a sibling task rather than the paper directly.

=== 5. GOVERNING DESIGN DOCUMENT -- PATH CORRECTED ===

Task 361 has completed and archived since this task was created. The governing design document has moved from `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md` to `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md` -- the same content, corrected path. All section references below (Representation theorem, Risks R3, GATING RULE) are unchanged in content.

=== 6. PRESERVED FROM THE ORIGINAL DESCRIPTION (still binding, unchanged in substance) ===

Prove, in both directions, that the task-model class is representable by shift sets <Omega, D, sh, A> -- D an ordered abelian group, Omega a nonempty type with a D-action sh : Omega -> D -> Omega, and A : Atom -> Omega -> Prop. (Note: once task 414 lands, re-derive this statement against the post-refactor `TruthAt`/`Box` signature per section 3 above before proceeding -- the shift-set carrier `Omega` in THIS sentence is the paper-facing mathematical object, distinct from the Lean parameter of the same name discussed in sections 1-3, which is exactly the coincidence-of-naming this audit had to disentangle.)

THIS TASK IS THE GATE FOR THE ENTIRE ULTRAPRODUCT BRANCH. The follow-on work -- the ultraproduct carrier (S2), the Los lemma for TruthAt (S3), compactness of the Base/Dense consequence relations (S4), and strong completeness for Dense and Base (S5-Dense, S5-Base) -- is NOT AUTHORIZED and has deliberately NOT been created as tasks. It becomes authorized only when this task lands sorry-free. Do not spawn, plan, or dispatch any of it from within this task.

Gate-passed evidence standard, and nothing weaker: a sorry-free Lean statement of both directions, with #print axioms on each direction reporting no sorryAx. A statement that type-checks with a sorry body does not pass. Proving only the forward direction does not pass. A prose argument does not pass.

Cancel condition: if either direction is refuted, or the construction cannot be stated without an additional non-elementary hypothesis, then Route B (semantic compactness via ultraproduct) is REFUTED and the whole branch is cancelled, not retried. Record the refutation and re-open the compactness question; do not proceed to S2 hoping the gap can be patched downstream.

Governing design document: specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md -- section "Representation theorem" for both directions (the reverse direction uses WorldHistory.timeShift and FormalSystem.Semantics.TimeShift.time_shift_preserves_truth, FormalSystem/Semantics/Truth.lean:446), section "Risks" R3 for the Type vs Type* constraint (assert it EARLY, not at assembly time), and section "GATING RULE" for the full gate contract.

Acceptance: both directions sorry-free; #print axioms clean on each; lake build green; the task's summary states explicitly whether the gate PASSED or FAILED.

---

### 423. Land set based consequence layer setderivable and per class setsemanticconsequence
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Create FormalSystem/Metalogic/SetConsequence.lean containing the finitary set-derivability relation SetDerivable, the four per-class SetSemanticConsequence* predicates, the basic lemmas, and the strong-completeness / compactness / model-existence statements. Then import it from FormalSystem/Metalogic/StrongCompleteness.lean.

This is vocabulary only. It proves no compactness result and closes no existing sorry. It is self-contained and unblocks two downstream branches (the Discrete non-compactness witness, and Dense strong completeness).

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/01_set-consequence-layer.md — transcribe section 2 (SetDerivable), section 3 (the four per-class definitions), section 4 (basic lemmas), section 5 (StrongCompletenessDense, CompactDense, strongCompletenessDense_of_compact, SatisfiableDenseSet, ModelExistenceDense). Section 4's "Implementer notes" name three elaboration risks; section 7 records what is deliberately out of scope.

Acceptance (from design/01 section 6, all five required): zero sorries and zero vacuous placeholders; grep -c 'import FormalSystem.Metalogic.BXCanonical' on the new module returns 0; each SetSemanticConsequence* binder list is byte-comparable to its Validity.lean source (valid :79, ValidDense :169, ValidDiscrete :187, ValidDedekindDense :276) with only the premise hypothesis inserted, and uses Type not Type* (Validity.lean:77 records this as deliberate); #print axioms on every new declaration reports no sorryAx; StrongCompleteness.lean imports the module and still builds.

---

### 422. Build discrete chronicle over non archimedean block carrier with restricted coherence
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 414, Task 420, Task 421, Task 439

**Description**: Construct the discrete-case analogue of the existing dense chronicle machinery, over the non-Archimedean carrier Q x_lex Z confirmed by the predecessor task.

Deliverable (a): the analogue of box_dense_gives_density (FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:435) and cantorIsoDense for the "box U(T,F) in A" case — block decomposition of the chronicle order into Z-blocks, densification of the block order, and the isomorphism into Q x_lex Z.

Deliverable (b): the three restricted-coherence analogues, mirroring cantor_bfmcs_dense_restricted_tc (:629), _buc (:680), _fuc (:755) at the new carrier.

Why this carrier and not Z: succ_cofinal — the obligation that killed the old BX pipeline, refuted by the Z+Z counterexample in Boneyard/BXPipelineGapAnalysis/ — was only ever needed to force the chronicle into Z, i.e. to make it Archimedean. FrameClass.Base imposes no Archimedean-ness (valid, FormalSystem/Semantics/Validity.lean:79, has no IsSuccArchimedean binder). The Z+Z shape is not a counterexample here — it is the intended carrier. Do not re-attempt succ_cofinal.

PRINCIPAL RISK, unresolved at scoping time: it has NOT been verified that the chronicle's block order can always be densified without disturbing MCS-chain coherence. A countable discrete order without endpoints is a Z-indexed fibration over its block order, but making the total structure a group requires the block order to carry a compatible group structure. If this fails, escalate as [BLOCKED] with the failing coherence obligation named — do not paper over it with a sorry or a vacuous placeholder.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md, sections 5.4-5.7.

Acceptance: the block-carrier construction and all three restricted-coherence analogues are sorry-free; #print axioms on each reports no sorryAx; lake build green. This task does NOT close the Transfer.lean:1242 sorry — that is task 169's job, which consumes this output.

FOUR-AXIOM / TOTALITY EXPOSURE NOTE (added 2026-08-10): this task constructs a chronicle-backed frame while the paper-refactor cluster (tasks 420, 414, 415) refactors TaskFrame and validity underneath it. Once task 420 lands, TaskFrame carries the paper's FOUR def:frame axioms (biconditional Compositionality, Seriality, Limit, Spherical -- pinned in specs/paper-definitions-of-record.md) plus a Nonempty WorldState field and a [Nontrivial D] binder; any frame this task builds must discharge ALL of them, not just the current three structure fields. Once task 414 lands, `valid` / `SemanticConsequence` are Omega-free and totality-based, so the Validity.lean line citation above and the 'no IsSuccArchimedean binder' observation must be re-verified against the refactored signatures. Sequence this task after 420/414/415 or budget for the rebase.

---

### 421. Correct transfer route guidance and probe non archimedean discrete carrier
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Two deliverables on the Base weak terminus, both small.

(a) Correct the refuted route guidance. FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1239-1241 currently proposes "(i) a Base-MCS -> Discrete-MCS transfer lemma that lets countermodel_discrete_reynolds_v2 apply". Route (i) is REFUTED and MUST NOT be re-attempted. The witness: over D := Z x_lex Z (lex, first coordinate dominant) with p true exactly at points >= (1,0), every point has an immediate successor so box U(T,F) holds; G(Gp -> p) holds at (0,0); FGp holds at (0,0) (witness (1,0)) but Gp fails there (witness (0,1)); hence Axiom.z1 p is false. So a Base-MCS containing box U(T,F) need not be Discrete-consistent and no Base-to-Discrete MCS transfer lemma can exist. Replace those comment lines with the refutation and point at route (ii). Docstring/comment-only — do not touch the sorry at :1242 in this task.

(b) Probe the recommended carrier. Confirm AddCommGroup, LinearOrder, IsOrderedAddMonoid, Nontrivial all resolve for Q x_lex Z, and add a CarrierProbe-style example block (mirroring the pattern at FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:61-100) showing the parametric canonical machinery elaborates at that carrier. This is a confirmation step, not a supply step: Mathlib/Algebra/Order/Monoid/Prod.lean:52-59 declares @[to_additive] instance Lex.isOrderedMonoid ... : IsOrderedMonoid (a x_lex b), whose additive form supplies IsOrderedAddMonoid (a x_lex b). Confirm the instance actually fires for Q x_lex Z (in particular that AddLeftStrictMono Q is found) — the generated instance name was inferred from the attribute and not resolved by lookup.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md, section 5.3 (the refutation), 5.5 (the carrier), 5.6 (the Mathlib instance).

Acceptance: the refuted-route comment no longer appears at Transfer.lean:1239-1241; the probe block elaborates; lake build is green; #print axioms on any new declaration shows no sorryAx; the live non-Boneyard sorry count is unchanged at 2 (verify with: grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -vc Boneyard).

---

### 420. Align task frame with positive cone axioms
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 438, Task 439
- **Research**: [420_align_task_frame_with_positive_cone_axioms/reports/01_taskframe-positive-cone-limit-nullity.md]
- **Summary**:
  - [420_align_task_frame_with_positive_cone_axioms/summaries/01_taskframe-limit-nullity-alignment-summary.md]
  - [420_align_task_frame_with_positive_cone_axioms/summaries/03_four-axiom-fields-unblocked-summary.md]
  - [420_align_task_frame_with_positive_cone_axioms/summaries/04_axiom-fields-split-batch-summary.md]
- **Plan**:
  - [420_align_task_frame_with_positive_cone_axioms/plans/02_four-axiom-frame-alignment.md]
  - [420_align_task_frame_with_positive_cone_axioms/plans/03_four-axiom-fields-unblocked.md]
  - [420_align_task_frame_with_positive_cone_axioms/plans/04_axiom-fields-split-batch.md]

**Description**: RE-ISSUED 2026-08-10 (description rewrite only; status remains `blocked` -- phases 1-5 are LANDED, GREEN, and COMMITTED and are not undone by this re-issue). ALIGN THE LEAN TaskFrame WITH THE PAPER'S FOUR-AXIOM def:frame.

=== 1. THE PAPER'S CURRENT def:frame (settled; do not re-litigate) ===
Paper anchor \label{def:frame}, verbatim: "A *frame* is any F = <W, D, =>> where W is a nonempty set of world states, D is a temporal order, and => is a task relation satisfying the following for x, y >= 0: *Compositionality:* w =>_{x + y} v if and only if w =>_x u and u =>_y v for some u in W. *Seriality:* w =>_x u and v =>_x w for some u, v in W. *Limit:* intersection over x > 0 of (w)_x = {w}. *Spherical:* intersection of S is nonempty for any directed family S of nonempty fibers and segments."

FOUR axioms. Nullity is NOT among them -- it is DERIVED. \label{lem:nullity}, verbatim: "w =>_0 w for every world state w in W in every frame F = <W, D, =>>", proved choice-free from *Seriality* at x = 0 plus *Limit* (the paper also records that Compositionality plus Limit suffice, so it is over-determined).

Preliminaries, each quoted so the label stays recoverable if renamed:
- \label{def:temporal-order}: "A *temporal order* is a nontrivial totally ordered abelian group D = <D, +, 0, <=> with *positive cone* D^+ := {x in D : x >= 0}."
- \label{def:task-relation}: a task relation on a NONEMPTY set of world states W over a temporal order D, "extended to negative durations by the *converse convention* w =>_{-x} u := u =>_x w for x >= 0", determining -- Fiber: Fib(w, x) := {u in W : w =>_x u}; Cone: (w)_x := union over |y| < x of Fib(w, y) where x > 0; Segment: [w, v]_x^y := Fib(w, x) intersect Fib(v, -y) where x, y >= 0.
- \label{def:directed}: "A nonempty family of sets S is *directed* just in case S' subset-of S_1 intersect S_2 for some S' in S whenever S_1, S_2 in S."

NOTATION IS BINDING: segments use the bracket form [w, v]_x^y with the defining equation spelled out above. The paper's old `\Seg` macro is DELETED from its preamble and survives only inside commented-out lines; function-application segment notation is not current notation. *Spherical* ranges over directed families of nonempty FIBERS AND SEGMENTS as two SEPARATE classes -- the retired device by which one-sided fibers counted among the segments must not be reintroduced. The lemma formerly cited for the two-sided segment family no longer exists in the paper; cite \label{lem:constraint} and \label{lem:step} instead.

=== 2. WHAT LANDED (phases 1-5, PRESERVED -- do not redo, do not revert) ===
Phases 1-5 landed green across five commits and are sorry-free, zero-new-axiom results. PRESERVED:
- Phase 1's re-anchored def:frame citations, which still point at the live def:frame region (now larger and four-axiom).
- Phase 2's docstring recast from "divergence" framing to "agreement" framing -- directionally still correct; do NOT re-invert it.
- Phases 3-4's THREE helper theorems in FormalSystem/Semantics/TaskFrame.lean: `limit_nullity_of_succOrder`, `limit_nullity_of_shift`, and `exists_uniform_radius_of_finite`. Each is stated against a bare relation `R : W -> D -> W -> Prop` with hypotheses passed in explicitly, never against a TaskFrame structure field, and each was independently re-verified as SURVIVING VERBATIM in both research rounds. The one thing that changes is how their nullity hypothesis is discharged: Nullity is no longer a frame axiom to cite directly but a derived lemma (lem:nullity, from Seriality plus Limit), so the hypothesis must now be proved via that derived lemma rather than read off a structure field.
- Phase 5's LaTeX restatement SCAFFOLDING -- the \label{def:frame} cross-reference, the positive-cone and task-cone macros, and the primitives table -- survives as reusable structure even though the definition TEXT it contains must be rewritten again (see section 3).

=== 3. WHAT IS STALE (a second time) ===
- The phase-5 LaTeX definition text in latex/subfiles/02-Semantics.tex is STALE A SECOND TIME. It was written against the superseded three-axiom presentation and must now be rewritten to state the biconditional *Compositionality* (interpolation included), *Seriality*, *Limit*, *Spherical*, and the fiber/segment/directedness apparatus.
- PHASE 6 MUST BE RE-SCOPED. Its former scope -- add one structure field and discharge the instantiation sites -- is too small. It must add *Seriality*, *Spherical*, and the interpolation direction of *Compositionality* TOGETHER, with the fiber/segment/directedness definitions they are stated with, plus the `Nonempty WorldState` field and the `[Nontrivial D]` structure binder (def:temporal-order and def:task-relation both require them, and the structure currently has neither -- note that `valid` and `SemanticConsequence` in FormalSystem/Semantics/Validity.lean ALREADY carry `[Nontrivial D]`, so the gap is specifically at the structure level, not everywhere).
- `forward_comp` states only the one-directional inclusion, and the module's own docstrings still say the equality is not adopted. Both are now backwards: the paper's Compositionality IS biconditional and interpolation IS asserted. The docstring text must be corrected along with the field.
- The task's own former title named one axiom out of four, and that axiom's former name is itself superseded (it is now simply *Limit*). The task has been renamed accordingly.

OPEN DESIGN QUESTION, not settled: `nullity_identity` currently exists as an axiom FIELD, in the strictly stronger iff form. The paper asserts reflexivity only, via lem:nullity. Whether Lean should demote it to a derived lemma, keep the iff form as a deliberate strengthening, or keep reflexivity as a derived lemma and drop the injectivity-at-zero direction is a decision for the target-signature work, taken jointly with task 414 -- flagged here, not resolved here.

=== 4. THE MACHINERY THE AXIOMS EXIST TO SUPPORT ===
Transcribe these because they are what makes the axioms load-bearing rather than decorative:
- \label{def:constraints} (promoted from lead-in prose to a numbered Ddef): for a partial history tau : X -> W over a frame F and duration z in D \ X, the *constraints imposed on z* are the segments [tau(t), tau(s)]_{z-t}^{s-z} for times t, s in X where t < z < s, and the fibers Fib(tau(t), z - t) for t in X otherwise.
- \label{lem:constraint} (Constraint Lemma): the constraints imposed on z form a directed family of nonempty sets. RESTRUCTURED: this lemma now states ONLY directedness plus nonemptiness -- the admissibility clause its earlier merged statement carried has been split out into lem:admissible below. Its proof consumes Compositionality in BOTH directions plus Seriality.
- \label{lem:fibers} (NEW): a world state u belongs to every member of the constraints imposed on z just in case tau(t) =>_{z-t} u for every t in X.
- \label{lem:admissible}: the function tau union {<z, u>} is a partial history on X union {z} just in case u belongs to every member of the constraints imposed on z. Proof = lem:nullity (the zero loop at z itself) + lem:fibers.
- \label{lem:step} (Step Lemma): "Every partial history tau : X -> W over a frame F extends to a partial history on X union {z} for any duration z in D." Proof = lem:constraint + *Spherical* (its SOLE application site) + lem:admissible. Closing remark, verbatim: "When the family has a subset-least member, that member already contains a candidate and *Spherical* is not needed."
- \label{thm:extension}: "Every partial history tau : X -> W over a frame F is extended by some total world history sigma in H_F." Proof = Zorn over partial histories ordered by extension, closed via lem:step. Nothing else.
- \label{cor:occurrence} (MERGED anchor -- the former \label{thm:occurrence} and \label{app:nonempty} NO LONGER EXIST): "For any frame F = <W, D, =>>, world state w in W, and time x in D, there is a total world history tau in H_F where tau(x) = w, and so H_F is nonempty." Strictly stronger than the old pair (the time x is universally given, not merely witnessed); its proof extends the one-point partial history {<x, w>} directly via thm:extension -- the old translation argument is GONE from this chain.
The Lean development should mirror this decomposition lemma-for-lemma per the literature-fidelity policy.

=== 5. HISTORY STRUCTURES -- JOINT SCOPE WITH TASK 414 ===
\label{def:world-history}, verbatim: "A *partial history* over a frame F = <W, D, =>> is a function tau : X -> W on a nonempty set X subset-of D where tau(x) =>_{y-x} tau(y) for all times x, y in X. ... A *world history* is any partial history whose domain X is *convex* ... A world history is *total* --- equivalently, a *possible world* --- just in case X = D. A partial history sigma *extends* tau just in case dom(tau) subset-of dom(sigma) and tau(x) = sigma(x) for all x in dom(tau). The set of all total world histories over F is denoted H_F." The layering is partial history, then world history, then total. Note a partial history requires a nonempty domain and does NOT require convexity. The vocabulary "task-constrained function" is retired paper-wide and must not appear as current terminology.

GAP: Lean's `WorldHistory` (FormalSystem/Semantics/WorldHistory.lean) has `domain : D -> Prop` with NO nonemptiness field, so the empty history is a legal Lean WorldHistory but is not a world history in the paper. Earlier research scored the base definition a "match"; it is a match on four of five conjuncts. Impact on the consequence chain is nil, but it is real for thm:extension fidelity, whose hypothesis is a NONEMPTY partial history. Introduce the `PartialHistory` / `WorldHistory` layering and the nonemptiness field ONCE, jointly with task 414, BEFORE the consequence refactor -- not after, and not twice.

=== 6. CROSS-TASK ACCEPTANCE CRITERION (shared with task 414) ===
Phase 6 is NOT done when Spherical typechecks as a structure field. *Spherical*'s Lean statement must be literally the hypothesis that lem:step's proof consumes -- not an inert field, and no longer pointed at thm:extension's proof, which under the current architecture consumes only Zorn plus lem:step. If this task lands Spherical as an inert field while 414 separately rebuilds totality machinery without threading it through, both tasks can go green while jointly failing to reconstruct thm:extension. Landing the field and demonstrating lem:step consumes it are one deliverable, not two.

=== 7. REMAINING MECHANICAL WORK CARRIED FORWARD ===
Inventory and discharge ALL TaskFrame instantiation sites tree-wide -- re-run the site-inventory greps (`: TaskFrame`, `TaskFrame D where`, `.mk`) rather than trusting the prior inventory, which predates task 415's landing. Known cases: `trivialFrame` (Unit singleton, trivially fine), `identityFrame` (verify), `natFrame` (violates Limit over dense D -- any state is reachable in arbitrarily small nonzero duration; repair the relation or restrict its temporal parameter to discrete D), plus every canonical/countermodel frame in FormalSystem/Metalogic/ (coordinate with task 415, which owns the per-class canonical obligations). The LaTeX restatement must still compile standalone (pdflatex with TEXINPUTS=../assets: from latex/subfiles/). SCOPE BOUNDARY with task 409: 409 owns 04-Metalogic.tex and 06-Notes.tex identifier-architecture fidelity; THIS task owns the 02-Semantics.tex frame-definition subsection. OPTIONAL STRETCH (defer if nontrivial): formalize the paper's T1 topology theorem as a sanity check.

=== 8. WHAT SURVIVES, WHAT DOES NOT ===
SURVIVES: everything in section 2, plus the blocker MECHANISM (see the blockers field), plus the scope boundary with 409 and the notation decision below.
SUPERSEDED by round 1 (the team research): the entire three-axiom framing -- iff-Nullity as a primitive axiom, the one-directional positive-cone Compositionality law with interpolation declared not adopted, the "Limit Nullity" axiom name, Reflection-as-derived-only framing, and Occurrence left unaddressed; the claim that `forward_comp` is exactly the official law; the assertion that Nullity matches as a primitive axiom.
SUPERSEDED by round 2 (round-1 findings that no longer hold): round 1's quotes of def:world-history, thm:extension, and the *Spherical* axiom; its citation of the now-deleted segment lemma; its function-application segment notation; its "task-constrained function" vocabulary; its "match" verdict on the base WorldHistory definition (section 5); its cross-task acceptance criterion pointed at thm:extension rather than lem:step (section 6); and every parenthetical possible_worlds.tex:NNNN locator. Round 1 remains authoritative for everything round 2 did not touch, including the entire phases-1-5 survival inventory.

=== 9. NON-GOALS ===
No edits under /home/benjamin/Philosophy/Papers/ -- the paper is READ-ONLY ground truth. No change to `WorldHistory.respects_task` beyond the layering decision in section 5 (it evaluates at d = t - s with the converse convention handling signs). No validity/semantics refactor: task 414 owns that and depends on this task, so the Omega-free API lands once, against the final frame structure. Related: 414, 415, 417, 409.

NOTATION (binding user decision, 2026-07-28, carried forward unchanged): any explicit converse operation on the task relation is written with a superscript inverse -- $\Rightarrow^{-1}$ (and $R^{-1}$ for abstract relations) -- NEVER the relation-algebra breve/smile ($\breve{R}$, $R^{\smallsmile}$) common in the arrow-logic literature. This applies to the 02-Semantics.tex restatement of the converse convention, to any Lean notation or declaration names (prefer inv / ^-1 vocabulary, e.g. `TaskRel.inv`, consistent with Mathlib's `Inv`), and to all module docstrings. The paper itself states the converse convention with subscript negation only and introduces no operator symbol; if one is ever introduced paper-side it uses the same superscript -1 form.

=== 10. FIRST STEP FOR THE NEXT DISPATCH (do this before reading any definition) ===
Run `bash scripts/check-paper-definitions.sh` and read specs/paper-definitions-of-record.md. That file -- not the paper -- is what specs in this repository cite: it pins every definition this cluster depends on (def:temporal-order, def:task-relation, def:directed, def:frame and each of its four axioms individually, lem:nullity, def:world-history, def:constraints, lem:constraint, lem:fibers, lem:admissible, lem:step, thm:extension, cor:occurrence, def:BL-model, def:BL-semantics, def:frame-validity, def:logical-consequence, and the CO / TMP-CO aitem anchors) with verbatim text and content hashes re-derived from the live paper on every run. Lint outcomes: case (a) silent pass and case (b) notice (paper changed but no recorded definition drifted) -- proceed; case (c) FAIL naming each drifted anchor -- STOP and re-issue the affected specs before consuming them. The md5/HEAD-baseline diff procedure this section formerly prescribed is RETIRED (its baselines were already three drift waves stale). Cite by \label (or \aitem key) only; a bare possible_worlds.tex:NNNN is never a citation. Quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search.

---

### 419. Machine check co reynolds independence
- **Effort**: large
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 420, Task 438, Task 439
- **Research**: [419_machine_check_co_reynolds_independence/reports/01_co-not-derives-prior-u.md]
- **Plan**: [419_machine_check_co_reynolds_independence/plans/01_machine-check-co-independence.md]

**Description**: RE-ISSUED 2026-08-10 (description rewrite only; status unchanged). Machine-check the CO-does-not-derive-Reynolds independence result. Currently recorded ONLY as a pen-and-paper model sketch in the Layer 9 prose of FormalSystem/ProofSystem/Axioms.lean (immediately above the `Axiom.prior_U_gap` constructor), where it is explicitly flagged as NOT machine-checked.

GOAL: construct a Lean countermodel establishing that the paper's CO principle does not syntactically derive the Reynolds gap axioms -- specifically that CO does not derive `Axiom.prior_U_gap`.

THE SKETCH TO FORMALIZE: a rational (Q) flow carrying isolated not-phi points that accumulate at an irrational from above validates every CO instance while refuting Prior-U; this is the classical Stavi US-vs-FO gap phenomenon.

WHY IT MATTERS: this is the sole load-bearing justification for the paper-side amendment to \label{def:TMplus-c} / the TM completeness corollary in /home/benjamin/Philosophy/Papers/PossibleWorlds/ (fix.md C4 option 2) -- the paper's completeness claim is deferred to this repository with no independent citation, so if the sketch is right def:TMplus-c is deductively too weak, and if it is wrong the amendment is unnecessary. Right now that amendment rests on an unverified claim.

=== 1. THE PRIMARY OPEN QUESTION: SPHERICAL MAY KILL THE Q-FLOW SKETCH ===
This is the single highest-priority item for the next research pass and it is NOT a routine conformance check. Do not soften it.

The paper's \label{def:frame} now requires FOUR axioms of every frame: "*Compositionality:* w =>_{x + y} v if and only if w =>_x u and u =>_y v for some u in W. *Seriality:* w =>_x u and v =>_x w for some u, v in W. *Limit:* intersection over x > 0 of (w)_x = {w}. *Spherical:* intersection of S is nonempty for any directed family S of nonempty fibers and segments." Any legitimate countermodel frame must satisfy all four -- and Spherical is load-bearing for H_F being nonempty at all, via \label{lem:constraint} -> \label{lem:step} -> \label{thm:extension}.

The paper carries its OWN worked non-example for Spherical, and it is structurally the same family of construction this task's sketch proposes: a Q-carrier flow engineered around a point not reachable within Q. It appears as a footnote to the world-history sentence in the body of the Construction section; the footnote carries NO label of its own, so \label{def:world-history} is the durable formal anchor for it. Current text, verbatim:

  "Convexity alone does not guarantee extendability: taking D = Q and W = {q in Q : q > 0} with r =>_x r' *iff* |r' - r| <= x yields a structure satisfying every axiom but *Spherical*, in which the partial history tau(t) = 1 - t defined for 0 < t < 1 admits no value u at the time 1, since |u - (1 - s)| <= 1 - s for every s < 1 forces u <= 0, and so tau restricts no total world history. *Spherical* is exactly what excludes this structure."

CONSEQUENCE: this task's sketch is at serious risk of not being a legitimate frame at all under the four-axiom def:frame, potentially requiring an entirely different carrier or frame choice if it cannot be repaired to satisfy Spherical. This is a genuine open mathematical question, not a checkbox. By contrast, Compositionality's interpolation direction and Seriality are comparatively low-risk for a deterministic or near-deterministic flow construction; Spherical specifically targets "gaps", which is the entire mechanism the sketch is trying to exploit. Resolve this BEFORE investing in the Lean construction.

Supporting definitions the Spherical check needs, quoted so the labels stay recoverable: \label{def:task-relation} gives Fiber: Fib(w, x) := {u in W : w =>_x u}; Cone: (w)_x := union over |y| < x of Fib(w, y) for x > 0; Segment: [w, v]_x^y := Fib(w, x) intersect Fib(v, -y) for x, y >= 0. \label{def:directed} gives "A nonempty family of sets S is *directed* just in case S' subset-of S_1 intersect S_2 for some S' in S whenever S_1, S_2 in S." \label{def:world-history} gives the partial/world/total layering: a partial history is a function tau : X -> W on a NONEMPTY X subset-of D with tau(x) =>_{y-x} tau(y), a world history is a partial history with convex domain, and total (equivalently: a possible world) means X = D.

=== 2. CITATION CORRECTION FOR THE CO FORMULA ===
The prior description cited "CO source formula: PossibleWorlds/JPL/possible_worlds.tex:3250". That locator is stale AND was wrong when written -- it was inherited from a stale citation in /home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md, not introduced here. Replace it with LaTeX-key anchors, never a line number.

Precise anchors, re-verified 2026-08-10 (note: CO and TMP-CO are `\aitem` axiom KEYS resolved by `\aref`, not `\label{}` names -- earlier research described them as labels, which is imprecise):
- Base TM form: `\aitem{CO}`, inside the extension subsection anchored by \label{sub:Extension}. Verbatim: `\aitem{CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.`
- TM^+ restatement (the one `Formula.co` actually mirrors, per FormalSystem/ProofSystem/Axioms.lean): `\aitem[CO]{TMP-CO}`, inside \label{def:TMplus-c}. Verbatim: `\aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.` with the paper's own footnote "This axiom coincides with \aref{CO} in **TM**, though it is expressed in $\BL^+$."
TMP-CO is the more precise anchor for this task's Lean-facing claim, since it sits inside def:TMplus-c -- the exact definition the fix.md C4 amendment concerns. CO remains the useful base-TM cross-reference.

STALE LOCATOR STILL LIVE IN THE LEAN TREE (this task's work, NOT task 438's): the same stale `possible_worlds.tex:3250` citation also persists at FormalSystem/Theorems/DedekindDerived.lean:359 and FormalSystem/Syntax/Formula.lean:467. Task 438 had no write scope in FormalSystem/ and deliberately did not touch them. Re-anchor both to the `\aitem` keys above as part of this task.

=== 3. CONTEXT ALREADY IN THE TREE -- DO NOT REDO ===
The CONVERSE direction is DONE and SORRY-FREE and must not be redone: `co_derived` in FormalSystem/Theorems/DedekindDerived.lean proves Reynolds |- CO, consuming `Axiom.prior_U_gap` and nothing else outside `FrameClass.Base`; `co_valid` in FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean gives the semantic side. `Formula.co` (FormalSystem/Syntax/Formula.lean) is the CO formula as a source-cited abbreviation; note the triangle there is `Formula.always`, NOT `Formula.box`. This survives untouched by the paper refactor -- it is a proof-system derivability fact that does not depend on def:frame's axiom count at all.

The overall goal statement is likewise unaffected in kind: the paper never mentions Prior-U, Reynolds, or Stavi anywhere (zero grep hits), so this independence result is and remains an entirely repo-side concern layered on top of the paper's CO axiom. Nothing currently in the Lean tree depends on the claim, so the work is additive -- no rebase surface.

Likely needs a /literature acquisition pass for Stavi and Reynolds 1992 on the US-vs-FO expressiveness gap.

=== 4. WHAT SURVIVES, WHAT DOES NOT ===
SURVIVES: the converse-direction proof and its sorry-free status (section 3); the overall goal and its motivation; the observation that this is additive with no rebase surface.
SUPERSEDED by round 1 (the team research): the `possible_worlds.tex:3250` CO citation; the implicit assumption that the Q-flow sketch is an unproblematic frame.
SUPERSEDED by round 2 (round-1 findings that no longer hold): round 1's version of the Q non-example quote, which predates the partial-history restatement and lacks the forcing computation, and its `:926` locator for it; round 1's description of CO/TMP-CO as `\label{}` names. Round 1 remains authoritative for everything round 2 did not touch, including the whole Spherical-risk verdict in section 1, which round 2 re-confirmed in full force.

=== 5. NON-GOALS ===
No edits under /home/benjamin/Philosophy/Papers/ -- the paper is READ-ONLY ground truth. Related: 416, 408, 390.

=== 6. FIRST STEP FOR THE NEXT DISPATCH (do this before reading any definition) ===
Run `bash scripts/check-paper-definitions.sh` and read specs/paper-definitions-of-record.md. That file -- not the paper -- is what specs in this repository cite: it pins every definition this cluster depends on (def:temporal-order, def:task-relation, def:directed, def:frame and each of its four axioms individually, lem:nullity, def:world-history, def:constraints, lem:constraint, lem:fibers, lem:admissible, lem:step, thm:extension, cor:occurrence, def:BL-model, def:BL-semantics, def:frame-validity, def:logical-consequence, and the CO / TMP-CO aitem anchors) with verbatim text and content hashes re-derived from the live paper on every run. Lint outcomes: case (a) silent pass and case (b) notice (paper changed but no recorded definition drifted) -- proceed; case (c) FAIL naming each drifted anchor -- STOP and re-issue the affected specs before consuming them. The md5/HEAD-baseline diff procedure this section formerly prescribed is RETIRED (its baselines were already three drift waves stale). Cite by \label (or \aitem key) only; a bare possible_worlds.tex:NNNN is never a citation. Quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search.

---

### 417. Semantic fmp finite worldstate over z
- **Effort**: medium
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 414, Task 420, Task 438, Task 439
- **Research**: [417_semantic_fmp_finite_worldstate_over_z/reports/02_semantic-fmp-rescoped-z-time.md]
- **Plan**: [417_semantic_fmp_finite_worldstate_over_z/plans/03_semantic-fmp-z-time.md]

**Description**: RE-ISSUED 2026-08-10 (supersedes the prior maximal-history framing). SEMANTIC FMP OVER A FIXED CARRIER, stated against the TOTAL-history semantics of task 414: prove the TruthAt-connected finite model property the paper's decidability corollary proof text cites -- any formula satisfiable over the Discrete class is satisfiable in a model with FINITE WorldState over D = Z -- replacing reliance on the syntactic closure-MCS FMP theorems (FormalSystem/Metalogic/Decidability/FMP/FMP.lean) that never connect to TruthAt. Add decidable model checking for the finite-W-over-Z presentation to back the paper's enumeration argument (restated paper-side as finite W over Z, since every model has infinite D). This is the semantic-FMP follow-on explicitly descoped by the task-165 redirect; the tableau programme remains the decision-procedure route and also rebases onto the new semantics. Related: 165, 410, 411, 412.

=== 1. TARGET PREDICATE ===
Every place this task's eventual Lean target would have named a maximality predicate must instead name TOTALITY -- `forall t, tau.domain t` -- per task 414's corrected charter. Paper anchor \label{def:world-history}, verbatim: "A *partial history* over a frame F = <W, D, =>> is a function tau : X -> W on a nonempty set X subset-of D where tau(x) =>_{y-x} tau(y) for all times x, y in X. ... A *world history* is any partial history whose domain X is *convex* ... A world history is *total* --- equivalently, a *possible world* --- just in case X = D. ... The set of all total world histories over F is denoted H_F." Satisfiability has no labeled paper definition; Lean's satisfiable family inherits the totality fix as a design decision, not as a reconciliation finding. The vocabulary "task-constrained function" is retired paper-wide; use "partial history" and "world history".

=== 2. THE LIMIT AXIOM OVER Z -- SURVIVES VERBATIM ===
The prior description's note survives as pure mathematics and needs only a renaming pass, not a re-derivation: over D = Z the frame axiom is automatic (|y| < 1 forces y = 0, then reflexivity), so the finite-W-over-Z programme is mathematically unaffected. The axiom's paper name is now *Limit* (the earlier "Limit Nullity" name is superseded; the mathematics is unchanged). Paper anchor \label{def:frame}, *Limit*, verbatim: "intersection over x > 0 of (w)_x = {w}", where \label{def:task-relation} gives the cone (w)_x := union over |y| < x of Fib(w, y) for x > 0 and the fiber Fib(w, x) := {u in W : w =>_x u}. The Lean discharge is `TaskFrame.limit_nullity_of_succOrder` (FormalSystem/Semantics/TaskFrame.lean), stated against a bare relation and confirmed surviving verbatim -- this task's TaskFrame packaging discharges the field through it in one line.

=== 3. SPHERICAL OVER Z -- WHAT IS SETTLED AND WHAT IS NOT ===
There is a genuine, precisely-scoped strengthening here that must not be overstated in either direction.

SETTLED (paper-side): the STEP EXTENSION is Spherical-free over a discrete order. \label{lem:step} (Step Lemma) states "Every partial history tau : X -> W over a frame F extends to a partial history on X union {z} for any duration z in D", and its proof closes with, verbatim: "When the family has a subset-least member, that member already contains a candidate and *Spherical* is not needed." The constraint family in question is the one \label{def:constraints} defines and \label{lem:constraint} (Constraint Lemma) proves directed and nonempty: the segments [tau(t), tau(s)]_{z-t}^{s-z} for times t < z < s in X if assignments flank z, and the fibers Fib(tau(t), z - t) for t in X otherwise (the admissibility characterization now lives in the new \label{lem:fibers} and \label{lem:admissible}, and lem:step closes via lem:admissible). Over D = Z any nonempty bounded set of integers has a maximum and a minimum, so the nearest flanking assignments exist and index a subset-least member of the family -- hence over Z the extension machinery (lem:step, and through it \label{thm:extension}) never needs to invoke *Spherical*.

NOT SETTLED, and NOT discharged by the above: the *Spherical* AXIOM itself must still be proved for any concrete frame instance this task constructs. \label{def:frame} requires it of every frame, so a finite-WorldState-over-Z frame is not a frame until Spherical is discharged for it, regardless of the fact that the extension theorem over Z would not have used it. Do not let the Spherical-free step extension be mistaken for a discharge of the axiom.

UPGRADED FROM LEAD TO PAPER-STATED ARGUMENT (2026-08-10): the paper now uses exactly this finite-W argument in its own proof prose, verifying *Spherical* for a concrete finite-W frame, verbatim: "*Spherical* holds because W is finite, so a directed family of nonempty fibers and segments has finitely many distinct members and directedness yields a subset-least member equal to its nonempty intersection" (stated for the off-zero-universal discrete witness frame in the frame-properties appendix; the same conclusion is independently asserted in general form by the new cor:tm-completeness transfer footnote: Spherical "holds automatically whenever the constructed frame has finite W"). TRANSCRIBE this argument rather than re-deriving it from scratch; note it derives Spherical from finiteness plus directedness alone (member nonemptiness comes from Seriality where needed). CAUTION: the paper introduced that witness frame as a REPLACEMENT for a former two-state universal-relation witness that VIOLATES Limit; if the Lean tree transcribed the old witness anywhere, that is rebase surface. It remains a SEPARATE argument from the discrete-order one above and neither implies the other. Relatedly, the same transfer footnote records that Seriality comes free wherever Occurrence is already being checked -- relevant to this task's open Seriality-over-Z question below. Whether SERIALITY is also automatic over D = Z is likewise an OPEN question for this task's next research pass: it is plausible-automatic for a construction with no genuine dead ends, and likely true of the finite-WorldState-over-Z construction by design, but it has not been checked.

Directedness, for whichever route is taken, is \label{def:directed}: "A nonempty family of sets S is *directed* just in case S' subset-of S_1 intersect S_2 for some S' in S whenever S_1, S_2 in S." *Spherical* quantifies over directed families of nonempty fibers AND segments as two separate classes; segments are written [w, v]_x^y := Fib(w, x) intersect Fib(v, -y) for x, y >= 0. The lemma formerly cited for the two-sided segment family no longer exists in the paper -- cite lem:constraint and lem:step.

=== 4. WHAT SURVIVES, WHAT DOES NOT ===
SURVIVES: the "axiom is automatic over Z" result (section 2), verbatim under the renamed axiom; the overall FMP-over-a-fixed-carrier charter and its relation to the tableau programme.
SUPERSEDED by round 1: the framing "against the refactored Omega-free maximal-history semantics of task 414" -- the target predicate is totality, inherited transitively from 414's corrected charter, and this task's research was conducted against the wrong target, which is why its status was reset.
SUPERSEDED by round 2 (round-1 findings that no longer hold): round 1's weaker version of the Spherical lead for this task, which is replaced by the two-part settled/not-settled split in section 3; its quotes of def:world-history and the *Spherical* axiom; its "task-constrained function" vocabulary; and every parenthetical possible_worlds.tex:NNNN locator. Round 1 remains authoritative for everything round 2 did not touch, including the finite-W argument, since upgraded to paper-stated text (section 3).

=== 5. DEPENDENCIES AND NON-GOALS ===
Depends on tasks 414 (totality-based semantics), 420 (four-axiom TaskFrame plus the fiber/segment/directedness machinery), and 438. NON-GOAL: no edits under /home/benjamin/Philosophy/Papers/ -- the paper is read-only ground truth.

=== 6. FIRST STEP FOR THE NEXT DISPATCH (do this before reading any definition) ===
Run `bash scripts/check-paper-definitions.sh` and read specs/paper-definitions-of-record.md. That file -- not the paper -- is what specs in this repository cite: it pins every definition this cluster depends on (def:temporal-order, def:task-relation, def:directed, def:frame and each of its four axioms individually, lem:nullity, def:world-history, def:constraints, lem:constraint, lem:fibers, lem:admissible, lem:step, thm:extension, cor:occurrence, def:BL-model, def:BL-semantics, def:frame-validity, def:logical-consequence, and the CO / TMP-CO aitem anchors) with verbatim text and content hashes re-derived from the live paper on every run. Lint outcomes: case (a) silent pass and case (b) notice (paper changed but no recorded definition drifted) -- proceed; case (c) FAIL naming each drifted anchor -- STOP and re-issue the affected specs before consuming them. The md5/HEAD-baseline diff procedure this section formerly prescribed is RETIRED (its baselines were already three drift waves stale). Cite by \label (or \aitem key) only; a bare possible_worlds.tex:NNNN is never a citation. Quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search.

---

### 415. Completeness over total history semantics
- **Effort**: large
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 414, Task 420, Task 438, Task 439
- **Research**: [415_completeness_over_total_history_semantics/reports/02_total-history-internalization.md]
- **Plan**: [415_completeness_over_total_history_semantics/plans/02_total-history-completeness.md]

**Description**: RE-ISSUED 2026-08-10 (supersedes the prior maximal-history framing in full). COMPLETENESS OVER TOTAL-HISTORY SEMANTICS -- INTERNALIZED, NOT BRIDGED: restate and reprove WEAK completeness per frame class so the canonical/chronicle constructions deliver countermodels that are total-history models OUTRIGHT.

=== 1. THE COUNTERMODEL FAMILY (the corrected target) ===
The required countermodel family is the FULL TOTAL-history set H_F -- every possible world of the frame -- not a maximal-history set and not a distinguished sub-family. Paper anchor \label{def:world-history}, verbatim: "A *partial history* over a frame F = <W, D, =>> is a function tau : X -> W on a nonempty set X subset-of D where tau(x) =>_{y-x} tau(y) for all times x, y in X. ... A *world history* is any partial history whose domain X is *convex* ... A world history is *total* --- equivalently, a *possible world* --- just in case X = D. ... The set of all total world histories over F is denoted H_F." The layering is partial history, then world history (convex domain), then total. Note that a partial history requires a NONEMPTY domain and does NOT require convexity; the vocabulary "task-constrained function" is retired paper-wide and must not appear as current terminology.

Anchor \label{def:logical-consequence}, verbatim: "A conclusion phi is a *logical consequence* of a set of premises Gamma --- written Gamma |= phi --- just in case for all models M, possible worlds tau in H_F, and times x in D, if M,tau,x |= gamma for all premises gamma in Gamma, then M,tau,x |= phi." Anchor \label{def:BL-semantics} box clause, verbatim: "M,tau,x |= Box phi *iff* M,sigma,x |= phi for all sigma in H_F." The former singleton-Omega device (WeakCanonical/Transfer.lean) becomes: construct frames -- deterministic frames are the lead -- whose full total-history set IS the required countermodel family; no transfer or realization lemmas in the final statements. The mathematical content of realization is absorbed into the constructions; the headline theorems mention only the paper-aligned validity.

=== 2. PER-CLASS PROOF OBLIGATIONS UNDER THE FOUR-AXIOM FRAME ===
Every canonical/chronicle construction must now discharge FOUR axioms, not one. Paper anchor \label{def:frame}, verbatim: "A *frame* is any F = <W, D, =>> where W is a nonempty set of world states, D is a temporal order, and => is a task relation satisfying the following for x, y >= 0: *Compositionality:* w =>_{x + y} v if and only if w =>_x u and u =>_y v for some u in W. *Seriality:* w =>_x u and v =>_x w for some u, v in W. *Limit:* intersection over x > 0 of (w)_x = {w}. *Spherical:* intersection of S is nonempty for any directed family S of nonempty fibers and segments."

- BICONDITIONAL COMPOSITIONALITY is a NEW obligation for every construction that previously relied only on the one-directional inclusion. The interpolation direction (from w =>_{x+y} v produce a witness u with w =>_x u and u =>_y v) must be proved, not assumed. The Lean tree's current `forward_comp` states only the inclusion, and TaskFrame.lean's own docstrings still say the equality is not adopted -- both are stale against the paper and are task 420's to fix; this task must construct frames that satisfy the biconditional.
- SERIALITY: forward and backward fibers nonempty at every nonnegative duration.
- LIMIT: the axiom formerly called "Limit Nullity" in this task's superseded description is now simply named *Limit*; the mathematics is unchanged. Discrete class: automatic over Z via task 420's `limit_nullity_of_succOrder` helper (|y| < 1 forces y = 0). Dense, Dedekind, and Base canonical/chronicle constructions: a genuine per-class obligation -- verify the constructed task relation does not relate distinct states in arbitrarily small durations. A class whose canonical frame violates Limit needs a repaired construction, not a weakened axiom.
- SPHERICAL is the LEAST ROUTINE of the four and should be scheduled as such. It is not statable at all until fibers, segments, and directedness exist as Lean objects (task 420's territory). Paper anchors and notation, binding: \label{def:task-relation} gives Fiber: Fib(w, x) := {u in W : w =>_x u}; Cone: (w)_x := union over |y| < x of Fib(w, y) for x > 0; Segment: [w, v]_x^y := Fib(w, x) intersect Fib(v, -y) for x, y >= 0. \label{def:directed} gives "A nonempty family of sets S is *directed* just in case S' subset-of S_1 intersect S_2 for some S' in S whenever S_1, S_2 in S." *Spherical* quantifies over directed families of nonempty FIBERS AND SEGMENTS as two SEPARATE classes; the retired device by which one-sided fibers counted among the segments must not be reintroduced, and the paper's old `\Seg` macro is deleted from its preamble -- the bracket form [w, v]_x^y is the only current notation. CORRECTION (2026-08-10): the Spherical "calibration" footnote an earlier version of this description quoted here ("past and future constraints may tighten at different rates ... mismatched cofinalities ...") has been DELETED from the paper and must not be cited -- the only footnote remnant at def:frame's Spherical clause is a commented-out ball-spaces reference. The identity w =>_{x+y} v iff [w, v]_x^y is nonempty likewise no longer appears as paper text; it remains a one-line consequence of Compositionality plus def:task-relation's segment equation and is still likely the workhorse for discharging Spherical on a concrete construction, but it must now be DERIVED in Lean, not cited to the paper.

=== 3. WHY THESE AXIOMS ARE NOT OPTIONAL FOR A COUNTERMODEL ===
H_F must be NONEMPTY for a total-history countermodel to refute anything, and its nonemptiness is a theorem, not a stipulation: \label{def:constraints} defines the constraints imposed on any new time z (the segments [tau(t), tau(s)]_{z-t}^{s-z} when assignments flank z, the fibers Fib(tau(t), z - t) otherwise); \label{lem:constraint} (Constraint Lemma) shows they form a directed family of nonempty sets; \label{lem:fibers} and \label{lem:admissible} characterize when a one-point extension is a partial history; \label{lem:step} (Step Lemma) applies *Spherical* to the family and closes via lem:admissible to extend any partial history by one further duration; \label{thm:extension} then runs Zorn over partial histories and closes via lem:step; \label{cor:occurrence} follows (a MERGED anchor -- the former thm:occurrence and app:nonempty no longer exist; the merged statement is strictly stronger, giving tau(x) = w at any prescribed time x, and its proof extends {<x, w>} directly with no translation argument). A construction that satisfies only some of the axioms does not merely fail conformance -- it may have an empty or degenerate H_F and prove nothing. (The lemma formerly cited for the two-sided segment family no longer exists in the paper; cite lem:constraint and lem:step instead.)

=== 4. WHAT SURVIVES FROM PRIOR RESEARCH, AND WHAT DOES NOT ===
SURVIVES (round-1 findings, untouched by the round-2 audit):
- The staging plan Discrete -> Dense -> Base -> Dedekind, and the decision to internalize realization into the constructions rather than bridge. This is a proof-architecture decision independent of the target predicate. Discrete is currently green under the old semantics; Dense, Base, and Dedekind targets all rebase onto the new semantics.
- The identification of the deterministic lead frame `bundleFlowFrame` (WorldState := FamIdx x D) as the right countermodel engine. It is plausibly closer to a totality-native countermodel than a maximality-native one -- the "total-domain flow line" reasoning already underlies `multiFamHistory` / `isMax_of_total` -- so treat the deterministic lead-frame strategy as FAVORABLE for totality, not merely tolerant of it. This is a plausibility judgment to confirm, not a proven result.
- The obligation already anticipated in this task's prior description (that constructions must discharge more than Compositionality) is correctly anticipated content: kept and strengthened, not discarded.

SUPERSEDED, and by which round:
- Superseded by round 1: "completeness over Omega-free, maximal-history semantics" as the target, inherited transitively from task 414; "the FULL maximal-history set is the required countermodel family"; the under-scoping of the new obligation to one axiom alone; the axiom name "Limit Nullity".
- Superseded by round 2 (round-1 findings that no longer hold): round 1's quotes of def:world-history, thm:extension, and the *Spherical* axiom; its citation of the now-deleted segment lemma; its function-application segment notation; its "task-constrained function" vocabulary; and every parenthetical possible_worlds.tex:NNNN locator it carried. Round 1 remains authoritative for everything round 2 did not touch, including the entire SURVIVES list above.

=== 4b. NEW PAPER CONTENT DIRECTLY RELEVANT TO THIS TASK (added 2026-08-10) ===
(i) THE STRAND-CONSTRUCTION FOOTNOTE. cor:tm-completeness's proof now carries a footnote (source-tagged 'task 52 total-histories: optional S43 hedge') stating: the machine-checked completeness results in this repository are for "a parametric variant of the semantics in which validity is relativized to a designated shift-closed set of histories"; their transfer to the paper's total-history semantics "proceeds by a strand construction covering BL and BL+ only, and is not itself machine-checked"; and the transfer must verify the biconditional Compositionality, Seriality, and Spherical axioms of def:frame for the strand-delivered frames, whereupon Occurrence follows by cor:occurrence -- with Seriality free wherever Occurrence was already being checked, Spherical automatic for finite-W frames, and infinite W a genuine obligation external to the paper. CHARTER CONSEQUENCE: this task's 'internalized, not bridged' decision STANDS -- internalization strictly dominates, since landing it makes the footnote's hedge obsolete paper-side (updating the paper is the user's follow-on, not this task's). But treat the footnote's obligation list as the paper's own acceptance checklist for whatever constructions this task rebuilds.
(ii) WORKED FOUR-AXIOM VERIFICATIONS NOW IN THE PAPER. The paper's proof prose now verifies all four def:frame axioms for two concrete frames: the translation-flow frame (W = D with w =>_d u iff u = w + d for d >= 0 -- both Compositionality directions via the unique intermediate u = w + x, Seriality via singleton forward/backward fibers, Limit via (w)_d = {u : |u - w| < d}, Spherical because every fiber and every nonempty segment is a singleton) and an off-zero-universal discrete frame (finite W; Spherical because a directed family of nonempty fibers and segments over finite W has finitely many distinct members and directedness yields a subset-least member equal to its nonempty intersection). These CORROBORATE the deterministic-lead-frame judgment in section 4's SURVIVES list (previously 'a plausibility judgment to confirm' -- now paper-corroborated) and supply reusable discharge patterns. CAUTION: the paper REPLACED its former two-state universal-relation witnesses precisely because they VIOLATE Limit; if the Lean tree ever transcribed those old witnesses (frame-property proofs, countermodels), that is rebase surface -- audit for it.

=== 5. DEPENDENCIES AND NON-GOALS ===
Depends on tasks 414 (the totality-based semantics API), 420 (the four-axiom TaskFrame and the fiber/segment/directedness machinery Spherical is stated with), and 438. Task 420's own phase 6 still phase-waits on this task's `bundleFlowFrame`, even though the task-level 420 -> 415 dependency edge was dropped to break a cycle -- coordinate directly rather than relying on the edge list. Order: Discrete, then Dense (task 170), Base (task 169), Dedekind (task 408). NON-GOAL: no edits under /home/benjamin/Philosophy/Papers/ -- the paper is read-only ground truth. NON-GOAL: do not weaken a frame axiom to make a construction go through.

=== 6. FIRST STEP FOR THE NEXT DISPATCH (do this before reading any definition) ===
Run `bash scripts/check-paper-definitions.sh` and read specs/paper-definitions-of-record.md. That file -- not the paper -- is what specs in this repository cite: it pins every definition this cluster depends on (def:temporal-order, def:task-relation, def:directed, def:frame and each of its four axioms individually, lem:nullity, def:world-history, def:constraints, lem:constraint, lem:fibers, lem:admissible, lem:step, thm:extension, cor:occurrence, def:BL-model, def:BL-semantics, def:frame-validity, def:logical-consequence, and the CO / TMP-CO aitem anchors) with verbatim text and content hashes re-derived from the live paper on every run. Lint outcomes: case (a) silent pass and case (b) notice (paper changed but no recorded definition drifted) -- proceed; case (c) FAIL naming each drifted anchor -- STOP and re-issue the affected specs before consuming them. The md5/HEAD-baseline diff procedure this section formerly prescribed is RETIRED (its baselines were already three drift waves stale). Cite by \label (or \aitem key) only; a bare possible_worlds.tex:NNNN is never a citation. Quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search.

---

### 414. Refactor semantics to total history validity
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 420, Task 438, Task 439
- **Research**: [414_refactor_semantics_to_total_history_validity/reports/05_seriality-witness-nontermination.md]
- **Plan**: [414_refactor_semantics_to_total_history_validity/plans/04_seriality-witness-termination-fix.md]
- **Summary**: [414_refactor_semantics_to_total_history_validity/summaries/09_phase29-2-preguard-differential-rebaseline.md]

**Description**: === 0. EXECUTION STATUS (updated 2026-08-11; supersedes the sections named below) ===
18 of 23 plan phases are COMPLETE, `lake build` is GREEN, 0 sorries were introduced (1
pre-existing, Metalogic/WeakCanonical/Transfer.lean:1084, out of scope), 0 new axioms. Plan of
record: plans/03_omega-free-totality-refactor.md, whose "## Execution Status" section carries the
per-phase detail, the two lessons governing the remainder, and the four file-list corrections.
REMAINING: phases 19-22 (the Omega-binder sweeps) and phase 23 (OPTIONAL frame-relative validity).

The paper anchors, verbatim definitions, and NOTATION rules in sections 1-10 below remain ground
truth and are unchanged. What follows records only which OPEN QUESTIONS and PENDING OBLIGATIONS
have since been settled, so the charter stops posing as open work that is already done.

SETTLED -- section 7 (CROSS-TASK ACCEPTANCE CRITERION), the most consequential: **DISCHARGED.**
*Spherical* is verified as literally the hypothesis lem:step's proof consumes, by two independent
checks -- a deletion probe (removing the `hSph` binder makes the proof fail to elaborate with
`Unknown identifier`) and proof-term inspection (`#print` shows it applied as a function head).
`Extension/Step.lean` is its SOLE application site repo-wide; every other occurrence is docstring
prose. Phase 10 re-verified the invariant survived thm:extension, which forwards the axiom binders
without applying them. The obligation "this task is not done until that threading is demonstrated"
is met. One item task 420 must absorb: `step` carries an extra `hLim` binder (Limit in hypothesis
form), because TaskFrame does not carry Limit as a field and lem:admissible needs lem:nullity at
z; it discharges by the same mechanical substitution as the others when 420's frame-axiom-field
phase lands.

SETTLED -- section 3 (THE HISTORY-STRUCTURE GAP): the layering decision was made ONCE, at plan
time, and is landed. `PartialHistory` (nonempty domain, respects_task, no convexity) exists with
`WorldHistory` re-based onto it, plus the extension order and the Zorn machinery, in
FormalSystem/Semantics/PartialHistory*.lean and Semantics/Extension/. The paper's decomposition
(def:constraints -> lem:constraint -> lem:fibers -> lem:admissible -> lem:step -> thm:extension ->
cor:occurrence) is transcribed lemma-for-lemma and is sorry-free. Frame-intrinsic cor:occurrence
was deliberately NOT attempted and remains gated on task 420's frame-axiom-field phase, as scoped.

SETTLED -- section 2 (THE ACTUAL BINDER DELTA): applied. TruthAt's box clause now reads
`forall (sigma : WorldHistory F), sigma.IsTotal -> ...`, matching def:BL-semantics with no Omega
and no shift-closure side condition; the target predicate is TOTALITY, never IsMax. The validity
layer's binder delta landed across twelve definitions. `ShiftClosed` was DELETED from
time_shift_preserves_truth rather than replaced -- the statement got strictly stronger while
losing a hypothesis, confirming the charter's "strictly easier" prediction. untl/snce remain
EVENT-FIRST; the paper footnote's contradictory guard-first reading was NOT adopted.

SETTLED -- the three-way delete-vs-generalize question for Omega (section 5 / report 7.5): all
five Omega-valued definitions are now provably = H_F, so no split-scope spawn was needed. The
completeness side was largely the predicted rewrite; the decidability side required the real work
the charter anticipated -- regionFrame was re-hosted onto a deterministic clock carrier
(WorldState := W x D) IN THIS TASK, and its consumers repaired, closing the junk-history problem
that totality alone does not fix. Note two corrections to prior research discovered en route:
(a) "rewrite, not re-proof" held only for the two FlowFrame definitions; multiFamTaskFrame and
zTaskFrameV2 are independent defs with no totality characterization to rewrite along, so two new
proofs were required; (b) `regionConstant_regionHistory_zero` became FALSE, not merely unproved,
under the deterministic carrier, and was replaced by `not_regionConstant_regionHistory`.

CORRECTION to section 5's SURVIVES list: it states, on round-3 authority, that the extension-order
machinery (Preorder, chainSup, exists_maximal_extension, isMax_of_total, timeShift_mono) "exists
ONLY as a prototype inside report 01 and is NOT in the tree". That was true when written and is
now STALE -- the order-machinery phase ported it, and it is in the tree. The rest of the SURVIVES
list stands, including the soundness-survival analysis, which the ShiftClosed deletion above
confirms a fortiori. The Group C 88/16/8 counts remain unverified against the current tree; still
never present them as freshly derived.

STILL OPEN -- section 8 (OPTIONAL DELIVERABLE): frame-relative validity |=_F has no Lean
counterpart yet. It is the plan's final phase and remains explicitly OPTIONAL.

STILL BINDING -- section 10 (FIRST STEP FOR THE NEXT DISPATCH): unchanged. Run
`bash scripts/check-paper-definitions.sh` and read specs/paper-definitions-of-record.md before
consuming any definition. It passed silently at the start of the 2026-08-11 run.RE-ISSUED 2026-08-10 (supersedes the prior maximal-history charter in full). TOTAL-HISTORY VALIDITY REFACTOR: make totality-based validity THE validity of the repo, eliminating the Omega parameter from the semantics core.

=== 1. THE TARGET PREDICATE (the single most consequential correction) ===
The target predicate for TruthAt's box clause, valid, SemanticConsequence, the satisfiable family, and H_F generally is TOTALITY -- in Lean, `IsTotal (tau) := forall t, tau.domain t` -- NOT Mathlib's `IsMax` and not any order-theoretic maximality predicate. The paper's own layering is partial history, then world history, then total (equivalently: possible world). Paper anchor \label{def:world-history}, verbatim: "A *partial history* over a frame F = <W, D, =>> is a function tau : X -> W on a nonempty set X subset-of D where tau(x) =>_{y-x} tau(y) for all times x, y in X. ... A *world history* is any partial history whose domain X is *convex*, so that y in X whenever x, z in X and x < y < z. A world history is *total* --- equivalently, a *possible world* --- just in case X = D. A partial history sigma *extends* tau just in case dom(tau) subset-of dom(sigma) and tau(x) = sigma(x) for all x in dom(tau). The set of all total world histories over F is denoted H_F."

Note carefully: a partial history has NO convexity requirement and DOES require a nonempty domain; convexity is what promotes a partial history to a world history. The vocabulary "task-constrained function" is RETIRED throughout the paper (the extension theorem, the occurrence result -- now cor:occurrence -- and the gluing footnote were all recast); do not reintroduce it as current terminology.

Consequence anchor \label{def:logical-consequence}, verbatim: "A conclusion phi is a *logical consequence* of a set of premises Gamma --- written Gamma |= phi --- just in case for all models M, possible worlds tau in H_F, and times x in D, if M,tau,x |= gamma for all premises gamma in Gamma, then M,tau,x |= phi. A sentence phi is *valid* just in case |= phi."

Truth anchor \label{def:BL-semantics}: preamble "Truth in a model at a possible world tau in H_F and time is defined recursively"; atom clause "M,tau,x |= p_i *iff* tau(x) in |p_i|" (NO domain conjunct); box clause "M,tau,x |= Box phi *iff* M,sigma,x |= phi for all sigma in H_F"; tense clauses range over all y in D.

=== 2. THE ACTUAL BINDER DELTA (corrected -- do not overstate it) ===
`valid` (FormalSystem/Semantics/Validity.lean:80) and `SemanticConsequence` (:104) ALREADY carry `[Nontrivial D]`. The genuine binder gap is only at the `TaskFrame` STRUCTURE level: no `[Nontrivial D]` binder and no `Nonempty WorldState` field. At the consequence level the delta is exactly two moves: (i) drop `Omega` / `ShiftClosed` / the `tau in Omega` hypothesis, and (ii) add the totality constraint on tau. Earlier research presented `[Nontrivial D]` as new at every level; that presentation is superseded -- state the smaller delta. `ShiftClosed` becomes unnecessary in the STATEMENT of validity/consequence because totality is trivially preserved by `timeShift`. Whether the Omega machinery is deleted outright or retained as a generalization that `valid` specializes is 415-coupled and remains a planning decision. NOTE (new paper content, 2026-08-10): the paper itself now NAMES the repo's current Omega architecture -- a footnote inside cor:tm-completeness's proof describes the machine-checked results as stated for "a parametric variant of the semantics in which validity is relativized to a designated shift-closed set of histories", transferred by a non-machine-checked strand construction; landing this task (with 415) is what makes that hedge obsolete. See task 415's description for the footnote's full obligation list.

Also in scope for the binder rewrite: Lean's `Formula` takes Until/Since (`untl` / `snce`) as PRIMITIVE with G/H/F/P derived -- mirroring the paper's extended \label{def:BLplus-semantics} rather than \label{def:BL-semantics}, which has primitive Past/Future only. The totality refactor must rewrite the `untl` / `snce` clauses' binders too; they are tau-local and unchanged in shape, but they sit inside TruthAt's binder list.

=== 3. THE HISTORY-STRUCTURE GAP (corrected earlier error; joint scope with 420) ===
Lean's `WorldHistory` (FormalSystem/Semantics/WorldHistory.lean) has `domain : D -> Prop` with NO nonemptiness field. The empty history is therefore a legal Lean `WorldHistory` but is not a world history in the paper. Earlier research scored the base definition a "match"; it is a match on four of five conjuncts. Impact on the consequence chain is nil (total histories have domain D, nonempty because a nontrivial ordered group is infinite), but it is real for \label{thm:extension} fidelity, whose hypothesis is a NONEMPTY partial history: a faithful transcription must either carry the nonemptiness field/hypothesis or make an explicit empty-case argument the paper does not make.

Decide the layering ONCE, before the consequence refactor, not after: introduce `PartialHistory` (nonempty domain, respects_task, no convexity) with `WorldHistory` as the convex special case -- whether by `extends`, an `IsConvex` mixin, or adding a nonemptiness field to the existing standalone structure is an implementation-plan choice. Add `PartialHistory.Extends` (domain inclusion + agreement) as the extension order. `H_F` as a subtype (`{tau : WorldHistory F // tau.IsTotal}`) versus a witness pair remains an open planning decision. This decision is shared with task 420 and must not be made twice.

=== 4. THE FOUR-AXIOM FRAME AND THE MACHINERY H_F DEPENDS ON ===
Paper anchor \label{def:frame}, verbatim: "A *frame* is any F = <W, D, =>> where W is a nonempty set of world states, D is a temporal order, and => is a task relation satisfying the following for x, y >= 0: *Compositionality:* w =>_{x + y} v if and only if w =>_x u and u =>_y v for some u in W. *Seriality:* w =>_x u and v =>_x w for some u, v in W. *Limit:* intersection over x > 0 of (w)_x = {w}. *Spherical:* intersection of S is nonempty for any directed family S of nonempty fibers and segments."

Supporting anchors, each with the text that makes the label recoverable if it is renamed:
- \label{def:temporal-order}: "A *temporal order* is a nontrivial totally ordered abelian group D = <D, +, 0, <=> with *positive cone* D^+ := {x in D : x >= 0}."
- \label{def:task-relation}: a task relation on a NONEMPTY set of world states W over a temporal order D, extended to negative durations by the *converse convention* "w =>_{-x} u := u =>_x w for x >= 0", determining -- Fiber: Fib(w, x) := {u in W : w =>_x u}; Cone: (w)_x := union over |y| < x of Fib(w, y) where x > 0; Segment: [w, v]_x^y := Fib(w, x) intersect Fib(v, -y) where x, y >= 0.
- \label{def:directed}: "A nonempty family of sets S is *directed* just in case S' subset-of S_1 intersect S_2 for some S' in S whenever S_1, S_2 in S."
- \label{lem:nullity}: "w =>_0 w for every world state w in W in every frame" -- Nullity is DERIVED (from Seriality at x = 0 plus Limit), choice-free, not an axiom.
- \label{def:constraints} (promoted from lead-in prose to a numbered Ddef): for a partial history tau : X -> W over a frame F and duration z in D \ X, the *constraints imposed on z* are the segments [tau(t), tau(s)]_{z-t}^{s-z} for times t, s in X where t < z < s, and the fibers Fib(tau(t), z - t) for t in X otherwise.
- \label{lem:constraint} (Constraint Lemma): the constraints imposed on z form a directed family of nonempty sets. RESTRUCTURED: this lemma now states ONLY directedness plus nonemptiness -- the admissibility clause its earlier merged statement carried has been split out into lem:admissible below. Its proof consumes Compositionality in BOTH directions plus Seriality.
- \label{lem:fibers} (NEW): a world state u belongs to every member of the constraints imposed on z just in case tau(t) =>_{z-t} u for every t in X.
- \label{lem:admissible}: the function tau union {<z, u>} is a partial history on X union {z} just in case u belongs to every member of the constraints imposed on z. Proof = lem:nullity (the zero loop at z itself) + lem:fibers.
- \label{lem:step} (Step Lemma): "Every partial history tau : X -> W over a frame F extends to a partial history on X union {z} for any duration z in D." Proof = lem:constraint + *Spherical* (its SOLE application site) + lem:admissible. Closing remark, verbatim: "When the family has a subset-least member, that member already contains a candidate and *Spherical* is not needed."
- \label{thm:extension}: "Every partial history tau : X -> W over a frame F is extended by some total world history sigma in H_F." Proof = Zorn over partial histories ordered by extension, closed via lem:step. Nothing else.
- \label{cor:occurrence} (MERGED anchor -- the former \label{thm:occurrence} and \label{app:nonempty} NO LONGER EXIST): "For any frame F = <W, D, =>>, world state w in W, and time x in D, there is a total world history tau in H_F where tau(x) = w, and so H_F is nonempty." Strictly stronger than the old pair (the time x is universally given, not merely witnessed); its proof extends the one-point partial history {<x, w>} directly via thm:extension -- the old translation argument is GONE from this chain.

NOTATION IS BINDING: segments are written in the bracket form [w, v]_x^y with the defining equation [w, v]_x^y := Fib(w, x) intersect Fib(v, -y) for x, y >= 0. The paper's old `\Seg` macro is DELETED from its preamble and survives only inside commented-out lines; the old function-application segment notation is not current notation and must not appear as such. *Spherical* ranges over directed families of nonempty FIBERS AND SEGMENTS as two SEPARATE classes -- the device by which one-sided fibers used to count among the segments is RETIRED, and directedness is now its own definition per \label{def:directed}. The lemma formerly cited for the two-sided segment family no longer exists in the paper; every such citation is replaced by lem:constraint + lem:step.

=== 5. WHAT SURVIVES FROM PRIOR RESEARCH, AND WHAT DOES NOT ===
SURVIVES (still authoritative, from the round-1 team research):
- The extension `Preorder` on histories (tau <= sigma iff domain inclusion plus state agreement on the smaller domain), `timeShift_mono`, the shift/unshift lemma pair, and `chainSup` (chain-union) -- predicate-agnostic, axiom-content-free order machinery.
- `exists_maximal_extension` (Zorn) -- still true and useful, but demoted from "the target existence theorem" to an internal lemma en route to thm:extension.
- `isMax_of_total` (total implies maximal under the extension order) -- survives and becomes the load-bearing direction: it is exactly what lets a totality-based H_F sit inside the maximal-extension machinery.
- The soundness-survival analysis: soundness consumes shift-preservation, not Zorn extension. A totality-based `time_shift_preserves_truth` is strictly EASIER than the maximality-based one already verified, so this survives a fortiori.
- The Group C dead/live/portable bucketing (88 dead + 16 live-portable + 8 live-unportable). CARRY BOTH HALVES: the bucketing is a kernel-level reachability fact orthogonal to the predicate choice and survives; the COUNTS were verified only as an internally-consistent transcription of the source report and were NOT re-derived against the current tree, and that report predates task 415's landing, so the cardinalities may have drifted. Never present these counts as freshly derived.

SUPERSEDED, and by which round:
- Superseded by round 1 (the team research): the "make maximal-history validity THE validity of the repo" charter; the target Lean signatures using `IsMax` binders in TruthAt's box clause, valid, SemanticConsequence, and satisfiable; the `IsMax`-versus-alias naming discussion (moot -- whichever name is chosen must denote totality); this task's former "charter is mathematically unaffected" framing.
- Superseded by round 2 (the discrepancy audit), i.e. round 1's own findings that no longer hold: round 1's quotes of def:world-history, thm:extension, and the *Spherical* axiom; its citation of the now-deleted segment lemma; its function-application segment notation; its "task-constrained function" vocabulary; its "match" verdict on the base `WorldHistory` definition (see section 3); its presentation of `[Nontrivial D]` as new at every level (see section 2); and every parenthetical `possible_worlds.tex:NNNN` locator it carried. Round 1 remains authoritative for everything round 2 did not touch, including the whole SURVIVES list above.
- Still standing from round 1, explicitly: satisfiability has NO paper anchor -- Lean's satisfiable family inherits the totality fix as a design decision, not as a reconciliation finding.

=== 6. TRANSCRIPTION-COST UPDATE (round 2, Findings 3) ===
thm:extension is CHEAPER than round 1 estimated, because the paper now supplies the lemma decomposition (def:constraints -> lem:constraint -> lem:fibers -> lem:admissible -> lem:step -> Zorn wrapper) that round 1 said the Lean side would have to invent. Mirror it lemma-for-lemma per the literature-fidelity policy. The Zorn engine from this task's own prototype retargets to `PartialHistory`, with the final "maximal implies total" step going through lem:step -- which resolves cleanly what round 1 could only describe as "maximal-to-total requires Seriality and Spherical". All four def:frame axioms remain load-bearing for thm:extension and hence for H_F's nonemptiness: lem:constraint consumes Compositionality in BOTH directions plus Seriality; lem:admissible consumes lem:nullity (which rests on Seriality-at-0 plus Limit) via lem:fibers; and lem:step consumes lem:constraint plus Spherical plus lem:admissible.

=== 7. CROSS-TASK ACCEPTANCE CRITERION (shared with task 420) ===
*Spherical*'s Lean statement must be literally the hypothesis that lem:step's proof consumes -- NOT an inert structure field, and no longer pointed at thm:extension's proof, which under the current architecture consumes only Zorn plus lem:step. If 420 lands Spherical as an inert field while this task rebuilds totality machinery without threading it through, both tasks can go green while jointly failing to reconstruct thm:extension. This task is not done until that threading is demonstrated.

=== 8. OPTIONAL DELIVERABLE (not required scope) ===
Frame-relative validity: \label{def:frame-validity}'s |=_F has no Lean counterpart at all. It is the natural home for cor:occurrence's never-vacuous theorem -- the paper states "Since H_F is nonempty for every frame by cor:occurrence, frame validity is never vacuous: every frame contributes evaluation points, and so not-|=_F bottom for every frame F." (Anchor updated: the former app:nonempty was merged into cor:occurrence.) Mark OPTIONAL.

=== 9. DEPENDENCIES, NON-GOALS, NOTATION ===
Depends on task 420 (the four-axiom TaskFrame must land first so the validity refactor lands once, against the final frame structure) and on task 438. Downstream metalogic rebasing is task 415; 417 restates against this semantics; 427 syncs the typst book last. NO compatibility shims, aliases, or parallel validity notions: one uniform Omega-free API. NON-GOAL: no edits under /home/benjamin/Philosophy/Papers/ -- the paper is read-only ground truth.

NOTATION (binding user decision, 2026-07-28, carried forward unchanged): any explicit converse operation on the task relation is written with a superscript inverse -- $\Rightarrow^{-1}$ (and $R^{-1}$ for abstract relations) -- NEVER the relation-algebra breve/smile ($\breve{R}$, $R^{\smallsmile}$) common in the arrow-logic literature. Prefer inv / ^-1 vocabulary in Lean declaration names, consistent with Mathlib's `Inv`. The paper itself states the converse convention with subscript negation only and introduces no operator symbol.

=== 10. FIRST STEP FOR THE NEXT DISPATCH (do this before reading any definition) ===
Run `bash scripts/check-paper-definitions.sh` and read specs/paper-definitions-of-record.md. That file -- not the paper -- is what specs in this repository cite: it pins every definition this cluster depends on (def:temporal-order, def:task-relation, def:directed, def:frame and each of its four axioms individually, lem:nullity, def:world-history, def:constraints, lem:constraint, lem:fibers, lem:admissible, lem:step, thm:extension, cor:occurrence, def:BL-model, def:BL-semantics, def:frame-validity, def:logical-consequence, and the CO / TMP-CO aitem anchors) with verbatim text and content hashes re-derived from the live paper on every run. Lint outcomes: case (a) silent pass and case (b) notice (paper changed but no recorded definition drifted) -- proceed; case (c) FAIL naming each drifted anchor -- STOP and re-issue the affected specs before consuming them. The md5/HEAD-baseline diff procedure this section formerly prescribed is RETIRED (its baselines were already three drift waves stale). Cite by \label (or \aitem key) only; a bare possible_worlds.tex:NNNN is never a citation. Quote definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text search.

---

### 413. Formalize tm conservativity bridge
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 439

**Description**: Formalize the TM+ over TM conservativity bridge in Lean 4 (paper thm:ConservativeExtension, CEB/CEF/CED/CEC): add a BL base-language Formula type with primitive box/G/H, its TM axiom set and derivation trees, a translation into the existing BL+ Formula type, and prove that TM+ derivability of a translated BL-formula yields TM derivability, supplying the missing step in the paper's cor:tm-completeness route

ANCHORS RE-VERIFIED 2026-08-10: \label{thm:ConservativeExtension} [Conservative Extension] and \label{cor:tm-completeness} [Completeness] both resolve in the current paper. Cite by \label only, never bare line numbers; before consuming any semantic definition, run `bash scripts/check-paper-definitions.sh` and cite specs/paper-definitions-of-record.md rather than the paper directly.

NEW PAPER CONTENT THIS TASK MUST KNOW (2026-08-10): cor:tm-completeness's proof now carries a footnote (source-tagged 'task 52 total-histories: optional S43 hedge') stating that the machine-checked completeness results in THIS repository are for "a parametric variant of the semantics in which validity is relativized to a designated shift-closed set of histories"; that their transfer to the paper's total-history semantics "proceeds by a strand construction covering BL and BL+ only, and is not itself machine-checked"; and that the transfer must verify the biconditional Compositionality, Seriality, and Spherical axioms of def:frame for the strand-delivered frames (Occurrence then follows by cor:occurrence; Seriality is free wherever Occurrence was already checked; Spherical is automatic for finite W; infinite W is a genuine obligation external to the paper). This footnote sits in exactly the proof this task formalizes. The conservativity bridge itself is PROOF-THEORETIC (translation plus derivability) and therefore does not depend on the semantics refactor -- this task does NOT need tasks 414/415 to land first -- but phrase its Lean statements so they compose with the totality-based validity once 414/415 land, and coordinate naming with the paper-refactor cluster, whose completeness route (task 415) this bridge feeds.

---

### 412. Prove refutation core and decidability of provability with completeness corollaries
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: Task 165, Task 410, Task 411, Task 428, Task 430

**Description**: Track B finish for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.1, 8.3, 8.5). Create Verified/Refutation/Core.lean proving allClosed_derivable as ONE induction over allRulesForFC fc, discharging each rule by its admissibility lemma (predecessor tasks) and its ruleFrameClass r <= fc hypothesis via the RuleSpec GATE lemmas — Dense/Discrete/Dedekind instantiate the generic theorem, they do not re-prove it. Then Verified/Provable.lean: Decidable (Derivable fc [] phi) combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen; the completeness corollaries ValidFor fc phi -> Derivable fc [] phi; discharge the pre-existing sorry countermodel_discrete at FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242; and supply the Dedekind engine consumed by completeness_dedekind_of_engine (StrongCompleteness.lean:308, target ValidDedekindDense). Acceptance: zero sorries repo-wide outside Boneyard; lake build green; update typst/latex decidability chapters to record headline result 2.
RE-SCOPING ADDENDUM (2026-07-29, supersedes the buildTableau_isSome reference above): the scope text above depends on "Track A's buildTableau_isSome", which task 165 proved FALSE and placed on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine signature, not a proof difficulty: buildTableau returns none whenever a formula explores more than maxBranches := 50000, at ANY fuel. Consequently this task's acceptance criterion "zero sorries repo-wide outside Boneyard" was UNREACHABLE AS SCOPED, independently of task 165's own status.

CORRECTED DEPENDENCE: consume the budget-parameterised totality theorem from task 428 (engine_totality_at_a_quantified_branch_budget) -- shape `buildTableau_isSome_of_budget phi fc maxBranches (hmb : <bound in phi> <= maxBranches)` -- in place of the unconditional buildTableau_isSome. Task 428 has been added as a predecessor. Do NOT attempt the unconditional form yourself.

ALSO NOTE: this task inherits obstructions O2 and O3 (the boxAnchoredCheck and temporalWitnessCheck truth-lemma side conditions) from Phase 7.3 of task 165 by way of not_valid_of_hasOpen. Those are owned by task 429. If your induction reaches a point where a truth-lemma gate hypothesis must be discharged on real engine output, that is 429's work, not this task's -- record it and coordinate rather than re-deriving it. Grounding for all of this: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

---

### 411. Prove hard admissibility lemmas for until since trichotomy discrete and dedekind rules
- **Effort**: 15-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: Task 165, Task 410

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Dependencies**: Task 165, Task 429
- **Research**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/reports/01_internalize-routine-admissibility.md]
- **Plan**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md]

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 362. Completeness capstone consequence all classes strong where compact
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 375, Task 169, Task 170

**Description**: Implement the completeness capstone under the SETTLED TERMINOLOGY (2026-07-27): "strong completeness" is reserved for consequence from possibly-infinite premise sets (Γ : Set Formula) with finitary set-derivability; finite-context (Context = List Formula) consequence statements are inter-derivable with weak completeness via the deduction theorem and are named CONSEQUENCE completeness, never strong. (This task was formerly "main_strong_completeness: finite-context strong completeness" — that framing was misleading and is retired.)

SCOPE:
(A) Finite-context CONSEQUENCE completeness for all four frame classes. For each X ∈ {Base, Dense, Discrete}: define SemanticConsequenceX (Γ : Context) (paralleling the ValidX binder list), prove the semantic deduction lemma, and prove consequence_completeness_X : SemanticConsequenceX Γ φ → Derivable FrameClass.X Γ φ via (a) the semantic deduction lemma, (b) the class's weak completeness engine, (c) the fc-generic derivable_foldr_imp_iff. The Dedekind instance and all the generic lemmas (truthAt_foldr_imp, derivable_of_derivable_foldr_imp, derivable_foldr_imp_of_derivable, derivable_foldr_imp_iff) ALREADY EXIST in FormalSystem/Metalogic/StrongCompleteness.lean (landed by task 408 phase 2, reframed 2026-07-27) — follow its three-declaration shape and drop the Base/Dense/Discrete instances into that file's reserved sections. Weak completeness for each class stays re-exposed as the Γ=[] corollary (exactly one proof of the weak form per class, as a corollary). State conclusions as `Derivable` (definitionally Nonempty (DerivationTree ...), ProofSystem/Derivable.lean:69), matching the existing weak termini.
(B) GENUINE strong completeness (Γ : Set Formula with finitary set-derivability) for Base and Dense ONLY, conditional on task 361's feasibility verdict and gated on the set-based model-existence theorem it scopes (every SetConsistent set satisfiable in a class frame). If 361 returns a non-compactness verdict for Base or Dense, record the counterexample and downgrade that leg to consequence-only, matching Discrete/Dedekind.
(C) Discrete and Dedekind get NO strong form — both provably non-compact (Discrete: the {F p} ∪ {¬Xⁿ p : n} witness under IsSuccArchimedean, since next = untl φ bot is definable; Dedekind: Reynolds 1992 Thm 7 weak-only, restriction genuine). The StrongCompleteness.lean section headers already document this; optionally land the formalized Discrete non-compactness witness if 361 scoped it.
(D) LaTeX alignment: restate latex/subfiles/04-Metalogic.tex so "Strong Completeness" (main_strong_completeness, :266; identifier also at :211, :490) is used ONLY for the Set Formula statement (stated for Base/Dense if reachable, with the non-compactness of Discrete/Dedekind recorded), presenting the finite-context result as consequence completeness derived from weak completeness; resolve that file's "Note on Infinite Contexts" TODO accordingly.

VERIFIED ANCHORS (re-checked 2026-07-27):
  - FormalSystem/Metalogic/BXCanonical/Completeness.lean:196 `completeness`; :255 `completeness_dense`; :296 `completeness_discrete` (base validity predicate is lowercase `valid`; dense/discrete are ValidDense/ValidDiscrete — Semantics/Validity.lean:79, :169, :187).
  - FormalSystem/Metalogic/StrongCompleteness.lean — module docstring carries the per-class programme and reserved sections; Dedekind instance complete modulo its engine (consequence_completeness_dedekind_of_engine, completeness_dedekind_of_engine).
  - Syntactic deduction theorem: FormalSystem.ProofSystem.Derivable.deduction (Metalogic/Core/DeductionTheorem.lean:467, Prop-level), data-level deductionTheorem at :325, deductionConverse at :447.
  - Set-based MCS layer (for leg B): SetConsistent/SetMaximalConsistent/set_lindenbaum, Metalogic/Core/MaximalConsistent.lean:96/:103/:303. SetConsistent is already finitary (every finite sublist consistent).
  - Frame-class-agnostic SemanticConsequence (Γ : Context) exists at Semantics/Validity.lean:103 with notation Γ ⊨ φ at :114 — it quantifies over ALL carriers and is NOT the per-class relation; per-class variants named in UpperCamel (Prop-valued definitions), theorem names snake_case.
  - Update the tracking table in FormalSystem/Metalogic.lean (the file at the FormalSystem/ root, NOT FormalSystem/Metalogic/Metalogic.lean, which does not exist).

Axioms exactly [propext, Classical.choice, Quot.sound] modulo whatever the underlying weak terminus already carries; leg A sorry-free once the three weak termini are green.

DEPENDENCY STATUS (2026-07-27; dependencies array unchanged): 375 (discrete weak terminus) COMPLETED — completeness_discrete/completeness_dense kernel-verify to the pristine axiom set. 169 (base weak) not_started. 170 (dense weak) not_started. 361 (terminology/architecture research + set-based layer design + Base/Dense compactness verdict) not_started — leg B is additionally gated on 361's verdict and the model-existence tasks it spawns; legs A/C/D are not.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 297, Task 343
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**: [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 295, Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274, Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 230

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 231
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 165, Task 402
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

**Description**: Apply validity-intro and truth-simp macros to the soundness layer.

RE-SCOPED 2026-07-26 by the codebase tactic survey (now archived at specs/archive/196_codebase_tactic_survey/reports/02_automation-survey.md section 6.3). The original charter targeted Theorems/ using tm_prove. Theorems/ is 7,017 lines - 3.8% of the tree, half the relative share the 2026-05 research assumed - and is sorry-free and stable; tm_prove (task 192) is abandoned; and the search-family tactics it would have fallen back on have zero adoption. The task keeps its kind (an application pass that reduces existing proof text) and replaces its target and its instrument.

Define a small family of syntactic macros and apply them mechanically to the three files that concentrate the codebase two highest-frequency verbatim proof repetitions. This is an APPLICATION task: the deliverable is measured reduction in existing proof text at named files, not the existence of a macro.

Macros to define (single-line `macro ... : tactic` declarations - no elaboration, no goal inspection):
  - intros_validity           for `intro F M Omega _h_sc τ _h_mem t`
  - intros_validity_framed    for the frame-condition-prefixed variant
  - simp_truth                for the recurring `simp only [TruthAt, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]` bundle
  - unfold_validity           composing intros_validity with simp_truth, for sites where the two appear consecutively

NAMING NOTE (2026-07-27): the simp head symbol is `TruthAt`, not the pre-upgrade `truth_at` -- the systematic Mathlib naming upgrade renamed it. The `Truth.*_iff` names above are unchanged (declared in FormalSystem/Semantics/Truth.lean at :220 some_future_iff, :239 some_past_iff, :258 future_iff, :278 past_iff).

Measured target sites (re-verified 2026-07-27 against the working tree, Boneyard/ excluded; counts unchanged from the 2026-07-26 measurement, only the paths and the simp head symbol were restated):
  - FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean      - 92 `intro F M Omega`, 54 `simp only [TruthAt`
  - FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean - 56 `intro F M Omega`, 30 `simp only [TruthAt`
  - FormalSystem/Metalogic/Soundness.lean                          -  0 `intro F M Omega`, 47 `simp only [TruthAt`

DO BOTH MACRO GROUPS AS ONE PASS over the same files, not two. Splitting them edits the same two files twice and forfeits the unfold_validity collapse.

COMPLETION CRITERION: `intro F M Omega` occurrences in the two SoundnessLemmas/ files reach zero; `simp only [TruthAt` occurrences across the three files fall by at least 80%; lake build green; executable sorry count unchanged at 1, located BY CONTENT in FormalSystem/Metalogic/WeakCanonical/Transfer.lean, never by line number. A task that ends with working macros and unchanged proof text has FAILED.

EXPLICITLY OUT OF SCOPE: Theorems/ refactoring, tm_prove, modal_search and every other search-family tactic, and any new elaborated tactic. See the survey report section 5 for the measured evidence (38 real proof-site invocations across ~5,800 lines of proof automation, all 38 in one file).

DEPENDENCY ON THE SYSTEMATIC MATHLIB NAMING UPGRADE -- NOW DISCHARGED (2026-07-27): this task rewrites proof bodies at roughly 330 sites, and the naming-upgrade task rewrote the same reference graph at 24,364 sites while moving every file from Theories/Bimodal/ to FormalSystem/. A mass proof rewrite must not race a mass rename, so this task was held until that rename landed. It HAS landed -- the naming-upgrade task is status `completed` -- so the precondition is satisfied and this task is NOT blocked. Every path in this description, and every entry in file_scope, is now stated in its post-rename FormalSystem/ form; `Theories/Bimodal/` appears above only as the historical source of that move, never as a path to open.

Inventory groups drawn on: survey report section 4.2 groups 2 (intros_validity, score 153) and 3 (simp_truth, score 72.7).

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402, Task 426, Task 428, Task 429, Task 430, Task 431, Task 432, Task 433, Task 434

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 169. Complete frame extension setup and soundness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 422

**Description**: Base (FrameClass.Base / general) WEAK completeness green: make the empty-context theorem `completeness` (BXCanonical/Completeness.lean:196, `valid φ → Derivable FrameClass.Base [] φ`) genuinely sorry-free.

CORRECTED SCOPE (2026-07-28, from task 361's design/03_weak-terminus-status.md): this task's earlier description named THREE open sorries. That was stale. `completeness` has EXACTLY ONE reachable sorry: `WeakCanonical.countermodel_discrete` at `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`. Machine-verified this session via `lean_verify`: `#print axioms completeness` = [propext, sorryAx, Classical.choice, Quot.sound], with `Transfer.lean:1242` the sole `sorryAx` source. The other two the old description named are gone from live code — the dense arm now runs through `countermodel_dense_enriched` (Completeness.lean:133, called at :221), which is sorry-free, and the mixed case is closed by `Chronicle.mcs_mixed_case_absurd` (MCSMixedCase.lean, called from Completeness.lean:231), also sorry-free. `dd_countermodel_chronicle_mixed_sorry` is archived.

ROUTE (settled by task 361, design/03 sections 5.3-5.7):
- Route (i) — a Base-MCS → Discrete-MCS transfer lemma letting `countermodel_discrete_reynolds_v2` apply (the route the Transfer.lean docstring currently proposes) — is REFUTED and MUST NOT be re-attempted. Witness: over `ℤ ×ₗ ℤ` with `p` true exactly at points ≥ (1,0), `□U(⊤,⊥)` holds everywhere while `Axiom.z1 p` is false at (0,0); so a Base-MCS containing `□U(⊤,⊥)` need not be Discrete-consistent.
- Route (iii) — reuse the existing ℚ dense chronicle — is BLOCKED: `box_dense_gives_density` (ChronicleToCountermodelBasic.lean:435) is load-bearing for the ℚ Cantor isomorphism and is unavailable when the order is discrete.
- Route (ii) — direct construction over the NON-ARCHIMEDEAN discrete carrier `ℚ ×ₗ ℤ` — is RECOMMENDED. `FrameClass.Base` imposes no Archimedean-ness (`valid`, Validity.lean:79, has no `IsSuccArchimedean` binder), so the ℤ+ℤ shape that killed the old BX `succ_cofinal` pipeline is not a counterexample here — it is the intended carrier. Do not re-attempt `succ_cofinal`.

DEPENDENCIES: task 421 corrects the refuted route guidance in Transfer.lean and probes the carrier's Mathlib instances; task 422 builds the discrete chronicle over that carrier plus its three restricted-coherence analogues. THIS task consumes 422's output to close `countermodel_discrete`, delete the Transfer.lean sorry, and re-verify `#print axioms completeness` reports no `sorryAx`.

ROLE IN THE COMPLETENESS PROGRAMME (terminology settled 2026-07-27): this is the headline WEAK terminus for Base, consumed by the consequence-completeness capstone (task 362) as its single-formula engine. The weak engine yields only the finite-context consequence corollary (inter-derivable with weak completeness via the deduction theorem — deliberately NOT called "strong completeness"). Genuine STRONG completeness for Base (Γ : Set Formula) additionally requires semantic compactness, gated on task 424; that obligation is NOT discharged by this task.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md.

---

### 128. Open set operator dense continuous
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add topological open set (interior) operator for dense and continuous temporal frames. On discrete ℤ the interior is trivial (discrete topology), but on dense ℚ and continuous ℝ it captures neighborhood-stable truth: Int(φ) true at t iff φ holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4, and Fernandez-Duque intuitionistic temporal logic. Phase 1: add TopologicalSpace instance to TaskFrame for dense/continuous cases. Phase 2: add interior constructor to Formula with truth clause. Phase 3: axioms (S4-like: Int(φ)→φ, Int(φ)→Int(Int(φ))). Phase 4: interaction with temporal operators and S5 □. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014) — completeness may require non-standard techniques.

---

### 127. Time addition operator
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add time addition operator (+) to the bimodal logic TM. φ + ψ is true at (τ, x) iff ∃ y,z with x = y+z, φ true at (τ,y), ψ true at (τ,z). This internalizes the AddCommGroup structure of D into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), and separation logic (BI). Phase 1: add tadd/tsub constructors to Formula, truth clause in semantics. Phase 2: basic axioms (associativity, commutativity, identity, inverse). Phase 3: soundness proofs. Phase 4: interaction with G/H/U/S/□. Completeness (ternary canonical model) and decidability are open research problems — defer to later phases.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 420, Task 439

**Description**: Implement a Jonsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. Phased approach: Phase 1 — Complex algebra Cm(F): define powerset STSA for TaskFrames with box/G/H/sigma operators derived from frame relations. Prove Cm(F) satisfies all STSA axioms. Phase 2 — Ultrafilter frame Uf(A): given abstract STSA A, construct frame whose worlds are ultrafilters with canonical relations R_G, R_H, R_Box (seed infrastructure from task 163 recovery of UltrafilterChain.lean). Prove Uf(A) satisfies TaskFrame axioms. Phase 3 — Embedding theorem: prove eta(a) = {U | a in U} is an injective STSA homomorphism A into Cm(Uf(A)). Phase 4 — Since/Until extension: extend STSA typeclass with binary untl/sinc operators and prove representation for the full operator signature. Start with basic {box, G, H} fragment (Phases 1-3) before tackling S/U (Phase 4). Prerequisites: resolve 6 algebraic sorries (temp_k_dist, temp_a, temp_l in TenseS5Algebra/InteriorOperators/LindenbaumQuotient); obtain 3 missing papers (Jonsson-Tarski 1951/52, BRV 2001 Ch.5, Goldblatt 1989). Task 992 research report (01_stsa-algebraic-analysis.md) maps ~80% of needed infrastructure. Architecture: restructure Algebraic/ into Core/ (shared STSA/Boolean/ultrafilter), Completeness/ (renamed existing), Representation/ (new J-T work).

FOUR-AXIOM EXPOSURE NOTE (added 2026-08-10): Phase 2's obligation 'Prove Uf(A) satisfies TaskFrame axioms' is about to get strictly harder. Once task 420 lands, TaskFrame carries the paper's four def:frame axioms (biconditional Compositionality, Seriality, Limit, Spherical -- pinned in specs/paper-definitions-of-record.md) plus a Nonempty WorldState field and a [Nontrivial D] binder. Spherical (every directed family of nonempty fibers and segments has nonempty intersection) for an ultrafilter frame is a genuinely nontrivial NEW obligation the current three-field structure does not anticipate -- scope Phase 2 against the four-axiom target, and note the paper's finite-W discharge pattern (subset-least member of a finite directed family) does NOT apply to ultrafilter frames, which are typically infinite.

---

### 95. Completeness verification audit
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 165, Task 408, Task 412, Task 426, Task 428, Task 429, Task 430, Task 431, Task 432, Task 433, Task 434

**Description**: Verify and record the final axiom/sorry status of the headline metalogical results, then close.

RE-SCOPED 2026-07-26. Most of this task's original content has been ANSWERED by the archivable-sorry review, which resolved the question definitively rather than partially. Do not re-derive it:

  - The discrete-case sorryAx trace is COMPLETE. `WeakCanonical.countermodel_discrete`
    (FormalSystem/Metalogic/WeakCanonical/Transfer.lean) is the SOLE sorryAx source reaching
    `BXCanonical.completeness`. This was established by a whole-environment
    `Lean.collectAxioms` scan, not by inference from names or file locations.
  - The tainted set is exactly 3 declarations: countermodel_discrete,
    completeness, completeness'. It was 47 before the archival.
  - `completeness_dense` and `completeness_discrete` are CLEAN.
  - The BX chronicle path named in the original charter
    (dd_countermodel_chronicle_discrete -> succ_embed_surjective ->
    chronicle_gap_contradiction) was dead code and has been ARCHIVED to
    FormalSystem/Boneyard/DeadChronicleGapElimination/. It is no longer in
    the build, so there is nothing left to trace along that path.
  - The dense and mixed chronicle countermodels were already confirmed
    sorry-free.

WHAT REMAINS -- a narrow confirmation pass, not an investigation:
  (1) Re-run `#print axioms` (or lean_verify) on the headline theorems and
      confirm the state above still holds. Record the result.
  (2) Confirm the live sorry count is exactly 1, located BY CONTENT in
      FormalSystem/Metalogic/WeakCanonical/Transfer.lean -- never by line number, it drifts
      with every edit to that file.
  (3) Record, in a durable location, that discharging countermodel_discrete is a
      genuine open construction rather than an oversight: the clean
      `countermodel_discrete_reynolds_v2` requires a Discrete-MCS, and the old
      BX route is PROVABLY unavailable (succ_cofinal is refuted by the Z+Z
      counterexample). Proving it belongs to its own task.

METHODOLOGY WARNING, established the hard way: do NOT build a reverse-dependency
graph over `ConstantInfo.value?` to decide what depends on what. Under Lean
4.33's module system imported THEOREM bodies are unavailable, so such a graph
silently under-reports -- it wrongly showed countermodel_discrete as having zero
consumers, which would have led to archiving the one sorry that breaks
completeness. Use `Lean.collectAxioms` plus textual analysis instead.

EXPECTED OUTCOME: this task most likely closes as verified-complete. If step (1)
or (2) diverges from the state above, that divergence IS the finding and should
be reported prominently rather than silently reconciled.
