# BimodalLib: the library of TM results

`BimodalLib` is a Lake library beside `BimodalTools`. It files what is known about TM and its
extensions by language fragment: the theorems proved under `FormalSystem/Theorems/`, second
proofs of those theorems, and conjectures. This page describes what the library holds and how
to add to it. The design of the parts not yet built (countermodels, the tableau pipeline,
diagnostics, sweeps of the proof mode) is in
[records/theorem-library.md](../../records/theorem-library.md).

## Where it sits

`BimodalLib` imports `FormalSystem`, and `FormalSystem` never imports it. Check `B3` of
`scripts/check-module-invariants.sh` fails on an `import BimodalLib` anywhere under
`FormalSystem/`. The library therefore sits above the tableau and above the proof mode and may
use both.

It is outside `defaultTargets`. A plain `lake build` compiles the published library and nothing
here; the library is built by explicit target and by its own `--wfail` step in CI:

```bash
lake build BimodalLib --wfail       # the library; also the registration check
lake build BimodalLibTest --wfail   # its tests
bash scripts/library-index.sh       # regenerate BimodalLib/INDEX.md
```

The alternative is a default target, under which a contributor's plain build would catch a
second proof that has drifted from its statement. It is rejected because CI catches the same
drift, and because the library is where sweeps and enumerated entries land, of which there will
be many: `lake build` means "the published library".

## Layout

| Path | Holds |
|---|---|
| `BimodalLib/Fragment.lean` | The operator families, the four fragments, and the profile of a formula |
| `BimodalLib/Registry.lean` | The row type `TheoremEntry` and the command `register_theorem` |
| `BimodalLib/Registry/Complete.lean` | The command `assert_registry_complete` |
| `BimodalLib/Theorems/<Fragment>/<FrameClass>.lean` | The registration lines, one per registered theorem |
| `BimodalLib/Theorems/Complete.lean` | Runs the registration check, the proof-fragment check, and the non-redundancy check over the generated entries |
| `BimodalLib/Theorems/Enumerated/Base.lean` | The machine-generated entries the tableau pipeline admits; one file, because proof extraction is `Base`-only |
| `BimodalLib/Subsumption.lean` | `matchSubst?`, `isSubstInstance`, and the command `assert_no_subsumed_entries` |
| `BimodalLib/Pairing.lean` | The row type `ReproofEntry` and the command `reprove X as Y := t` |
| `BimodalLib/Conjecture.lean` | The type `Conjecture` |
| `BimodalLib/Conservativity.lean` | Derivability within a cell, in which the conservativity edges are stated, and the proof profile of a derivation |
| `BimodalLib/Conservativity/Proved.lean` | The proved edges: out of `Boolean` and out of the cell with `□` |
| `BimodalLib/Conservativity/TemporalBase.lean` | The refuted edge: out of `TemporalBoolean` at the base class |
| `BimodalLib/Conservativity/Table.lean` | The registry of edges, each with a kernel-checked verdict |
| `BimodalLib/ProofFragment.lean` | The commands `record_proof_fragment` and `assert_proof_fragments_recorded` |
| `BimodalLib/Conjectures/` | The registered conjectures |
| `BimodalLib/Conjectures/Enumerated.lean` | The pipeline's non-admitted outcomes, one aggregate constant per (fragment, frame class, verdict) cell |
| `BimodalLib/Countermodel.lean` | The row type `CountermodelEntry`, the consequence relation `GenericConsequenceIn`, the class `HasProfile`, and the three grades |
| `BimodalLib/Countermodel/Transfer.lean` | The two transfer theorems and their entry-level companions |
| `BimodalLib/Countermodel/Gates.lean` | `gatesOK`, the branch gates bundled, and the gate bridge theorem |
| `BimodalLib/Countermodel/Lookup.lean` | Looking a refuted inference up to renaming of atoms |
| `BimodalLib/Countermodels/<Fragment>/<FrameClass>.lean` | The countermodel rows, filed by fragment and maximal frame class |
| `BimodalLib/Countermodels/Complete.lean` | Runs the near-miss resolution check over every row |
| `BimodalLib/Index.lean` | The polarity census and the command `library_index` |
| `BimodalLib/INDEX.md` | The generated index |
| `Tests/BimodalLibTest/` | Tests of each command, in both directions |

