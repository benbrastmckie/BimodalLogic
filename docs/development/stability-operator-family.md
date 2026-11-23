# The Stability Operator and the Modal Family

An evaluation of where the stability operator `⊡` and its dual `⟐` are filed in the operator
families of the theorem library and the proof mode: under Modal, beside `□` and `◇`, or in a
Stability family of their own. The layout is described in
[`records/theorem-library.md`](../../records/theorem-library.md) and
[`records/proof-mode-architecture.md`](../../records/proof-mode-architecture.md); the milestone
is M23 of [`records/proof-mode.md`](../../records/proof-mode.md).

## Verdict

**One family. `⊡` belongs in Modal.**

The Modal family is the family of *necessity operators over histories*. Its laws are stated once,
with the operator as a parameter, and each operator of a language instantiates them at the
strength it has.

- The two layouts record the same eight cells. They differ in whether four of the cells are
  directories or sections, and in nothing else that is information.
- Without Temporal, `⊡` is the identity. Two of the four fragments a Stability family would add
  hold the collapse and nothing else.
- The modal operators of the Open language are further instances of the same laws at S5, and the
  nomic operator is an instance at a weaker strength. A family per necessity operator doubles the
  set of fragments with each operator; one family keeps four fragments for any number of them.
- Each of the three facts that distinguish `⊡` from `□` is a property of an operator, recurring
  in another form for the other restricted necessities. None marks a family boundary.
- The parameterized statement is compiled: `NecessityRules` in
  `FormalSystem/Theorems/ProofMode/Congruence/Modal.lean`, instantiated at three operators.

