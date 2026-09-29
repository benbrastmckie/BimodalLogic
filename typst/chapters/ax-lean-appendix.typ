// ============================================================================
// ax-lean-appendix.typ
// Back-matter appendix -- Reading the Lean Formalization
//
// A from-basics Lean 4 primer, scoped to exactly what a reader needs in order
// to go from a formal claim cited in this book to the live declaration under
// FormalSystem/ that backs it. Every Lean identifier cited here names a live
// (non-Boneyard) declaration. Snippets are of two kinds, both presented via
// typst/template.typ's lean-code() environment:
//   - source excerpts (lean-code(source: (module, name))[...]): quoted from
//     the live source, verbatim up to whitespace (docstrings omitted, lines
//     re-broken to fit the column budget).
//   - didactic examples (lean-code[...], no source: argument), compiled
//     against the current toolchain with lake env lean before being
//     written here.
// See ../SYNC-MAP.md for the dated entry.
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count, rule-count, sorry-total-excl-boneyard, lean-toolchain-pin, mathlib-tag, mathlib-rev, formalsystem-file-count, formalsystem-line-count, tests-file-count, tests-line-count, tools-file-count, tools-line-count

#pagebreak()
// Appendix identity. This is a real appendix, not an unnumbered chapter: the
// level-1 heading counter is reset so the title numbers as letter "A" (not
// the accumulated chapter count), and the supplement is overridden from the
// document-wide "Chapter" to "Appendix" so @lean-appendix reads "Appendix A"
// rather than "Chapter A". The machine-readable appendix that follows
// continues the same counter to letter "B" (see its own numbering block).
#counter(heading).update(0)
#show heading.where(level: 1): set heading(supplement: "Appendix")
#set heading(numbering: (..n) => numbering("A", n.pos().first()))
#heading[Reading the Lean Formalization] <lean-appendix>

// --- Appendix-local formatting (scoped to this file by #include) ------------
//
// Section numbering. The appendix title above carries real letter numbering,
// which auto-resets the level-2 counter to 0, so the sections below start
// numbering fresh at A.1, A.2, ... which is also how @-references to them
// render ("Section A.4"). The "A." prefix is hardcoded per this file, the
// same file-local pattern the machine-readable appendix repeats with "B.".
#set heading(numbering: (..n) => "A." + numbering("1.1", ..n.pos().slice(1)))

// Code blocks are presented by typst/template.typ's lean-code() environment
// (geometry, column budget and fidelity policy documented there), applied
// uniformly book-wide -- no file-local rule here.

// Lists and tables. Same vertical rhythm as the template's items
// environment, so neither runs into the paragraph that follows it.
#show list: set block(above: 0.8em, below: 0.8em)
#show figure: set block(above: 1em, below: 1em)

// Scale figures. Every count below comes from generated/status.typ, which is
// written by scripts/typst-status-counts.sh and diffed against a live
// regeneration by Check 2 of scripts/typst-sync-check.sh. This helper only
// punctuates them. It never computes one.
#let figcount(n) = {
  let s = str(n)
  let parts = ()
  let i = s.len()
  while i > 3 {
    parts.push(s.slice(i - 3, i))
    i = i - 3
  }
  parts.push(s.slice(0, i))
  parts.rev().join(",")
}

This appendix is a self-contained primer on Lean 4, for a reader who knows the mathematics of *TM* from Part I but has never opened a Lean file.
It builds up from what Lean is to reading `FormalSystem/` itself, in fourteen short sections, each self-contained enough to skip to directly from a citation elsewhere in the book.

- *Foundations.* What a proof assistant checks (@lean-appendix-what-is-lean), the two universes `Type` and `Prop` (@lean-appendix-types-props), and propositions as types (@lean-appendix-props-as-types).
- *Declarations.* Inductive types, with `Formula` and `DerivationTree` as the running examples (@lean-appendix-inductive), then structures and classes on the semantic layer (@lean-appendix-structures), dependent fields and subtypes on histories (@lean-appendix-dependent-fields), and definition by structural recursion on `TruthAt` (@lean-appendix-recursion).
- *Proofs and style.* The two proof styles used throughout the codebase, tactic and term (@lean-appendix-tactics), a derived theorem of *TM* read end to end (@lean-appendix-derived-theorem), its semantic counterpart by transport (@lean-appendix-semantic-counterpart), what it buys to make derivations data (@lean-appendix-derivations-as-data), and the codebase's naming and documentation conventions (@lean-appendix-conventions).
- *The project.* The build tool, the layer order and the four proof systems (@lean-appendix-lake), and a worked guide to locating, mapping and trust-reading the declarations behind the book's soundness, completeness and decidability results (@lean-appendix-reading-source).

Code is displayed in two ways.
A block introduced by a `>` line naming a module and declaration is an excerpt from the live source, with docstrings omitted and lines re-broken to fit the page.
A block with no such line is a didactic example written for this appendix, and each one compiles against the current library.

== What Lean Is <lean-appendix-what-is-lean>

Lean 4 is a dependently typed functional programming language that doubles as an interactive proof assistant.
The same expression language that defines ordinary data (numbers, lists, formulas) also states and proves theorems, because a proof in this system is itself a piece of data of a particular type (@lean-appendix-props-as-types).

Trust rests on a small *kernel* that type-checks every proof term against the theorem's stated type.
Everything else, including the tactic framework that writes most proofs in practice, is untrusted elaboration machinery: it only has to produce a term the kernel accepts.
This is what makes machine checking meaningful.
The book's formal claims are not merely stated in a Lean-flavored notation.
Each is type-checked by the kernel against its declared type, so a proof with a gap in it does not compile.
What the kernel cannot check is that a Lean statement says what the surrounding prose claims it says.
That comparison is the reader's, and making it possible is the purpose of this appendix.

*Mathlib* is the community mathematical library the project builds on, and `lakefile.toml` pins it to a specific tagged revision (@lean-appendix-lake).
`FormalSystem/` does not reprove general mathematics that Mathlib already has (orders, groups, `Nat`, `Finset`).
It imports what it needs and formalizes only what is specific to *TM*: the formula language, the proof system, task-frame semantics, and the metalogic connecting them.
This is why the book pairs its formal claims with Lean identifiers rather than restating them.
`soundness`, `completeness`, and every axiom and rule constructor are declarations a reader can open, inspect, and audit with the kernel's own trust report (@lean-appendix-reading-source).

== Types, Props, and Dependent Types <lean-appendix-types-props>

Every Lean expression has a type, and types are themselves classified into universes.
Two universes matter for reading this codebase: `Type`, the universe of data, and `Prop`, the universe of propositions.

- *`Type`.* `Formula` lives here: a formula is a piece of data one can pattern-match on, print, and compute with.
- *`Prop`.* A statement such as `1 + 1 = 2` or `Valid φ` lives here. Propositions are also types, whose inhabitants are their proofs, but Lean treats `Prop` specially: any two proofs of the same proposition are equal (*proof irrelevance*), because a proof's only job is to witness that its proposition holds.

`FormalSystem/` puts both universes to work on the same underlying idea, derivability, and the contrast is instructive.
`DerivationTree fc Γ φ` (@lean-appendix-inductive) is declared in `Type`, not `Prop`, because its inhabitants carry information the codebase computes with: a derivation has a height (`DerivationTree.height`), a case structure the metalogic inducts on, and a concrete shape the decision procedure returns as its certificate of validity.
`Derivable fc Γ φ` is the `Prop`-valued twin.
It asserts *that* a derivation exists without retaining *which* one:

#lean-code(source: ("FormalSystem.ProofSystem", "Derivable"))[
```
def Derivable (fc : FrameClass) (G : Context) (p : Formula) :
    Prop :=
  Nonempty (DerivationTree fc G p)
```
]

The wrapper exists for automation: `simp` and similar tactics target `Prop`-valued goals, so a consistency argument or a quick lemma application states its goal with `Derivable`, while the metalogic, which needs the tree itself, works with `DerivationTree`.

The `fc : FrameClass` argument should not be read as semantics entering a syntactic definition.
`FrameClass` is a four-element tag (`Base`, `Dense`, `ZTime`, `RTime`) declared alongside the axioms in `FormalSystem.ProofSystem`, with no reference to frames, models, or truth.
Its only role here is to select which axiom set a derivation may draw on, so that one inductive definition covers the base system and its three extensions.
The tag is named for the class of frames its axiom set is meant to axiomatize, but it acquires that meaning only later, in the module `FormalSystem.Semantics.FrameClassValidity`, where `FrameClass.Sat` interprets each tag as a condition on task frames.
Soundness and completeness are then what connect the two uses of the one index (@lean-appendix-reading-source).

Both come with turnstile notation, which the source uses far more often than the spelled-out names:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header(
      [*Notation*], [*Unfolds to*], [*Universe*],
    ),
    table.hline(),
    [`Γ ⊢ φ`], [`DerivationTree FrameClass.Base Γ φ`], [`Type`],
    [`Γ ⊢[fc] φ`], [`DerivationTree fc Γ φ`], [`Type`],
    [`G |-! p`], [`Derivable FrameClass.Base G p`], [`Prop`],
    [`G |-![fc] p`], [`Derivable fc G p`], [`Prop`],
    [`⊨ φ`], [`Valid φ`], [`Prop`],
    table.hline(),
  ),
  caption: none,
)

In all four turnstile forms the context may be omitted: `⊢ φ` abbreviates a derivation from the empty context, that is, a theorem of the base system.
Six further points are worth fixing before any of these forms is read in anger.