## Fragments

There is one Boolean base and two operator families over it: **Modal** (`□`, and `⊡` in the
extended language) and **Temporal** (Until, Since and what is defined from them). A fragment is
a set of families: `Boolean`, `ModalBoolean`, `TemporalBoolean`, `ModalTemporalBoolean`.

The fragment of a formula is computed. `profileF : Formula → Profile` and
`profileP : PlusFormula → Profile` record which primitive operators occur, by recursion on the
primitives; a defined operator is counted through its definition because it unfolds to
primitives. A `Profile` has a field for `□`, one for `⊡` and one for the temporal operators, so
it carries the **modal operator set** of a formula as well as its fragment, and
`Profile.fragment` maps both `□` and `⊡` to the Modal family. Profiles are ordered by inclusion.
`profileP_ofFormula` proves that the two computations agree on the embedding of `Formula` into
`PlusFormula`. Why `⊡` is in the Modal family and not a family of its own is set out in
[stability-operator-family.md](../development/stability-operator-family.md).

`SubstClass` records whether a statement is schematic in all its variables or restricted to
atoms or to state-local formulas in named variables. Only a statement with `⊡` can be
restricted.

## The registry

A theorem is registered by reference. One line names a closed derivation declared under
`FormalSystem/Theorems/`:

```lean
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity1
  (dual := FormalSystem.Theorems.Perpetuity.perpetuity2)
```

The command reads the type of the declaration and adds a definition
`BimodalLib.Registry.<full name>` of type `TheoremEntry`:

| Field | What it is |
|---|---|
| `arity` | The number of schema variables |
| `frameClass` | The frame class the derivation is stated at |
| `stmt` | The statement, as a function of an assignment to its variables |
| `proof` | The registered derivation, at every class above `frameClass` and every assignment |
| `profile`, `profile_eq` | The operators of the statement, and a proof by `rfl` that they are the computed ones |
| `substClass` | The substitution class; `schematic` for every row, since `proof` holds at every assignment |
| `dual` | The declaration registered as the law in the other polarity, if one is declared |

A row is a term the kernel has checked. Its `proof` field cites the declaration at the row's
statement, so the statement is read from the declaration and is never retyped, and the fragment
and operator set are computed and not asserted. The registry is the set of constants of type
`TheoremEntry`. Nothing is stored in an attribute or an environment extension, because rows
held there pass no kernel check; and the derivations stay in `FormalSystem/Theorems/`, where
the metalogic imports them.

**Frame class.** A derivation stated at every class is filed at `Base`; one with a hypothesis
`C ≤ fc` at `C`; one stated at a fixed class at that class. Above `Base`, the class of a row is
the class its derivation is **stated at**: the row proves derivability there and at every
stronger class, and does not prove failure at a weaker one.

**What is registered.** A closed derivation concludes a derivation from the empty context and
has no derivation among its premises. A derivation from a non-empty context and a rule with a
derivation among its premises are not registered; the check reports how many of each it saw.

**The check.** `BimodalLib/Theorems/Complete.lean` imports the root `FormalSystem` and every
registration module and runs `assert_registry_complete`. It fails, naming the declarations,
when a closed derivation declared in a module under `FormalSystem.Theorems`, outside
`FormalSystem.Theorems.ProofMode`, has no row, or when a declared dual has none. A closed
derivation added under `FormalSystem/Theorems/` therefore breaks `lake build BimodalLib` until
it is registered. The check keys on the module that declares a constant, and it sees only
imported modules, which is why the module that runs it imports the library root.

**Adding a theorem.** Add its `register_theorem` line to the file for its fragment and frame
class, importing the module that declares it, and regenerate the index. A line filed in the
wrong file still builds; the index files every row by what the row computes.

## Enumerated entries

