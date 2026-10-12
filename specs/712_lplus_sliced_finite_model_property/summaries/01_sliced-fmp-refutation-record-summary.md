# L⁺ Sliced Finite Model Property — Refutation Record

**Closed as a refutation record**, not as completed work and not as abandoned. The statement this
record was filed to hold open is machine-checked FALSE, and the refutation is landed as a
`FormalSystem/` library theorem. `[ABANDONED]` was rejected by user ruling: the question was
answered, and a reader deserves the answer.

## The statement that was held open

> Every ℤ-time non-validity of a `PlusFormula` admits a tail-stable sliced certificate meeting
> its `Certifies` predicate.

Together with the soundness theorem and the decidable checker, this would have yielded
decidability of L⁺ ℤ-time validity — the result the L⁺ completeness programme existed to reach.

## The refutation, and why it is this statement

`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean`, namespace
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth`:

| Theorem | Statement |
|---------|-----------|
| `not_sliced_complete` | `¬ ∀ ψ : PlusFormula, ¬ PlusValidZTime ψ → ∃ G : PlusSlicedCertificate [] [ψ], G.Certifies` |
| `not_finite_width_fmp` | no certificate class presenting finite per-time fibres is complete, whatever its clauses |

`not_sliced_complete` is the direct negation of the held-open statement. The identification is
exact on all three of its load-bearing parts:

- **Tail-stability is inside the refuted scope.** `Certifies` (`PlusSlicedCertificate/Check.lean`)
  is `G.BiSerial ∧ G.TailStable ∧ G.BoxLabelFaithful ∧ …`, so `TailStable` is a conjunct of the
  predicate being refuted rather than an untested side condition.
- **The certificate class is the intended one** — `PlusSlicedCertificate`, the class the
  compression work landed.
- **Premises match** — `Γ = []`, the empty-context reading of "ℤ-time non-validity".

Both theorems verified against the kernel: axioms `[propext, Classical.choice, Quot.sound]`, no
`sorryAx`, no non-standard axioms.

The witness is `Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)`. The obstruction is finite **width**, not finite
carrier: limit closure together with finite per-time fibres contradicts König. That is strictly
stronger than, and subsumes, the finite-carrier refutation recorded under
`Decidability/FMP/README.md`.

## Scope limits of the refutation — do not over-read it

Stated in `NoFiniteWidth.lean`'s own docstrings and preserved here:

1. **ℤ (discrete) frames only.** The pumping argument the refutation rests on needs discreteness
   and says nothing about a dense duration.
2. **An L⁺ result specifically.** `Φ` uses `⊡` (`PlusFormula.stab`), a constructor of an
   inductive sharing no supertype with `Syntax.Formula`. This is not a result about the base
   language TM. `Probe706.no_finite_carrier_sat`, whose witness is `⊡`-free, is the half that
   does speak about base TM.
3. **Nothing about an infinite carrier** — only about finite per-time fibres over one.
4. **Soundness is untouched.**
5. **No width bound is claimed** for a target that does have a finite-width countermodel; only
   that `Φ.neg` is not such a target.

## What this does and does not close

Closed: the sliced route to L⁺ ℤ-time decidability. The route is refuted, not merely blocked, so
the ω-automata determinization dependency that once gated *proving* the statement now points at
nothing.

Not closed: decidability of full L⁺. A successor certificate class would have to present
**infinite** fibres (root paths of a finite class graph), for which there is no checker
precedent. Whether to open that is a programme-level decision and is deliberately not made here.
The complexity floor constrains any such attempt: L⁺ ℤ-time validity is 2EXPTIME-hard by the
CTL\* reduction, so a singly exponential certificate checkable in time polynomial in its size
would place a 2EXPTIME-hard problem in co-NEXPTIME. No bound is committed.

Unaffected: the stab-free flagship, and the base-language tableau decidability programme over
`Syntax.Formula`, which is disjoint from this one.

## Marker correction applied at close

This record previously carried `[BLOCKED]` with no `blockers` entry — the only such task. The
blocked marker described a gate on proving a statement that is now refuted, so it was not
correctable by supplying a blocker; it is resolved by the terminal status instead.

A claim in the prior record is superseded: it stated that the library landing did not exist and
that `PlusSlicedCertificate/Limits/` was not a directory in the tree. Both halves are landed
there now (`NoFiniteWidth.lean`, `FiniteCarrier.lean`), which is what satisfied the ruling's
precondition for closing as a refutation record rather than on the probe alone.
