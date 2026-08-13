// ============================================================================
// p4-dual-verification.typ
// Part II chapter -- Dual Verification and Worked Examples
// Worked examples drawn verbatim (with adapted wrapper prose) from the
// sorry-free Examples/ directory.
// ============================================================================

#import "../template.typ": *

= Dual Verification and Worked Examples

#chapter-header(
  description: [The dual-verification architecture (proof certificates vs. countermodel search) framing this book's worked material, plus curated derivations from the sorry-free `Examples/` library rendered dual-track.],
  dependencies: [Chapters 3--5 (proof theory, metalogic, theorems); Part II's frame-classes and decidability chapters for the semantic side.],
)


== Dual Verification

"Together with ProofChecker, [ModelChecker] forms the dual verification architecture: ModelChecker searches for countermodels while ProofChecker constructs formal derivations."#footnote[`README.md:183`.]
Adapting the Logos manual's framing:#footnote[Logos `01-introduction.typ`, "Dual Verification" section (external repository, commit-pinned by citation; not a local Lean name).]

#items[
  #item[*Proof certificates* -- a kernel-checked `DerivationTree` term is a machine-verifiable witness explaining *why* a formula is a theorem, not merely *that* it is one. Every `valid` result from `decide` (@sec:decidability-practice) carries one.]
  #item[*Counterexamples* -- an explicit `SimpleCountermodel` (or the richer `SemanticCountermodel`) gives targeted corrective feedback: not merely that an inference fails, but which atoms make it fail.]
  #item[*Soundness guarantees* -- soundness (proven for `TM`, all four frame classes: Base, Dense, Discrete, Dedekind) is what makes a proof certificate reliable independent of the search procedure that found it: if the kernel accepts a `DerivationTree`, the corresponding formula is genuinely valid.]
]

In this repository, the lean-verified instance of this architecture is the decision procedure of @sec:decidability-practice (`decide_sound` proven, countermodels extracted from open tableau branches); the cross-project vision above remains architectural only, where ModelChecker's independent Z3-based search would corroborate ProofChecker's Lean-checked derivations for the same formula.

== The Workflow, End to End

The dual-verification loop for a candidate formula $phi.alt$ has a single entry point and two exits.

+ *Pose.* Formulate the conjecture as a `Formula` term -- say the P1 pattern $square.stroked p arrow.r triangle.stroked.t p$ or its converse $triangle.stroked.t p arrow.r square.stroked p$.
+ *Decide.* Run `decide` (or, inside a proof, attempt `tm_auto`/`modal_search`). The procedure tries the fast paths first -- direct axiom match, bounded proof search -- and falls back to the tableau.
+ *Exit valid.* The result carries a `DerivationTree` proof term. Lean's kernel re-checks the term independently of the search that found it, so acceptance does not depend on trusting the decision procedure -- this is the content of `decide_sound`.
+ *Exit invalid.* The result carries a `SimpleCountermodel` naming the atom assignment that breaks the formula, extracted from an open saturated tableau branch. The countermodel is a checkable artifact in its own right: evaluating the formula under the reported assignment reproduces the failure.

The two conjectures above illustrate the exits.
The P1 pattern closes as a theorem (`perpetuity_1`, below).
Its converse fails, and the shape of the failure is instructive: a formula can hold at every time along one history while failing on another history through a different world state, so "always" does not imply "necessarily" -- the semantic content of the countermodel any run on the converse pattern produces.
Each exit hands downstream consumers a certificate of the corresponding kind, which is precisely the dual-signal contract the dataset pipeline of @sec:dataset-pipeline packages at scale.

== Worked Examples: Perpetuity in Practice

`Examples/BimodalProofs.lean` (241 lines, sorry-free) demonstrates the perpetuity principles (@sec:notes) as concrete, checked derivations rather than abstract statements.

#example("P1 Applied to an Atom")[
  `⊢ φ.box.imp φ.always := perpetuity_1 φ`#footnote[`Examples/BimodalProofs.lean:52`.] instantiates immediately to any formula; concretely, for an atom: `⊢ (Formula.atomS "p").box.imp (△(Formula.atomS "p")) := perpetuity_1 _`#footnote[`Examples/BimodalProofs.lean:61`.] -- necessity of $p$ implies $p$ holds always, both notations (`.always` and $triangle.stroked.t$) proven definitionally equal.
]

#example("P5: Persistent Possibility")[
  `⊢ φ.sometimes.diamond.imp φ.diamond.always := perpetuity5 φ`#footnote[`Examples/BimodalProofs.lean:124` (`noncomputable`, since the underlying modal-collapse argument is classical).] -- if $φ$ is possibly true at some time, then it is always possible that $φ$ -- the most semantically rich of the six perpetuity principles, connecting temporal existence with modal persistence.
]

#example("Automated S5 Derivations via `modal_search`")[
  The T and 4 axioms, proven automatically rather than by direct axiom application:
  ```
  example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") := by modal_search
  example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p").box.box := by modal_search
  ```
  #footnote[`Examples/BimodalProofs.lean:211-217`; the proof-automation engine of @sec:proof-automation closes both goals within its default search depth.]
  A capstone combined example in the same file (`Examples/BimodalProofs.lean:223`) shows $square.stroked$ distributing over the derived always-future operator, $square.stroked φ arrow.r square.stroked (G φ)$#footnote[Via `allFuture`; note a commented-out BX1/reflexivity test at `Examples/BimodalProofs.lean:219` documents that the T-axiom-style test for the *temporal* operator was intentionally disabled under the strict/irreflexive semantics convention (@sec:design-choices) -- reflexive temporal T-axioms are not valid here.], proven the same way.
]

== Worked Examples: Concrete Temporal Structures

`Examples/TemporalStructures.lean` (277 lines, sorry-free) instantiates the abstract task-frame semantics of @sec:truth over concrete duration types.
The file concretely instantiates the *discrete* case -- `intTimeFrame` (`Examples/TemporalStructures.lean:65`) and `intNatFrame` (`Examples/TemporalStructures.lean:78`) over `Int` -- alongside a fully polymorphic `genericTimeFrame` (`Examples/TemporalStructures.lean:144`) and `genericNatFrame` (`Examples/TemporalStructures.lean:156`), generic over any ordered abelian group `D`; a concrete dense ($QQ$/$RR$) instantiation requires additional Mathlib imports and is not included.
Sanity-check lemmas (`Examples/TemporalStructures.lean:217` and `Examples/TemporalStructures.lean:222`) confirm the generic frame specializes correctly to the concrete `Int` frame by `rfl`; `int_nullity_example` (`Examples/TemporalStructures.lean:229`) / `generic_nullity_example` (`Examples/TemporalStructures.lean:235`) and `int_compositionality_example` (`Examples/TemporalStructures.lean:242`) / `generic_compositionality` (`Examples/TemporalStructures.lean:257`) exercise the two task-frame axioms of @sec:truth concretely.

== Reproducibility Note

Every derivation cited in this chapter is sorry-free and can be re-checked by compiling `FormalSystem/Examples/BimodalProofs.lean` and `TemporalStructures.lean` directly; no external tooling (ModelChecker, Z3) is required for the worked examples above.
