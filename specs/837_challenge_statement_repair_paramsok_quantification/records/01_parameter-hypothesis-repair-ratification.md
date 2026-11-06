# Decision Record: the parameter-hypothesis repair to the refuted Challenge statements

- **Record**: 01, task 837
- **Date**: 2026-11-06
- **Decides**: nothing. This record RATIFIES a repair already adopted and already landed.
- **Adopting round**: `specs/761_ladder_realization_theorem/plans/03_ladder-paramsok-parameter-repair.md`
- **Carried forward in**: `specs/761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md`,
  `## Lean Challenge Statements` block (declarations at `:4062` and `:4113`; the hypothesis at
  `:4067` and `:4118`)
- **Library layer**: `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean`
- **Refuting probe**: `specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean`
  (`Probe761R`)

Every line number in this record was re-derived by command on 2026-11-06, not copied from an
earlier artifact.

## Decision

**Repair (a) — adding a `ParamsOk` hypothesis — is the adopted repair for the two refuted
factorization-side Challenge statements `cellAt_const_of_kappa_eq` and `ladderRealized`. Repair
(b), existentially quantifying the four parameters `(Tc Tn P B : Nat)`, is NOT adopted.**

The defect repair (a) answers: both statements universally quantified `(Tc Tn P B : Nat)` with no
hypothesis relating the parameters to the object, the formula, or each other. At
`Tc = Tn = P = B = 0` the quotient `CK 0 0 0 0` is a subsingleton, so the class map `kappa`
identifies every counter pair whatever it is, and both statements then assert that the ladder cell
is constant in `(c, n)` — which `cell_succ_ne` refutes. Repair (a) keeps the parameters
universally quantified and CONSTRAINS them by the four parameter conditions (K1)-(K4), which
`ParamsOk` bundles (`CounterQuotient.lean:776`):

```
paramsOkK1 step pend lab φ P ∧ paramsOkK2 step pend lab φ Tc ∧
  paramsOkK3 Q pend φ Tc Tn ∧ paramsOkK4 φ B
```

**Why repair (b) is not adopted.** Existentially quantifying `(Tc Tn P B)` would make both
statements assert only that SOME parameter tuple works, which no downstream consumer can use:
`ladderSound`, `ladderCons_localRun` and `ladderLift` all quantify the same four parameters
universally and must instantiate at a tuple the caller chooses, and `Dmax` is indexed by them
(`Dmax step pend lab phi Tc Tn P B`). An existential would also hide, rather than state, the
parameter conditions (K1)-(K4) that the design of record names. Repair (a) states them.

## The revised statements

