# Teammate C Findings (Critic): Gaps, Shortcomings, and Blind Spots in the Book-Design Ambition

**Task**: 313 - Design the full extent of the BimodalReference book
**Role**: Critic — research-quality and completeness audit of the design premise
**Date**: 2026-07-06 (Lean ground truth: commit `a883361bf`)

## Key Findings

### F1. "Vlach operators" are paper-only; the Lean language is Until/Since. The proposed framing misdescribes the formalization.

The task description proposes presenting the system as "vanilla LTL + S5 modal operators +
Vlach operators". None of the three components of that framing survives contact with the
sources:

1. **No Vlach operators exist anywhere in the Lean codebase.** `grep -rn "Vlach"` over
   `Theories/` returns zero hits. The `Formula` inductive
   (`Theories/Bimodal/Syntax/Formula.lean:70-85`) has exactly six constructors: `atom`,
   `bot`, `imp`, `box`, `untl`, `snce` (Burgess-convention Until/Since). Vlach-style
   indexed store/recall operators appear only in the *possible worlds paper's* Extensions
   subsection (`possible_worlds.tex:1254`, §3.3), which task 312's SYNC-MAP explicitly
   scoped OUT as "not formalized" (SYNC-MAP.md, D4).
2. **TM is not "vanilla LTL + S5".** LTL is future-only over ℕ; TM's temporal fragment is
   past+future Until/Since over general linear orders (ℤ discrete, ℚ dense, via
   frame-class parametrization). More importantly, TM is not a fusion or product: it has a
   modal-temporal *interaction* layer (`modal_future` MF, layer 4 of the 42-constructor
   axiom inventory) and 5 uniformity axioms (layer 5) tied to the task-frame semantics
   (SYNC-MAP.md, Ground-Truth Counts). The interaction axioms are load-bearing
   (perpetuity principles). A "vanilla LTL + S5" pitch invites the reader to expect
   PTL×S5 — which is a *different, weaker* logic.
3. **The PTL×S5 identification belongs to the Lk paper's L₁, not to TM.** The Lk abstract
   (`Lk/sections/00-abstract.tex`) identifies its one-register logic L₁ with PTL×S5 over
   *sets of discrete future-only traces* — a different semantics (trace sets, not task
   frames), a different time order (ℕ, not ℤ/ℚ), and no past operators. Importing Lk
   framing into BimodalReference without flagging these differences would conflate two
   distinct systems that merely share an ancestor.

