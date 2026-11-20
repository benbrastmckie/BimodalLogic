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

## Principles

1. **A script shows what it builds.** A reader can tell from the tactic names alone whether a
   script produces a derivation tree, changes only how a formula is written, or proves truth at
   a point of a model. No tactic name serves two of these.
2. **Small checked steps over opaque guarantees.** A tactic inspects formula syntax and theorem
   statements. It uses a supplied proof through its statement and never unfolds it.
3. **Nothing semantic stands in for a derivation.** Soundness carries a derivation to truth.
   Nothing carries truth to a derivation.
4. **A rule's statement names only the operators it is about.** Rules for one operator family are
   stated without any other; rules for an interaction name exactly the families that interact,
   Boolean included.
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

**The semantic tier is a separate mode.** It has its own directory, its own tactic names, its own
guide and its own tests, and it registers nothing on derivation-tier syntax.

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

### Interactions

An interaction is its own module, named by exactly the families its statements join. Boolean
counts as a family here: a rule that names a modal operator and an implication is filed under
Modal with Boolean, never under Modal.

| Interaction | Module | Content |
|---|---|---|
| Modal with Boolean | `ModalBoolean` | K as a formula, distribution of `□` over `∧` and of `◇` over `∨`, duality, each also for `⊡` and `⟐`; `□φ → ⊡φ`; the collapse `φ ↔ ⊡φ` for state-local `φ` |
| Temporal with Boolean | `TemporalBoolean` | distribution of `G` and `H`, the connecting axioms, leads-to consequence, transitivity and cases |
| Modal with Temporal | `ModalTemporal` | `□`-facts crossing into `G`, `H` and always scopes, by MF and TF, stated as scope rules; pasting for `⊡`, with its pure-future and pure-past side conditions |
| Modal with Temporal with Boolean | `ModalTemporalBoolean` | MF and TF as formulas, the perpetuity principles, the pasting schemata as formulas, `Will`, `will`, `Could`, `could` |

Within a module the rules for `□` alone come first and those that name `⊡` are a section of
their own, so that the part TM instantiates can be read off.

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
- the interface: one class per family carrying its pure rules, and one class per interaction
  extending exactly the families it joins;
- the fragments of the theorem library. A fragment is a set of families with Boolean, and it
  contains the rules of every module whose families it includes: the library's `ModalBoolean`
  is this scheme's `Modal` and `ModalBoolean` together. See
  [theorem-library.md](theorem-library.md).

A language is an instance of the classes for the operators it has, and of the Modal class at
each necessity operator it has.
The semantic side already has this shape in its truth-clause classes, one per operator.

### Adding a language extension

A new operator family (a counterfactual, a metric operator, a nominal) adds:

1. one pure module and one class for the family;
2. one interaction module and class with Boolean;
3. one further interaction module and class for each existing family it has a rule with;
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
| `□`-facts into temporal scopes | Derivation | Modal with Temporal | `proof_mode_cross_modal_scopes_mf_tf` |
| always and sometimes | Derivation | Temporal; Modal with Temporal for `□`-facts entering them | `proof_mode_always_sometimes_scopes` |
| Carrying `G` and `H` facts across steps | Derivation | Temporal | contributed; one carrying table shared with the two scope records above |
| Until and Since introduction and monotonicity | Derivation | Temporal | `proof_mode_until_since_intro_unfold_induction`; introduction contributed |
| One-step unfolding and folding, backward induction | Derivation | Temporal at ZTime | same record; contributed, with folding at every class |
| Until and Since induction generalizing invariance | Derivation | Temporal at ZTime | same record; open |
| Linearity cases | Derivation | Temporal | `proof_mode_linearity_case_tactic` |
| Whole-judgment time reflection | Derivation | Temporal | contributed |
| Leads-to consequence, transitivity, cases | Derivation | Temporal with Boolean | `proof_mode_leads_to_invariance_library`; strict form contributed, present-inclusive form open |
| Dense and RTime rules | Derivation | Temporal at Dense and RTime | `proof_mode_dense_and_real_time_rules` |
| Folding and unfolding defined operators, inclusive forms, formula equalities | Views | every family | `proof_mode_views_tier`; partly contributed inside the rewriting tactics, to be separated |
| Logical rewriting under operators, bounded simplification | Derivation | one congruence step per family; seed equivalences under the Boolean interactions | contributed |
| Leaf closing | Derivation | Boolean | `proof_mode_close_leaves_with_automation`, `proof_mode_decision_procedure_leaf_closers` |
| Refutation of an unclosed leaf | none: a diagnostic, it builds nothing | the fragment of the leaf | `proof_mode_countermodels_for_unclosed_leaves`, through the countermodel half of the library |
| Sweeps: library entries proved again in the mode | Derivation | one sweep per fragment | `proof_mode_reprove_perpetuity`, `proof_mode_reprove_temporal_slice`; the entries with `⊡` unfiled |
| One interface, rules proved once | all | one class per family and interaction | `proof_mode_abstract_frontend_interface`; the congruence kit is its first generic piece |
| Truth at a point, witnesses, transport, rank progress | Semantic | per truth-clause class | contributed as overloads of derivation tactics; to be a separate mode |

## Open decisions

1. **Tactic names for views.** One pair (`lunfold`, `lfold`) taking an operator name, or one
   tactic per view.
2. **Where the semantic mode lives.** Under `FormalSystem/Semantics/` it sits at layer 2 and its
   soundness adapter must sit above it; under `FormalSystem/Automation/` it sits beside the
   derivation mode with a directory of its own.
3. **Does the semantic mode get a record and a client before it is built?** Ordinary Lean tactics
   already work on truth goals, so the case for a tactic language rests on proofs it shortens.
4. **Does logical rewriting enter the adequacy measurement?** If it does, the rule set the first
   gate measures grows; if not, rewriting needs its own client.
5. **How is the shared S5 statement carried?** As a structure taking the operator as a field,
   instantiated twice per language, or as a class indexed by the operator. A class keyed on the
   formula type alone cannot hold two instances for TM⁺.
6. **Is `⊡` rightly in the Modal family?** Open decision 2 of
   [theorem-library.md](theorem-library.md), examined in
   `investigate_stability_as_modal_family`. A separate family would add a `Stability` module and
   class and its interactions, and move the sections that name `⊡` into them.
