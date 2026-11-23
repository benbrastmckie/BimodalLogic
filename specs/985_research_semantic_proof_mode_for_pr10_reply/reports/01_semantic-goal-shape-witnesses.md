# Research Report: Task #985

**Task**: 985 - Research semantic proof mode goal shape and witnesses for the PR #10 reply
**Started**: 2026-11-23T19:33:35Z
**Completed**: 2026-11-23T19:45:50Z
**Effort**: about 1.5 hours
**Dependencies**: None
**Sources/Inputs**: - `specs/reviews/pr-reviews-2026-11-21/pr10-review.md`, `pr10-comment.md`, `pr11-comment.md`; `specs/978_.../reports/01_review-pr11-pointed-semantic-lemmas.md`; `specs/990_.../reports/01_rereview-pr11-at-usability-and-tests.md`; `records/milestones.md`, `records/proof-mode-architecture.md`; `records/semantic-proof-mode.md` at PR #10 head `ada7074dd`; `main` at `edfce7452` (`Semantics/TruthClauses.lean`, `PointTransport.lean`, `TemporalRules.lean`, `PlusLanguage/PlusTruth.lean`, `PlusNonValidities.lean`, `StarLanguage/StarTruth.lean`, `StarNonValidities.lean`, `Tactic/FormulaSyntax.lean`); PR #9 head `b3d8f6463` (`SemanticMeta.lean`, `SemanticCore.lean`, `ProofModeExtensionsTest.lean`); three compiled probes run with `lake env lean` through the build guard
**Artifacts**: - `specs/985_research_semantic_proof_mode_for_pr10_reply/reports/01_semantic-goal-shape-witnesses.md`; probes in `specs/985_research_semantic_proof_mode_for_pr10_reply/probes/` (`P1.lean`, `P2.lean`, `P3.lean`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Two inputs named in the task have moved.** PR #10's head is `ada7074dd`, not `bdaa3b6d0`; it
  is `CONFLICTING` with `main`. PR #11 is **merged** at `b2eb3ac0b` with the `at_def` simp
  lemma. The "which `At` fix" question is therefore retrospective; the answer is that the fix that
  landed is the right one, and there is nothing further to ask of #11.
- **Goal shape.** The evaluator should not recurse by rewriting at all. Clause lemmas *apply* up
  to definitional equality on all three heads (`PlusTruthAt`, `TruthEnv.T`, `At`), while `rw`
  fails on two of them, and fails on `TruthEnv.T` itself whenever the formula is written with a
  language's own derived operator (compiled, `P1.lean`). So the canonical shape is the record's
  `TruthEnv.T M τ t e A`, with the per-language heads accepted on input and used for display.
  `At` is the wrong recursion shape: every clause moves one coordinate of the point, and
  `At`-level clauses nest `Point` literals three deep after three layers (compiled, `P3.lean`).
- **Witness interface.** "Argument list or named witnesses" is too coarse a choice. In all three
  clients a later witness or obligation uses a name introduced by an earlier universal clause, so
  any interface must bind names; the real choice is between a clause-directed *pattern* (binder
  names and witness terms in clause order, as in `rintro`/`refine`) and labelled entries.
- **The control is under-specified, and that changes the threshold's meaning.** With twelve
  directional clause lemmas (truth-introduction and refutation forms; 44 lines, generic over the
  clause classes), plain term-mode Lean re-proves the three clients in 8, 9 and 9 lines against
  13, 20 and 14: 145/165/168 tokens against 167/235/229 (compiled, `P2.lean`). About a third of
  each control is valuation and side-condition discharge that no clause-directed evaluator
  removes. What is left for the evaluator to save is the clause-lemma names and the instance
  annotations, roughly 30 of 150 tokens per client.
- **The #9 layer is not an evaluator.** It is a step-by-step natural-deduction mode over abstract
  `(M, τ, t)`; it has no negated goal, no atom or valuation obligation, no L⋆, and no test at a
  named model. Its goal reader and clause-application kernel are reusable; its 32 `@[tactic]`
  handlers on `l*` syntax are not.
- **Recommended**: keep the record's goal form; ask that the trial compare a pattern interface
  against labelled entries on `refute_stab_allFuture_past`; define the lemmas-only control to
  include directional lemmas; say that the evaluator's own rule registry, not
  `FormulaSyntax.lean`, recognizes operators, so the L⋆ clients do not wait on D1.

## Context & Scope

Research only. Nothing under `FormalSystem/`, `records/` or `specs/reviews/` was edited, and
nothing was posted. The soundness adapter (D4) and the adoption threshold's existence are decided
and out of scope; the threshold's *comparator* is discussed because finding (2) bears on what the
"lemmas-only control" denotes.

Evidence tier. The lean-lsp server held a stale import state after PR #11's merge
(`lean_run_code` returned "Imports are out of date"), so the probes were compiled with
`lake env lean` through `lake-build-guard.sh` after a guarded build of the four modules involved
(exit 0, 1473 jobs). Every compiled claim below names its probe. Prior art in finding (5) is from
general knowledge and was not re-checked against sources.

## Findings

### Codebase Patterns

#### (1) The goal shape

**What the three heads are.** `PlusTruthAt M τ t φ` and `StarTruthAt M τ t v φ` are structural
recursions on the formula (`PlusTruth.lean:83`, `StarTruth.lean:110`). `TruthEnv.T M τ t e φ` is
a class projection whose instance for each language is the per-language predicate
(`PlusTruth.lean:101`, `StarTruth.lean:138`). `At M p A` is an `abbrev` for
`TruthEnv.T M p.history p.time p.env A` (`PointTransport.lean:45`), with `@[simp] at_def` beside
it. All three are definitionally equal on a given point.

**Measured: which steps work on which head** (`P1.lean`, goal
`G⊡p` at `(natModel, natHist (fun _ => 0), 0)`, the formula written as the client writes it,
`PlusFormula.allFuture (.stab (.atom p))`):

| Head | `rw [PlusTruth.allFuture_iff]` | `rw [TruthClauses.allFuture_iff]` | `apply (TruthClauses.allFuture_iff ..).mpr` | Residual goal |
|---|---|---|---|---|
| `PlusTruthAt` | works | not tried | works | head flips to `TruthEnv.T` |
| `TruthEnv.T` | fails | **fails** | works; `apply (PlusTruth.allFuture_iff ..).mpr` also works | `TruthEnv.T natModel τ y PUnit.unit (atom p).stab`, clean |
| `At` with a literal point | fails | fails | works | `TruthEnv.T natModel {history := τ, time := 0, env := ()}.history y {..}.env (atom p).stab`, projections of the literal left unreduced |

`simp only [at_def, TruthEnv.T, PlusTruth.allFuture_iff]` works on the `At` goal and lands in
`PlusTruthAt` form, confirming the idiom recorded for PR #11.

Two things follow.

1. *The generic clause lemma does not rewrite the record's own goal form.* The failure on the
   `TruthEnv.T` row is on the formula, not the head: the pattern is
   `TruthClauses.allFuture ?φ` and the target is `PlusFormula.allFuture _`, which agree only
   after unfolding the instance. This is the doubled derived operators that D1 is to write once.
   Until D1, a rewriting evaluator over `TruthEnv.T` would need per-language lemma sets anyway.
2. *Application is indifferent to the head.* The unifier unfolds the instance and the abbreviation
   at default transparency, so `Iff.mpr` of a generic clause closes over all three heads and over
   L⋆ as well (`P2.lean`, client `r2`, generic lemmas at `StarFormula`).

**So the choice of shape does not constrain how the evaluator recurses; it constrains two smaller
things.** (a) *Reading the judgment*: the evaluator has to read `M, τ, t, e, A` off the goal
syntactically before it picks a clause. `TruthEnv.T` gives all five as arguments; a per-language
head gives four and a known instance; `At` gives a point that must be projected. (b) *Presenting
residual goals*: after a generic clause the head is `TruthEnv.T` whatever it was before, so an
evaluator that wants to hand back `PlusTruthAt` goals has to re-present them. The #9 branch does
exactly this (`SemanticMeta.lean`: a `direct : Bool` field on the judgment, and
`SemanticCore.lean` `present`, which rewrites `TruthEnv.T` subterms back to the source head
under a checked `isDefEq`).

**`At` as recursion shape: rejected, with the reason.** A clause changes one coordinate of the
point: the time for `G`, `F`, `U`, `S` and recall, the history for `□` and `⊡`, the
environment for store. An `At`-level statement of a clause therefore has to rebuild the point,
`At M ⟨q.history, s, q.env⟩ φ`. `P3.lean` states `allFuture_at` and `stab_at` this way and
rewrites with them through `⊡G⊡p`: after three layers the goal's point is a `Point` literal
whose `time` and `env` fields are projections of a literal whose fields are projections of a
literal (the printed goal is eighteen lines for one atom). `At` is the right vocabulary for what
`PointTransport.lean` uses it for, relations between two whole points; it is not the shape to
recurse on. Of the two fixes offered to PR #11, `at_def` exposes `TruthEnv.T`, the shape the
evaluator recurses on, in one step; `At`-level clause lemmas would have produced the nesting
above and doubled the clause API a third time. The fix that merged is the one to prefer.

**The four clients under each shape.** All four state a non-validity, and the truth judgments
arrive from the validity definitions in per-language form: `PlusValid.apply` returns
`PlusTruthAt M τ t φ` (`PlusValidity.lean:156`), and `F.StarValidOn` unfolds to
`StarTruthAt`.

| Client | Truth half | Falsity half | Under `TruthEnv.T` | Under `At` |
|---|---|---|---|---|
| `refute_allFuture_stab` | `PlusTruthAt natModel τ₀ 0 (G⊡p)` | `¬ PlusTruthAt natModel τ₀ 0 (⊡Gp)` | same indices, `e = PUnit.unit` shown | point literal `⟨τ₀, 0, ()⟩`, projections after each clause |
| `refute_stab_allFuture_past` | `… (⊡GPp)` | `¬ … (G⊡Pp)` | as above | three layers of nesting, as in `P3.lean` |
| `refute_modal_future` | `StarTruthAt natModel τ₀ 0 v₀ (□(↓¹p → p))` | `¬ … (□G(↓¹p → p))` | `e = v₀` is the register vector and is read by the recall clause | the recall clause sets `time := q.env 1`, a projection applied to an argument |
| `refute_sentDet` | none: two valuation goals left by `not_starValidOn_sentDet` | none | not a truth goal at any head | not a truth goal |

Three facts about this table matter for the record. The evaluator needs the *negated* judgment as
a first-class goal, which the record states. The clients never present a `TruthEnv.T` goal on
their own, so the evaluator must accept the per-language heads or the measured script pays a
`show` per client. And `refute_sentDet` gives the evaluator nothing to recurse on; it measures
only the valuation normalizer.

**Store and recall are outside the clause classes.** `TruthClauses.lean` has a class for atom,
`⊥`, `→`, `□`, `U`, `S`, `⊡`, `G`, `H` and none for `↑ⁱ` or `↓ⁱ`;
`StarTruth.lean` says so itself ("nothing about them is instantiated here"). Their clauses exist
only as `StarTruth.timeStore_iff` and `timeRecall_iff`, stated on `StarTruthAt`. The record's
"Store and recall use the selected language's environment operations" is satisfiable only through
the registry it also proposes ("Register each rule with a theorem and an operator shape"): a rule
keyed on `StarFormula.timeRecall` whose theorem is stated per-language and applied up to
definitional equality. `P2.lean` does this by hand (`recall_true`), and it compiles. One hazard
showed up there: applying `(StarTruth.timeRecall_iff _ _ _ _ 1 _).mpr` with the indices left to
unification failed, because the clause's new time is `v 1` and the unifier will not solve
`?v 1 =?= 0`. The evaluator must pass the point it has read explicitly rather than leave indices
as metavariables. The #9 kernel already does (`clauseIff` passes model, history, time and
environment).

