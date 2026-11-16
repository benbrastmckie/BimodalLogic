# Round 21 — the refutation attempt on the filed `cellAt_const_of_kappa_eq`: verdict

**Verdict: outcome (b) — OPEN WITH A MEASURED ACCOUNT.** The filed statement is NOT refuted and
it is not proved. This is not outcome (a) and must not be cited as a refutation.

**Where it is compiled.** `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`,
second section (`# THE REFUTATION ATTEMPT ON THE FILED AGREEMENT, AND ITS VERDICT`), appended
after the probe's original `end Probe761C`; nothing above it is edited. Zero `sorry`.

## What was attempted

Plan v21 Phase 11.29 predicted: the countdown is a function of the pend profile
(`cntAt_eq_of_pend_eq`), the fixture's pending bit is a readable atom (`pendFactorsLabC`), so a
formula recording how long the pending bit is held separates two `kappa`-equal ladder states
with different countdowns.

The candidate was stated first: `sepC k := X^(k+1) ¬p` (`X ψ := untl ⊥ ψ`, the strict until), and
its `⊡`-prefixed sibling `stabSepC k := ⊡ (sepC k)`.

## What closed

| Step | Declaration | Result |
|------|-------------|--------|
| Positive membership at countdown `k` | `sepC_mem_of_cnt_eq` | CLOSED |
| Negative membership at every countdown `c' > k` | `sepC_not_mem_of_lt_cnt` | CLOSED |
| The two cells differ | `sepC_cell_ne`, `stabSepC_cell_ne` | CLOSED |

So the mechanism is real: the separating type is exhibited and both memberships compile.

## The step that fails, and the goal state

The step that fails is the INSTANTIATION of the separated pair at a `kappa`-collision under
`ParamsOk`. The goal reached was, with `hp : ParamsOk stepC pendC labC (sepC k) Tc Tn P B` and
`hk : kappa Tc Tn P B (k, n) = kappa Tc Tn P B (c', n')` in context:

```
⊢ k < c'
```

(the hypothesis `sepC_cell_ne` needs). It does not merely fail to close; its negation compiles:

- `lt_Tc_of_closure_card`: under `ParamsOk` at ANY formula `φ`, `card (closure φ) < Tc`. Source:
  (K2)'s margin conjunct `card Q * 2 ^ card (closure φ) * (P + 1) * (D + 1) ≤ Tc`.
- `sepC_closure_card`: `k + 2 ≤ card (closure (sepC k))`.
- `sepC_no_collision` / `stabSepC_no_collision`: hence `c' = k` — `kappa`'s first coordinate
  `min c Tc` is injective below `Tc`, and every countdown the formula records is below `Tc`.
- `sepC_cell_eq`: at countdowns `≥ k` the cell of `sepC k` reads `min c (k + 1)` only.
- `sepC_agreement_at_collision`: at EVERY collision with countdown `≥ k` under `ParamsOk` at
  `sepC k`, the two cells are EQUAL.

In one statement: `round_one_verdict`.

## What would have to be true for the refutation to close

A formula `φ` whose cell distinguishes two countdowns BOTH `≥ Tc` (or two registers both `≥ Tn`,
or two gaps both clipped at `B`) for parameters satisfying `ParamsOk` at `φ` itself — i.e. a
formula that reads a countdown above `2 ^ card (closure φ)`. The `X`-chain family cannot, nor can
its `⊡`-prefixed sibling. The target is stated, undecided, as `RefutationTargetC`.

**Not established**: that no formula can. The families tried are box-free, `⊡`-depth ≤ 1, on one
two-state object, at world state `(0, x)` and time `0`. An informal reading (not compiled): on
this object a history through `⟨(0, c, n), _⟩` is `p` for exactly `c` more steps, and a formula
whose temporal reach is bounded by its closure size cannot count past it; `until` reaches the
region's END without measuring its length; `⊡` reads the state, whose observable content at a
large countdown is the gap `n - c` in a bounded window. That is an argument for why the attempt
found nothing, not a proof of the agreement.

