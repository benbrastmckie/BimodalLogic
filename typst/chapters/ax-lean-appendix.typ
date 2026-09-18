// ============================================================================
// ax-lean-appendix.typ
// Back-matter appendix -- Reading the Lean Formalization
//
// A from-basics Lean 4 primer, scoped to exactly what a reader needs in order
// to go from a formal claim cited in this book to the live declaration under
// FormalSystem/ that backs it. Every Lean identifier cited here names a live
// (non-Boneyard) declaration; every snippet is either a byte-exact #leansrc
// excerpt or a didactic example, both verified against the current toolchain
// in specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean
// before being written here. See ../SYNC-MAP.md for the dated entry.
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count, rule-count, sorry-total-excl-boneyard

#pagebreak()
#heading(numbering: none)[Appendix: Reading the Lean Formalization] <lean-appendix>

This appendix is a self-contained primer on Lean 4, aimed at a reader who knows the mathematics of *TM* from Parts I and II but has never opened a Lean file.
It builds up from what Lean is to reading `FormalSystem/` itself: the type theory that lets a proof assistant check mathematics by computation, how that theory represents the specific objects this book cites (`Formula`, `DerivationTree`, `Derivable`), the proof styles the codebase uses, the project's naming and file-layout conventions, and finally a worked guide to locating and trust-reading the declarations behind the book's soundness and completeness claims.
Nine sections carry this arc, each self-contained enough to skip to directly from a citation elsewhere in the book.

== What Lean Is <lean-appendix-what-is-lean>

Lean 4 is a dependently typed functional programming language that doubles as an interactive proof assistant: the same expression language that defines ordinary data (numbers, lists, formulas) also states and proves theorems, because -- as @lean-appendix-props-as-types below makes precise -- a proof, in this system, *is* a piece of data of a particular type.
A small trusted kernel type-checks every proof term against the theorem's stated type; everything else in the system, including the tactic framework that writes most proofs in practice, is untrusted elaboration machinery that merely has to produce a term the kernel accepts.
This is what makes machine checking meaningful: the book's formal claims are not merely *stated* in a Lean-flavored notation, they are *type-checked* by that kernel against their declared types, and a claim that type-checks cannot be an unnoticed transcription error the way a claim in ordinary prose can be.

Mathlib is the community mathematical library the project builds on (`lakefile.toml` pins a specific tagged revision -- @lean-appendix-lake below).
`FormalSystem/` does not reprove general mathematics that Mathlib already has (orders, groups, `Nat`, `Finset`): it imports what it needs and formalizes only what is specific to *TM* -- the formula language, the proof system, task-frame semantics, and the metalogic connecting them.
This is why the book pairs its formal claims with Lean identifiers rather than restating them: `soundness`, `completeness`, and every axiom and rule constructor are declarations a reader can open, inspect, and -- following @lean-appendix-reading-source -- check the kernel's own trust report on.

== Types, Props, and Dependent Types <lean-appendix-types-props>

Every Lean expression has a type, and types themselves are classified into two universes that matter for reading this codebase: `Type`, the universe of data, and `Prop`, the universe of propositions.
`Formula` lives in `Type`: a formula is a piece of data you can pattern-match on, print, and compute with.
A statement like `1 + 1 = 2` or `Valid φ` lives in `Prop`: propositions are also types (their inhabitants are proofs), but Lean treats `Prop` specially -- any two proofs of the same proposition are considered equal (*proof irrelevance*), because a proof's only job is to witness that its proposition holds, not to carry further information.

`FormalSystem/` puts both universes to work side by side on the *same* underlying idea, and the contrast is instructive.
`DerivationTree fc Γ φ` (@lean-appendix-inductive) is declared in `Type`, not `Prop`, precisely because its *proof objects* carry information the codebase needs to compute with: a derivation's height, its case structure for induction in the metalogic, its shape for the decision procedure.
`Derivable fc Γ φ` (`FormalSystem.ProofSystem.Derivable`) is the `Prop`-valued twin of the same idea, defined as `Nonempty (DerivationTree fc Γ φ)`: it asserts *that* a derivation exists without retaining *which* one, which is exactly what `simp` and `aesop`-style automation need, since they work with propositional goals and do not care which proof term eventually closes them.