- *The brackets are literal tokens.* All eight turnstile forms are project-defined `notation` declarations, four in `FormalSystem/ProofSystem/Derivation.lean` and four in `FormalSystem/ProofSystem/Derivable.lean`. Neither the turnstile nor the square brackets are built-in Lean syntax, and the brackets are not Lean's instance binders of @lean-appendix-structures. They are punctuation this project chose, and they mean nothing outside it.
- *What goes between them is a `FrameClass`.* Any term of that type may sit there. A concrete tag, as in `⊢[.Dense] φ`, gives a derivation in that one system. A bound variable, as in the `{fc : FrameClass}` binder of `perpetuity2` (@lean-appendix-derived-theorem), gives a statement holding in all four systems at once.
- *This is the book's subscripted turnstile.* `⊢[.Dense] φ`, `⊢[.ZTime] φ` and `⊢[.RTime] φ` are the Lean spellings of derivability in *TM*#sub[d], *TM*#sub[f] and *TM*#sub[c] respectively (@sec:frame-classes).
- *The bracket-free forms are the `FrameClass.Base` instances.* `Γ ⊢ φ` is not an abbreviation that unfolds to `Γ ⊢[.Base] φ` by some separate rule; the two notations produce the same term, so they are the same type and `rfl` proves it.
- *The exclamation mark marks the `Prop`-valued twin.* `|-!` is `Derivable` where `⊢` is `DerivationTree`, which is the `Type`-versus-`Prop` contrast drawn above, and `⊨ φ` is neither: it is `Valid φ`, a semantic claim about models rather than a syntactic one about derivations. `Valid φ` is itself `ValidIn FrameClass.Base φ` by definition, so validity outright and validity on the base class are one notion. The source also declares a two-place `Γ ⊨ φ` for `SemanticConsequence`, which this appendix never uses.
- *The two spellings of the variables are one convention.* The `DerivationTree` rows above write `Γ` and `φ`, the `Derivable` rows write `G` and `p`. Each notation quotes the variable names of its own source file, and nothing turns on the difference: `Γ` and `G` both range over contexts, `φ` and `p` both over formulas. The difference is spelling, not meaning.

The identity of the bracket-free and `.Base` forms is checkable in one line:

#lean-code[
```
example (Γ : Context) (φ : Formula) :
    (Γ ⊢ φ) = (Γ ⊢[.Base] φ) := rfl

example (G : Context) (p : Formula) :
    (G |-! p) = (G |-![.Base] p) := rfl
```
]

`DerivationTree` is also an example of a *dependent* type.
Its type, `FrameClass → Context → Formula → Type`, takes ordinary values (a frame class, a context, a formula) as arguments, and the resulting type depends on which values were supplied.
`DerivationTree .Dense [] φ` and `DerivationTree .Base [] φ` are different types, not one type carrying two labels: a value of the first may use the density axiom, and a value of the second may not.

This is how the `fc` parameter enforces frame-class discipline structurally.
The `axiom` constructor carries the side condition `h.minFrameClass ≤ fc` as a hypothesis inside the type (@lean-appendix-inductive), so a `DerivationTree fc` value cannot have been built from an axiom its frame class does not license.
There is no validity check to run after the fact, because an ill-formed derivation cannot be constructed at all.

== Propositions as Types and Proof Terms <lean-appendix-props-as-types>

The Curry-Howard correspondence reads a proposition as a type and a proof as a value (a *term*) of that type.
Proving `A → B` means writing a function from proofs of `A` to proofs of `B`, and proving `A ∧ B` means producing a pair of proofs.
`FormalSystem/` puts this reading to work at two levels.

- *The meta level.* An ordinary Lean `theorem` such as `soundness` (@lean-appendix-reading-source) is a proof term whose type is the stated claim, checked by the kernel as described in @lean-appendix-what-is-lean.
- *The object level.* `DerivationTree fc Γ φ` reifies the same correspondence for *TM* itself. A term of this type is not a Lean proof of a Lean proposition. It is data encoding a derivation of `φ` from `Γ` in the object system, built from constructors that mirror the rules of the Hilbert-style calculus (@lean-appendix-inductive lists all #rule-count).

A *term-mode* proof writes such a value down directly, with no tactic block.
For an arbitrary formula `p`, the instance `⊢ □p → p` of the modal T axiom is:

#lean-code[
```
def boxPImpP (p : Formula) : ⊢ p.box.imp p :=
  DerivationTree.axiom [] _ (Axiom.modal_t p) trivial
```
]

`DerivationTree.axiom` takes four arguments: the context (here empty), the formula (here `_`, left for Lean to infer), an `Axiom` witness, and a proof of the frame-class side condition of @lean-appendix-types-props.
For `Axiom.modal_t` the minimum frame class is `FrameClass.Base`, so at the base system the side condition is discharged by `trivial`.

Derivations compose the way proof terms always do, by applying one term to another.
Given a hypothetical derivation `dBoxP : ⊢ □p`, the `modus_ponens` constructor combines it with `boxPImpP` to build a derivation of `p`:

#lean-code[
```
example (p : Formula) (dBoxP : ⊢ p.box) : ⊢ p :=
  DerivationTree.modus_ponens [] p.box p (boxPImpP p) dBoxP
```
]

Passing from the tree to the bare fact of derivability is one step, because `Derivable` is defined by `Nonempty`: the anonymous-constructor brackets wrap the tree, and `Derivable.ofTree` is the same step by name.

#lean-code[
```
example (p : Formula) : |-! p.box.imp p := ⟨boxPImpP p⟩
```
]

@lean-appendix-tactics sets this term-mode style beside a tactic-mode proof of the same fact.

== Inductive Types: `Formula` and `DerivationTree` <lean-appendix-inductive>

An *inductive type* is defined by an exhaustive list of constructors, each specifying one way to build a value of the type, possibly from other values of the same type.
Recursion and structural induction over the type then come for free.
`Formula` (@sec:formulas) is declared with exactly the six primitive constructors the syntax chapter states:

#lean-code(source: ("FormalSystem.Syntax", "Formula"))[
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
]

Every other connective in the book is a `def` layered over these six, never a further constructor.
`neg`, `and`, `or`, `diamond`, `allFuture`, `allPast`, `someFuture`, `somePast`, `always`, `sometimes`, and the rest are ordinary functions computing a `Formula` from `Formula` arguments.
Dot notation keeps such definitions readable: `φ.neg` abbreviates `Formula.neg φ`, so operators chain left to right.
The two temporal operators the book emphasizes are typical:

#lean-code(source: ("FormalSystem.Syntax", "Formula.always"))[
```
def always (φ : Formula) : Formula :=
  φ.allPast.and (φ.and φ.allFuture)

def sometimes (φ : Formula) : Formula := φ.neg.always.neg
```
]

`DerivationTree fc Γ φ` (@sec:proof-theory) is the second running example: an inductive *family*, indexed by frame class, context, and formula, with #rule-count constructors, one per inference rule of the Burgess-Xu system.
Its constructor names are the rule names used throughout the metalogic chapters:

#lean-code(source: ("FormalSystem.ProofSystem", "DerivationTree"))[
```
inductive DerivationTree (fc : FrameClass) :
    Context → Formula → Type where
  | axiom (Γ : Context) (φ : Formula)
      (h : Axiom φ) (h_fc : h.minFrameClass ≤ fc) :
      DerivationTree fc Γ φ
  | assumption (Γ : Context) (φ : Formula)
      (h : φ ∈ Γ) :
      DerivationTree fc Γ φ
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (d1 : DerivationTree fc Γ (φ.imp ψ))
      (d2 : DerivationTree fc Γ φ) :
      DerivationTree fc Γ ψ
  | necessitation (φ : Formula)
      (d : DerivationTree fc [] φ) :
      DerivationTree fc [] (Formula.box φ)
  | temporal_necessitation (φ : Formula)
      (d : DerivationTree fc [] φ) :
      DerivationTree fc [] (Formula.allFuture φ)
  | time_reflection (φ : Formula)
      (d : DerivationTree fc [] φ) :
      DerivationTree fc [] φ.reflectTime
  | weakening (Γ Δ : Context) (φ : Formula)
      (d : DerivationTree fc Γ φ) (h : Γ ⊆ Δ) :
      DerivationTree fc Δ φ
  deriving Repr
```
]

Reading a constructor is reading an inference rule.
Each one is laid out above as name and parameters, then premises, then conclusion: `modus_ponens` takes two sub-derivations, of `φ.imp ψ` and of `φ` from the same `Γ` and `fc`, and returns a derivation of `ψ`.
The rule's premises-then-conclusion shape is made literal as a function's arguments-then-return-type shape.
The two necessitation constructors and `time_reflection` require their premise to have the *empty* context `[]`, which is the constructor-level encoding of the proof-theory chapter's restriction of these rules to theorems.

== Structures and Classes <lean-appendix-structures>

A `structure` bundles named fields into a single value: it is Lean's record type.
`Atom`, the type underlying `Formula.atom`, is a minimal example with two fields:

#lean-code(source: ("FormalSystem.Syntax", "Atom"))[
```
structure Atom where
  base : String
  freshIndex : Option Nat
  deriving Repr, DecidableEq, BEq, Hashable
```
]