## Consequence for the route

Decision entry (E-5) routes outcome (b) to Round 3, the non-atom-preserving count move (Phase
11.32). This round already lands an instance of it: `exists_non_atom_preserving_count_move` —
two ladder paths at different countdowns `c ≠ c'` (both `> k`) realizing the SAME `sepC k` type
with atom rows that DIFFER at position `min c c' + 1`. The rows differ beyond the formula's
reach. It is one formula family on one object with explicit paths; it is not a general
construction, and the general form (reach of an arbitrary closure vs. the margin) is what Round 3
would have to state.

## Deviations from the phase as written

- The plan asked for the two membership goals as `sorry`-bodied signatures first and, on outcome
  (b), exactly one `sorry` left on the unclosed membership. Neither membership was left unclosed —
  both compile — and the failing step is a refuted instantiation, so no `sorry` exists anywhere;
  the undecided target is carried as the `def RefutationTargetC : Prop` instead.
- Scope hypothesis ("ONE formula, ONE headline theorem"): exceeded. Two formulas (`sepC`,
  `stabSepC`) and fourteen printed theorems, still in the one fixture, no new file, no library
  declaration.

---

# Round 3 — the non-atom-preserving count move (Phase 11.32): construction NOT built, account compiled

**Status: [BLOCKED].** The general construction — for arbitrary `Q`, arbitrary `φ` (with `⊡`) and
an arbitrary `kappa`-collision, a ladder path through the other state realizing the same closure
type — is NOT built. The filed `cellAt_const_of_kappa_eq` stays OPEN. Nothing is promoted into
`LadderRealize.lean`; no library declaration is added.

**Where it is compiled.** Third section of
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`
(`# THE COUNT MOVE THE AGREEMENT NEEDS: ITS TYPE, A TRANSFER PRINCIPLE FOR IT, AND WHERE IT
REFUSES`), appended after the second section's `end Probe761C`; nothing above it is edited. Zero
`sorry`. Fifteen printed theorems, axioms `[propext, Quot.sound]` or
`[propext, Classical.choice, Quot.sound]`.

## The sentence the phase is anchored on

> "two ladder paths can realize the same closure type without agreeing on a single atom row, so
> the obligation can be met by a construction that does not preserve the valuation pointwise. No
> such construction is stated anywhere in the tree and none is supplied here."

## The construction's type (stated first, as the phase requires)

| Object | Declaration | Status |
|--------|-------------|--------|
| The count move, no atom-row clause | `TypePreservingCountMove` | STATED |
| Move ⇔ diagonal cell agreement at every collision | `typePreservingCountMove_iff_cellAt_const` | PROVED |
| The rows must differ when the countdowns do | `countMove_rows_differ` | PROVED |
| The move at the two-state object, every `φ`, every `ParamsOk` tuple | `CountMoveTargetC` | STATED, UNDECIDED |

The phase asked for `sorry`-bodied signatures; the undecided target is carried as a `def … : Prop`
instead, because a `sorry` in a wired probe is a gate question and the equivalence above already
makes the target an object.

## What was built toward it

1. **A transfer principle that is not positionwise** (`TransferSys`, `truth_iff_of_transferSys`).
   A depth-indexed family of relations between points of two histories, one back-and-forth clause
   per operator; the temporal clauses match intermediate points by SOME intermediate point; the
   `⊡` clauses match a history through one state by a history through the other. Related points
   satisfy the same formulas up to the level's operator depth, for the whole language.
   `typePreservingCountMove_of_transferSys`: the count move follows from any such system plus one
   link per collision. This is the first tool in the tree that can relate two ladder paths whose
   positions do not correspond — the shape `no_positionwise_lift` leaves open.
2. **Instances.** The time shift, whole language (`shiftR_transferSys`). The slide inside a
   stretch carrying one atom row (`slideR_transferSys`, `tpOf_eq_of_homStretch`) — closures with
   no `⊡`/`□` member. The slide closure of ANY whole-language system under the state link
   (`slide_closure_transferSys`, `tpOf_eq_of_linkedStretch`), with an unconditional corollary
   where the link is free (`tpOf_eq_of_constStretch`, a history resting in one world state).
3. **A count move for every history, not an exhibited walk** (`slide_count_move_C`): at the
   two-state object, any ladder path pending on the `d + D` positions before `0` with countdown at
   least `D` at `0` (`D` the closure's operator depth) realizes at `-d`, where its countdown is
   `c + d`, the type it realizes at `0`. This generalizes `exists_non_atom_preserving_count_move`
   from one formula family on explicit walks to every closure without `⊡`/`□` on arbitrary paths.
   **It carries a `⊡`-free premise and is therefore NOT the construction**; it is recorded as a
   fragment instance of the transfer principle. The phase's own verification grep
   (`hno|stabFree|AtomPreservingCountMove`) hits `hnos`/`hnob`, `allowed_of_stabBoxFree` and
   `stabBoxFree_of_mem_closure` on exactly `tpOf_eq_of_homStretch`, `slide_count_move_C` and the
   helper that serves them; no hit is on the construction's type, the transfer theorem, the slide
   closure or the cap.

## The refusing coordinate, the pairs, and the inequality

**Coordinate: the PAST pending row.** Every prior measurement located the count move's obstruction
in the future (the exit position moves with the countdown). The slide shows the future half is
harmless once the path is deep in its run. What refuses is the past:

```
cnt_cap_of_row :
  cntAt g z + (z - e - 1) ≤ (x₀ - e₀ - 1) + (e - e₀)
