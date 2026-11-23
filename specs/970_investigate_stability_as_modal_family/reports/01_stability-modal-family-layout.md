# Research Report: Task #970

**Task**: 970 - Investigate whether the stability operator belongs in the Modal family or a family of its own
**Started**: 2026-11-23T21:56:28Z
**Completed**: 2026-11-23T22:03:00Z
**Effort**: one research pass; the implementation deliverable is one report under `docs/development/` plus record edits (markdown only, no Lean)
**Dependencies**: None
**Sources/Inputs**: - `records/theorem-library.md`, `records/proof-mode-architecture.md`, `records/proof-mode.md`, `records/milestones.md`
  - `FormalSystem/PlusLanguage/` (README, `Axioms.lean`, `PlusStateLocal.lean`, `PlusTruth.lean`, `PlusNonValidities.lean`, `Derivation.lean`)
  - `FormalSystem/OpenLanguage/` (README, `OpenAxioms.lean`, `OpenDerivation.lean`), `FormalSystem/NomicLanguage/` (README, `NomicTenseFree.lean`, `NomicValidity.lean`), `FormalSystem/Semantics/Nomic/Frame.lean`
  - `FormalSystem/Theorems/ProofMode/Congruence/Modal.lean`, `FormalSystem/Semantics/TruthClauses.lean`
  - `/home/benjamin/Projects/cslib` at `3bdf16d9f`: `Cslib/Foundations/Logic/{Operators,Connectives,ProofSystem}.lean`, `Cslib/Foundations/Logic/Metalogic/ProofSystemMorphism.lean`
  - `specs/state.json` (descriptions and `file_scope` of the filed proof-mode and theorem-library tasks)
**Artifacts**: - `specs/970_investigate_stability_as_modal_family/reports/01_stability-modal-family-layout.md`
**Standards**: report-format.md, subagent-return.md

**Evidence tier.** Everything below was established by reading source and records. No Lean was
compiled and no lean-lsp lookup was run; where a claim is an inference from what was read rather
than a named declaration, it is marked *(inference)*.

## Executive Summary

- **Recommendation: keep one family.** `⊡` stays in the Modal family, and the family is to be
  understood as *necessity operators over histories*, parameterized by operator. A separate
  Stability family is not recommended. The merged layout is not wrong; it is under-specified in
  three places, listed under Recommendations as amendments R1 to R3.
- **"Four fragments against eight" is not a real difference in content.** The merged layout
  already carries a second computed coordinate, the operator set. Fragment times operator set has
  exactly the cells the eight-fragment lattice has. The choice is only whether four of those
  cells are directories or sections. What decides it is how each option scales, and that is
  settled by the next point.
- **The Open-language modals are further instances of the same laws; the nomic operator is an
  instance at a weaker strength.** `▷` and `◁` each have K, T, 4 and 5 as axioms of `OpenAxiom`
  and necessitation as a derived rule, exactly as `⊡` does. `◈` is normal with D over every nomic
  frame, has T only on lawful frames, 4 only on uniform ones (over integer time), and full S5 only
  on its tense-free fragment. So "necessity operator of a given strength" is the abstraction, on
  one condition: the shared statement must be stratified by law (a K core, then T, D, 4, 5 as
  separate members), not stated as one S5 block. A family per necessity operator would give
  2^k family sets for k operators; with `□`, `⊡`, `▷`, `◁` alone that is sixteen modal
  combinations before Temporal is counted.
- **Each of the three proved facts about `⊡` turns out to be a per-operator parameter, not a
  per-family one.** Collapse, restricted substitution and missing decision procedure each recur
  for the other restricted necessities in a different form (a different rigid class, a different
  restricted fragment). They argue for recording operator-level data per entry, which the merged
  layout already does, and not for a family boundary around `⊡` in particular.
- **What the operators do not share is every interaction with Temporal.** MF, TF and the
  perpetuity principles belong to `□`; pasting with its purity side conditions belongs to `⊡`;
  HN and the rigidity schemata belong to `▷` and `◁`. No parameterized statement covers these,
  and the records should say so (R3).
