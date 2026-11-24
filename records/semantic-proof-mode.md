# Semantic proof mode

The semantic mode evaluates formulas at a specified model, history, time and environment.
Its main client is a proof that a formula fails at a particular countermodel point. This
record complements the [proof-mode architecture](proof-mode-architecture.md), the
[theorem and countermodel library](theorem-library.md), and the
[project milestones](milestones.md).

## Judgments and evidence

The evaluator takes a goal of the form `TruthEnv.T M τ t e A` or its negation. It also accepts
`PlusTruthAt` and `StarTruthAt` goals, and returns its remaining goals in the head it was given. It
recurses over the syntax of `A` with the rule registered for each operator. The evaluator applies directional clause lemmas
up to definitional equality on all three heads.
A blanket `rw` fails on `TruthEnv.T` when the formula is written with a per-language operator such as
`PlusFormula.allFuture`. An atom leaves
a valuation obligation. A universal clause may introduce an arbitrary time or history or use
a supplied counterexample. An existential clause may use a supplied witness or introduce the
witness of an assumed truth in a refutation. Bounded search can supply either witness when
its result carries evidence accepted by the clause. Until and Since retain the ordering
evidence, event endpoint and guard interval. Store and recall use the selected language's
environment operations.

The evaluator checks supplied evidence and leaves an explicit obligation for an unresolved
clause. It can prove truth or falsity from checked certificates for arbitrary formula syntax.
A separate decision procedure would require a presentation covering all time and history
quantifiers. A finite state carrier does not by itself provide such coverage.

Start with one tactic, tentatively `seval`, with explicit witness, refuter and normalizer
arguments as needed by the measured clients. Give the mode a distinct registry and syntax
under `FormalSystem/Semantics/`. Register each rule with a theorem and an operator shape.
Parsing uses syntax quotations, and elaboration errors identify the argument that failed.
The shared views and position planner provide formula syntax without depending on either
proof mode. Evaluation uses clause semantics, so it can proceed without the position planner.
A later local rewrite interface can use it to select the occurrence and discharge the
pointwise demand there.

Point transport uses the semantic library's explicit source and destination judgments.
An evidence argument states the relation on the two points and the direction in which
truth transfers.

Pointed soundness with premises is stated once over `TruthEnv`, each language an instance, in
[PointedSoundness.lean](../FormalSystem/Metalogic/PointedSoundness.lean) (D4). The soundness adapter (C4), under
`FormalSystem/Metalogic/`, applies `truth_of_derivation` and wraps no language's soundness theorem.
It supplies the frame-class evidence, the environment (`PUnit.unit` for TM and TM⁺, the stored-time
vector for TM⋆) and truth of every premise at the specified point.

## Scope

The tableau finds a countermodel; the evaluator checks one it is given. The evaluator therefore has
clients wherever the tableau has no verified verdict, today `⊡` and L⋆. The two form a pipeline:
the tableau proposes and the evaluator certifies.

None of the four clients below exercises Until, Since or store. Their first rules wait for a client
that does. Store and recall have no clause class, so their rules are per-language registry entries.
`refute_modal_future` needs the recall entries.

## Initial clients

Keep the models, witness data and statement of each reference proof fixed. Measure the
proofs of truth or falsity inside the refutations first, then the complete declarations.

| Reference declaration | Part to measure |
|---|---|
| `PlusNonValidities.lean` · `refute_allFuture_stab` | Prove the universal premise, then refute stability at the supplied history and future time. |
| `PlusNonValidities.lean` · `refute_stab_allFuture_past` | Compose stability, future and past clauses while keeping the times of the witnesses explicit. |
| `StarNonValidities.lean` · `refute_modal_future` | Evaluate the recall implication at the named history, future time and register environment. |
| `StarNonValidities.lean` · `refute_sentDet` | Use the existing witness theorem as a short control and measure the two atom obligations. |

These declarations are the first candidate clients for the countermodel side of
`BimodalLib`. Add examples that exercise a clause only when an existing proof needs it.

## Measurement and milestones

1. Land the standalone semantic lemmas with the directional clause lemmas: for each clause class, a
   truth form and a refutation form, generic over the class. Re-prove the selected declarations
   with these alone. This is the control.
2. Prototype the smallest evidence checker for the selected declarations (C3). Repeat the proofs
   with the same imports, witnesses and normalization lemmas. Keep the reference, control and
   evaluator scripts next to their measurements.
3. Report source tokens, elaborated term size and median elaboration time across three runs
   with an identical warm dependency cache and the pinned Lean version. Share the valuation
   obligations (atoms and state agreement) between the versions as named facts, and report them
   apart from clause recursion. Report unresolved obligations and any work moved into custom rules
   or preprocessing. Count each helper once. Restyle the control to its shortest known form first,
   and use one token counter throughout.
4. Adopt a tactic when it meets the threshold below and keeps witness and transport obligations
   legible. Keep work in the lemma library when the control achieves the same saving. File
   further tactics by operator family with a named use and the comparison that warrants them. Add
   the proof-mode interface and the soundness adapter at C4.

### Adoption threshold

Use the clause-ordered interface for the next prototype if it reduces clause-recursion tokens by
at least 10% against both the reference proof and the best lemmas-only control on all three clients
that perform clause recursion. Keep the fourth client, `refute_sentDet`, as a control for the
cost of invoking a tactic when a witness theorem already does most of the work.