#leansrc("FormalSystem.ProofSystem", "Derivable")
```
def Derivable (fc : FrameClass) (G : Context) (p : Formula) : Prop :=
  Nonempty (DerivationTree fc G p)
```

`DerivationTree` is also an example of a *dependent* type: its very type, `FrameClass → Context → Formula → Type`, takes ordinary *values* (a frame class, a context, a formula) as arguments, and the resulting type genuinely depends on which values were supplied -- `DerivationTree .Dense [] φ` and `DerivationTree .Base [] φ` are different types, not the same type decorated with different labels, because a value of the first type may use the density axiom and a value of the second may not.
This is what lets the `fc` parameter enforce frame-class validity *structurally*: the `axiom` constructor's side condition `h.minFrameClass ≤ fc` (below) is a hypothesis inside the type, so a `DerivationTree fc` value simply cannot have been built from an incompatible axiom -- there is no separate validity check to run after the fact, because an ill-typed derivation cannot be constructed at all.

== Propositions as Types and Proof Terms <lean-appendix-props-as-types>

The Curry-Howard correspondence reads a proposition as a type and a proof as a value (a *term*) of that type: proving `A → B` means writing a function from proofs of `A` to proofs of `B`, and proving `A ∧ B` means producing a pair of proofs.
`FormalSystem/` puts this reading to work at two levels at once. At the meta level, an ordinary Lean `theorem` such as `soundness` (@lean-appendix-reading-source) is itself a proof term whose type is the stated implication, checked by the kernel exactly as sketched in @lean-appendix-what-is-lean.
At the *object* level -- the level the book's own axiomatization operates at -- `DerivationTree fc Γ φ` reifies the same correspondence for *TM* itself: a term of this type is not a meta-level Lean proof of some Lean proposition, it is data encoding a derivation of `φ` from `Γ` in the object system, built from the same constructors *TM*'s Hilbert-style calculus specifies (axiom instances, modus ponens, the two necessitation rules, time reflection, weakening -- @lean-appendix-inductive lists all seven).

A term-mode proof simply writes down such a value directly, with no tactic block. The modal T axiom instance `⊢ □p → p` is:

```
def boxPImpP : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") :=
  DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atomS "p")) trivial
```

`DerivationTree.axiom` takes the context, the formula, an `Axiom` witness, and a proof that the axiom's `minFrameClass` is compatible with the ambient frame class; for `Axiom.modal_t`, that minimum is `FrameClass.Base` (the dependent-type discussion above's `h.minFrameClass ≤ fc` gate), so at `fc = .Base` the side condition is discharged by `trivial`.
Derivations compose the way proof terms always do -- by applying one term to another. Given a hypothetical derivation `dBoxP : ⊢ □p`, `DerivationTree.modus_ponens` combines it with `boxPImpP` to build a derivation of `⊢ p`:

```
example (dBoxP : ⊢ (Formula.atomS "p").box) : ⊢ (Formula.atomS "p") :=
  DerivationTree.modus_ponens [] (Formula.atomS "p").box (Formula.atomS "p") boxPImpP dBoxP
```

@lean-appendix-tactics contrasts this term-mode style with the tactic-mode proof of the same fact.

== Inductive Types: `Formula` and `DerivationTree` <lean-appendix-inductive>

An inductive type is defined by an exhaustive list of constructors, each specifying how to build a value of the type (possibly from other values of the same type, which is what makes recursion and structural induction available for free).
`Formula` (@sec:formulas) is the running example throughout this book, and it is declared with exactly the six primitive constructors the syntax chapter states:

#leansrc("FormalSystem.Syntax", "Formula")
```
inductive Formula : Type where
  | atom : Atom → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | untl : Formula → Formula → Formula
  | snce : Formula → Formula → Formula
  deriving Repr, DecidableEq, BEq, Hashable, Countable
```

