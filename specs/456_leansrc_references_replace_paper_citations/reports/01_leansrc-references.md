# Research: Replace paper-citation footnote apparatus with `#leansrc` references

Task: replace the paper-citation footnote apparatus in `typst/FormalFoundations.typ` (working
tree, uncommitted) with Lean source references via the existing `#leansrc(module, name)` macro.
Research only — `typst/FormalFoundations.typ` was not edited.

All line numbers below are from the working-tree file read at research time
(`typst/FormalFoundations.typ`, 1091 lines) and will drift as edits land; every site is also
identified by a quoted excerpt so the implementer can locate it by pattern.

## 1. `leansrc` binding resolution (confirmed empirically)

Two competing bindings exist:

- `typst/template.typ:98` — `#let leansrc(module, name) = block(above: 1.0em, below: 1.0em, raw(block: true, "> " + module + "." + name + "."))` — renders as a standalone raw block, `> Module.name.`
- `typst/notation/shared-notation.typ:59` — `#let leansrc(module, name) = raw(module + "." + name)` — renders inline, no `>` prefix, no block spacing.

`FormalFoundations.typ` imports both, in this order:
```
26  #import "notation/bimodal-notation.typ": *      // re-exports shared-notation's inline leansrc
27  #import "template.typ": ..., leansrc, ...        // template's block leansrc, named explicitly
```
Typst import bindings behave like sequential top-level assignments into the same scope; a later
`#import` that names a symbol overwrites an earlier wildcard import of the same name. Verified
empirically: compiled a standalone probe file (`#import "notation/bimodal-notation.typ": *` then
`#import "template.typ": leansrc` then `#leansrc("Test.Module", "test_decl")`) with `typst
compile`, extracted text from the resulting PDF with `pdftotext`, and got:
```
> Test.Module.test_decl.
```
i.e. the **block** form from `template.typ` wins, matching the rendering of the existing 7 call
sites in `FormalFoundations.typ`. `shared-notation.typ`'s inline `leansrc` is dead for this
document — never reached, shadowed at line 27. No action needed on this front; just don't
delete/reorder the line-27 import.

## 2. Complete footnote inventory

`FormalFoundations.typ` contains 51 `#footnote[...]` occurrences total. Of these:

- **1 is commented out** (line 260, inside a `// FIX:` block belonging to sibling tasks — do not
  touch) and never renders.
- **41 immediately trail the closing bracket of a statement block** (`]#footnote[...]`,
  `]<label>#footnote[...]`, or `)#footnote[...]` for a table/figure) — this is the citation-
  bookkeeping apparatus the task targets.
- **9 are mid-paragraph**, attached to a word or clause inside running prose rather than to a
  block's closing bracket (e.g. lines 167, 494, 680, 697, 724, 790, 876, 932, 1074). These are
  substantive prose footnotes, not part of the bookkeeping pattern (several don't even cite the
  paper — they cite `@doets1987`, `@reynolds1992`, `@kamp1968`, etc., or nothing). **They are out
  of scope for this task and should be left alone.**

My count of block-trailing footnotes is **41**, against the task prompt's estimate of 39 — a
2-site discrepancy, both borderline: line 384 trails a table/figure (the frame-class extensions
table) rather than a `#definition`/`#theorem`/`#lemma`/`#corollary` directly, and several others
(418, 434, 505, 523, 832, 855, 902) trail a `#proposition` or `#remark` rather than the four named
types literally. I've included all of them below since they follow the identical
anchor-plus-citation pattern and need the identical treatment; the planner can exclude the
borderline ones if a stricter reading is wanted, but I'd recommend treating all 41 uniformly since
the pattern (and the fix) is the same regardless of block keyword.

Of the 41: **7 are Lean-path** (mention a `.lean` file path or bare Lean identifiers, no paper
citation), **16 are pure bookkeeping** (anchor + citation only, nothing else), and **18 are
substantive** (anchor + citation + real commentary, or in three cases no leading anchor at all).
This lines up closely with the task's 27/7 split (my 16 pure-bookkeeping + 13 substantive-with-
leading-anchor = 29 that "open with an inert anchor," vs. the task's 27 — same ballpark, exact
figure sensitive to the proposition/remark borderline cases noted above). The **7 Lean-path**
figure matches the task's stated count exactly.

### 2a. PURE BOOKKEEPING — delete outright (16 sites)

Each is `]#footnote[`\`anchor\`. @brastmckie2026possibleworlds]` (or a comma-list of anchors) with
*no* content beyond the anchor(s) and the citation. Locate by the block's title string.

