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

The **operator set** of an entry, the modal operators that occur in it, is a coordinate of the
lattice beside the fragment. A **cell** is a fragment together with an operator set. The two
fragments with Modal each have three cells, for `□`, for `⊡` and for both; `Boolean` and
`TemporalBoolean` have one each. Directories are per fragment; conservativity edges run between
cells.

### Two operators in the Modal family

`□` quantifies over every history and `⊡` over the histories that share the present state, so
`□φ → ⊡φ`, and each is an S5 operator. They are filed as one family, the necessity operators
over histories. The laws are stated once over a necessity operator given as a parameter and
entered for both: a K core (scope introduction, distribution, monotonicity, the diamond duals),
with T, 4 and 5 as further members that an operator has or lacks. A section has each law for
`□`, `◇`, `⊡` and `⟐`. The inclusion `□φ → ⊡φ` relates the two operators and is entered once.
An entry records its operator set, so that the part of a fragment that belongs to L is
recoverable: an entry is a statement of L exactly when `⊡` is not in its operator set.

Three facts about `⊡` are theorems in the tree, and the filing has to respect each.

- **Without Temporal, `⊡` is the identity.** Atoms and `⊥` are state-local, an implication of
  state-local formulas is, and so is any formula headed by `□` or `⊡`, whatever is beneath the
  head. A state-local `φ` satisfies `φ ↔ ⊡φ` at every frame
  (`PlusFormula.StateLocal`, `plusStateLocal_stab_iff` in
  `FormalSystem/PlusLanguage/PlusStateLocal.lean`). In `ModalBoolean` the operator contributes
  the collapse and what follows from it; its other content is in `ModalTemporalBoolean`:
  pasting, the limit-closure schemata, and the refutations in
  `FormalSystem/PlusLanguage/PlusNonValidities.lean`.
- **TM⁺ is not closed under uniform substitution.** The schema AS, `p → ⊡p`, holds for atoms and
  generalizes to state-local formulas only. A theorem that depends on AS is not a schema in its
  atoms. The state-local formulas are the **rigid class** of `⊡`: the class on which `φ → ⊡φ`
  holds.
- **The tableau does not cover `⊡`.** The decision procedure is over `Formula`. Refutations in
  L⁺ come from hand-built models and from the certificate checkers under
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` and `PlusSlicedCertificate/`.

`⊡` is filed under Modal on these grounds. A family of its own would record the same cells as
eight fragments, and by the first fact the two of them without Temporal would hold the collapse
and nothing else. Restricted substitution and tableau coverage are properties of an operator,
recorded per entry by the operator set and the substitution class, and they recur in other forms
for the other restricted necessities, so they mark no family boundary. The L-part of a fragment
is recovered by the operator set. And the operators of the Open and Nomic languages are further
instances of the same laws, so a family per necessity operator would double the fragments with
each one. [stability-operator-family.md](../docs/development/stability-operator-family.md) sets
out the comparison and what a separate family would require.

### Filing rule

- The **statement fragment** of an entry is the set of families whose primitive operators occur
  in its statement, with defined operators counted through their definitions. It is computed by
  a function on formulas and decides the directory. The operator set is computed the same way.
  The functions are `profileF` and `profileP` in `BimodalLib/Fragment.lean`.
- The **proof fragment** is the set of operators of every formula the reference proof derives.
  Where it is larger than the statement fragment, the entry is listed in `BimodalLib/INDEX.md`
  with a reason: a proved conservativity edge, by which the proof can be lowered, or a reason
  recorded beside the registration. The listing and the check that enforces it are described in
  [docs/reference/bimodal-lib.md](../docs/reference/bimodal-lib.md).
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
operator that is a necessity over histories joins Modal as a further instance of the
parameterized laws instead, at the strength it has, and the operator set grows by it. `□`, `⊡`
and the Open language's `▷` and `◁` join at S5. The Nomic language's `◈` joins at KD, the K core
with seriality, once it has a calculus over the frame notion of the lattice.

## Conservativity

Filing a statement at its smallest fragment claims that the larger logics prove nothing new
about it. That claim is one statement per edge of the lattice, and it is not a theorem at every
edge. The edges out of `Boolean` and out of the cell with `□` are proved at every frame class,
the edge from L into L⁺ is proved at all four, and the edge out of `TemporalBoolean` at the base
class is refuted: TM derives `X⊤ → G X⊤` through `□`, and the temporal cell does not. So filing
at the smallest fragment is a theorem at `Boolean` and at `ModalBoolean`, and at
`TemporalBoolean` it is a convention: a temporal statement over `Base` may have no proof inside
its cell. The table of edges, each with a kernel-checked verdict, is generated in
`BimodalLib/INDEX.md`; the theorems, the method and the registry are described in
[docs/reference/bimodal-lib.md](../docs/reference/bimodal-lib.md).

What is not built:

| Edge | Status | What stands in the way |
|---|---|---|
| `TemporalBoolean` into TM at `Dense`, `ZTime` and `RTime` | open, three registered conjectures | The translation that would prove the edge reads `□` as `always`. It needs the S5 laws of `always`, the law `always φ → always Gφ` and replacement of provable equivalents, each derived inside the temporal cell at the class. No completeness theorem is needed. |
| `TemporalBoolean` with uniform discreteness as a hypothesis, into TM at `Base` | open, one registered conjecture | The same, and whether the hypothesis `X⊤ → always X⊤`, with its past mirror, is all that TM derives about the temporal cell through `□`. |

These four are one piece of work, the always translation, and are proposed as a record of their
own. Until they are settled, an entry at `TemporalBoolean` whose reference proof uses `□` stays
listed with a recorded reason.

The edge from L⁻ into L is a different question, answered and partly refuted in
`FormalSystem/Metalogic/Conservativity/README.md`. L⁻ is not a fragment in this lattice: it has
other primitives, not fewer families.

## Layout

The library is the Lake library `BimodalLib`, beside `BimodalTools`, outside `defaultTargets`,
importing `FormalSystem` and never imported by it. Its layout, the fragment computation, the
registry of the theorems under `FormalSystem/Theorems/`, the pairing of a second proof with its
registered statement, and the index are implemented and described in
[docs/reference/bimodal-lib.md](../docs/reference/bimodal-lib.md).

The directory still to come, by fragment and, within a fragment, by frame class and then by
theme:

```
BimodalLib/
  ProofMode/<Fragment>/       registered statements proved in the mode
