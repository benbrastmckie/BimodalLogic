# Research Report: Task #976

**Task**: 976 - Decide open questions from PR reviews and records
**Started**: 2026-11-20T19:45:35Z
**Completed**: 2026-11-20T19:57:00Z
**Effort**: one research dispatch; record and review edits estimated at 2-3 hours
**Dependencies**: None. Coordinates with task 970 (`investigate_stability_as_modal_family`) on question (f).
**Sources/Inputs**: - `specs/reviews/pr-reviews-2026-11-20/pr{7,8,9}-review.md`; `records/proof-mode.md`, `records/proof-mode-architecture.md`, `records/theorem-library.md`, `records/README.md`; `ORGANISATION.md`; `CONTRIBUTING.md`; `scripts/measure-refactor-partitions.py`; `lakefile.toml`; `.github/workflows/ci.yml`; the PR heads as local refs `pr/7-head` (fc85c61b9), `pr/8-head` (1f545ea0a), `pr/9-head` (b3d8f6463); `main` at 514b652c4; a compiled Lean prototype
**Artifacts**: - `specs/976_decide_open_questions_from_pr_reviews_and_records/reports/01_open-questions-decisions.md` (this report); `specs/976_decide_open_questions_from_pr_reviews_and_records/evidence/S5Proto.lean`; `specs/976_decide_open_questions_from_pr_reviews_and_records/evidence/closure.py`
**Standards**: report-format.md, subagent-return.md

## Needs user ruling

Two items. Neither blocks the record and review edits; each has a recommendation the edits can
proceed on.

1. **(i) What "default" means for adoption (M12).** A policy on how contributors must work,
   which the tree cannot settle. Options and evidence are under question (i).
   Recommendation: option B+A (library registration requires a script or a failure class;
   new `Examples/` and case-study modules are written in the mode; `Theorems/` is exempt by
   layering), stated as contingent on a GO at gate one.
2. **(c, naming residue) Whether PR #8's `luntil unfold` / `luntil fold` keep those keywords**
   once the views pair is named `lunfold` / `lfold`. Taste, not evidence. Recommendation:
   rename the derivation-tier keywords (`expand` / `contract`) so the words fold and unfold
   belong to the views tier alone.

One item is deferred, not open for ruling now: **(f) the place of `⊡`** stays with
`investigate_stability_as_modal_family`. A ruling is needed only if that report recommends a
separate family.

Everything else, (a) (b) (c) (d) (e) (g) (h) (j) (k) (l), is decided below.

## Executive Summary

- **A factual error runs through the records and the PR #9 review**: `FormalSystem/Semantics/`
  is layer 1, not layer 2 (`ORGANISATION.md` table; `LAYERS` in
  `scripts/measure-refactor-partitions.py:144-151`). `pr9-review.md` line 141 "corrects" the
  contributor's accurate "Layer 1". This changes what question (a) requires.
- **(a)** The semantic mode goes under `FormalSystem/Semantics/` in a directory of its own, at
  layer 1, with one adapter module at layer 3. The import closure supports this only on one
  condition, which becomes part of the decision: the views tier and the position planner sit
  at layer 0 or 1, not under `FormalSystem/Automation/`.
- **(b)** Record and named client before the mode is built: yes. The countermodel half is a
  candidate client, not an established one; nothing has been measured.
- **(c)** One pair, `lunfold` / `lfold`, taking a view name from one table.
- **(d)** `lrewrite` / `lsimp` are out of the gate-one scripts. Of PR #8's rules, only `G`/`H`
  carrying and whole-judgment time reflection may enter, and only by adoption into M1.
- **(e)** A structure with the operator as a field. Prototype compiled against `main`; the
  class variant fails on an operator presented through a definition.
- **(g)** The linearity case-split record is a sequencing-only predecessor of the induction
  rule. A statement of the generalizing rule is given.
- **(h)** Present-inclusive leads-to is the named definition; PR #8's strict rules are the layer
  beneath it.
- **(j)** `MinusDeduction.lean` moves to `FormalSystem/Theorems/`. **(k)** `BimodalLib` is not
  a default target; CI builds it explicitly.
