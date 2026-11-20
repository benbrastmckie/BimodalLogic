# Theorem and countermodel library

This record fixes what the library of TM results is, how it is organized, how results enter it,
and how it is used to measure and improve the derivation proof mode. The mode's own organization
is in [proof-mode-architecture.md](proof-mode-architecture.md); its goals, milestones and gates
are in [proof-mode.md](proof-mode.md).

## Aim

`BimodalLib` holds every result about what follows from what in TM and its extensions, in three
parts: **theorems**, each a valid inference with a derivation; **countermodels**, each an
invalid inference with a checked refutation; and **conjectures**, each a statement earmarked as
not yet established either way. It is organized by language fragment, so that a result is stated
once at the smallest language that can state it and inherited by every larger one, and so that a
new operator family extends the library without reorganizing it.

The library is the mode's test bed. Every theorem in it has a reference proof; a selection is
proved again in the proof mode; the two are compared by a fixed set of measurements; and what
the comparison finds wrong is what the mode works on next. The Perpetuity principles are one
section of the library, not its extent.

## Principles

1. **A statement is filed where its operators put it.** The fragment of a statement is computed
   from the operators that occur in it. Nobody chooses it.
2. **One statement, several proofs.** A statement is registered once. A hand proof, a proof
   extracted from the tableau and a proof-mode script are three proofs of the same registered
   statement, and comparison is between proofs of one statement.
3. **Every entry is kernel-checked.** A theorem entry carries a derivation. A countermodel entry
   carries a proof of non-validity. A statement with neither is a conjecture, kept apart and
   never cited as a result. Nothing in the library contains `sorry`.
4. **Theorems travel up, countermodels travel down.** A theorem holds in every larger language
   and every stronger frame class. A countermodel refutes in every smaller frame class, and in
   every larger language that is semantically conservative over its own. Each step of either
   kind rests on a named conservativity or transfer theorem.
5. **Each operator is entered in both polarities.** `□` with `◇`, `⊡` with its dual `⟐`, `G`
   with `F`, `H` with `P`, always with sometimes. A section that has the box law and lacks the
   diamond law is incomplete.
6. **Every stage of the pipeline reports in one schema.** A figure quoted anywhere is reproduced
   by a named command.

## Fragments

### The lattice

There is one Boolean base and two operator families over it.

| Family | Operators |
|---|---|
| Modal | `□`, `◇`; and in L⁺ the stability operator `⊡` with its dual `⟐` |
| Temporal | `U`, `S`, and the operators defined from them |

A fragment is a set of families; Boolean is in every fragment, because a statement is a formula.

| Fragment | Language it is | Logic |
|---|---|---|
| `Boolean` | propositional | classical |
| `ModalBoolean` | propositional modal, with one or both modal operators | S5 for each operator, `□φ → ⊡φ`, and the collapse `φ ↔ ⊡φ` |
| `TemporalBoolean` | Until and Since over linear time | the temporal schemata of TM, by frame class |
| `ModalTemporalBoolean` | L with `□` alone; L⁺ with both | TM; TM⁺ |

Names list families in the order Modal, Temporal, Boolean, which is the order the proof-mode
modules use. A library fragment contains the rules of every proof-mode module whose families it
includes: `ModalBoolean` in the library is the proof mode's `Modal` and `ModalBoolean` modules
together.

Frame class is a second axis, as in the proof mode. It applies only where Temporal is present:
Base, Dense, ZTime, RTime. An entry is filed at the weakest class at which it holds.

### Two operators in the Modal family

`□` quantifies over every history and `⊡` over the histories that share the present state, so
`□φ → ⊡φ`, and each is an S5 operator. They are filed as one family: the S5 laws are stated once
over a necessity operator given as a parameter and entered for both, and a section has each law
for `□`, `◇`, `⊡` and `⟐`. An entry records its **operator set**, the modal operators that occur
in it, so that the part of a fragment that belongs to L is recoverable: an entry is a statement
of L exactly when `⊡` is not in its operator set.

