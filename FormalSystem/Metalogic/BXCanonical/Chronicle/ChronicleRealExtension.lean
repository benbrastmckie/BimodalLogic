/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGapWitness
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGuardWitness

/-!
# Until/Since at the real bundle: the mechanical transport

`Bundle/RealExtensionBundle.lean` builds the real bundle `BFMCS.toRealBundle` over a rational
bundle and transports restricted **temporal** coherence to it. This module does the same work for
restricted **Until/Since** coherence, as far as it goes.

## The one lemma everything rests on

`guard_transport_realLimitMCS` says that a guard stated over *rationals* in an interval already
guards every *real* in that interval. At a selected real the extension is a rational set and the
rational guard applies verbatim; at an unselected real the extension is `limitMCSBelow`, and the
left end of the interval is itself a legitimate `limitSetBelow` threshold, so
`limitSetBelow_subset_limitMCSBelow` upgrades the guard. This removes the selected/unselected
split from every guard obligation in the file.

## What transports and what does not

The four obligations do **not** behave alike, and the asymmetry is structural rather than an
artifact of these proofs. `realLimitMCS` takes the limit **from below**, so a membership at an
unselected real is information about the rationals *underneath* it:

- **Forward `untl`, forward `snce`, at a selected target** — `toRealBundle_forward_until_selected`
  and `toRealBundle_forward_since_selected`. Mechanical: the rational witness `s'` transports to
  the real `(s' : ℝ) - δ` and the rational guard transports by the guard lemma.
- **Backward `untl` at a selected target** — `toRealBundle_backward_until_selected`. The real
  witness `s` sits *above* the target, so descending from it (`limitMCSBelow_cofinal_below`, via
  `exists_rat_witness_of_realLimitMCS`) moves *towards* the target and lands inside the guarded
  interval. That is the whole reason this case closes.
- **Backward `snce`, and backward `untl` at an unselected target** — these are the cases the
  guard-free transport cannot have, and the `Refutations` section below says why. They are
  nevertheless *available*, at the cost of one further hypothesis on the rational bundle:
  `BFMCS.LimitGuardBelow`, which says a formula guarding an interval that abuts a gap from above
  already guards an interval abutting it from below. With it, `toRealBundle_backward_until_unselected`
  runs the guard down through the gap, and
  `exists_rat_since_witness_below_of_limitGuardBelow` relocates the `snce` witness to a rational
  **below** the gap, where `limitMCSBelow_cofinal_below` can reach it.

**The backward side is complete.** `BFMCS.toRealBundle_restricted_backward_until_since` covers
all four cases, and `cantor_bfmcs_dense_real_restricted_buc` is its chronicle instance, obtained
by composing with `cantor_bfmcs_dense_restricted_buc` and the guard-reach discharge
`cantor_bfmcs_dense_limit_guard_below`.

`cantor_bfmcs_dense_real_restricted_fuc` is **deliberately absent** from this module, and its
absence is the module's only gap. Forward `untl` from a membership at an *unselected* target —
forward case B — is a separate obligation with its own probe; there the guard is the
*conclusion* rather than a hypothesis, so nothing supplies the antecedent that
`BFMCS.LimitGuardBelow` needs, and the backward completion above does not reach it. Its absence
is not an oversight and does not mean the module is half-finished. How far the forward side does
get, and exactly where it stops, is settled below and recorded in
`forward_until_unselected_eventuality_of_priorU`; the *transport*
`BFMCS.toRealBundle_restricted_forward_until_since` is nevertheless complete, and the section
"The forward side, reduced to one predicate" states exactly what it rests on.

## Forward case B: what is settled

The forward obligation at an unselected target splits, and the split is a theorem
(`toRealBundle_forward_until_unselected_dichotomy`), not a description:

- **Forward case A** — the descent finds a rational witness pattern *straddling* the shifted
  target. `forward_until_witness_of_straddling_rat` closes it outright, with no selectedness
  assumption anywhere: the rational guard on `(p, s')` covers the subinterval `(t + δ, s')`, and
  `guard_transport_realLimitMCS` carries it to every real in between. This case is **landed**.
- **Forward case B** — every rational witness stays below the target. Then `φ` holds at rationals
  cofinally below the gap, `limitSetBelow_someFuture_of_cofinal` turns that into
  `F φ ∈ limitSetBelow`, and Prior-U applied at `F φ` (`limitFutureWitness_of_priorU`) crosses the
  gap. **The eventuality half is therefore available and is proved here.** What is *not* available
  is any guard at all on the rationals between the gap and that witness.

The guard is not merely unproved, it is unreachable by this route, and the reason is structural.
`Axiom.prior_U_gap` at `χ` has consequent `U(¬χ ∨ K⁺(¬χ), χ)`, which guards with `χ` and nothing
else; a `ψ`-guard therefore requires applying it at `χ = ψ` (or at some `χ ⊢ ψ`). Its antecedent
is `U(⊤, χ)`, demanding `χ` uninterruptedly on an interval abutting the gap **from below** — and
under `χ ⊢ ψ` that already delivers `ψ` uninterruptedly on that interval. The antecedent is thus
available exactly when the below-gap analogue of the conclusion already holds. Forward case B
supplies only `ψ` on the descent intervals `(p, s'_p)`, each closing strictly below the gap: `ψ`
is cofinally, not eventually, true below it. This is the whole asymmetry with the backward side,
where `BFMCS.LimitGuardBelow`'s own hypothesis hands Prior-S the interval it needs.

Reynolds records the same limitation at the same point of his own development (§6 opening,
**printed p.176**): "We know that the Prior axioms ensure that there will not be any definable
gaps in a model. To show that our model can be made into a model over the reals we actually need
a stronger result." Burgess 1984 runs the completion route only in the `F`/`G` fragment
(**printed pp.109-110**) and says nothing about `U`/`S` at a gap.

## The forward side, reduced to one predicate

Both unselected forward cases are now landed — `toRealBundle_forward_until_unselected` and
`toRealBundle_forward_since_unselected` — and `BFMCS.toRealBundle_restricted_forward_until_since`
composes them with the two selected cases into the full transport. **The entire remaining content
of forward Until/Since coherence at ℝ is the single predicate `BFMCS.LimitGuardEventual`**, and it
is undischarged.

The predicate says the guard `ψ` of an `untl`/`snce` surviving into the limit at an unselected real
is *eventually*, not merely cofinally, true below it. That is precisely the negation of Reynolds'
`γ⁺` at the guard: he defines the connective by saying that "`γ⁺(A)` holds exactly when `A` remains
true for a while after now but only up until a gap after which `A` is arbitrarily soon false", and
calls the indicated gap an `A` *left gap* (**printed p.175**).

Three things about it are worth recording, because each of them closes off a search a later reader
would otherwise repeat.

1. **It is necessary as well as sufficient.** Sufficiency is the two lemmas named above.
   Necessity: the forward `untl` obligation's own conclusion guards *every real* of an interval
   `(t, s)`, whose selected members are exactly the rationals of `(t + δ, s + δ)`; feeding that
   rational guard interval back through `BFMCS.LimitGuardBelow` returns the predicate's conclusion
   verbatim. There is no weaker sufficient condition to look for, and no third route.
2. **Given it, nothing else is missing.** The two ingredients the `untl` half adds are both landed
   assets: the guard-reach lemma above a gap (Prior-U applied to the guard, discharged for the
   chronicle by `cantor_bfmcs_dense_limit_guard_above`) and `boundedWitness_of_limitGuardBelow`,
   which converts a cofinal witness below the gap into one *inside* the guarded interval. The
   `snce` half adds nothing at all — it reads its guard straight off the predicate.
3. **Its discharge has no source in the corpus.** It is not derivable from a Dedekind axiom:
   `Axiom.prior_U_gap`'s antecedent `U(⊤, χ)` *is* the below-gap interval it would have to produce,
   `Axiom.prior_S_gap` consumes an above-gap interval and so yields only the necessity direction,
   and `Axiom.sep` lives entirely inside `K⁺`/`K⁻`, which is the negation of "holds on an interval".
   Reynolds reaches ℝ by the separability route instead (**printed pp.177-178**), and Burgess 1984's
   completion argument stays in the `F`/`G` fragment, where the gap witness is placed on the far
   side with no bound whatever and no guard to carry (**printed pp.109-110**). Its discharge is
   therefore deferred to a phase that is gated on explicit authorization, and
   `cantor_bfmcs_dense_real_restricted_fuc` remains absent from this module until then.

### Refutation 3 — forward `untl`, at an *unselected* target

Built like Refutations 1 and 2: `M` a genuine model over the flow `ℝ`, `m q := {χ | M, q ⊨ χ}`
for rational `q`. Fix an irrational `T`, rationals `t_n ↗ T` and `α_n ∈ (t_n, t_{n+1})`, and
mirror them above: rationals `u_n ↘ T` and `α'_n ↘ T` interleaved as
`α'_{n+1} < u_{n+1} < α'_n`. Let `V(φ) = {α_n} ∪ {α'_n}` and let `V(ψ)` omit exactly the points
`{t_n} ∪ {u_n}`. All boundary points are rational, so both directions of *unrestricted* rational
Until coherence hold, and each `m q` is maximal consistent at `FrameClass.Dedekind` for free.