Most rows are registered by reference: a line names a closed derivation declared under
`FormalSystem/Theorems/`. The entries under `BimodalLib/Theorems/Enumerated/` are not. They are
generated: a tableau decides an enumerated formula, proof extraction yields a `DerivationTree`
for it, and the pipeline prints Lean source that reconstructs that tree, generalizes it from the
formula's own atoms to schema variables, and registers it. Regenerate with

```bash
bash scripts/theorem-library-pipeline.sh --all-fragments --atoms 2 \
  --frame-class Base --frame-class Dense --frame-class ZTime --frame-class RTime
```

An edit made inside that directory is lost on the next run; the emitter
(`BimodalTools/LeanSourceEmit.lean`) and the driver (`BimodalTools/TheoremPipeline.lean`) are
where a change belongs.

They are filed together rather than by frame class because proof extraction is `Base`-only by
construction: `extractProof` ignores its frame-class argument and `ProofExtractionResult.success`
is hard-coded to `Base`. The frame-class axis moves the countermodel half alone.

### What admission requires

A formula is admitted only when it is valid **and** carries an extracted derivation, and is not a
substitution instance of an entry already present. Everything else is registered as a conjecture
with its verdict and is never a result. The distinction that catches a reader out is
`extractionFailed`: the tableau closed, so the formula *is* valid, but no witness was
reconstructed, and the row type's `proof` field needs one — so such a formula is valid and
inadmissible at once. A yield figure quoted as the raw `valid` count therefore overstates the
admissible set by exactly the `extractionFailed` share.

The derivation-bearing yield at the ruled bound over a two-atom pool is **six** non-subsumed
schemata — `A → (B → A)`, `□⊥ → A`, `□A → A`, `□(□⊥ → A)`, `□(□A → A)` and
`A → □(□(A → ⊥) → ⊥)` — from 3,955 decided formulas of which 13 were valid and 48 further were
`extractionFailed` (`data/theorem-library-pipeline.jsonl`). The bound is stated in
`Formula.complexity`'s measure, which counts *pattern-aware operator layers* and not primitive
nodes; and a yield figure is not reportable without its atom pool, because the yield is
superexponential in pool size.

### Non-redundancy is a build invariant, over the generated entries

`assert_no_subsumed_entries BimodalLib.Theorems.Enumerated` in
`BimodalLib/Theorems/Complete.lean` fails the build when a generated entry's statement is a
substitution instance of another row's. This is a design property of the library, not an
implementation detail of the pipeline:

* **The candidate side is scoped; the comparison side is not.** Only rows under the
  `Enumerated` prefix are tested as candidates, but each is compared against every row in scope,
  so a generated entry that duplicates a hand-curated law is caught. That is what the admission
  rule asks for.
* **The hand-curated named laws are outside the invariant on purpose.** The library deliberately
  names laws that are instances of more general schemata: `Combinators.topThm : ⊤` is
  `Combinators.identity` at `⊥`, and its own proof term is literally `identity Formula.bot`;
  `Propositional.em : A ∨ ¬A` unfolds to `(A → ⊥) → (A → ⊥)`, an instance of `A → A`. Twenty-six
  of the registry's rows are of that kind. They are out of scope rather than exempted: there is
  no baseline file and no exemption ledger for them anywhere, because naming a useful instance of
  a schema is not a defect to be waived.
* **Subsumption is strict.** A row subsumes another only when the second is an instance of the
  first and not conversely. Two statements each an instance of the other are renamings, which
  `register_theorem` already refuses by name.

The matcher behind it, `BimodalLib.isSubstInstance`, is computable and tested rather than
kernel-verified. That is sound here for a specific reason: a wrong answer can drop an entry or
keep a redundant one, but it can never admit an *unproved* entry — the kernel still checks every
registered row's `proof` field.

### The conjecture side

The non-admitted outcomes are registered as one aggregate `Conjecture` per (fragment, frame
class, verdict) cell, 48 in all, in `BimodalLib/Conjectures/Enumerated.lean`. The count is the
product and so is bounded independently of how large the conjecture half is — which matters,
because that half is three orders of magnitude larger than the admitted one (2,895 formulas at
the ruled bound). One constant per formula would mean 2,895 documented declarations and as many
index rows; the per-formula fact lives in the ADMIT record's own `disposition` and
`conjecture_verdict` fields instead.