Every other connective in the book is a `def` layered over these six, never a further constructor -- `neg`, `and`, `or`, `diamond`, `allFuture`, `allPast`, `someFuture`, `somePast`, `always`, `sometimes`, and the rest are ordinary functions computing a `Formula` from `Formula` arguments. The two temporal operators the book emphasizes are typical:

#leansrc("FormalSystem.Syntax", "Formula.always")
```
def always (φ : Formula) : Formula := φ.allPast.and (φ.and φ.allFuture)
def sometimes (φ : Formula) : Formula := φ.neg.always.neg
```

`DerivationTree fc Γ φ` (@sec:proof-theory) is the second running example: an inductive *family*, indexed by frame class, context, and formula, with #rule-count constructors -- one per inference rule of the Burgess-Xu system.
Its constructor names are the rule names used throughout the metalogic chapters:

#leansrc("FormalSystem.ProofSystem", "DerivationTree")
```
inductive DerivationTree (fc : FrameClass) : Context → Formula → Type where
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ fc)
      : DerivationTree fc Γ φ
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree fc Γ φ
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (d1 : DerivationTree fc Γ (φ.imp ψ))
      (d2 : DerivationTree fc Γ φ) : DerivationTree fc Γ ψ
  | necessitation (φ : Formula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.box φ)
  | temporal_necessitation (φ : Formula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.allFuture φ)
  | time_reflection (φ : Formula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.reflectTime
  | weakening (Γ Δ : Context) (φ : Formula)
      (d : DerivationTree fc Γ φ)
      (h : Γ ⊆ Δ) : DerivationTree fc Δ φ
  deriving Repr
```

Reading a constructor is reading an inference rule: `modus_ponens` takes two sub-derivations (of `φ.imp ψ` and of `φ`, both from the same `Γ` and `fc`) and returns a derivation of `ψ` -- exactly the rule's premises-then-conclusion shape, made literal as a function's argument-then-return-type shape.
The two necessitation constructors and `time_reflection` all require their premise derivation to have the *empty* context, which is the constructor-level encoding of "only applies to theorems" from the proof-theory chapter's statement of the rule.

== Structures and Classes <lean-appendix-structures>

A `structure` bundles named fields into a single value, and is Lean's tool for record types: `Atom`, the type underlying `Formula.atom`, is a minimal example with two fields:

#leansrc("FormalSystem.Syntax", "Atom")
```
structure Atom where
  base : String
  freshIndex : Option Nat
  deriving Repr, DecidableEq, BEq, Hashable
```

The semantic layer's `TaskModel` (@sec:truth) is a one-field structure parameterized by a `TaskFrame`, showing how a structure can depend on a value (here, the frame `F` it is a model *over*) exactly the way @lean-appendix-types-props described for `DerivationTree`:

#leansrc("FormalSystem.Semantics", "TaskModel")
```
structure TaskModel (F :
      TaskFrame) where
  valuation : F.WorldState → Atom → Prop
```

`class`, by contrast, declares a structure *and* registers it for automatic inference: writing `[DecidableEq α]` as a hypothesis asks Lean's elaborator to find an instance rather than requiring the caller to supply one explicitly.
`Formula`'s `deriving Repr, DecidableEq, BEq, Hashable, Countable` clause (@lean-appendix-inductive) auto-generates exactly such instances for `Formula`, so that anywhere a `DecidableEq Formula` instance is needed, `inferInstance` (or the `by infer_instance` tactic form) finds it without help:

```
example : DecidableEq Formula := inferInstance
```

This is why decidable-equality and hashing "just work" throughout `FormalSystem/` on formula-keyed sets and maps (`Finset Formula`, `Std.HashMap Formula _`) without a single hand-written `Decidable` instance for `Formula` anywhere in the codebase.

== Tactic Proofs vs. Term Proofs <lean-appendix-tactics>

Every Lean proof is, at the kernel level, a term -- but `by`-blocks let an author build that term *interactively*, one tactic at a time, against a displayed goal, rather than writing the finished term by hand.
The `⊢ □p → p` example from @lean-appendix-props-as-types has both forms. The term-mode version there names the axiom directly; the tactic-mode version instead runs a proof-search or axiom-matching procedure and lets it find the term:

```
example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") := by
  modal_search
```

`modal_search` (`FormalSystem.Automation`, documented in full in the tactic reference alongside @sec:proof-automation) performs bounded proof search over the derivation rules and axiom schemata, up to a configurable depth and node-visit limit; it is the project's pedagogical entry point for "show this is derivable" goals, not infrastructure the metalogic itself is built on.
`apply_axiom` is narrower and more literal: it is a zero-argument tactic macro expanding to `apply DerivationTree.axiom; refine ?_`, so it applies exactly the `axiom` constructor and leaves its `h : Axiom _` and `h_fc` side goals open for the caller to close by hand, rather than searching for the matching constructor itself:

```
example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p") := by
  apply_axiom
  case h => exact Axiom.modal_t _
  case h_fc => trivial
```

Between these extremes, ordinary tactics compose the way they do in any Lean proof: `intro` introduces a hypothesis, `exact e` closes the goal with a term `e` you already have in hand (often the bridge back to a term-mode fragment like `boxPImpP` above), `apply f` unifies the goal's conclusion against `f`'s result type and leaves `f`'s remaining arguments as new goals, and `simp` rewrites using registered simplification lemmas.
Term mode and tactic mode are not a stylistic fork with separate rules -- a tactic block is simply a way of writing a term, and the two are freely interchangeable at any point in a proof, including mid-term via `by`. The project favors term mode where a direct construction is short and self-documenting (most of `Theorems/`) and tactic mode where a repeated automatable pattern would otherwise be typed out by hand (`propDecide` for propositional tautologies, `modal_search` for schema instances).

== Mathlib Conventions <lean-appendix-conventions>

`FormalSystem/`'s naming rules are Mathlib's, keyed on what a declaration *produces* rather than on which command declares it. A `def` that produces data uses lowerCamelCase (`reflectTime`, `allFuture`, `always`); a `def` that produces a `Prop` -- i.e. defines a predicate -- uses UpperCamelCase (`Derivable`, `TruthAt`), matching Mathlib's own `Function.Injective` and `IsCompact`; a `theorem` or `lemma` uses snake_case (`soundness`, `completeness`); and a tactic token is snake_case as well (`modal_t`, `apply_axiom`), following every built-in Lean tactic (`simp_all`, `push_neg`).
Namespaces mirror the directory structure the library actually has -- `FormalSystem.Syntax`, `FormalSystem.ProofSystem`, `FormalSystem.Metalogic.BXCanonical` -- rather than an abbreviated or ad hoc scheme, and `open` is used sparingly in favor of qualified names where a name would otherwise be ambiguous.

A module typically opens with a docstring (`/-! # Title ... -/`) stating its main definitions, main results, and implementation notes, and each nontrivial declaration carries its own `/-- ... -/` docstring, as the excerpts throughout this appendix illustrate.
`variable` blocks hoist repeated implicit or instance arguments (a frame `F`, a frame class `fc`) out of individual declaration signatures within a section, and Unicode notation -- `□`, `◇`, `⊢`, `Γ`, `φ`, `ψ` -- follows the same symbols the book's own mathematics uses, so a Lean declaration and its prose statement read as the same expression in two fonts rather than as a translation.

== Lake and Project Layout <lean-appendix-lake>

Lake is Lean's build tool, configured declaratively by #link("https://toml.io")[`lakefile.toml`] rather than by a Lean-syntax `lakefile.lean`.
The package is named `BimodalLogic`; its main library target is `FormalSystem`, and its test library is `BimodalTest` (`srcDir = "Tests"`).
A `[[require]]` block pins Mathlib to a specific tagged revision, so the whole project builds against one frozen, reproducible mathematical library rather than a moving target.
`lean-toolchain` at the repository root pins the Lean 4 release itself (currently a `leanprover/lean4` prerelease tag); `elan`, Lean's toolchain manager, reads this file and switches toolchains automatically per directory.

