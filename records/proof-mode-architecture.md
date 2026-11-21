# Proof mode: architecture

This record fixes how proof-mode rules and tactics are organized. Goals, milestones and gates are
in [proof-mode.md](proof-mode.md); the library of results the mode is measured against is in
[theorem-library.md](theorem-library.md). This document says where a rule or a tactic belongs and
what it may depend on. Contributions are placed against it before they are reviewed.

## Aim and measure

The mode exists to make derivations in TM and TM⁺ short to write and plain to read, and then to
carry safety and liveness arguments about systems specified in TM. A capability earns its place
by a proof it makes possible or shorter. The measure is the theorem library: every theorem in it
has a reference proof, a selection chosen for what it tests is proved again in the mode, and the
two are compared fragment by fragment with one set of diagnostics. The adequacy reports are
sweeps over such selections; the Perpetuity principles are one section of the first. A capability that improves
no library entry needs another named client before it is built, and a library entry the mode
cannot close is where the next capability comes from.

Logical rewriting is measured apart from the first gate. `lrewrite` and `lsimp` are not used in
gate-one scripts and do not enter the gate's verdict: the gate measures exactly the rule set
[proof-mode.md](proof-mode.md) fixes for it. Rewriting's client is a second run of the gate-one
selection with the two tactics permitted, reported as a separate comparison. Of the contributed
temporal rules, gate-one scripts may use two, `G`/`H` carrying and whole-judgment time
reflection, each only once it is adopted into M1 of [proof-mode.md](proof-mode.md) before the
selection is fixed. Until and Since introduction, folding and unfolding, next-step carrying,
backward induction and the leads-to rules are not used at gate one. Admitting rewriting to gate
one has a merit: the gate would measure the mode a user actually has, and a rewrite-heavy proof
may be where the mode gains most. It is rejected because it changes what a GO at the gate means,
and the second run gives the same information without moving the gate.

## Principles

1. **A script shows what it builds.** A reader can tell from the tactic names alone whether a
   script produces a derivation tree, changes only how a formula is written, or proves truth at
   a point of a model. No tactic name serves two of these.
2. **Small checked steps over opaque guarantees.** A tactic inspects formula syntax and theorem
   statements. It uses a supplied proof through its statement and never unfolds it.
3. **Nothing semantic stands in for a derivation.** Soundness carries a derivation to truth.
   Nothing carries truth to a derivation.
4. **A rule's statement names only the operators it is about.** Rules for one operator family are
   stated without any other; rules for an interaction name the families that interact, and
   every interaction includes Boolean.
5. **Each rule is proved once.** Languages are instances of an interface, not copies of a file.
6. **A language extension adds modules and changes none.**

## Three tiers

| Tier | What it does | What it may use | What it produces |
|---|---|---|---|
| Views | Changes how a formula is written: folds and unfolds a defined operator, or replaces a formula by an equal one | Definitions and formula equalities only. No axiom, no rule, no context, no frame class | The same judgment, up to definitional equality or a cast |
| Derivation | Builds derivations: scopes, cases, logical rewriting under operators, closing leaves | Derivation constructors and proved derivation rules | `DerivationTree`, `PlusDerivationTree` |
| Semantic | Proves truth at a model, history and time | Truth clauses, semantic lemmas, and derivations through soundness | A proof of a truth judgment |

The tiers are ordered. Views are below both other tiers and may be used by either. The derivation
tier does not import the semantic tier. The semantic tier meets the derivation tier at one
module, the soundness adapter.

**Views are not rewriting.** Unfolding `◇A` to `¬□¬A`, or an inclusive Until to its strict form,
changes no content and can fail only if the formula has the wrong shape. Replacing `A` by `B`
under `□` because `□(A ↔ B)` is derivable is a logical step: it uses modal K, it needs evidence
that survives the scope, and it respects polarity. The first is a view; the second belongs to the
derivation tier. They have different tactic names.

**The views tier has one pair of tactics.** `lunfold` and `lfold` each take a view name. One
table holds the views; a row gives the name, the folded shape, the unfolded shape and the
equality that relates them, `rfl` for a defined operator and a proved formula equality
otherwise. A formula equality is used as a view by registering it as a row, and the pair takes
no free proof term. The elaborators' operator matching reads the same table, so a language
extension adds rows and no syntax. The alternative is one tactic per view. Its merits: each name
is found by completion, a misspelt operator is a parse error instead of a lookup failure, and no
table is needed. It is rejected on count, `Formula` having 26 defined operators and
`PlusFormula` 22 besides the inclusive Until and Since forms, and on principle 6, since each
extension would add tactic syntax.

**The semantic tier is a separate mode.** It has its own directory, its own tactic names, its own
guide and its own tests, and it registers nothing on derivation-tier syntax. Its code is placed
by what it is:

