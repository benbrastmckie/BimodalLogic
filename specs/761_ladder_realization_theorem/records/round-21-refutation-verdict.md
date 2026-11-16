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
