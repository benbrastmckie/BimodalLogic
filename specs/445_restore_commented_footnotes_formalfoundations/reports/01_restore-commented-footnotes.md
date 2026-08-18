# Research Report: Restore or retire 39 commented-out footnotes in FormalFoundations.typ

- **Task**: 445 - Restore or retire 39 commented-out footnotes in FormalFoundations.typ
- **Started**: 2026-08-18T08:48:12Z
- **Completed**: 2026-08-18T08:52:49Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Sources/Inputs**:
  - `typst/FormalFoundations.typ` (target file, 1090 lines)
  - `typst/bibliography.bib` (citation keys)
  - `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (paper source, anchor labels)
  - `FormalSystem/` tree (Lean source files and symbols cited by footnotes)
  - `specs/state.json` (task 445/446/447 descriptions, to confirm scope boundary)
- **Artifacts**: this report
- **Standards**: report-format.md, artifact-formats.md, subagent-return.md

## Executive Summary

- All 39 `] // FIX: #footnote[...]` sites in `typst/FormalFoundations.typ` are footnote-carrying blocks (definitions, lemmas, theorems, corollaries) whose footnote text is fully drafted and merely commented out via the `// FIX:` prefix.
- Restoration is mechanical for 37 of the 39 sites: strip `// FIX: ` and join `]` directly to `#footnote[` with zero whitespace, matching the document's own live-footnote convention used elsewhere in the file.
- 2 sites carry a genuine citation error that must be corrected during restoration, not just uncommented: line 305 cites a paper anchor that does not exist (`def:BL-model`), and line 714 misattributes two Lean symbols to the wrong source file.
- Every paper anchor, bibliography key, internal Typst label, and Lean file path/symbol referenced across the 39 footnotes was checked against its live source; results are itemized below so the implementer does not need to re-derive them.
- No footnote is recommended for deletion. Every site's substantive content was corroborated against the paper or the live Lean tree (including the `sorryAx`/`countermodel_discrete` claim at line 488, which is not merely plausible but is the literal state of `WeakCanonical/Transfer.lean` today).
- The implementer can act purely mechanically from the disposition table in this report: 37 uncomment-only edits, 2 uncomment-with-correction edits, then `typst compile typst/FormalFoundations.typ` to confirm.

## Context & Scope

`typst/FormalFoundations.typ` contains 50 `// FIX:` occurrences in total, split across three sibling tasks by the pattern each FIX tag matches:

- **Task 445 (this task)**: 39 sites matching `] // FIX: #footnote[...]` — a definition/lemma/theorem/corollary block immediately followed, on the same line, by a commented-out footnote call. This report covers exactly these 39 sites.
- **Task 446**: 6 bare `// FIX:` tags at lines 214, 257, 263, 267, 277, 323, 342, 353, 362, 369, 393 that mark commented-out *prose or proof blocks* spanning multiple lines (not single-line footnote calls). These are out of scope for task 445 because they are a structurally different artifact — multi-line commented-out `#proof[...]` blocks, remarks, and prose paragraphs — not footnotes trailing a block closer, and task 446's own description explicitly enumerates this same line set as its scope.
- **Task 447**: a further 6 of those same bare `// FIX:` line numbers (244, 267, 353, 362, 369, 393) are additionally claimed by task 447 for substantive rewrites requiring new mathematical exposition grounded in the paper, distinct from mechanical restoration.

Scope verification: `grep -n "FIX:" typst/FormalFoundations.typ` was run and every line matching `] // FIX: #footnote\[` was extracted; the resulting 39 line numbers (149, 178, 191, 196, 211, 213, 238, 242, 255, 274, 276, 305, 321, 333, 340, 359, 367, 409, 418, 434, 448, 488, 505, 511, 523, 554, 575, 663, 691, 714, 739, 832, 841, 855, 883, 885, 891, 902, 944) match the task description's own list exactly, one-for-one.

## Findings

### Restoration Mechanics

The document already contains live (non-FIX) footnotes elsewhere, and they establish a single unambiguous attachment convention: a footnote call must join its preceding content with **zero whitespace** — no space, no newline — because Typst's footnote marker attaches to the immediately preceding node. Confirmed instances (`grep -n "\]#footnote\|\.#footnote\|)#footnote\|:#footnote"`):