- **(l)** PR #7 carries its own surface separation; the full views tier stays under
  `proof_mode_views_tier`. The records currently contain an ordering cycle (M17 after M16 after
  M0 after PR #7); the order becomes M17, M0, M16.

## Context & Scope

The task asks for a decision, with reason and rejected alternative, on twelve questions raised
by the reviews of PRs #7, #8, #9 and by the open-decision lists of three records. This dispatch
is the research phase: it produces the decisions and the list of edits. It edits no record and
no review file, and posts nothing to GitHub.

Reference grounding is Tier 3 (implementation-backed): the tree and the PR branches are the
specification. No literature source is involved; the one mathematical statement proposed (the
induction rule under (g)) is argued from first principles and marked as such.

Settled design restated (not reopened here): three tiers (views, derivation, semantic); rules
filed by operator family; the theorem library as the measure; gate one measures the M1 and M2
rule set. Evidence tier for Lean facts: compiled probe (`lake env lean`) plus `grep`; the
lean-lsp index was not consulted, so no absence claim rests on it.

## Findings

### Source-to-evidence map

| Question | Authority read | Local evidence |
|---|---|---|
| (a) | `ORGANISATION.md` layer table; `LAYERS` dict | import closure of 12 PR #9 modules, `evidence/closure.py` |
| (b) | architecture record "Aim and measure"; theorem-library "Countermodels" | `PlusNonValidities.lean`, `StarNonValidities.lean`; PR #9 test and guide grep |
| (c) | M16 done-when | defined-operator counts; `formula_unfold` / `formula_fold` in `Tactic/Attr.lean` |
| (d) | M3 block; "Gates" section | token counts in `FormalSystem/Theorems/Perpetuity/` |
| (e) | architecture "Operator families"; PR #7 `Congruence.lean` | `evidence/S5Proto.lean`, compiled |
| (g) | M4 block; `Discrete.lean:147`; `DiscreteUnfolding.lean:177-181` | `Theorems → Automation` import count |
| (h) | M10 done-when; PR #8 `TemporalComposition.lean:214-277` | rule statements read |
| (j) | `ORGANISATION.md` per-file rule | imports of the Minus chain; two existing deduction theorems |
| (k) | `lakefile.toml` header; `ci.yml:85-112` | read |
| (l) | M0, M16, M17 blocks; `state.json` dependencies | PR #7 `Rewriting.lean:147,431-475` |

### Codebase Patterns

**Layers.** `LAYERS = {Syntax: 0, ProofSystem: 0, ForMathlib: 0, Init: 0, Tactic: 0, Version: 0,
Semantics: 1, Theorems: 2, Metalogic: 3, Automation: 3, Examples: 4, MainResults: 4}`. The
`ORGANISATION.md` table agrees. Three places say otherwise and are wrong:
`records/proof-mode-architecture.md` open decision 2 ("under `FormalSystem/Semantics/` it sits
at layer 2"), `pr9-review.md` line 97 (same phrase) and line 141 ("`Semantics/` is layer 2 in
`ORGANISATION.md`").

**Import closure of the PR #9 modules** (computed on `pr/9-head` over `FormalSystem.*` imports):

| Module | Closure by top directory | Highest layer reached |
|---|---|---|
| `Semantics.ProofModeRules` | Semantics 5, Syntax 2, Init, Tactic, ForMathlib | 1 |
| `Semantics.ProofModeTemporalRules` | Semantics 6, Syntax 2, ... | 1 |
| `Semantics.ProofModeIntervals` | Semantics 6, PlusLanguage 3, Syntax 3, ... | 1 |
| `Semantics.ProofModeTransport` | Semantics 21, PlusLanguage 6, ProofSystem 1, ... | 1 |
| `Metalogic.ProofModeSoundness` | Metalogic 8, Theorems 9, Semantics 24, ... | 3 |
| `Automation.ProofMode.Positions` | Automation 1 (`Meta`), Theorems 10, ... | 3 |
| `Automation.ProofMode.SemanticMeta` | Automation 2, Theorems 10, Semantics 7, ... | 3 |
| `Automation.ProofMode.SemanticCore` | Automation 8, Metalogic 9, Theorems 26, ... | 3 |
| `Automation.ProofMode.SemanticRewriting` | Automation 8, Theorems 25, ... | 3 |
| `Automation.ProofMode.SemanticSimplification` | Automation 9, Theorems 25, ... | 3 |
| `Automation.ProofMode.SemanticTransport` | Automation 7, Theorems 25, Semantics 22, ... | 3 |
| `Automation.ProofMode.Semantic` (aggregator) | Automation 14, Metalogic 9, Theorems 27, ... | 3 |

The four lemma modules are clean at layer 1. Every elaborator module is at layer 3, and reaches
it by three routes: `SemanticMeta → Positions → Meta → Theorems.ProofMode.{Basic, PlusRules}`;
direct imports of the derivation elaborators `Temporal`, `Discrete`, `Simplification`; and
`SemanticCore → Metalogic.ProofModeSoundness`. So the review's sentence "nothing in the mode but
the adapter needs layer 3" is true of the lemmas, and true of the tactics only after the
overloads are removed and the shared pieces are brought down.

**Tactic code outside `Automation/`.** `FormalSystem/Semantics/FrameClassValidity.lean:210`
declares `macro "sat_intro " h:ident : tactic`, a tactic at layer 1.
`Metalogic/Expressiveness/EFGameTactics.lean` and `Metalogic/Decidability/Propositional/Tactic.lean`
are tactic modules beside their subject. `FormalSystem/Tactic/Meta.lean` is "ordinary
metaprogramming placed at layer 0 because its consumers are spread across `Automation/` and
`Metalogic/`" (`ORGANISATION.md`); it imports `FormalSystem.ProofSystem`.

**Views already have a layer-0 seed.** `Tactic/Attr.lean` registers the simp sets
`formula_unfold` and `formula_fold`, described there as exact `rfl` inverses; the tagged lemmas
are in `Automation/Normalization.lean` (24 lines mention `formula_unfold`). PR #8 files its
TM-side inclusive definitions in `PlusLanguage/TemporalViews.lean`, importing only
`PlusLanguage.Formula`, and PR #9 gives it a layer-0 row (`"TemporalViews": 0`).

**Defined operators.** `Formula`: 26 (`top neg someFuture somePast allFuture allPast kPlus kMinus
and or diamond always co next prev weakFuture weakPast release after before weakUntil trigger
weakSince strongRelease strongTrigger sometimes`). `PlusFormula`: 22 (`top neg someFuture
somePast allFuture allPast kPlus kMinus and or iff diamond always sometimes next prev after dstab
Will will Could could`). Patterns: `^def |^abbrev ` over the two `Formula.lean` files, filtered
by hand to formula-valued definitions; cross-checked with `^def [a-zA-Z]+ .*: Formula :=`
(27 hits, one of them the atom helper `atomS`) and `^def [a-zA-Z]+ .*: PlusFormula :=` (22 hits).

**Tactic names.** `main` has 21 tactic heads under `Automation/ProofMode`. PR #7 adds `lrewrite`,
`lsimp`. PR #8 adds `linduction`, `ltemporal_dual`, `ltime_reflect`, and the forms
`luntil fold`, `luntil unfold`, `lsince fold`, `lsince unfold` (`Temporal.lean:800-822` on
`pr/8-head`). Neither `lunfold` nor `lfold` exists anywhere.

**Three axiom bases for "S5".** TM `Axiom` has `modal_t`, `modal_5_collapse`, `modal_k_dist`
(4 is the derived `DerivedAxioms.modal4`). TM⁺ `PlusAxiom` has `modal_t`, `modal_4`, `modal_b`,
`modal_5_collapse`, `modal_k_dist` for `□`, and `stab_k`, `stab_t`, `stab_4`, `stab_5` for `⊡`,
with 5 stated as `⟐φ → ⊡⟐φ`. No two of the three coincide.

**Perpetuity proofs.** In `FormalSystem/Theorems/Perpetuity/`: 0 occurrences of `untl`, `snce`,
`next`, `prev`, `linear`, `tempLinearity`; 12 of `DerivationTree.time_reflection`; 236 tokens
containing `always`.

**Induction and linearity.** `forwardInvariantRule` (`Theorems/ProofMode/Discrete.lean:147`) is
`⊢[ZTime] A → (A → X A) → G(A → X A) → G A`. Its docstring names UZ, Until enrichment and Since
unfolding. `unfoldForward`'s docstring (`DiscreteUnfolding.lean:177-181`) names
`Axiom.linear_until` as its engine. `FormalSystem/Theorems/` has 0 import lines into
`FormalSystem/Automation/`. `Theorems/LinearityDerived.lean` already has `tempLinearity`,
`tempLinearityPast` and their context forms.

**Deduction theorems.** TM: `Theorems/DeductionTheorem.lean`. TM⁺:
`Theorems/ProofMode/PlusRules.lean:122`. Minus: `Metalogic/Conservativity/MinusDeduction.lean`,
whose only import is `FormalSystem.MinusLanguage.Derivation`; `MinusTemporalDerived.lean`
imports only `MinusDeduction`. Importers of `MinusDeduction`: `FormalSystem.lean`,
`Metalogic/Conservativity.lean`, `MinusTemporalDerived.lean`.

**Build targets.** `defaultTargets = ["FormalSystem"]`, with the header stating that a plain
`lake build` "must compile the published library and nothing else". CI builds `BimodalTools` and
`BimodalToolsTest` in explicit `--wfail` steps. `BimodalLib/` does not exist yet.

**Ordering cycle in the records.** M17: "Sequencing-only dependencies: M16". M16:
"Sequencing-only dependencies: M0". M0: "It moves files that open contributions edit, so it runs
after they are merged or declined". M17 is PR #7. `state.json` has no M17 task, so the cycle is
in the record text only: 969 (`proof_mode_views_tier`) depends on 960 and nothing depends on a
rewriting task.

**PR #7's definitional path is already a separate function.** `Rewriting.lean:431-475` on
`pr/7-head` holds `formulaEqualityRewriteProof` and `equalityRewrite`; the dispatch is at line
147 ("lrewrite requires a formula equality or a native implication/equivalence").

**Hand-built refutations.** `PlusNonValidities.lean`: 5 theorems, 205 lines.
`StarNonValidities.lean`: 5 theorems, 197 lines. `refute_stab_box` is 9 tactic lines of ordinary
Lean (`intro`, `have`, `rw [atom_iff]`, `exact`). Across the library about 60 theorems have
refutation-shaped names [COVERAGE-UNVERIFIED: `grep -rhE '^theorem .*(refute_|not_valid|_invalid|independent)' FormalSystem` / a name pattern cannot find refutations named otherwise, and no statement-shape pattern was run].
PR #9's tests and guide cite none of them (`git grep 'refute_\|NonValidities' pr/9-head -- Tests/BimodalTest/Automation docs/user-guide`: no hit).

### External Resources

None used. No reference materials beyond the repository apply; the induction-rule statement is
first-principles work.

## Decisions

Each entry: decision, reason, rejected alternative on its merits, confidence.

### (a) Where the semantic mode lives

**Decision.** Three placements, by what the code is:

1. The semantic lemmas stay in `FormalSystem/Semantics/` as general semantics (layer 1).
2. The semantic tactics go in a directory of their own under `FormalSystem/Semantics/`
   (for example `FormalSystem/Semantics/ProofMode/`), at layer 1.
3. The adapter is one module at layer 3 under `FormalSystem/Metalogic/`, holding the soundness
   lemma and `luse_derivation`. It imports `Metalogic.Soundness`, `PlusSoundness` and the
   semantic mode, and nothing under `FormalSystem/Automation/ProofMode/`.

**Condition, part of the decision.** A layer-1 mode can import only layers 0 and 1. The two
things it shares with the derivation mode, the views tier and the position and polarity planner,
therefore sit at layer 0 or 1, not under `FormalSystem/Automation/ProofMode/`. Both are
formula-syntax only, and `ORGANISATION.md` already has the rule for them: shared
metaprogramming whose consumers are spread across directories goes to `FormalSystem/Tactic/`
at layer 0, as `Tactic/Meta.lean` does. The planner as written imports `ProofMode.Meta`, whose
closure holds 10 `Theorems` modules; it has to be cut loose from that import.

**Reason.** (i) The lemma closures are measured at layer 1. (ii) A layer-3 mode cannot be used
by any semantic proof at layer 1 or 2, which is where the semantic proofs are:
`Semantics/`, and the layer-1 files of the language directories, `PlusNonValidities.lean` among
them. That is the same wall the derivation mode has with `Theorems/`, and here it is avoidable.
(iii) A tactic at layer 1 is not new: `sat_intro` is one. (iv) It is the placement the review
already prefers.

**Rejected: `FormalSystem/Automation/`, beside the derivation mode.** Its merits are real: no
relocation of views or planner, all tactics in one place, matching `ORGANISATION.md`'s
description of `Automation/` as "tactics and proof search", and it is where PR #9 put every
elaborator. It loses because it makes the mode unusable below layer 3, leaving `BimodalLib`,
`Metalogic/` and `Examples/` as its only possible users.

**Consequences.** M16's files move out of the Elaborators lane directory; the layer number is
corrected in three places; `pr9-review.md` line 141 is withdrawn.

**Confidence.** High on the layer facts and closures. Medium on the placement itself: it rests
on the condition being met, and on clients at layer 1 that question (b) has yet to establish.

### (b) Record and client before the semantic mode is built

**Decision.** Yes to both. `records/semantic-proof-mode.md` is agreed before any tactic code is
reviewed. The lemma PR (review item 1) needs no record and goes first.

On the countermodel half: it is a **candidate** client. The record must turn it into a measured
one before the tactics are rebuilt: name the declarations (the five in `PlusNonValidities.lean`
and the five in `StarNonValidities.lean` are the obvious set), re-prove them twice, once with
the lemma PR alone and once with the tactics, and report both against the existing proofs. The
lemma-only run is the control: if the lemmas already give the saving, the tactic language has no
client there.

**Reason.** The architecture record's rule applies without exception: "A capability that
improves no library entry needs another named client before it is built." No milestone covers a
semantic mode. The existing refutations are short and written in ordinary Lean with truth-clause
rewrites, so a saving is not evident from reading them, and PR #9 re-proves none.

**Rejected: treat the countermodel library as an established client now.** Its merit: those
entries are truth proofs at a model, the same kind of measure the derivation mode has, and M20
will register them. It loses because M20 is not started (973, behind 971 and 972) and no
comparison exists.

**Confidence.** High that nothing is measured. Medium on the size of the candidate set (see the
coverage mark above).

### (c) Tactic names for the views tier

**Decision.** One pair, `lunfold` and `lfold`, each taking a view name. One table holds the
rows: name, folded shape, unfolded shape, and the equality that relates them (`rfl` for a
defined operator, a proved formula equality otherwise). A formula equality is used as a view by
registering it as a row; the pair takes no free proof term. The elaborators' operator matching
reads the same table, as M16's done-when already requires.

**Reason.** 26 defined operators in `Formula` and 22 in `PlusFormula`, plus the inclusive Until
and Since forms: one tactic per view is on the order of a hundred tactic names for a tier that
proves nothing. The table-driven shape already exists at layer 0 as `formula_unfold` /
`formula_fold`. A new language extension then adds rows and no syntax, which is principle 6.

**Rejected: one tactic per view.** Its merits: each name is discoverable by completion, a
misspelt operator is a parse error instead of a lookup failure, and no registry is needed. It
loses on count and on principle 6, since each extension would add tactic syntax.

**Naming residue (ruling item 2).** PR #8 uses `fold` and `unfold` as keywords of derivation
tactics (`luntil unfold` uses the ZTime axioms). The tactic heads differ, so principle 1 is met
to the letter, but one word then names a view and a logical step.

**Confidence.** High on the counts. Medium on the registry design; it is a proposal, not a
prototype.

### (d) Rewriting and PR #8's rules at gate one

**Decision.**

- `lrewrite` and `lsimp` are not used in gate-one scripts and do not enter its verdict.
- M17's client is its own: once the gate-one sweep exists, the same selection is run a second
  time with `lrewrite` and `lsimp` permitted and reported as a separate comparison. That is the
  "at least one library entry in a sweep is shorter" of M17's done-when, and the records already
  say a sweep is re-run by one command after a change to the rule set.
- Of PR #8's rules, gate-one scripts may use two, and only once each is adopted into M1's
  done-when before the selection is fixed: `G`/`H` carrying (`keeping`), as rows of M1's
  carrying table; and whole-judgment time reflection (`ltime_reflect`).
- Until and Since introduction, folding and unfolding, `nextKeep`, `linduction` and the leads-to
  rules are not used at gate one.

**Reason.** M3: "The gate measures exactly that rule set", and "Nothing in this document weakens
gate one". Admitting rewriting changes what a GO means. The two admitted rules are different in
kind: the architecture record already says `G`/`H` carrying shares one table with the M1 scope
records, and time reflection is a primitive rule of the calculus that the reference Perpetuity
proofs use 12 times and that no merged tactic exposes. The excluded rules are M4 and M10 work,
which hard-depend on a GO, and the gate-one fragments never mention their operators (0
occurrences of `untl`, `snce`, `next`, `prev` under `Theorems/Perpetuity/`).

**Rejected: admit rewriting to gate one.** Its merit: the gate would measure the mode a user
actually has, and a rewrite-heavy proof such as a perpetuity principle might be where the mode
wins most. It loses because the selection must exercise every rule the gate measures, the
tactics are unmerged and under requested changes, and the second run gives the same information
without moving the gate.

**Confidence.** High on the record text and counts. Medium on admitting `ltime_reflect`: M1
supplies both time directions natively, so the selection may not need it.

### (e) How the shared S5 statement is carried

**Decision.** A structure taking the operator as a field, over PR #7's `Kit`, instantiated once
per necessity operator per language. The modal congruence step is one definition taking that
structure. The fields are theorems, not axioms.

**Reason.** Prototyped in `evidence/S5Proto.lean`, compiled against `main` with exit 0:

- Structure variant: `Necessity kit` with `box`, `mp`, `nec`, `k`, `t`, `four`; instances
  `plusBoxN`, `plusStabN`, `tmBoxN`; `Necessity.step : Necessity kit → Step kit` gives the
  `□` step, the `⊡` step and the TM step from one definition.
- Class variant: `S5Nec kit box` with two instances on `PlusFormula` coexists, resolves at
  `PlusFormula.stab`, at `fun x => PlusFormula.stab x`, and infers the operator from a goal.
  It **fails** at `def myStab := PlusFormula.stab` ("failed to synthesize instance of type class
  `S5Nec (plusKit fc) myStab`", pinned by `#guard_msgs`), and its fields needed explicit
  `(kit := kit) (box := box)` arguments to elaborate.
- The structure handles the same definitional presentation with no resolution at all.

PR #7 already made this choice for `Kit` and `Step`, which are structures. And since TM `□`,
TM⁺ `□` and `⊡` have three different axiom bases, each instance supplies some fields by
derivation (TM's `four` is `DerivedAxioms.modal4`).

**Rejected: a class indexed by the operator.** Its merits: call sites need not name the
instance, and generic theorems read as ordinary typeclass-polymorphic statements; the prototype
shows two instances on one type do coexist. It loses because resolution is keyed on how the
operator is written, which is fragile for operators the library defines through `def`, and
because the elaborators have the operator in hand anyway.

**Note for (f).** Review #7 asks whether one step taking the operator removes the `⊡` iteration
limit. The prototype does not answer that; it shows only that the step is one definition.

**Confidence.** High; machine-checked. The 5 axiom was left out of the prototype because its
three statements differ, which is itself the finding.

### (f) Whether `⊡` stays in the Modal family

**Decision.** Unchanged and not re-examined here. The design starts from `⊡` in Modal; task 970
owns the question and nothing waits on it. Two findings above are inputs to it: the three axiom
bases, and the structure carrier, which makes a later split a matter of which module holds an
instance.

**Record hygiene.** The question is stated three times (`proof-mode.md` decision 4,
architecture decision 6, `theorem-library.md` decision 2). Keep the full statement in
`theorem-library.md`, which has the case for each side, and reduce the other two to pointers.

**Rejected: decide it now.** Merit: M0, M8, M18 and M21 are cheaper once it is known. It loses
because that is exactly the report M23 commissions, and deciding here would duplicate it.

**Confidence.** High.

### (g) Linearity and the induction rule

**Decision, part 1.** `proof_mode_linearity_case_tactic` is a sequencing-only predecessor of
every part of `proof_mode_until_since_intro_unfold_induction`, the induction rule included. Open
decision 1 of `proof-mode.md` is removed and M4's "undetermined" sentence is replaced.

**Reason.** This holds whatever the rule's formula is. The pure rule lives under
`FormalSystem/Theorems/ProofMode/` at layer 2 and cannot import a tactic (0 import lines from
`Theorems/` into `Automation/`). What it can need is linearity as a theorem, and that is on
`main`: `Axiom.linear_until` and `Theorems/LinearityDerived.lean`. Unfolding already uses that
axiom (`unfoldForward`'s docstring), so the induction rule depends on linearity the same way
invariance does today, through the calculus and not through the case-split record.

**Decision, part 2: the statement.** At ZTime, with guard `g`, event `e` (Lean
`Formula.untl g e`), strict operators and `X φ := untl ⊥ φ`:

```
⊢[ZTime] (X(e ∨ (g ∧ C)) → C) → G(X(e ∨ (g ∧ C)) → C) → (g U e → C)
```

with the Since mirror by time reflection. Both a present premise and a `G` premise are needed
because `G` is strict, as in `forwardInvariantRule`.

*Instance.* Put `g := ⊤`, `e := ¬A`, `C := ¬A`. The premise body becomes `X¬A → ¬A`, which at
ZTime is `A → X A` by contraposition and `¬X¬A ↔ X A`. The conclusion becomes `F¬A → ¬A`, that
is `A → G A`. This is `forwardInvariantRule` up to argument order.

*Validity on ℤ, argued by hand.* Let `g U e` hold at `t` with witness `s > t`. Show `C` on
`[t, s-1]` downward from `s-1`. At `s-1`, `X e` holds. At `u` with `t ≤ u < s-1`, the point
`u+1` lies in `(t, s)`, so `g` holds there, and `C` holds there by the induction hypothesis.
The premise is available at `t` (present form) and above it (`G` form).

**Status of the statement.** Proposed. Not derived and not machine-checked; deriving it is the
work of the Until/Since record. The instance relation was checked by hand against the Lean
statement at `Discrete.lean:147`.

**Rejected: keep the edge undetermined until the plan states the rule.** Merit: caution about a
formula nobody has derived. It loses because the layer argument does not depend on the formula.

**Rejected statement: backward induction (`linduction`, `G(Gφ → φ)` and `F(Gφ)` give `Gφ`).**
Merit: it is on `main` as `futureBackwardInduction` and PR #8 exposes it. It is a different
rule; `forwardInvariantRule` is not an instance of it, so it does not meet M4's done-when.

**Confidence.** High on part 1. Low-to-medium on part 2 until it is derived.

### (h) Strict or present-inclusive leads-to

**Decision.** Present-inclusive leads-to is the named abbreviation and the form the M10 rules
are stated for. PR #8's strict rules stay as the layer beneath it, labelled as the strict layer,
and the inclusive rules are proved from them. M10's done-when stands as written.

**Reason.** The strict `G(φ → Fψ)` says nothing about the present, and two rules every leads-to
argument starts from fail for it: reflexivity (`G(p → F p)` is refuted on ℤ with `p` true at
exactly one time) and introduction from an implication. PR #8's own statements show the cost:
each rule has a "current" and a "persistent" form (`TemporalComposition.lean:214-216`), and
`leadsToConsequence` takes one side condition now and the other under `G`. M10's finite-family
well-founded progress rule needs the reflexive base case. `Formula.weakFuture` (`φ ∧ Gφ`) is
already on `main` to build the inclusive form from.

**Rejected: strict as the base.** Its merits: it matches the primitive operators, needs no
unfolding of a definition, and its three rules are proved in PR #8 for both languages. It loses
on reflexivity and implication introduction.

**Confidence.** High on the statements read. The refutation of `G(p → F p)` is a one-line
hand argument, not machine-checked.

### (i) What "default" means for adoption: needs user ruling

Not decided. This is a policy on how contributors work.

| Option | What it requires | Evidence for | Evidence against |
|---|---|---|---|
| A | New example and case-study modules are written in the mode | `Examples/` is layer 4 and can import `Automation/` | binds work outside the measure |
| B | Every new derived theorem is registered in `BimodalLib` with a proof-mode script or a recorded failure class | `BimodalLib` sits above every layer; M12's done-when already states this clause | registry (M18) not built |
| C | The mode stays optional outside the sweeps | no burden on contributors | contradicts M12's done-when, which requires B and one module outside tests and sweeps |

Fixed by the tree whatever the ruling: proofs under `FormalSystem/Theorems/` cannot be written
in the mode (layer 2 below layer 3), and M12 hard-depends on a GO.

**Recommendation.** B as the rule, A for `Examples/` and case studies, `Theorems/` exempt and
said to be so, all contingent on a GO. C is already excluded by M12's own done-when; the open
choice is whether A is added to B.

### (j) Where the Minus instance lives

**Decision.** `MinusDeduction.lean` moves from `FormalSystem/Metalogic/Conservativity/` to
`FormalSystem/Theorems/`, with `MinusTemporalDerived.lean` if the rule module needs it. The
Minus pure-rule module then sits under `FormalSystem/Theorems/ProofMode/` like the other two.
The move is M9a's to carry out; the decision is recorded now because it bears on M8's layout.

**Reason.** The closure of both files is layer 0 only, and every importer is at layer 3, so the
move creates no upward edge. Both existing languages with rules keep their deduction theorem at
layer 2 under `Theorems/` (`DeductionTheorem.lean`, `ProofMode/PlusRules.lean:122`); Minus is the
exception. After the move the naming scheme's first item, "the pure-rule modules under
`FormalSystem/Theorems/ProofMode/`", holds for every language.

**Rejected: the instance at layer 3, beside the theorem.** Merits: no file moves, no regenerated
inventories, and once M8 stops elaborators naming a language no `Automation → Metalogic` import
is needed. It loses because it puts one language's rule module outside the Rule-theory lane and
makes the scheme carry an exception.

**Rejected: move it into `MinusLanguage/`.** The per-file rule assigns a language-directory file
the layer of its origin directory, here `Metalogic/Conservativity/`, so it would keep layer 3 as
`MinusLanguage/Soundness.lean` does. Assigning it 0 by content is the judgement
`ORGANISATION.md` rules out by name.

**Confidence.** High on imports. Medium on whether the rule module needs more of the Minus chain
than these two files; that is unknown until the M8 interface exists.

### (k) Whether `BimodalLib` is built by default

**Decision.** No. `BimodalLib` is a Lake library outside `defaultTargets`, built by explicit
target and by its own `--wfail` step in CI, as `BimodalTools` is. An import-direction check
(`FormalSystem` never imports `BimodalLib`) accompanies it, as check B3 does for `BimodalTools`.

**Reason.** The lakefile header states the invariant: a plain `lake build` compiles the
published library and nothing else. The library holds sweeps and, later, enumerated entries,
"many" by the record's own account.

**Rejected: a default target.** Merits: a contributor's plain build would catch a re-proof that
has drifted, and hand-registered entries are cheap. It loses because CI catches the same drift
and the default build's stated meaning would change.

**Confidence.** High.

### (l) Views extraction, and the order of M16 and M17

**Decision.**

- PR #7 does its own surface separation, as a merge condition and not an offer: the formula
  equality path leaves `lrewrite` and `lsimp` and is exposed through `lunfold` / `lfold`, with
  the first rows of the view table. This is the request the review already makes; decision (c)
  now gives it names.
- The full tier stays under `proof_mode_views_tier`: every defined operator, the elaborators'
  operator matching on the same table, and the layer placement from (a).
- Order: M17, then M0, then M16. M17's sequencing dependency on M16 is removed. M16 keeps its
  dependency on M0 and absorbs the rows M17 introduced.

**Reason.** The records as written cannot be scheduled: M17 waits on M16, M16 on M0, and M0 on
PR #7 being merged or declined. Something has to give, and the smallest change is the M17 edge.
The separation is small on the PR's side: the equality handler is already its own pair of
functions (`Rewriting.lean:431-475`) behind one dispatch line. The full tier is not small and
reaches into `main`'s `Meta.lean`, which the contributor does not own.

**Rejected: the maintainer builds M16 first and PR #7 rebases onto it.** Merits: the tier's
owner designs its surface, and principle 1 never has an exception on `main`. It loses because
it requires dropping M16's edge on M0 and writing the tier in a layout M0 then moves, and it
blocks the contributor on unscheduled work.

**Rejected: merge PR #7 with `lrewrite` still casting, separate later.** Merit: fastest merge.
It puts a tactic name serving two tiers on `main`.

**Confidence.** High on the cycle and on the code locations.

## Recommendations

### Edits to `records/proof-mode-architecture.md`

1. Open decision 1: remove; state the pair and the table in "Three tiers".
2. Open decision 2: remove; state the three placements and the condition from (a) in the
   semantic-tier paragraph, with layer 1.
3. Open decision 3: remove; state that the mode has a record and a measured client first, and
   point at `records/semantic-proof-mode.md` once it exists.
4. Open decision 4: remove; state the rule from (d) under "Aim and measure".
5. Open decision 5: remove; state the structure carrier in "The Modal family has two operators
   and one statement", including that fields are theorems because the axiom bases differ.
6. Open decision 6: reduce to a pointer at `theorem-library.md`.
7. "One scheme, used six times": add that the views tier and the planner sit at layer 0 or 1.
8. "Where the work sits": the views row (pair named; first rows contributed with rewriting);
   the semantic row (directory, adapter module); the leads-to row (strict layer beneath the
   inclusive definition); the induction row (statement proposed).

### Edits to `records/proof-mode.md`

1. Open decision 1: remove. M4: replace the "undetermined" sentence by "sequencing only for all
   three"; add the proposed statement to the done-when or the filed-record line.
2. Open decision 2: keep, restated with the three options and the recommendation, until ruled.
3. Open decision 3: remove. M9a: replace the layer-3 sentence by the move from (j).
4. Open decision 4: reduce to a pointer.
5. Open decision 5: remove. M18: state the Lake target is outside `defaultTargets`.
6. The sentence above the list ("These need a ruling from the user. Nothing in this document
   decides them.") no longer fits a list of one; reword.
7. M16: files at layer 0 or 1; sequencing dependency on M17's rows; lane table adjusted.
8. M17: remove the sequencing dependency on M16; done-when gains the second-run comparison and
   the surface separation; drop the pointer to architecture decision 4.
9. M1: add `G`/`H` carrying rows and time reflection to the done-when if adopted under (d).
10. M10: say the strict rules are the layer beneath; no change of substance.
11. "Dependency picture" and "What can run at once": M17 before M0 before M16.
12. The four reversible positions are untouched by these decisions.

### Edits to `records/theorem-library.md`

1. Open decision 1 (build status): remove; state it in "Layout".
2. Open decision 2: keep as the single full statement of the `⊡` question.
3. Open decision 3 (enumeration bounds): not among the twelve questions; left open and said so.

### Edits to the review files

- `pr7-review.md`: lines 71 and 76 state decisions (d) and (l) and (c) instead of asking; line
  83 states the structure carrier from (e); line 33's hold on M0 stays.
- `pr8-review.md`: line 32 states which two rules may enter gate one and on what condition;
  line 73 gives the proposed induction statement and says the linearity edge is sequencing
  only; line 74 states (h); line 79 names the pair; add the keyword note if ruling item 2 goes
  the recommended way.
- `pr9-review.md`: line 97 and line 116 state (a) with layer 1 and the condition; **line 141 is
  removed**, since the contributor's "Layer 1" is correct; lines 146-148 state (b) with the
  control run; line 105 notes the layer of views and planner.

### Not to do

Nothing is posted to GitHub. The review files are revised in place under `specs/`.

## Adversarial Self-Verification

| Claim | Evidence | Method | Confidence |
|---|---|---|---|
| `Semantics/` is layer 1 | `LAYERS` dict; `ORGANISATION.md` table | read both | High |
| PR #9 lemma modules close at layer 1 | closure table | `evidence/closure.py` on `pr/9-head` | High |
| PR #9 elaborators reach layer 3 | closure table, direct import lists | same | High |
| A tactic exists at layer 1 | `FrameClassValidity.lean:210` | grep | High |
| Class variant fails through a `def` | `#guard_msgs` block | `lake env lean`, exit 0 | High |
| Structure variant gives one step for three operators | three `example`s | same | High |
| Axiom bases differ | constructor lists of `Axiom`, `PlusAxiom` | grep; a first prototype failed on `Axiom.modal_4` | High |
| `Theorems/` never imports `Automation/` | 0 lines | grep | High |
| Minus chain closes at layer 0 | import lines | grep | High |
| Perpetuity uses no Until, Since, Next | token counts | grep | High |
| M17, M16, M0 form a cycle | three record blocks | read | High |
| Induction rule is valid on ℤ | hand argument | none mechanical | Low-Medium |
| `G(p → F p)` is not valid | hand argument | none mechanical | Medium |
| About 60 refutation theorems | one name pattern | grep | Low (marked) |
| Semantic tactics shorten refutations | none | not tested | UNVERIFIED |

Conflicts searched for: the layer number (found, resolved by current code over record text);
the claim that only the adapter needs layer 3 (found partly false as built, resolved by the
closure); whether `state.json` also carries the cycle (it does not).

Limits. The closure script reads `import` lines of `FormalSystem.*` modules only. No PR branch
was built. The planner's freedom from proof-building is the review's claim and was not checked.

## Risks & Mitigations

- **(a) rests on moving views and planner down.** If M16 cannot be written at layer 0 or 1,
  the placement falls back to `Automation/`. Mitigation: the `formula_unfold` sets and PR #8's
  layer-0 `TemporalViews.lean` show the content is already there.
- **The induction statement may need adjusting when derived.** Mitigation: it is marked
  proposed, and part 1 of (g) does not depend on it.
- **Asking PR #7 for the surface split adds to a long review.** Mitigation: it is one function
  pair behind one dispatch line, and the names are now fixed.
- **The contributor may prefer other tactic names.** The reviews invite a view; the decision
  can be revisited on argument.

## Context Extension Recommendations

None (meta task).

## Appendix

Commands, run from the repository root:

- `python3 specs/976_decide_open_questions_from_pr_reviews_and_records/evidence/closure.py pr/9-head <modules...>`
- `lake env lean specs/976_decide_open_questions_from_pr_reviews_and_records/evidence/S5Proto.lean`
- `grep -n "^LAYERS" -A8 scripts/measure-refactor-partitions.py`
- `grep -rn 'import FormalSystem.Automation' FormalSystem/Theorems | wc -l`
- `git grep -hoE '^\s*(syntax|elab|macro) (\(name := \w+\) )?"l[a-z_]+"' pr/8-head -- FormalSystem/Automation/ProofMode`
- `jq` over `specs/state.json` for tasks 944-976 and their dependencies

Issue log: one entry recorded (the layer-number error). No blocker met.