- **The parameterized statement already exists in compiled form.** `NecessityRules` in
  `FormalSystem/Theorems/ProofMode/Congruence/Modal.lean` is a structure with the operator as a
  field, instantiated three times (`tmBox`, `plusBox`, `plusStability`). It carries the K core
  only, which is the stratification R1 asks the records to adopt.
- **cslib can host a second necessity operator without change, but not through instance
  resolution.** Its modal axiom classes take `[HasBox F]` as an instance argument, so they are
  already operator-parameterized in type; the second operator has to be supplied by an explicit
  instance, a type synonym, or a proof-system morphism. cslib's own precedent for a second
  necessity-like operator on a type that has `HasBox` (`G` and `H` in `BimodalTMHilbert`) is
  operator-specific axiom classes, not a second `HasBox`.

## Context & Scope

The question is the one both records list under "Open decisions" with the text **"Is `⊡` rightly
in the Modal family?"** It is cited here by that text. The task description calls it "open
decision 2 of `records/theorem-library.md`"; in the record as it stands it is decision 1 there
and decision 2 of `records/proof-mode.md`.

The task asks for four things: (1) weigh the one-family layout against a separate Stability
family using three proved facts; (2) determine whether the Open and Nomic modal operators are
further instances of the parameterized necessity laws; (3) review how cslib would host two
necessity operators on one formula type; (4) recommend one layout and, if it is a separate
family, list every change to the records and the filed tasks.

This report is the research input. The task's own deliverable, a report under
`docs/development/`, is written at implementation. Because a ruling could still go the other way,
the change list for the separate-family layout is given in full in the Appendix even though it is
not the recommendation.

History that bears on the question: the layout has already been reversed once. The original
descriptions of `proof_mode_split_shared_test_and_guide_files`,
`proof_mode_abstract_frontend_interface` and `proof_mode_s5_aware_box_scopes` name a `Stability`
family and a `StabilityModal` interaction; each now opens with a "FAMILY LAYOUT REVISED"
paragraph that overrides this and files `⊡` under Modal. The separate-family layout is therefore
the earlier position of the same design, and its text is still in those three descriptions.

## Findings

### 1. What the two layouts actually differ in

The merged layout has four fragments and records, per entry, an **operator set**: which modal
operators occur. The operator set ranges over none, `□`, `⊡`, both. Crossed with whether Temporal
is present, that is eight cells. The separate layout has families Modal, Stability and Temporal
and so eight fragments. The cells are the same eight.

| Cell | Merged layout | Separate layout |
|---|---|---|
| no modal operator, no Temporal | `Boolean` | `Boolean` |
| `□` | `ModalBoolean`, set `□` | `ModalBoolean` |
| `⊡` | `ModalBoolean`, set `⊡` | `StabilityBoolean` |
| `□`, `⊡` | `ModalBoolean`, set both | `ModalStabilityBoolean` |
| Temporal | `TemporalBoolean` | `TemporalBoolean` |
| `□`, Temporal | `ModalTemporalBoolean`, set `□` | `ModalTemporalBoolean` |
| `⊡`, Temporal | `ModalTemporalBoolean`, set `⊡` | `StabilityTemporalBoolean` |
| `□`, `⊡`, Temporal | `ModalTemporalBoolean`, set both | `ModalStabilityTemporalBoolean` |

So the two layouts hold the same information. They differ in three practical respects.

- **Directories and module names.** The separate layout doubles the directories under each of
  `BimodalLib/Theorems/`, `ProofMode/`, `Countermodels/`, `Conjectures/`, and adds a pure
  `Stability` module plus its interactions to each of the six places the naming scheme is used.
- **Which edges are lattice edges.** In the merged layout the only conservativity edge that is
  proved, L into L⁺ (`plusDerivable_ofFormula_iff`), is not an edge of the fragment lattice: it
  runs inside `ModalTemporalBoolean`. The conservativity table already shows the strain, with a
  row "`ModalBoolean` with `□` into `ModalBoolean` with both". In the separate layout every such
  edge is a lattice edge. This is the strongest point in favour of the separate layout, and R2
  answers it without changing the layout.
- **How the scheme grows.** See finding 3.

### 2. The three proved facts, weighed

