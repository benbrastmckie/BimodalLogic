# Phase 7.2 — Forward case B: two-outcome probe

**Status**: `[BLOCKED]` — outcome (ii), a planned outcome of the phase's charter, not a failure.
**Rung elected**: R4 (honest floor). **R2 eliminated on verbatim source evidence.** R3 flagged.

## What was executed

Phase 7.2 was chartered as a two-outcome probe: prove forward case B, or exhibit a refuting
family. Outcome (ii) fired. Both halves of the phase's task list that could be executed were.

### Forward case A — landed sorry-free (the H2 formal-proof-line bar)

Two declarations in `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean`:

- `forward_until_witness_of_straddling_rat` — from any rational witness pattern straddling the
  shifted target (`p` below, `s'` above, `φ ∈ m s'`, `ψ` guarding `(p, s')`), the real witness
  `(s' : ℝ) - δ` and the transported guard discharge the forward `untl` obligation. Selectedness
  of the target is never consulted: the rational guard on `(p, s')` covers the *subinterval*
  `(t + δ, s')`, and `guard_transport_realLimitMCS` carries it to every real between.
- `toRealBundle_forward_until_unselected_dichotomy` — the descent plus the explicit case split,
  as a theorem. Either case A fires and the obligation closes, or every rational witness stays
  below the target and `φ` holds at rationals cofinally below it.

### Forward case B — probed, and the reach is now a theorem

- `limitSetBelow_someFuture_of_cofinal` — cofinal `φ`-points below `T` give
  `F φ ∈ limitSetBelow m T`. This is the conversion that matters: `F φ`'s truth region below the
  gap is an *interval*, `(-∞, T)`, even when `φ`'s own is a merely accumulating set.
- `forward_until_unselected_eventuality_of_priorU` — composes the above with
  `limitFutureWitness_of_priorU` (Prior-U at `F φ`) to prove that at an unselected target,
  **either** the obligation is discharged outright, **or** there is a rational `w > t + δ` with
  `φ ∈ fam.mcs w` and **no guard whatever** on the rationals between.

All four are `[propext, Classical.choice, Quot.sound]`.

## Why the guard is unreachable by this route

The phase required that any Prior-U attempt state up front which formula it is applied to and
what supplies its `U(⊤, ·)` antecedent. The answer is structural, not tactical:

`Axiom.prior_U_gap` at `χ` has consequent `U(¬χ ∨ K⁺(¬χ), χ)`, which guards with `χ` and with
nothing else. A `ψ`-guard therefore requires `χ = ψ` or `χ ⊢ ψ`. Its antecedent is `U(⊤, χ)` —
`χ` uninterruptedly on an interval abutting the gap **from below** — and under `χ ⊢ ψ` that
antecedent already delivers `ψ` uninterruptedly on that interval. **The antecedent is available
exactly when the below-gap analogue of the conclusion already holds.** Forward case B supplies
`ψ` only on the descent intervals `(p, s'_p)`, each closing strictly below the gap: cofinally,
not eventually. The attempt therefore stopped rather than iterating tactics, as instructed.

This is the whole asymmetry with the backward side. `BFMCS.LimitGuardBelow`'s Prior-S antecedent
`S(⊤, ψ)` is free *because that predicate's own hypothesis hands it the interval*. In the forward
direction the guard is the **conclusion**, so there is no hypothesis to hand over and
`LimitGuardBelow` has no antecedent to consume.

## Refutation 3 (recorded in the module docstring, by printed page)

1. **The family.** Irrational `T`; rationals `t_n ↗ T`, `α_n ∈ (t_n, t_{n+1})`; mirrored above by
   `u_n ↘ T` and `α'_n ↘ T` interleaved as `α'_{n+1} < u_{n+1} < α'_n`. `V(φ) = {α_n} ∪ {α'_n}`,
   `V(ψ)` omits exactly `{t_n} ∪ {u_n}`. All boundary points rational, so both directions of
   unrestricted rational Until coherence hold and each `m q` is maximal consistent at
   `FrameClass.Dedekind` for free. Every rational `φ`-point above `T` is some `α'_n`, and
   `(T, α'_n)` contains the `ψ`-failure `u_{n+1}`; no unselected witness exists either, since
   `V(φ)`'s only accumulation point is `T` itself.