## Pairing a second proof

```lean
reprove FormalSystem.Theorems.Perpetuity.perpetuity1 as perpetuity1Again :=
  fun φ => combineImpConj3 (boxToPast φ) (boxToPresent φ) (boxToFuture φ)
```

`reprove X as Y := t` elaborates `t` against the type of the registered declaration `X` and
declares `Y`, in the current namespace, with that type. A proof of any other statement is a type
error and declares nothing. The command then adds a row of type `ReproofEntry`, named by the
full name of `Y` under the library's `Reproofs` namespace, whose `proof` field cites `Y` at the statement of the row of `X`. The
pairing is a kernel-checked term and not a naming convention. The command fails if `X` has no
registry row. Lean's own `reprove ... by` command is a different command; the two are told
apart by the keyword `as`.

## Conjectures

A conjecture is a constant of type `Conjecture`: a `statement : Prop`, a `fragment`, an operator
set `ops`, an optional `frameClass`, a `status` and a `note` on where it is stated, what was
tried and what it would settle. The type has no field for a proof, so a conjecture cannot stand
where a theorem is required and registering one leaves nothing unproved in the library. The
statement is a `Prop` and not a formula because some conjectures are about derivability. Its
fragment and operator set are declared by its author, where those of a theorem row are computed.

To register one, declare a `Conjecture` in a module under `BimodalLib/Conjectures/` and
regenerate the index.

The registered conjectures are the conservativity edges and the derivability in the extended
system of the collapse `φ ↔ ⊡φ` for state-local `φ`, which is proved as a validity
(`plusStateLocal_stab_iff`). A conjecture whose edge has been proved or refuted is kept, with
status `derived` or `refuted` and a note naming the theorem, as the link from the question to
its answer. `BimodalLib/INDEX.md` lists each with its statement and note.

## Conservativity edges

Filing a statement at its smallest fragment claims that the larger logics prove nothing new
about it. The claim is stated over derivability within a cell. `within c d` holds when every
formula derived in the derivation `d` has a profile included in `c`; `DerivableIn c fc φ` says
`φ` has such a closed derivation; `ConservativeEdge c fc` says that a formula of the cell
derivable at `fc` is derivable within the cell. `withinP` and `DerivableInP` are the same for
the extended system. The axiom instances and rule applications that stay inside a cell are that
cell's logic, so no proof system per fragment is defined. `proofProfile d` is the join of the
profiles of every formula `d` derives, `within c d` holds exactly when `proofProfile d ≤ c`
(`within_iff_proofProfile_le`), and so `within` is decidable.

What is known of each edge:

| Edge | Verdict | Theorem |
|---|---|---|
| L into L⁺ | proved at all four classes | `FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff` |
| `Boolean` into TM, and so into `ModalBoolean` and into `TemporalBoolean` | proved at every class | `BimodalLib.conservativeEdge_boolean`, `derivableIn_boolean_of_box`, `derivableIn_boolean_of_temporal` |
| `ModalBoolean` with `□` into TM | proved at every class | `BimodalLib.conservativeEdge_box` |
| `ModalBoolean` with `□` into `ModalBoolean` with `□` and `⊡` | proved at every class | `BimodalLib.derivableIn_box_of_derivableInP` |
| `TemporalBoolean` into TM at `Base` | refuted | `BimodalLib.not_conservativeEdge_temporal_base` |
| `TemporalBoolean` into TM at `Dense`, `ZTime`, `RTime` | open | three conjectures |
| `TemporalBoolean` with uniform discreteness as a hypothesis, into TM at `Base` | open | one conjecture |

This table is a summary. The generated one is the section "Conservativity edges" of
`BimodalLib/INDEX.md`, rendered from `BimodalLib/Conservativity/Table.lean`. A row there is a
`ConservativityEdge`: the statement of the edge and an `EdgeVerdict` on it. The verdict is a
dependent value: `proved` carries a proof of the statement, `refuted` a proof of its negation,
`open` the obstruction as text. The index prints the constructor, so a row reads proved or
refuted only when the kernel has checked the proof. To register an edge, declare a
`ConservativityEdge` in that module and regenerate the index.