**Fact 1: without Temporal, `⊡` is the identity.** `PlusFormula.StateLocal` admits atoms, `⊥`,
implications of state-local formulas, and any formula headed by `□` or `⊡`, whatever is beneath
the head; `plusStateLocal_stab_iff` gives `φ ↔ ⊡φ` for these at every frame. The record's
statement ("every formula built from atoms, `⊥`, `→`, `□` and `⊡` is state-local") is true and a
little weaker than the tree, which also counts `□Gp` and `⊡Fp` as state-local.

Consequence for the separate layout: two of its four new fragments are degenerate.
`StabilityBoolean` and `ModalStabilityBoolean` contain no temporal operator, so every formula in
them is state-local and `⊡` is the identity throughout. Each would hold the collapse, the S5 laws
of `⊡` (which the collapse trivializes) and nothing else. The content that is particular to `⊡`
sits in the two fragments with Temporal. A family whose pure module and whose Boolean interaction
are both trivial is a weak candidate for a family.

Consequence for the merged layout: none beyond what it already says. The collapse is one entry in
`ModalBoolean`.

**Fact 2: TM⁺ is not closed under uniform substitution.** `atom_stab` is stated for atoms, and
`stab_of_stateLocal` generalizes it to state-local formulas only. This is a real difference from
`□`, which has no such schema. But it is not peculiar to `⊡` among necessity operators. In
`OpenAxiom`, `▷` has `rigidity_ofut_bwd` restricted to `IsPurePastOpen` formulas and `◁` has
`rigidity_opast_bwd` restricted to `IsPureFutureOpen` ones, and atoms satisfy both predicates. So
each restricted necessity comes with a **rigid class**: a syntactic class of formulas `φ` for
which `φ → Nφ` holds, and the schema is restricted to it. For `⊡` the class is the state-local
formulas, for `▷` the pure-past ones, for `◁` the pure-future ones; for `□` it contains no atom.
`◈` shows the same pattern from another side: its S5 laws hold on the tense-free fragment only.

So restricted substitution is a parameter of the operator. Both layouts must record a
substitution class per entry, and the record already requires it. A family boundary around `⊡`
would mark one instance of the pattern and miss the others.

One place where the merged layout needs care: stage 5 of the tableau pipeline generalizes a
certified valid formula from atoms to schema variables. That step is sound only where uniform
substitution holds. Today it is safe by accident, because the enumerator is over `Formula` and
cannot produce `⊡`. The record should state the condition and not rely on the accident (R2).

**Fact 3: the tableau does not cover `⊡`.** The decision procedure is over `Formula`. This is a
fact about a language, and it is expressed equally by "operator set contains `⊡`" and by
"fragment contains Stability". In the separate layout the tableau-covered fragments are exactly
the four without Stability, which reads cleanly. In the merged layout M19's sentence "enumerates
the formulas of `Boolean`, `ModalBoolean`, `TemporalBoolean` and `ModalTemporalBoolean`" is
accurate only with the qualifier "with `□` alone". This is a wording fix, not a layout argument.

**Net.** Fact 1 counts against a separate family. Facts 2 and 3 are neutral between the layouts
and each asks only that operator-level data be recorded per entry.

### 3. Open and Nomic operators as instances

**`▷` and `◁` (Open language).** They are S5 necessities with a calculus.

- `OpenAxiom` has `ofut_k`, `ofut_t`, `ofut_four`, `ofut_five` and the four `opast` mirrors as
  schematic axioms. The restricted-modal block has 18 constructors by the arms of
  `OpenAxiom.minFrameClass`: these eight, the three inclusions `stab_of_box`, `ofut_of_stab`,
  `opast_of_stab`, the two HN schemata, the four rigidity schemata, and `definability_fwd`.
- Necessitation for each is derived, through the chain `□` to `⊡` to `▷` or `◁`
  (`stabNecessitation`, `ofutNecessitation`, `opastNecessitation` in `OpenDerivation.lean`). TM⁺
  derives `⊡`-necessitation the same way.
- The operators are ordered by inclusion of their history classes: `□` implies `⊡`, `⊡` implies
  each of `▷` and `◁`; each implication is strict and `▷`, `◁` are incomparable
  (`OpenOckhamist.lean`).