2. **Realizability inside `cantorBfmcsDense`: explicitly UNSETTLED.** This is the weaker outcome
   the phase permits and it is labelled as such. `BFMCS.LimitGuardBelow` constrains the family
   hard — any formula constant on an interval above `T` must be eventually true below `T`, which
   forces `φ`, `ψ` and `untl φ ψ` each to oscillate on **both** sides of `T`, and is why the
   family is built two-sided rather than copying Refutation 2's one-sided shape. Whether the
   chronicle's own back-and-forth can produce such a configuration at some gap is open.
3. **The ultrafilter computation.** `{q | untl φ ψ ∈ m q} = ⋃ (t_n, α_n) ∩ ℚ` is cofinal below
   `T`, and so is its complement. **Neither contains an interval `(z, T)`, so neither lies in
   `limitFilterBelow (t + δ)`.** Membership in `limitMCSBelow` is decided by
   `Ultrafilter.of (limitFilterBelow T)` and is *not* determined by `limitFilterBelow_le`, the
   only property of that choice the development uses. The transport is therefore **not derivable**
   from rational coherence plus `LimitGuardBelow` plus `LimitFutureWitness`; it is not thereby
   shown false.

## R2 is dead — verbatim source evidence

The binding directive required reading the sources before acting on R2. Reading
`sources/reynolds_1992/sec04_7-separability.md` settles it against R2:

- **Theorem 5** (§7, printed pp.184-185) — the separability step R2 would consume — says at its
  critical line: *"Let the temporal formula `C` be true exactly at points who are the left hand
  end points of their classes. This includes the case of a singleton class. **We use expressive
  completeness here.**"*
- **Doets' theorem** (§8, Theorem 6, printed pp.185-188) is stated purely for *"monadic
  first-order sentences of quantifier depth at most `k`"* and proved by EF-game arguments,
  lexicographic sums and shuffles (Lemmas 11-13); Lemma 12 constructs a monadic formula
  `ε(x, y)`.

Phase 7.2's own R2 clause states that "if an escalation finds itself needing expressive
completeness of `{U,S}` then R2 is also dead". It does, so it is. The standing Postmortem
Constraint against the Reynolds transfer route applies in full.

## The positive residual — R3's precise target

One invariant closes forward case B outright: **if the guard `ψ` is *eventually* true below the
gap rather than merely cofinally**, then `U(⊤, ψ)` is free, Prior-U at `ψ` yields
`U(¬ψ ∨ K⁺(¬ψ), ψ)`, and the endpoint it produces can lie neither below the gap (where `ψ` holds)
nor at it (unselectedness), so it lies above — delivering exactly the missing guard. This is the
mirror of `limitGuardBelow_of_priorS`.

R3 (a no-left-accumulation invariant on Until-witnesses in `cantorBfmcsDense`'s deferral closure)
is therefore no longer speculative but precisely targeted. Electing it **modifies `Chronicle/`**,
so it requires an explicit Postmortem Constraints amendment plus a new research dispatch. This
dispatch **flagged it and did not elect it**.

## Verification

| Check | Result |
|---|---|
| New sorries | 0 (baseline outside Boneyard unchanged: `WeakCanonical/Transfer.lean:1242`) |
| New vacuous definitions | 0 |
| New axioms | 0 |
| `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension` | passes |
| `lake build FormalSystem.Metalogic` (1871 jobs) | passes |
| `lake build` (full) | fails **only** in `Automation/DatasetGenerator.lean` — a concurrent session's uncommitted in-flight edits; that module has zero imports from and zero mentions of `Chronicle/` |

## Prohibitions honoured

No `sorry`. No vacuous definition. No `LimitUntilWitness`-style predicate threaded onto
`countermodel_dedekind_dense`, `completeness_dedekind_engine`,
`consequence_completeness_dedekind` or `completeness_dedekind`. No narrowing of the target class.
No chronicle declaration edited; no closure enlarged; no witness-aware selection. **Phase 8 must
not be dispatched** — under outcome (ii) the correct action is task `[PARTIAL]`.