#### (2) The witness interface

**What the evidence is, clause by clause.** "Introduce" means the clause is universal in the
direction being proved and the evaluator binds a name; "supply" means the caller gives a term.

`refute_allFuture_stab`, at `τ₀ = natHist (fun _ => 0)`, time `0`:

| Half | Layer | Clause | Evidence |
|---|---|---|---|
| truth of `G⊡p` | 1 | `G`, universal | introduce `y`, `hy : 0 < y` |
| | 2 | `⊡`, universal | introduce `ρ`, `hs : τ₀.state y = ρ.state y` |
| | 3 | atom | valuation `ρ.state y = 0`, closed by `hs.symm` (uses the layer-2 name) |
| falsity of `⊡Gp` | 1 | `⊡`, refuted | supply `σ₁ = natHist (fun s => if s = 1 then 1 else 0)` and a proof of `τ₀.state 0 = σ₁.state 0` |
| | 2 | `G`, refuted | supply time `1` and `0 < 1` |
| | 3 | atom, refuted | valuation `¬ (if 1 = 1 then 1 else 0) = 0`, by `simp` |

`refute_modal_future`, at `τ₀`, time `0`, registers `v₀ = fun _ => 0`:

| Half | Layer | Clause | Evidence |
|---|---|---|---|
| truth of `□(↓¹p → p)` | 1 | `□`, universal | introduce `σ` |
| | 2 | `→` | introduce `hrec : ↓¹p` at `(σ, 0, v₀)` |
| | 3 | atom | `hrec` itself, because recall at `v₀ 1 = 0` is the same point |
| falsity of `□G(↓¹p → p)` | 1 | `□`, refuted | supply `σ₁ = natHist (fun s => if s ≤ 0 then 0 else 1)` |
| | 2 | `G`, refuted | supply time `1` and `0 < 1` |
| | 3 | `→`, refuted | two branches: truth of `↓¹p`, falsity of `p` |
| | 4a | recall then atom | valuation `(if 0 ≤ 0 then 0 else 1) = 0`, by `simp` |
| | 4b | atom, refuted | valuation `¬ (if 1 ≤ 0 then 0 else 1) = 0`, by `simp` |