Both signatures below are quoted verbatim from plan 11's `## Lean Challenge Statements` block,
with the hypothesis `(hp : ParamsOk step pend lab phi Tc Tn P B)` in its recorded position —
immediately after the parameter binder `(phi : PlusFormula) (Tc Tn P B : Nat)` and before the
state binders. (The block uses ASCII `forall`/`exists`/`->` and `phi` by its own convention; the
`sorry` bodies are the block's unproved-Challenge marker.)

```lean
theorem cellAt_const_of_kappa_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B)
    (q : Q) (c n c' n' : Nat) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (t z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      = cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c', n'), h'⟩) z := sorry
```

```lean
theorem ladderRealized {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q) (t z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      = {T | exists S : ClType phi, typeOfCl S = T ∧
          (q, S, kappa Tc Tn P B (c, n)) ∈ Dmax step pend lab phi Tc Tn P B} := sorry
```

The other four theorems of the same block — `ladderSound`, `ladderCons_localRun`, `ladderLift`
and `paramsOk_params` — are unchanged by this repair and do NOT carry `hp`. `ladderSound`,
`ladderCons_localRun` and `ladderLift` are not factorization-side statements: they do not assert
that the cell is a function of the `kappa`-class, so the subsingleton collapse does not refute
them and the hypothesis would be decoration there.

## Why the hypothesis is dischargeable

`paramsOk_params` (`CounterQuotient.lean:785`) proves `ParamsOk` at exactly the four parameters
the periodicity fixpoint defines for an object:

```
ParamsOk step pend lab φ (Tcof step pend lab φ) (Tnof step pend lab φ)
  (Pof step pend lab φ) (Bof step pend lab φ)
```

Its in-source docstring (`CounterQuotient.lean:781-784`) states the standard this meets: a
hypothesis no one can discharge is indistinguishable from an unproved statement for every
downstream consumer. This one has a landed witness, so neither revised statement is vacuous, and
a consumer instantiating at the fixpoint's own outputs discharges `hp` by `paramsOk_params`
without further work.

## Why the hypothesis is load-bearing

`not_paramsOk_allZero` (`CounterQuotient.lean:868`) records that `ParamsOk` FAILS at the tuple the
refutation turns on, on the refuting probe's own four-state tag object:

```
¬ ParamsOk stepP pendP labP phiP 0 0 0 0
```

So the hypothesis is not decoration: it excludes precisely the counterexample. The refutation it
excludes is compiled and stays wired, in the probe file named above:

| Declaration | Location | What it establishes |
|---|---|---|
| `ck_zero_subsingleton` | `ladder-unconstrained-parameter-refutation.lean:486` | `CK 0 0 0 0` has exactly one inhabitant, by `decide`; inhabited by `ckZero`. An equality of inhabitants, not an emptiness claim |
| `cell_succ_ne` | `ladder-unconstrained-parameter-refutation.lean:458` | the ladder cell is NOT constant in `(c, n)`, for every `c` and `n` at fixed next deadline |
| `separating_pair_nonvacuous` | `ladder-unconstrained-parameter-refutation.lean:575` | non-vacuity on both sides of the separation, so the refutation is not an artefact of an empty side |

These three are declarations of the WIRED PROBE, not of the library; `CounterQuotient.lean:30-43`
narrates them in prose under the heading "Why the parameters are CONSTRAINED and not freely
quantified". That docstring also records the standing instruction: the probe stays wired and
unchanged, because it is the compiled reason the hypothesis exists, and a reader who removes the
hypothesis re-breaks both statements.

## What this ratification does NOT cover

**`ParamsOk` is not a general repair for every refuted statement of the round, and must NOT be
added to `rk_of_count_drift`.** `specs/761_ladder_realization_theorem/reports/08_rk-bounded-representative-refutation.md`
Finding 4 establishes why: `ParamsOk` constrains `P` only through (K1), a divisibility condition
into `P + 1`, and neither (K2) nor (K3) mentions `P` at all. So `ParamsOk` admits `P` arbitrarily
large relative to `Tc`, `Tn` and `B` — precisely the direction that refutation exploits — and no
numeric consequence of `ParamsOk` can close that gap. The in-source docstring at
`CounterQuotient.lean:421` already carries the instruction at the declaration's own site:
"**`ParamsOk` is NOT a hypothesis here, and must not be added.**"

Both facts are stated here together deliberately, so a later round reads neither as general: the
hypothesis repairs the two factorization-side statements and nothing else.

## The `realizes_of_certAdm_cohBi` directive conflict

A second, independent inconsistency stood in task 761's plan 01: its Phase 8 task list required
promoting `realizes_of_certAdm_cohBi` while that phase's own Scope Hypothesis said `certStab` and
`certAdm` are deliberately NOT promoted. The two directives cannot both hold —
`realizes_of_certAdm_cohBi` is stated in terms of `certAdm` and its proof destructures
`certAdm_iff`'s fields.

**Settled in favour of promotion.** `certStab` and `certAdm` were promoted at the `K`-free carrier
`ProdState Q φ`, and the promoted layer is landed:

| Anchor | Location |
|---|---|
| `abbrev ProdState` | `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean:791` |
| `def certStab` | `Certificate.lean:975` |
| `def certAdm` | `Certificate.lean:984` |
| `theorem certAdm_iff` | `Certificate.lean:988` |
| `theorem realizes_of_certAdm_cohBi` | `Certificate.lean:1312` |
| The reason, in-source | `Certificate.lean:75-78`, under "Deliberately NOT promoted" |

`Certificate.lean:75-78` states the resolution in the module itself: "`certStab` and `certAdm` ARE
promoted, at the `K`-free carrier `ProdState Q φ`, because `realizes_of_certAdm_cohBi` is stated
in terms of both and cannot be promoted without them; the `K`-indexed versions of the same two
conditions are separate objects over a different carrier and carry their own names." The
`K`-indexed versions (`certStabK`, `certAdmK`) are what the Scope Hypothesis was about, and they
remain unpromoted. The decision and its reason are also recorded in
`specs/761_ladder_realization_theorem/summaries/01_ladder-realization-presentation-a-summary.md`
(Decisions and Plan Deviations sections), and plan 11's `### Phase 8: Promote the Certificate
Layer into the Library` is `[COMPLETED]` at `:957` with no contradictory Scope Hypothesis. No live
plan carries the conflict; this record exists so a later round does not re-litigate it.

## Statement Fidelity position

`.claude/rules/plan-compliance.md`'s Statement Fidelity rule forbids an *implement* dispatch from
editing a recorded Challenge statement in flight. It does not forbid a plan revision from
recording a corrected one, and it does not forbid a later record from citing a correction already
adopted that way. Both conditions hold here:

1. Task 761's Phases 9 and 13 closed `[BLOCKED]` under plan 01 rather than editing the statements
   — the escalate-rather-than-edit behaviour the rule mandates.
2. The corrected statements were then recorded by a `/revise` round,
   `plans/03_ladder-paramsok-parameter-repair.md`, and carried forward to plan 11 unchanged.

This record therefore ratifies and documents; it adopts nothing new, and it changes no recorded
statement to match an implementation.

## What is NOT claimed here

- **Neither theorem is proved.** `cellAt_const_of_kappa_eq` and `ladderRealized` are both still
  unproved, and both remain `sorry`-bodied in plan 11's Challenge block. Task 761 owns them:
  Phase 11.7 (`:1519`, `[NOT STARTED]`) owns the agreement `cellAt_const_of_kappa_eq`, and
  Phase 16 (`:3843`, `[NOT STARTED]`) owns the fibre equation `ladderRealized`.
- **This record changes no `.lean` file.** Task 837's round writes no Lean source at all; the
  library layer it cites (`ParamsOk`, `paramsOk_params`, `not_paramsOk_allZero`) was landed by
  task 761 and is read, not modified. No `lake build` result is claimed by this record, because
  this round compiles nothing.
- **Nothing in task 761's lane is edited.** Task 761 is on `[HOLD]`; its plans, summaries, reports
  and `specs/state.json` entry are untouched by the round that wrote this record.