- `⊡φ ↔ ▷◁φ ↔ ◁▷φ` on regular frames (`stab_iff_ofut_opast`), with only the forward half an
  axiom.

So `▷` and `◁` instantiate the parameterized S5 statement exactly as `⊡` does: the K core by an
axiom and derived necessitation, T, 4 and 5 by axioms. They also instantiate the two per-operator
pieces identified below: an inclusion from a stronger operator and a rigidity schema on a rigid
class.

**`◈` (Nomic language).** It is a necessity at a weaker strength, and it has no calculus.

- Over every nomic frame: the clause is a universal quantifier over a set of histories, so K and
  necessitation hold *(inference; the tree states K by name on the tense-free fragment only, as
  `nomic_k_tenseFree`)*, and D holds (`nomic_serial`).
- T holds on lawful frames. `NomicFrame.Lawful` is defined as the condition that every possible
  world is a law-history at each state it occupies, which is reflexivity of the accessibility
  relation; the first hierarchy witness is static and not lawful.
- 4 holds, over integer time, exactly on uniform frames (`four_validOn_iff_uniform`), and on
  those `◈` coincides with `□` (`nomic_iff_box_of_uniform`).
- All five S5 schemata hold on the tense-free fragment over every frame
  (`nomic_*_tenseFree`), where `◈` again coincides with `□`.

So `◈` is KD in general, KT on lawful frames, S5 on uniform frames or on a restricted fragment.
It fits "necessity operator of a given strength" only if the shared statement lets an operator
supply the K core without T, 4 and 5.

Two limits on that conclusion. `◈` is evaluated over `NomicFrame`, which is not a `TaskFrame`,
and the Nomic component has no proof system. So `◈` cannot instantiate the proof-mode interface
at all today, and it sits outside the fragment lattice for the same kind of reason the record
gives for L⁻: the lattice is over one frame notion. It is an instance of the *laws*, not yet of
the *interface*.

**What is shared and what is not, across all five operators.**

| Piece | Shape | `□` | `⊡` | `▷`, `◁` | `◈` |
|---|---|---|---|---|---|
| K core: scope introduction, distribution, monotonicity, duality | one operator | yes | yes | yes | yes, semantically |
| T | one operator | yes | yes | yes | lawful frames |
| 4, 5 | one operator | yes | yes | yes | uniform frames |
| Inclusion `Nφ → Mφ` | ordered pair of operators | source | from `□` | from `⊡` | from none; equals `□` under uniformity |
| Rigidity `φ → Nφ` on a rigid class | one operator and a formula class | none on atoms | state-local | pure-past, pure-future | not stated |
| Interaction with Temporal | operator-specific | MF, TF, perpetuity | pasting PS, US with purity conditions | HN and its mirror | 4 fails through `U`, `S` |

The first three rows are what the records call the shared statement. The last three are not
shared and never will be: an inclusion relates two operators, a rigidity schema needs a formula
class, and the temporal interactions have nothing in common. In particular the `□` principles do
not transfer to `⊡`: `PlusNonValidities.lean` refutes `⊡p → □⊡p`, `G⊡p → ⊡Gp`, `⊡GPp → G⊡Pp` and
`P⊡p → ⊡Pp`.

**Scaling.** If each necessity operator were a family, k operators give 2^k family sets, and the
directory tree, the module scheme and the interface classes all multiply with it. The merged
layout keeps four fragments for any k and grows the operator set. The record's rule under
"Adding a family" ("a new operator that is an S5 or weaker necessity over histories joins Modal")
is the right rule, and this finding is its justification.

### 4. The parameterized statement in the tree

`FormalSystem/Theorems/ProofMode/Congruence/Modal.lean` defines

```
structure NecessityRules {L : Type} {P : L → Type} (kit : Kit L P) where
  operator : L → L
  distribution : ∀ A B, P (kit.imp (operator (kit.imp A B)) (kit.imp (operator A) (operator B)))
  mono : ∀ {A B}, P (kit.imp A B) → P (kit.imp (operator A) (operator B))
```

and instantiates it at `tmBox`, `plusBox` and `plusStability`, with one congruence step
`Step.necessity` taking the structure. This is the design the architecture record chooses (a
structure taking the operator as a field; fields supplied by axiom or by derivation), already
compiled and already used at both operators of TM⁺. Two observations:

- It has the K core and no T, 4 or 5. The records describe the shared statement as "scope
  introduction, T, 4, 5 and the diamond rules". A stratified statement, with the K core as the
  base and each further law a separate extension, matches the code, matches cslib's
  one-class-per-axiom layering, and is what lets a KD operator in.
- The semantic side has the per-operator shape too: `StabClause` is its own class in
  `FormalSystem/Semantics/TruthClauses.lean`, beside `BoxClause`, and `StabClauses` extends
  `UntlClauses`. That is one clause class per operator, not per family, which is consistent with
  either layout.

### 5. How cslib would host two necessity operators

What cslib has (at `3bdf16d9f`):

- `HasBox (α)` with one field `box : α → α`, keyed on the formula type alone, and a scoped
  notation `□`.
- One class per modal axiom (`HasAxiomK`, `HasAxiomT`, `HasAxiom4`, `HasAxiomB`, `HasAxiom5`,
  `HasAxiomD`), a rule class `Necessitation`, and bundles from `ModalHilbert` through
  `ModalS5Hilbert` (S4 plus B) to `BimodalTMHilbert`, which extends `ModalS5Hilbert`,
  `TemporalBXHilbert` and `HasAxiomMF`. Each takes `[HasBox F]` as an **instance argument** and a
  tag type `S`.
- Generic theorem modules stated over a bundle (`Theorems/Modal/Basic.lean` over
  `[ModalHilbert S]`, `Theorems/Modal/S5.lean` over `[ModalS5Hilbert S]`).
- `HasDynamicBox (α β)`, a box indexed by an action type `β`, with no axiom classes over it.
- `ProofSig`, `ProofSigHom` and `Deriv.map`: a formula map preserving implication, an axiom-family
  map, and a coherence condition sending each closure operator of the source to a chosen closure
  operator of the target.

Because the box is an instance argument of every axiom class and bundle, those classes are
already parameterized by the operator at the level of types: `ModalS5Hilbert S` at one `HasBox F`
instance and at another are different propositions. What cslib lacks is a way for instance
resolution to find the second. Four ways to host `⊡` follow, in order of how much they ask of
cslib.

| Route | What it is | Cost |
|---|---|---|
| Explicit instance | Keep `HasBox PlusFormula := ⟨box⟩` canonical; define a named, non-instance `stabBox : HasBox PlusFormula := ⟨stab⟩` and state `@ModalS5Hilbert _ S _ _ stabBox _`. Generic theorems are applied with the instance given explicitly. | No change to cslib. The `□` notation resolves to the canonical instance, so statements about `⊡` print badly, and every use site names the instance. |
| Type synonym | `def StabView (F) := F` with `HasBox (StabView PlusFormula) := ⟨stab⟩` and the inference system carried across; the pattern of `OrderDual` and `Additive`. | No change to cslib. Instance resolution works. Statements mixing the two operators cross the synonym. |
| Morphism | A `ProofSigHom` from an S5 signature into TM⁺ sending the box to `stab`; `clMap` is satisfiable once `⊡`-necessitation is offered as a closure of the target, and `Deriv.map` transports every S5 derivation. | No change to cslib. Transports derivations, not class instances, so generic theorems are reached by mapping their derivations. This is the route the theorem-library record already lists as taken ("transport along a morphism"). |
| Indexed necessity | Axiom classes and bundles over an indexed box, `HasDynamicBox`-style, with the index ranging over the necessity operators of the language. | New upstream API. It is the only route in which "two S5 operators and an inclusion between them" is a class one can state. |

cslib's own precedent points away from a second `HasBox`. `G` and `H` are necessity-like
operators on a type that already has `HasBox`, and `BimodalTMHilbert` does not host them through
a second box: the temporal side has operator-specific axiom classes written over `HasUntil` and
`HasSince`. The interaction axiom `HasAxiomMF` is likewise specific. So within cslib, a second
necessity operator has so far meant its own axiom classes.