`refute_stab_allFuture_past`, at `τ₀`, time `0` (three clause layers each way):

| Half | Layer | Clause | Evidence |
|---|---|---|---|
| truth of `⊡GPp` | 1 | `⊡`, universal | introduce `σ`, `hs : τ₀.state 0 = σ.state 0` |
| | 2 | `G`, universal | introduce `y`, `hy : 0 < y` |
| | 3 | `P`, existential | supply time `0` and `hy` (the layer-2 name) |
| | 4 | atom | `hs.symm` (the layer-1 name) |
| falsity of `G⊡Pp` | 1 | `G`, refuted | supply time `1` and `0 < 1` |
| | 2 | `⊡`, refuted | supply `σ₂ = natHist (fun s => if s = 1 then 0 else 1)` and `τ₀.state 1 = σ₂.state 1` |
| | 3 | `P`, refuted | introduce `s`, `hs1 : s < 1` |
| | 4 | atom, refuted | valuation `¬ (if s = 1 then 0 else 1) = 0`, needing `s ≠ 1` from `hs1` |

**The observation that decides the question.** In every client, evidence at a later layer is a
term over names bound at an earlier one: `hs` at layer 2 closes layer 3 in the first; `hy` and
`hs` close layers 3 and 4 in the third; `hs1` is needed inside the last valuation of the third.
A witness list of closed terms cannot express this. Both candidate interfaces therefore bind
names, and they differ only in how an entry is matched to its clause.