```

`BimodalLib/Countermodels/<Fragment>/<FrameClass>.lean` is in place, along with
`BimodalLib/Countermodel.lean` and the three modules under `BimodalLib/Countermodel/`; see
[docs/reference/bimodal-lib.md](../docs/reference/bimodal-lib.md)'s Countermodels section.

`BimodalLib/Diagnostics/` holds the record **schema** and the `reprove`/`compare` emitters, and
is already in place. The five reserved stages' emitters are **not** there and should not be put
there: they live in `BimodalTools/PipelineDiagnostics.lean`. `scripts/proof-mode-cost-baseline.sh`
pins the directory `BimodalLib/Diagnostics` in its measured-surface array, so a commit writing
anywhere under it reports `STALE BASELINE` until the pin moves; and that directory is the
Evaluation lane's territory while the pipeline is the Library lane's. Reserving the keys in the
schema is what lets a second library supply the emitter.

`BimodalLib/Theorems/Enumerated/` and `BimodalLib/Conjectures/Enumerated.lean` are in place too:
the pipeline's admitted entries and its non-admitted outcomes.

A proof-mode re-proof under `ProofMode/` is entered with the pairing command, so that it is
elaborated against the type of the registered statement.

## Sources and the tableau pipeline

Entries come from four sources.

| Source | Covers | Evidence |
|---|---|---|
| Hand proofs under `FormalSystem/Theorems/` | entries without `⊡` | the derivation |
| The manuscript's listed principles | all fragments | a derivation written for the entry |
| The tableau, over enumerated formulas | entries without `⊡` | an extracted derivation, or a gated open branch |
| Transfer | entries with `⊡` | a TM theorem carried along `ofTM`; an S5 law instantiated at `⊡` and `⟐` |

The tableau pipeline is the bulk source. It runs on the cells whose operator set is within `□`.
The decision procedure is over `Formula`, and the admit stage generalizes a certified formula from
atoms to schema variables, which is sound only where uniform substitution holds.

**Stages 1 to 5 — enumerate, decide, extract, certify, admit — are implemented.** One command runs
them end to end:

```bash
bash scripts/theorem-library-pipeline.sh --all-fragments --atoms 2 \
  --frame-class Base --frame-class Dense --frame-class ZTime --frame-class RTime