**Consequence for the design**: the "LTL + S5 + Vlach" chapter can only be honest as a
*positioning* chapter ("TM in the landscape of temporal-modal logics, and the store/recall
extension it anticipates"), not as a description of the formalized system.

### F2. The "derive metaphysical modality from tensed counterfactuals" claim exists — but only as one definitional line in an unformalized paper.

The claim *is* carried out on paper: `counterfactual_worlds.tex:1012-1014` discusses and
then adopts the definition □A ≔ ⊤ □→ A ("define metaphysical necessity as ⊤ boxright A" in
the language L^CML), and the paper gives a task-semantics soundness appendix
(§Appendix/Soundness, line 1847). However:

- **Nothing of this is formalized.** BimodalLogic's Lean has no counterfactual operator,
  no state mereology (no parthood), and no imposition/outcome machinery. The Logos
  project's Lean (`~/Projects/Logos/Theory/`) exists but `LogosManual.typ` is a 197-line
  overview document, not a reference manual with formalized-content backing; the
  counterfactual semantics is implemented in the *ModelChecker* (Python) per the paper's
  own abstract ("implemented in the \modelchecker software").
- **The bridge is real but nontrivial.** The counterfactual paper constructs worlds from
  states + parthood + tasks + times (its abstract), whereas the Lean `TaskFrame`
  (`Semantics/TaskFrame.lean:93-104`) has *structureless* `WorldState` with a
  duration-indexed `task_rel`. "Adding constitutive structure" means adding a mereology on
  states and redefining world histories — a semantic *replacement* at the base level, not
  a conservative chapter-sized extension. The proposed "next chapter" is really a
  next-*volume*-sized research program, and presenting it as a chapter of a reference
  manual will re-create exactly the doc-vs-code divergence task 312 just eliminated.
- **Completeness for the counterfactual logic is not claimed even on paper** (soundness
  only, `counterfactual_worlds.tex` §Soundness); "yielding tensed counterfactual logic
  from which metaphysical modality can be derived" is a semantic definition plus a
  soundness result, not a derivation theorem with metatheory.

### F3. Coherence risk: the design reverses scope decisions made one commit ago, and the drift-prevention mechanism (SYNC-MAP) has no category for what the design wants to add.

Task 312 (commit `a883361bf`, same day) synchronized BimodalReference.typ to the Lean
source and recorded explicit scope decisions in `Theories/Bimodal/typst/SYNC-MAP.md`:

- D4: "Paper's Objective Modality and 2D Semantics: out of scope (not formalized)".
- D4: "Paper §3.3 Extensions [the Vlach/store-recall material]: documented only where
  Lean-formalized ... otherwise a one-line 'not yet formalized' note".
- D4: Kamp/tasks 303/309-311 material "appears only as short 'work in progress, not
  citable' notes".

The task-313 ambition re-introduces, at chapter scale, precisely the material 312 scoped
down to one-line notes. That is not necessarily wrong — but the current SYNC-MAP verifies
*claims about Lean source*, and has no machinery for verifying or even bounding
*prospective* content. Without a new discipline (see Recommended Approach), every
paper-sourced chapter is unmonitored drift by construction. The failure mode is concrete:
the pre-312 typst doc described a *deleted architecture* (`semantic_weak_completeness`,
`FMP/`, `Representation/` — SYNC-MAP D1 resolution note) because prose outlived code.
A 3x-larger book tracking two papers, an anonymous submission, and a second project's
roadmap multiplies that failure surface while the Lean target is actively moving
(tasks 303/309-311 in flight on the discrete/Kamp path).

### F4. The decidability story is weaker than the book design assumes; honest claims require careful wording the design brief does not yet have.

Checked facts (all at `a883361bf`):

- `Metalogic/Decidability/` is sorry-free at file level (0 grep hits; README claims
  sorry-free per module), **but** the headline theorems are much weaker than their names:
  - `validity_decidable` (`Decidability/Correctness.lean:72-75`) is literally
    `Classical.em (⊨ φ)` — a tautology with zero computational or decision-theoretic
    content. Same for `validity_has_decision_procedure` (`:82`, classical `by_cases`).
  - There is no `Decidable (valid φ)` instance and no verified termination: `decide`
    (`DecisionProcedure.lean:122`) is fuel-based with a `timeout` branch.
  - Tableau *soundness* is proven (`decide_sound`); tableau *completeness* rests on the
    FMP development, and `fmp_completeness` (`Correctness.lean:123`) is stated relative
    to "truth in all closure MCS bundles", not semantic validity — the semantic link runs
    through the sorry-tainted completeness chain.
  - The book's own `06-notes.typ:96-100` already states this honestly ("FMP ... still in
    progress"). Any new "decidable fragments for automated reasoning" chapter must
    inherit this honesty; the design brief currently reads as if decidability were a
    settled asset to *present*, when it is a program to *report on*.
- **Sorry inventory**: the book's stamped claim of "43 genuine sorries" on the
  completeness path (`06-notes.typ:91`, stamped commit `a883361bf`) is consistent with
  SYNC-MAP methodology, but counting method matters: a strict bare-`sorry`-line grep
  outside `Boneyard/` gives 38; a looser pattern gives ~53 (includes comment mentions).
  Any number printed in a book is stale at the next commit. A larger book with *more*
  status-bearing chapters needs a scripted, single-source-of-truth count (regenerated at
  build time or stamped per SYNC-MAP protocol "do not copy forward"), or it should avoid
  raw counts in favor of structural statements ("the dense chronicle construction and
  discrete transfer each carry open obligations; see SYNC-MAP").

### F5. Publication-status and text-reuse questions are unasked and are the most likely source of real-world trouble.

- **Lk is a double-blind submission.** `Lk/main.tex:22-29` is an *anonymous* TACAS 2027
  submission ("Anonymous Author(s)", `llncs` runningheads). Publishing its framing,
  results, or case study in a publicly hosted, author-attributed reference book before
  the review cycle completes risks deanonymization. At minimum, the Lk-derived
  decidability chapter must be embargoed or abstracted beyond recognition until
  acceptance.
- **possible_worlds.tex is a live JPL submission** (submission zip + cover letter in the
  directory). Verbatim reuse of its text in the book raises prior-publication and
  self-plagiarism questions during review; Springer's policies on preprint-like
  disclosures vary and have not been checked by anyone in this task.
- **Counterfactual Worlds is published** (J. Phil. Logic 2025, per
  `LogosManual.typ:126`). Springer copyright transfer likely constrains verbatim reuse;
  paraphrase + citation is safe, transplanted sections are not (unverified — flagged as
  an open question, not a conclusion).
- **Audience is undefined.** The current book is a *reference manual for the Lean
  formalization* (its intro sells an RL-training rationale in one sentence,
  `00-introduction.typ:12`). The proposed additions serve at least four audiences
  (Lean users; temporal-logic researchers; AI-training practitioners; philosophers
  interested in the Logos program) with conflicting genre expectations. No teammate was
  asked to determine who the book is *for*, yet every scope decision downstream depends
  on it.
- **Single-source-of-truth conflict with LogosManual.** A Logos-roadmap chapter in
  BimodalReference duplicates the role of `LogosManual.typ`. Two documents describing the
  same roadmap in two repositories will diverge; the design should name one owner and
  have the other link.

### F6. The AI-training-contrast content has no source material.

"Decidable fragments for automated reasoning vs training AI to reason proof-theoretically
and solve constraint systems" appears in no examined artifact beyond a single sentence in
`00-introduction.typ:12`. Unlike every other proposed chapter, there is no paper, no Lean
directory, and no spec to sync against — it would be newly authored essay content with a
different epistemic status (opinion/vision) embedded in a reference manual whose
credibility rests on verified claims. If included, it must be typed as such (a clearly
marked outlook chapter), and someone must actually write it from scratch — the effort
estimate for the book should not treat it as "synthesis of existing material".

## Recommended Approach

1. **Two-part architecture with per-chapter sync contracts.** Part I: the existing
   synced reference (chapters 00-06), governed by SYNC-MAP as today. Part II:
   "Perspectives and Program" — positioning (TM vs LTL/S5 products vs hyperlogics),
   decidability program, store/recall (Vlach) extension, constitutive/counterfactual
   roadmap, Logos milestone framing. Extend SYNC-MAP with a per-chapter header field:
   `sync-class: lean-verified | paper-sourced(<paper>, <status>) | outlook`, and make the
   verification pass check that no `lean-verified` claim appears in Part II chapters and
   no unstamped Lean claim appears anywhere.
2. **Resolve the framing honestly**: present TM as "Until/Since temporal logic over
   linear orders, fused with S5 and interaction axioms over task frames", with the
   LTL+S5+Vlach story as the *extension roadmap* (paper §3.3 + Lk lineage), explicitly
   marked unformalized.
3. **Gate the Lk-derived chapter on publication status** (embargo until TACAS decision or
   write it at a level of abstraction that cites no Lk-specific results).
4. **Counterfactual chapter as a bounded "bridge" chapter**, limited to: (a) the
   task-relation commonality between `TaskFrame` and the paper's task space, (b) the
   □A ≔ ⊤ □→ A definition as the derivation claim, cited to the published paper, (c) an
   explicit statement that none of it is in this repository's Lean. Defer full treatment
   to LogosManual/Logos volume; add a cross-link rather than a parallel exposition.
5. **Script the status claims**: one generator producing sorry counts (fixed grep
   pattern, `Boneyard/` excluded), axiom/rule counts, and completeness wiring facts,
   stamped with commit hash — consumed by both SYNC-MAP and the typst build. Never
   hand-copy numbers into prose.
6. **Ask the unasked questions before planning**: intended audience(s); text-reuse policy
   per paper (published/under review/double-blind); ownership split vs LogosManual;
   cadence for re-syncing Part I against a moving Lean target (tasks 303/309-311 will
   invalidate stamped claims soon).

## Evidence/Examples

| Claim checked | Verdict | Citation |
|---|---|---|
| Lean implements Vlach operators | **False** — Until/Since only | `Syntax/Formula.lean:70-85`; zero `Vlach` hits in `Theories/` |
| Vlach store/recall exists in sources | Paper-only, Extensions section | `possible_worlds.tex:1254` (§3.3, indexed ⟨store,recall⟩ for times and worlds) |
| TM = vanilla LTL + S5 | **Misleading** — interaction + uniformity layers; past operators; ℤ/ℚ time | SYNC-MAP.md axiom table (42 constructors, layers 4-5); `Formula.lean` |
| PTL×S5 identification | Belongs to Lk's L₁ over trace sets, not TM | `Lk/sections/00-abstract.tex` |
| Lk safe to source publicly | **At risk** — anonymous TACAS 2027 double-blind submission | `Lk/main.tex:22-29` |
| □ derived from counterfactuals is "carried out" | On paper only: □A ≔ ⊤ □→ A, soundness only, no Lean | `counterfactual_worlds.tex:1012-1014`, §Soundness (line 1847) |
| Counterfactual Worlds publication status | Published, JPL 2025 | `LogosManual.typ:126` |
| Completeness sorry-free | **No** — wired end-to-end but sorry-tainted | SYNC-MAP.md D1; `06-notes.typ:89-93` |
| "43 sorries" robust | Method-dependent: 38 (bare-line) / 43 (book's stamped count) / ~53 (loose) | greps at `a883361bf`; `06-notes.typ:91` |
| Decidability verified | Soundness only; `validity_decidable` is `Classical.em`; fuel-based, no `Decidable` instance | `Decidability/Correctness.lean:72-95`, `DecisionProcedure.lean:122`, `06-notes.typ:96-100` |
| Decidability dir sorry-free (file level) | True (0 hits), but semantic completeness link runs through sorry-tainted chain | grep; `Correctness.lean:123` (`fmp_completeness` stated over closure MCS, not validity) |
| LogosManual as mature companion | Thin: 197 lines, overview + links | `Logos/Theory/typst/manual/LogosManual.typ` |
| AI-training contrast has source material | No — one sentence | `00-introduction.typ:12` |

## Confidence Level

- **High**: F1 (operator inventory), F4 (decidability theorem contents — read directly),
  F3 (SYNC-MAP scope reversals), Lk anonymity, □-from-counterfactual location.
- **Medium**: F5 text-reuse/copyright implications (policies not verified against
  publisher terms — flagged as open questions); exact sorry-count reconciliation
  (38 vs 43 vs 53 — methodology difference identified but the book's 43 was not
  re-derived step-for-step); Logos Lean maturity (directory inspected shallowly).
- **Low**: none of the findings rest on low-confidence claims; where evidence was thin
  the finding is phrased as a question to ask, not a conclusion.