**How each would read.** The syntax below is illustrative; nothing here is implemented.

Clause-directed pattern, entries in clause order, one entry per quantifier clause:

```lean
-- refute_stab_allFuture_past, truth half
seval [σ hs, y hy, ⟨0, hy⟩] with exact hs.symm
-- falsity half
seval refute [⟨1, one_pos⟩, ⟨σ₂, by show _; simp⟩, s hs1] with valuation_goal
```

Labelled entries, each naming the clause it feeds:

```lean
seval
  | stab σ hs
  | allFuture y hy
  | somePast := 0, hy
  | atom => exact hs.symm
```

The compiled directional-lemma control, which is ordinary Lean and already has both features:
positional application is the pattern form, and `(σ := σ₂)` named arguments are the labelled
form (`P2.lean`, `r3`):

```lean
fun h =>
  allFuture_false (L := PlusFormula) (e := PUnit.unit) (1 : ℤ) (one_pos : (0 : ℤ) < 1)
    (stab_false (natHist fun s => if s = 1 then 0 else 1)
      (by show (0 : ℕ) = (if (1 : ℤ) = 1 then 0 else 1); simp)
      (somePast_false fun s hs1 => atom_false (by
        show ¬ (if (s : ℤ) = 1 then (0 : ℕ) else 1) = 0
        rw [if_neg (ne_of_lt hs1)]; exact one_ne_zero)))
    (h.apply NF natModel (natHist fun _ => 0) 0
      (stab_true (L := PlusFormula) (e := PUnit.unit) fun _ hs =>
        allFuture_true fun _ hy => somePast_true 0 hy (atom_true hs.symm)))
```