- the semantic lemmas are general semantics and sit in `FormalSystem/Semantics/`, at layer 1;
- the tactics sit in a directory of their own under `FormalSystem/Semantics/`, for example
  `FormalSystem/Semantics/ProofMode/`, at layer 1;
- the soundness adapter is one module at layer 3 under `FormalSystem/Metalogic/`, holding the
  soundness lemma and `luse_derivation`. It imports soundness for each language and the
  semantic mode, and nothing under `FormalSystem/Automation/ProofMode/`.

A layer-1 mode imports layers 0 and 1 only. The two things it shares with the derivation mode,
the views tier and the position and polarity planner, therefore sit at layer 0 or 1 and not
under `FormalSystem/Automation/ProofMode/`; this condition is part of the placement. The mode is
at layer 1 because the semantic proofs are at layers 1 and 2, in `FormalSystem/Semantics/` and
the layer-1 files of the language directories, and a mode at layer 3 can be used by none of
them. The alternative is `FormalSystem/Automation/`, beside the derivation mode. Its merits: the
views and the planner need not sit below layer 3, all tactics are in one place, and
`ORGANISATION.md` describes `Automation/` as tactics and proof search. It is rejected because it
makes the mode unusable below layer 3.

**The semantic mode has a record and a measured client before any tactic is built.** The record
is `records/semantic-proof-mode.md`, which is to be written; the semantic lemmas need neither
and come first. Ordinary Lean tactics already work on truth goals, so the case for a tactic
language rests on proofs it shortens. The countermodel half of the theorem library is a
candidate client, and the record makes it a measured one: it names the declarations, and each is
proved again twice, once with the lemmas alone and once with the tactics, both reported against
the existing proofs. The run with the lemmas alone is the control: if the lemmas give the
saving, the tactic language has no client there. The alternative is to count the countermodel
half as an established client. Its merit: its entries are truth proofs at a model, the same kind
of measure the derivation mode has. It is rejected because no comparison exists, and the
refutations in the tree are short in ordinary Lean, so a saving is not evident from reading
them.

## Operator families

Rules are filed by the operators their statements name.

### Families

| Family | Operators | Rules stated with these alone |
|---|---|---|
| Boolean | `⊥`, `→`, and the defined `¬`, `∧`, `∨`, `↔`, `⊤` | assumption, cut, introduction and elimination for each connective |
| Modal | `□`, `◇`; in TM⁺ also the stability operator `⊡` and its dual `⟐` | scope introduction (from `□Γ ⊢ A` to `□Γ ⊢ □A`), T, 4, 5, `◇` introduction and consequence, each for both operators; a `□`-fact gives a `⊡`-fact |
| Temporal | Future: `U`, `F`, `G`. Past: `S`, `P`, `H`. Both: always, sometimes | scope introduction for `G` and `H`, Until and Since introduction, guard and event monotonicity, bind, temporal 4, linearity cases, whole-judgment time reflection, always and sometimes |

A pure rule is stated at the level of judgments, so it needs no connective from another family:
scope introduction takes a context of `□`-facts to a `□`-conclusion and mentions no implication,
where the axiom K mentions both. **A pure family module contains no implication in any
statement.** Purity is a property of the statement. The proof of a pure rule uses whatever the
calculus provides.

Views are what make this possible for defined operators. `◇`, `⟐`, `G`, `F` and always are
defined through negation and conjunction; their rules are stated about them directly, and the
view tier relates them to their definitions.

**Each family has its rules in both polarities.** Where a family has a rule for its universal
operator it has the dual rule for its existential one: `◇` beside `□`, `⟐` beside `⊡`, `F` and
`P` beside `G` and `H`, sometimes beside always. A family module with a box rule and no diamond
rule is incomplete.

**The Modal family has two operators and one statement of the S5 rules.** Scope introduction,
T, 4, 5 and the diamond rules are stated once over a necessity operator given as a parameter,
and instantiated at `□` and at `⊡`. A language instantiates them at the operators it has: TM at
`□` only, TM⁺ at both, with the rule from `□` to `⊡` as a member that only a language with both
provides. Two things are particular to `⊡` and are kept out of the shared statement. The schema
`p → ⊡p` holds for atoms and state-local formulas only, so a rule that uses it is not schematic
and says so in its statement. And without a temporal operator `⊡` collapses to the identity, so
its remaining rules are interactions with Temporal. Filing `⊡` under Modal is the position this
design starts from; `investigate_stability_as_modal_family` examines whether it should be a
family of its own.