Three things follow for how the design is stated; they are set out under
[What the layout states](#what-the-layout-states). The cost of the alternative is under
[What a separate Stability family would require](#what-a-separate-stability-family-would-require).

## Evidence tier

Every claim here was established by reading source: the Lean files named in each section, and
cslib at commit `3bdf16d9f`. Each declaration named was confirmed to exist under that name in the
file given. Nothing was compiled for this evaluation and no probe was run.

One claim is an inference and not a named declaration: that K and necessitation hold for the
nomic operator `◈` over every nomic frame. It follows from the shape of the truth clause, a
universal quantifier over a set of histories. The tree states K by name for `◈` on the tense-free
fragment only (`nomic_k_tenseFree`). The verdict does not depend on the inference: seriality
alone (`nomic_serial`) shows `◈` is not an S5 operator in general, which is all the argument
uses.

## The two layouts are the same eight cells

The one-family layout has four fragments, `Boolean`, `ModalBoolean`, `TemporalBoolean` and
`ModalTemporalBoolean`, and records for each entry an **operator set**: which modal operators
occur in it. The operator set ranges over none, `□`, `⊡`, and both. A **cell** is a fragment
together with an operator set. A layout with families Modal, Stability and Temporal has eight
fragments. They are the same eight cells.

| Cell | One family | Separate Stability family |
|---|---|---|
| no modal operator, no Temporal | `Boolean` | `Boolean` |
| `□` | `ModalBoolean`, operator set `□` | `ModalBoolean` |
| `⊡` | `ModalBoolean`, operator set `⊡` | `StabilityBoolean` |
| `□`, `⊡` | `ModalBoolean`, operator set both | `ModalStabilityBoolean` |
| Temporal | `TemporalBoolean` | `TemporalBoolean` |
| `□`, Temporal | `ModalTemporalBoolean`, operator set `□` | `ModalTemporalBoolean` |
| `⊡`, Temporal | `ModalTemporalBoolean`, operator set `⊡` | `StabilityTemporalBoolean` |
| `□`, `⊡`, Temporal | `ModalTemporalBoolean`, operator set both | `ModalStabilityTemporalBoolean` |

The layouts differ in three practical respects.

- **Directories and module names.** A Stability family doubles the fragment directories in each
  place the naming scheme is used, and adds a pure `Stability` module with its interactions to
  each.
- **Which conservativity edges are lattice edges.** The conservativity of TM⁺ over TM
  (`plusDerivable_ofFormula_iff`, `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean`) adds
  `⊡` at `ModalTemporalBoolean`. If the lattice is the four fragments alone, that edge runs
  inside one fragment and is not an edge of the lattice. With a Stability family every such edge
  is a lattice edge. This is the strongest consideration in favour of a separate family. It is
  met without one by making the operator set a coordinate of the lattice, so that edges run
  between cells.
- **How the scheme grows** with further necessity operators. This decides the question, and is
  the subject of [Open and Nomic operators](#open-and-nomic-operators-are-further-instances).

## The three proved facts, weighed

### Without Temporal, `⊡` is the identity

`PlusFormula.StateLocal` admits atoms, `⊥`, implications of state-local formulas, and any formula
headed by `□` or `⊡`, whatever lies beneath the head. `plusStateLocal_stab_iff`
(`FormalSystem/PlusLanguage/PlusStateLocal.lean`) gives `φ ↔ ⊡φ` for every state-local `φ` at
every frame. A formula with no temporal operator is state-local, so in a cell without Temporal
`⊡` is the identity.

For a Stability family this makes two of its four added fragments degenerate.
`StabilityBoolean` and `ModalStabilityBoolean` contain no temporal operator, so each would hold
the collapse, the S5 laws of `⊡` (which the collapse makes trivial), and nothing more. Everything
particular to `⊡` sits in the two fragments with Temporal. A family whose pure module and whose
interaction with Boolean are both trivial is a weak candidate for a family.

For the one-family layout the collapse is one entry in `ModalBoolean`.

### TM⁺ is not closed under uniform substitution

The axiom `atom_stab` (`FormalSystem/PlusLanguage/Axioms.lean`) is `p → ⊡p` for atoms, and
`stab_of_stateLocal` extends it to state-local formulas and no further. `□` has no such schema,
so this is a real difference between the two operators.

It is not a difference between `⊡` and the other restricted necessities. In `OpenAxiom`
(`FormalSystem/OpenLanguage/OpenAxioms.lean`), `▷` has `rigidity_ofut_bwd`, restricted to
`IsPurePastOpen` formulas, and `◁` has `rigidity_opast_bwd`, restricted to `IsPureFutureOpen`
formulas; atoms satisfy both predicates. Each restricted necessity `N` therefore comes with a
**rigid class**: a syntactic class of formulas `φ` for which `φ → Nφ` holds, the schema being
restricted to that class.

| Operator | Rigid class |
|---|---|
| `□` | contains no atom |
| `⊡` | state-local formulas |
| `▷` | pure-past formulas |
| `◁` | pure-future formulas |

Restricted substitution is a parameter of the operator. Either layout has to record a
substitution class per entry. A family boundary around `⊡` would mark one instance of the pattern
and leave the others unmarked.

The fact does place one condition on the theorem library's tableau pipeline. Its last stage
generalizes a certified valid formula from atoms to schema variables, and that step is sound only
where uniform substitution holds. The enumerator runs over `Formula`, which has no `⊡`, so the
step is sound for what the pipeline produces. The condition is on the cell, and is stated as
such: the pipeline runs on cells whose operator set is within `□`.

### The tableau does not cover `⊡`

The decision procedure is over `Formula`. This is a fact about a language. "The operator set
contains `⊡`" and "the fragment contains Stability" express it equally. With a Stability family
the tableau-covered fragments are the four without Stability; with one family they are the cells
whose operator set is within `□`. The difference is one of wording.

### Net

The collapse counts against a separate family. Restricted substitution and tableau coverage are
neutral between the layouts; each asks that operator-level data be recorded per entry, which the
one-family layout does through the operator set and the substitution class.

## Open and Nomic operators are further instances

### `▷` and `◁` in the Open language

They are S5 necessities with a calculus.

- `OpenAxiom` has `ofut_k`, `ofut_t`, `ofut_four` and `ofut_five`, and `opast_k`, `opast_t`,
  `opast_four` and `opast_five`, as schematic axioms.
- Necessitation for each is a derived rule, obtained through the chain from `□` to `⊡` to `▷` or
  `◁`: `stabNecessitation`, `ofutNecessitation` and `opastNecessitation` in
  `FormalSystem/OpenLanguage/OpenDerivation.lean`. TM⁺ derives necessitation for `⊡` the same way
  (`stabNecessitation`, `FormalSystem/PlusLanguage/Derivation.lean`).
- The operators are ordered by inclusion of their classes of histories. The axioms
  `stab_of_box`, `ofut_of_stab` and `opast_of_stab` give `□φ → ⊡φ`, `⊡φ → ▷φ` and `⊡φ → ◁φ`.
  `FormalSystem/OpenLanguage/OpenOckhamist.lean` shows each implication strict and `▷`, `◁`
  incomparable.
- On regular frames `⊡φ ↔ ▷◁φ` (`stab_iff_ofut_opast`, `FormalSystem/OpenLanguage/OpenTruth.lean`).
  Only the forward half is an axiom (`definability_fwd`).

So `▷` and `◁` instantiate the parameterized statement exactly as `⊡` does: distribution by an
axiom, necessitation derived, and T, 4 and 5 by axioms. Each also has the two per-operator pieces
`⊡` has: an inclusion from a stronger operator, and a rigidity schema on a rigid class.

### `◈` in the Nomic language

It is a necessity at a weaker strength, and it has no calculus.

- Over every nomic frame, K and necessitation hold (the inference marked under
  [Evidence tier](#evidence-tier)) and D holds (`nomic_serial`,
  `FormalSystem/NomicLanguage/NomicValidity.lean`).
- T holds on lawful frames. `NomicFrame.Lawful` (`FormalSystem/Semantics/Nomic/Frame.lean`) says
  that every possible world is a law-history at each state it occupies, which is reflexivity of
  the relation `◈` quantifies over.
- 4 holds over integer time exactly on uniform frames (`four_validOn_iff_uniform`,
  `FormalSystem/NomicLanguage/NomicFour.lean`), and on those `◈` coincides with `□`
  (`nomic_iff_box_of_uniform`).
- K, T, 4, 5 and B hold on the tense-free fragment over every frame (`nomic_k_tenseFree`,
  `nomic_t_tenseFree`, `nomic_four_tenseFree`, `nomic_five_tenseFree`, `nomic_b_tenseFree`).

So `◈` is KD in general, KT on lawful frames, and S5 on uniform frames or on a restricted
fragment. It is a necessity operator of a given strength only if the shared statement lets an
operator supply the K core without T, 4 and 5.

Two limits apply. `◈` is evaluated over `NomicFrame`, which is not a `TaskFrame`, and the Nomic
component has no proof system. `◈` is therefore an instance of the *laws* and cannot be an
instance of the proof-mode *interface*, and it sits outside the fragment lattice, which is over
one frame notion.

### What the five operators share, and what they do not

| Piece | Shape | `□` | `⊡` | `▷`, `◁` | `◈` |
|---|---|---|---|---|---|
| K core: scope introduction, distribution, monotonicity, the diamond duals | one operator | yes | yes | yes | yes, semantically |
| T | one operator | yes | yes | yes | lawful frames |
| 4, 5 | one operator | yes | yes | yes | uniform frames |
| Inclusion `Nφ → Mφ` | an ordered pair of operators | source | from `□` | from `⊡` | from none; equals `□` under uniformity |
| Rigidity `φ → Nφ` on a rigid class | one operator and a formula class | none on atoms | state-local | pure-past, pure-future | not stated |
| Interaction with Temporal | particular to the operator | MF, TF, perpetuity | pasting, with purity conditions | HN and its mirror | 4 fails through `U`, `S` |

The first three rows are the shared statement. The last three are not shared by their nature: an
inclusion relates two operators, a rigidity schema needs a formula class, and the temporal
interactions have nothing in common. The principles of `□` do not transfer to `⊡`:
`FormalSystem/PlusLanguage/PlusNonValidities.lean` refutes `⊡p → □⊡p` (`refute_stab_box`),
`G⊡p → ⊡Gp` (`refute_allFuture_stab`), `⊡GPp → G⊡Pp` (`refute_stab_allFuture_past`) and
`P⊡p → ⊡Pp` (`refute_somePast_stab`).

### Scaling

If each necessity operator were a family, `k` operators would give 2^k sets of families, and the
directory tree, the module scheme and the interface classes would all multiply with it. With `□`,
`⊡`, `▷` and `◁` that is sixteen modal combinations before Temporal is counted. One family keeps
four fragments for any `k` and grows the operator set. "Necessity operator of a given strength"
is the abstraction, on one condition: the shared statement is stratified by law.

## The parameterized statement as compiled

`FormalSystem/Theorems/ProofMode/Congruence/Modal.lean` defines

```lean
structure NecessityRules {L : Type} {P : L → Type} (kit : Kit L P) where
  operator : L → L
  distribution : ∀ A B, P (kit.imp (operator (kit.imp A B))
    (kit.imp (operator A) (operator B)))
  mono : ∀ {A B}, P (kit.imp A B) → P (kit.imp (operator A) (operator B))
```

with one congruence step, `Step.necessity`, taking the structure, and three instances: `tmBox`,
`plusBox` and `plusStability`. The operator is a field; each instance supplies the fields by
axiom or by derivation from its own axiom base.

- The structure carries the K core and no T, 4 or 5. A stratified statement, with the K core as
  base and each further law a separate member, matches this code and matches cslib's layering of
  one class per axiom. It is also what admits a KD operator.
- The semantic side has the same per-operator shape. `StabClause` is a class of its own in
  `FormalSystem/Semantics/TruthClauses.lean`, beside `BoxClause`, and `StabClauses` extends
  `UntlClauses`. That is one clause class per operator, which fits either layout.

## Hosting two necessity operators in cslib

Files read, at cslib commit `3bdf16d9f`: `Cslib/Foundations/Logic/Operators.lean`,
`Cslib/Foundations/Logic/Connectives.lean`, `Cslib/Foundations/Logic/ProofSystem.lean`,
`Cslib/Foundations/Logic/Metalogic/ProofSystemMorphism.lean`, and the generic theorem modules
`Cslib/Foundations/Logic/Theorems/Modal/Basic.lean` and `S5.lean`.

What cslib provides:

- `HasBox α`, with one field `box : α → α`, keyed on the formula type alone.
- One class per modal axiom (`HasAxiomK`, `HasAxiomT`, `HasAxiom4`, `HasAxiomB`, `HasAxiom5`,
  `HasAxiomD`), a rule class `Necessitation`, and the bundles from `ModalHilbert` through
  `ModalS5Hilbert` to `BimodalTMHilbert`. Each takes `[HasBox F]` as an instance argument.
- Generic theorem modules stated over a bundle.
- `HasDynamicBox α β`, a box indexed by a second type, with no axiom classes over it.
- `ProofSig`, `ProofSigHom` and `Deriv.map`: a formula map preserving implication, a map of axiom
  families, and a coherence condition on closure operators, which together transport
  derivations.

Because the box is an instance argument of every axiom class and bundle, those classes are
already parameterized by the operator in their types: `ModalS5Hilbert S` at one `HasBox F`
instance and at another are different propositions. What cslib does not provide is a way for
instance resolution to find a second box on the same type. Four routes host `⊡`, ordered by how
much they ask of cslib.

| Route | What it is | Cost |
|---|---|---|
| Explicit instance | `HasBox PlusFormula := ⟨box⟩` stays the instance; a named, non-instance `HasBox PlusFormula` built from `stab` is passed explicitly to the bundle and to each generic theorem. | No change to cslib. The `□` notation resolves to the instance, so statements about `⊡` print as `□`, and every use site names the second box. |
| Type synonym | A synonym of the formula type carrying `HasBox` at `stab`, with the inference system carried across, in the manner of `OrderDual`. | No change to cslib. Instance resolution works. A statement mixing the two operators crosses the synonym. |
| Morphism | A `ProofSigHom` from an S5 signature into TM⁺ sending the box to `stab`; the closure condition is met once necessitation for `⊡` is offered as a closure of the target, and `Deriv.map` transports every S5 derivation. | No change to cslib. It transports derivations, not class instances, so a generic theorem is reached by mapping its derivation. |
| Indexed necessity | Axiom classes and bundles over an indexed box in the style of `HasDynamicBox`, the index ranging over the necessity operators of the language. | New upstream API. It is the only route in which "two S5 operators and an inclusion between them" is a class one can state. |

cslib's own precedent for a second necessity-like operator points away from a second `HasBox`.
`G` and `H` are necessity-like operators on a type that has `HasBox`, and `BimodalTMHilbert` does
not host them through a second box: `TemporalBXHilbert` has axiom classes of its own written over
`HasUntil` and `HasSince`, and the interaction axiom `HasAxiomMF` is likewise particular.

For the layout here: a structure with the operator as a field is the local counterpart of cslib's
parameterization by instance argument, made explicit, and corresponds to the explicit-instance
route. One `HasBox` per formula type stays the rule. Nothing in cslib favours a separate family;
a Stability family would correspond to a `HasStab` class with its own copies of the axiom
classes, which is the duplication the parameterized statement avoids.

## Summary of the weighing

| Consideration | One family | Separate Stability family |
|---|---|---|
| Information recorded | eight cells | the same eight cells |
| Collapse without Temporal | one entry | two of four added fragments degenerate |
| Restricted substitution | substitution class per entry | substitution class per entry |
| Tableau coverage | cells with operator set within `□` | fragments without Stability |
| TM into TM⁺ as a lattice edge | yes, with the operator set a coordinate | yes |
| S5 laws stated once | yes, one structure instantiated per operator | yes, the same structure; the family boundary adds nothing |
| Rules particular to `⊡` | sections and files inside Modal fragments | modules of their own |
| `▷`, `◁`, and `◈` | join the family; four fragments | each a family; the fragments double per operator |
| cslib counterpart | parameterization by explicit instance | duplicated axiom classes |

## What the layout states

The recommendation keeps every module name, every fragment and every interface class of the
one-family layout. It asks three things of how that layout is stated, and the records state them.

1. **The shared statement is stratified.** Its base is a K core: scope introduction, distribution,
   monotonicity and the diamond duals. T, 4 and 5 are further members an operator supplies when
   it has them, and D is the member a serial operator supplies. `NecessityRules` is the compiled
   K core. `□`, `⊡`, `▷` and `◁` join the family at S5; `◈` joins at KD once it has a calculus
   over the lattice's frame notion.
2. **The operator set is a coordinate of the lattice.** A cell is a fragment together with an
   operator set, and conservativity edges run between cells. TM into TM⁺ is the edge that adds
   `⊡` to the operator set at `ModalTemporalBoolean`. The tableau pipeline, including its
   generalization from atoms to schema variables, runs on cells whose operator set is within `□`.
3. **Three pieces lie outside the shared statement, each per operator.** An **inclusion** is a
   rule about an ordered pair of operators, supplied only by a language that has both. A
   **rigidity** rule takes an operator and a rigid class; it is not schematic and says so in its
   statement. **Interactions with Temporal** are particular to the operator: the sections of
   `ModalTemporalBoolean` that name `⊡` share no statement with those for `□`.

Two risks are accepted with the recommendation.

- The sections naming `⊡` inside `ModalTemporalBoolean` hold pasting and the operators defined
  from it, and may grow large. A file per operator inside a fragment directory is available
  without a family, and the filed record `theorem_library_stability_entries` already scopes such
  files.
- A class indexed by operator may prove more convenient than a structure when the interface is
  extracted. Either carries a per-operator statement inside one family, so the choice is
  independent of this one.

## What a separate Stability family would require

This is the cost of the rejected layout: the changes it would need across the design records and
the filed records. Module order would be Modal, Stability, Temporal, Boolean.

**`records/theorem-library.md`**

- The lattice: a Stability row in the family table; eight fragment rows in place of four; the
  collapse and `□φ → ⊡φ` filed in `StabilityBoolean` and `ModalStabilityBoolean`.
- A section on the Stability family in place of the one on two operators in Modal, keeping the
  three facts and the parameterized statement, instantiated across two families.
- The filing rule without the operator set, stating that only fragments containing Stability
  have restricted substitution classes.
- The rule for adding a family restricted to operators with no rigid class.
- Conservativity: one row per fragment gaining Stability, including `ModalBoolean` into
  `ModalStabilityBoolean` and `Boolean` into `StabilityBoolean`.
- Sources: the tableau covers the four fragments without Stability.

**`records/proof-mode-architecture.md`**

- Families: a Stability row, with `⊡` and `⟐` out of the Modal row. The structure-per-operator
  design stands.
- Interactions: `StabilityBoolean` (the collapse), `ModalStabilityBoolean` (`□φ → ⊡φ`),
  `StabilityTemporalBoolean` (pasting and the operators defined from it) and, if a rule needs all
  four families, `ModalStabilityTemporalBoolean`, with those items out of the existing rows.
- The fragment names in the description of the naming scheme and in the examples of adding a
  language extension, and the rows for `□` and `⊡` scopes and for sweeps in the table of where
  the work sits.

**`records/proof-mode.md`**

- The goal naming the family layout, the done-when of the milestone carrying the TM⁺ stability
  mirror, M19's fragment list, and M21's done-when and sequencing.

**`records/milestones.md`**

- The rows naming the single S5 step over `□` and `⊡`; wording only.

**Filed records**

| Record | Change |
|---|---|
| `proof_mode_split_shared_test_and_guide_files` | Stability and its interactions named among the split files; `file_scope` is two directories and stands. |
| `proof_mode_s5_aware_box_scopes` | `file_scope` gains `FormalSystem/Theorems/ProofMode/Stability.lean`, `FormalSystem/Automation/ProofMode/Stability.lean`, a stability test file and `docs/user-guide/proof-mode/stability.md`. |
| `proof_mode_abstract_frontend_interface` | Interface classes `Stability`, `StabilityBoolean`, `ModalStabilityBoolean` and `StabilityTemporalBoolean`. |
| `proof_mode_cross_modal_scopes_mf_tf`, `proof_mode_always_sometimes_scopes` | Unaffected unless they carry pasting scope rules, which would move to `StabilityTemporalBoolean`. |
| `theorem_library_layout_and_registry` | A family set of three, eight fragments, no operator set. |
| `theorem_library_stability_entries` | `file_scope` becomes files in the `Stability*` fragment directories. |
| `theorem_library_fragment_conservativity` | The edge list. |
| `theorem_library_tableau_pipeline` | No change; its four fragments are then the tableau-covered ones. |
| `connective_signature_layer_shared_primitives` | A class for the stability operator apart from the Modal one. |

The list was assembled from the design records and the descriptions of the filed records. The
descriptions of `proof_mode_cross_modal_scopes_mf_tf` and `proof_mode_always_sometimes_scopes`
were not read in full, so it is not claimed complete for those two.