**Which is legible at three layers.** The pattern form stays one line per half at three layers,
but the reader has to hold the formula in mind to know that the third entry is the `P` witness;
at the `→` branch of `refute_modal_future` it also needs a convention for branch order. The
labelled form is self-describing and survives a change to the formula with a located error, at
roughly one line per clause, which at three layers is the length of the reference proof's own
`have hA` block (seven lines). The term-mode control sits between them: the clause is named by its
lemma, the nesting mirrors the formula, and no new syntax is learned.

**What the trial should be judged on.** Four things, in this order.

1. *Tokens against the right control.* Measured here:

   | Client | Reference | Directional-lemma control | Of which valuation and side conditions |
   |---|---|---|---|
   | `refute_allFuture_stab` | 13 lines, 167 tokens | 8 lines, 145 tokens | 53 |
   | `refute_stab_allFuture_past` | 20 lines, 235 tokens | 9 lines, 165 tokens | 62 |
   | `refute_modal_future` | 14 lines, 229 tokens | 9 lines, 168 tokens | 53 |

   The twelve helper lemmas cost 44 lines, 843 tokens, counted once as the record requires; they
   are not repaid by three clients (153 tokens saved) and would be by a countermodel library.
   Tokens are counted as identifiers, numerals and single symbols over the proof body.
2. *Whether the valuation obligations are reduced.* They are a third of each control and are the
   part the reference proofs spend most lines on (`change … ; simp`). An evaluator that leaves
   them as raw goals has addressed two thirds of the script at most; one with a normalizer for
   `natModel` and `natHist` addresses the rest. The record's "normalizer arguments" should be
   measured separately from clause recursion.
3. *Dependent evidence.* Each interface must express `⟨0, hy⟩` and the `hs1`-dependent valuation
   without leaving the mode.
4. *Error location.* A wrong witness at layer 2 of 3 should be reported against that entry.

#### (3) Evaluator beside the lemmas, or one module with the mode

**What `records/milestones.md` assumes.** Goal C states it as prose, not as an open decision:
"The evaluator sits under that directory beside the semantic lemmas, with the semantic mode, C4,
a thin tactic layer over it, rather than the two as one module." Its Open decisions list has two
items, neither about this. The dependency columns agree: C3 depends on C1 and C2; C4 depends on
C3, A4 and D4; B4 depends on C3 "for the evaluator-checked entries", not on C4.
`records/proof-mode-architecture.md` places "the tactics" in a directory of their own under
`FormalSystem/Semantics/`, for example `Semantics/ProofMode/`.

**What (1) and (2) add.** The work divides into three parts, not two.

| Part | Content | Imports | Depends on |
|---|---|---|---|
| Directional clause lemmas | truth-introduction and refutation forms per clause, generic over the clause classes | `TruthClauses.lean` only; no `Lean.Meta` | nothing |
| Evaluator | a `MetaM` function: read the judgment, look up the rule for the formula's head, apply it at the read point, return the residual goals; the rule registry | `Lean.Meta`, the lemmas | the lemmas |
| Mode | `seval` syntax, the witness interface, the soundness-adapter tactic | `Lean.Elab.Tactic`, the evaluator, D4 | A4, D4 |

For keeping the evaluator apart from the mode: B4 uses the evaluator and must not import
`Metalogic/`; the evaluator can land and be measured (C3) before D4 exists; the witness-interface
trial replaces the mode's front end twice while the evaluator stays fixed; and no file under
`FormalSystem/Semantics/` imports `Lean` meta-programming today, so the meta code wants a
directory boundary regardless. For one module: with a single tactic the split is one file's
worth, and a registry attribute and the syntax that fills it are often written together.

The stronger finding is the first row. Most of the measured saving comes from lemmas that belong
with C1's lemmas and need no evaluator. The record should name them as the first deliverable of
step 1, since they are both the lemmas-only control and the evaluator's rule set.

#### (4) What the #9 branch already tried

Read at `b3d8f6463`: `SemanticMeta.lean` (262 lines), `SemanticCore.lean` (1181),
`SemanticRewriting.lean`, `SemanticSimplification.lean`, `SemanticTransport.lean`,
`ProofModeExtensionsTest.lean`.