**How the proved edges are proved.** The theorems are in
`FormalSystem/Metalogic/Conservativity/Fragments/`, over a calculus `CellDerivable L fc` of
derivations inside an abstract sublanguage `L`; `derivableIn_iff_cellDerivable` identifies it
with derivability within a cell. `conservative_of_translation` states the argument once: a map
on formulas that commutes with implication, sends each admissible axiom instance to a formula
derivable inside `L`, preserves that derivability under the three rules for theorems, and is the
identity on `L`, gives the edge by induction on the derivation. The two instances collapse the
temporal operators, reading a formula in a model with one moment, and keep `□` or read it as the
identity. The translated axioms are propositional tautologies, derivable inside any sublanguage
by `tautology_derivable`, or instances of T, 5 and K. No completeness theorem for the smaller
logic is used. `FormalSystem.Metalogic.Conservativity.Fragments.boolean_conservative`,
`modal_conservative` and `conservative_of_translation` are in `docs/theorem-index.md` with
pinned axiom sets. The theorems of `BimodalLib` are outside what that ledger can pin, because
its check reads the declarations reachable from `import FormalSystem`; each depends on
`propext`, `Classical.choice` and `Quot.sound` only.

**What the refutation means for filing.** At `TemporalBoolean` over `Base`, filing a statement
at its smallest fragment is not a theorem. TM derives `X⊤ → G X⊤` at the base class from
`X⊤ → □X⊤`, and the temporal cell is sound for every linear order without endpoints, among them
the integers followed by the rationals, where that formula fails. A temporal statement filed
there may have no proof that avoids `□`. The open edges at the other three classes, and the
repaired edge at `Base`, need a translation that reads `□` as `always` and the S5 laws of
`always` derived inside the temporal cell.

## Proofs outside the statement cell

A theorem row is filed by the operators of its statement. Its reference proof may use more. The
section "Proofs outside the statement cell" of the index lists every registered theorem whose
registered derivation derives a formula outside the cell of its statement, with the proof
profile and a reason. The proof profile of a row is computed by evaluating `proofProfile` on the
registered derivation, at the row's own frame class and at the canonical schema variables. It is
a report; no theorem depends on it.

A listed row needs a reason, and there are two kinds. Where the edge out of the statement's cell
into TM is proved at the row's frame class, the proof can be lowered into the cell, and the
index names the edge theorem. Otherwise the reason is recorded beside the registration:

```lean
register_theorem FormalSystem.Theorems.ConnectDerived.discreteSymmFwd
record_proof_fragment FormalSystem.Theorems.ConnectDerived.discreteSymmFwd
  "The derivation routes through NF, which the full system derives through □. ..."
```

`assert_proof_fragments_recorded`, run from `BimodalLib/Theorems/Complete.lean`, fails the build
when a listed row has neither, and names the row. It also fails when a reason is recorded for a
row whose proof stays inside its cell, so that a reason does not outlive the proof it was
written for. Three rows are listed: NP, its time reflection and NA, each at `TemporalBoolean`
over `Base` and each derived through `□`.

## Countermodels

Every refuted inference is kept beside a checked refutation. A countermodel row is a definition
of type `CountermodelEntry L` in a module under `BimodalLib/Countermodels/`, and the index walk
discovers every such constant. There is no registration command, and the asymmetry with
`register_theorem` is the reason: a theorem row must read its statement off a declaration's type
and may not retype it, whereas a countermodel row's statement is the refuted *inference*, which
has no declaration to be read from and which the author therefore writes.

The row type is stated once, generically over `PointTruth` (`FormalSystem/Semantics/`,
`ValidityLayer.lean`), and serves both L and L⁺. That costs nothing at the statement side,
because `ValidIn` and `PlusValidIn` are definitionally `GenericValidIn`, so every refutation
already in the tree is admissible without restatement. It costs one explicit branch per language
in the index's meta-code, because `evalExpr` is monomorphic.