// TODO: Elaborate this example. The excerpt is clear and helpful, but nothing after it says what
// the Lean syntax means. Walk through it line by line: the `structure ... where` header; each
// `name : Type` field line (what `String`, `Nat`, and `Option Nat` are, and why `freshIndex` is
// optional); how an `Atom` value is built (anonymous-constructor brackets, `{ base := ..., .. }`,
// and the generated `Atom.mk`) and how its fields are read back (`a.base`, `a.freshIndex`); and
// what the `deriving` clause generates, one handler at a time (`Repr`, `DecidableEq`, `BEq`,
// `Hashable`), since this is the first structure the reader meets and the later ones build on it.

=== Three Kinds of Binder

Every signature from here on uses all three of Lean's argument brackets, so it is worth fixing them once.
The brackets record *who supplies the argument*, not what kind of thing it is.

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header(
      [*Binder*], [*Written*], [*Supplied by*],
    ),
    table.hline(),
    [explicit], [`(φ : Formula)`], [the caller, in order],
    [implicit], [`{fc : FrameClass}`], [Lean, by unifying the other arguments],
    [instance], [`[DecidableEq α]`], [instance synthesis],
    table.hline(),
  ),
  caption: none,
)

// TODO: Make the discussion of the three binders clear, systematic, and complete. The table names
// them, but the prose that follows treats them unevenly: implicit gets three sentences, instance
// is folded into the account of `class`, and explicit gets none. Explain each binder in full and
// in the same order and shape: (1) what is written at the declaration site; (2) what the caller
// writes, or omits, at the use site; (3) how Lean fills the argument in when it is omitted
// (unification for implicit, instance synthesis for instance) and what error the reader sees when
// it cannot; (4) how to override the default (`@f`, named arguments `(fc := .Dense)`); and (5) one
// worked example from `FormalSystem/` per binder, ideally a single signature that uses all three,
// shown once as declared and once as called. Also cover the variants a reader will meet in the
// source: several names under one binder `(φ ψ : Formula)`, strict-implicit `⦃x : T⦄`,
// anonymous instance binders `[DecidableEq α]` versus named ones `[inst : DecidableEq α]`,
// `variable` declarations that add binders invisibly, and auto-bound implicits.

An implicit argument is one Lean can read off the rest of the call, so writing it out would be noise.
`perpetuity2` (@lean-appendix-derived-theorem) takes its frame class implicitly, which is what lets a single proof term serve all four frame classes.
Prefixing a name with `@` turns every implicit argument back into an explicit one, which is how `#check` is made to print a signature with nothing hidden.

A `class` is a structure that is additionally registered for *instance inference*.
Writing `[DecidableEq α]` in a signature asks Lean's elaborator to find an instance on its own, rather than requiring the caller to supply one.
`Formula`'s `deriving Repr, DecidableEq, BEq, Hashable, Countable` clause (@lean-appendix-inductive) generates exactly such instances, so wherever a `DecidableEq Formula` instance is needed, `inferInstance` finds it without help:

#lean-code[
```
example : DecidableEq Formula := inferInstance
```
]

This is why decidable equality and hashing simply work on formula-keyed collections (`Finset Formula` throughout `FormalSystem/`, `Std.HashMap Formula _` in the `BimodalTools` dataset generators) with no hand-written equality instance for `Formula` anywhere in the codebase.
Square-bracketed instance arguments recur in the metalogic, where they state frame conditions: the dense soundness theorem of @lean-appendix-reading-source assumes `[DenselyOrdered F.Duration]`.

=== Instance-Bracket Fields and the Duration Coercion

A structure's *fields* can carry instance brackets too, and the semantic layer opens with the clearest case.
`TemporalOrder` (@sec:truth) bundles a type of durations together with the four algebraic properties the mathematics demands of it:

#lean-code(source: ("FormalSystem.Semantics", "TemporalOrder"))[
```
structure TemporalOrder where
  carrier : Type
  [addCommGroup : AddCommGroup carrier]
  [linearOrder : LinearOrder carrier]
  [isOrderedAddMonoid : IsOrderedAddMonoid carrier]
  [nontrivial : Nontrivial carrier]

instance : CoeSort TemporalOrder Type :=
  ⟨TemporalOrder.carrier⟩

attribute [instance] TemporalOrder.addCommGroup
  TemporalOrder.linearOrder TemporalOrder.isOrderedAddMonoid
  TemporalOrder.nontrivial
```
]

Only `carrier` is data.
The other four fields are Mathlib classes, bracketed so that constructing a `TemporalOrder` finds them by synthesis instead of demanding them positionally.
The two declarations after the structure are what make the bundle usable.

- *The coercion.* `CoeSort` is a *coercion to a sort*, meaning a coercion whose target is a type rather than a value. It lets a `TemporalOrder` stand wherever Lean expects a type, which is why `(t : F.Duration)` elaborates at all when `F.Duration` is a structure.
- *The re-export.* `attribute [instance]` registers the four bracketed fields with instance synthesis, so an abstract duration type carries its group and order structure wherever it travels.

Both are visible the first time a reader runs `#check` on a declaration this appendix quotes.
The source of `soundness` writes the time argument at `F.Duration`, and `#check` prints its type back as `F.Duration.carrier`, because the elaborated term has the coercion already applied.
The two spellings name one type, before and after the coercion unfolds.
The re-export is what makes `[DenselyOrdered F.Duration]` in `soundness_dense` meaningful, since that instance is sought at the carrier and needs `linearOrder` in scope to be found.

=== Frames in Two Layers

A task frame is assembled in two steps, and both steps are ordinary structures.
`FrameOver D` is everything a frame contributes *over a fixed temporal order* `D`, which is the second way a structure can depend on a value: @lean-appendix-types-props made the same point about `DerivationTree`.

#lean-code(source: ("FormalSystem.Semantics", "FrameOver"))[
```
structure FrameOver (D : TemporalOrder) where
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  PosRel : WorldState → D.PositiveCone → WorldState → Prop
  comp : TaskFrame.Compositional (TaskFrame.reflect PosRel)
  serial : TaskFrame.Serial (TaskFrame.reflect PosRel)
  limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧
    TaskFrame.reflect PosRel w y u) → u = w
  saturation : TaskFrame.Saturation (TaskFrame.reflect PosRel)

attribute [instance] FrameOver.worldNonempty
```
]

// TODO: Explain the `worldNonempty` field in full; "the same instance-bracket-field pattern one
// level down" assumes too much. Say (1) that the line has the same `name : Type` shape as every
// other field, with `worldNonempty` the field's name; (2) what `Nonempty α` is: a `Prop`
// (`class inductive Nonempty (α : Sort u) : Prop`, one constructor `Nonempty.intro : α → Nonempty α`)
// recording *that* an element exists while forgetting *which*, so the field's value is a proof,
// not data, and it encodes the requirement that the set of world states be nonempty; (3) that by
// proof irrelevance (@lean-appendix-types-props) any two such proofs are equal, so the field
// singles out no particular world state; (4) the contrast with `Inhabited α`, which stores a
// specific default element, and how the source obtains an element when it needs one
// (`F.worldNonempty.some`, which is noncomputable and rests on choice); (5) what the square
// brackets add at the construction site (the author of a frame writes nothing; Lean finds, say,
// `Nonempty Bool` by instance synthesis) and what the `attribute [instance]` line adds at the use
// site (given `F`, the fact `Nonempty F.WorldState` is available to synthesis, so lemmas with a
// `[Nonempty α]` hypothesis apply to world states unprompted). Also gloss the other field lines
// the prose below passes over: that `comp`, `serial`, `limit` and `saturation` are proof fields
// too, and how to read the `∀ w u, (∀ x, 0 < x → ∃ y, ...) → u = w` statement of `limit`.

`worldNonempty` is the same instance-bracket-field pattern one level down, re-exported by the same kind of `attribute` line.
It is a field rather than a binder on the structure for a stated reason: a binder must be discharged at every mention of the type, whereas a field is discharged once per frame, at the site where that frame is built.

The primitive relation `PosRel` is indexed by `D.PositiveCone`, the nonnegative durations, and the four axiom fields are stated over `TaskFrame.reflect PosRel` rather than over `PosRel` itself.
That is the *reflection convention*, which the source spells `FrameOver.TaskRel := TaskFrame.reflect PosRel`: the two-sided relation every consumer speaks about is the primitive one extended to negative durations by running it backwards.

#lean-code(source: ("FormalSystem.Semantics", "FrameOver.TaskRel"))[
```
def TaskRel (F : FrameOver D) :
    F.WorldState → ↑D → F.WorldState → Prop :=
  TaskFrame.reflect F.PosRel

theorem reflection (F : FrameOver D) (w : F.WorldState)
    (d : ↑D) (u : F.WorldState) :
    F.TaskRel w d u ↔ F.TaskRel u (-d) w
```
]

Note which of these is which.
`TaskRel` is a `def`, so reflection could have been imposed by fiat as an extra field.
It is not: `reflection` is a *theorem*, derived from the `limit` and `serial` fields at zero and from the definitional content of `TaskFrame.reflect` elsewhere (@sec:frame-classes).
The same holds of `nullity`, `eq_of_taskRel_zero` and `forward_comp`, which read like axioms of the mathematics and are proved rather than assumed.

The outer layer packages a fibre with the order it sits over:

#lean-code(source: ("FormalSystem.Semantics", "TaskFrame"))[
```
structure TaskFrame where
  Duration : TemporalOrder
  toFibre : FrameOver Duration

@[reducible] def WorldState (F : TaskFrame) : Type :=
  F.toFibre.WorldState

@[reducible] def TaskRel (F : TaskFrame) :
    F.WorldState → F.Duration → F.WorldState → Prop :=
  F.toFibre.TaskRel
```
]