**The shared statement is a structure taking the operator as a field.** It is instantiated once
per necessity operator per language: for TM at `□`, for TM⁺ at `□` and at `⊡`. The modal
congruence step is one definition taking the structure. The fields are theorems and not axioms,
because TM `□`, TM⁺ `□` and `⊡` have three different axiom bases, so each instance supplies
some fields by derivation. The alternative is a class indexed by the operator. Its merits: call
sites need not name the instance, generic theorems read as ordinary typeclass-polymorphic
statements, and two instances on one formula type do coexist. It is rejected because instance
resolution is keyed on how the operator is written and fails on an operator presented through a
definition, and because the elaborators have the operator in hand anyway. A class keyed on the
formula type alone cannot hold two instances for TM⁺.

### Interactions

An interaction is its own module, named by the families its statements join, and every
interaction includes Boolean: a rule that names a modal operator and an implication is filed
under Modal with Boolean, never under Modal, and a rule that joins Modal and Temporal is filed
under Modal with Temporal with Boolean whether or not its statement names a connective. So
every class other than `Boolean` itself extends `Boolean`, and the interaction modules carry
exactly the names of the theorem library's fragments.

The alternative is a `ModalTemporal` module for the rules that join the two families and name
no connective, the `□`-facts crossing into temporal scopes. Its merit: those rules are pure, so
the purity rule would hold for an interaction as it does for a family. It is rejected because
the module would hold a handful of rules, no language here has Modal and Temporal without
Boolean, and no library fragment corresponds to it, so the scheme would carry a name used in
one of its six places.

| Interaction | Module | Content |
|---|---|---|
| Modal with Boolean | `ModalBoolean` | K as a formula, distribution of `□` over `∧` and of `◇` over `∨`, duality, each also for `⊡` and `⟐`; `□φ → ⊡φ`; the collapse `φ ↔ ⊡φ` for state-local `φ` |
| Temporal with Boolean | `TemporalBoolean` | distribution of `G` and `H`, the connecting axioms, leads-to consequence, transitivity and cases |
| Modal with Temporal with Boolean | `ModalTemporalBoolean` | `□`-facts crossing into `G`, `H` and always scopes, by MF and TF, stated as scope rules; MF and TF as formulas; the perpetuity principles; pasting for `⊡`, with its pure-future and pure-past side conditions, as scope rules and as formulas; `Will`, `will`, `Could`, `could` |

Within a module the rules for `□` alone come first and those that name `⊡` are a section of
their own, so that the part TM instantiates can be read off. Within `ModalTemporalBoolean` the
scope rules, whose statements name no connective, are a section of their own ahead of the
formulas.

### Frame class

Frame class is a second axis, written as a suffix on the family or interaction. A rule that holds
only at a class is filed there, with the certificate as an explicit premise.

| Module | Rules |
|---|---|
| `TemporalZTime` | Next and Previous, one-step unfolding of Until and Since, invariance, backward induction |
| `TemporalDense` | density |
| `TemporalRTime` | prior-Until gap, separation, continuity |

### One scheme, used six times

A module name is the list of families its statements name, in the order Modal, Temporal,
Boolean, followed by a frame class if it needs one. The same names are used for:

- the pure-rule modules under `FormalSystem/Theorems/ProofMode/`;
- the tactic modules under `FormalSystem/Automation/ProofMode/`;
- the test files under `Tests/BimodalTest/Automation/ProofMode/`;
- the guide pages under `docs/user-guide/proof-mode/`;
- the interface: the `Boolean` class, one class per further family carrying its pure rules
  and extending `Boolean`, and one class per interaction extending the classes of the families
  it joins;
- the fragments of the theorem library. A fragment is a set of families with Boolean, and it
  contains the rules of every module whose families it includes: the library's `ModalBoolean`
  is this scheme's `Modal` and `ModalBoolean` together, and its `ModalTemporalBoolean` adds
  `Temporal`, `TemporalBoolean` and this scheme's `ModalTemporalBoolean`. See
  [theorem-library.md](theorem-library.md).

A language is an instance of the classes for the operators it has, and supplies the Modal
family's structure at each necessity operator it has.
The semantic side already has this shape in its truth-clause classes, one per operator.

The views tier and the position and polarity planner are filed outside the tactic directory
above. Both are formula-syntax only and are shared by the derivation mode and the semantic mode,
so they sit at layer 0 or 1, under the rule in `ORGANISATION.md` that puts shared metaprogramming
in `FormalSystem/Tactic/`.

### Adding a language extension

A new operator family (a counterfactual, a metric operator, a nominal) adds:

1. one pure module and one class for the family;
2. one interaction module and class with Boolean;
3. one further interaction module and class, Boolean included, for each existing family it has
   a rule with;
4. its views, for any operator it defines;
5. its fragments in the theorem library, with entries in both polarities, the conservativity
   theorems for the new edges, and a sweep over a selection of the entries.