Day-to-day commands: `lake build` compiles the whole library (or `lake build FormalSystem` for just the main library target); `lake env lean FILE.lean` runs the Lean elaborator on a standalone file *with* the project's dependencies and import path resolved, which is how this appendix's own didactic snippets were checked, in a scratch file outside `FormalSystem/` and `Tests/`; and `import FormalSystem` (or a specific submodule such as `import FormalSystem.Syntax.Formula`) brings the library into scope in any such file.

The directory tour in @lean-appendix-reading-source below maps each top-level directory under `FormalSystem/` to the chapter of this book whose formal claims it backs. For general Lean 4 reference beyond this appendix's scope, see the #link("https://leanprover.github.io/theorem_proving_in_lean4/")[Theorem Proving in Lean 4] book, the #link("https://lean-lang.org/documentation/")[Lean 4 documentation], and the #link("https://leanprover-community.github.io/mathlib4_docs/")[Mathlib4 docs].

== Reading `FormalSystem/` Source <lean-appendix-reading-source>

`FormalSystem/` is organized so that each directory backs a recognizable stretch of this book: `Syntax/` defines `Formula` and its derived operators (@sec:formulas); `ProofSystem/` holds the #axiom-count axiom constructors and the #rule-count inference rules of the `DerivationTree` / `Derivable` machinery (@sec:proof-theory); `Semantics/` defines task frames, models, and truth conditions; `Metalogic/` proves soundness for every frame class and the completeness theorems (@sec:metalogic); `Theorems/` collects the derived-theorem library, including the perpetuity principles; and `Automation/` and `Examples/` hold the proof tactics and worked examples covered in Part II (@sec:proof-automation).
`ForMathlib/` is a fifth, smaller directory: Mathlib-shaped extensions (the prime-filter API used in the algebraic route through completeness) written to be upstreamed, importing nothing from the rest of `FormalSystem/`.
One directory is explicitly *not* live: `Boneyard/`, wherever it appears nested under another directory, holds archived material -- superseded constructions kept for historical reference -- and nothing this book cites resolves there.

Two worked walkthroughs connect the book's two central metatheoretic claims to their declarations. Soundness:

#leansrc("FormalSystem.Metalogic", "soundness")
```
theorem soundness (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Base Γ φ)
    (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ
```

reads as: given a `FrameClass.Base` derivation `d` of `φ` from `Γ`, and *any* frame, model, history, and time at which every formula in `Γ` is true, `φ` is true there too. The hypotheses are universally quantified over the semantic side (`F`, `M`, `τ`, `t`) precisely because soundness must hold for every model, not some fixed one; `soundness_dense`, `soundness_ztime`, and `soundness_rtime` are the same statement specialized to the other three frame classes.
Completeness runs the other direction, in `FormalSystem.Metalogic.BXCanonical`:

#leansrc("FormalSystem.Metalogic.BXCanonical", "completeness")
```
theorem completeness (φ : Formula) :
    Valid φ → Derivable FrameClass.Base [] φ
```

Every formula valid on all task frames is derivable in the base system -- the converse direction from soundness, proved by the canonical-model construction the metalogic chapter describes in prose. The two combine into the biconditional `Valid φ ↔ Derivable FrameClass.Base [] φ` that the metalogic chapter states as the headline result.

Trust-reading practice: `#check`, applied to a declaration name, shows that declaration's type without evaluating anything, useful for confirming a signature before reading the proof body; `#print axioms`, applied to a declaration name, lists every axiom the kernel actually depended on to produce that declaration's proof, which is how this book's `sorry`-tracking is verified rather than merely asserted -- the current count outside the archived `Boneyard/` material is #sorry-total-excl-boneyard.
Every citation in this book gives a declaration *name*, never a `file:line` pair, because line numbers drift with routine edits while a name survives them (and a Lean editor's go-to-definition, or `lean_declaration_file`-style tooling, resolves a name to its current location instantly).
For the complete name-by-name correspondence between every axiom, rule, and derived operator in the book and its `FormalSystem/` declaration, see @machine-appendix.