**Goal shape.** A `TruthJudgment` record read off the goal: language, frame, model, history,
time, environment, the `TruthEnv` instance, formula, and `direct`. `readTruthHead?` accepts
`TruthAt`, `PlusTruthAt` (five arguments, `direct := true`) and `TruthEnv.T` (eight); an `At`
goal reaches it by unfolding outer abbreviations. Clauses are applied generically
(`semanticApp` forces the language and instance, `clauseIff` passes the read point), the
assignment is checked by `isDefEq`, and results are re-presented in the source head. This is
the design finding (1) arrives at, already written.

**Witness handling.** One command per clause, each naming what it binds or supplies:
`lmodal_witness σ`, `ltemporal_witness s`, `luntil witness s`,
`ltemporal_cases h as s hs a`, `lmodal_intro settled using [hp, hq] as ρ hState p q`.
`introWitness` elaborates the witness against the existential's domain and returns the conjuncts
as goals in clause order. It is a labelled interface with one line per clause, and no command
takes more than one clause's evidence.

**What worked.** Index discipline (`sameIndex`, `samePoint`, `indexedDefEq` compare model,
history, time and environment before the formula, so a fact at another point is refused);
transactional failure; presentation in the source head; Until and Since witnesses with order,
event and guard in clause order.

**What it is not.** Every semantic example in the test file is over variables `M τ σ t`; none is
at `natModel` or any named model. There is no handling of a negated truth goal and no atom
clause (`grep -i "atom\|valuation"` over `SemanticCore.lean` finds only unrelated uses).
`Language` is `tm | plus`, and `readTruthHead?` returns `none` for any other carrier, so
neither L⋆ client could be stated to it. `clauseIff` is a closed `match` on sixteen operator
names, not a registry. It is a natural-deduction mode at the semantic tier, and none of the four
clients of PR #10 was or could have been run through it.

**Reusable under a separate prefix and registry.** `TruthJudgment`, `readTruthHead?`,
`truthJudgment?`, `truthType`, `semanticApp`, `clauseIff` (as the body of a registry lookup),
`openClause`, `introClause`, `elimClause`, `present`, `introWitness`, `splitGoals`,
`destruct`, `assignChecked`, `transactional`, and the index checks. These are `MetaM` or
`TacticM` functions with no reference to `l*` syntax. They need: `Language` widened or replaced
by the registry key (the import of `Automation.ProofMode.Positions` is only for `Language` and
`operatorArgs?`, both now in `FormalSystem/Tactic/FormulaSyntax.lean`); the `Point`
references retargeted from `ProofModeRules` to `PointTransport`; an atom rule; and the negated
forms.

**Dependent on overloading.** `semanticMain` and `runSemantic` (throw `unsupportedSyntax` so
the derivation handler runs), the thirty-two `@[no_fallback, tactic …]` elaborators attached to
`lexact`, `lapply`, `lintro`, `lmodal_intro`, `ltemporal_intro`, `luntil`, `lsince` and the
rest, the raw-syntax readers (`afterKeyword?`, `termsAfter?`, `namesAfterAs`) that parse
`using`/`keeping`/`as` out of derivation-mode syntax trees, and the imports of
`ProofMode.Temporal` and `ProofMode.Discrete`.

### External Resources

#### (5) Prior art, where it changes a recommendation

- **`norm_num` extensions, `positivity`, `gcongr` in Mathlib.** Each is a `MetaM` evaluator
  keyed on the head symbol of the term, extended by an attribute, with the tactic a thin front end
  in a separate file; `norm_num` returns a proof that the proposition is true or that it is
  false, and `gcongr` separates main goals from side goals handed to a discharger. This is the
  three-part division of finding (3) and the "valuation obligations to a normalizer" split of
  finding (2). It supports the evaluator-beside-the-lemmas ruling and a registry keyed on the
  formula's head constant.
- **`rintro`/`obtain` patterns and `refine ⟨w, ?_⟩` in Lean; introduction and specialization
  patterns in the Iris proof mode.** The established answer to "a list of evidence in clause
  order where later items mention earlier names" is a pattern language with binders, not a list
  of terms. This is why finding (2) recasts the first interface as a pattern.