`F.Duration`, `F.WorldState` and `F.TaskRel` are the three accessors every later signature uses, and the last two are `@[reducible]` so that a proof about `F.toFibre` is definitionally a proof about `F`.
This is the whole of the vocabulary `soundness` needs.
Its binder list `(F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)` reads, in order, as a frame, a model over it, a history in that model, and a time in the frame's temporal order.

== Dependent Fields and Subtypes <lean-appendix-dependent-fields>

Histories are where dependent types stop being a slogan and start doing work.
A history assigns a world state to each time *in its domain*, and to no other time, so the type of the assignment has to mention the domain.
`PartialHistory` (@sec:convex-histories) says exactly that:

#lean-code(source: ("FormalSystem.Semantics", "PartialHistory"))[
```
structure PartialHistory (F : TaskFrame) where
  domain : F.Duration → Prop
  nonempty_domain : ∃ t, domain t
  states : (t : F.Duration) → domain t → F.WorldState
  respects_task : ∀ (s t : F.Duration) (hs : domain s)
      (ht : domain t),
    F.TaskRel (states s hs) (t - s) (states t ht)
```
]

The `states` field is a *dependent function*.
The type of its second argument, `domain t`, mentions its first argument `t`, and the whole field's type mentions the earlier field `domain`.
Reading `states` as an ordinary two-argument function would force a choice with no good answer, namely what it returns at a time outside the domain.
A dependent field removes the question rather than answering it.
There is nothing to return off the domain, because a caller cannot form the application at all without first producing a proof that the time is in the domain.
So the library carries no junk values, and no lemma has to say that the junk values are never inspected.

Two of the other fields repay a close reading.

- `nonempty_domain` carries nonemptiness as *data* rather than as a side hypothesis on every later theorem, the same trade-off `worldNonempty` makes in @lean-appendix-structures.
- `respects_task` is stated *unconditionally*, over every pair of times in the domain, with no `s ≤ t` guard. Negative differences are covered by the reflection convention of @lean-appendix-structures rather than excluded, and the guarded form is derived afterwards as `respects_task_le`.

=== Predicates Rather Than Structures

@sec:convex-histories distinguishes convex and total histories from partial ones.
Lean could give each its own structure, and deliberately does not:

#lean-code(source: ("FormalSystem.Semantics", "PartialHistory.IsTotal"))[
```
def IsTotal (τ : PartialHistory F) : Prop :=
  ∀ t : F.Duration, τ.domain t

def IsConvex (τ : PartialHistory F) : Prop :=
  ∀ (x z : F.Duration), τ.domain x → τ.domain z →
    ∀ (y : F.Duration), x ≤ y → y ≤ z → τ.domain y
```
]

Both are *predicates*, which is to say functions into `Prop`, each naming a property that a `PartialHistory` may or may not have.
One structure then carries every history in the library, and the two conditions compose as ordinary propositions.
`IsTotal.isConvex`, the fact that a total history is convex, is a one-line theorem under this design.
Under the alternative it would be a conversion between two record types, and every lemma stated about one would need a twin about the other.

Where a property does have to travel with its subject, Lean offers the *subtype*.
A subtype is written as a type and a property separated by a double bar, and its inhabitants are pairs of a value and a proof of the property, with `.val` and `.property` as the two projections.
`WorldHistory` is the total histories, packaged this way:

#lean-code(source: ("FormalSystem.Semantics", "WorldHistory"))[
```
def WorldHistory (F : TaskFrame) : Type _ :=
  {τ : PartialHistory F // τ.IsTotal}
```
]

This is the type that truth and validity quantify over, and it is a `def` rather than an `abbrev` so that the generic `Subtype` lemmas do not leak onto it.
Its payoff is the accessor below.

#lean-code(source: ("FormalSystem.Semantics", "WorldHistory.state"))[
```
def state (τ : WorldHistory F) (t : F.Duration) :
    F.WorldState :=
  τ.val.states t (τ.property t)
```
]

`state` takes a time and returns a state, with no domain proof anywhere in its signature, because `τ.property` supplies that proof for every time at once.
The dependent field of `PartialHistory` is still doing its work underneath.
It has simply been discharged once, in this definition, instead of at every call site.
The `@[simp]` lemma `states_eq_state` rewrites any surviving dependent projection toward `state`, so `τ.state t` is the form a reader meets in `TruthAt` and everywhere downstream.

=== Models over a Frame

A model adds the one thing a frame lacks, namely which atoms hold where.

#lean-code(source: ("FormalSystem.Semantics", "TaskModel"))[
```
structure TaskModel (F : TaskFrame) where
  valuation : F.WorldState → Atom → Prop
```
]

The field is `Prop`-valued rather than `Bool`-valued, so a valuation is read as a *family of sets of world states*, one per atom, rather than as a computation.
Fixing an atom and collecting the states where it holds gives that set directly:

#lean-code[
```
example (F : TaskFrame) (M : TaskModel F) (p : Atom) :
    Set F.WorldState :=
  {w | M.valuation w p}
```
]

This is the reading @sec:truth uses, and it is why the atomic clause of `TruthAt` (@lean-appendix-recursion) is just membership: an atom holds at a history and a time exactly when that history's state at that time lies in the set.

== Definition by Structural Recursion <lean-appendix-recursion>

@lean-appendix-inductive said that recursion over an inductive type comes for free.
`TruthAt` is what that looks like in practice.
It is defined by one clause per `Formula` constructor, each clause written as a pattern on the left of `=>` and the truth condition on the right:

#lean-code(source: ("FormalSystem.Semantics", "TruthAt"))[
```
def TruthAt (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) : Formula → Prop
  | Formula.atom p => M.valuation (τ.state t) p
  | Formula.bot => False
  | Formula.imp φ ψ => TruthAt M τ t φ → TruthAt M τ t ψ
  | Formula.box φ => ∀ σ : WorldHistory F, TruthAt M σ t φ
  | Formula.untl ψ φ => ∃ s : F.Duration, t < s ∧
      TruthAt M τ s φ ∧
      ∀ r : F.Duration, t < r → r < s → TruthAt M τ r ψ
  | Formula.snce ψ φ => ∃ s : F.Duration, s < t ∧
      TruthAt M τ s φ ∧
      ∀ r : F.Duration, s < r → r < t → TruthAt M τ r ψ
```
]

Three things about the shape are worth naming before the content.

- *The clauses are exhaustive by construction.* `Formula` has exactly six constructors (@lean-appendix-inductive), so six clauses cover every formula. Lean checks this. A missing clause is a compile error, not a case that silently falls through.
- *The recursion is structural.* Each recursive call is on a strict subformula, so Lean accepts the definition as terminating without being given a measure and without a `termination_by` clause.
- *The definition is total.* There is no default case and no partiality, which is why `TruthAt` can be used as an ordinary mathematical function in every later proof.

Reading the clauses, the first two are the base cases and the third is the standard treatment of implication.
The remaining three carry the content of @sec:truth.

- *`Formula.box`.* The clause quantifies over *all* world histories at the same time `t`, with no accessibility relation between them. Necessity in *TM* is truth in every history at the present moment.
- *`Formula.untl` and `Formula.snce`.* Both bounds are *strict*. The until clause asks for a later `s` at which the event `φ` holds and at which the guard `ψ` has held strictly between, and the since clause is its mirror in the past.

The argument order of the last two is easy to misread and worth stating outright.
The first argument is the *guard* and the second is the *event*, as the pattern `Formula.untl ψ φ` shows.
So `Formula.untl ψ φ` is the formula the book writes as $ψ$ until $φ$, with `ψ` the condition that must hold throughout and `φ` the condition that must eventually hold.

=== Extending a Language by One Constructor

L⁺ (@ch:vlach-blstar) adds a single stability modal to the language of *TM*, and both halves of that addition are visible in Lean as one extra line.
The syntax gains a seventh constructor:

#lean-code(source: ("FormalSystem.PlusLanguage", "PlusFormula"))[
```
inductive PlusFormula : Type where
  | atom : Atom → PlusFormula
  | bot : PlusFormula
  | imp : PlusFormula → PlusFormula → PlusFormula
  | box : PlusFormula → PlusFormula
  | untl : PlusFormula → PlusFormula → PlusFormula
  | snce : PlusFormula → PlusFormula → PlusFormula
  | stab : PlusFormula → PlusFormula
  deriving Repr, DecidableEq, Countable
```
]

The semantics gains a seventh clause, and nothing else changes:

#lean-code(source: ("FormalSystem.PlusLanguage", "PlusTruthAt"))[
```
def PlusTruthAt (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) : PlusFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => PlusTruthAt M τ t φ → PlusTruthAt M τ t ψ
  | .box φ => ∀ σ : WorldHistory F, PlusTruthAt M σ t φ
  | .untl ψ φ => ∃ s : F.Duration, t < s ∧
      PlusTruthAt M τ s φ ∧
      ∀ r : F.Duration, t < r → r < s → PlusTruthAt M τ r ψ
  | .snce ψ φ => ∃ s : F.Duration, s < t ∧
      PlusTruthAt M τ s φ ∧
      ∀ r : F.Duration, s < r → r < t → PlusTruthAt M τ r ψ
  | .stab φ => ∀ σ : WorldHistory F, τ.state t = σ.state t →
      PlusTruthAt M σ t φ
```
]