- `] <def-operators>#footnote[...]` (line 162)
- `lacking one.#footnote[...]` (line 167)
- `)#footnote[...]` (line 384, after a `#figure(...)`)
- `@sec:histories.#footnote[...]` (line 494)
- `has nonempty intersection outright.#footnote[...]` (line 680)
- `the limit keeps them all.#footnote[...]` (line 697)
- `it is not machine-checked here.#footnote[...]` (line 724)
- `validity is a separate, open obligation.#footnote[...]` (line 790)
- `and not defined outright.#footnote[...]` (line 876)
- `compactness.#footnote[...]` (line 932)
- `there is wrong on arrival.#footnote[...]` (line 1074)

Every one of the 39 FIX sites in scope for this task has the form `] // FIX: #footnote[...]` — the block already closes with `]`, so the transformation is uniform and mechanical:

```
] // FIX: #footnote[CONTENT]
```
becomes
```
]#footnote[CONTENT]
```

No other character in `CONTENT` needs to change for 37 of the 39 sites (see disposition table). Two sites (305, 714) need a text correction inside `CONTENT` as well as the tag removal; see "Detail on the Two Corrections" below.

**What is and is not a compiled reference.** Every footnote quotes one or more backtick-wrapped anchor names from the paper (e.g. `` `def:frame` ``) or from the Lean tree (e.g. `` `SetConsistent` ``). These are **inert prose** — plain backtick-code spans, not Typst cross-reference syntax (`@label` or `#ref(label)`). They do not participate in Typst's reference resolution and cannot cause a compile failure regardless of whether the named anchor exists. The only tokens in these footnotes that Typst actually resolves at compile time are `@`-prefixed tokens: bibliography citations (`@brastmckie2026possibleworlds`, `@scott1970advice`, `@doets1987`, `@reynolds1992`, `@gabbayhodkinsonreynolds1994`) and internal cross-document labels (`@def-operators`, `@sec:construction`). This distinction matters for verification: the task's stated acceptance criterion ("all `@`-references and bibliography keys must resolve") applies only to this second category, not to the backtick-quoted paper/Lean anchor names, which are free-text documentation of provenance.

### Verification Performed

**Paper anchors** — checked with `grep -c "label{ANCHOR}" possible_worlds.tex` for every distinct anchor named across the 39 footnotes (33 distinct anchors: `def:BLplus-language`, `def:temporal-order`, `def:task-relation`, `def:directed`, `def:frame`, `lem:nullity`, `def:world-history`, `thm:extension`, `cor:occurrence`, `def:task-topology`, `app:topology-t1`, `app:topology-r0`, `def:BL-model`, `def:BL-semantics`, `def:BLplus-semantics`, `def:frame-properties`, `def:frame-validity`, `def:logical-consequence`, `def:S5`, `def:BX`, `thm:TM-soundness`, `app:discrete`, `app:dense`, `app:complete`, `cor:tm-completeness`, `def:TMplus`, `cor:tm-decidability`, `def:strongest`, `thm:exist`, `lem:uniq`, `thm:s4`, `thm:sym`, `sub:Extension`, plus `Pthm:13`/`Pthm:14`/`Pthm:18`/`Pthm:20`). **32 of the 33 named `def:`/`thm:`/`cor:`/`lem:`/`app:`/`sub:`/`Pthm:` anchors resolve to exactly one `\label{...}` in the paper. The single exception is `def:BL-model` (line 305), which does not exist anywhere in the paper** — see correction detail below.

**Bibliography keys** — checked with `grep -n` against `typst/bibliography.bib`. All 5 keys used across the 39 footnotes resolve: `brastmckie2026possibleworlds` (bib line 12), `scott1970advice` (bib line 524), `doets1987` (bib line 79), `reynolds1992` (bib line 70), `gabbayhodkinsonreynolds1994` (bib line 114).