Three facts about `⊡` are theorems in the tree, and the filing has to respect each.

- **Without Temporal, `⊡` is the identity.** Every formula built from atoms, `⊥`, `→`, `□` and
  `⊡` is state-local, and a state-local `φ` satisfies `φ ↔ ⊡φ` at every frame
  (`PlusFormula.StateLocal`, `plusStateLocal_stab_iff` in
  `FormalSystem/PlusLanguage/PlusStateLocal.lean`). In `ModalBoolean` the operator contributes
  the collapse and what follows from it; its other content is in `ModalTemporalBoolean`:
  pasting, the limit-closure schemata, and the refutations in
  `FormalSystem/PlusLanguage/PlusNonValidities.lean`.
- **TM⁺ is not closed under uniform substitution.** The schema AS, `p → ⊡p`, holds for atoms and
  generalizes to state-local formulas only. A theorem that depends on AS is not a schema in its
  atoms.
- **The tableau does not cover `⊡`.** The decision procedure is over `Formula`. Refutations in
  L⁺ come from hand-built models and from the certificate checkers under
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` and `PlusSlicedCertificate/`.

Filing `⊡` under Modal is the position this design starts from. Whether it should be a family of
its own is under investigation in `investigate_stability_as_modal_family`; see Open decisions.

### Filing rule

- The **statement fragment** of an entry is the set of families whose primitive operators occur
  in its statement, with defined operators counted through their definitions. It is computed by
  a function on formulas and decides the directory. The operator set is computed the same way.
- The **proof fragment** is the smallest interface the reference proof is stated over. Where it
  is larger than the statement fragment, the conservativity table below says whether the proof
  can be lowered, and the entry is listed until it has been.
- An entry states its **substitution class**: schematic in all its variables, or restricted to
  atoms or to state-local formulas in named variables. Only entries with `⊡` in their operator
  set are restricted.

### How inheritance is realized

A theorem is proved once over the interface of its fragment and is available in every language
that instantiates that interface. The interface is the one the proof mode extracts
(`proof_mode_abstract_frontend_interface`): one class per family, one per interaction. Until it
exists, an entry without `⊡` is stated over `Formula`, an entry with it over `PlusFormula`, and
a TM theorem reaches TM⁺ through `PlusDerivationTree.ofTM` and `plusDerivable_substPlus`. The
registry and the directory layout do not change when the interface lands; only the reference
proofs are restated.

Fragments are computed sublanguages, not separate inductive types. A formula type per fragment
with embeddings between them would state the same lattice with a translation at every edge, and
each new family would double the count.

### Adding a family

A new operator family adds one element to the family set. Every existing entry keeps its
fragment, because its statement does not mention the new operator. The new fragments are the
existing ones with the family added, populated in the order: the family with Boolean, then with
each existing family, then the rest. The proof mode adds modules by the same rule. A new
operator that is an S5 or weaker necessity over histories joins Modal as a further instance of
the parameterized laws instead.

## Conservativity

Filing a statement at its smallest fragment claims that the larger logics prove nothing new
about it. That claim is a theorem for each edge of the lattice, and the library depends on every
one: it is what makes the proof fragment lowerable, what lets a countermodel in a small language
refute in a large one, and what makes a fragment's section complete in itself.

Each edge is established the way cslib establishes its own (`conservative_over_cpl`,
`modal_conservative_extension_param`, `temporal_conservative_over_cpl`), in three steps:

1. **Soundness of the larger logic** over its models.
2. **A semantic bridge**: for a formula of the smaller language, truth in a model of the larger
   logic agrees with truth in a model of the smaller, proved by induction on the formula. The
   model is chosen to make the added operators trivial where that suffices.
3. **Completeness of the smaller logic.**

Derivable in the larger gives valid in the larger by 1, valid in the smaller by 2, derivable in
the smaller by 3. The converse direction is the embedding of derivations.

| Edge | Status | Where |
|---|---|---|
| L into L⁺ (`⊡` added) | proved at all four frame classes | `plusDerivable_ofFormula_iff`, `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean` |
| `Boolean` into `ModalBoolean` | to prove | completeness of the smaller is the propositional procedure under `FormalSystem/Metalogic/Decidability/Propositional/` |
| `Boolean` into `TemporalBoolean` | to prove | the same |
| `ModalBoolean` with `□` into TM | to prove | needs completeness of S5 for the `□`-fragment, which the tree does not state |
| `TemporalBoolean` into TM, per frame class | to prove | needs completeness of the temporal schemata alone at each class, which the tree does not state |
| `ModalBoolean` with `□` into `ModalBoolean` with both | to prove | follows from L into L⁺ once the two edges into TM are proved, or directly by the collapse |

The theorems live with the rest of the metalogic under `FormalSystem/Metalogic/Conservativity/`.
The library keeps this table as a generated index over them. An edge that is not yet proved is a
conjecture in the sense of the section below, and an entry whose filing depends on it says so.

The edge from L⁻ into L is a different question, answered and partly refuted in
`FormalSystem/Metalogic/Conservativity/README.md`. L⁻ is not a fragment in this lattice: it has
other primitives, not fewer families.

## Layout

The library is a Lake library of its own, beside `BimodalTools`. It imports
`FormalSystem`, and `FormalSystem` never imports it. It therefore sits above the tableau and
above the proof mode, and may use both; the layer order that keeps proof-mode proofs out of
`FormalSystem/Theorems/` does not constrain it.

```
BimodalLib/
  Fragment.lean               the family set, the fragment of a formula, the registry
  Theorems/<Fragment>/        registered statements with their reference proofs
  ProofMode/<Fragment>/       the same statements proved in the mode
  Countermodels/<Fragment>/   refuted inferences with their models
  Conjectures/<Fragment>/     statements not yet established either way
  Diagnostics/                the record schema and the commands that emit it