The `stab` clause quantifies over the histories that agree with `τ` on the *present world state*, where the box clause quantifies over all of them.
That single restriction is the whole semantic content of the added modal.
Setting the two definitions side by side also shows what a language extension costs in a formalization, namely one constructor, one clause, and a re-proof of every result that inducts over the language.

The two definitions differ in one further respect, which is notation rather than content.
`TruthAt` writes its patterns out as `Formula.atom p`, while `PlusTruthAt` writes `.atom p`.
The leading dot is *anonymous constructor notation*: Lean already knows from the declared type which inductive is being matched, so the type's name may be dropped.
The same dot appears in expressions, as in the `FrameClass.Base` argument written `.Base`, and a reader who has met it once will meet it constantly in `FormalSystem/`.

== Tactic Proofs vs. Term Proofs <lean-appendix-tactics>

Every Lean proof is, at the kernel level, a term.
A `by` block lets an author build that term *interactively*, one tactic at a time against a displayed goal, rather than writing the finished term by hand.
The `⊢ □p → p` example of @lean-appendix-props-as-types has both forms.
The term-mode version there names the axiom directly, whereas the tactic-mode version runs a search procedure and lets it find the term:

#lean-code[
```
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search
```
]

The project's tactics relevant to a first reading are these.

- *`modal_search`* performs bounded proof search over the derivation rules and axiom schemata, up to a configurable depth and node-visit limit (@sec:proof-automation). It is the entry point for goals of the form "show this is derivable", not infrastructure the metalogic is built on.
- *`apply_axiom`* is narrower and more literal. It is a zero-argument macro expanding to `apply DerivationTree.axiom; refine ?_`: it applies exactly the `axiom` constructor and leaves the two side goals, `h : Axiom _` and `h_fc`, for the caller to close.
- *`propDecide`* decides propositional tautologies, and is used where a propositional pattern would otherwise be typed out by hand.

The second of these, spelled out:

#lean-code[
```
example (p : Formula) : ⊢ p.box.imp p := by
  apply_axiom
  case h => exact Axiom.modal_t _
  case h_fc => trivial
```
]

Between these extremes, ordinary tactics compose the way they do in any Lean proof.

- `intro` introduces a hypothesis.
- `exact e` closes the goal with a term `e` already in hand, and is the usual bridge back to a term-mode fragment such as `boxPImpP`.
- `apply f` unifies the goal's conclusion against `f`'s result type and leaves `f`'s remaining arguments as new goals.
- `simp` rewrites using registered simplification lemmas.

Term mode and tactic mode are not a stylistic fork with separate rules.
A tactic block is simply a way of writing a term, and the two are interchangeable at any point in a proof, including mid-term via `by`.
The project favors term mode where a direct construction is short and self-documenting, and tactic mode where a repeated automatable pattern would otherwise be written out by hand.

== Reading a Derived Theorem <lean-appendix-derived-theorem>

Everything so far has been vocabulary.
This section reads one complete derived theorem of *TM* end to end.
`perpetuity2` is the second perpetuity principle of @sec:perpetuity, that whatever is sometimes the case is possible.

#lean-code(source: ("FormalSystem.Theorems.Perpetuity", "perpetuity2"))[
```
def perpetuity2 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.sometimes.imp φ.diamond := by
  -- Goal: ⊢ ▽φ → ◇φ
  -- Recall: ▽φ = sometimes φ = ¬(always ¬φ)
  --   = ¬(H¬φ ∧ ¬φ ∧ G¬φ)
  -- Recall: ◇φ = diamond φ = ¬□¬φ = (φ.neg.box).neg
  -- By P1 for ¬φ: □(¬φ) → △(¬φ) = □(¬φ) → always(¬φ)
  -- By contraposition: ¬(always(¬φ)) → ¬(□(¬φ))
  -- Which is: sometimes φ → diamond φ = ▽φ → ◇φ
  have h1 : ⊢[fc] φ.neg.box.imp φ.neg.always :=
    perpetuity1 φ.neg
  -- Unfold: always (neg φ) = H(neg φ) ∧ neg φ ∧ G(neg φ)
  -- So h1 : ⊢ (¬φ).box → (¬φ).always
  -- We need: ⊢ ¬((¬φ).always) → ¬((¬φ).box)
  -- Which is: ⊢ sometimes φ → diamond φ
  exact contraposition h1
```
]

Read it a piece at a time.

- *`def`, not `theorem`.* The declared type is `DerivationTree`-valued, hence data rather than a proposition, which is the rule @lean-appendix-conventions states for the whole of `FormalSystem/Theorems/`.
- *The implicit frame class.* `{fc : FrameClass}` is the implicit binder of @lean-appendix-structures. Nothing in the body mentions a particular frame class, so this one declaration is a derivation at *every* frame class rather than four parallel derivations.
- *The type is the statement.* `⊢[fc] φ.sometimes.imp φ.diamond` is the turnstile notation of @lean-appendix-types-props, and it unfolds to a `DerivationTree` at `fc` from the empty context. A reader auditing this declaration audits that line and nothing else.
- *`have` names an intermediate derivation.* `h1` is the first perpetuity principle at `φ.neg`, obtained by applying `perpetuity1` exactly as one applies any function.
- *`exact` finishes with a term.* `contraposition h1` builds the goal's derivation from `h1`, and the tactic block exists only to let the two steps be named.

The double-dash comment lines are the source author's own running commentary, kept here because they are what the source actually looks like.
They work through the argument in the book's notation before the Lean lines do it in Lean's, which is the house style throughout `FormalSystem/Theorems/`.

One name in that body needs care.
Two live declarations are called `contraposition` with identical statements, one in `Theorems.Perpetuity` and one in `Theorems.Propositional`, and the body above resolves to the first because that is its own namespace.
Cited from outside, it has to be qualified by its namespace, exactly as `Axiom.modal_t` has to be (@lean-appendix-conventions).
A short name that reads unambiguously inside one file is not therefore unambiguous in the library.

The ingredient it reuses is shown by its statement alone, with its body omitted:

#lean-code(source: ("FormalSystem.Theorems.Perpetuity", "perpetuity1"))[
```
def perpetuity1 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.box.imp φ.always
```
]

Not every derived theorem needs writing out at all.
The instance of the *MF* axiom (`Axiom.modal_future`) is found by the search tactic of @lean-appendix-tactics:

#lean-code[
```
example (φ : Formula) : ⊢ φ.box.imp φ.allFuture.box := by
  modal_search
```
]

The term `modal_search` produces is the same kind of object as the one `perpetuity2` writes by hand, and the kernel checks both the same way.

== The Semantic Counterpart <lean-appendix-semantic-counterpart>

Every syntactic result has a semantic twin, and the twin is proved differently.
The *MF* axiom is derivable, as just shown.
It is also *valid*, and that is a separate theorem:

#lean-code(source: ("FormalSystem.Metalogic", "modal_future_valid"))[
```
theorem modal_future_valid (φ : Formula) :
    ⊨ ((φ.box).imp ((φ.allFuture).box))
```
]

Note `theorem` here against `def` above.
This one really is `Prop`-valued, because validity is a proposition and not a piece of data.
Its proof spends exactly one substantive fact, which is that shifting a history in time preserves truth:

#lean-code(source: ("FormalSystem.Semantics.TimeShift", "timeShift_preserves_truth"))[
```
theorem timeShift_preserves_truth (M : TaskModel F)
    (σ : WorldHistory F) (x y : F.Duration)
    (φ : Formula) :
    TruthAt M (σ.timeShift (y - x)) x φ ↔ TruthAt M σ y φ
```
]

The statement is an `↔` rather than a one-way implication, so it can be used in either direction without a second lemma.
What is worth noticing is how it is *not* proved.
There is no induction over `Formula` here, even though the claim is about every formula.
Instead it is an instance of one generic transport lemma:

#lean-code(source: ("FormalSystem.Semantics", "Truth.truthAt_of_truthCorr"))[
```
theorem truthAt_of_truthCorr {F F' : TaskFrame}
    {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthCorr M M') (φ : Formula) :
    ∀ (σ : WorldHistory F) (σ' : WorldHistory F'), I.Rel σ σ' →
      ∀ t : F.Duration, TruthAt M σ t φ ↔
        TruthAt M' σ' (I.dur t) φ
```
]

`TruthCorr M M'` bundles what it takes for two models to agree formula by formula, and the induction over `Formula` is done once, here.
`shiftCorr` supplies that bundle for a shift, and `timeShift_preserves_truth` is the transport at `shiftCorr M (y - x)` followed by the arithmetic `x + (y - x) = y`.
The design point generalizes past this one lemma.
Where a library proves one transport lemma and then instantiates it, a reader has one induction to audit rather than one per result.

Soundness is what makes the two routes agree.
The derivation of *MF* and the validity of *MF* are independent facts until `soundness` (@lean-appendix-reading-source) says that every derivable formula is valid, and the *MF* case of that proof is precisely where `modal_future_valid`, and through it time-shift invariance, is spent.

The two routes also differ in what they cost at the kernel.
`#print axioms` on `perpetuity2` reports `[propext]` alone, while `timeShift_preserves_truth` reports `[propext, Quot.sound]` and the metalogic results of @lean-appendix-reading-source report all three of the standard classical axioms.
The audit reports what a proof actually used rather than a fixed preamble, which is what makes it worth running.

== Derivations Are Data <lean-appendix-derivations-as-data>

@lean-appendix-types-props said that `DerivationTree` lives in `Type` rather than `Prop` because the codebase computes with derivations.
This section shows one such computation.
`lift` takes a derivation at one frame class and returns a derivation of the same formula at a larger one:

#lean-code(source: ("FormalSystem.ProofSystem", "DerivationTree.lift"))[
```
def lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂)
    {Γ : Context} {φ : Formula} :
    DerivationTree fc₁ Γ φ → DerivationTree fc₂ Γ φ
  | .axiom Γ φ h h_fc => .axiom Γ φ h (le_trans h_fc h_le)
  | .assumption Γ φ h => .assumption Γ φ h
  | .modus_ponens Γ φ ψ d1 d2 =>
      .modus_ponens Γ φ ψ (d1.lift h_le) (d2.lift h_le)
  | .necessitation φ d => .necessitation φ (d.lift h_le)
  | .temporal_necessitation φ d =>
      .temporal_necessitation φ (d.lift h_le)
  | .time_reflection φ d => .time_reflection φ (d.lift h_le)
  | .weakening Γ Δ φ d h => .weakening Γ Δ φ (d.lift h_le) h
```
]

This is structural recursion again, now over derivations rather than over formulas, and with one clause per inference rule instead of one per connective.
Six of the seven clauses are pure bookkeeping.
They rebuild the same constructor around lifted sub-derivations and change nothing else.
All of the work is in the first clause, and there is a reason it is the only one.
The `axiom` constructor is the sole place a frame class is checked at all, through the side condition `h.minFrameClass ≤ fc` of @lean-appendix-types-props.
Lifting therefore has to produce a new proof of that side condition, and `le_trans` produces it by composing the old one with `h_le`.
Every other rule is frame-class agnostic, so there is nothing for the other six clauses to repair.

The order `h_le` refers to is a genuine partial order on the four-element `FrameClass`:

#lean-code(source: ("FormalSystem.ProofSystem", "FrameClass"))[
```
instance : LE FrameClass where
  le a b := match a, b with
    | .Base, _ => True
    | .Dense, .Dense => True
    | .Dense, .RTime => True
    | .RTime, .RTime => True
    | .ZTime, .ZTime => True
    | _, _ => False
```
]

`FrameClass.Base` is below everything, `FrameClass.Dense` is below `FrameClass.RTime`, and `FrameClass.ZTime` is comparable only with itself.
The order is a branch and not a chain, which is the proof-theoretic shadow of the dense-versus-discrete dichotomy of @sec:dichotomy.
A `PartialOrder FrameClass` instance is registered, so `le_trans` above is Mathlib's, and a `DecidableRel` instance makes every closed order goal a `decide`:

#lean-code[
```
example : FrameClass.Base ≤ FrameClass.Dense := by decide
example : FrameClass.Base ≤ FrameClass.ZTime := by decide
example : FrameClass.Dense ≤ FrameClass.RTime := by decide
example : ¬(FrameClass.ZTime ≤ FrameClass.Dense) := by decide
```
]

Which is what makes `lift` pleasant to call.
The side condition is discharged by the elaborator rather than by the caller:

#lean-code[
```
example (φ : Formula) (d : ⊢ φ) : ⊢[FrameClass.Dense] φ :=
  DerivationTree.lift (by decide) d
```
]

Step back and the reason for the `Type` declaration is visible.
Because a derivation is data, the decision procedure of @lean-appendix-reading-source can *return* one as its certificate of validity, `DerivationTree.height` can recurse on one to give the deduction theorem its termination measure, and the dataset pipeline of @sec:dataset-pipeline can serialize one to disk.
None of these is available for a `Prop`-valued derivability predicate, which by design remembers only *that* a derivation exists.

== Naming and Documentation Conventions <lean-appendix-conventions>

The naming rules of `FormalSystem/` are Mathlib's.
They key on what a declaration *produces* rather than on which command declares it, so a name's capitalization already tells a reader what kind of thing it is:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header(
      [*Produces*], [*Case*], [*Examples*],
    ),
    table.hline(),
    [data], [lowerCamelCase], [`reflectTime`, `always`],
    [a `Prop` or a `Type`], [UpperCamelCase], [`TruthAt`, `Formula`],
    [a proof], [snake_case], [`soundness`, `completeness`],
    [a tactic], [snake_case], [`modal_search`, `apply_axiom`],
    table.hline(),
  ),
  caption: none,
)

Three consequences are worth knowing before searching the source.

- *Derived theorems of TM are `def`s.* A result such as `perpetuity1` is mathematically a theorem, but its Lean type is `DerivationTree`-valued, hence data (@lean-appendix-types-props). Lean therefore requires `def` rather than `theorem`, and the name is lowerCamelCase. Most of `FormalSystem/Theorems/` has this form.
- *Constructors are named for what they encode.* The constructors of `Axiom` and `DerivationTree` carry the snake_case names of the axioms and rules themselves (`modal_t`, `modus_ponens`, `temporal_necessitation`). `modal_t` is, in addition, the name of a tactic that applies that axiom, so the constructor is always written qualified, as `Axiom.modal_t`.
- *A few tactics are lowerCamelCase*, `propDecide` among them, against the general rule.

Namespaces mirror the directory structure: the declarations of `FormalSystem/Syntax/` live in `FormalSystem.Syntax`, and those of `FormalSystem/Metalogic/BXCanonical/` in `FormalSystem.Metalogic.BXCanonical`.
`open` is used sparingly, in favor of qualified names wherever a short name would be ambiguous.

A module opens with a docstring (#raw("/-! # Title ... -/")) stating its main definitions, main results, and implementation notes, and each nontrivial declaration carries its own #raw("/-- ... -/") docstring.
The excerpts in this appendix omit these for space, but in the source they are the first thing to read.
`variable` blocks hoist repeated implicit or instance arguments (a frame `F`, a frame class `fc`) out of the individual signatures within a section.
Unicode notation (`□`, `◇`, `⊢`, `Γ`, `φ`, `ψ`) follows the symbols the book's own mathematics uses, so that a Lean declaration and its prose statement read as the same expression in two fonts rather than as a translation.

== Lake and Project Layout <lean-appendix-lake>

*Lake* is Lean's build tool.
The project configures it declaratively, in the #link("https://toml.io")[TOML] file `lakefile.toml`, rather than by Lake's alternative Lean-syntax configuration file (conventionally named #raw("lakefile.lean")), which this project does not use.

- *Package and libraries.* The package is named `BimodalLogic`. Its main library, and its only default build target, is `FormalSystem`. The test library is `BimodalTest` (`srcDir = "Tests"`). The dataset and benchmark tooling of Part II is a separate library, `BimodalTools`, built only on request.
- *Mathlib.* A `[[require]]` block pins Mathlib to a specific tagged revision, so the whole project builds against one frozen, reproducible mathematical library rather than a moving target.
- *Toolchain.* `lean-toolchain` at the repository root pins the Lean 4 release itself. `elan`, Lean's toolchain manager, reads this file and switches toolchains automatically per directory.

Three commands cover day-to-day reading.

- `lake build` compiles the default target, which is the whole `FormalSystem` library, and `lake build FormalSystem` names the same target explicitly.
- #raw("lake env lean FILE.lean") runs the Lean elaborator on a standalone file with the project's dependencies and import path resolved. This is how this appendix's didactic snippets were checked, in a scratch file outside `FormalSystem/` and `Tests/`.
- `import FormalSystem`, or a specific submodule such as `import FormalSystem.Syntax.Formula`, brings the library into scope in any such file.

=== What Is Pinned, and How Much There Is

The two pins and the three library sizes are the project's vital statistics.
Every figure below is read from a generated file, regenerated from live source by a script and diffed against a fresh regeneration by the repository's own sync check, so none of them is typed by hand.

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (left, left),
    table.hline(),
    table.header([*Pin*], [*Value*]),
    table.hline(),
    [Lean toolchain], [#text(size: 8pt, raw(lean-toolchain-pin))],
    [Mathlib, requested tag], [#text(size: 8pt, raw(mathlib-tag))],
    [Mathlib, resolved commit], [#text(size: 8pt, raw(mathlib-rev))],
    table.hline(),
  ),
  caption: none,
)

The tag and the commit are reported separately on purpose.
The tag is what `lakefile.toml` asks for and the commit is what Lake actually fetched, and a tag that moved upstream would change the second while leaving the first alone.
Mathlib has no version number of its own, since it tags releases to track the Lean release they build against, so the toolchain string and the Mathlib tag agreeing here is expected rather than a coincidence.

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, right, right),
    table.hline(),
    table.header([*Tree*], [*Files*], [*Lines*]),
    table.hline(),
    [`FormalSystem/`], [#figcount(formalsystem-file-count)], [#figcount(formalsystem-line-count)],
    [`Tests/`], [#figcount(tests-file-count)], [#figcount(tests-line-count)],
    [`BimodalTools/`], [#figcount(tools-file-count)], [#figcount(tools-line-count)],
    table.hline(),
  ),
  caption: none,
)

These are the three *live* trees.
The archived `Boneyard/` is excluded from all three rows rather than folded into any of them, for the reason @lean-appendix-reading-source gives.
The `FormalSystem/` file count is cross-checked against the generated library root, which carries exactly one `import` line per module, so a file added without regenerating that root is caught rather than silently mis-counted.

=== The Layer Order

`FormalSystem/` is not a flat collection of directories.
Its modules are arranged in import layers, and no module imports from a layer above its own.

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (left, left),
    table.hline(),
    table.header([*Layer*], [*Directories*]),
    table.hline(),
    [0, foundation], [`FormalSystem/ForMathlib/`, `FormalSystem/Tactic/`, `FormalSystem/Syntax/`, `FormalSystem/ProofSystem/`, `FormalSystem/PlusLanguage/`],
    [1], [`FormalSystem/Semantics/`],
    [2], [`FormalSystem/Metalogic/`],
    [3], [`FormalSystem/Theorems/`],
    [4], [`FormalSystem/Automation/`],
    [5], [`FormalSystem/Examples/`],
    table.hline(),
  ),
  caption: none,
)