```

for `e₀` idle, `(e₀, x₀]` a pending region with `x₀ + 1` idle, `e ≥ x₀ + 1` idle, `(e, z]`
pending. In words: the entry register of the region containing `z` is at most the previous
region's length less one, plus the number of steps between the two entries. The right side is a
function of the pending row on `[e₀, z]` alone.

**Pairs: every collision that raises a countdown past the cap.**
`exists_past_row_change_of_cap_lt`: a ladder path whose countdown at `z` exceeds the cap another
path's row sets there differs from that path's pending row somewhere in `[e₀, z]`.
`tight_state_refuses_C`: for every `m` there is a ladder path at the two-state object with
countdown `2 m + 2` at position `m + 3` attaining the cap, so EVERY ladder path with a larger
countdown there rewrites the window `[0, m + 3]`. `m` is unbounded, so the pairs include
collisions of every counter quotient at every parameter tuple.

**Goal state at which the construction stops.** With `g` through `⟨(q, c, n), h⟩`, the collision
`hk`, `c < c'`, and the cap attained on `g`:

```
⊢ ∃ g' τ', IsLadderPath step pend g' ∧ g' 0 = ⟨(q, c', n'), h'⟩ ∧ (∀ t, τ'.state t = (t, g' t)) ∧
    tpOf (ladderModel step pend fwd bwd lab) φ τ' 0 = tpOf (ladderModel step pend fwd bwd lab) φ τ 0
```

with the compiled side fact that any such `g'` differs from `g`'s pending row inside the two
regions before `0`. No landed tool produces a `g'` whose past row differs from `g`'s and whose
type at `0` is `g`'s.

## Why the past half does not close with what exists (argued, NOT compiled)

