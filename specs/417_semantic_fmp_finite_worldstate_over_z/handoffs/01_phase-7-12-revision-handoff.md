# Task 417 — Revision Handoff: the two blockers share one root cause

**Date**: 2026-08-17
**Status at handoff**: `[BLOCKED]` — 8 of 13 phases closed
**Author**: orchestrator, from the dispatch's own machine-checked evidence
**Supersedes planning in**: `plans/03_semantic-fmp-z-time.md` phases 7, 9, 10, 12, 13

---

## 1. Executive summary

The dispatch reported two independent blockers. They are not independent. Both are instances of a
single modelling error:

> **Satisfiability is treated as a property of a world-state when it is irreducibly a property of
> a history.**

- **Phase 7** asserts a truth lemma of the form `TruthAt M τ t ψ ↔ ψ ∈ (τ.states t).carrier` —
  i.e. that truth at `(τ, t)` is fixed by the *state* `τ.states t` alone.
- **Phase 12** asserts a decision procedure `check P w φ : Bool` recursing on `φ` — i.e. that
  satisfiability at a *state* `w` is compositional in `φ`.

Both are false, and the dispatch proved both false. The shared repair is to make the **path** the
primary object: define truth *along a fixed, finitely-presented path*, which is compositional and
computable, and place the existential quantifier over paths only at the top level, outside the
recursion.

This reframing also unifies the deliverables: the **same** object — a bounded, fulfilling,
ultimately-periodic path — is what the semantic FMP produces and what the decision procedure
enumerates. The task currently builds two unrelated machines; it should build one.

**Two corrections to the blocker records** follow in §3. One of them materially reduces the
estimated remaining work; the other materially increases it. Both matter for planning.

---

## 2. What actually landed (reusable assets)

Verified present and sorry-free in the tree at handoff time:

| Asset | Location | Why it matters downstream |
|---|---|---|
| `TaskFrame.ofStep R₁ fwd bwd : TaskFrame ℤ` | `Semantics/IntNormalForm.lean:411` | Synthesises a **fully axiomatised** ℤ task frame from a bare one-step relation. See §3.1. |
| `TaskFrame.ofStep_step` | `IntNormalForm.lean:450` | The synthesised frame's step relation *is* `R₁`, definitionally. |
| `spherical_of_finite` | `Semantics/TaskFrame.lean:930` | *Spherical* for **any** relation on a finite carrier. |
| `limit_of_succOrder` | `Semantics/TaskFrame.lean` | *Limit* from discreteness of the duration type, for **any** relation. |
| `mem_HF_iff_adjacent` (Phase 4) | `Semantics/IntNormalForm.lean` | `H_F` over ℤ = bi-infinite step-paths. The bridge from frames to paths. |
| `box_const` (Phase 6) | Phase 6 output | `□` is a model constant — history-independent. Critical for §4.3. |
| `exists_bounded_iter`, `exists_lt_iter_of_card_le`, `exists_repeat_of_isStepPath`, `exists_path_of_iter`, `iter_of_path` (Phase 8) | `FMP/Periodicity.lean` | The pigeonhole/splice toolkit. Consumed by the lasso extraction in §4.2. |
| `IntPresentation`, `toFiniteFrame` (Phase 11) | `Decidability/IntPresentation.lean` | Computable presentation: `card`, `step`, `val`, `fwd`, `bwd`, `card_pos`. |
| `FilteredWorld φ`, `filteredWorld_nonempty`, `subformulaClosureFintype` | `FMP/Filtration.lean`, `FMP/FiniteModel.lean` | Finite, nonempty atom carrier — already built. |
| `ClosureMCS` negation-completeness | `FMP/ClosureMCS.lean:133` | Atoms are negation-complete over `subformulaClosure φ`. |

Phase 8's toolkit is **not** wasted by this revision. It is load-bearing in the recommended
architecture, in both halves.

---

## 3. Corrections to the blocker records

### 3.1 The Phase 7 blocker overestimates the axiom burden — the four axioms are nearly free

The Phase 7 record says:

> "those discharges will be genuinely hard where the permissive ones were free: *Limit* and
> *Spherical* currently come from permissiveness, and a non-universal relation loses both routes."

**This is incorrect over ℤ.** Reading `TaskFrame.ofStep` (`IntNormalForm.lean:411-442`), all seven
frame fields — including all four `def:frame` axioms — are discharged for an **arbitrary** one-step
relation `R₁`:

```lean
def ofStep {W : Type} [Finite W] [Nonempty W] (R₁ : W → W → Prop)
    (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w) : TaskFrame ℤ where
  ...
  serial    := ...                                  -- from fwd/bwd, iterated
  limit     := limit_of_succOrder ...               -- from ℤ's discreteness
  spherical := spherical_of_finite (ofStepRel R₁)   -- from [Finite W]
```

Neither `limit` nor `spherical` consults `R₁` at all. `limit` is a fact about ℤ having a successor;
`spherical` is a fact about the carrier being finite. Permissiveness was never what bought them —
it merely also happened to work.

**Consequence**: the entire axiom obligation for a genuine filtered relation reduces to exactly two
lemmas:

```lean
fwd : ∀ w : FilteredWorld φ, ∃ u, filteredStep φ w u
bwd : ∀ w : FilteredWorld φ, ∃ v, filteredStep φ v w
```

`[Finite]` and `[Nonempty]` for `FilteredWorld φ` already exist. This is a large reduction against
the blocker's estimate: what looked like "four fresh axiom discharges, two of them genuinely hard"
is two seriality lemmas and a call to a landed constructor.

### 3.2 The Phase 12 blocker's proposed fix is right in kind but wrong in shape for ℤ

The record's `to_unblock` says:

> "Index `check` by an ultimately-periodic path (a lasso: prefix + loop) — the standard
> omega-automata setup."