- **Evaluation games.** Truth at a model is a winning strategy for the verifier and falsity one
  for the falsifier; the supplied witnesses are that player's moves and the introduced names are
  the opponent's. A strategy is a function of the opponent's earlier moves, which is the
  dependency observed in all three clients, and the two players' rules are the truth and
  refutation lemma families.
- **Certifying model checkers.** A checker emits a witness or counterexample that a small
  independent checker validates. This is the tableau-proposes, evaluator-certifies pipeline in
  the draft's item 3, and it supports keeping that sentence.

No prior art examined argues for `At`-shaped recursion or for a purely positional list.

### Recommendations

- Keep `TruthEnv.T M τ t e A` and its negation as the record's goal form, and add that the
  evaluator also accepts the per-language heads and applies clauses rather than rewriting with
  them. [VERIFIED: PASS -- `P1.lean` compiled through the build guard: `apply` of the generic and
  per-language clause succeeds on all three heads; `rw` fails on `TruthEnv.T` and `At`]
- Do not ask PR #11's author for `At`-level clause lemmas; `at_def`, as merged, is the fix to
  keep. [VERIFIED: PASS -- `P3.lean`: hand-stated `allFuture_at`/`stab_at` rewrite, and leave a
  triply nested `Point` literal after three layers]
- Define the lemmas-only control to include directional clause lemmas (truth and refutation
  forms), and have the record name them as step 1's first deliverable.
  [VERIFIED: PASS -- `P2.lean`: twelve such lemmas and term-mode re-proofs of three clients
  compile; 145/165/168 tokens against 167/235/229]
- Recast the witness trial as pattern against labelled entries, both binding names, judged on
  `refute_stab_allFuture_past` first. [No compiled gate applicable]
- State that operator recognition for the evaluator is its own rule registry keyed on the
  formula's head constant, so the L⋆ clients do not wait on D1. [VERIFIED: PASS -- `P2.lean`
  `r2`: generic clause lemmas and a per-language recall rule apply at `StarFormula` today]
- Keep the evaluator beside the lemmas and apart from the mode. [No compiled gate applicable]
- Carry the #9 goal reader and clause kernel forward by name in the fresh pull request the mode
  returns as. [No compiled gate applicable]

## Decisions

- Read PR #10 at its live head `ada7074dd` and PR #11 as merged, rather than the heads the task
  names.
- Treated the `At` question as a judgment on the merged fix.
- Counted tokens with one fixed tokenizer over proof bodies only; statements are identical across
  versions.
- Wrote no prototype evaluator: the directional-lemma control is the strongest thing ordinary Lean
  can do and bounds what an evaluator can add.

## Risks & Mitigations

- **The token figures are from one author's control scripts.** A tighter reference or a tighter
  control would move them. Mitigation: the probes are saved and re-runnable; the claim relied on
  is the ordering and the one-third share, not the exact counts.
- **The adoption threshold may be unreachable against a directional control.** The evaluator has
  about 30 tokens per client to win. Mitigation: the threshold is already stated as revisable;
  the reply can say what the control is so that the first measurement is not disputed afterward.
- **Head flipping.** A generic clause leaves a `TruthEnv.T` residual on a `PlusTruthAt` goal, and
  the existing `PlusTruth.*` lemmas then fail to rewrite it. Mitigation: re-present in the source
  head, as the #9 kernel does.
- **`records/milestones.md` "Where it stands" still lists the semantic lemmas as open.** Out of
  scope here; noted for whoever next reconciles the record.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `TruthEnv.T … (PlusFormula.allFuture _)` | `rw` | fail | `PlusTruth.allFuture_iff`; `TruthClauses.allFuture_iff` |
| same | `apply (_).mpr` | success | either lemma |
| `At … (PlusFormula.allFuture _)` | `rw` | fail | `TruthClauses.allFuture_iff` |
| same | `simp only` | success | `[at_def, TruthEnv.T, PlusTruth.allFuture_iff]` |
| same | `simp only` | `at_def` fires, clause unused | `[at_def, TruthClauses.allFuture_iff]` |
| `PlusTruthAt … (allFuture _)` | `apply (_).mpr` | success, head becomes `TruthEnv.T` | `TruthClauses.allFuture_iff (L := PlusFormula)` |
| valuation goals of the clients | `show …; simp` | success | needs the `show` to expose the `if` |

## Context Extension Recommendations

- **Topic**: head-insensitive application against head-sensitive rewriting for class-projected
  predicates.