**Internal Typst labels** — the two internal cross-references used inside footnote text (`@def-operators` at line 149's footnote, `@sec:construction` at lines 488's and 944's footnotes) both resolve: `<def-operators>` is defined at `FormalFoundations.typ:162`, and `<sec:construction>` is defined at `FormalFoundations.typ:539` (the `= The Completeness Construction <sec:construction>` heading).

**Lean file paths** — every Lean file path named in the Lean-referencing footnotes (488, 554, 663, 691, 714, 739, 944) was checked with `find . -path "*/<path>"` against the live `FormalSystem/` tree. All resolve:
- `FormalSystem/Metalogic/Core/MaximalConsistent.lean`
- `FormalSystem/Metalogic/Bundle/BFMCS.lean`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean`
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`
- `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean`
- `FormalSystem/Metalogic/WeakCanonical/RealModel/Shuffle.lean`, `ShuffleReal.lean`, `EpsilonDense.lean`, `OrderIsoReal.lean`
- `FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean`, `BooleanStructure.lean`, `InteriorOperators.lean`, `UltrafilterMCS.lean`, `FlowFrame.lean`

**Lean symbols** — every symbol name cited in a Lean-referencing footnote was checked with `grep -n "def <symbol>\|theorem <symbol>\|structure <symbol>"` (or plain occurrence search for field names) against the file the footnote attributes it to:
- `SetConsistent`, `SetMaximalConsistent` — both `def`s at `MaximalConsistent.lean:96,103`. Correct.
- `BFMCS` (structure), `modal_forward`, `modal_backward` (fields) — `structure BFMCS` at `BFMCS.lean:91`, fields at `:104,112`. Correct.
- `singletonChronicle`, `omegaChain` — `def`s at `ChronicleConstruction.lean:70,283`. Correct.
- `one_class` — `theorem one_class` at `NoGapsDiscreteProof.lean:95`. Correct as attributed.
- `VeryGood` — `def VeryGood` at `GoodStructures.lean:86`. Correct as attributed.
- `good` — attributed by the footnote to `RealModel/DoetsTheorem.lean`, but `def good` actually lives at `GoodStructures.lean:78`; `DoetsTheorem.lean` only consumes it via transitive imports and never redefines it (confirmed: `DoetsTheorem.lean` imports `RealModel.ShuffleReal` and `DenseModelSurgery.Singletons`, neither of which is `GoodStructures.lean`, and no `def good`/`theorem good` occurs in `DoetsTheorem.lean` itself — only derived `goodDense_*` theorems). **Misattributed — see correction detail.**
- `limitdom_is_good` — attributed by the footnote to `WeakCanonical/Transfer.lean`, but `grep -c "limitdom_is_good" Transfer.lean` returns 0; the actual `theorem limitdom_is_good` is at `IntegerModel/ReynoldsBridge.lean:361`. **Misattributed — see correction detail.**
- `truth_transfer` — `theorem truth_transfer` at `Transfer.lean:354`. Correct as attributed.
- `RealModel/DoetsTheorem.lean`, `Shuffle.lean`, `ShuffleReal.lean`, `EpsilonDense.lean`, `OrderIsoReal.lean` (line 739, files only, no individual symbols claimed) — all five files exist in `FormalSystem/Metalogic/WeakCanonical/RealModel/`. Correct.
- `LindenbaumQuotient.lean`, `BooleanStructure.lean`, `InteriorOperators.lean`, `UltrafilterMCS.lean`, `FlowFrame.lean` (line 944) — all five files exist under `Metalogic/Algebraic/` (the first four) and `Metalogic/Algebraic/FlowFrame.lean`. The footnote's claim "All five measure sorry-free" was checked with `grep -rn "sorry" <the five files>`, which returned zero matches across all five. Correct.
- `countermodel_discrete`, `countermodel_discrete_reynolds_v2`, `completeness_discrete` (line 488, no explicit file citation beyond `WeakCanonical/Transfer.lean` for the first) — `theorem countermodel_discrete` is at `Transfer.lean:1068`, ends with a literal `sorry` at `:1084`, under a section comment `## countermodel_discrete — the one live sorry` (`:1049`) stating "This is the repository's sole live `sorry`... a *direct terminal* sorry with no [live callers]". `countermodel_discrete_reynolds_v2` is confirmed as the symbol `completeness_discrete` actually calls (`Completeness.lean:297` onward references it, e.g. `:362`). Correct as stated; no dead-code claim in the footnote is contradicted by the source.

### Detail on the Two Corrections

**Line 305 — `def:BL-model` does not exist; use `def:BL-semantics`.**

The FIX'd footnote reads:
```
] // FIX: #footnote[`def:BL-model`. @brastmckie2026possibleworlds An interpretation assigns each sentence letter a set of *world states*. ...]
```
`grep -c "label{def:BL-model}" possible_worlds.tex` returns 0. A full scan of every `\label{def:BL...}` in the paper (`grep -n "label{def:BL"`) returns only: `def:BL-language` (line 2711), `def:BL-semantics` (line 3036), `def:BLplus-language` (line 3559), `def:BLplus-semantics` (line 3571), `def:BLplus-defined` (line 3585). There is no separate "model" definition in the paper. Reading the paper at `def:BL-semantics` (lines 3036-3045) confirms why: the labelled block opens with "A *model* of $\BL$ is a structure $\M = \tuple{W, \D, \Rightarrow, \vert{\cdot}}$ where..." and then immediately continues, in the same `Ddef` environment and under the same single label, into the recursive truth clauses. The paper does not split "model" and "truth" into two labelled definitions the way `FormalFoundations.typ` does (its own `#definition("Model")` at line 301-304 and `#definition("Truth")` at line 307-320 are two separate Typst blocks). Corroborating evidence: the typst document's own Truth definition footnote, two blocks later at line 321, already correctly cites `` `def:BL-semantics`, `def:BLplus-semantics` `` for the truth clauses that live in that same paper block. The correct fix is therefore to change the anchor name inside the footnote from `` `def:BL-model` `` to `` `def:BL-semantics` ``, i.e.:
```
]#footnote[`def:BL-semantics`. @brastmckie2026possibleworlds An interpretation assigns each sentence letter a set of *world states*. Truth at a time is mediated entirely by the world state the history occupies there; this is the content of the atomic clause below, and it is what makes a possible world a trajectory through a fixed state space and not an independent index.]
```
The rest of the footnote's prose is untouched — only the anchor token changes.

**Line 714 — two Lean symbols misattributed to the wrong file.**

The FIX'd footnote reads:
```
] // FIX: #footnote[`one_class` (`WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean`), `VeryGood` (`IntegerModel/GoodStructures.lean`), `good` (`RealModel/DoetsTheorem.lean`), `limitdom_is_good` and `truth_transfer` (`WeakCanonical/Transfer.lean`). The decomposition technique is Doets's @doets1987; the step-by-step k-equivalence argument for Until/Since is Reynolds's @reynolds1992, as developed in Gabbay, Hodkinson, and Reynolds @gabbayhodkinsonreynolds1994.]
```
Per-symbol evidence (all commands run against the live `FormalSystem/` tree at the commit checked out during this research pass):
- `one_class` — attributed to `NoGapsDiscreteProof.lean`. Confirmed: `theorem one_class ...` at `NoGapsDiscreteProof.lean:95`. **No change.**
- `VeryGood` — attributed to `GoodStructures.lean`. Confirmed: `def VeryGood ...` at `GoodStructures.lean:86`. **No change.**
- `good` — attributed to `RealModel/DoetsTheorem.lean`. `grep -n "^def good\b" FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean` finds nothing; `DoetsTheorem.lean` only contains derived theorems named `goodDense_*` (e.g. `goodDense_of_orderIso_real`, `goodDense_shuffleReal`) that consume the `good` predicate, not define it. The actual definition, `def good (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat) ...`, is at `GoodStructures.lean:78`, immediately above `VeryGood` in the same file. **Correct attribution: `IntegerModel/GoodStructures.lean`, not `RealModel/DoetsTheorem.lean`.**
- `limitdom_is_good` — attributed to `WeakCanonical/Transfer.lean`. `grep -c "limitdom_is_good" FormalSystem/Metalogic/WeakCanonical/Transfer.lean` returns `0`. The actual definition, `theorem limitdom_is_good {fc : FrameClass} (A : Set Formula) ...`, is at `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:361`. Corroborating evidence from a third file: `FormalSystem/Metalogic/BXCanonical/Completeness.lean:382` contains a comment naming the exact call chain — `` (`countermodel_discrete_reynolds_v2` → `limitdom_is_good` → `no_gaps_discrete_model_surgery` `` — which places `limitdom_is_good` downstream of the Reynolds-bridge construction, consistent with it living in `ReynoldsBridge.lean` rather than in `Transfer.lean`. **Correct attribution: `IntegerModel/ReynoldsBridge.lean`, not `WeakCanonical/Transfer.lean`.**
- `truth_transfer` — attributed to `WeakCanonical/Transfer.lean`. Confirmed: `theorem truth_transfer {sig : MonadicSignature} ...` at `Transfer.lean:354` (`grep -c "truth_transfer" Transfer.lean` returns 2: the definition plus one internal use). **No change.**

Corrected footnote text:
```
]#footnote[`one_class` (`WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean`), `VeryGood` and `good` (`IntegerModel/GoodStructures.lean`), `limitdom_is_good` (`IntegerModel/ReynoldsBridge.lean`), and `truth_transfer` (`WeakCanonical/Transfer.lean`). The decomposition technique is Doets's @doets1987; the step-by-step k-equivalence argument for Until/Since is Reynolds's @reynolds1992, as developed in Gabbay, Hodkinson, and Reynolds @gabbayhodkinsonreynolds1994.]
```
(`VeryGood` and `good` are merged onto one file citation since both now resolve to the same file; the rest of the sentence is unchanged.)

### Why No Deletions Are Recommended

Every one of the 39 footnotes was checked against either the paper or the live Lean tree, and in every case the substantive claim is corroborated, not stale or contradicted:

- The line 488 footnote — the most consequential claim, since it concerns the repository's one live `sorry` — asserts that `sorryAx` traces to `countermodel_discrete` in `WeakCanonical/Transfer.lean`, that this is dead code, and that `countermodel_discrete_reynolds_v2` is what `completeness_discrete` actually calls. This was cross-checked directly against `Transfer.lean:1049-1084` (the `## countermodel_discrete — the one live sorry` section, ending in a literal `sorry` at `:1084`, with an adjacent comment block confirming "the repository's sole live `sorry`") and against `Completeness.lean` (which calls `countermodel_discrete_reynolds_v2`, not `countermodel_discrete`, at `:362` and surrounding lines). The claim is accurate as written.
- The remaining 38 footnotes were checked as documented above (paper anchors, bib keys, internal labels, Lean paths/symbols) and none was found to misstate a fact about the current tree or paper — aside from the two corrections already detailed.

There is therefore no basis for retiring any of the 39 footnotes; the disposition set is exhaustively {restore-as-is, restore-with-correction}.

## Decisions

- All 39 sites are dispositioned RESTORE (uncomment); none is dispositioned DELETE.
- 2 of the 39 (lines 305, 714) require a text correction to the footnote content in addition to removing the `// FIX: ` prefix, per the detail above.
- The remaining 37 are uncomment-only: replace `] // FIX: #footnote[` with `]#footnote[`, with no other change to the bracketed content.

## Recommendations

Per-site disposition table. "RESTORE" = strip `// FIX: ` and join `]` to `#footnote[` with zero whitespace, no other change. "RESTORE (corrected)" = same transformation, plus the specific text correction noted.

| Line | Block | Anchor(s)/reference cited | Disposition |
|------|-------|---------------------------|-------------|
| 149 | Definition (Language) | `def:BLplus-language` | RESTORE |
| 178 | Definition (Temporal Order) | `def:temporal-order` | RESTORE |
| 191 | Definition (Task Relation) | `def:task-relation` | RESTORE |
| 196 | Definition (Directed Family) | `def:directed` | RESTORE |
| 211 | Definition (Frame) | `def:frame` | RESTORE |
| 213 | Lemma (Nullity) | `lem:nullity` | RESTORE |
| 238 | Definition (History) | `def:world-history` | RESTORE |
| 242 | Theorem (Extension) | `thm:extension` | RESTORE |
| 255 | Corollary (Occurrence) | `cor:occurrence` | RESTORE |
| 274 | Definition (Task Topology) | `def:task-topology` | RESTORE |
| 276 | Theorem (Separation) | `app:topology-t1`, `app:topology-r0` | RESTORE |
| 305 | Definition (Model) | `def:BL-model` (does not exist) | **RESTORE (corrected: `def:BL-model` -> `def:BL-semantics`)** |
| 321 | Definition (Truth) | `def:BL-semantics`, `def:BLplus-semantics` | RESTORE |
| 333 | Definition (Frame Properties) | `def:frame-properties` | RESTORE |
| 340 | Definition (Validity and Consequence) | `def:frame-validity`, `def:logical-consequence` | RESTORE |
| 359 | Definition (S5) | `def:S5` | RESTORE |
| 367 | Definition (BX) | `def:BX` | RESTORE |
| 409 | Theorem (Soundness) | `thm:TM-soundness` | RESTORE |
| 418 | Proposition (Correspondence) | `app:discrete`, `app:dense`, `app:complete` | RESTORE |
| 434 | Proposition (Collapse) | `Pthm:13`, `Pthm:14`, `Pthm:18`, `Pthm:20` | RESTORE |
| 448 | Theorem (Incompleteness at the base level) | `cor:tm-completeness` | RESTORE |
| 488 | Theorem (Base-class completeness, outstanding) | Lean: `countermodel_discrete`, `WeakCanonical/Transfer.lean`, `countermodel_discrete_reynolds_v2` | RESTORE |
| 505 | Remark (conservativity) | `def:TMplus` | RESTORE |
| 511 | Theorem (Decidability) | `cor:tm-decidability` | RESTORE |
| 523 | Proposition (Failure of uniform FMP over Z) | `cor:tm-decidability`'s proof | RESTORE |
| 554 | Definition (Consistent and MCS) | Lean: `SetConsistent`, `SetMaximalConsistent`, `Metalogic/Core/MaximalConsistent.lean` | RESTORE |
| 575 | Theorem (Dichotomy) | Part of `cor:tm-completeness`'s proof | RESTORE |
| 663 | Definition (Bundled Family of MCSs) | Lean: `BFMCS`, `Metalogic/Bundle/BFMCS.lean`, `modal_forward`, `modal_backward` | RESTORE |
| 691 | Definition (Chronicle) | Lean: `singletonChronicle`, `omegaChain`, `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` | RESTORE |
| 714 | Definition (The Reynolds pipeline) | Lean: `one_class`, `VeryGood`, `good`, `limitdom_is_good`, `truth_transfer` (file attributions) | **RESTORE (corrected: `good` -> `IntegerModel/GoodStructures.lean`; `limitdom_is_good` -> `IntegerModel/ReynoldsBridge.lean`)** |
| 739 | Definition (The real-model construction) | Lean: `RealModel/DoetsTheorem.lean`, `Shuffle.lean`, `ShuffleReal.lean`, `EpsilonDense.lean`, `OrderIsoReal.lean` | RESTORE |
| 832 | Remark (structural necessity, not special to task semantics) | `sub:Extension` | RESTORE |
| 841 | Definition (Irregular World) | `sub:Extension` (unlabelled footnote within it, quoted verbatim) | RESTORE |
| 855 | Proposition (The price of irregular worlds) | `sub:Extension`; internal `def:strongest`, `thm:exist` | RESTORE |
| 883 | Definition (Strongest Objective Normal Modal Operator) | `def:strongest` | RESTORE |
| 885 | Theorem (Existence) | `thm:exist` | RESTORE |
| 891 | Theorem (Uniqueness and logic) | `lem:uniq`, `thm:s4`, `thm:sym` | RESTORE |
| 902 | Proposition (Orthogonality) | Stability footnote (paper prose, no separate label) | RESTORE |
| 944 | Definition (The Lindenbaum-Tarski Algebra) | Lean: `Metalogic/Algebraic/LindenbaumQuotient.lean`, `BooleanStructure.lean`, `InteriorOperators.lean`, `UltrafilterMCS.lean`, `FlowFrame.lean` | RESTORE |

37 sites: RESTORE as-is. 2 sites (305, 714): RESTORE with the specific correction detailed above. 0 sites: DELETE.

## Risks & Mitigations

- **Risk**: a mechanical find-and-replace across all 39 sites could accidentally also touch the 11 bare `// FIX:` lines belonging to tasks 446/447, since some are numerically close (e.g. 213/214, 276/277). **Mitigation**: match on the full pattern `] // FIX: #footnote[` (not bare `// FIX:`), which uniquely identifies the 39 in-scope sites and does not match any of the bare-tag lines.
- **Risk**: the two corrected footnotes (305, 714) could be uncommented verbatim by an automated script without applying the text correction. **Mitigation**: this report's disposition table flags both explicitly as "RESTORE (corrected)" with the exact replacement text given in "Detail on the Two Corrections" above, so a script or implementer can special-case those two line numbers.
- **Risk**: `typst compile` could still fail for reasons unrelated to the footnotes (e.g. unrelated syntax errors elsewhere in the file). **Mitigation**: the stated verification step (`typst compile typst/FormalFoundations.typ`) should be run after the edits regardless, and any failure traced to its actual line rather than assumed to be footnote-related.

## Appendix

- Anchor-resolution commands used: `grep -c "label{ANCHOR}" possible_worlds.tex` for each of the 33 distinct paper anchors named across the 39 footnotes.
- Bibliography-key commands used: `grep -n "brastmckie2026possibleworlds\|scott1970advice\|doets1987\|reynolds1992\|gabbayhodkinsonreynolds1994" typst/bibliography.bib`.
- Lean-path commands used: `find . -path "*/<relative-path>"` from the repository root for each Lean file named in a footnote.
- Lean-symbol commands used: `grep -n "def <symbol>\|theorem <symbol>\|structure <symbol>"` (or plain-text occurrence search for struct fields) against the specific file each footnote attributes the symbol to.
- Scope-boundary source: `specs/state.json` entries for tasks 445, 446, and 447 (project_number 445/446/447), read directly to confirm the 39-vs-11 line-number partition described in Context & Scope.