```

`docs/reference/bimodal-lib.md` describes what admission requires and how the generated entries
are filed; `docs/reference/diagnostics.md` describes the five stage records. What remains:

6. **Re-prove.** Each admitted theorem is attempted in the proof mode.
7. **Compare and feed back.** Measurements are taken, failures are classified, and the
   missing-rule list is updated.

The pipeline exists for dataset generation and is reused, not rebuilt.

**The measured yield, and the figure not to quote.** At the ruled bound over a two-atom pool —
`Boolean` and `ModalBoolean` at complexity 5, `TemporalBoolean` and `ModalTemporalBoolean` at
complexity 4, where "complexity N" counts *pattern-aware operator layers* in
`Formula.complexity`'s measure and not primitive nodes — 3,955 formulas were decided: 13 valid,
3,523 invalid, 371 `fuelExhausted` and 48 `extractionFailed`. The **derivation-bearing** yield,
which is what admission needs, is **six** non-subsumed schemata after the subsumption test
(`data/theorem-library-pipeline.jsonl`); the countermodel half is 2,981 gated refutations
(`data/theorem-library-countermodels.jsonl`) and the conjecture half 2,895.

The raw `valid` column of a dataset is **not** the admissible theorem yield, and quoting it
overstates the result. A formula whose tableau closed without yielding a proof term is valid and
inadmissible at once, because the registry's row type needs a witness. At complexity 4 over the
Base class a dataset tabulation reports 17 valid of 806 (`data/bmlogic-c4_metadata.json`), of
which 15 came from the structural prefilter and carry no derivation — so two of those 17 are
admissible. The same gap at the ruled bound is the 48 `extractionFailed` verdicts.

So the theorem half grows slowly by enumeration and the countermodel half quickly. Hand proofs
and the manuscript's principles are where the deep entries come from; enumeration supplies the
complete low layers and the countermodels.

## Countermodels

The entry type, its registration, the three admitted grades, the filing rule, both transfers,
the lookup up to renaming of atoms, the near-miss field and its build invariant, and the index's
countermodel section are implemented and described in
[docs/reference/bimodal-lib.md](../docs/reference/bimodal-lib.md)'s Countermodels section. That
page also records what is deliberately not a row, and why near-miss naming is one-directional:
a theorem row is `Formula`-only by type, so the laws the stability refutations bound cannot be
registry rows and there is no row for a countermodel row to be named by.

Two parts remain unimplemented.

**Bulk admission of the tableau-fed gated entries.** One row stands as the gated-tableau grade's
existence witness; the pipeline's 1,047 distinct gated statements are not admitted. Two measured
obstacles, both to be cleared before the bulk is attempted:

- The pipeline's refutation record carries the gate flags and the true and false atoms, and
  **not** the open branch or its time ordering, which is exactly what the gate theorem consumes.
  No kernel-checked row can be generated from the data file as it stands; the record must emit
  the branch first.
- At roughly 70 wrapped source lines per row — measured on the smallest refuted formula in the
  dataset, whose branch is 14 signed formulas over 4 times — the full set is on the order of
  73,000 lines across some fifty files, against a package-wide 1,500-line file linter that CI
  enforces with `--wfail`. Sizing comes before generating: measure lines per row and elaboration
  time on a ten-row sample, file per (fragment, frame class), and pin each generated file's
  long-file baseline to its actual length.

**The evaluator-checked fourth grade.** A refutation checked by the evaluator that
[semantic-proof-mode.md](semantic-proof-mode.md) owns. Its client is the evaluator milestone of
[milestones.md](milestones.md), and it waits on the evaluator; the grade constructor is
deliberately absent from `BimodalLib.Grade` (`BimodalLib/Countermodel.lean`) until the evaluator
exists, so that the type does not advertise a route that is not there.

## Conjectures

A statement that is neither derived nor refuted has a place of its own. The type of a
conjecture, how one is registered, and the first entries (the conservativity edges and
the derivation in TM⁺ of the collapse `φ ↔ ⊡φ` for state-local `φ`) are implemented and
described in [docs/reference/bimodal-lib.md](../docs/reference/bimodal-lib.md).

Conjectures come from four places: results stated in the manuscript and not yet formalized;
conservativity edges not yet proved; formulas the tableau left undetermined, whether by
exhausted fuel, failed extraction or an ungated refutation; and missing rules a sweep names
before anyone has derived them. The last three sources are not yet feeding the library.

A conjecture leaves the directory in one of two ways. Derived, it becomes a theorem entry;
refuted, a countermodel entry. Either way its registration is kept as the link from the
question to its answer.

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
- **Conservativity proved once in parametric form and instantiated per edge.** cslib's
  argument is soundness, a semantic bridge and completeness of the base. Here the bridge is read
  on formulas, as a translation, and the argument is an induction on derivations, because a
  fragment's logic is a set of TM derivations and no completeness theorem in the tree returns a
  derivation inside a fragment.
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

1. **Enumeration bounds.** The complexity bound per fragment and frame class, and whether
   admission filters by an interestingness measure
   (`BimodalTools/InterestingnessMetrics.lean`) or keeps every non-subsumed theorem.