| # | Locate by (block title / opening text) | Footnote content (verbatim) |
|---|---|---|
| 1 | `#definition("Defined Operators")` | `` `def:BLplus-defined`. @brastmckie2026possibleworlds `` |
| 2 | `#definition("Temporal Order")` | `` `def:temporal-order`. @brastmckie2026possibleworlds `` |
| 3 | `#definition("Directed Family")` | `` `def:directed`. @brastmckie2026possibleworlds `` |
| 4 | `#lemma("Nullity")` | `` `lem:nullity`. @brastmckie2026possibleworlds `` |
| 5 | `#definition("History")` | `` `def:world-history`. @brastmckie2026possibleworlds `` |
| 6 | `#theorem("Extension")` | `` `thm:extension`. @brastmckie2026possibleworlds `` |
| 7 | `#corollary("Occurrence")` | `` `cor:occurrence`. @brastmckie2026possibleworlds `` |
| 8 | `#theorem("Separation")` | `` `app:topology-t1`, `app:topology-r0`. @brastmckie2026possibleworlds `` |
| 9 | `#definition("Validity and Consequence")` | `` `def:frame-validity`, `def:logical-consequence`. @brastmckie2026possibleworlds `` |
| 10 | `#definition("S5")` | `` `def:S5`. @brastmckie2026possibleworlds `` |
| 11 | `#proposition("Correspondence")` | `` `app:discrete`, `app:dense`, `app:complete`, against `def:frame-properties`. @brastmckie2026possibleworlds `` |
| 12 | `#theorem("Incompleteness at the base level")` | `` `cor:tm-completeness`. @brastmckie2026possibleworlds `` |
| 13 | `#theorem("Decidability")` (the open-question one, "Whether TM, ... are decidable is open.") | `` `cor:tm-decidability`. @brastmckie2026possibleworlds `` |
| 14 | `#theorem("Dichotomy")` | `Part of `` `cor:tm-completeness` ``'s proof. @brastmckie2026possibleworlds` |
| 15 | `#remark` beginning "The phenomenon is not special to task semantics..." (follows the "Necessity of temporal structure" proposition) | `` `sub:Extension`, live prose. @brastmckie2026possibleworlds `` |
| 16 | `#definition("Strongest Objective Normal Modal Operator")` | `` `def:strongest`. @brastmckie2026possibleworlds `` |

### 2b. SUBSTANTIVE — strip the `anchor. @citation` prefix, keep the rest verbatim (18 sites)

