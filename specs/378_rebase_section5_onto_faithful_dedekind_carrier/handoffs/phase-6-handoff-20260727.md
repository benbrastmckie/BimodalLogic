# Phase 6 handoff — faithful Lemma 5.1 at one witness, landed

**Session**: `sess_1785150996_3c6f1f_378` | **Date**: 2026-07-27 | **Phase 6 status**: COMPLETED

## Immediate next action

Dispatch **Phase 7** (`negFixListFaithful`, `NegFixListFaithful.lean`) — the declared cost centre,
with its mandatory internal re-split boundaries 7a/7b/7c. Read PDF pp.10-11 directly first.

Phase 7 should expect the shape Phase 6 found, because **Phase 7 is the continuation of the very
induction Phase 6 stopped at**: PDF p.10's *"It is sufficient to show that
`(∃z)^{<z₁}_{>z₀} INF^{¬β₁}(z) ∧ ¬[α₀,β₁,α₁,…,β_{n+1},α_{n+1}](z₀,z₁)` is equivalent to a `∨∃⃗∀`
formula. We prove this by induction on `n`. The basis is trivial."* Phase 6 is that statement at
one witness; the `Aᵢ`/`Bᵢ` definitions immediately below it on p.10 are Phase 7's inductive step.
The eq (5.3) pin, the `allSeg`/`infPinPoint`/`concatPin` idiom and `negFixOneTail` all carry
forward directly.

## THE VERDICT PHASE 6 WAS DISPATCHED TO SETTLE

**`HasDedekindSUP` was NOT consumed. This is the THIRD consecutive drop, and it is now a finding
about the plan's carrier model, not about the phase.**

Verified against the actual proof obligations, not inherited. Rabinovich's Lemma 5.1 proof (PDF
pp.9-10) uses **no `K⁻`, no supremum, and no last-occurrence point at all**. Its only pinned point
is the eq (5.3) *infimum* `INF^{¬β₁}`, which is eq (5.2) of p.8 read at `P := ¬β₁` — i.e. the
`HasDedekindINF` carrier, not the SUP one. Its Case 2 hands the entire `s1` side to Corollary
5.4(2), which Phase 5 already proved needs `HasDedekindINF` alone.

The two `h_SUP.last_occ_tp` call sites (`NegFixOne.lean:243`, `:272`) are artifacts of the tree's
own six-disjunct formulation of the `n = 1` negation, not of the paper. No use for
`HasDedekindSUP.last_occ_tp` or `orderedPointsExist_combine_kminus` was contrived.

**Assessment for the orchestrator (not for Phase 7 to re-litigate):** Phase 2's SUP mirror is
unconsumed by Phases 4, 5 and 6, and no remaining phase looks like a plausible consumer on Lemma
5.1 grounds — Phase 7 continues the same Case 3 induction (INF-side), and Phases 8-9 are lifts.
The mirror is still independently valuable (it lands `kminusFormula`/`kminus_formula_correct`,
absent from the tree before, plus the right-end chain primitives and the SUP-side exclusion
theorem), but the plan's expectation that Section 5's `n = 1` case would consume it was wrong
about Rabinovich, not about the implementation.

## The structural payoff held again — but in a different shape

Phases 4 and 5 found the payoff at the *endpoint slot*: `VecEA2.endpointLeft`/`endpointRight` lets
the printed `¬F₀(z₀)` / `¬Ĝ(z₁)` be written directly, so the attained pin disappears. That pattern
recurs here for **Case 1**, which is the pure endpoint condition `K⁺(¬β₁)(z₀)` and is carried by
`kplusLeftBlock` with no carrier at all.

But the decisive new mechanism is different and worth carrying forward: the eq (5.3) pin's point
type `¬β₁(r) ∨ K⁺(¬β₁)(r)` **confines every bracket witness to `(z₀,r₀]` with no carrier
hypothesis whatsoever** (`bracketOne_witness_le_infPin`). The `K⁺` alternative is discharged by
density rather than by producing a witness — that is precisely why attainment is not needed. Phase
7's recursion will need the same step at every peel.

Also worth carrying: `bracketOne_witness_le_infPin` does **not** use eq (5.3)'s second conjunct
`(∀y)^{<z}_{>z₀} β₁(y)`. That conjunct is carried in the disjuncts because Rabinovich prints it
(it is what makes `r₀` the infimum, hence unique), not because the confinement step needs it.

## Why Phase 6 is NOT the six-disjunct list with the carriers swapped — machine-checked

The plan's task line asked to mirror `NegFixOne.lean:224`/`:243`/`:272`/`:276`. That route is
**impossible**, and the module proves it rather than arguing it.

`NegFixOneFaithfulGateProbe` builds an `ℝ` structure — `¬s1` exactly on `(2,3)`, `¬s0` exactly on
`(3,4)`, `p` exactly on `(2,3) ∪ {7}`, interval `(0,10)` — on which:

| fact | declaration |
|---|---|
| the bracket `[s0,p,s1]` fails | `bracketOneR_not_holds` |
| **all six** disjuncts `{A,B1,B2,B3,B4,B4′}` fail | `negFixOneR_not_holds` |
| the FAITHFUL eq (5.2) obligation at the pinned predicate is DISCHARGED (`r₀ = 2`, via the `K⁺` alternative) | `MR_dedekind_shape_at_pR` |
| the ATTAINED obligation is REFUTED | `MR_not_hasAttainedINF` |
| all three as one statement | `negFixOne_not_a_cover_without_attainment` |