Prefix + loop is the **ℕ**-shaped lasso. The frames here are indexed by **ℤ**, and `H_F` consists
of *bi-infinite* step-paths (Phase 4's `mem_HF_iff_adjacent`). A path that is ultimately periodic
only to the right is not finitely presented — its past is still arbitrary, and `snce` quantifies
over it.

The correct object is a **bi-lasso**: ultimately periodic in *both* directions.

```
   … B B B B ] [ M ] [ F F F F …
   ←── backward loop, repeated leftward
                  ↑ finite middle
                        forward loop, repeated rightward →
```

Getting this wrong is not cosmetic: a right-only lasso makes the `snce` case of `eval`
non-terminating and the small-model theorem false as stated. Flagging it because the record's
phrasing would lead a fresh implementer straight into it.

### 3.3 A third obstruction the record does not name: there is no canonical relation to filter

`grep` over `FormalSystem/Metalogic/BXCanonical/` finds **no** canonical one-step, task, or
temporal relation defined anywhere. The Phase 7 record describes the fix as "a genuine filtered
task relation", which presupposes something to filter. There is nothing.

So `filteredStep` is not a filtration of an existing canonical relation — it must be **defined
outright** from the MCS structure, and its adequacy proved directly. This does not make the task
harder than the record implies in *difficulty*, but it changes its *character*: it is a
construction, not a quotient, and it cannot borrow correctness from a canonical-model theorem that
does not exist.

---

## 4. Recommended architecture

### 4.0 The organising principle

Define these three notions, in this order, and let everything else follow:

1. **Coherent path** — a `filteredStep`-path. Captures the *local* unfolding conditions.
2. **Fulfilling path** — a coherent path in which every eventuality obligation is actually
   discharged. Captures the *global* condition the local one cannot.
3. **Bi-lasso** — a finitely-presented ultimately-periodic path, in both directions.

The truth lemma holds along **fulfilling** paths, not along coherent ones (§4.4). The decision
procedure enumerates **bi-lassos**. The bridge between them is a small-model theorem: *if a
fulfilling path exists, a bounded fulfilling bi-lasso exists* (§4.2).

### 4.1 Why ℤ is exactly the right scope (and the Discrete class is not)

ℤ has a successor, so "strictly between `t` and `t+1`" is empty, and the `untl` clause

```lean
| Formula.untl φ ψ => ∃ s, t < s ∧ TruthAt M τ s φ ∧ ∀ r, t < r → r < s → TruthAt M τ r ψ
```

admits an **exact one-step unfolding**:

```
untl φ ψ  at t   ↔   φ at t+1   ∨   ( ψ at t+1  ∧  untl φ ψ at t+1 )
snce φ ψ  at t   ↔   φ at t−1   ∨   ( ψ at t−1  ∧  snce φ ψ at t−1 )
```

Every formula mentioned is already in `subformulaClosure φ`, so the existing closure is adequate —
no Fischer–Ladner enlargement is needed. This is a real piece of luck and should be stated in the
new plan, because it is exactly what fails over a dense duration type, and it is the technical
reason the task is correctly scoped to ℤ-time rather than the paper's Discrete class.

**The eventuality trap, stated explicitly.** The unfolding above is a *fixpoint equation with two
solutions*. The semantics is the **least** fixpoint: the eventuality must actually be discharged.
Any MCS/atom construction only enforces the equation *locally*, which yields the **greatest**
fixpoint, admitting paths that postpone `φ` forever while keeping `ψ` true. This gap — and nothing
else — is what the six Boneyard attempts (`RoundRobinChain`, `OracleStep`, `OracleCoherence`,
`ScheduleBasedBFMCS`, …) were failing to close. Naming it precisely is the main planning value of
this handoff: **do not attempt a truth lemma over coherent paths. It is false.**

### 4.2 The lasso layer (independent, do this first)

New module, proposed `FormalSystem/Metalogic/Decidability/BiLasso.lean`.

```lean
structure BiLasso (P : IntPresentation) where
  back : List (Fin P.card)     -- backward loop, nonempty
  mid  : List (Fin P.card)     -- finite middle, possibly empty
  fwd  : List (Fin P.card)     -- forward loop, nonempty
  back_ne  : back ≠ []
  fwd_ne   : fwd  ≠ []
  -- adjacency within each segment, plus the three seams and the two wrap-arounds
  coherent : ...

def BiLasso.unroll (L : BiLasso P) : ℤ → Fin P.card := ...

theorem BiLasso.unroll_isStepPath (L : BiLasso P) :
    IsStepPath P.toTaskFrame L.unroll
```

Then the evaluator — note it recurses on `φ` with `(L, t)` **fixed**, which is exactly what `check`
failed to do:

```lean
def eval (P) (bx : Formula → Bool) (L : BiLasso P) : ℤ → Formula → Bool
```

with correctness

```lean
theorem eval_correct (hbx : BoxOracleSound P bx) (L : BiLasso P) (t : ℤ) (φ : Formula) :
    eval P bx L t φ = true ↔ TruthAt P.toModel (hist L.unroll) t φ
```

Termination of the `untl`/`snce` cases: truth along `unroll L` is periodic outside the middle, so
each case need only scan `|mid| + |fwd|` (resp. `|mid| + |back|`) positions. State this as a
periodicity lemma and use it, rather than attempting well-founded recursion on ℤ.

**The small-model theorem** (the crux of this layer, and where Phase 8 is consumed):

```lean
theorem exists_biLasso_of_truth
    (τ : P.toTaskFrame.HF) (t : ℤ) (φ : Formula)
    (h : TruthAt P.toModel τ.val t φ) :
    ∃ L : BiLasso P, L.bounded (P.card) φ ∧ eval P bx L t φ = true
```

Proof technique — the point where the eventuality trap must be dodged a second time. Pigeonhole
must be run not on states but on **triples**:

```
( state ,  type ,  pending )
```

where *type* is the set of closure-subformulas true at that position and *pending* is the set of
as-yet-undischarged eventuality obligations. Pigeonholing on `state` alone (or even on
`state × type`) lets the extracted loop drop an obligation that the original path discharged
outside the loop — producing a lasso that satisfies the unfolding equation but not the semantics.
This is the degeneralisation step of the standard Büchi construction, and it is the single most
likely place for this layer to go wrong.

`exists_bounded_iter` is the right shape for the forward search; `exists_lt_iter_of_card_le` is the
splice. Both are already stated against the adjacency presentation, so they apply directly.

**Then, finally:**

```lean
def check (P : IntPresentation) (w : Fin P.card) (φ : Formula) : Bool :=
  decide (∃ L ∈ boundedBiLassos P (bound P.card φ), L.unroll 0 = w ∧ eval P bx L 0 φ)
```

This is a legitimate `check` because the `∃` sits **outside** the recursion on `φ`. The
`no_compositional_imp` refutation does not touch it — that theorem refutes any `g` computing
`Sat (φ → ψ)` from `Sat φ` and `Sat ψ`, and this definition never forms such a `g`.

**Retain `evidence/phase12-check-not-compositional.lean` in the tree** as a regression guard. It is
a permanent proof that the abandoned signature cannot be revived, and it is cheap to keep green.

### 4.3 The box oracle — stratify by modal depth

`box_const` (Phase 6) gives that `□χ` is history-independent. But computing it is a
*validity-in-the-presentation* question:

```
□χ true  ⟺  ∀ total histories σ, χ at σ  ⟺  ¬ ∃ bi-lasso refuting χ
```

so the box oracle calls back into `eval`. Break the circularity by **induction on modal depth**:
compute `bx` for all `□`-subformulas of depth `k` using an `eval` that only ever consults `bx` at
depth `< k`. Define `BoxOracleSound` as the invariant carried through this induction.

This obligation is **not** in the current plan at all. It is not hard, but it is a phase's worth of
work and it must exist, or `eval`'s `box` case has nothing correct to call.

### 4.4 The filtration layer (harder; do second)

New module, proposed `FMP/FilteredStep.lean`.

```lean
def filteredStep (φ : Formula) (w u : FilteredWorld φ) : Prop
```

lifted through `Quotient.lift₂` from a relation on `ClosureMCSBundle φ` requiring, for all
formulas in `subformulaClosure φ`:

| Clause | Condition |
|---|---|
| `untl χ ψ` | `untl χ ψ ∈ w  ↔  χ ∈ u ∨ (ψ ∈ u ∧ untl χ ψ ∈ u)` |
| `snce χ ψ` | `snce χ ψ ∈ u  ↔  χ ∈ w ∨ (ψ ∈ w ∧ snce χ ψ ∈ w)` |
| `box χ` | `box χ ∈ w  ↔  box χ ∈ u` (box is a model constant) |

Well-definedness on the quotient is immediate: every clause mentions only membership of
closure-formulas, and `formula_mem_respects_equiv` (`Filtration.lean:411`) already gives that
membership respects `ClosureMCSEquiv`.

Then, by §3.1, the **entire** remaining frame obligation is:

```lean
theorem filteredStep_fwd (φ) (w : FilteredWorld φ) : ∃ u, filteredStep φ w u
theorem filteredStep_bwd (φ) (w : FilteredWorld φ) : ∃ v, filteredStep φ v w

noncomputable def FilteredStepFrame (φ : Formula) : TaskFrame ℤ :=
  TaskFrame.ofStep (filteredStep φ) (filteredStep_fwd φ) (filteredStep_bwd φ)
```

and all four `def:frame` axioms come with it.

**`filteredStep_fwd` is the real work and the main unknown.** It is a Lindenbaum-style step: given
a closure MCS `w`, construct a closure MCS `u` satisfying the table. Whether this is provable
depends on the proof system carrying the temporal axioms that make the unfolding derivable
(a `untl`-fixpoint axiom and its `snce` mirror, or something that entails them). **This has not
been verified.** See §6 for the spike that must precede any commitment here.

`filteredStep_bwd` should come from `temporal_duality` rather than a duplicated argument — the
table is symmetric under swapping `untl`/`snce` and reversing the relation.

### 4.5 The fulfilling-path lemma replaces the truth lemma

Do **not** restate Phase 7's truth lemma. State this instead:

```lean
def Fulfilling (φ) (p : ℤ → FilteredWorld φ) : Prop :=
  (∀ t, ∀ χ ψ, untl χ ψ ∈ p t → ∃ s, t < s ∧ χ ∈ p s ∧ ∀ r, t < r → r < s → ψ ∈ p r) ∧
  (∀ t, ∀ χ ψ, snce χ ψ ∈ p t → ∃ s, s < t ∧ χ ∈ p s ∧ ∀ r, s < r → r < t → ψ ∈ p r)

theorem truth_along_fulfilling (φ) (p) (hcoh : IsStepPath (FilteredStepFrame φ) p)
    (hful : Fulfilling φ p) (t : ℤ) (ψ) (hψ : ψ ∈ subformulaClosure φ) :
    TruthAt (filteredModel φ) (hist p) t ψ ↔ ψ ∈ p t
```

Induction on `ψ`. The `untl`/`snce` cases split cleanly: `←` is `Fulfilling` applied directly;
`→` is the unfolding conditions plus induction. This decomposition is what makes the eventuality
case tractable, and it is precisely the decomposition the Boneyard attempts lacked — they tried to
*establish* fulfilment inside the truth-lemma induction, where it cannot be established because it
is not a local property.

Fulfilment is then supplied from outside, and cheaply: the projection of a genuine satisfying model
is fulfilling **by construction**, because the model's own eventualities are genuinely witnessed.
That is the whole argument.

### 4.6 Assembling the FMP

```
satisfying model over ℤ
  → project each time to its atom            (fulfilling coherent path, by construction)
  → truth_along_fulfilling                   (truth ↔ membership along it)
  → bounded bi-lasso extraction (§4.2)       (finite presentation, fulfilment preserved)
  → finite WorldState model over ℤ           ∎
```

The lasso layer is reused verbatim; the extraction argument does not need to be written twice. This
is the payoff of the unification and the reason to build §4.2 first even though §4.4 is what the
task nominally exists for.

---

## 5. Recommended task split

The current task is three tasks wearing one plan. Splitting is what makes the risk legible.

| Task | Scope | Depends on | Risk | Deliverable if it lands alone |
|---|---|---|---|---|
| **A — bi-lasso layer** | §4.2 + §4.3. `BiLasso`, `unroll`, `eval`, `eval_correct`, box oracle, small-model theorem, `check`, `check_correct`, `Decidable` instance | Phase 8, 11 (both landed) | Medium | A working decision procedure for presented ℤ-frames. Ships independently. |
| **B — filtered step relation** | §4.4. `filteredStep`, `fwd`, `bwd`, `FilteredStepFrame`, four axioms via `ofStep` | Phases 2, 5 (both landed) | Medium-high, concentrated in `fwd` | A genuine finite ℤ frame carrying the MCS dynamics. |
| **C — 417, retained** | §4.5 + §4.6. `Fulfilling`, `truth_along_fulfilling`, semantic FMP | A, B | **Highest** — this is where the Boneyard sits | The task's original deliverable. |

Recommended order: **A → B → C**. A is independent, unblocks the two phases that are blocked for
the *easier* of the two reasons, and produces the extraction machinery C needs. B's main risk is
resolvable by a cheap spike (§6). C should not be dispatched until both are green.

**Do not re-dispatch 417 as it stands.** Phases 7, 9, 10, 12, 13 of `plans/03` are superseded by
this handoff; phases 1–6, 8, 11 are closed and should be preserved as landed.

---

## 6. Required spike before committing to Task B

**Question**: is `filteredStep_fwd` provable in this repository's proof system?

**Why it gates**: §4.4 reduces the whole frame construction to `fwd`/`bwd`. If `fwd` is not
provable, Task B is not a construction task but an axiomatisation task, and the plan is wrong in a
way no amount of implementation effort fixes.

**Procedure** (2–4 hours, go/no-go, no `sorry`):

1. Identify the proof-system rules governing `untl`/`snce` — specifically whether the fixpoint
   unfolding of §4.1 is derivable as a theorem schema.
2. Attempt `filteredStep_fwd` for the single-eventuality case: `φ = untl p q`, so
   `subformulaClosure φ` has four elements and `FilteredWorld φ` is small enough to inspect
   concretely.
3. Report one of: **(a)** derivable, with the schema named; **(b)** derivable only with an
   additional axiom, with that axiom stated and its soundness over ℤ checked; **(c)** not
   derivable, with the obstruction exhibited.

Outcome (b) is a legitimate and expected result, but it changes the task's character from
construction to axiom-extension and must be surfaced to the user before proceeding, not absorbed
silently.

**Mind the argument-order convention throughout**: `Formula.untl φ ψ` is **event-first,
guard-second** — "`φ` holds at some future `s`, with `ψ` throughout between". This reads backwards
from the naive guard-first convention. See `specs/decisions/untl-snce-argument-order.md`. Every
table in this handoff uses the repository convention. Getting it backwards is silent and
expensive, and the current plan's Phase 9 already flags it as a known failure mode.

---

## 7. Verification contract for the successor work

Non-negotiable, inherited from the current plan and reaffirmed:

- **Zero `sorry`.** Not as scaffold, not as placeholder, not "removed next phase". The live-sorry
  count for the repository stays at exactly 1 (`Transfer.lean:1084`, task 415's declared
  invariant), verified via `scripts/check-module-invariants.sh`, never naive grep.
- **No vacuous definitions.** No `def X := True`, no restatement of a lemma in a form that holds
  trivially. The Phase 7 blocker record notes none was used; hold that line.
- **A blocked phase stops the dispatch.** Mark `[BLOCKED]`, write the record with the precise goal
  state that resisted, escalate. Do not proceed to dependent phases.
- **Evidence files stay green.** Both existing probes
  (`evidence/phase7-filtered-frame-is-universal.lean`,
  `evidence/phase12-check-not-compositional.lean`) are permanent regression guards against
  reviving either refuted design. Wire them into the build rather than leaving them as loose files.
- **Scope honesty in docstrings.** The target is **ℤ-time**, not the paper's Discrete class — the
  Discrete-class form is false (`CO` is refutable on `ℤ ×lex ℤ` yet valid over `D = ℤ`, which task
  419 has now machine-checked). And `cor:tm-decidability` states decidability is **open**, so
  nothing here backs a decidability claim for the logic.

**Blocking prerequisite, inherited from Phase 10's record**: `cor:tm-decidability` no longer
resolves in the live paper, and `specs/paper-definitions-of-record.md` is stale repo-wide
(`check-paper-definitions.sh` returns case (c): 19 drifted anchors, 2 dangling). Any successor
dispatch that must cite that anchor has to re-resolve it first. This is not owned by any current
task and is worth its own.

---

## 8. Provenance and confidence

Written by the orchestrator from the dispatch's own machine-checked evidence plus direct reading
of the tree. Confidence varies by section and is stated honestly:

| Claim | Basis | Confidence |
|---|---|---|
| Both blockers share the state-vs-path root cause | Direct reading of both probe files | High |
| `ofStep` discharges all four axioms for any `R₁` | Read `IntNormalForm.lean:411-442` directly | High — verifiable in one file read |
| A ℤ lasso must be bi-infinite | `mem_HF_iff_adjacent` + `snce` semantics | High |
| No canonical relation exists to filter | `grep` over `BXCanonical/`, empty result | High |
| ℤ-unfolding is exact and closure is adequate | `TruthAt` definition + `SuccOrder` | High |
| Pigeonhole must range over `(state, type, pending)` | Standard Büchi degeneralisation | Medium-high — not verified against this tree |
| `filteredStep_fwd` is provable here | **Not verified** | **Unknown — this is what §6 exists to settle** |
| Effort ordering A → B → C | Dependency structure above | Medium |

No proof in this document has been attempted in Lean. The architecture is a recommendation
grounded in what the tree already contains; §6 is the designed first contact with reality, and it
is placed exactly where the confidence table says the uncertainty is.