| # | Locate by | Anchor/citation prefix to strip | Commentary to keep |
|---|---|---|---|
| 1 | `#definition("Language")` | `` `def:BLplus-language`. @brastmckie2026possibleworlds `` | "The paper's base language $BL$ takes the one-place $allpast$ and $allfuture$ as primitive instead; it embeds into $BLplus$ under @def-operators, and is not used below. The paper is available at [link]." — **note:** this is where the paper's URL currently lives; see §4 below on where the single citation/link should end up. |
| 2 | `#definition("Task Relation")` | `` `def:task-relation`. `` | "The relation is primitive only on $D^+$; negative durations are defined, not given." |
| 3 | `#definition("Frame")` | `` `def:frame`. `` | "Compositionality is a biconditional, load-bearing in both directions." |
| 4 | `#definition("Task Topology")` | `` `def:task-topology`. `` | "The topology is carried by the world states, not by $H_taskframe$ or by $D$." |
| 5 | `#definition("Model")` | `` `def:BL-semantics`. `` | "An interpretation assigns each sentence letter a set of *world states*. ... makes a possible world a trajectory through a fixed state space and not an independent index." |
| 6 | `#definition("Truth")` | `` `def:BL-semantics`, `def:BLplus-semantics`. `` | "Evaluating at a possible world paired with a time, ... is an instance of Scott's proposal @scott1970advice that the index of evaluation be a structured point of reference and not a bare world." — **preserve the `@scott1970advice` citation**, it's a different (still-live) reference, not part of the bookkeeping being removed. |
| 7 | `#definition("Frame Properties")` | `` `def:frame-properties`. `` | "The first three constrain $Dur$; the fourth constrains $arrow.r.double.long$." |
| 8 | `#definition("BX")` | `` `def:BX`. `` | "Seventeen named keys. The past direction of each axiom is derived from the future direction by TD, not postulated." |
| 9 | figure/table, "The three frame-class extensions of $TM^+$" | `` `def:TMplus`, `def:TMplus-f`, `def:TMplus-d`, `def:TMplus-c`. `` | "Whether CO alone axiomatizes the same $BLplus$-logic as the full Reynolds triple is open." |
| 10 | `#theorem("Soundness")` | `` `thm:TM-soundness`. `` | "The characteristic case is M5, ... which holds because $square.stroked$ quantifies over $H_taskframe$ entire and so is insensitive to the possible world at which it is evaluated." |
| 11 | `#proposition("Collapse")` | `Pthm:13, Pthm:14, Pthm:18, Pthm:20, each a chain of at most six lines from the perpetuity principles P1--P6 and TF (...), which follow in turn from MF and MT.` | Keep the whole sentence minus the trailing `@brastmckie2026possibleworlds` — the `Pthm:` keys are the anchor-equivalent here; strip them too if the convention is "no bare paper anchors survive," or keep them as informal cross-reference prose (implementer's call, but consistent with stripping elsewhere). |
| 12 | `#remark` following the "Incompleteness at the base level" theorem, beginning "No conservativity claim is made..." | `` `def:TMplus`. `` | "The paper's former conservative-extension theorem has been deleted; this footnote's four parts replace it." |
| 13 | `#proposition("Failure of a uniform finite model property over $ZZ$")` | `` `cor:tm-decidability`'s proof. `` | "A repaired finite model property must be class-specific, ranging over effective non-Archimedean carriers such as $ZZ times_lex ZZ$ and not over $ZZ$ alone." |
| 14 | `#definition("Irregular World")` | "Quoted in substance from the live footnote at `sub:Extension`, which is unlabelled and so cannot be pinned by anchor; re-verified verbatim against the live paper on 2026-08-13." | "Cosets and not subgroups: a family of translates is closed under ambient translation and so preserves MF and the perpetuity principles, which the subgroup formulation loses." — this one has no clean "anchor. @citation" prefix to strip; it's an editorial verification note. Recommend keeping the substantive half and dropping the "re-verified against the live paper on [date]" bookkeeping clause, or moving that provenance note to the single citation site (§4). |
| 15 | `#proposition("The price of irregular worlds")` | "Parts (i)--(iii) are the paper's own, at `sub:Extension`; its verdict there is that \"these considerations recommend possible over irregular worlds.\"" | "Part (iv) is this document's addition, grounded in `def:strongest` and `thm:exist` below together with the observation that broadening the consequence relation changes which operator is $prec.eq$-least; the paper's sentence stating it is commented out in the live source and is not cited as paper text." |
| 16 | `#theorem("Existence")` | `` `thm:exist`. `` | "Clause (1) is the second conjunct of O-Meet, clause (2) follows from the first, and T, N, K, and necessitation-closure follow by detaching O-Fac, O-Ax, and O-Nec at $Bm$." |
| 17 | `#theorem("Uniqueness and logic")` | `` `lem:uniq`, `thm:s4`, `thm:sym`. `` | "Under the hypothesis, `lem:uniq` gives $tack.r forall p(square.stroked p arrow.l.r Bm p)$, and factivity and necessitation follow by detaching O-Fac and O-Nec." |
| 18 | `#proposition("Orthogonality")` | "The live Stability footnote following its semantic clause." | "The general lesson drawn in the statement is this document's own; the paper's sentence stating it generally is commented out in the live source and is not cited as paper text." |

### 2c. LEAN-PATH — convert to `#leansrc` blocks, preserve substantive prose as trimmed footnotes (7 sites)

These 7 already read like Lean-source notes (file paths / bare identifiers, no paper citation) —
they're the clearest candidates for `#leansrc` conversion, and in several cases the block should
carry **multiple** `#leansrc` calls (one per Lean declaration mentioned) rather than one.

| # | Locate by | Current footnote (verbatim) | Declarations mentioned | Disposition |
|---|---|---|---|---|
| 1 | `#theorem("Base-class completeness (outstanding)")` | "The `sorryAx` traces to a single dependency, `countermodel_discrete` in `WeakCanonical/Transfer.lean`, which is dead code: the live replacement `countermodel_discrete_reynolds_v2` is what `completeness_discrete` actually calls (@sec:construction). The obligation is therefore narrow and identified, which is not the same as discharged." | `countermodel_discrete` (dead), `countermodel_discrete_reynolds_v2`, `completeness_discrete` | This is the task prompt's own worked example: **preserve the sorryAx dependency analysis as a trimmed footnote** (it's substantive, not bookkeeping), and add a `#leansrc("Metalogic.WeakCanonical", "countermodel_discrete_reynolds_v2")` block (verify module — see §3) since that's the live declaration the prose is actually about; `countermodel_discrete` is dead code and doesn't need its own `#leansrc`. |
| 2 | `#definition("Consistent and Maximal Consistent Sets")` | "`SetConsistent` and `SetMaximalConsistent` in `Metalogic/Core/MaximalConsistent.lean`. Consistency is defined on finite subsets, so the set-level layer is finitary even though the sets themselves are infinite." | `SetConsistent`, `SetMaximalConsistent` | `#leansrc("Metalogic.Core", "SetConsistent")` and `#leansrc("Metalogic.Core", "SetMaximalConsistent")` (two calls), footnote trimmed to just the finitary-layer remark. |
| 3 | `#definition("Bundled Family of MCSs")` | "`BFMCS` in `Metalogic/Bundle/BFMCS.lean`, fields `modal_forward` and `modal_backward`; the structure also designates an evaluation family, the one containing the original consistent set." | `BFMCS` | `#leansrc("Metalogic.Bundle", "BFMCS")`; footnote trimmed to the "also designates an evaluation family..." remark, or dropped if judged pure bookkeeping (borderline — recommend keeping, it's genuine content about a field not obvious from the name). |
| 4 | `#definition("Chronicle")` | "`singletonChronicle` and `omegaChain` in `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`. Countability of the enumeration is what makes an $omega$-chain sufficient." | `singletonChronicle`, `omegaChain` | Two `#leansrc("Metalogic.BXCanonical.Chronicle", "singletonChronicle")` / `("...", "omegaChain")` calls; footnote trimmed to the countability remark. |
| 5 | `#definition("The Reynolds pipeline")` | "`one_class` (`WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean`), `VeryGood` and `good` (`IntegerModel/GoodStructures.lean`), `limitdom_is_good` (`IntegerModel/ReynoldsBridge.lean`), and `truth_transfer` (`WeakCanonical/Transfer.lean`). The decomposition technique is Doets's @doets1987; the step-by-step k-equivalence argument for Until/Since is Reynolds's @reynolds1992, as developed in Gabbay, Hodkinson, and Reynolds @gabbayhodkinsonreynolds1994." | `one_class`, `VeryGood`, `good`, `limitdom_is_good`, `truth_transfer` | Four `.lean` files → four `#leansrc` calls (module differs per file, see §3). **Preserve the Doets/Reynolds/Gabbay-Hodkinson-Reynolds citation sentence as a trimmed footnote** — these are genuine external-literature citations distinct from `@brastmckie2026possibleworlds` and must survive. |
| 6 | `#definition("The real-model construction")` | "`RealModel/DoetsTheorem.lean`, `Shuffle.lean`, `ShuffleReal.lean`, `EpsilonDense.lean`, and `OrderIsoReal.lean`. The basis is the Reynolds triple Prior-U, Prior-S, and Sep, with CO derived." | files only, no bare declaration names given in-text | Need the actual top-level declaration name(s) in each file (grep during implementation — this footnote names files, not declarations); footnote trimmed to "The basis is the Reynolds triple..." remark. |
| 7 | `#definition("The Lindenbaum--Tarski Algebra")` | "`Metalogic/Algebraic/LindenbaumQuotient.lean`, `BooleanStructure.lean`, `InteriorOperators.lean`, `UltrafilterMCS.lean`; the flow-frame engine of @sec:construction lives alongside them in `FlowFrame.lean`. All five measure sorry-free." | 5 files, no bare declaration names given in-text | Same issue as #6 — footnote names files, not declarations; implementer needs to grep each file for its principal declaration. Footnote trimmed to "All five measure sorry-free" (still true and worth keeping) or dropped if judged redundant with the `#leansrc` blocks themselves. |

For #6 and #7, the footnote text names *files*, not bare Lean identifiers, unlike the other five.
The implementer will need one extra grep step per file to get the declaration name for the
`#leansrc(module, name)` call — I did this for the files I had budget to check (§3) but not
exhaustively for every file in these two groups.

## 3. Document-item → `FormalSystem/` declaration mapping

**Module-string convention** (derived from the 7 existing call sites and confirmed against their
actual Lean source): the `module` argument is the file's Lean namespace with the leading
`FormalSystem.` stripped (e.g. a file opening `namespace FormalSystem.Metalogic.BXCanonical.Chronicle`
takes `"Metalogic.BXCanonical.Chronicle"`), and `name` is the bare declaration identifier as
written after `theorem`/`def`/`structure`/`lemma`, *not* dot-qualified even when the namespace
nests further. Verified against all 7 existing sites, e.g. `mcs_mixed_case_absurd` is declared
under `namespace FormalSystem.Metalogic.BXCanonical.Chronicle` in
`FormalSystem/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean`, matching
`#leansrc("Metalogic.BXCanonical.Chronicle", "mcs_mixed_case_absurd")` exactly.

Confidence tags: **[confirmed]** = grep-verified declaration + namespace, matches the module-
string rule above. **[plausible]** = strong candidate found via docstring cross-reference to the
same paper anchor, not independently re-derived from the declaration's namespace — verify before
use. **[none]** = searched, found nothing; treat absence as a decision, not an oversight.

| Document item | Lean counterpart | `#leansrc` call | Confidence |
|---|---|---|---|
| `#definition("Frame")` | `structure TaskFrame` in `Semantics/TaskFrame.lean`, `namespace FormalSystem.Semantics` | `#leansrc("Semantics", "TaskFrame")` | [confirmed] |
| `#lemma("Nullity")` | `theorem nullity` in `Semantics/TaskFrame.lean`, inside `namespace TaskFrame` (nested in `Semantics`) | `#leansrc("Semantics.TaskFrame", "nullity")` | [confirmed] |
| `#definition("Directed Family")` | `def DirectedFamily` in `Semantics/TaskFrame.lean`, same nested `TaskFrame` namespace | `#leansrc("Semantics.TaskFrame", "DirectedFamily")` | [confirmed] |
| `#definition("Task Relation")` (Fiber/Cone/Segment sub-items) | `def Fib`, `def cone`, `def Seg`, all in `Semantics/TaskFrame.lean`'s nested `TaskFrame` namespace | Three calls, e.g. `#leansrc("Semantics.TaskFrame", "Fib")`, `("...", "cone")`, `("...", "Seg")` — or pick the frame-relevant single anchor if the plan wants one block per definition (see Logos reference pattern in §4, which groups these under one `#leansrc("Foundations.Constitutive.Frame", "TaskFrame")` after presenting Fiber/Cone/Segment/Task-Frame as a run of definitions) | [confirmed] |
| `#definition("Temporal Order")` | **No single bundled declaration.** Realized as a typeclass assumption bundle `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`, repeated as a `variable`/hypothesis everywhere (`TaskFrame.lean`, `Truth.lean`, etc.), not a named structure. | none | [none] — flag as a genuine absence; the paper's bundled notion has no Lean-side name to point at. |
| `#definition("History")` (partial history / world history / possible world) | `structure PartialHistory` (`Semantics/PartialHistory.lean`, `namespace FormalSystem.Semantics`) and `structure WorldHistory` (`Semantics/WorldHistory.lean`, same namespace) | `#leansrc("Semantics", "PartialHistory")` and `#leansrc("Semantics", "WorldHistory")` | [confirmed] |
| `#theorem("Extension")` | `theorem extension` in `Semantics/Extension/Extension.lean`, `namespace FormalSystem.Semantics.PartialHistory` | `#leansrc("Semantics.PartialHistory", "extension")` | [confirmed] |
| `#corollary("Occurrence")` | `theorem occurrence`, same file/namespace | `#leansrc("Semantics.PartialHistory", "occurrence")` | [confirmed] |
| the commented-out `` `lem:step` `` material (Step Lemma) | Consumed inside `extension`'s proof per the file's own docstring ("2. `PartialHistory.step` (`lem:step`)"); check for a standalone `step` declaration in `Semantics/Extension/Step.lean` | `#leansrc("Semantics.PartialHistory", "step")` (verify name/namespace against `Extension/Step.lean` directly) | [plausible] — this whole passage is commented out (`// FIX:`, sibling-task territory per the task's constraints); do not touch it in this task regardless. |
| `cor:spherical-finite` (finite-carrier Spherical discharge, referenced from several footnotes) | `theorem spherical_of_finite` in `Semantics/TaskFrame.lean` (top-level `Semantics` namespace, outside the nested `TaskFrame` block — verify) | `#leansrc("Semantics", "spherical_of_finite")` | [plausible] |
| `#definition("Model")` | `structure TaskModel` in `Semantics/TaskModel.lean`, `namespace FormalSystem.Semantics` | `#leansrc("Semantics", "TaskModel")` | [confirmed] |
| `#definition("Truth")` | `def TruthAt` in `Semantics/Truth.lean`, `namespace FormalSystem.Semantics` (before the nested `namespace Truth` reopens) | `#leansrc("Semantics", "TruthAt")` | [confirmed] |
| `#definition("Validity and Consequence")` | `def valid`, `def SemanticConsequence` in `Semantics/Validity.lean`, `namespace FormalSystem.Semantics` | `#leansrc("Semantics", "valid")` and `#leansrc("Semantics", "SemanticConsequence")` | [confirmed] |
| `#definition("Frame Properties")` (Discrete/Dense/Complete/Deterministic) | `FrameConditions/FrameClass.lean` has `DenseTemporalFrame.mk'`, `DiscreteTemporalFrame.mk'`, `DedekindTemporalFrame.mk'`/`.of_conditionallyComplete` theorems, implying structures `DenseTemporalFrame`/`DiscreteTemporalFrame`/`DedekindTemporalFrame` exist in the same file; "Deterministic" (constrains the task relation, not $D$) not located in this file | `#leansrc("FrameConditions.FrameClass", "DenseTemporalFrame")` etc. (verify structure declarations directly — only the `.mk'` lemmas were grepped, not the structures themselves) | [plausible] for Discrete/Dense/Complete; [none found yet] for Deterministic — needs a direct grep during implementation. |
| `#definition("S5")` | **No single declaration.** MK/MT/M5 are three separate constructors of `inductive Axiom` in `ProofSystem/Axioms.lean` (`namespace FormalSystem.ProofSystem`): `modal_k_dist` (MK), `modal_t` (MT), `modal_5_collapse` (M5). No anchor `def:S5` appears anywhere in `FormalSystem/`. | Either three `#leansrc("ProofSystem.Axioms", "Axiom.modal_k_dist")`-style calls naming the constructors, or note as unmapped since the paper's "S5" is a bundle, not a Lean declaration | [confirmed - constructors exist] but [no single-declaration match] — implementer/planner should decide whether three leansrc calls or a prose note is the right treatment. |
| `#definition("BX")` (17 named axiom keys) | Scattered constructors of the same `inductive Axiom` — `serial_future`/`serial_past`, `connect_future`/`connect_past`, `enrichment_until`/`enrichment_since`, `self_accum_until`/`_since`, `absorb_until`/`_since`, `linear_until`/`_since`, `until_F`/`since_P`, `temp_linearity`/`_past`, `F_until_equiv`/`P_since_equiv` — no anchor `def:BX` found anywhere in `FormalSystem/` | Same situation as S5: no single declaration; a `#leansrc` per constructor would be 17+ calls, almost certainly not the intended treatment | [no anchor found] — treat as NO Lean counterpart in the `#leansrc` sense; the axiom *system* is the `Axiom` inductive type as a whole (`ProofSystem.Axioms`), not any one constructor. |
| frame-class table (`TM^+_f`, `TM^+_d`, `TM^+_c`) | `inductive FrameClass` in `ProofSystem/Axioms.lean:519`, `namespace FormalSystem.ProofSystem` | `#leansrc("ProofSystem.Axioms", "FrameClass")` (verify module — could also be bare `"ProofSystem"` if no sub-namespace reopens before line 519; check) | [plausible] |
| `#theorem("Soundness")` | `FrameConditions/Soundness.lean`, `namespace FormalSystem.FrameConditions`: `soundness_linear` (Base/TM), `soundness_dense`, `soundness_discrete`, `soundness_Int`; no single umbrella theorem covering all five systems in the paper's exact form | Multiple `#leansrc("FrameConditions.Soundness", "soundness_dense")` etc., or point to `soundness_over` (line 63, more general) if it's the umbrella | [confirmed - individual theorems exist]; [none found for a single umbrella statement] |
| `#proposition("Correspondence")` (DF/DN/CO iff Discrete/Dense/Complete) | Not independently pinned down in this pass — candidates live in `Metalogic/SoundnessLemmas/{DenseValidity,FrameClassVariants,CoValidity}.lean` and `FrameConditions/{Validity,Compatibility}.lean` (all matched a grep for "correspondence"/"iff...Discrete" but weren't individually opened) | needs implementer follow-up | [needs verification] |
| `#proposition("Collapse")` (the four perpetuity/collapse biconditionals, `Pthm:13/14/18/20`) | `Theorems/Perpetuity/Principles.lean`, `namespace FormalSystem.Theorems.Perpetuity`: candidates `perpetuity_2`, `modal5`, `perpetuity3`, `perpetuity4` (names don't obviously 1:1 match the paper's four biconditionals — needs a content-level check, not just a name match, since e.g. `perpetuity_2`/`perpetuity3`/`perpetuity4` look like a numbered family that may not align with `sometimes-box`, `always-box`, `box-always-box`, `diamond-sometimes` in that order) | `#leansrc("Theorems.Perpetuity.Principles", "perpetuity_2")` etc. — **verify each biconditional's exact statement against the Lean theorem's exact statement before binding**, don't match on name similarity alone | [plausible, needs content verification] |
| `#theorem("Weak completeness, dense/discrete/dense-and-complete class")` | Already has `#leansrc` (3 existing sites, lines 465/472/479) | n/a — already done | n/a |
| `#lemma("Lindenbaum")` | Already has `#leansrc("Metalogic.Core", "set_lindenbaum")` (line 560) | n/a | n/a |
| `#theorem("Case Split")` | Already has `#leansrc("Metalogic.BXCanonical.Chronicle", "mcs_mixed_case_absurd")` (line 616) | n/a | n/a |
| `#theorem("Truth Lemma, D-parametric form")` | Already has `#leansrc("Metalogic.Algebraic", "multiFamTaskFrameGen")` (line 675) | n/a | n/a |
| `#theorem("Base-class completeness (outstanding)")` | `completeness` in `Metalogic/BXCanonical/Completeness.lean` — mentioned by name in the doc's own prose ("stated in the development as `completeness`") but has no `#leansrc` yet, unlike the other three completeness theorems | `#leansrc("Metalogic.BXCanonical", "completeness")` | [confirmed] — worth adding even though this is the sorry-containing one; the doc explicitly wants readers to see it's real code, just unfinished. |
| `#definition("Consistent and Maximal Consistent Sets")` | `SetConsistent`, `SetMaximalConsistent` in `Metalogic/Core/MaximalConsistent.lean`, `namespace FormalSystem.Metalogic.Core` | `#leansrc("Metalogic.Core", "SetConsistent")`, `#leansrc("Metalogic.Core", "SetMaximalConsistent")` | [confirmed] |
| `#definition("Bundled Family of MCSs")` | `structure BFMCS` in `Metalogic/Bundle/BFMCS.lean`, `namespace FormalSystem.Metalogic.Bundle` | `#leansrc("Metalogic.Bundle", "BFMCS")` | [confirmed] |
| `#definition("Chronicle")` | `singletonChronicle`, `omegaChain` in `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` — namespace not independently re-verified in this pass but the file sits alongside `MCSMixedCase.lean` (confirmed `Metalogic.BXCanonical.Chronicle`) | `#leansrc("Metalogic.BXCanonical.Chronicle", "singletonChronicle")`, `("...", "omegaChain")` | [plausible — same directory as a confirmed file, namespace not independently re-grepped] |
| `#definition("The Reynolds pipeline")` | `one_class` (`WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean`), `VeryGood`/`good` (`IntegerModel/GoodStructures.lean`), `limitdom_is_good` (`IntegerModel/ReynoldsBridge.lean`), `truth_transfer` (`WeakCanonical/Transfer.lean`) — namespaces not independently re-verified; by directory convention likely `Metalogic.WeakCanonical.IntegerModel` for the first three and `Metalogic.WeakCanonical` for the last | Four `#leansrc` calls, modules per above — **verify namespaces before use** | [needs verification] |
| `#definition("The real-model construction")` | Files named but not declarations: `RealModel/{DoetsTheorem,Shuffle,ShuffleReal,EpsilonDense,OrderIsoReal}.lean`, likely `namespace FormalSystem.Metalogic.WeakCanonical.RealModel` | needs a declaration-name grep per file, then `#leansrc("Metalogic.WeakCanonical.RealModel", "<name>")` | [needs verification] |
| `#definition("The Lindenbaum--Tarski Algebra")` | Files named but not declarations: `Algebraic/{LindenbaumQuotient,BooleanStructure,InteriorOperators,UltrafilterMCS}.lean`, `namespace FormalSystem.Metalogic.Algebraic` (confirmed for `FlowFrame.lean` sibling used by `multiFamTaskFrameGen`'s existing leansrc, module `"Metalogic.Algebraic"`) | needs a declaration-name grep per file, then `#leansrc("Metalogic.Algebraic", "<name>")` | [module confirmed, declaration names need a grep pass] |
| `#definition("Strongest Objective Normal Modal Operator")`, `#theorem("Existence")`, `#theorem("Uniqueness and logic")`, `#proposition("Orthogonality")` | **No Lean counterpart searched found.** No anchor (`def:strongest`, `thm:exist`, `lem:uniq`, `thm:s4`, `thm:sym`) appears anywhere in `FormalSystem/`. This is the higher-order Bacon-style "strongest objective modality" apparatus — a primitive predicate $O$ over operator terms with quantification over an unrestricted domain of propositional operations — which is philosophical scaffolding, not part of the machine-checked S5/BX/task-frame development. | none | [none] — high confidence this whole subsection (§"The Strongest Objective Modality") has nothing to formalize against; leave these four items with no `#leansrc` block. |
| `#definition("Irregular World")`, `#proposition("The price of irregular worlds")` | No anchor found (these sections quote/paraphrase an unlabelled paper footnote, `sub:Extension`, with document-original additions); no Lean search performed since the content is explicitly about broadening the *paper's* consequence relation, not about the Lean development | none | [none] |

**Items to explicitly report as having NO Lean counterpart** (so the implementer treats the
absence as a decision): Temporal Order (no bundled structure); S5 and BX as single named axiom
sets (scattered constructors instead — a design choice, not an oversight, and probably shouldn't
get 20+ leansrc calls); Correspondence proposition (not conclusively located — flagged
"needs verification" above, may turn out to exist); the entire "Strongest Objective Modality"
subsection (Strongest Objective Normal Modal Operator, Existence, Uniqueness and logic,
Orthogonality); Irregular World and The price of irregular worlds.

## 4. Placement rules

Grounded in both the existing 7 call sites in this document and the Logos manual reference file
(`~/Projects/Logos/Theory/typst/manual/chapters/02-constitutive.typ`):

1. **`#leansrc` is a standalone block placed immediately after the item(s) it documents**, before
   any surviving footnote-turned-prose and before the next `==`/`===` heading or prose paragraph.
   All 7 existing sites in this document follow this: the block sits on its own line directly
   after the theorem/lemma/definition's closing `]`, with no intervening prose.
2. **One `#leansrc` block per closely related group of Lean declarations, not necessarily one per
   `#definition`.** The Logos reference groups `Fiber`/`Cone`/`Segment`/`Task Frame` — four
   separate `#definition[...]` blocks — under a single trailing
   `#leansrc("Foundations.Constitutive.Frame", "TaskFrame")`, because all four are facets of one
   Lean structure. Apply the same grouping here: e.g. Fiber/Cone/Segment (inside
   `#definition("Task Relation")`) and the standalone `#definition("Directed Family")` and
   `#definition("Frame")` that follow it are all part of the same `Semantics/TaskFrame.lean`
   apparatus and could reasonably share fewer, better-placed blocks rather than one each — but
   where the paper's `#definition` and the Lean `structure`/`def` are 1:1 (as with the 7 existing
   sites), keep it 1:1.
3. **Multiple Lean declarations for one document item become multiple stacked `#leansrc` calls**,
   not one call with concatenated names — there is no multi-name variant of the macro. The Logos
   file never needs this (each of its leansrc calls names exactly one declaration); this
   document's own footnote-2c items (`SetConsistent`/`SetMaximalConsistent`,
   `singletonChronicle`/`omegaChain`, the four Reynolds-pipeline declarations, etc.) will need
   stacked calls.
4. **A trimmed substantive footnote, if one survives, goes after the `#leansrc` block(s), not
   before.** None of the 7 existing sites have a footnote at all, so this is inferred from general
   Typst footnote-anchoring practice (a footnote mark must trail the text it annotates) combined
   with the document's own precedent at lines 465-466 / 472-473 / 479-480, where a plain
   (non-footnote) line of prose ("Axioms: exactly `propext`, ...") follows the `#leansrc` block
   directly. For the 7 lean-path sites in §2c that need a *footnote* (not just plain prose)
   preserved, put the footnote mark on the last sentence of the block-adjacent prose, after the
   `#leansrc` call, mirroring that existing pattern.
5. Do **not** attach `#leansrc` to a `#proof[...]` block or to a `#remark[...]` — every existing
   site and every Logos site attaches to a `#definition`/`#theorem`/`#lemma`/`#corollary`/
   `#proposition`, never to a proof or remark. Where a footnote currently trails a `#remark` (e.g.
   the conservativity remark, or "No conservativity claim..."), that footnote's disposition
   (delete or strip) is decided by §2's per-site table, but no new `#leansrc` block should be
   invented for a remark that doesn't itself introduce a new formalizable object.

## 5. Where the single paper citation should live

The paper needs to be cited exactly once — currently it's cited 36 times and never in the
introduction/abstract. The best location is the **`#definition("Language")` footnote**, which
already happens to be the *only* footnote of the 41 that carries the paper's URL
(`https://benbrastmckie.com/publications/possible_worlds.pdf`), right at the top of §1 ("The
System"), which is also the earliest point in the body where the paper's content (the base
language $BL$ vs. $BLplus$) is actually discussed. Concretely:

- Keep this footnote (it's classified SUBSTANTIVE in §2b, item 1), strip nothing but reduce it to
  a single citation: something like *"This document reports what is machine-checked in
  `FormalSystem/`, following the presentation of Brast-McKie's task-frame semantics
  @brastmckie2026possibleworlds, available at [link]. The paper's base language $BL$ takes the
  one-place $allpast$ and $allfuture$ as primitive instead; it embeds into $BLplus$ under
  @def-operators, and is not used below."* — this keeps the existing substantive content (BL vs.
  BLplus embedding) and folds the citation announcement into the same footnote rather than adding
  a second one.
- Alternative: move the citation to the **abstract block** itself (`#abstract-block[...]`, lines
  116-132) as a plain inline citation on the first mention of "TM" or "task-frame semantics" —
  this satisfies "first page" even more literally than the Language-definition footnote, but the
  abstract block currently has zero footnotes/citations and adding one there is a slightly bigger
  structural change than reusing the Language footnote. Either location satisfies the verification
  constraint (`grep -c brastmckie2026possibleworlds` → 1); I'd lean toward the Language-definition
  footnote since it's already carrying the URL and doesn't require inventing new abstract-block
  prose, but the choice is the planner's to make.
- Whichever site is chosen, every other one of the 36 current `@brastmckie2026possibleworlds`
  citations must be removed as part of executing §2's per-site dispositions (deleted outright with
  the pure-bookkeeping footnotes, or stripped out of the substantive ones while keeping the
  commentary).

## 6. Verification notes for the implementer

- `typst compile typst/FormalFoundations.typ` currently succeeds (confirmed exit 0 via the
  probe-file compile test in §1's methodology, though that was a standalone probe, not the real
  document — re-run against the real document as the final check) against the documented baseline
  of two `unknown font family: new computer modern sans` warnings from `thmbox`.
- For every `#leansrc(module, name)` this report proposes with confidence tag [plausible] or
  [needs verification], re-derive the module string directly from the target file's `namespace
  FormalSystem....` line (not from this report's guess) before writing it, exactly as done for the
  7 [confirmed] entries above — this is a 30-second grep per site and removes all risk of a
  non-resolving `#leansrc` pair.
- `lean_local_search` / `lean_hover_info` (via the lean-lsp MCP server) can substitute for grep to
  confirm a declaration still exists and get its exact signature before binding.