Reading in that order is reading in dependency order, and it is the order this appendix's own sections follow.
Two entries in layer 0 are worth a note.
`FormalSystem/ForMathlib/` imports nothing from the rest of the library at all, because it is written to be upstreamed into Mathlib unchanged.
`FormalSystem/Tactic/` holds only attribute and simp-set declarations, and it sits upstream of everything so that every module inherits them without importing anything else.

=== Four Proof Systems

The book studies *TM* alongside three neighboring object languages, and each is a self-contained component with its own formula type, axioms and derivation trees.

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*System*], [*Directory*], [*Language*]),
    table.hline(),
    [*TM*], [`FormalSystem/Syntax/`, `FormalSystem/ProofSystem/`], [the language of Part I],
    [*TM*#super[−]], [`FormalSystem/MinusLanguage/`], [tense primitives, @sec:conservative-extension],
    [*TM*#super[+]], [`FormalSystem/PlusLanguage/`], [one stability modal added, @ch:vlach-blstar],
    [*TM*#super[⋆]], [`FormalSystem/StarLanguage/`], [the wider extension of @ch:vlach-blstar],
    table.hline(),
  ),
  caption: none,
)

Each is developed over all four frame classes, using the same `FrameClass` index of @lean-appendix-types-props.
There is a fifth component, `FormalSystem/OpenLanguage/`, which carries a formula type, a truth definition and a validity notion but *no* proof system, so it appears in no row above.

*TM*#super[+] is the one whose relationship to *TM* is settled at every frame class.
Its soundness is `plus_soundness_base` and its three siblings, and conservativity over *TM* is `plusDerivable_ofFormula_iff` in the namespace `FormalSystem.Metalogic.Conservativity`, with a corollary per frame class.
That result says a formula of *TM* is a theorem of *TM*#super[+] exactly when it is a theorem of *TM*, so the added modal proves nothing new in the old language.

Two files with similar names hold different results, and conflating them is easy.
`FormalSystem/Metalogic/Conservativity/Plus.lean` aggregates the *TM*#super[+] result just described, which holds at all four frame classes.
`FormalSystem/Metalogic/Conservativity.lean` is about a different pair entirely, the *TM*#super[−] and *TM* bridge of @sec:conservative-extension, and its own module documentation is the place to read what is and is not established there.

For general Lean 4 reference beyond this appendix's scope, see the #link("https://leanprover.github.io/theorem_proving_in_lean4/")[Theorem Proving in Lean 4] book, the #link("https://lean-lang.org/documentation/")[Lean 4 documentation], and the #link("https://leanprover-community.github.io/mathlib4_docs/")[Mathlib4 docs].

== Reading `FormalSystem/` Source <lean-appendix-reading-source>

=== The Directory Tour

`FormalSystem/` is organized so that each directory backs a recognizable stretch of this book.
@lean-appendix-lake gives the same directories in import order, which is the order to read them in.

- `FormalSystem/Syntax/` -- `Formula` and its derived operators (@sec:formulas, @lean-appendix-inductive).
- `FormalSystem/ProofSystem/` -- the #axiom-count axiom constructors of `Axiom`, and the #rule-count inference rules of the `DerivationTree` and `Derivable` machinery (@sec:proof-theory), together with the `FrameClass` order and the functions on derivations of @lean-appendix-derivations-as-data.
- `FormalSystem/Semantics/` -- temporal orders, task frames, models, histories, and truth conditions (@sec:truth), which are the declarations @lean-appendix-structures through @lean-appendix-recursion read.
- `FormalSystem/Metalogic/` -- soundness and the completeness theorems at every frame class, the compactness results and their two refutations, the decision procedure, and the conservativity bridges (@sec:metalogic, @sec:decidability-practice). The result map below is the guide to it.
- `FormalSystem/Theorems/` -- the derived-theorem library, including the perpetuity principles read in @lean-appendix-derived-theorem.
- `FormalSystem/Automation/`, `FormalSystem/Examples/` -- the proof tactics and worked examples of Part II (@sec:proof-automation), and the dataset pipeline of @sec:dataset-pipeline.
- `FormalSystem/MinusLanguage/`, `FormalSystem/PlusLanguage/`, `FormalSystem/StarLanguage/`, `FormalSystem/OpenLanguage/` -- self-contained components for the neighboring object languages: the deferred tense-primitive subsystem of @sec:conservative-extension, and the extensions of *TM* surveyed in @ch:vlach-blstar.
- `FormalSystem/ForMathlib/` -- Mathlib-shaped extensions written to be upstreamed (the prime-filter API used in the algebraic route through completeness), importing nothing from the rest of `FormalSystem/`.
- `FormalSystem/Tactic/` -- the attributes and named `simp` sets the library registers, placed upstream of every other module.

One file deserves a first visit: `FormalSystem/MainResults.lean` proves nothing, but lists the headline metatheory on one page and runs the two audit commands described below over each result.
One directory is explicitly *not* live: `Boneyard/`, at the repository root and outside `FormalSystem/`, holds archived material, superseded constructions kept for historical reference.
Nothing this book cites resolves there.

=== Two Worked Statements

Two walkthroughs connect the book's central metatheoretic results to their declarations.
Soundness first:

#lean-code(source: ("FormalSystem.Metalogic", "soundness"))[
```
theorem soundness (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Base Γ φ)
    (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ
```
]

Everything before the final colon is a hypothesis, and what follows it is the conclusion.
The statement reads: given a `FrameClass.Base` derivation `d` of `φ` from `Γ`, and *any* frame, model, history, and time at which every formula in `Γ` is true, `φ` is true there too.
The semantic parameters (`F`, `M`, `τ`, `t`) are universally quantified because soundness must hold for every model, not for some fixed one.
`soundness_dense`, `soundness_ztime`, and `soundness_rtime` have the same shape for the other three frame classes.
Each takes a derivation at its own frame class and adds the matching order-theoretic hypotheses on `F.Duration`, such as `[DenselyOrdered F.Duration]` in the dense case.

Completeness runs in the other direction:

#lean-code(source: ("FormalSystem.Metalogic.BXCanonical", "completeness"))[
```
theorem completeness (φ : Formula) :
    Valid φ → Derivable FrameClass.Base [] φ
```
]

Every formula valid on all task frames is derivable in the base system.
Note the `Prop`-valued `Derivable` in the conclusion: the canonical-model argument shows that a derivation exists without constructing one, which is exactly what `Derivable` was introduced to express (@lean-appendix-types-props).
Together with `soundness` at the empty context, this yields the biconditional `Valid φ ↔ Derivable FrameClass.Base [] φ`.
This is the weak, premise-free form of completeness, and @sec:completeness-theorems states the strongest form each frame class admits.

=== The Result Map

The two worked statements above are the entry points to a larger set.
Each of the four metalogical results is proved, or refuted, separately at each of the four frame classes, and the four tables below are the complete map.
Read them together rather than singly, because the pattern across them is the point.

*Soundness*, that a derivation at a frame class yields truth at every model of that class:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Frame class*], [*Declaration*], [*Status*]),
    table.hline(),
    [Base], [`soundness`], [proved],
    [Dense], [`soundness_dense`], [proved],
    [ZTime], [`soundness_ztime`], [proved],
    [RTime], [`soundness_rtime`], [proved],
    table.hline(),
  ),
  caption: none,
)

*Weak completeness*, that a formula valid on the class is derivable at it:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Frame class*], [*Declaration*], [*Status*]),
    table.hline(),
    [Base], [`completeness_base`], [proved],
    [Dense], [`completeness_dense`], [proved],
    [ZTime], [`completeness_ztime`], [proved],
    [RTime], [`completeness_rtime`], [proved],
    table.hline(),
  ),
  caption: none,
)

Each of these has type `WeakCompleteness` at its own tag, which unfolds to the statement written out longhand in the `completeness` excerpt above.
That excerpt and `completeness_base` are the same claim, not two, because validity on the base class and validity outright are definitionally equal:

#lean-code[
```
example : ValidIn FrameClass.Base = Valid := rfl
```
]

The remaining two results are where the frame classes part company.
*Compactness*, that a set of premises with an unsatisfiable consequence already has a finite such subset:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Frame class*], [*Declaration*], [*Status*]),
    table.hline(),
    [Base], [`compactBase`], [proved],
    [Dense], [`compactDense`], [proved],
    [ZTime], [`notCompactZTime`], [refuted],
    [RTime], [`notCompactRTime`], [refuted],
    table.hline(),
  ),
  caption: none,
)

*Strong completeness*, weak completeness with an arbitrary set of premises carried along:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Frame class*], [*Declaration*], [*Status*]),
    table.hline(),
    [Base], [`strongCompletenessBase`], [proved],
    [Dense], [`strongCompletenessDense`], [proved],
    [ZTime], [`notStrongCompletenessZTime`], [refuted],
    [RTime], [`notStrongCompletenessRTime`], [refuted],
    table.hline(),
  ),
  caption: none,
)