### The two kernel-checked invariants

A row carries the same pair the theorem half does.

`refutation : ¬ GenericConsequenceIn frameClass premises conclusion` is what the kernel checks.
`GenericConsequenceIn` is the premise-bearing consequence relation over `PointTruth`, added
because it existed for neither language: `SemanticConsequenceIn` is `Formula`-only, and L⁺
carried no premise-bearing consequence predicate at all. `genericConsequenceIn_nil` is the
bridge at the empty premise list, through which an existing `¬ Valid…`-shaped theorem becomes a
row's refutation without restatement.

`profile_eq : inferenceProfile premises conclusion = profile` is closed by `rfl`, so the
fragment a row is filed in is computed and not asserted. The profile of an inference joins the
premises' onto the conclusion's, so a row is filed by the operators occurring anywhere in it.

The record's third component, a model, is carried by `model : Option String`, which names the
declaration the refutation's proof uses. It is a name rather than a packed existential on
purpose: every landed refutation in the tree has the `¬ Valid…` shape, and converting one into a
model-exhibiting existential needs classical choice, which discards exactly the explicit model
the conversion was for.

### The three admitted grades

| Grade | What stands behind it | How rows of it are populated |
|---|---|---|
| `semantic` | A Lean theorem that the inference is not valid, by an explicit model | By hand, from the refutations under `FormalSystem/Metalogic/Independence/` and `FormalSystem/PlusLanguage/PlusNonValidities.lean` |
| `certificate` | A finite certificate accepted by a proved checker | The witness-family checkers at `ZTime`: a labelled lasso whose `Certifies` conditions are decided on finite data, turned into a refutation by `not_consequence_ztime` |
| `gatedTableau` | An open saturated branch passing the gates, with the gate theorem applied | By hand from branch data today; see below |

A fourth grade, a refutation checked by a semantic evaluator against witnesses the caller
supplies, is anticipated and deliberately absent. Its client milestone and its design record are
not in the tree, and admitting the constructor now would advertise a route that does not exist.

**An ungated `invalid` verdict is never a row, at any grade.** A decision procedure's bare
refutation is registered as a conjecture at `ConjectureStatus.heuristicallyRefuted`, whose own
docstring says what that means: a procedure returned a refutation that no theorem stands behind.
Only a branch that passes the gates, with the gate theorem applied, is admitted.

### Filing: fragment, and maximal frame class

A row is filed by the fragment of its inference and by the strongest frame class at which its
model lives. The frame-class order is a **tree, not a chain**: `Base` is below everything,
`Dense ≤ RTime`, and `ZTime` is **incomparable** with both `Dense` and `RTime`. Two consequences
follow and both are load-bearing.

First, "the strongest frame class" is not always unique, so one inference may legitimately carry
two maximal rows — one at `RTime`, one at `ZTime`. Second, a weaker-class reading is *derived*
rather than registered: rows are admitted at maximal classes only, and a `Base` duplicate of a
`ZTime` row is not a row.

### Transfer

Both transfers rest on a named theorem rather than on a convention.

`not_genericConsequenceIn_of_le` moves a refutation down the order, and takes an explicit
`fc₁ ≤ fc₂` hypothesis so the order is checked by the kernel and not by the author. That matters
precisely because of the tree shape: a model at `ZTime` does not refute at `Dense` or `RTime`,
and a "weaker class" convention would hide that.

`not_genericConsequenceIn_ofFormula` reads an L countermodel in L⁺, premise by premise, through
the truth-transfer bridge `plusTruthAt_ofFormula`. The `Γ = []` case of this is
`plusValidIn_ofFormula_iff`, which carries no premises, which is why the premise-bearing form
goes through the point-level bridge instead. `inferenceProfile_map_ofFormula` records that the
embedding preserves the filing, so an L⁺ reading lands in the same cell as its L original.

`CountermodelEntry.transferLe` and `CountermodelEntry.toPlus` are the entry-level companions:
each rebuilds a row, changing only what the transfer changes.

### The gated-tableau grade: gates as data