Lengthening the previous region by `x` raises the current region's admissible entry register by up
to `2x`, but raises the previous region's OWN entry register by `x`, which can bind the cap one
region earlier. The cascade halves the demand at each step and terminates when a region has slack
or an idle stretch is long enough to lengthen invisibly. It does not terminate on a history whose
regions double exactly from a short one (`1, 3, 7, 15, …` at single idle separators, the family
`tight_state_refuses_C` is the two-region case of): the bottom region is too short to lengthen
without changing a small-depth type. On such a history the only type-preserving way to reach a
higher countdown is to INSERT A WHOLE REGION into the chain. That is sound only if the chain below
a countdown at or above `Tc` has more regions than a formula of that closure can count; (K2)'s
margin `2 ^ card (closure φ) ≤ Tc` is the available source of that inequality (a chain reaching
`Tc` by doubling from a region the formula can measure has about `card (closure φ)` steps, and
counting one region costs several closure members), and it is NOT checked here. Either way it is an
indistinguishability of two histories whose region SEQUENCES differ, and no landed object states
it.

Independently, at a closure carrying `⊡` the slide owes `StateLinked`: the states
`(q, c - i, n_i)` along the run must answer each other's histories one level down. Two such
states with the same countdown and different registers have different exit-register windows, so
linking them again requires reshaping LATER regions (shortening the next region to fit the smaller
window, then every region after it that the doubling bound makes dependent). Same object: a
transfer system between histories whose region lengths differ at infinitely many regions.

## What would unblock it

One object, in the form `TransferSys` already fixes: a whole-language transfer system on ladder
histories that relates a history to one obtained by (a) changing the lengths of regions above a
depth-indexed threshold, at infinitely many regions, and (b) inserting or deleting whole regions in
a chain longer than the level, with (c) the `⊡` clause discharged by induction on the level through
the state relation the system itself induces. On the two-state object the path side of (a) is
elementary (deleting the first `L - M` positions of each region longer than `M` and clipping the
register at `M - 1` is again a ladder path — checked by hand in this round, not compiled); the
relation side is the work. On a general object the deletions must also respect the object's cycle
structure, which is what (K1) is for.

This is a route question for a `/revise`: the phase's Scope Hypothesis ("ONE construction, built in
the fixture first and promoted once") does not hold — the construction is a theory, not a lemma.

## Deviations from the phase as written

- `sorry`-bodied signatures first: not done; the undecided target is `def CountMoveTargetC : Prop`.
- "Promote into `LadderRealize.lean` and derive the agreement at the filed signature": not done —
  the fixture does not carry the construction, so the promotion gate is not met.
- Scope Hypothesis exceeded: the section adds four definitions of relations/predicates
  (`TransferSys`, `ShiftR`, `SlideR`, `StateLinked`), not one construction. Still one fixture, no
  new file, no library module.
- A fragment instance with a `⊡`-free premise is present (item 3 above) and is labelled as not
  being the construction.

# Round 4 — the gap coordinate (dispatch 62): the filed agreement is REFUTED

**Status: outcome (a).** `RefutationTargetC` HOLDS; `CountMoveTargetC` is FALSE; the statement
filed as `cellAt_const_of_kappa_eq` is false with its quantifiers, and `ladderRealized` with it.
The Round 1 verdict above ("NOT REFUTED") and the Round 3 status ("stays OPEN") describe the
countdown coordinate and are superseded on the truth value; their measurements stand.

**Where it is compiled.** Fourth section of
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`
(`# THE FILED AGREEMENT IS REFUTED: THE GAP CLIP OF (K4) IS TOO SMALL, BY AN UNBOUNDED AMOUNT`),
appended; nothing above it is edited. Zero `sorry`. Eighteen printed theorems, axioms
`[propext, Quot.sound]` or `[propext, Classical.choice, Quot.sound]`.

## The mechanism

Rounds 1 and 3 read the countdown `c`, which (K2)'s margin `2 ^ card (closure φ) ≤ Tc` puts out of
reach. The gap `n - c` is `kappa`'s fifth coordinate, clipped to `[-B, B]`, and (K4) asks only
`2 * dBack φ + 1 ≤ B`, `2 * dFwd φ + 1 ≤ B`, `2 ≤ B` — linear in the LARGER of two nesting
depths, with no margin. At a pending state `(c, n)`:

1. a history through it has an idle position in its past only if `c ≤ n + 1`
   (`cnt_le_nxt_succ_of_past_idle`);
2. one step forward the gap rises by up to `2`, one step backward it falls by up to `2`;
3. `⊡` re-chooses the history at each state.

## The separating objects

| Object | Declaration | Content |
|--------|-------------|---------|
| Formula | `thetaC := ⊡ X ⊡ ¬ P ¬p` | `dBack = dFwd = 1`, `Bof = 3` (`Bof_thetaC`) |
| Out of the cell at gap `-3` | `thetaC_not_mem` | state `(n + 3, n)`; witness histories built by `gluePath` |
| In the cell at gap `≤ -4` | `thetaC_mem` | every state `(c, n)`, `n + 4 ≤ c` |
| Collision | `kappa_collision_theta` | `(Tc + 3, Tc)` vs `(Tc + 3 + (P + 1), Tc)` at clip `3`, every `Tc Tn P` |
| Headline | `refutationTargetC_holds` | at `Tcof/Tnof/Pof/Bof` of `thetaC`, `paramsOk_params` |
| Filed schema | `cellAt_const_of_kappa_eq_schema_refuted` | the filed quantifier prefix, negated |
| Count move | `not_countMoveTargetC` | |
| Fibre equation | `no_fibre_equation_over_kappa` | no function of the class equals the cell |
| Transfer systems | `no_transferSys_links_collisions` | the (T-1) verdict object |
| Certificate | `certStabK_fails_of_contains_realized` | condition (5) fails on every set containing the realized triples, clip `3` |
| Unbounded excess | `mixC_refutes` | `mixC (k + 2) k`: clip `2 k + 5`, separated gap `3 k + 4`, every `k ≥ 1` |

## What is NOT settled

- Whether a larger clip makes the agreement true. Both families are defeated by
  `B ≥ 2 * (dBack φ + dFwd φ) + 2`. That bound is a READING of the two families, not a theorem:
  no proof of the agreement at any clip exists. Further amplification through `⊡` alternation was
  looked for by hand and not found (the gap is monotone in time along one history, `until`/`since`
  jumps saturate), and that search is argued, not compiled.
- The tight family of Round 3: its gaps are in `{-1, 0, 1}`, inside every clip. Decision (T-1)'s
  literal obligation — a verdict AT that family — is not discharged; what is compiled is that no
  `TransferSys` links ALL collisions at the filed parameters.
- `ladderSound`, `ladderLift`, `ladderCons_localRun`: not refuted. `certStabK_fails_of_contains_realized`
  says the set of realized triples is not certified at the clip `3`, which is the route by which
  `ladderSound` was to be proved (`Real ⊆ Dmax` through `Real`'s own certification); it does not
  say `Dmax` misses a realized triple.

## Consequence for the route

Decision (E-5) pre-assigned outcome (a) to Round 2 (the run-level adequacy pair) on the premise
that "the parameter axis is already spent" and that the failure would be `kappa`'s incompleteness
as an invariant. The refutation found is of a different kind: a parameter SOURCE is wrong ((K4)'s
clip), and the certificate's condition (5) fails at the same place, so the soundness leg of the
run-level pair inherits the defect unrepaired. Phases 11.30/11.31 were therefore not entered and
a route decision is returned.

## Deviations

- Dispatch 62 was an implement dispatch on a plan whose recorded next step was a research round
  and a `/revise`. The (T-1) measurement was run inside Phase 11.32's file scope.
- Phase 11.29's outcome-(a) task "land the library-side statement in `LadderRealize.lean`" is not
  done: it needs the two-state object in the library, and which statement the library should
  carry is the route question.
- `docs/theorem-index.md`, `LadderCell.lean`'s decision docstring, one docstring sentence of
  `LadderRealize.lean` and two sentences of the RaySummary README were corrected from OPEN to
  REFUTED; no library declaration was added or changed.