What this implies for the layout here. The theorem-library record's "Not taken" entry ("one
`HasBox` per formula type") is correct and should stay. The structure-with-an-operator-field
design is the local counterpart of cslib's instance-argument parameterization made explicit, and
it corresponds to the explicit-instance route. Nothing in cslib favours a separate family: a
separate Stability family would map to a `HasStab` class with duplicated axiom classes, which is
the duplication the parameterized statement exists to avoid.

### 6. Summary of the weighing

| Consideration | One family | Separate family |
|---|---|---|
| Information recorded | same eight cells | same eight cells |
| Fact 1, collapse | one entry | two of four new fragments degenerate |
| Fact 2, substitution | per-entry class, already required | per-entry class still required |
| Fact 3, tableau | "operator set within `□`" | "fragment without Stability" |
| L into L⁺ as a lattice edge | no, unless operator set is made a coordinate (R2) | yes |
| S5 laws stated once | yes, structure per operator | yes, the same structure; the family boundary adds nothing |
| Rules particular to `⊡` | sections inside Modal modules | modules of their own |
| `▷`, `◁`, later `◈` | join the family; fragments stay four | each a family; family sets double per operator |
| Change to records and filed tasks | three amendments | Appendix B: four records, six tasks certainly and two more possibly |
| cslib counterpart | explicit-instance parameterization | duplicated axiom classes |

## Recommendations

**Keep `⊡` in the Modal family.** State the family as the necessity operators over histories,
with the S5 laws parameterized by operator, and make the following amendments. None changes a
module name, a `file_scope` or a filed dependency.