*The hypothesis holds, conditionally on the ultrafilter.* `untl φ ψ ∈ m q` exactly for
`q ∈ ⋃ (t_n, α_n)` below `T`: at such a `q` the witness `α_n` works and `ψ` guards `(q, α_n)`,
while at `q ∈ (α_n, t_{n+1})` the next `φ`-point is `α_{n+1}`, beyond the `ψ`-failure `t_{n+1}`.

*The conclusion fails.* Every rational `φ`-point above `T` is some `α'_n`, and `(T, α'_n)`
contains the `ψ`-failure `u_{n+1}`, so no rational witness carries a guard. No *unselected*
witness exists either: `V(φ)` is a discrete point set whose only accumulation point is `T`
itself, so `φ ∉ limitMCSBelow m g` for every gap `g > T`. The eventuality is met — as
`forward_until_unselected_eventuality_of_priorU` proves it must be — and the guard never is.

*The ultrafilter computation.* `{q | untl φ ψ ∈ m q} = ⋃ (t_n, α_n) ∩ ℚ` is cofinal below `T`,
and so is its complement `⋃ (α_n, t_{n+1}) ∩ ℚ`. **Neither contains an interval `(z, T)`, so
neither lies in `limitFilterBelow T`.** Membership of `untl φ ψ` in `limitMCSBelow m T` is
therefore decided by `Ultrafilter.of (limitFilterBelow T)` and is *not* determined by
`limitFilterBelow_le`, the only property of that choice the development ever uses. The honest
reading: the forward transport is **not derivable** from rational coherence together with
`BFMCS.LimitGuardBelow` and `BFMCS.LimitFutureWitness`, since a proof would have to know how
`Ultrafilter.of` resolves an oscillation nothing constrains. It is not thereby shown false.

*Why the guard-side exclusion does not rescue this one.* Refutations 1 and 2 are killed by
`BFMCS.LimitGuardBelow`, and that predicate does constrain this family hard: any formula constant
on an interval above `T` must be eventually true below `T`, so `φ`, `ψ` and `untl φ ψ` are each
forced to oscillate on **both** sides of `T` — which is exactly why the family above is built
two-sided rather than copying Refutation 2's one-sided shape. It then satisfies
`BFMCS.LimitGuardBelow` vacuously at `T`, and `BFMCS.LimitGuardBelow` has no antecedent left to
consume.

*What is not settled.* Whether `cantorBfmcsDense`'s own back-and-forth can produce a two-sided
oscillation of this shape at some gap is **open**, and is deliberately labelled as open rather
than asserted either way. Refutation 3 refutes the route at the level of the hypotheses actually
available to the transport; it does not exhibit the configuration inside the chronicle.

*The positive residual.* One invariant closes forward case B outright: if the guard `ψ` is
*eventually* true below the gap rather than merely cofinally, then `U(⊤, ψ)` is free, Prior-U
applied at `ψ` gives `U(¬ψ ∨ K⁺(¬ψ), ψ)`, and the endpoint it produces cannot lie below the gap
(where `ψ` holds) nor equal it (unselectedness), so it lies above — delivering precisely the
missing guard. That is the exact mirror of `limitGuardBelow_of_priorS`, and it names the one
strengthening that would settle the forward side.

## Refutations

The generic backward transport

> `B.RestrictedBackwardUntilSinceCoherent root →`
> `(B.toRealBundle).RestrictedBackwardUntilSinceCoherent root`

is **false**, and is therefore not stated in this module; nor is the chronicle instance that
would be obtained by composing it with the rational backward instance. Two independent
counterexample families are recorded below. Both are built the same way — take a genuine model
`M` over the flow `ℝ`, set `m q := {χ | M, q ⊨ χ}` for rational `q`, and observe that the real
bundle's value at a gap is a limit **from below** and so disagrees with `M`'s own theory at that
gap. Taking theories of a real model makes every `m q` maximal consistent at
`FrameClass.Dedekind` for free, and makes `forward_G`/`backward_H` hold semantically, so each
family really is an `FMCS (fc := FrameClass.Dedekind) Rat`; the one-family bundle over it has
both modal fields, with `□χ ↔ χ` at a single modal world.

### Refutation 1 — backward `snce`, at a *selected* target

Fix an irrational `g` with `0 < g < 5`. Let `V(φ) = (0, g)` and `V(ψ) = (g, 5)`, and take
`root := snce φ ψ`, `δ := 0`.

*The hypothesis holds.* The only Until/Since formula in `subformulaClosure root` is `snce φ ψ`
itself, and the rational antecedent is never satisfied: a rational `u` with `φ ∈ m u` lies in
`(0, g)`, so the rationals of `(u, t)` include rationals of `(u, g)`, where `ψ` fails. Rational
restricted backward coherence therefore holds vacuously.

*The real witness pattern holds* at the selected target `t := 5` with the unselected witness
`s := g`. First, `φ ∈ realLimitMCS m 0 g`, because `{q | φ ∈ m q} ⊇ (0, g) ∩ ℚ` is a
`limitFilterBelow g` generator, so `φ ∈ limitSetBelow m g ⊆ limitMCSBelow m g`. Second, the guard
holds at every real of `(g, 5)`: directly at a selected one, and at an unselected one because
every rational of `(g, r)` carries `ψ`.

*The conclusion fails.* `snce φ ψ ∉ m 5`, since a real `u < 5` with `M, u ⊨ φ` lies in `(0, g)`
and `ψ` then fails throughout `(u, g]`.

*Isolation.* Nothing above uses the modal dimension, the ultrafilter's choice, or the difference
between the deferral and subformula closures. The single load-bearing fact is that the real
bundle at the gap `g` contains `φ` because `φ` is *eventually true from below* there, while `M`'s
own point `g` does not satisfy `φ`. The real bundle's witness pattern can thus be met by a
witness the rational family cannot supply — and for `snce` the witness lies *below* the target,
so descending from it (the move that rescues `untl`) leaves the guarded interval rather than
entering it. This is exactly the asymmetry noted at
`toRealBundle_backward_since_selected_of_rat_witness`.

### Refutation 2 — backward `untl`, at an *unselected* target

Fix an irrational `g` with `0 < g < 2 < 3`, rationals `t_n ↗ g`, and rationals
`α_n ∈ (t_n, t_{n+1})`. Let `V(ψ) = (⋃ n, (t_n, α_n)) ∪ (g, 3)` and `V(φ) = (g, 3)`, and take
`root := untl φ ψ`, `δ := 0`.

*The hypothesis holds.* Again `untl φ ψ` is the only Until/Since formula in the closure. At a
rational `t < g` the antecedent fails, since any `φ`-point is above `g` and the rationals of
`(t, g)` include `¬ψ` points from the intervals `(α_n, t_{n+1})`. At a rational `t ∈ (g, 3)` the
antecedent's conclusion is true in `M` anyway. At `t ≥ 3` there is no `φ`-point above `t`.

*The real witness pattern holds* at the unselected target `t := g`, with the selected witness
`s := 2`: `φ ∈ m 2` and the guard holds at every real of `(g, 2)`.

*The conclusion fails.* No rational below `g` carries `untl φ ψ`, and `{q : ℚ | (q : ℝ) < g}` is
a `limitFilterBelow g` generator, so the complement of `{q | untl φ ψ ∈ m q}` is large and
`untl φ ψ ∉ limitMCSBelow m g`.

### What these do and do not settle

They refute the transport theorem **as stated above**, whose only hypothesis on the rational
bundle is restricted backward coherence — and that refutation is permanent. They do **not**
settle the chronicle instance, and in fact both families are excluded by a *guard-side* gap
hypothesis that the chronicle bundle satisfies: `BFMCS.LimitGuardBelow`.

- *Refutation 1.* `ψ` is true at every rational of `(g, 5)` and at **no** rational below `g`.
  That is a `ψ`-**right gap** at `g` in Reynolds' sense — the connective `γ⁻`, dual to the `γ⁺`
  that marks left gaps (Reynolds 1992, printed p.175) — and `Axiom.prior_S_gap` excludes exactly
  that configuration. (Independently, this family also violates the already-discharged
  `BFMCS.LimitFutureWitness`: `someFuture φ ∈ m q` for every rational `q < g`, hence in
  `limitSetBelow m g ⊆ limitMCSBelow m g`, yet `V(φ) = (0, g)` gives no rational `s > g` with
  `φ ∈ m s`.)
- *Refutation 2.* `ψ` is uninterruptedly true on `(g, 3)` and false arbitrarily recently below
  `g`, by the oscillation — again verbatim the `γ⁻` pattern, so `BFMCS.LimitGuardBelow` fails at
  `r := g`. Once `ψ` is known on an interval `(a, g)`, rational backward coherence puts
  `untl φ ψ` in `m q` for every rational `q ∈ (a, g)`, hence in
  `limitSetBelow m g ⊆ limitMCSBelow m g`, and the refutation's conclusion-failure step
  evaporates.