`gatesOK φ fc b ord` bundles the branch gates as one decidable `Bool` over `FormalSystem`
primitives, and `not_genericConsequenceIn_of_gatesOK` is the bridge from that `Bool` to a
refutation. A row then discharges its gates by `decide` on finite branch data.

**No tableau is rebuilt in the kernel.** None of the gate theorems requires the branch to have
come from the tableau construction — soundness rests on the gates alone — and that is what makes
an explicit-branch row cheap. The alternative shape, deciding the whole construction per row, is
deliberately not taken. `native_decide` is barred in this library and is not a fallback for
either shape.

The conclusion of the bridge is at `FrameClass.Base` whatever class the branch's closure check
was run at, because the gate theorem concludes `¬ Valid χ`: the class argument is the one fed to
the closure search, not the class of the conclusion.

`BimodalTools.TableauBridge` carries the other bundle of the same gates, and the
`BimodalLib → BimodalTools` import is forbidden outright, so duplicating the conjunction was the
only route open. `Tests/BimodalLibTest/GateAgreementTest.lean` pins the two bundles to agree, in
both verdicts; the test library may import both and the library itself may not.

**Bulk admission is not implemented.** The tableau pipeline's dataset carries 1,047 distinct
gated statements and none of them can become a kernel-checked row as the data file stands: the
records carry the gate flags and the true and false atoms, and not the open branch or its time
ordering, which is exactly what the gate theorem consumes. Beyond that, the measured cost is
roughly 70 wrapped source lines per row against a package-wide 1,500-line file linter that CI
enforces with `--wfail`, so the full set is on the order of 73,000 lines. One row stands as the
grade's existence witness; the bulk waits on the pipeline emitting branches.

### The certificate grade cannot be fed by the tableau pipeline

This is structural rather than incidental. At `ZTime` the region-label and temporal-witness gates
come back `false` on every formula, so the gated grade is unavailable there by construction, and
the pipeline's output carries no `ZTime` row and no certificate row at all. The certificate
grade's population route is the witness-family checkers, and nothing else.

### Lookup, up to renaming of atoms

An inference can be looked up in the library up to a renaming of its atoms. This is the proof
mode's entry point: where a tableau leaves a leaf unclosed, the leaf's inference is looked up,
and a hit is **reported against the leaf** rather than used to discharge it. A countermodel is
not a proof of anything about the goal under consideration — a row can say why a branch stayed
open, and cannot say that the goal is false.

Renaming is mutual substitution-instance, and the strictness is the point. `sameUpToRenaming x y`
is `isSubstInstance x y && isSubstInstance y x`; the one-directional test accepts a strict
instance, so a lookup built on it would report a row refuting something more general than the
inference asked about. `BimodalLib/Subsumption.lean`'s matcher was `Formula`-only, so a
`PlusFormula` companion with the `⊡` case was added beside it.

An inference is matched as one folded formula, `Γ.foldr .imp φ`. That is what a *single
consistent* renaming requires: one assignment is threaded through the premises and the
conclusion together, so a variable recurring across two premises must meet the same subformula
both times. The cost is that the premise list is matched in order rather than as a set; matching
it as a set would need permutation search and is deliberately not done.

### Near-miss naming is one-directional, by type

