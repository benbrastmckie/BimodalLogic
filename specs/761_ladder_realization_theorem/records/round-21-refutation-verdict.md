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