- **R1. Stratify the shared statement.** In `records/proof-mode-architecture.md` (the two
  paragraphs beginning "The Modal family has two operators" and "The shared statement is a
  structure") and in `records/theorem-library.md` ("Two operators in the Modal family"), describe
  the shared statement as a K core (scope introduction, distribution, monotonicity, the diamond
  duals) with T, 4 and 5 as separate members an operator supplies when it has them. Cite
  `NecessityRules` as the existing K core. Change "an S5 or weaker necessity over histories joins
  Modal" to say at which strength each known operator joins: `□`, `⊡`, `▷`, `◁` at S5; `◈` at KD
  once it has a calculus.
- **R2. Make the operator set a coordinate of the lattice, not only an attribute of an entry.**
  In `records/theorem-library.md`: say that a cell is a fragment together with an operator set;
  that conservativity edges run between cells, so that L into L⁺ is the edge that adds `⊡` to the
  operator set at `ModalTemporalBoolean`; restate the row "`ModalBoolean` with `□` into
  `ModalBoolean` with both" in those terms; and state that the tableau pipeline, including its
  generalization from atoms to schema variables, runs on cells whose operator set is within `□`.
  In `records/proof-mode.md`, qualify M19's list of fragments the same way.
- **R3. Name the three pieces that are not shared.** In `records/proof-mode-architecture.md`,
  beside the shared statement, state: an **inclusion** is a rule about an ordered pair of
  operators and is a member only a language with both supplies; a **rigidity** rule takes an
  operator and a formula class, is not schematic, and says so in its statement (`⊡` with
  state-local formulas now; `▷` with pure-past and `◁` with pure-future formulas if the Open
  language gets an instance); and **interactions with Temporal are per operator**, so the
  sections of `ModalTemporalBoolean` that name `⊡` share no statement with those for `□`. This
  replaces the sentence "its remaining rules are interactions with Temporal" with something a
  contributor can file against.
- **R4. Close the open decision in all three records** with the recommendation and a pointer to
  the `docs/development/` report, and remove the "may reverse this" sentences from the six filed
  task descriptions that carry one (list in Appendix A). This is the only edit to filed tasks.
- **R5. Write the `docs/development/` report** from findings 1 to 6. It must not cite task
  numbers or the earlier layout as history; rejected alternatives are stated on their merits.
  Suggested name: `docs/development/stability-operator-family.md`.

Minor corrections to make while editing: the record's description of the state-local class can
cite the tree's exact definition (any formula headed by `□` or `⊡` is state-local), and the
"Sources" table's phrase "an S5 law of `□` restated for `⊡` and `⟐`" should read "instantiated
at", since the laws are not restated.

No recommendation here changes a mechanical rule over a corpus, so no corpus check is owed.

## Decisions

- The open decision is cited by its question text, not by ordinal, because the ordinal in the
  task description no longer matches the record.
- The comparison is made cell by cell, not by counting fragments, because the two layouts have
  the same cells.
- `◈` is treated as an instance of the necessity laws and not of the interface: it has no
  calculus and is evaluated over a different frame notion.
- No `user_decision` is raised. `records/proof-mode.md` requires a ruling before the records
  change only for a recommendation of a separate family, and this report recommends the layout
  the records already start from. Amendments R1 to R3 refine wording within that layout.
- The separate-family change list is still supplied (Appendix B), so that a contrary ruling can
  be acted on without a second research pass.

## Risks & Mitigations

- **The recommendation rests on reading, not on a compiled probe.** The K and necessitation claim
  for `◈` over arbitrary nomic frames is an inference from the truth clause. Mitigation: the
  recommendation does not depend on it; `◈` enters only as evidence that the statement should be
  stratified, and D alone (`nomic_serial`) shows `◈` is not S5 in general.
- **The interface task may find a class indexed by operator more convenient than a structure.**
  That is the architecture record's own alternative and is independent of this question; either
  carries a per-operator statement inside one family.
- **Sections naming `⊡` inside Modal modules may grow large**, since pasting, `Will`, `will`,
  `Could` and `could` all live in `ModalTemporalBoolean`. Mitigation: the filed `file_scope` of
  `theorem_library_stability_entries` already gives them files of their own
  (`.../ModalTemporalBoolean/Stability.lean`); a file per operator inside a fragment directory is
  available without a family.
- **A later ruling to make `⊡` a defined operator in the Open language** would move its Open
  entries through the definition `▷◁`. Under the filing rule (defined operators counted through
  their definitions) they stay in the Modal family in the merged layout, and would change family
  in the separate one. The standing ruling keeps `⊡` primitive, so this is a note, not a risk to
  act on.
- **Deliverable rules.** The `docs/development/` report and any record edit fall under the rules
  against task-number references and draft-history language in deliverables; `records/` is not
  under `specs/`, so both apply to it. The planner should carry this into the plan.

## Context Extension Recommendations

- **Topic**: necessity operators as a parameterized family across the language components.
- **Gap**: no context file records that `□`, `⊡`, `▷`, `◁` share an S5 core, are ordered by
  inclusion, and each carry a rigid class, or that `◈` is KD in general.
- **Recommendation**: none to create now; the `docs/development/` report this task produces is
  the durable home, and a context pointer to it can follow.

## Appendix

### A. Filed tasks whose descriptions refer to this investigation

Found with `jq` over `specs/state.json`, selecting descriptions that contain
`investigate_stability_as_modal_family`; cross-checked with a second selection on `⊡`,
`Stabilit` and `stability`, which returned these plus tasks that mention the operator without
depending on the layout. The six:

| Task | Sentence to remove under R4 |
|---|---|
| `proof_mode_split_shared_test_and_guide_files` | "`investigate_stability_as_modal_family` may reverse this; do not wait on it." |
| `proof_mode_s5_aware_box_scopes` | the same sentence |
| `proof_mode_abstract_frontend_interface` | "`investigate_stability_as_modal_family` may reverse the family layout; read its report if it exists." |
| `theorem_library_layout_and_registry` | "`investigate_stability_as_modal_family` may change the family set; ..." |
| `theorem_library_stability_entries` | "FIRST read the report ...: if it recommends a separate family ..." and the sequencing clause |
| `connective_signature_layer_shared_primitives` | its one reference; not read in full in this pass, to be checked at planning |

### B. Change list if a separate Stability family is ruled for instead

Module order would be Modal, Stability, Temporal, Boolean.

`records/theorem-library.md`
- "The lattice": add a Stability row to the family table; replace the four-row fragment table
  with eight rows (finding 1); move the collapse and `□φ → ⊡φ` to `StabilityBoolean` and
  `ModalStabilityBoolean`.
- Replace "Two operators in the Modal family" with a section on the Stability family; keep the
  three facts; keep the parameterized S5 statement, now instantiated across two families.
- "Filing rule": drop the operator set; state that only fragments containing Stability have
  restricted substitution classes.
- "Adding a family": delete the last sentence, or restrict it to operators with no rigid class.
- "Conservativity": replace the L into L⁺ row by one row per fragment gaining Stability; replace
  "`ModalBoolean` with `□` into `ModalBoolean` with both" by "`ModalBoolean` into
  `ModalStabilityBoolean`"; add "`Boolean` into `StabilityBoolean`".
- "Sources": the tableau covers the four fragments without Stability.
- "Open decisions": remove decision 1. Principle 5 and "What is taken from cslib" stand.

`records/proof-mode-architecture.md`
- "Families": add a Stability row; remove `⊡` and `⟐` from the Modal row; rewrite the two
  paragraphs on the Modal family's two operators (the structure-per-operator design stands).
- "Interactions": add `StabilityBoolean` (collapse), `ModalStabilityBoolean` (`□φ → ⊡φ`),
  `StabilityTemporalBoolean` (pasting, `Will`, `will`, `Could`, `could`) and, if any rule needs
  all four, `ModalStabilityTemporalBoolean`; remove those items from the existing rows; drop the
  sentence on `⊡` sections within a module.
- "One scheme, used six times" and "Adding a language extension": the fragment names and the
  correspondence examples.
- "Where the work sits": the `□` and `⊡` scopes row and the sweeps row.
- "Open decisions": remove decision 1.

`records/proof-mode.md`
- Goal 5 (the sentence naming this investigation), M1's done-when ("the TM⁺ stability mirror"
  becomes a Stability-family item), M19's fragment list, M21's done-when and sequencing, M23, and
  open decision 2.

