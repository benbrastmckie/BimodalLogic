# Phase 7.4 — The bounded witness, `LimitGuardEventual`, and both unselected forward cases

- **Task**: 408 (faithful route to strong completeness for the Dedekind extension)
- **Phase**: 7.4 (R3b + R3c) — `[COMPLETED]`
- **Plan**: `plans/05_strong-completeness-dedekind-v5.md`
- **Date**: 2026-07-27
- **Outcome**: all five chartered statements landed sorry-free in one run; full `lake build` green

## What landed

| Declaration | File | Role |
|---|---|---|
| `BFMCS.LimitGuardEventual` | `Bundle/RealExtensionBundle.lean` | The bundle predicate — closure-free, no `root` argument. The sole undischarged residual of forward Until/Since coherence at ℝ |
| `boundedWitness_of_limitGuardBelow` | `Chronicle/ChronicleRealExtension.lean` | Transcribed verbatim from `reports/05_forward-guard-r3-research.md` §3 (12 lines). Converts a cofinal witness below a gap into one inside any interval abutting it from above |
| `toRealBundle_forward_until_unselected` | same | Forward `untl` at an unselected target, by the chartered six-step chain |
| `toRealBundle_forward_since_unselected` | same | Forward `snce` at an unselected target — **v4's charter gap**, closed with no Prior-U step at all |
| `BFMCS.toRealBundle_restricted_forward_until_since` | same | The composition over all four cases |

All five report `#print axioms` exactly `[propext, Classical.choice, Quot.sound]`.

## How the two unselected cases went

**`untl`.** The dichotomy's left disjunct closes outright (landed in Phase 7.2). On the right
disjunct, `LimitGuardEventual` supplies `ψ ∈ limitSetBelow m (t+δ)`; the guard-reach lemma above a
gap turns that into a rational bound `c > t+δ` with `ψ` throughout `(t+δ, c)`; the bounded witness
at that `c`, fed the dichotomy's cofinal `φ`-points, produces `w ∈ (t+δ, c)` with `φ ∈ m w`; and
`guard_transport_realLimitMCS` on the subinterval `(t+δ, w)` carries the guard to every real
between `t` and `(w : ℝ) - δ`. Steps 1-4 are consumed from Phase 7.3, not inlined.

**`snce`.** No gap axiom is used. The obligation asks for `ψ` on the rationals abutting `t+δ` from
*below*, which is verbatim what `ψ ∈ limitSetBelow m (t+δ)` says, so the predicate discharges the
guard directly. Only the witness needs work: `limitMCSBelow_cofinal_below` produces a rational `p`
*inside the predicate's own guard interval* still carrying `snce φ ψ`, and rational forward
coherence at `p` yields the witness below it. Choosing `p` above the predicate's threshold `z` is
what makes the guard on `(s', t+δ)` cover piecewise — rational coherence below `p`, the predicate
at and above `p`.

## Literature grounding (verified verbatim before writing)

Reynolds 1992, printed p.175 (`sources/reynolds_1992/sec06_5-…md:27`):

> Given a temporal formula `A`, we can define a connective `γ⁺` by saying that `γ⁺(A)` holds
> exactly when `A` remains true for a while after now but only up until a gap after which `A` is
> arbitrarily soon false. If `γ⁺(A)` is true anywhere we call the indicated gap an `A` *left gap*
> and more generally a *definable gap*.

`LimitGuardEventual` is exactly the failure of `γ⁺` at the guard. The bounded witness's provenance
is Burgess 1984 §2.7, printed pp.109-110, where the far-side gap witness is placed with **no bound
whatsoever** (licensed by `A7a`) because `F`/`G` carries no guard; here the bound is precisely what
makes the guard interval finite, and it is bought with the Since-side gap axiom.

## The residual, stated once

The forward side is now reduced to `BFMCS.LimitGuardEventual` and nothing else. The module
docstring records three facts about it so no later reader repeats a dead search: it is **necessary
as well as sufficient** (the obligation's own conclusion entails it, via `LimitGuardBelow`); given
it, nothing else is missing; and its discharge **has no source in the corpus** — `prior_U_gap`'s
antecedent *is* the interval it would have to produce, `prior_S_gap` yields only necessity, and
`sep` lives entirely inside `K⁺`/`K⁻`.

## Deviation

Statement 5's drafted binder list `(B) (root) (h_rfuc) (h_rbuc) (h_lgb) (h_lge)` is not provable as
written; the landed signature adds `hfc`, `hSf`, `hSb` (the bounded witness's ingredients — the
plan's own "TRANSCRIBE, do not re-derive" instruction forces them, since `h_lgb` is the *packaged
conclusion* of `limitGuardBelow_of_priorS`, not its ingredients) and `h_lga` (Phase 7.3's
conclusion written out, since this phase's territory forbids both extending that module and adding
a `LimitGuardAbove` predicate), and drops the two that go unused. Every added binder is discharged
at a chronicle call site from assets that already exist, so the route gains no obligation. Full
rationale in the plan's DEVIATION block at the end of the Phase 7.4 section.

## Verification

- `lake build` — green, 1903 jobs. (One transient failure in `Decidability/CountermodelExtraction`
  from the concurrent task-165 session editing `Decidability/Saturation.lean` mid-build; the same
  target and then the full build both succeeded on re-run with no change to this phase's files.)
- Live sorries outside `Boneyard/`: exactly `WeakCanonical/Transfer.lean:1242` — unchanged.
- Vacuous definitions: 0. New axioms: 0.
- `cantor_bfmcs_dense_real_restricted_fuc` not attempted; no chronicle declaration edited; no
  closure enlarged; no predicate threaded onto any terminus.
