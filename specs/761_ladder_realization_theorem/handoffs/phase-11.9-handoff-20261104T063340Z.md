# Phase 11.9 Handoff — The Tight-Chain Decision Gate

- **Phase**: 11.9 (plans/09_tight-chain-gate-regated-graph.md) — closed `[COMPLETED WITH EXCLUSIONS]`
- **Verdict**: **INCONCLUSIVE** (of the three branches the phase defines)
- **Dispatch**: seq 26, session `sess_1793770123_ca991a`

## Immediate next action

A `/revise` is the route. It has three concrete inputs from this phase: the two statement repairs
to the recorded probe block (`0 < m`, and the lifting form in place of the register-specific one),
the object correction (the chain's pins must be unbounded above), and the wiring of the landed
480-line probe into `scripts/check-evidence-probes.sh`, which the INCONCLUSIVE branch forbade this
dispatch to touch and which leaves the probe unprotected until it happens.

## What landed

`specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean`, 480 lines,
namespace `Probe761T`, compiling standalone through the build guard with every headline theorem at
`[propext, Classical.choice, Quot.sound]`. NOT wired into the evidence gate (the branch's own
instruction); `git status --short FormalSystem/ Tests/ scripts/` is empty.

The headline result — the claim the live `RaySummary/README.md` records as ARGUED rather than
compiled, now compiled, and in a form strictly stronger than the recorded statement:

```lean
theorem tightChain_positive_deletion_does_not_lift (a : ℤ) (ha : 4 ≤ a) (L : ℕ) (hL : 0 < L) :
    ¬ ∃ g : ℤ → LadderState Qc pendC, IsLadderPath stepC pendC g ∧
        (∀ v, objAt g v = delObj a L v)
```

No ladder path WHATSOEVER has the deleted object walk: the countdown and the register are both
existentially quantified away. Plus `tightChain_iter_deletion_does_not_lift` (the iterated shape)
and `tightChain_deletion_derivative_does_not_lift` (at the gate's own hypothesis
`Tcof … ≤ cntAt tightChain z`, with `two_le_Tcof` and `three_le_of_two_le_cT` deriving the
placement of `z` from it), and the chain's own facts: `tightChain_isLadderPath`,
`tightChain_pins`, `tightChain_slack_zero`, `paramsOk_chain`, `stabFree_chiT`.

**The mechanism**, so a successor need not re-derive it: two pins of the DELETED walk on opposite
sides of the deletion. The pin at `0`, whose region is the single position `1`, lies entirely
below the deletion and survives with countdown `0`. A pin `2^j - 2 - L`, whose region lies
entirely above the deletion, survives with the chain's own countdown `2^j - 2`. The distance
between them has fallen by exactly `L` while their countdown difference has not moved at all, and
`pinCompat_of_ladderPath` (`LadderAgree.lean`) proves pairwise compatibility of region-start
countdowns NECESSARY for any ladder path. No type, no parameter condition and no certificate
object enters.

## Why the verdict is INCONCLUSIVE and not REFUTED

The REFUTED branch needs `cellLEZeroConstOfKappaEq_refuted` and `exists_refuting_tight_collision`
to close with the non-liftability. Neither was attempted, and the reason is a precise gap, not
fatigue: a cell equality at a `kappa`-collision asks that every type realized at the first state
be realized at the second by SOME ladder path through it, and nothing makes that path a
deletion-derivative of the chain — the cell quantifies over every history through the state. What
is owed is a closure formula whose letters FORCE the realizing path to be a deletion-derivative.
Two compiled facts constrain that choice: the schema is refuted at the frozen `ParamsOkPre` whose
`(K4)` reads the backward depth alone, while under `ParamsOk` the same probe's `not_paramsOkK4_two`
and `kappa_D_dissolves` show the two-depth predicate rejects that clip and dissolves that
collision. And an `atom`-level formula is no use: the closure of `atom p` has one member, so its
cell depends on the object state alone and the schema HOLDS for it.

## Three statement-level findings (reported, not worked around)

1. The recorded `tightChain_deletion_derivative_not_ladderPath` is **false at `m = 0`** — the
   derivative deletes nothing and IS the chain. It needs `0 < m`.
2. Its conclusion `¬ IsLadderPath step pend (delIterWalk …)` is **register-specific**, so weaker
   than the record's own claim that the derivative does not LIFT.
3. The object must be the chain with **pins unbounded above**. On the archived prototype's
   finite-`J` chain the last region carries no pin above it, so deleting from it moves no later
   pin and the `1`-Lipschitz condition admits it: a finite-`J` chain HAS a lifting
   deletion-derivative and the claim is false there.

The recorded block was left byte-identical on all three counts; the landed theorems carry honest
names of their own.

## Verification at close

Probe compiles standalone: exit 0, zero `error:`, zero `sorry`. `#print axioms` on all eight
headline theorems: `[propext, Classical.choice, Quot.sound]`. No library or script file changed.
`check-evidence-probes.sh` exits 0, still 47 wired probes. `check-task-references.sh --quiet`
exits 0. `typst-sync-check.sh` exits 0 and did not move. Full `lake build`: exit 0, 0 errors, 0
warnings, 2,895 jobs. `check-module-invariants.sh` still exits 1 on the same single pre-existing
`C16` finding in `LadderChain.lean`.