- **Gap**: no context file records that `rw` with a generic clause lemma fails on a formula
  written with a language's own derived operator, while `apply` succeeds.
- **Recommendation**: add a short pattern note under `.claude/context/project/lean4/patterns/`
  (in the source store), citing `P1.lean`'s table.

## Appendix

- Probes: `specs/985_research_semantic_proof_mode_for_pr10_reply/probes/P1.lean` (heads against
  `rw`/`apply`/`simp only`), `P2.lean` (directional lemmas and three clients), `P3.lean`
  (`At`-level clauses). Run with
  `bash .claude/scripts/lake-build-guard.sh build --timeout 280 -- env lean <file>`. `P1` and
  `P3` contain deliberately failing steps; `P2` compiles with no output.
- Commands: `gh pr view 10|11|9 --json headRefOid,state`; `git fetch origin pull/10/head pull/9/head`;
  `git show pr/10:records/semantic-proof-mode.md`; `git show pr/9:FormalSystem/Automation/ProofMode/Semantic{Meta,Core}.lean`.
- No Mathlib search was needed; no search tool was called.

## Implications for the replies

### For #10 (`pr10-comment.md`)

**Ask for**

- Item 1.2, reworded: both interfaces bind names, because later evidence uses earlier names in all
  three clients. Try a clause-ordered pattern against labelled entries, on
  `refute_stab_allFuture_past` first, and judge on tokens, dependent evidence and error location.
- A sentence in "Judgments and evidence": the evaluator accepts `PlusTruthAt` and `StarTruthAt`
  goals as well as `TruthEnv.T`, applies clauses rather than rewriting, and hands goals back in
  the head it was given.
- Step 1 of "Measurement" to name directional clause lemmas (truth and refutation forms, generic
  over the clause classes) as its deliverable, and the lemmas-only control to use them.
- A sentence that valuation obligations are measured apart from clause recursion; they are about
  a third of each proof.
- Item 3's gap sentence, extended: store and recall have no clause class, so their rules are
  per-language entries in the registry.

**State as decided**

- Goal form `TruthEnv.T M τ t e A` or its negation: agreed, as the record has it.
- Evaluator beside the lemmas, mode a thin layer: this is what `milestones.md` Goal C says. The
  draft's "Yours to rule; I lean to the former" can become "as Goal C has it; say so in the
  record".
- Items 1.4 and 1.5 and the threshold, unchanged.

**Drop**

- "Research the goal shape and the witness interface, to settle 1.2" from the groundwork list;
  it is done.
- Nothing from item 3. The record at `ada7074dd` already says the evaluator checks supplied
  evidence and does not search, but it still does not state the relation to the tableau or name
  the Until, Since and store gap, which is what item 3 asks for.

**Wrong or unsupported in the current draft**

- Item 1.3, "`FormulaSyntax.lean` stops at TM⁺, so L⋆ operators are recognized once the
  signature layer (D1) lands." The premise is right and the conclusion is not: two of the four
  clients are L⋆, and the evaluator recognizes operators through its own rule registry, which
  works at `StarFormula` today. D1 later merges the per-language keys; it is not a precondition.
- Item 2's data point, "the lemmas-only control on `refute_allFuture_stab` with #11's lemmas is
  13 lines, the same as the existing proof." True of #11's lemmas, which are persistence and bind
  rules. With directional clause lemmas the control is 8 lines, 145 tokens against 167, and the
  other two clients fall by 27 to 30 percent. Give the unit as tokens, since the threshold is in
  tokens, and replace the data point with these.
- Item 4 is confirmed, not wrong: at `ada7074dd`, `git merge-tree` against `origin/main`
  reports one conflict, in `records/proof-mode-architecture.md`.

### For #11

Merged at `b2eb3ac0b` with `at_def`; nothing to ask. Had the choice still been open, `at_def`
is the one to prefer: it exposes `TruthEnv.T`, the shape clauses are stated in and an evaluator
recurses on, whereas `At`-level clause lemmas must rebuild the point at every clause and leave
nested `Point` literals. One correction to the posted diagnosis, for the record only:
`rw [TruthClauses.allFuture_iff]` fails on such a goal even without `At`, because the formula's
`PlusFormula.allFuture` is not syntactically the generic `TruthClauses.allFuture`; that half of
the failure is D1's to fix, not `At`'s.