*A correction.* An earlier version of this paragraph asserted that neither family satisfies the
*unrestricted* rational **forward** Until coherence that `cantorBfmcsDense` enjoys, "in
Refutation 2 the same happens for the definable gap of `φ.neg` at `g`". That claim is unsupported
for Refutation 2, and no forward violation is constructible there: for every candidate
`untl α β` at a rational `q < g`, a rational witness is available either below `g` or inside
`(g, 3)`, because `V(φ) = (g, 3)` is entered immediately above `g` and the `θ`-points `{αₙ}` are
themselves rational. What Refutation 2's family *does* fail is unrestricted rational **backward**
Until coherence, via the separating formula `β := ψ ∨ ¬K⁻ψ ∨ ¬K⁺ψ`: `β` holds at every rational
of `(q, s)` for `q < g < s < 3` — at `αₙ` because `¬K⁺ψ` holds there, inside `(αₙ, tₙ₊₁)` because
`¬K⁻ψ` holds, and above `g` because `ψ` holds — but fails at the real `g`, where `ψ` is false and
both `K⁻ψ` and `K⁺ψ` are true. The guard-side exclusion above supersedes both readings and is the
one the transport actually consumes.

The strengthened transport `BFMCS.toRealBundle_restricted_backward_until_since` therefore stands,
and with it the chronicle instance `cantor_bfmcs_dense_real_restricted_buc`. The refuted,
guard-free signature is not to be re-attempted.

## Main results

- `guard_transport_realLimitMCS`, `exists_rat_witness_of_realLimitMCS`.
- `toRealBundle_forward_until_selected`, `toRealBundle_forward_since_selected`.
- `toRealBundle_backward_until_selected`,
  `toRealBundle_backward_since_selected_of_rat_witness`.
- `toRealBundle_backward_until_unselected`,
  `exists_rat_since_witness_below_of_limitGuardBelow`,
  `toRealBundle_backward_since_selected_of_gap_witness`,
  `toRealBundle_backward_since_unselected`.
- `BFMCS.toRealBundle_restricted_backward_until_since`.
- `forward_until_witness_of_straddling_rat`,
  `toRealBundle_forward_until_unselected_dichotomy`,
  `limitSetBelow_someFuture_of_cofinal`,
  `forward_until_unselected_eventuality_of_priorU`.
- `cantor_bfmcs_dense_real_restricted_tc`, `cantor_bfmcs_dense_real_restricted_buc`.
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-! ## The shared guard lemma -/

/--
**A rational guard is already a real guard.**

If `ψ` lies in `m q` for every rational `q` strictly between the reals `a` and `b`, then `ψ` lies
in the real extension `realLimitMCS m δ` at every real point whose shifted coordinate `r + δ`
lies strictly between `a` and `b`.

At a selected point this is the rational guard read off through `realLimitMCS_of_rat`. At an
unselected point the extension is `limitMCSBelow m (r + δ)`, and `a` itself is a threshold
witnessing `ψ ∈ limitSetBelow m (r + δ)`: every rational in `(a, r + δ)` is in `(a, b)`, since
`r + δ < b`. `limitSetBelow_subset_limitMCSBelow` then finishes.

This is what removes the unselected-point difficulty from **every** guard obligation over the
real bundle, and it is stated free of any bundle so that it can be reused.
-/
theorem guard_transport_realLimitMCS (m : Rat → Set Formula) (δ a b : ℝ) (ψ : Formula)
    (hguard : ∀ q : Rat, a < (q : ℝ) → (q : ℝ) < b → ψ ∈ m q)
    (r : ℝ) (hra : a < r + δ) (hrb : r + δ < b) :
    ψ ∈ realLimitMCS m δ r := by
  by_cases hx : ∃ p : Rat, (p : ℝ) = r + δ
  · obtain ⟨p, hp⟩ := hx
    rw [realLimitMCS_of_rat m δ r p hp]
    exact hguard p (by rw [hp]; exact hra) (by rw [hp]; exact hrb)
  · rw [realLimitMCS_of_not_rat m δ r hx]
    refine limitSetBelow_subset_limitMCSBelow m (r + δ) ⟨a, hra, ?_⟩
    intro q h1 h2
    exact hguard q h1 (by linarith)

/-! ## Rational interpolation of a real witness -/

/--
**A real witness restricts to a rational one, without overshooting.**

If `φ` lies in the real extension at `s`, then for any real threshold `z` below the shifted
coordinate `s + δ` there is a rational `u` with `z < u ≤ s + δ` and `φ ∈ m u`.

At a selected `s` the rational is the selecting one and the bound is an equality; at an
unselected `s` it is `limitMCSBelow_cofinal_below`, which produces rationals arbitrarily close
below `s + δ`. The `≤` (rather than `<`) is exactly what makes the two cases share a statement.

Note the direction: the rational produced is **at or below** `s + δ`. That is why this helper
serves the backward `untl` obligation, whose witness sits above the target, and why it does
*not* serve the backward `snce` obligation, whose witness sits below the target — there,
descending from the witness moves away from the guarded interval rather than into it.
-/
theorem exists_rat_witness_of_realLimitMCS (m : Rat → Set Formula) (δ s : ℝ) (φ : Formula)
    (hφ : φ ∈ realLimitMCS m δ s) (z : ℝ) (hz : z < s + δ) :
    ∃ u : Rat, z < (u : ℝ) ∧ (u : ℝ) ≤ s + δ ∧ φ ∈ m u := by
  by_cases hx : ∃ p : Rat, (p : ℝ) = s + δ
  · obtain ⟨p, hp⟩ := hx
    rw [realLimitMCS_of_rat m δ s p hp] at hφ
    exact ⟨p, by rw [hp]; exact hz, le_of_eq hp, hφ⟩
  · rw [realLimitMCS_of_not_rat m δ s hx] at hφ
    obtain ⟨u, h1, h2, h3⟩ := limitMCSBelow_cofinal_below m (s + δ) hφ z hz
    exact ⟨u, h1, le_of_lt h2, h3⟩

/-! ## Forward case A: a selected target -/

/--
**Forward `untl` at a selected real.** From `untl φ ψ` in the extension at a real `t` whose
shifted coordinate is the rational `p`, the rational forward coherence supplies a rational
witness `s'` and a rational guard on `(p, s')`; the real witness is `(s' : ℝ) - δ`, whose own
shifted coordinate is `s'`, and the guard transports by `guard_transport_realLimitMCS`.

