# Phase 7.6 — Invariant preservation across `c5_forward_walk` (R3d-2)

- **Task**: 408 (faithful route to strong completeness for the Dedekind extension)
- **Plan**: `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/06_strong-completeness-dedekind-v6.md`, Phase 7.6
- **Status**: `[COMPLETED]`, sorry-free
- **Session**: `sess_1785243543_9dde88`
- **Commits**: `0998e1685` (implementation), plus the artifact commit recorded below

## Outcome

`C5ForwardWalkResult` now carries the guard-accumulation preservation content, discharged in all
three of Burgess's cases, sorry-free, with the full project build green.

### Route taken in the split case: **(a), preservation as-is**

Burgess's midpoint placement is **unchanged**. No `PointInsertion.lean` edit, no `h_actual`-style
witness reuse, no new placement rule, no closure enlargement. Route (b) was not taken and no
departure from Burgess's placement was made, so the "departure" docstring requirement does not
arise. The split case discharges the new field *vacuously*, and for the structural reason the plan
anticipated: the witness is the midpoint of the adjacent pair `(start, x')`, so the open interval
`(start, witness)` of the extended domain contains no old point (by adjacency) and no new point
(the midpoint is the only insertion and is itself the witness).

## What landed

All three declarations are in
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`, inside the
forward-walk region only.

### 1. `C5ForwardWalkResult.guard_interval` (new field) — the non-free content

```
guard_interval : ∀ w ∈ val.dom, start < w → w < witness → ξ ∈ val.f w
```

Every point of the **result** domain strictly between `start` and the witness carries the guard.
This strengthens the existing `domain_guard`, which quantifies only over the **original** domain
`χ.dom`, to the domain the walk actually produces — which is the form the limit step needs, since
the limit domain is a union of result domains, not of input domains.

Discharged in the three cases:

| Case | Discharge |
|---|---|
| Base (`start = max dom`) | Vacuous: the only new point is the witness itself, and no old point lies above `start` |
| Condition (i) | `x'` carries `ξ` by `conj_left_mcs` from the condition-(i) conjunction; points above `x'` come from the recursive instance of the field; nothing lies strictly between `start` and `x'` (old points by adjacency of `(start, x')`, new points by `new_point_after` at `x'`) |
| Split | Vacuous: the witness is the midpoint of the adjacent pair `(start, x')` |

The field is genuinely constraining rather than decorative: it is exactly the condition-(i) branch
check that makes it hold. A variant walk that recursed past `x'` **without** the
`ξ ∧ U(ξ,η) ∈ f(x')` test would falsify it. That is the falsifiability witness for the field.

### 2. `C5ForwardWalkResult.guard_accum_preserved` (new field) — landed, and honestly labelled

```
guard_accum_preserved : ∀ G : Set Formula,
  NoGuardAccumulation (↑χ.dom) χ.f G → NoGuardAccumulation (↑val.dom) val.f G
```

The literal preservation statement the plan's Task 1 specifies, in the invariant's landed form,
with no restatement and no weakening.

**Deviation of substance, reported rather than papered over.** A chronicle domain is a `Finset`,
so this conclusion is discharged outright by 7.5's `noGuardAccumulation_of_finite` — the
hypothesis is never used, and the field carries **no stage-level content of its own**. This is
stated plainly in the field's own docstring, not only here. The field is nevertheless landed as
the plan specifies, because the ω-chain limit step needs a uniformly named preservation handle
across the two walks and the elimination step, and stating it here fixes the exact form that
handle must take. No plan step was skipped, altered, or substituted: this is the specified field
plus an honesty note plus the additional non-free field above.

This confirms, from the construction side, the finding recorded in the Phase 7.5 handoff: the
residual risk of the whole R3d arc sits in the **limit** step (7.8/7.9), not in the finite stages.

### 3. `C5ForwardWalkResult.no_guard_failure_below_witness` (new public theorem)

```
theorem C5ForwardWalkResult.no_guard_failure_below_witness ... :
  Formula.neg ξ ∉ r.val.f w
```

The accumulation reading of `guard_interval`, obtained via consistency of each `val.f w` (from
`c0`) and `set_consistent_not_both`. It is public (the walk itself is `private`, so consumers need
this handle rather than the `def`).

## Adversarial verification (H4) and the family-`Q` falsification check

`familyQ_violates_noGuardAccumulation` is the standing falsification target. Family `Q`'s shape
requires guard-failure points (`¬¬P`) cofinal below a gap while `U(P, ¬P)` holds at every rational
below it.

**Check result: a single forward walk cannot lay down the family-`Q` pattern inside the interval
it opens.** `no_guard_failure_below_witness` says exactly that the open interval `(start, witness)`
of the result domain is guard-failure free, so no `¬ψ`-point of a would-be accumulating set can sit
in it. This is a landed theorem, not a prose claim.

**What the check does *not* establish, stated so it is not over-read.** It bounds one walk at one
stage. It does not exclude the residual pattern where the intervals opened by *successive* stages
are squeezed toward a gap while guard failures accumulate in their complements. That gap-side
question is 7.8's, and it is precisely why 7.8's induction cannot be a routine
preserved-at-each-step argument and must produce a bound uniform in the stage — the point carried
forward from 7.5.

No `FamilyQShape` instance is extractable from a walk result (the walk's domain is finite), so no
lemma tying the two was manufactured; inventing one would have required an unsatisfiable antecedent
and would itself have been a vacuous declaration.

## Honesty charter compliance

- Every new declaration carries the **no-source** statement in its docstring.
- The only adapted-from citation used is **ADAPTED-FROM Burgess 1982 I §2.10, printed
  pp.372-373** (the fresh-point witness placement whose interval behaviour is recorded), with the
  printed pages, and with the explicit note that Burgess states no such property because his
  construction never reaches a gap.
- Reynolds 1992 is not cited anywhere in this phase — nothing here discharges a Reynolds
  statement.
- No task-number citation appears in any file outside `specs/`.

## Verification

| Gate | Result |
|---|---|
| Scoped build | `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.CounterexampleElimination` — **green**, "Build completed successfully (1108 jobs)" |
| Full build | `lake build` — **green**, "Build completed successfully (1907 jobs)" |
| Live sorries outside `Boneyard/` | exactly one, `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` — baseline **unchanged** |
| New sorries | none |
| `#print axioms` on `no_guard_failure_below_witness` | `[propext, Classical.choice, Quot.sound]` — no `sorryAx` |
| Six statements frozen by Amendment 2 | untouched (`git diff` over the phase range returns no matching line) |
| `ChronicleTypes.lean`, `ChronicleToCountermodelBasic.lean` | byte-identical (not in the diff) |
| `ChronicleGuardAccumulation.lean` | untouched — consumed, not edited |
| `PointInsertion.lean`, `cantorIsoDense` | untouched |
| Territory | the concurrent Decidability/Automation work was never staged or touched |

## Files touched

- `FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (+109 / -2):
  one import line, two structure fields with proofs in three branches, one public theorem.
- Plan and summary artifacts under `specs/408_.../`.

## Next dispatch target

**Phase 7.7** — the mirror of this phase across `c5_backward_walk`. It is a mirror, not a copy:
the guard interval reverses to `(witness, pt)`, the insertion primitives are the Since-side ones,
and the field it adds must be the **same** below-accumulation invariant, not an above-accumulation
mirror. 7.7 may consume this phase's `guard_interval`, `guard_accum_preserved`, and
`no_guard_failure_below_witness` as landed. The `[COMPLETED]` marking of Phase 7.6 does **not**
release the Phase 8 gate, which remains bound to 7.9.
