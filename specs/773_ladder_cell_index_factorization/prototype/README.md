# Prototype findings: the gap-carrying cell index

`gap-index-test.lean` — 520 lines, compiles under `lake env lean` at exit 0 with no warnings and
no `sorry`; the six new theorems carry only `[propext, Quot.sound]` or
`[propext, Classical.choice, Quot.sound]`. The fixture (object `Q = Bool`, `pendB = id`,
`stepB ≡ true`, `phi := p U (r ∧ X(p ∧ X r))`) is copied VERBATIM from
`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` so every verdict below is
directly comparable with that probe's refutation. This is a prototype, not a wired probe: it is
not registered in `scripts/check-evidence-probes.sh`.

Run before the general proof is attempted, to decide the direction rather than discover it late.

## A — the gap is genuinely unbounded (`gap_step_pending`)

`Count true true` forces `c' + 1 = c` while `Drift` moves the next deadline by at most one, so
across a pending→pending step the gap `n - c` satisfies

```
gap' ∈ {gap, gap + 1, gap + 2}
```

It is non-decreasing, and rises by up to two per step. Over a region of length `c₀` it reaches
`g₀ + 2·c₀`, and `c₀` is unbounded on the carrier. **The drift risk is confirmed as fact**, and
general in the object — no fixture is involved.

## B — but the refutation does not iterate upward (`phi_blind_above_two`)

This is the finding that matters, and it points the opposite way from what A suggests.

`not_phi_of_gap_two` generalises verbatim to every gap `≥ 2` (`not_phi_of_gap_ge_two`): the
region still runs to `0` at `B`, the idle state at `B + 1` still carries `1 ≤ n`, and the next
region still has length at least two, so `r ∧ X(p ∧ X r)` fails at the seam. Hence `phi` is
absent from every type realised at every gap `≥ 2`, so for any `j, j' ≥ 2` it cannot tell gap `j`
from gap `j'` (`phi_blind_above_two`). The separation in `cell_ne` is real but confined: gap 1
against gap `≥ 2`, with no finer distinction above 2 (`cell_ne_gap_ge_two`).

**So the two-coordinate index did not fail because the gap is unbounded.** It failed by
destroying a SMALL gap at LARGE counter values — clipping `c` and `n` independently maps
`(B, B+1)` and `(B, B+2)` together, and those are exactly the two gaps this `phi` can see. A's
unboundedness is therefore not an obstruction to the gap-carrying index, and the sub-problem is
not deeper than three coordinates for this reason.

Consequence for the candidate: **the gap coordinate's clip bound must come from `phi` — its
`X`-nesting depth, or `|cl phi|` — never from the counters.** A fixed formula resolves region
lengths only up to its own nesting depth; beyond that all gaps look alike, which is precisely
what makes a finite clip sound.

Honest limit of this result: one formula, one fixture. It establishes that the KNOWN refutation
does not lift to large gaps. It does not prove the general factorization lemma, and a formula
with deeper `X`-nesting distinguishes correspondingly larger gaps — which is the reason the bound
has to be `phi`-dependent rather than absolute.

## C — a second route: bound the carrier instead of indexing it

`count_le_max`: in every branch of `Count`, `c' ≤ max c n` — pending→pending decrements, a region
start copies `n`, an idle target zeroes. `rlad_counters_bdd`: if both counters start `≤ N`, the
successor's countdown is `≤ N`. `drift_refl`: `Drift n n` always holds, so bounding `n` never
obstructs the next-deadline clause.

Together: **the only thing that can grow either counter is `Drift`'s `n' = n + 1`**, and the
sub-carrier `{x // Adm ∧ c ≤ N ∧ n ≤ N}` is closed under `Rlad`. On that sub-carrier the carrier
is a `Fintype` outright — `Q × Fin (N+1) × Fin (N+1)` — and the index problem does not arise at
all.

What this route costs instead: seriality becomes a sharper object condition (backward seriality
at a pending state with `c' = N` needs a region-start predecessor, since `c = c' + 1` would leave
the bound), and the real question becomes the standard finite-model-property one — does every
refutable `phi` have a refuting ladder object whose deadlines are `≤ N(phi)`? That is a
better-shaped question than indexing an infinite carrier, and it is where the effort should go if
the factorization lemma resists.

## Suggested order of work

1. Define `ladderIndex` with the gap coordinate clipped at a `phi`-derived bound (B above, not a
   counter-derived one) and attempt the factorization lemma.
2. In parallel, test route C's premise: is there an `N` syntactic in `phi` bounding the deadlines
   of some refuting object? If yes, C dissolves the problem and is strictly cheaper.
3. Only if both resist: the sub-problem is deeper than three coordinates, and A is then the
   reason to suspect no fixed-arity index exists.