So the failure is located exactly at attainment, not at Dedekind completeness. This is the same
class of artifact as `prior_makes_disjunct2_unreachable` and the `ℤ` probe `NegFixGateProbe`
(which shows `B4`/`B4′` are unavoidable *given* attainment); the two probes are complementary.

**Not claimed:** that this `ℝ` structure satisfies `HasDedekindINF` at every predicate. That needs
a definability theorem about `ℝ` the tree does not have, and is not needed — the obligation is
discharged at the predicate the attained cover actually pins.

## What Phase 6 landed

`FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixOneFaithful.lean`, 15
declarations, all axiom-clean:

| Declaration | Role |
|---|---|
| `HasDedekindINF.first_occ_tp` | the INF-side counterpart of Phase 2's `HasDedekindSUP.last_occ_tp` |
| `infPinPoint` / `_holds` | eq (5.3)'s third conjunct `¬β₁(z) ∨ K⁺(¬β₁)(z)` (PDF p.10) |
| `allSeg` / `_holds` | eq (5.3)'s second conjunct `(∀y)^{<z}_{>z₀} β₁(y)` |
| `somePointBlock` / `_holds` | "`P` holds at some interior point", for Case 3a |
| `negFixOneTail` / `_iff` | Rabinovich's `Form₂`: anchored Cor 5.4(2) at anchor `p` (reused from Phase 5, not re-derived) |
| `negFixOneCase1/2/3a/3b/3c` | the paper's `Condᵢ ∧ Formᵢ` disjuncts |
| `negFixOneFaithful` | their disjunction |
| `bracketOne_witness_le_infPin` | the load-bearing confinement step — **carrier-free** |
| `negFixOneFaithful_sound` / `_cover` / `_iff` | Lemma 5.1 at one witness, `HasDedekindINF` alone |
| `negFixOneFaithful_iff_of_attained` | the attained → faithful shim (needs only the INF half) |
| `NegFixOneFaithfulGateProbe.*` (9 decls) | the `ℝ` exclusion probe above |

Plus one import edge + NOTE in `Kamp/NfMultiAnchorBridge.lean`.

## Key decisions

1. **The bracket-notation reading was settled from Figure 1 (PDF p.10), not assumed.** In
   `[α₀,β₁,α₁,β₂,α₂](z₀,z₁)` the `α`'s are POINT types (`α₀` at `z₀`, `α₂` at `z₁`) and the `β`'s
   are SEGMENT types. So `bracketOne s0 p s1` is the paper's `[⊤, s0, p, s1, ⊤]`, and with
   `α₀ = ⊤` the first alternative of the paper's Case 1 (`¬α₀(z₀)`) is unavailable — Case 1 is
   `K⁺(¬s0)(z₀)` alone. Everything downstream depends on this reading.
2. **The three cases are not a case analysis of the module's own devising.** They are exactly the
   three outcomes of `HasDedekindINF.first_occ` read at `P := ¬β₁`: no occurrence (Case 2), left
   disjunct (Case 1), right disjunct (Case 3). That is why the paper can assert "at least one of
   the following cases holds" over Dedekind complete chains with no fourth case.
3. **Phase 5's output was APPLIED, not restated.** `negFixOneTail` is
   `negBoundedLeftFixAnchoredFaithful p (BracketFormula.trivial s1)` — Cor 5.4(2) at the anchor
   `α₁ = p`, used on **two** intervals: `(z₀,z₁)` in Case 2 and the shrunken `(z₀,r₀)` in Case 3c.
4. **Phase 3's `VVecEA2.concatPin` and `conjEverywhere` were both consumed for the first time.**
   Case 3's arms are `concatPin` around the eq (5.3) pin; `Cond₂` rides in via `conjEverywhere`.

## Measured results (actual, not asserted)

| Gate | After Phase 5 | After Phase 6 |
|---|---|---|
| `lake build` exit | 0 | **0** |
| Jobs | 1888 | **1889** (+1) |
| Live modules from `FormalSystem.lean` | 274 | **275** (+1) |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** |
| `AggregateOffDiagK1` explicit build | 1098 jobs, EXIT 0 | **1098 jobs, EXIT 0** |

Census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. Liveness by
transitive `import` walk from `FormalSystem.lean`; `lake build BoneyardArchive` never run or cited.
All 15 new declarations verify as `[propext, Classical.choice, Quot.sound]` (or the strict subset
`[propext]` for `HasDedekindINF.first_occ_tp`) — no `sorryAx`.

The bare `grep -c '^axiom ' FormalSystem/` count is still **2**, both prose continuation lines
inside `Boneyard/` comments (`Boneyard/DiscreteXY/Discreteness.lean:40`;
`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:1233`). Neither is a declaration. Real
axiom count: 0. Carry this note forward; it recurs every phase.

The four call sites `NegFixOne.lean:224`/`:243`/`:272`/`:276` were re-confirmed independently by
`grep` before any editing and had **not** drifted.

Note for Phase 7 on job counting: the probe needs `Mathlib.Data.Real.Basic` and
`Mathlib.Tactic.Linarith`. Both were already in the build's transitive closure, so the job delta is
still exactly +1. A future module adding a Mathlib import outside that closure would not be.

## Deviations

See the plan's Phase 6 section for the full text. Summary: (1) the faithful `n = 1` negation is
Rabinovich's three-case split rather than the six-disjunct attained list with carriers swapped —
raised, with the `ℝ` probe as machine-checked evidence that the prescribed route is impossible,
not merely different; (2) `HasDedekindSUP` not consumed, third consecutive drop, reported above.
Plus one strict-superset addition (the probe itself).

## Sizing

Closed in one agent run. Three-strikes guard did not fire; no re-split boundary needed.