No existing module, class, test file, guide page or library entry changes. This is what the separate filing of
Boolean interactions buys: the pure modules of the existing families stay closed, at the cost of
more modules.

### Logical rewriting

Logical rewriting fits the same division. Each operator position supplies one congruence step:
the operator it wraps, the scope a rewrite must be justified in, and whether it flips polarity.
A step belongs to its operator's family class, and composition of steps is generic. The
equivalences a simplifier is seeded with are interaction rules and live in the interaction's
module.

## Where the work sits

| Capability | Tier | Family or interaction | Record in [proof-mode.md](proof-mode.md) |
|---|---|---|---|
| The layout itself: modules, tests and guide pages by family | all | all | `proof_mode_split_shared_test_and_guide_files` |
| Named assumptions, cut, connective rules | Derivation | Boolean | merged |
| `□` and `⊡` scopes carrying facts by 4 and 5 | Derivation | Modal | `proof_mode_s5_aware_box_scopes` |
| `□`-facts into temporal scopes | Derivation | Modal with Temporal with Boolean, in its scope-rule section | `proof_mode_cross_modal_scopes_mf_tf` |
| always and sometimes | Derivation | Temporal; Modal with Temporal with Boolean for `□`-facts entering them | `proof_mode_always_sometimes_scopes` |
| Carrying `G` and `H` facts across steps | Derivation | Temporal | contributed; one carrying table shared with the two scope records above |
| Until and Since introduction and monotonicity | Derivation | Temporal | `proof_mode_until_since_intro_unfold_induction`; introduction contributed |
| One-step unfolding and folding, backward induction | Derivation | Temporal at ZTime | same record; contributed, with folding at every class |
| Until and Since induction generalizing invariance | Derivation | Temporal at ZTime | same record; statement proposed and not yet derived, see M4 of [proof-mode.md](proof-mode.md) |
| Linearity cases | Derivation | Temporal | `proof_mode_linearity_case_tactic` |
| Whole-judgment time reflection | Derivation | Temporal | contributed |
| Leads-to consequence, transitivity, cases | Derivation | Temporal with Boolean | `proof_mode_leads_to_invariance_library`; the rules are stated for the present-inclusive definition, and the contributed strict rules are the layer beneath it |
| Dense and RTime rules | Derivation | Temporal at Dense and RTime | `proof_mode_dense_and_real_time_rules` |
| Folding and unfolding defined operators, inclusive forms, formula equalities | Views | every family | `proof_mode_views_tier`; the pair is `lunfold` and `lfold`; the first rows of the view table are contributed with the rewriting tactics, exposed through the pair |
| Logical rewriting under operators, bounded simplification | Derivation | Generic path composition, closed family congruence, and seed equivalences from Boolean interactions | M17; `lrewrite` and `lsimp` apply native rules only. The syntax planner is shared with other tiers. |
| Leaf closing | Derivation | Boolean | `proof_mode_close_leaves_with_automation`, `proof_mode_decision_procedure_leaf_closers` |
| Refutation of an unclosed leaf | none: a diagnostic, it builds nothing | the fragment of the leaf | `proof_mode_countermodels_for_unclosed_leaves`, through the countermodel half of the library |
| Sweeps: library entries proved again in the mode | Derivation | one sweep per fragment | `proof_mode_reprove_perpetuity`, `proof_mode_reprove_temporal_slice`, `theorem_library_stability_entries` |
| One interface, rules proved once | all | one class per family and interaction | `proof_mode_abstract_frontend_interface`; the congruence kit is its first generic piece |
| Truth at a point, witnesses, transport, rank progress | Semantic | per truth-clause class | contributed as overloads of derivation tactics; to be a separate mode in a directory of its own under `FormalSystem/Semantics/`, with one adapter module at layer 3, after `records/semantic-proof-mode.md` |

## Open decisions

1. **Is `⊡` rightly in the Modal family?** The question of that name under "Open decisions" of
   [theorem-library.md](theorem-library.md), examined in
   `investigate_stability_as_modal_family`. A separate family would add a `Stability` module and
   class and its interactions, and move the sections that name `⊡` into them.
2. **Do the Until and Since tactics keep `unfold` and `fold` as keywords?** The contributed
   `luntil unfold` and `luntil fold` are derivation steps that use the ZTime axioms, where
   `lunfold` and `lfold` name views. The tactic heads differ, so principle 1 is met to the
   letter, but one word then names a view and a logical step. The options are to keep the
   keywords, or to rename them `expand` and `contract` so that fold and unfold belong to the
   views tier alone. The recommendation is to rename. This is a matter of taste and awaits the
   user's ruling.