The last two tables say something a reader should not misread.
*Refuted* is not *unproved*.
A row marked refuted names a theorem whose statement carries a negation, proved to the same standard and audited by the same commands as every other row.
The library is not silent about compactness at `FrameClass.ZTime`.
It says that compactness fails there, and it says so with a witness:

#lean-code(source: ("FormalSystem.Metalogic", "notCompactZTime"))[
```
theorem notCompactZTime : ¬ CompactZTime :=
  not_compact_of_witness
    (archWitness_finitely_satisfiable ⟨"p", none⟩)
    (archWitness_not_satisfiable ⟨"p", none⟩)
```
]

The two arguments are the two halves of a counterexample, namely a set of formulas every finite part of which is satisfiable while the whole is not.
Both are applied to the atom built by the *anonymous constructor* `⟨"p", none⟩`, which is `Atom`'s two fields written without naming the structure, Lean supplying the type from the expected argument.
The discrete and Dedekind refutations use different witnesses, `archWitness` at `⟨"p", none⟩` and `dedWitness` at `⟨"q", none⟩`, and the first does not port to the second.
The discrete witness is built from `Formula.next`, which is vacuous on a densely ordered carrier, so a genuinely different set of formulas is needed on the dense side.
@sec:dichotomy is where the mathematics of the split is argued.

The proved rows compose out of one another, and the composition is legible in the Lean.
Strong completeness at the base class is a single term:

#lean-code(source: ("FormalSystem.Metalogic", "strongCompletenessBase"))[
```
theorem strongCompletenessBase : StrongCompletenessBase :=
  strongCompleteness_of_compact compactBase completeness_base
```
]

`StrongCompletenessBase` is a `Prop`-valued `def` declared in a separate module, which lets the statement be named once as vocabulary and discharged elsewhere.
The proof supplies compactness and the weak-completeness engine to one class-generic reduction, so the whole of the class-dependence sits in the two arguments rather than in the argument's shape.
This is why the compactness row and the strong-completeness row agree at every frame class.

Where the underlying proofs live is worth knowing before opening anything.

- *The chronicle route*, `FormalSystem/Metalogic/BXCanonical/`, carries the flagship completeness theorems. It builds a canonical chain of chronicles and reads a countermodel off it.
- *The Kamp and Reynolds route*, `FormalSystem/Metalogic/WeakCanonical/`, supplies the reflexive canonical model and the integer, real and group constructions the discrete and Dedekind cases need. It sits beside the chronicle route rather than under it, and the two import from each other.
- *The algebraic route*, `FormalSystem/Metalogic/Algebraic/`, supplies the Lindenbaum-Tarski quotient and the ultrafilter correspondence.
- *Compactness* takes none of these. It is an ultraproduct over `Ultraproduct.Idx`, the finite lists drawn from the premise set, with one model per index supplied by finite satisfiability and truth pulled back by `Ultraproduct.los_truthAt`. Strong completeness then follows uniformly, as the term above shows.

The single hypothesis that the frame condition survives the ultraproduct is the whole of the class-dependence, and it is exactly what fails at the discrete and Dedekind classes.
@sec:completeness-theorems states the strongest form each frame class admits, and @sec:metalogic sets the four results in their mathematical context.

=== The Decision Procedure

The results above are about derivability and truth.
The decision procedure of @sec:decidability-practice is about *computing*, and its types say precisely how far the computation is trusted.
Its return type has four constructors, which is one more than a naive reading of "decides" would suggest:

#lean-code(source: ("FormalSystem.Metalogic.Decidability", "DecisionResult"))[
```
inductive DecisionResult (φ : Formula) : Type where
  | valid (proof : ⊢ φ)
  | invalid (counter : SimpleCountermodel)
  | fuelExhausted
  | extractionFailed
  deriving Repr
```
]

The type is indexed by the formula, so a `DecisionResult φ` can only be a verdict about `φ`.

- *`valid`* carries a derivation. This is @lean-appendix-derivations-as-data's payoff. A positive verdict is not a Boolean to be trusted but a proof term the kernel can re-check.
- *`invalid`* carries a `SimpleCountermodel`, which is the refuting structure rather than a bare `false`.
- *`fuelExhausted`* is the honest undecided case. The tableau ran out of budget before reaching any verdict.
- *`extractionFailed`* is a fourth outcome kept deliberately distinct from the third. Every tableau branch closed, which is the tableau-level witness of validity, and only the reconstruction of a proof term failed. Folding it into `fuelExhausted` would have the procedure claim ignorance about formulas it had in fact settled.

The entry point shows Lean's *optional parameters*:

#lean-code(source: ("FormalSystem.Metalogic.Decidability", "decide"))[
```
def decide (φ : Formula) (searchDepth : Nat := 10)
    (tableauFuel : Nat := 1000) (fc : FrameClass := .Base) :
    DecisionResult φ
```
]

A `:=` inside a binder gives that argument a default.
Three of the four arguments have one, so the two calls below are the same call:

#lean-code[
```
example (φ : Formula) : DecisionResult φ := decide φ

example (φ : Formula) : DecisionResult φ :=
  decide φ 10 1000 .Base
```
]

A caller overrides `searchDepth := 10` or `tableauFuel := 1000` only when the defaults prove too small.
This is the ordinary way a Lean API offers tuning without making every call site carry it.

What the library proves about all this is narrower than the word *decide* suggests, and it is worth stating exactly.

#lean-code(source: ("FormalSystem.Metalogic.Decidability", "sound_of_isValid"))[
```
theorem sound_of_isValid {φ : Formula}
    (r : DecisionResult φ) (h : r.isValid = true) : ⊨ φ
```
]

- *Established.* A `valid` verdict is sound, by `decide_sound`, because it carries a `⊢ φ` and soundness applies. The `Bool`-level restatement `isValid φ fc = true → ⊨ φ` follows, which is the theorem above. On the tableau side, `ruleSound_of_mem_allRulesForFC` proves that every rule the scheduler can select preserves satisfiability at its frame class. A refuting verdict comes with the countermodel that justifies it.
- *Open.* The converse `⊨ φ → isValid φ fc = true`, and with it the biconditional and a `Decidable (⊨ φ)` instance, is *not* proved. It needs `valid_iff_allClosed`, which in turn needs the termination side and the truth-lemma gate, and it must also account for the two rules scheduled outside `allRulesForFC`, namely `serialityRule` and `timeLinearity`.
- *Open.* Totality against a formula-dependent budget is likewise open. While the fuel is a fixed argument rather than a bound computed from the formula, `fuelExhausted` remains a reachable outcome, which is why it is a constructor rather than an error.

@sec:fmp-resolution and @sec:decidability-practice are where the book states these as open problems and says what would close them.
The Lean side states no biconditional until one can be proved, which is the subject of the next subsection.

=== Trust-Reading Practice

Two commands let a reader audit a declaration without reading its proof.

- `#check`, applied to a declaration name, shows that declaration's type without evaluating anything. It confirms that the statement is the one the book cites before any time is spent on the proof body.
- `#print axioms`, applied to a declaration name, lists every axiom the kernel depended on in checking that declaration's proof.

For the two theorems above, the second command reports:

#lean-code[
```
'FormalSystem.Metalogic.soundness' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness'
  depends on axioms:
  [propext, Classical.choice, Quot.sound]
```
]

These three are the standard axioms of classical reasoning in Lean and Mathlib: propositional extensionality, the axiom of choice, and the soundness of quotient types.
What matters is what is absent.
An unfinished proof is marked in Lean by the placeholder `sorry`, and any declaration depending on one reports the additional axiom `sorryAx`, however deep in its dependencies the gap lies.
The book's count of `sorry` placeholders in live source, currently #sorry-total-excl-boneyard outside the archived `Boneyard/` material, is the source-level companion to this kernel-level check.

There is a second thing the kernel cannot check, and it is the reason both commands above are worth running.
A declaration's *name* is written by its author and is checked by nobody.
Only the statement is checked, so only the statement can be trusted, and a reader who audits the name has audited nothing.

`FormalSystem/` records one instance of this in its own source, in the retirement note in `FormalSystem/Metalogic/Decidability/Correctness.lean`.
Two theorems once stood there whose names claimed a decidability result their proofs did not contain.
The first was `validity_decidable (φ : Formula) : (⊨ φ) ∨ ¬(⊨ φ)`, proved by `exact Classical.em (⊨ φ)`.
That is excluded middle at an arbitrary proposition.
It holds of every predicate whatsoever, produces no procedure and no `Decidable` instance, and says nothing about validity, about tableaux, or about computation.
The second was `validity_has_decision_procedure (φ : Formula) : ∃ decision : Bool, decision = true ↔ ⊨ φ`, proved by a case split on the truth value one is trying to compute.
Its existential is witnessed by the answer rather than by anything that finds the answer, so it is the first theorem again with a `Bool` wrapped around it.

Both statements type-check.
Both are true.
Neither is a decision procedure, and a reader who saw only the names would have concluded otherwise.
`Decidable (⊨ φ)` is the statement that would carry the content, and the previous subsection is where the book says what is still owed before it can be proved.
The declarations were retired rather than quietly deleted, so that the record of the defect survives in the place a reader would look.

Finally, every citation in this book gives a declaration *name*, never a `file:line` pair, because line numbers drift with routine edits while a name survives them.
A Lean editor's go-to-definition, or `lean_declaration_file`-style tooling, resolves a name to its current location instantly.
For the complete name-by-name correspondence between every axiom, rule, and derived operator in the book and its `FormalSystem/` declaration, see #link(<machine-appendix>)[the machine-readable appendix] that follows.