No limit reasoning occurs anywhere: at a selected target the extension *is* the rational family.
-/
theorem toRealBundle_forward_until_selected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl ψ φ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (hU : Formula.untl ψ φ ∈ realLimitMCS fam.mcs δ t) :
    ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r := by
  rw [realLimitMCS_of_rat fam.mcs δ t p hp] at hU
  obtain ⟨s', hps', hφ, hguard⟩ := (h_rfuc fam hfam).1 p φ ψ hsub hU
  have hlt : (p : ℝ) < (s' : ℝ) := by exact_mod_cast hps'
  rw [hp] at hlt
  refine ⟨(s' : ℝ) - δ, by linarith, ?_, ?_⟩
  · rw [realLimitMCS_of_rat fam.mcs δ ((s' : ℝ) - δ) s' (by ring)]
    exact hφ
  · intro r hr1 hr2
    refine guard_transport_realLimitMCS fam.mcs δ (t + δ) ((s' : ℝ)) ψ ?_ r (by linarith)
      (by linarith)
    intro q hq1 hq2
    refine hguard q ?_ ?_
    · rw [← hp] at hq1; exact_mod_cast hq1
    · exact_mod_cast hq2

/--
**Forward `snce` at a selected real**: the mirror of `toRealBundle_forward_until_selected`, with
the witness below the target and the guard on `(s', p)`.
-/
theorem toRealBundle_forward_since_selected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce ψ φ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (hS : Formula.snce ψ φ ∈ realLimitMCS fam.mcs δ t) :
    ∃ s : ℝ, s < t ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r := by
  rw [realLimitMCS_of_rat fam.mcs δ t p hp] at hS
  obtain ⟨s', hs'p, hφ, hguard⟩ := (h_rfuc fam hfam).2 p φ ψ hsub hS
  have hlt : (s' : ℝ) < (p : ℝ) := by exact_mod_cast hs'p
  rw [hp] at hlt
  refine ⟨(s' : ℝ) - δ, by linarith, ?_, ?_⟩
  · rw [realLimitMCS_of_rat fam.mcs δ ((s' : ℝ) - δ) s' (by ring)]
    exact hφ
  · intro r hr1 hr2
    refine guard_transport_realLimitMCS fam.mcs δ ((s' : ℝ)) (t + δ) ψ ?_ r (by linarith)
      (by linarith)
    intro q hq1 hq2
    refine hguard q ?_ ?_
    · exact_mod_cast hq1
    · rw [← hp] at hq2; exact_mod_cast hq2

/-! ## Backward `untl` at a selected target -/

/--
**Backward `untl` at a selected real.** From a real witness pattern at a real `t` whose shifted
coordinate is the rational `p`, the rational backward coherence delivers `untl φ ψ ∈ fam.mcs p`.

The real witness `s` is interpolated to a rational `u` with `p < u ≤ s + δ`
(`exists_rat_witness_of_realLimitMCS`). Every rational `q` with `p < q < u` has
`(q : ℝ) - δ` strictly between `t` and `s`, so the real guard applies there and
`realLimitMCS_of_rat` reads it off as `ψ ∈ fam.mcs q`.

This is the one backward case that survives. `exists_rat_witness_of_realLimitMCS` descends from
the witness, and here the witness is *above* the target, so the descent stays inside the guarded
interval `(t, s)`. The `snce` mirror has the witness below the target and the same descent leaves
the guarded interval — which is why that case needs `BFMCS.LimitGuardBelow` to extend the guard
past the gap first; see `exists_rat_since_witness_below_of_limitGuardBelow`.
-/
theorem toRealBundle_backward_until_selected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl ψ φ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (hwit : ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.untl ψ φ ∈ realLimitMCS fam.mcs δ t := by
  obtain ⟨s, hts, hφ, hguard⟩ := hwit
  rw [realLimitMCS_of_rat fam.mcs δ t p hp]
  obtain ⟨u, hpu, hus, hφu⟩ :=
    exists_rat_witness_of_realLimitMCS fam.mcs δ s φ hφ (p : ℝ) (by rw [hp]; linarith)
  refine (h_rbuc fam hfam).1 p φ ψ hsub ⟨u, by exact_mod_cast hpu, hφu, ?_⟩
  intro q hpq hqu
  have h1 : (p : ℝ) < (q : ℝ) := by exact_mod_cast hpq
  have h2 : (q : ℝ) < (u : ℝ) := by exact_mod_cast hqu
  rw [hp] at h1
  have hr := hguard ((q : ℝ) - δ) (by linarith) (by linarith)
  rwa [realLimitMCS_of_rat fam.mcs δ ((q : ℝ) - δ) q (by ring)] at hr

/--
**Backward `snce` at a selected target, from a selected witness.**

The `snce` mirror of `toRealBundle_backward_until_selected`, and it is stated with the witness's
shifted coordinate `w` assumed rational rather than obtained by interpolation. That hypothesis is
not a convenience: for `snce` the witness lies *below* the target, so
`exists_rat_witness_of_realLimitMCS` — which descends — would produce a rational strictly below
`w`, outside the guarded interval `(s, t)`, where nothing is known about `ψ`. The Refutations
section of this module's docstring exhibits a family where exactly that failure is fatal. The
companion `toRealBundle_backward_since_selected_of_gap_witness` covers the excluded case, by
paying for the descent with `BFMCS.LimitGuardBelow` rather than with a rational witness.

With `w` rational the proof is the mirror image of the `untl` case and uses no limit reasoning at
all: every rational `q` with `w < q < p` has `(q : ℝ) - δ` strictly between `s` and `t`, so the
real guard reads off as `ψ ∈ fam.mcs q`.
-/
theorem toRealBundle_backward_since_selected_of_rat_witness {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce ψ φ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (s : ℝ) (hst : s < t) (w : Rat) (hw : (w : ℝ) = s + δ)
    (hφ : φ ∈ realLimitMCS fam.mcs δ s)
    (hguard : ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.snce ψ φ ∈ realLimitMCS fam.mcs δ t := by
  rw [realLimitMCS_of_rat fam.mcs δ t p hp]
  rw [realLimitMCS_of_rat fam.mcs δ s w hw] at hφ
  have hwp : (w : ℝ) < (p : ℝ) := by rw [hw, hp]; linarith
  refine (h_rbuc fam hfam).2 p φ ψ hsub ⟨w, by exact_mod_cast hwp, hφ, ?_⟩
  intro q hwq hqp
  have h1 : (w : ℝ) < (q : ℝ) := by exact_mod_cast hwq
  have h2 : (q : ℝ) < (p : ℝ) := by exact_mod_cast hqp
  rw [hw] at h1
  rw [hp] at h2
  have hr := hguard ((q : ℝ) - δ) (by linarith) (by linarith)
  rwa [realLimitMCS_of_rat fam.mcs δ ((q : ℝ) - δ) q (by ring)] at hr

/-! ## Backward `untl` at an unselected target -/

/--
**Backward `untl` at an unselected real**, using the guard-reach obligation.

The target's shifted coordinate `T := t + δ` is a gap. The real witness interpolates to a
rational `u ∈ (T, s + δ]` (`exists_rat_witness_of_realLimitMCS`), and every rational of `(T, u)`
is a selected real of `(t, s)`, so the real guard reads off as a *rational* guard on `(T, u)`.

That rational guard is exactly the antecedent of `BFMCS.LimitGuardBelow`: `ψ` holds on an
interval abutting the gap `T` **from above**, so — no `ψ`-right gap at `T` being possible — it
already holds on an interval `(a, T)` abutting `T` from below. The rational backward coherence
then fires at *every* rational `q ∈ (a, T)` with the single witness `u`, its guard obligation on
`(q, u)` being covered by `(a, T) ∪ (T, u)` — the two halves meet because `T` itself is not
rational. So `untl φ ψ ∈ limitSetBelow fam.mcs T`, which is the extension's value at `t` by
`limitSetBelow_subset_limitMCSBelow`.
-/
theorem toRealBundle_backward_until_unselected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_lgb : B.LimitGuardBelow)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl ψ φ ∈ subformulaClosure root)
    (hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ)
    (hwit : ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.untl ψ φ ∈ realLimitMCS fam.mcs δ t := by
  obtain ⟨s, hts, hφ, hguard⟩ := hwit
  obtain ⟨u, hu1, hu2, hφu⟩ :=
    exists_rat_witness_of_realLimitMCS fam.mcs δ s φ hφ (t + δ) (by linarith)
  have hrg : ∀ q : Rat, t + δ < (q : ℝ) → (q : ℝ) < (u : ℝ) → ψ ∈ fam.mcs q := by
    intro q h1 h2
    have hr := hguard ((q : ℝ) - δ) (by linarith) (by linarith)
    rwa [realLimitMCS_of_rat fam.mcs δ ((q : ℝ) - δ) q (by ring)] at hr
  obtain ⟨a, ha, hA⟩ := h_lgb fam hfam (t + δ) hx ψ u hu1 hrg
  rw [realLimitMCS_of_not_rat fam.mcs δ t hx]
  refine limitSetBelow_subset_limitMCSBelow fam.mcs (t + δ) ⟨a, ha, ?_⟩
  intro q h1 h2
  have hqu : (q : ℝ) < (u : ℝ) := by linarith
  refine (h_rbuc fam hfam).1 q φ ψ hsub ⟨u, by exact_mod_cast hqu, hφu, ?_⟩
  intro w hw1 hw2
  have hw1' : (q : ℝ) < (w : ℝ) := by exact_mod_cast hw1
  have hw2' : (w : ℝ) < (u : ℝ) := by exact_mod_cast hw2
  rcases lt_trichotomy ((w : ℝ)) (t + δ) with h | h | h
  · exact hA w (by linarith) h
  · exact absurd ⟨w, h⟩ hx
  · exact hrg w h hw2'

/-! ## Backward `snce`: the witness placed below the gap -/

/--
**The `snce` witness, relocated to a rational strictly below the target.**

Given a real witness `s < t` for `snce φ ψ` over the real bundle, this produces a *rational* `u`
with `(u : ℝ) < t + δ`, `φ ∈ fam.mcs u`, and `ψ ∈ fam.mcs q` for **every** rational `q` between
`u` and `t + δ`. That triple is precisely the antecedent of the rational backward coherence, at
any rational target in `(u, t + δ]`.

Both selection cases go through, and neither needs the target to be selected:

- *Selected witness.* `s + δ` is the rational `w`; take `u := w` and read the real guard off at
  each rational of `(w, t + δ)`.
- *Unselected witness.* `S := s + δ` is a gap. The real guard gives a rational guard on
  `(S, c)` for any rational `c ∈ (S, t + δ)`, so `BFMCS.LimitGuardBelow` extends `ψ` **past the
  gap**, to an interval `(a, S)` abutting `S` from below. `limitMCSBelow_cofinal_below` then
  descends from `φ ∈ limitMCSBelow fam.mcs S` into that very interval, yielding `u ∈ (a, S)`
  with `φ ∈ fam.mcs u`. The guard on `(u, t + δ)` is `(a, S) ∪ (S, t + δ)`; the gap `S` is not
  rational, so nothing is missed at the join.

This is the step the earlier refutation of the guard-free transport turns on. Descending from an
`snce` witness does leave the interval that the *real* guard covers — but the guarded interval
does not stop at the gap, because a `ψ`-right gap there is exactly what `Axiom.prior_S_gap`
forbids (Reynolds 1992's `γ⁻` and *right gaps*, printed p.175). Placing the new witness strictly
between two existing rational points is Burgess 1982 I's own construction step (printed
pp.372-373, where the interpolated point is `z = (x + y)/2`).
-/
theorem exists_rat_since_witness_below_of_limitGuardBelow {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (h_lgb : B.LimitGuardBelow)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t s : ℝ) (φ ψ : Formula)
    (hst : s < t) (hφ : φ ∈ realLimitMCS fam.mcs δ s)
    (hguard : ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r) :
    ∃ u : Rat, (u : ℝ) < t + δ ∧ φ ∈ fam.mcs u ∧
      ∀ q : Rat, (u : ℝ) < (q : ℝ) → (q : ℝ) < t + δ → ψ ∈ fam.mcs q := by
  have hrg : ∀ q : Rat, s + δ < (q : ℝ) → (q : ℝ) < t + δ → ψ ∈ fam.mcs q := by
    intro q h1 h2
    have hr := hguard ((q : ℝ) - δ) (by linarith) (by linarith)
    rwa [realLimitMCS_of_rat fam.mcs δ ((q : ℝ) - δ) q (by ring)] at hr
  by_cases hy : ∃ w : Rat, (w : ℝ) = s + δ
  · obtain ⟨w, hw⟩ := hy
    rw [realLimitMCS_of_rat fam.mcs δ s w hw] at hφ
    refine ⟨w, by rw [hw]; linarith, hφ, ?_⟩
    intro q h1 h2
    exact hrg q (by rw [← hw]; exact h1) h2
  · obtain ⟨c, hc1, hc2⟩ := exists_rat_btwn (show s + δ < t + δ by linarith)
    obtain ⟨a, ha, hA⟩ :=
      h_lgb fam hfam (s + δ) hy ψ c hc1 (fun q h1 h2 => hrg q h1 (by linarith))
    rw [realLimitMCS_of_not_rat fam.mcs δ s hy] at hφ
    obtain ⟨u, hu1, hu2, hφu⟩ := limitMCSBelow_cofinal_below fam.mcs (s + δ) hφ a ha
    refine ⟨u, by linarith, hφu, ?_⟩
    intro q h1 h2
    rcases lt_trichotomy ((q : ℝ)) (s + δ) with h | h | h
    · exact hA q (by linarith) h
    · exact absurd ⟨q, h⟩ hy
    · exact hrg q h h2

/--
**Backward `snce` at a selected target, from an unselected witness.**

The companion of `toRealBundle_backward_since_selected_of_rat_witness`, covering exactly the
case that lemma's rational-witness hypothesis excludes. The relocated rational witness comes from
`exists_rat_since_witness_below_of_limitGuardBelow`, and the rational backward coherence fires
once, at the target's own rational coordinate.
-/
theorem toRealBundle_backward_since_selected_of_gap_witness {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root) (h_lgb : B.LimitGuardBelow)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce ψ φ ∈ subformulaClosure root)
    (p : Rat) (hp : (p : ℝ) = t + δ)
    (s : ℝ) (hst : s < t) (hφ : φ ∈ realLimitMCS fam.mcs δ s)
    (hguard : ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.snce ψ φ ∈ realLimitMCS fam.mcs δ t := by
  obtain ⟨u, hut, hφu, hg⟩ :=
    exists_rat_since_witness_below_of_limitGuardBelow B h_lgb fam hfam δ t s φ ψ hst hφ hguard
  rw [realLimitMCS_of_rat fam.mcs δ t p hp]
  have hup : (u : ℝ) < (p : ℝ) := by rw [hp]; exact hut
  refine (h_rbuc fam hfam).2 p φ ψ hsub ⟨u, by exact_mod_cast hup, hφu, ?_⟩
  intro q h1 h2
  have h1' : (u : ℝ) < (q : ℝ) := by exact_mod_cast h1
  have h2' : (q : ℝ) < (p : ℝ) := by exact_mod_cast h2
  rw [hp] at h2'
  exact hg q h1' h2'

/--
**Backward `snce` at an unselected target.**

No gap lemma is needed *at the target*: the relocated rational witness `u` lies below every
rational `q ∈ (u, t + δ)`, and the guard covers `(u, q) ⊆ (u, t + δ)`, so rational backward
coherence puts `snce φ ψ` in `fam.mcs q` for **every** such `q` at once. That is membership in
`limitSetBelow fam.mcs (t + δ)` with threshold `(u : ℝ)`, hence in the extension at `t`.
-/
theorem toRealBundle_backward_since_unselected {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (root : Formula) (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_lgb : B.LimitGuardBelow)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce ψ φ ∈ subformulaClosure root)
    (hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ)
    (s : ℝ) (hst : s < t) (hφ : φ ∈ realLimitMCS fam.mcs δ s)
    (hguard : ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r) :
    Formula.snce ψ φ ∈ realLimitMCS fam.mcs δ t := by
  obtain ⟨u, hut, hφu, hg⟩ :=
    exists_rat_since_witness_below_of_limitGuardBelow B h_lgb fam hfam δ t s φ ψ hst hφ hguard
  rw [realLimitMCS_of_not_rat fam.mcs δ t hx]
  refine limitSetBelow_subset_limitMCSBelow fam.mcs (t + δ) ⟨(u : ℝ), hut, ?_⟩
  intro q h1 h2
  refine (h_rbuc fam hfam).2 q φ ψ hsub ⟨u, by exact_mod_cast h1, hφu, ?_⟩
  intro w hw1 hw2
  have hw1' : (u : ℝ) < (w : ℝ) := by exact_mod_cast hw1
  have hw2' : (w : ℝ) < (q : ℝ) := by exact_mod_cast hw2
  exact hg w hw1' (by linarith)

/-! ## The strengthened backward transport -/

/--
**Transport of restricted backward Until/Since coherence to the real bundle.**

The guard-free form of this statement is false — see the `Refutations` section of this module's
docstring. The single added hypothesis `BFMCS.LimitGuardBelow` is what excludes both refuting
families, and it is not an extra assumption in practice: the chronicle bundle discharges it from
`Axiom.prior_S_gap`.

Four cases, on the selection of the target's shifted coordinate `T := t + δ` and (for `snce`) of
the witness's `S := s + δ`:

| case | route |
|---|---|
| `untl`, `T` selected | `toRealBundle_backward_until_selected` — no gap reasoning |
| `untl`, `T` unselected | `toRealBundle_backward_until_unselected` |
| `snce`, `T` and `S` selected | `toRealBundle_backward_since_selected_of_rat_witness` |
| `snce`, `T` selected, `S` a gap | `toRealBundle_backward_since_selected_of_gap_witness` |
| `snce`, `T` unselected | `toRealBundle_backward_since_unselected` |

Only the `snce` branch splits twice; the `untl` branch never needs to know whether its witness is
selected, because `exists_rat_witness_of_realLimitMCS` descends *towards* the target there.
-/
theorem BFMCS.toRealBundle_restricted_backward_until_since {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_lgb : B.LimitGuardBelow) :
    (B.toRealBundle).RestrictedBackwardUntilSinceCoherent root := by
  rintro G ⟨fam, hfam, δ, rfl⟩
  constructor
  · intro t φ ψ hsub hwit
    have hwit' : ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
        ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r := hwit
    show Formula.untl ψ φ ∈ realLimitMCS fam.mcs δ t
    by_cases hx : ∃ p : Rat, (p : ℝ) = t + δ
    · obtain ⟨p, hp⟩ := hx
      exact toRealBundle_backward_until_selected B root h_rbuc fam hfam δ t φ ψ hsub p hp hwit'
    · exact toRealBundle_backward_until_unselected B root h_rbuc h_lgb fam hfam δ t φ ψ hsub hx
        hwit'
  · intro t φ ψ hsub hwit
    have hwit' : ∃ s : ℝ, s < t ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
        ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r := hwit
    obtain ⟨s, hst, hφ, hguard⟩ := hwit'
    show Formula.snce ψ φ ∈ realLimitMCS fam.mcs δ t
    by_cases hx : ∃ p : Rat, (p : ℝ) = t + δ
    · obtain ⟨p, hp⟩ := hx
      by_cases hy : ∃ w : Rat, (w : ℝ) = s + δ
      · obtain ⟨w, hw⟩ := hy
        exact toRealBundle_backward_since_selected_of_rat_witness B root h_rbuc fam hfam δ t φ ψ
          hsub p hp s hst w hw hφ hguard
      · exact toRealBundle_backward_since_selected_of_gap_witness B root h_rbuc h_lgb fam hfam δ t
          φ ψ hsub p hp s hst hφ hguard
    · exact toRealBundle_backward_since_unselected B root h_rbuc h_lgb fam hfam δ t φ ψ hsub hx s
        hst hφ hguard

/-! ## Forward case B, part one: a rational witness pattern straddling the gap -/

/--
**A rational witness pattern that straddles the target already gives the real one.**

If `p` lies strictly below the shifted target `t + δ`, the rational `s'` lies strictly above it,
`φ ∈ m s'`, and `ψ` guards every rational of `(p, s')`, then the real witness `(s' : ℝ) - δ` and
the transported guard discharge the forward `untl` obligation at `t` — with no assumption
whatever on whether `t + δ` is selected.

The guard is the only step that needs an argument, and it is `guard_transport_realLimitMCS`
applied on the *sub*interval `(t + δ, s')`: the rational guard on `(p, s')` covers it because
`p < t + δ`, and every real of `(t, (s' : ℝ) - δ)` has its shifted coordinate inside it. The
point `t + δ` itself is never asked about, which is why selectedness is irrelevant here.
-/
theorem forward_until_witness_of_straddling_rat (m : Rat → Set Formula) (δ t : ℝ) (φ ψ : Formula)
    (p s' : Rat) (hpt : (p : ℝ) < t + δ) (hts' : t + δ < (s' : ℝ))
    (hφ : φ ∈ m s') (hguard : ∀ q : Rat, p < q → q < s' → ψ ∈ m q) :
    ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS m δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS m δ r := by
  refine ⟨(s' : ℝ) - δ, by linarith, ?_, ?_⟩
  · rw [realLimitMCS_of_rat m δ ((s' : ℝ) - δ) s' (by ring)]
    exact hφ
  · intro r hr1 hr2
    refine guard_transport_realLimitMCS m δ (t + δ) ((s' : ℝ)) ψ ?_ r (by linarith) (by linarith)
    intro q hq1 hq2
    exact hguard q (by exact_mod_cast hpt.trans hq1) (by exact_mod_cast hq2)

/--
**Forward `untl` at an unselected target: the descent dichotomy.**

At an unselected `t` the membership `untl φ ψ ∈ realLimitMCS m δ t` is a statement about the
rationals *below* `t + δ`, and `exists_rat_witness_of_realLimitMCS` turns it into rationals
`p ↗ t + δ` each carrying `untl φ ψ`. Rational forward coherence gives each such `p` a witness
`s'` and a guard on `(p, s')`. Exactly two things can happen, and this lemma is that case split
made explicit:

- **Case (a)** — some witness lands strictly above `t + δ`. Then
  `forward_until_witness_of_straddling_rat` closes the obligation outright: the *left* disjunct.
- **Case (b)** — every witness stays below `t + δ`. Since `t + δ` is unselected no witness can
  equal it, so each witness is a `φ`-point strictly between its own `p` and `t + δ`; as the `p`
  are cofinal below `t + δ`, so are the `φ`-points: the *right* disjunct.

The right disjunct is therefore not a failure report but the precise residual: forward case B
reduces to the situation where `φ` holds cofinally below the gap and the eventuality is met
arbitrarily late, leaving the interval `(t + δ, ·)` with no guard at all. Nothing in this lemma
attempts to guard that interval, and nothing in it assumes the guard can be had.
-/
theorem toRealBundle_forward_until_unselected_dichotomy {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl ψ φ ∈ subformulaClosure root)
    (hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ)
    (hU : Formula.untl ψ φ ∈ realLimitMCS fam.mcs δ t) :
    (∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
        ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r) ∨
      ∀ z : ℝ, z < t + δ → ∃ w : Rat, z < (w : ℝ) ∧ (w : ℝ) < t + δ ∧ φ ∈ fam.mcs w := by
  by_cases hcase : ∃ p s' : Rat, (p : ℝ) < t + δ ∧ t + δ < (s' : ℝ) ∧ φ ∈ fam.mcs s' ∧
      ∀ q : Rat, p < q → q < s' → ψ ∈ fam.mcs q
  · obtain ⟨p, s', hpt, hts', hφ, hguard⟩ := hcase
    exact Or.inl
      (forward_until_witness_of_straddling_rat fam.mcs δ t φ ψ p s' hpt hts' hφ hguard)
  · refine Or.inr ?_
    intro z hz
    obtain ⟨p, hzp, hpt, hUp⟩ :=
      exists_rat_witness_of_realLimitMCS fam.mcs δ t (Formula.untl ψ φ) hU z hz
    have hptlt : (p : ℝ) < t + δ := lt_of_le_of_ne hpt (fun h => hx ⟨p, h⟩)
    obtain ⟨s', hps', hφ, hguard⟩ := (h_rfuc fam hfam).1 p φ ψ hsub hUp
    have hs'le : (s' : ℝ) ≤ t + δ := by
      by_contra hcon
      exact hcase ⟨p, s', hptlt, lt_of_not_ge hcon, hφ, hguard⟩
    have hs'lt : (s' : ℝ) < t + δ := lt_of_le_of_ne hs'le (fun h => hx ⟨s', h⟩)
    have hps'R : (p : ℝ) < (s' : ℝ) := by exact_mod_cast hps'
    exact ⟨s', by linarith, hs'lt, hφ⟩

/--
**Cofinal `φ`-points below a real make `F φ` eventually true below it.**

The right disjunct of `toRealBundle_forward_until_unselected_dichotomy` says `φ` holds at
rationals arbitrarily close below `T`. Backward Until coherence at `untl φ ⊤ = F φ` then puts
`F φ` in `m q` for **every** rational `q < T`, so `F φ` is not merely cofinally true below `T` but
eventually true there — `limitSetBelow m T`, the strongest of the three grades of "true below `T`".

This is the step that converts the residual into an input for `BFMCS.LimitFutureWitness`, whose
whole point is to move an `F` from the limit at a gap to a rational strictly above it. The
conversion is available because `F φ`'s truth region below `T` is an *interval*, `(-∞, T)`, even
when `φ`'s own is a merely accumulating set — the same interval-versus-accumulation distinction
that governs which formula Prior-U may be applied to (Reynolds 1992, printed p.176).
-/
theorem limitSetBelow_someFuture_of_cofinal (m : Rat → Set Formula) (T : ℝ) (φ : Formula)
    (hUb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p) →
      Formula.untl β α ∈ m t)
    (htop : ∀ q : Rat, Formula.top ∈ m q)
    (hcof : ∀ z : ℝ, z < T → ∃ w : Rat, z < (w : ℝ) ∧ (w : ℝ) < T ∧ φ ∈ m w) :
    Formula.someFuture φ ∈ limitSetBelow m T := by
  refine ⟨T - 1, by linarith, ?_⟩
  intro q _ hqT
  obtain ⟨w, hqw, hwT, hφ⟩ := hcof (q : ℝ) hqT
  exact hUb q φ Formula.top ⟨w, by exact_mod_cast hqw, hφ, fun p _ _ => htop p⟩

end FormalSystem.Metalogic.Bundle

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle

/-! ## The chronicle real instance for temporal coherence -/

/--
**Restricted temporal coherence for the real bundle over `cantorBfmcsDense`.**

The composition of `BFMCS.toRealBundle_restricted_temporally_coherent` with the rational instance
`cantor_bfmcs_dense_restricted_tc` and the gap discharge
`cantor_bfmcs_dense_limit_future_witness`. Neither of the latter two is modified here.

`cantor_bfmcs_dense_restricted_tc` carries an unnamed closure-containment hypothesis, discharged
at the call site by `deferralClosure_subset_extendedDeferralClosure`; it is threaded through
unchanged. The `hfc : FrameClass.Dedekind ≤ fc` hypothesis comes from the gap discharge and is
likewise threaded rather than discharged here.
-/
theorem cantor_bfmcs_dense_real_restricted_tc (fc : FrameClass) (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    ((cantorBfmcsDense fc A h_mcs h_box_dense).toRealBundle).RestrictedTemporallyCoherent root :=
  BFMCS.toRealBundle_restricted_temporally_coherent _ root
    (cantor_bfmcs_dense_restricted_tc fc A h_mcs h_box_dense root
      (fun _ψ hψ => Finset.mem_toList.mpr
        (deferralClosure_subset_extendedDeferralClosure root hψ)))
    (cantor_bfmcs_dense_limit_future_witness fc hfc A h_mcs h_box_dense root)

/-! ## The chronicle real instance for backward Until/Since coherence -/

/--
**Restricted backward Until/Since coherence for the real bundle over `cantorBfmcsDense`.**

The composition of `BFMCS.toRealBundle_restricted_backward_until_since` with the rational
instance `cantor_bfmcs_dense_restricted_buc` and the guard-reach discharge
`cantor_bfmcs_dense_limit_guard_below`. Neither of the latter two is modified here.

The transport's guard-free form is refuted (see this module's `Refutations` section); what makes
the instance nonetheless available is that the chronicle bundle *does* satisfy
`BFMCS.LimitGuardBelow`, discharged from `Axiom.prior_S_gap`. As with
`cantor_bfmcs_dense_real_restricted_tc`, the `hfc : FrameClass.Dedekind ≤ fc` hypothesis comes
from the gap discharge and is threaded rather than discharged here.
-/
theorem cantor_bfmcs_dense_real_restricted_buc (fc : FrameClass)
    (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    ((cantorBfmcsDense fc A h_mcs h_box_dense).toRealBundle).RestrictedBackwardUntilSinceCoherent
      root :=
  BFMCS.toRealBundle_restricted_backward_until_since _ root
    (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense root)
    (cantor_bfmcs_dense_limit_guard_below fc hfc A h_mcs h_box_dense)

/-! ## Forward case B, part two: how far Prior-U reaches -/

/--
**Forward `untl` at an unselected target: the eventuality is available, the guard is not.**

This is the exact reach of the Prior-U technique on forward case B, and it is stated so that the
residual is a theorem rather than a description. Either the obligation is discharged outright
(left disjunct, via `toRealBundle_forward_until_unselected_dichotomy` and case A), or there is a
rational `w` strictly **above** the shifted target with `φ ∈ fam.mcs w` — a witness with **no
guard whatever** on the rationals between `t + δ` and `w` (right disjunct).

*The route.* The dichotomy's right disjunct gives `φ`-points cofinal below `T := t + δ`;
`limitSetBelow_someFuture_of_cofinal` upgrades them to `F φ ∈ limitSetBelow fam.mcs T`; and
`limitFutureWitness_of_priorU` — Prior-U applied at `F φ`, exactly as in
`ChronicleLimitGapWitness.lean` — moves that across the gap. `Axiom.prior_U_gap` is consumed
there, whence `hfc`.

*Why the right disjunct cannot be improved to the full obligation, stated as the probe demands.*
A `ψ`-guard on an interval abutting `T` from above can be produced by Prior-U only by applying it
to `ψ` itself: the consequent of `Axiom.prior_U_gap` at `χ`, namely `U(¬χ ∨ K⁺(¬χ), χ)`, guards
with `χ` and with nothing else, so obtaining a `ψ`-guard requires either `χ = ψ` or `χ ⊢ ψ`. Its
antecedent is `U(⊤, χ)` — `χ` true *uninterruptedly* on an interval abutting `T` from below — and
under `χ ⊢ ψ` that already forces `ψ` to hold uninterruptedly on that interval. **The antecedent
is therefore available exactly when the conclusion's below-gap analogue already holds**, and
nothing in forward case B supplies it: the hypothesis `untl φ ψ ∈ limitMCSBelow fam.mcs T` yields
`ψ` only on the intervals `(p, s'_p)` produced by the descent, each closing strictly below `T`,
so `ψ` is cofinally but not eventually true below `T`.

This is the precise sense in which the forward direction is not the mirror of the backward one.
`BFMCS.LimitGuardBelow` moves a guard from above a gap to below it, and its Prior-S antecedent
`S(⊤, ψ)` is free *because that predicate's own hypothesis hands it the interval*. Here the guard
is the **conclusion**, so there is no hypothesis to hand over, and `BFMCS.LimitGuardBelow` has no
antecedent to consume. Reynolds states the same limitation directly (§6 opening, printed p.176):
"We know that the Prior axioms ensure that there will not be any definable gaps in a model. To
show that our model can be made into a model over the reals we actually need a stronger result."
Burgess 1984 runs the completion route only in the `F`/`G` fragment (printed pp.109-110) and says
nothing about `U`/`S` at a gap.

Accordingly `cantor_bfmcs_dense_real_restricted_fuc` is **not** stated in this module, and no
guard-supplying predicate is hypothesised in its place.
-/
theorem forward_until_unselected_eventuality_of_priorU {fc : FrameClass}
    (hfc : FrameClass.Dedekind ≤ fc)
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families)
    (hUf : ∀ (t : Rat) (α β : Formula), Formula.untl β α ∈ fam.mcs t →
      ∃ s : Rat, t < s ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, t < p → p < s → β ∈ fam.mcs p)
    (hUb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, t < s ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, t < p → p < s → β ∈ fam.mcs p) →
      Formula.untl β α ∈ fam.mcs t)
    (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl ψ φ ∈ subformulaClosure root)
    (hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ)
    (hU : Formula.untl ψ φ ∈ realLimitMCS fam.mcs δ t) :
    (∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
        ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r) ∨
      ∃ w : Rat, t + δ < (w : ℝ) ∧ φ ∈ fam.mcs w := by
  rcases toRealBundle_forward_until_unselected_dichotomy B root h_rfuc fam hfam δ t φ ψ hsub hx hU
    with hleft | hcof
  · exact Or.inl hleft
  · refine Or.inr ?_
    have htop : ∀ q : Rat, Formula.top ∈ fam.mcs q := fun q =>
      theorem_in_mcs (fam.is_mcs q) (FormalSystem.Theorems.Combinators.identity
        (fc := fc) Formula.bot)
    have hF : Formula.someFuture φ ∈ limitMCSBelow fam.mcs (t + δ) :=
      limitSetBelow_subset_limitMCSBelow fam.mcs (t + δ)
        (limitSetBelow_someFuture_of_cofinal fam.mcs (t + δ) φ hUb htop hcof)
    exact limitFutureWitness_of_priorU hfc fam.mcs (fun q => fam.is_mcs q) hUf hUb (t + δ) hx φ hF

end FormalSystem.Metalogic.BXCanonical.Chronicle

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-! ## The bounded witness -/

/--
**A cofinal witness below a gap is already a witness inside any interval abutting it from above.**

If `φ` holds at rationals arbitrarily close below an **unselected** real `r`, then for *every*
rational bound `c > r` there is a rational `w` with `r < w < c` carrying `φ`. The witness is
bounded — that is the whole content, and it is what turns an unguarded witness somewhere above the
gap into one inside the guarded interval.

*The proof.* Contrapositively, if `φ` failed at every rational of `(r, c)`, then `¬φ` would guard
that whole interval, and the guard-reach lemma below a gap (`limitGuardBelow_of_priorS`, from
`Axiom.prior_S_gap`, whence `hfc`) would push `¬φ` to an interval abutting `r` from *below* — where
the cofinal hypothesis puts a `φ`-point. Maximal consistency at that point is the contradiction.

*Provenance.* Burgess 1984 §2.7 (printed pp.109-110) places the gap witness on the far side with
**no bound whatsoever**, licensed by `A7a`; no bound is needed there because `F`/`G` carries no
guard. Here the bound is precisely what makes the guard interval finite, and it is bought with the
Since-side gap axiom rather than assumed.
-/
theorem boundedWitness_of_limitGuardBelow {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
    (hSf : ∀ (t : Rat) (α β : Formula), Formula.snce β α ∈ m t →
      ∃ s : Rat, s < t ∧ α ∈ m s ∧ ∀ p : Rat, s < p → p < t → β ∈ m p)
    (hSb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, s < t ∧ α ∈ m s ∧ ∀ p : Rat, s < p → p < t → β ∈ m p) →
      Formula.snce β α ∈ m t)
    (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (φ : Formula)
    (hcof : ∀ z : ℝ, z < r → ∃ w : Rat, z < (w : ℝ) ∧ (w : ℝ) < r ∧ φ ∈ m w)
    (c : Rat) (hc : r < (c : ℝ)) :
    ∃ w : Rat, r < (w : ℝ) ∧ (w : ℝ) < (c : ℝ) ∧ φ ∈ m w := by
  by_contra hcon
  push_neg at hcon
  have hguard : ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → φ.neg ∈ m q := by
    intro q h1 h2
    rcases SetMaximalConsistent.negation_complete (hm q) φ with h | h
    · exact absurd h (hcon q h1 h2)
    · exact h
  obtain ⟨z, hz, hall⟩ :=
    FormalSystem.Metalogic.BXCanonical.Chronicle.limitGuardBelow_of_priorS hfc m hm hSf hSb r hr
      φ.neg c hc hguard
  obtain ⟨w, hzw, hwr, hphi⟩ := hcof z hz
  exact SetMaximalConsistent.neg_excludes (hm w) φ (hall w hzw hwr) hphi

/-! ## Forward `untl` at an unselected target -/

/--
**Forward `untl` at an unselected real, in full.**

The residual left open by `toRealBundle_forward_until_unselected_dichotomy` is closed here, by the
six-step chain the guard-eventuality predicate makes available. Given the predicate's conclusion
`ψ ∈ limitSetBelow fam.mcs (t + δ)`:

- the guard-reach lemma **above** a gap (`h_lga`, Prior-U applied to the guard `ψ`) turns it into a
  rational bound `c > t + δ` with `ψ` at every rational of `(t + δ, c)`;
- `boundedWitness_of_limitGuardBelow` at that `c`, fed the dichotomy's cofinal `φ`-points, produces
  a rational `w` with `t + δ < w < c` and `φ ∈ fam.mcs w`;
- `(w : ℝ) - δ` is the real witness, and `guard_transport_realLimitMCS` on `(t + δ, w)` — a
  subinterval of `(t + δ, c)` — transports the guard to every real strictly between.

The guard-reach hypothesis `h_lga` is written out rather than named as a predicate: its chronicle
discharge is `cantor_bfmcs_dense_limit_guard_above`, and the module owning that lemma is not
extended here.
-/
theorem toRealBundle_forward_until_unselected {fc : FrameClass}
    (hfc : FrameClass.Dedekind ≤ fc) (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families)
    (hSf : ∀ (t : Rat) (α β : Formula), Formula.snce β α ∈ fam.mcs t →
      ∃ s : Rat, s < t ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, s < p → p < t → β ∈ fam.mcs p)
    (hSb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, s < t ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, s < p → p < t → β ∈ fam.mcs p) →
      Formula.snce β α ∈ fam.mcs t)
    (h_lga : ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ χ : Formula,
      χ ∈ limitSetBelow fam.mcs r →
      ∃ c : Rat, r < (c : ℝ) ∧ ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → χ ∈ fam.mcs q)
    (h_lge : B.LimitGuardEventual)
    (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.untl ψ φ ∈ subformulaClosure root)
    (hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ)
    (hU : Formula.untl ψ φ ∈ realLimitMCS fam.mcs δ t) :
    ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r := by
  have hUlim : Formula.untl ψ φ ∈ limitMCSBelow fam.mcs (t + δ) := by
    rwa [realLimitMCS_of_not_rat fam.mcs δ t hx] at hU
  rcases toRealBundle_forward_until_unselected_dichotomy B root h_rfuc fam hfam δ t φ ψ hsub hx hU
    with hleft | hcof
  · exact hleft
  · have hev : ψ ∈ limitSetBelow fam.mcs (t + δ) :=
      h_lge fam hfam (t + δ) hx φ ψ (Or.inl hUlim)
    obtain ⟨c, hTc, hguardAbove⟩ := h_lga (t + δ) hx ψ hev
    obtain ⟨w, hTw, hwc, hφw⟩ :=
      boundedWitness_of_limitGuardBelow hfc fam.mcs fam.is_mcs hSf hSb (t + δ) hx φ hcof c hTc
    refine ⟨(w : ℝ) - δ, by linarith, ?_, ?_⟩
    · rw [realLimitMCS_of_rat fam.mcs δ ((w : ℝ) - δ) w (by ring)]
      exact hφw
    · intro r hr1 hr2
      refine guard_transport_realLimitMCS fam.mcs δ (t + δ) ((w : ℝ)) ψ ?_ r (by linarith)
        (by linarith)
      intro q hq1 hq2
      exact hguardAbove q hq1 (by linarith)

/-! ## Forward `snce` at an unselected target -/

/--
**Forward `snce` at an unselected real, in full — and it needs no gap axiom at all.**

This is the half of `h_fuc` that no earlier phase chartered. It is also the cheap half: the
obligation asks for a real `s < t` with `φ` at `s` and `ψ` guarding `(s, t)`, i.e. for `ψ` on the
rationals abutting `t + δ` from *below* — which is verbatim what
`ψ ∈ limitSetBelow fam.mcs (t + δ)` says. So the guard-eventuality predicate discharges the guard
directly, with no appeal to Prior-U, no bounded witness, and no guard-reach lemma above the gap.

Only the witness needs work, and it comes from the same cofinal descent used everywhere on the
unselected side: `limitMCSBelow_cofinal_below` produces a rational `p` inside the predicate's own
guard interval still carrying `snce φ ψ`, and rational forward coherence at `p` yields the witness
`s'` below it. The guard on `(s', t + δ)` is then covered piecewise — by rational coherence below
`p`, by the predicate at and above `p` — which is exactly why `p` is chosen above the predicate's
threshold `z`.

An implementer reaching for `limitGuardAbove_of_priorU` here has misread the obligation's
direction: nothing above the gap is ever asked about.
-/
theorem toRealBundle_forward_since_unselected {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families)
    (h_lge : B.LimitGuardEventual)
    (δ t : ℝ) (φ ψ : Formula)
    (hsub : Formula.snce ψ φ ∈ subformulaClosure root)
    (hx : ¬ ∃ p : Rat, (p : ℝ) = t + δ)
    (hS : Formula.snce ψ φ ∈ realLimitMCS fam.mcs δ t) :
    ∃ s : ℝ, s < t ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r := by
  rw [realLimitMCS_of_not_rat fam.mcs δ t hx] at hS
  obtain ⟨z, hzT, hzguard⟩ := h_lge fam hfam (t + δ) hx φ ψ (Or.inr hS)
  obtain ⟨p, hzp, hpT, hSp⟩ := limitMCSBelow_cofinal_below fam.mcs (t + δ) hS z hzT
  obtain ⟨s', hs'p, hφ, hguard⟩ := (h_rfuc fam hfam).2 p φ ψ hsub hSp
  have hs'pR : (s' : ℝ) < (p : ℝ) := by exact_mod_cast hs'p
  refine ⟨(s' : ℝ) - δ, by linarith, ?_, ?_⟩
  · rw [realLimitMCS_of_rat fam.mcs δ ((s' : ℝ) - δ) s' (by ring)]
    exact hφ
  · intro r hr1 hr2
    refine guard_transport_realLimitMCS fam.mcs δ ((s' : ℝ)) (t + δ) ψ ?_ r (by linarith)
      (by linarith)
    intro q hq1 hq2
    by_cases hqp : (q : ℝ) < (p : ℝ)
    · exact hguard q (by exact_mod_cast hq1) (by exact_mod_cast hqp)
    · exact hzguard q (by have := not_lt.mp hqp; linarith) hq2

/-! ## The forward transport -/

/--
**Transport of restricted forward Until/Since coherence to the real bundle.**

Both halves split on selection of the shifted coordinate, and each of the four cases is a landed
lemma: `toRealBundle_forward_until_selected` and `toRealBundle_forward_since_selected` at a
selected target, `toRealBundle_forward_until_unselected` and `toRealBundle_forward_since_unselected`
at an unselected one.

*The residual, named once.* Everything the unselected cases need beyond rational coherence is
`BFMCS.LimitGuardEventual` — one predicate, necessary as well as sufficient, and undischarged here.
It appears as a hypothesis of this composition only; no chronicle instance is stated from it and it
is threaded onto no terminus.

*Binder note.* The composition carries three hypotheses beyond the two coherence predicates and the
guard-eventuality one. `hfc`, `hSf` and `hSb` are the ingredients of the bounded witness, and
`h_lga` is the conclusion of the guard-reach lemma above a gap, written out rather than named
because the module owning that lemma is not extended here. All four are discharged at a chronicle
call site by `cantor_bfmcs_dense_limit_guard_above` and by self-root instantiation of the rational
Since coherence, in the same way `cantor_bfmcs_dense_limit_guard_above` discharges its own. The
backward transport needs none of them because its guard obligations are consumed rather than
produced.
-/
theorem BFMCS.toRealBundle_restricted_forward_until_since {fc : FrameClass}
    (hfc : FrameClass.Dedekind ≤ fc) (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rfuc : B.RestrictedForwardUntilSinceCoherent root)
    (hSf : ∀ fam ∈ B.families, ∀ (t : Rat) (α β : Formula), Formula.snce β α ∈ fam.mcs t →
      ∃ s : Rat, s < t ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, s < p → p < t → β ∈ fam.mcs p)
    (hSb : ∀ fam ∈ B.families, ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, s < t ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, s < p → p < t → β ∈ fam.mcs p) →
      Formula.snce β α ∈ fam.mcs t)
    (h_lga : ∀ fam ∈ B.families, ∀ r : ℝ, (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ χ : Formula,
      χ ∈ limitSetBelow fam.mcs r →
      ∃ c : Rat, r < (c : ℝ) ∧ ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → χ ∈ fam.mcs q)
    (h_lge : B.LimitGuardEventual) :
    (B.toRealBundle).RestrictedForwardUntilSinceCoherent root := by
  rintro G ⟨fam, hfam, δ, rfl⟩
  constructor
  · intro t φ ψ hsub hU
    have hU' : Formula.untl ψ φ ∈ realLimitMCS fam.mcs δ t := hU
    show ∃ s : ℝ, t < s ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, t < r → r < s → ψ ∈ realLimitMCS fam.mcs δ r
    by_cases hx : ∃ p : Rat, (p : ℝ) = t + δ
    · obtain ⟨p, hp⟩ := hx
      exact toRealBundle_forward_until_selected B root h_rfuc fam hfam δ t φ ψ hsub p hp hU'
    · exact toRealBundle_forward_until_unselected hfc B root h_rfuc fam hfam (hSf fam hfam)
        (hSb fam hfam) (h_lga fam hfam) h_lge δ t φ ψ hsub hx hU'
  · intro t φ ψ hsub hS
    have hS' : Formula.snce ψ φ ∈ realLimitMCS fam.mcs δ t := hS
    show ∃ s : ℝ, s < t ∧ φ ∈ realLimitMCS fam.mcs δ s ∧
      ∀ r : ℝ, s < r → r < t → ψ ∈ realLimitMCS fam.mcs δ r
    by_cases hx : ∃ p : Rat, (p : ℝ) = t + δ
    · obtain ⟨p, hp⟩ := hx
      exact toRealBundle_forward_since_selected B root h_rfuc fam hfam δ t φ ψ hsub p hp hS'
    · exact toRealBundle_forward_since_unselected B root h_rfuc fam hfam h_lge δ t φ ψ hsub hx hS'

end FormalSystem.Metalogic.Bundle