```

Within a fragment directory, files are by frame class and then by theme.

The derived theorems under `FormalSystem/Theorems/` stay where they are: the metalogic imports
them. The library registers each by reference and files it by its computed fragment. It does not
copy them.

The registry pairs proofs mechanically. A proof-mode re-proof is elaborated against the type of
the registered statement, so that it cannot drift from it, and the pairing is a fact the kernel
has checked and not a naming convention.

## Sources and the tableau pipeline

Entries come from four sources.

| Source | Covers | Evidence |
|---|---|---|
| Hand proofs under `FormalSystem/Theorems/` | entries without `⊡` | the derivation |
| The manuscript's listed principles | all fragments | a derivation written for the entry |
| The tableau, over enumerated formulas | entries without `⊡` | an extracted derivation, or a gated open branch |
| Transfer | entries with `⊡` | a TM theorem carried along `ofTM`; an S5 law of `□` restated for `⊡` and `⟐` |

The tableau pipeline is the bulk source. Its stages:

1. **Enumerate.** Formulas of a fragment up to a complexity bound, one representative per
   renaming of atoms. `BimodalTools/FormulaEnumerator.lean` and
   `BimodalTools/AtomCanonicalization.lean` do this for L; the fragment is a filter on the
   enumeration.
2. **Decide.** `decide` at a stated frame class, giving one of `valid`, `invalid`,
   `fuelExhausted`, `extractionFailed`.
3. **Extract.** A `DerivationTree` from a closed tableau, or a countermodel from an open
   saturated branch.
4. **Certify.** A derivation is checked by the kernel on admission. An `invalid` verdict is
   certified only if the branch passes the eight gates of `not_valid_of_hasOpen_int`
   (`FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean`), or, at ZTime, if a
   witness-family certificate is accepted by `decidableCertifies`.
5. **Admit.** A certified valid formula is generalized from atoms to schema variables and
   dropped if it is a substitution instance of an entry already present. A certified invalid one
   is admitted as a countermodel. Everything else is registered as a conjecture with its
   verdict.
6. **Re-prove.** Each admitted theorem is attempted in the proof mode.
7. **Compare and feed back.** Measurements are taken, failures are classified, and the
   missing-rule list is updated.

The pipeline exists for dataset generation and is reused, not rebuilt. Its measured yield at
complexity 4 over the Base class is 17 valid, 669 invalid and 120 undetermined of 806
(`data/bmlogic-c4_metadata.json`), so the theorem half grows slowly by enumeration and the
countermodel half quickly. Hand proofs and the manuscript's principles are where the deep
entries come from; enumeration supplies the complete low layers and the countermodels.

## Countermodels

A countermodel entry records an inference `Γ ⊭ φ` at a frame class, a model, and a proof that
the model refutes it. Entries are graded by what the proof is.

| Grade | Evidence | Where it comes from |
|---|---|---|
| Semantic | a Lean theorem that the inference is not valid, by an explicit model | hand-built models: `PlusNonValidities`, `StarNonValidities`, the independence results |
| Certificate | a finite certificate accepted by a proved checker | the witness-family checkers at ZTime |
| Gated tableau | an open saturated branch passing the gates, with the gate theorem applied | the tableau |

An ungated `invalid` verdict is not a countermodel entry. It is registered as a conjecture,
labelled heuristically refuted, because no theorem stands behind it.

Countermodels are filed by the fragment of the refuted inference and by the strongest frame
class at which the model lives. A model at ZTime refutes the inference at Base as well. A
countermodel in L refutes in L⁺ through `plusValidIn_ofFormula_iff`.

Where a refuted inference is a near miss of a theorem (the converse of an implication, a schema
with its side condition dropped), the two entries name each other. The five refutations that
bound the `⊡` axiom set are the model for this.

The proof mode uses this half directly. A leaf that the mode cannot close is looked up in the
countermodel library and, failing that, sent through the pipeline; a refutation is reported
against the leaf. It never closes a goal.

## Conjectures

A statement that is neither derived nor refuted has a place of its own. A conjecture is a
registered statement with a fragment, a frame class, a status and a note on what is known: who
conjectured it or where it is stated, what was tried, and what it would settle. It is a
definition of the statement and carries no proof term, so it cannot be cited where a theorem is
required and the library stays free of `sorry`.

Conjectures come from four places: results stated in the manuscript and not yet formalized;
conservativity edges not yet proved; formulas the tableau left undetermined, whether by
exhausted fuel, failed extraction or an ungated refutation; and missing rules a sweep names
before anyone has derived them.

A conjecture leaves the directory in one of two ways. Derived, it becomes a theorem entry;
refuted, a countermodel entry. Either way its registration is kept as the link from the
question to its answer. The first entries are the conservativity edges above and the derivation
in TM⁺ of the collapse `φ ↔ ⊡φ` for state-local `φ`, which is proved as a validity only.

## Evaluating the proof mode

A **sweep** takes a fixed set of theorem entries from fragments the mode claims to cover and
writes, for each, a script in `BimodalLib/ProofMode/` against the registered statement, without
citing the reference proof or any lemma that restates it. A sweep produces one record per entry
and a report, and it can be re-run by one command, so that it is repeated after every change to
the rule set and coverage is not allowed to fall.

**The set is a selection, chosen for what it tests.** An entry is in a sweep because it
exercises a rule, a tactic, a scope or a combination of them that no entry already in the set
exercises, or because it is a result people need to write. The report states for each entry what
it is there to test. Once the method is working the set is enlarged where a sweep shows a gap in
what is exercised, and not otherwise: an entry that would repeat a measurement already taken is
left out.

Each attempt has one of four outcomes: closed by the mode's rules alone; closed with leaf
automation; closed with a term-mode escape; not closed. Each attempt that is not the first
outcome carries one failure class from a fixed list: missing rule, missing tactic for a rule
that exists, automation too weak, script too awkward to write, too slow, defect in the mode.
A missing rule is named by its statement and filed in the fragment it would belong to.

Length is compared against hand proofs only. A proof extracted from the tableau is not written
for a reader, so against it a script is measured for coverage and for the size of the derivation
it builds, not for brevity.

The findings drive the mode. Each sweep report ends with the missing-rule list, each item either
added during the sweep or named with a proposed description, and the next rule work is chosen
from that list.

## Diagnostics

One record schema covers every stage. A record is keyed by the statement's identifier and the
stage, and carries the fragment, the frame class, the commit and the command that produced it.

| Stage | Measured |
|---|---|
| Enumerate | formulas generated, by fragment and complexity; duplicates removed |
| Decide | verdict; time; fuel used; branches opened and closed |
| Extract | derivation size and height; axiom schemata used, with counts; extraction route; for a countermodel, number of histories and times |
| Certify | the axiom set the entry depends on; for a countermodel, the grade and each gate |
| Admit | admitted, subsumed by which entry, or registered as a conjecture with which verdict |
| Re-prove | outcome; failure class; tactic count and distinct tactics; size of any escape; elaboration time; size of the derivation built |
| Compare | script length against the hand proof; built derivation size against the reference; statement fragment against proof fragment |

Aggregates are by fragment and frame class: coverage (the share of entries closed, by outcome),
the distribution of length ratios, tactic usage, and failure classes by count. A report quotes
aggregates and links the records.

The schema, the commands and the meaning of each field are documented under `docs/` when the
first stage emits records, and a stage is not complete until its fields are documented there.

## What is taken from cslib and what is not

`/home/benjamin/Projects/cslib` organizes logics by the same idea and was reviewed for this
design.

Taken:

- **A theorem is proved at the weakest interface that proves it and inherited by extension.**
  cslib has one class per connective, one per axiom, bundles such as `ModalS5Hilbert` and
  `BimodalTMHilbert` that extend smaller ones, and generic theorem modules stated over a bundle.
  The fragment lattice here is that hierarchy.
- **Conservativity by soundness, a semantic bridge and completeness of the base**, proved once
  in parametric form and instantiated per edge.
- **Derivations are data.** Proof systems are `Type`-valued, so derivations can be measured.
- **Transport along a morphism of proof systems** (`ProofSigHom`, `Deriv.map`) as the general
  form of the lifts between languages.

Not taken:

- **One `HasBox` per formula type.** L⁺ has two S5 operators on one type. The S5 laws are
  stated over an operator given as a parameter and instantiated at `□` and at `⊡`, so a class
  keyed on the formula type alone cannot carry them.
- **A separate formula type per logic with embeddings.** See "How inheritance is realized".
- **Native conjunction, disjunction and diamond constructors.** Here they are defined operators,
  related to their definitions by the proof mode's views tier.

## Open decisions

1. **Build status.** `BimodalLib` can be built by default or, as `BimodalTools` is, only on
   request and in CI. Hand-registered entries are cheap to build; enumerated ones are many.
2. **Is `⊡` rightly in the Modal family?** The design files it there. The case for a family of
   its own: L and L⁻ have `□` without `⊡`, so the `⊡`-free language is recovered here by an
   operator set and not by the lattice; `⊡` breaks uniform substitution and `□` does not; the
   tableau covers one and not the other; and what is particular to `⊡` lies in its interaction
   with Temporal. The case for one family: both are S5 necessities over histories ordered by
   inclusion, the laws and the scope rules are shared, and the lattice has four fragments
   instead of eight. `investigate_stability_as_modal_family` examines this, including whether
   the operators of the Open and Nomic languages are further instances of the same
   parameterized laws at other strengths, and revises this record if the answer is a separate
   family.
3. **Enumeration bounds.** The complexity bound per fragment and frame class, and whether
   admission filters by an interestingness measure
   (`BimodalTools/InterestingnessMetrics.lean`) or keeps every non-subsumed theorem.