Where a refuted inference is the converse of a law, or a schema with its side condition dropped,
`nearMiss : Option Name` names the declaration it bounds. The design asks that the two entries
name *each other*, and only one direction of that is constructible — not as an omission, but
because of `TheoremEntry`'s type. A theorem row is `Formula`-only (`stmt : (Nat → Formula) →
Formula`, `proof : DerivationTree`), so the laws that the stability refutations bound — an axiom
constructor of the extended language, and two semantic validity theorems — are not and cannot be
registry rows. There is no row for the countermodel row to be named by.

`assert_near_miss_targets_resolve` therefore checks the direction that exists: every `some
nearMiss` must resolve in the environment. It runs in
`BimodalLib/Countermodels/Complete.lean`, so `lake build BimodalLib --wfail` is what catches a
renamed or deleted target; `Tests/BimodalLibTest/CountermodelTest.lean` pins its failing
direction against a fixture, so a check that stops failing is caught too. Where the bounded
object is not a declaration at all, the bound is recorded in the row's `note` instead, which is
why `nearMiss` is an `Option`.

### What is not a countermodel row

Recorded explicitly rather than by omission, because each is a judgement and not an oversight.

- **No `StarNonValidities` row.** The L⋆ refutations are not statable in L or L⁺: `StarValidOn`
  carries an extra binder, the stored-time vector, so L⋆ validity is not an instance of the point
  shape `PointTruth` abstracts; there is no profile computation for `StarFormula`, so an L⋆ row
  would have no computable filing; and the operators are L⋆-only. One of those refutations has
  L-statable content, but the declaration as written is over `StarFormula`.
- **No derivability- or definability-level independence result.** A claim that something is not
  derivable, or not definable, or that a frame is not separated, is about a calculus or a frame
  class — not about an inference failing in a model.
- **No frame-level refutation without a class-tag corollary beside it.** Manufacturing the
  corollary would be work in `FormalSystem`, and a row is not the place to do it.
- **No schematic sharpness statement.** A refutation stated for every class below a given one is
  open in its frame class and cannot be filed at a fixed one; the concrete class-tag declarations
  beside it are what the rows cite.

### Why there is no completeness check

`assert_registry_complete` demands a row for every closed derivation under
`FormalSystem/Theorems/`. The analogue here would demand one for every `¬ Valid…`-shaped theorem
in `FormalSystem`, and that would indict around a hundred declarations across the five
incompatible tiers just listed. A check that said so would be wrong rather than strict.
Registration is by the design's explicit list, not by exhaustion.

## The index

`bash scripts/library-index.sh` builds the library, runs the command `library_index`, and
writes `BimodalLib/INDEX.md`: the theorems by fragment and frame class, the second proofs by
statement, the conservativity edges, the proofs outside the statement cell, the conjectures, the
countermodels by grade and by fragment and frame class, and for each pair of dual operators the
laws with no declared dual.
`--check` fails when the committed index differs from a fresh one; CI runs it.

The dual pairs are `□`/`◇`, `G`/`F`, `H`/`P` and always/sometimes, with `⊡`/`⟐` listed as
having no rows. The operators of a statement are recognized by pattern over the primitives,
most specific pattern first, so the `G` and `H` inside an `always` are not counted again.
Whether one law is the dual of another is declared with `(dual := Y)`, not computed: a row is
listed when its statement has the universal operator of a pair and its `dual` is empty. The
listing is long because few duals are declared.

## What checks the library

| Check | Catches |
|---|---|
| `lake build BimodalLib --wfail` (CI) | An unregistered closed derivation; a declared dual with no row; a proof outside its statement cell with no reason; an edge marked proved or refuted without a proof; a generated entry that is a substitution instance of another row; any warning |
| `lake build BimodalLibTest --wfail` (CI) | A command that stops failing where it should: the registration check and the proof-fragment check on their fixtures, a drifted second proof, a declaration that is not a closed derivation, an edge table that omits a registered edge |
| `scripts/library-index.sh --check` (CI) | A stale `BimodalLib/INDEX.md` |
| `B3` of `scripts/check-module-invariants.sh` | `FormalSystem` importing `BimodalLib` |
| `assert_near_miss_targets_resolve` (in `BimodalLib/Countermodels/Complete.lean`, so `lake build BimodalLib --wfail`) | A countermodel row whose `nearMiss` names a declaration that is not in the environment |
| `Tests/BimodalLibTest/CountermodelTest.lean` (CI, via `lake build BimodalLibTest --wfail`) | The near-miss check stopping failing on its fixture; a grade losing its last row; the renaming relation accepting a strict instance; the lookup reporting a near-miss shape as a hit; a row's axiom set growing |
| `Tests/BimodalLibTest/GateAgreementTest.lean` (CI, same build) | The library's `gatesOK` and `BimodalTools.TableauBridge`'s `BranchGates` drifting apart, in either verdict |
| `lake exe runLinter BimodalLib` | A declaration, generated rows included, with no docstring |