This is a provisional version of the proposed three-of-four threshold. Restyling the control alone
changed a proof by 1–22 tokens, so a one-token lead would be poor evidence for choosing an
interface. The 10% threshold was set after the pilot. Step 3 should repeat the comparison independently
and report diagnostic quality, elaboration time and the cost of maintaining the implementation before
deciding on a public tactic.

## The witness interface

Later evidence uses names bound by earlier clauses in all three clients, so either interface must
bind names. Two were tried.

- A **clause-ordered pattern** lists one item for each clause in the order the recursion meets them.
  An item is a tuple of names where the clause introduces, a tuple of evidence where it
  chooses, and a proof at an atom. A branching clause takes one list for each branch.
- **Labelled entries** name the operator and branch each item belongs to. Order is free, and a
  repeated operator is numbered.

The probe under `specs/evidence/semantic-witness-interface/` implements both forms over one
clause recursion. It compiles against the library and prints the token counts and term sizes. The prototypes are measurement apparatus: they close a goal or fail, return no goals, cover
only the clauses these clients use, and are not the evaluator. The lemmas-only control is
stronger than the first one written for this comparison.

`refute_stab_allFuture_past` refutes `⊡GPp → G⊡Pp` and has three clause layers on each side.
`agree_one` and `atom_fails` are its two valuation facts.

```lean
seval_pat [[⟨_σ, hs⟩, ⟨_y, hy⟩, ⟨0, hy⟩, hs.symm],
  [⟨1, one_pos⟩, ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩, ⟨_s, hs⟩,
    atom_fails hs p]]

seval_lab [prem.stab := ⟨_σ, hs⟩, prem.future := ⟨_y, hy⟩, prem.past := ⟨0, hy⟩,
  prem.atom := hs.symm, concl.future := ⟨1, one_pos⟩,
  concl.stab := ⟨natHist fun s => if s = 1 then 0 else 1, agree_one⟩,
  concl.past := ⟨_s, hs⟩, concl.atom := atom_fails hs p]
```

**Source tokens**, as leaves of the syntax tree Lean's parser gives the proof after `:=`, with the
valuation facts shared:

| Client | Reference | Control | Pattern | Labelled |
|---|---|---|---|---|
| `refute_allFuture_stab` | 113 | 85 | 69 (−19%) | 77 (−9%) |
| `refute_stab_allFuture_past` | 146 | 97 | 82 (−15%) | 94 (−3%) |
| `refute_modal_future` | 138 | 93 | 73 (−22%) | 79 (−15%) |
| `refute_sentDet` | 91 | 91 | 95 | 99 |

Percentages are against the control. An earlier comparison reported reference/control counts of
167/145, 235/165 and 229/168 for the three recursive clients. This probe uses factored valuation
proofs and counts syntax-tree leaves, so comparisons use the four columns measured together here.
[Earlier measurement](https://github.com/benbrastmckie/BimodalLogic/pull/10#issuecomment-7112754953)

On the first three clients the elaborated terms
are 4% to 9% larger than the control's, and equal for the two interfaces. Heartbeats, identical over
three runs, are 1% to 5% above the control's; the reference uses fewer than both. Wall-clock time
was not measured.

**Dependent evidence.** In the pattern an item follows the item that binds its names, and reads
beside it: `⟨_y, hy⟩, ⟨0, hy⟩`. Which operator an item serves has to be counted off against the
formula. A label says it, but free order lets a use precede its binder, and numbered labels
shift when an operator is inserted. No client repeats an operator on a branch, so numbering is not
exercised.

**Where errors are reported.** The probe checks missing, extra and exchanged items in both
forms. It checks the wrong witness with the pattern.

| Fault | Pattern | Labelled |
|---|---|---|
| Wrong order evidence | at the evidence | at the evidence |
| Wrong number of names in an item | at the item | at the item |
| Missing binder item | at the next item, naming the clause | at the tactic head, naming the entry |
| Branch ends early | at that branch's list | at the tactic head |
| Extra item | at the item | at the entry |
| Two binder items of equal length exchanged | not at the items: at the first later use | accepted |
| Wrong witness time | at the dependent evidence | unmeasured |

**Finding.** Use the clause-ordered pattern for C3. It meets the provisional threshold on all
three recursive clients and keeps dependent evidence beside its binder. Labelled entries locate
a missing item more precisely and allow reordered binders. Have the pattern report the clause
and expected binder types at each failure. Neither interface improved the witness-theorem client.
The pilot establishes an interface preference. C3 still owes an independent measurement and an
evaluator that returns open obligations.

## Open decisions

1. **Placement.** The evaluator sits beside the lemmas under `FormalSystem/Semantics/` and the mode
   is a thin layer over it, as Goal C of [milestones.md](milestones.md) has it. The alternative is
   one module holding both; its merit is one registry and one syntax, and it would tie the
   evaluator's library clients to the tactic layer.
2. **Witness interface.** The finding above is the clause-ordered pattern. It is reopened by a
   client that repeats an operator on a branch, or by an error report showing that the
   exchanged-binder fault is common.
3. **Sharing.** The evaluator imports nothing from `FormalSystem/Automation/ProofMode/` and
   recognizes operators through its own rule registry, not `FormalSystem/Tactic/FormulaSyntax.lean`,
   which stops at TM⁺. The generic clause lemmas already apply at `StarFormula`, so the two L⋆
   clients do not wait on the signature layer (D1), which later merges the per-language keys.
4. **Grade of an evaluator-checked refutation.** Decided by `theorem_library_countermodels` (B4).
5. **Adoption threshold.** The provisional threshold above stands until step 3 reports.