`records/milestones.md`: rows B2, B5 and D2 name the single S5 step over `□` and `⊡`; wording only.

Filed tasks
- `proof_mode_split_shared_test_and_guide_files`: remove the "FAMILY LAYOUT REVISED" paragraph;
  its original text already names Stability and `StabilityModal`, to be renamed to the
  Boolean-inclusive interaction names; `file_scope` is the two directories and stands.
- `proof_mode_s5_aware_box_scopes`: remove the "FAMILY LAYOUT REVISED" paragraph; add
  `FormalSystem/Theorems/ProofMode/Stability.lean`, `FormalSystem/Automation/ProofMode/Stability.lean`,
  a `StabilityTest.lean` and `docs/user-guide/proof-mode/stability.md` to `file_scope`.
- `proof_mode_abstract_frontend_interface`: remove the "FAMILY LAYOUT REVISED" paragraph; classes
  `Stability`, `StabilityBoolean`, `ModalStabilityBoolean`, `StabilityTemporalBoolean`.
- `proof_mode_cross_modal_scopes_mf_tf`, `proof_mode_always_sometimes_scopes`: unaffected unless
  they carry pasting scope rules, which would move to `StabilityTemporalBoolean`.
- `theorem_library_layout_and_registry`: family set of three, eight fragments, no operator set;
  the index of missing duals unchanged.
- `theorem_library_stability_entries`: `file_scope` becomes files under
  `BimodalLib/{Theorems,ProofMode,Countermodels}/` in the `Stability*` fragment directories.
- `theorem_library_fragment_conservativity`: the edge list.
- `theorem_library_tableau_pipeline`: no change; its four fragments are then exactly the
  tableau-covered ones.

This list was assembled from the records and the descriptions read in this pass; the descriptions
of `proof_mode_cross_modal_scopes_mf_tf`, `proof_mode_always_sometimes_scopes` and
`connective_signature_layer_shared_primitives` were not read in full, so the list is not claimed
complete for those three.

### C. Searches used

- `grep -n "⊡\|[Ss]tabil\|M23\|necessity\|Nomic\|Open" records/proof-mode.md`
- `jq` selections over `specs/state.json` on `project_name` and on `description` (Appendix A)
- `grep` for constructors and theorem heads in `PlusLanguage/`, `OpenLanguage/`, `NomicLanguage/`,
  `Semantics/Nomic/`, `Semantics/TruthClauses.lean`, `Theorems/ProofMode/Congruence/`
- `grep -rn "class HasBox\|class Modal.*Hilbert\|HasDynamicBox\|ProofSigHom"` in cslib
- `git log -S"StabilityModal" -- records/` for the earlier layout
