# Research Report: Task #859

**Task**: 859 - Is the open-future modal ▷ L⁺-definable on the Base and Dense frame classes?
**Started**: 2026-11-04T13:33:00Z
**Completed**: 2026-11-04T15:05:00Z
**Effort**: 1 research round (one compiled-live probe, 419 lines, exit 0, no sorry/error/warning; four held literature sources re-read; one new gadget and one new collapse argument)
**Dependencies**: None beyond the parent round's report (`specs/854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md`) and probe
**Sources/Inputs**: - Codebase (`FormalSystem/PlusLanguage/PlusTruth.lean`, `PlusPasting.lean`, `FormalSystem/OpenLanguage/{Formula,OpenTruth}.lean`, `FormalSystem/Semantics/{TaskFrame,TaskModel,PartialHistory,FrameClassValidity}.lean`, `FormalSystem/Semantics/Frames/{Standard,TranslationProduct}.lean`), the parent round's probe `01_ofut-elimination-and-translation.lean`, literature briefing (`--lit`): Gabbay–Hodkinson–Reynolds 1994 vol. 1 §9.3–9.5, §10.2–10.3, §12.4–12.5; Rabinovich 2014 §2.3 and §7
**Artifacts**: - `specs/859_qtime_open_future_definability_base_dense/reports/01_qtime-open-future-definability.md` (this report)
- `specs/859_qtime_open_future_definability_base_dense/probes/01_ofut-marker-gadget-and-nondefinability.lean` (compiled-live, exit 0, no sorry, no warnings)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **VERDICT: ▷ (and its mirror ◁) is NOT L⁺-definable at `.Base`, and NOT L⁺-definable at
  `.Dense`.** The parent round's class split therefore closes as
  **positive at `.ZTime`/`.RTime`, negative at `.Base`/`.Dense`** — ▷ is a genuine expressive
  extension of L⁺ over non-Dedekind-complete time, not notation for it.
- **The mechanism is a marker gadget, and it is the round's main finding.** The reason nobody
  could build a separator before is that `▷ψ` is past-determined (`ofut_pastDet`), so it can only
  ever express pure-past properties, while every known U/S-inexpressible property (Stavi's `U'`,
  GHR's `γ₀⁺`, `γ_π⁺`) is stated with a quantifier over an interval whose endpoint is a **gap** —
  and U/S has no way to anchor such an interval. The gadget supplies the anchor:

  ```
  θ := ¬m ∧ ⊞m        ν := θ ∨ ⟡θ        R := p ∧ ⊞(ν → p)        Δ' := S(¬(p ∧ ¬R), ¬p)
  ```

  If `m` is false at `t` and true everywhere after, then `θ` holds at **exactly** `t`
  (`theta_eq_iff`), hence `ν` names the closed past `(-∞, t]` (`nu_iff_le`), hence `R` names
  membership in the backward `p`-run of `t` **without naming that run's lower endpoint**
  (`run_iff`). All three are **compiled-live**, on any frame over any duration.
- **`▷` installs the marker for free, because `m` occurs only inside `θ`.** The compiled
  `dofut_probe_iff` gives, exactly and with no slack, on any frame with enough worlds:

  ```
  (∃ ρ ∈ |τ⟩_t, PlusTruthAt M ρ t (θ ∧ Δ'))  ↔  DeltaProp M τ t
  ```

  equivalently `▷(¬(θ ∧ Δ')) ↔ ¬DeltaProp` (`ofut_neg_probe_iff`). So **`▷` computes
  `DeltaProp`**, the ℚ-time shape of GHR's isolation condition on a left `p` gap.
- **`DeltaProp` is not L⁺-expressible on a ℚ-time regular frame**, by a collapse argument
  transposing GHR Lemma 12.4.2 from their flow `T` to `ℚ`: on GHR-nice structures every L⁺
  formula is uniformly equivalent to one of `p, ¬p, ⊤, ⊥`, and two nice ℚ-structures that agree
  on `p(t)` disagree on `DeltaProp` — one whose `p`-runs below `t` have an immediate predecessor
  (run order type `ℤ`), one whose `p`-runs accumulate at the run's lower gap (order type
  `ω + 1 + ω`). Composing with the compiled `not_definable_of_deltaProp_inexpressible` gives the
  verdict. **This collapse step is the one paper step of record** (§Risks).
- **A frame-constraint discovery that shapes every future attempt here**: *Limit* forbids the
  naive permissive ℚ-frame. At a frame whose states are the atom colours alone, distinct states
  are unrelated at all small durations, so over a dense duration a finite-state history is a
  uniformly-discrete step function — no accumulating run structure, hence no gap for `Δ'` to be
  anchored at. The repository's own `colourClock` removes the obstruction: its clock component
  discharges *Limit* and finiteness discharges *Saturation*, leaving the colour component free
  over **every** temporal order. `colourFibre` and its `IsRegular` instance are compiled-live.
- **R3a is vindicated in a changed form and R3b is closed.** R3a's "Stavi/`γ_π⁺`-style candidate
  plus a ℚ-time bisimulation" is exactly what landed, except that the candidate had to be built
  from a marker rather than lifted from the literature, and the invariance half is a *collapse*
  (all L⁺ formulas degenerate to four) rather than a bisimulation. R3b (a ▷-specific elimination
  avoiding full separation) is refuted: the negative verdict rules it out at `.Base`/`.Dense`.

## Context & Scope

**The question, as dispatched.** The parent round proved ▷ L⁺-definable at `.ZTime` and `.RTime`
through Gabbay separation plus the elimination `▷(α ∨ β) ↔ α ∨ ⊡β`, and located the obstruction at
`.Base`/`.Dense` exactly: separation implies expressive completeness (GHR Thm 9.3.1) and U/S is
not expressively complete over ℚ (Rabinovich 2014 §7, held), while ℚ is a `TemporalOrder`. Two
routes were named: **(R3a)** a Stavi/`γ_π⁺`-style candidate `▷φ` plus a ℚ-time bisimulation for
the invariance half; **(R3b)** a ▷-specific elimination avoiding full separation.

**What "definable at a class" means here.** `Definable F` in the probe is the notion the parent
round's class-level results are instances of: a single translation `tr : OpenFormula → PlusFormula`
with `OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr φ)` at every model, world and time of `F`.
Definability at a class is definability at each of its frames (uniformly); refuting it at **one**
frame of the class refutes it for the class. `Sat .Base F` is `F.IsRegular`, and
`Sat .Dense F` is `F.IsRegular ∧ DenselyOrdered ↑F.Duration` (`FrameClassValidity.lean`), so a
single regular ℚ-time frame sits in both and settles both at once. Neither class contains the
witness's refutation of the other: ℚ is neither `IsZTime` (not discrete) nor `IsRTime` (not
Dedekind complete), so nothing here touches the positive half.

**What the tree already had.** `paste`/`paste_agreeUpTo`/`paste_agreeFrom`,
`IsPurePast`/`IsPureFuture` with `truth_congr_agreeUpTo`/`truth_congr_agreeFrom`, and the parent
probe's `PastDet`/`FutDet` elimination. The probe here reuses the agreement vocabulary and the
`|τ⟩_t`-as-equivalence-class facts, and adds no dependency on `paste`: the marker gadget needs
only the existence of **one** world with the right future, which is weaker than pasting.

**Scope.** Expressiveness only. No completeness or decidability claim is made or implied. No file
under `FormalSystem/` or `Tests/` was touched; everything new is under
`specs/859_.../probes/`.

## Literature Proof Structure

**Source**: Gabbay, Hodkinson, Reynolds, *Temporal Logic: Mathematical Foundations and
Computational Aspects*, vol. 1 (1994), §12.4 (`gabbay_1994/ch1202_124-expressive-power.md`, held);
Lemma 12.4.2 and the `γ_π⁺` remark in §12.5.
**Strategy**: indirect — a class of structures on which the weak language collapses to finitely
many formulas, plus two members of that class which the target property separates.

### Step Map

1. Fix a flow `T` with a non-isolated gap — [GHR] Lemma 12.4.2, construction of `T` (a copy of
   `ℤ` for each negative integer, then a copy of `ℤ` for each integer; the only non-isolated gap is
   between the two parts).
2. Define the *nice* `p`-structures over `T`: `p` constant on each little copy of `ℤ`, and every
   point has both `p` and `¬p` in its past and its future — [GHR] Lemma 12.4.2, "nice".
3. Show by induction that every `{U, S}` formula in `p` is uniformly equivalent, on all nice
   structures, to one of `p`, `¬p`, `⊤`, `⊥` — [GHR] Lemma 12.4.2, "An easy induction with
   several cases"; the sample computation given is `U(p, p) ≡ p`.
4. Exhibit two nice structures on which `γ₀⁺(p)` differs while `p` agrees, and conclude that no
   `{U, S}` formula can be `γ₀⁺(p)` — [GHR] Lemma 12.4.2, final two paragraphs.
5. (`γ_π⁺` variant) The same argument with "open intervals of `p` true and of `p` false replacing
   rational numbers in an interval" — [GHR] §12.5.

### Dependencies

- Step 3 depends on Step 2 (both labels cofinal in both directions is what kills `U(p, ¬p)`).
- Step 4 depends on Step 3 and on Step 1 (the non-isolated gap is where the two structures differ).
- Step 5 depends on Steps 2–4 only, not on Step 1's specific `T`.

### Potential Formalization Challenges

- **Step 1 is not reusable as given.** `T` is not the order of any totally ordered abelian group
  (groups are translation-homogeneous; `T` is not), and `F.Duration` is a `TemporalOrder`. The
  transposition used here replaces `T` by `ℚ` and the little copies of `ℤ` by `ℚ`-intervals — see
  F4. `ℚ ×ₗ ℤ` and `ℚ ×ₗ ℚ` are the group-shaped alternatives and work equally well; `ℚ` is
  simplest and is `.Dense`, so it is the one used.
- **Step 3 must be extended to `⊡` and `□`**, which GHR do not have. Translation invariance of
  L⁺ truth on the witness frame does this (F5): `⊡ψ` becomes a Boolean function of the present
  colour and `□ψ` a constant, so both stay inside the four.
- **Step 4's `γ₀⁺` is not what `▷` reaches.** `▷` yields pure-past properties, and `γ₀⁺` is a
  future property; the transposition therefore uses the past-side property `DeltaProp` (F3), which
  is `γ₀⁻`-shaped, and verifies the separation for it directly.

## Findings

### Codebase Patterns

**F1. `▷` is past-determined, `◁` future-determined — for every `OpenFormula`**
(`ofut_pastDet`, `opast_futDet`; compiled, axioms `[propext]`).

```
AgreeUpTo τ σ t → (OpenTruthAt M τ t (▷ψ) ↔ OpenTruthAt M σ t (▷ψ))
AgreeFrom  τ σ t → (OpenTruthAt M τ t (◁ψ) ↔ OpenTruthAt M σ t (◁ψ))
```

This is the structural constraint that was missing from the parent round's R3a and that explains
why R3a had no obvious candidate. A separator for ▷ must be a pair of worlds whose **pasts** are
L⁺-indistinguishable but `▷φ`-distinguishable; no pair differing only in the future can work,
whatever it does to Stavi's connectives. Symmetrically for ◁ and futures. Both halves of the
literature's inexpressibility witnesses sit on the wrong side of the seam as stated, which is why
the gadget below is needed rather than a direct lift.

**F2. The marker gadget** (`theta_eq_iff`, `nu_iff_le`, `run_iff`; compiled).

With two atoms `p` (data) and `m` (marker), and writing `⟡` for `someFuture` and `⊞` for
`allFuture`:

| Declaration | Statement | Mechanism |
|---|---|---|
| `theta_iff` | `θ ↔ MarkedAt` | one unfolding: `θ := ¬m ∧ ⊞m` reads "`m` false here, true after" |
| `theta_eq_iff` | under `MarkedAt M ρ t`: `θ` at `s` ↔ `s = t` | `s < t` dies on `⊞m` at `r := t`; `s > t` dies on `¬m` |
| `nu_iff_le` | under `MarkedAt`: `ν := θ ∨ ⟡θ` at `v` ↔ `v ≤ t` | `θ` is a singleton, so `⟡θ` is "`t` is still ahead" |
| `run_iff` | under `MarkedAt`: `R := p ∧ ⊞(ν → p)` at `v` ↔ `PRun M ρ v t` | `ν` bounds the universal to `(v, t]` |

`theta_eq_iff` is the content: **the point of evaluation is nameable from inside L⁺**, on any frame
over any duration, at the cost of one atom whose future is fixed. `run_iff` is what that buys:
membership in the backward `p`-run of `t` becomes definable *as a bounded universal over a region
named by `ν`*, with no reference to the run's lower endpoint. Over ℚ that endpoint is a gap, and
`U(p, ·)`-style formulas — the only tool U/S has — cannot reach it. This is precisely the step GHR
Lemma 12.4.2 shows `{U, S}` cannot take on its own.

**F3. What `▷` computes** (`DeltaProp`, `delta_iff`, `deltaProp_pastDet`, `dofut_probe_iff`,
`ofut_neg_probe_iff`; compiled, axioms `[propext, Classical.choice, Quot.sound]`).

```
DeltaProp M τ t  :=  ∃ u < t, ¬p(u) ∧ ∀ v ∈ (u, t), p(v) → PRun M τ v t
```

"There is a `¬p` point below `t` from which every `p` point up to `t` already lies in `t`'s
backward `p`-run" — i.e. **`t`'s `p`-run is immediately preceded by a stretch of `¬p`, with no
further `p`-run accumulating at the run's lower gap.** This is GHR's isolation condition on a
*right* `p` gap (`γ₀⁻`), which is the past-side mirror of their `γ₀⁺`, and it is the shape F1 says
a ▷-reachable property must have.

The key syntactic fact is that **`m` occurs in `φ := θ ∧ Δ'` only inside `θ`, and `θ` is the marker
condition itself**. So the existential dual of ▷ gets the marker for free:

- `→`: any `ρ ∈ |τ⟩_t` with `φ` true at `t` satisfies `θ` at `t`, which *is* `MarkedAt`; then
  `delta_iff` reads `Δ'` as `DeltaProp` on `ρ`, and `deltaProp_pastDet` transfers it to `τ`.
- `←`: install the marker and `Δ'` transfers the other way.

Nothing about the chosen world beyond the marker is used, so the equivalence is exact — not an
approximation, not one-directional. In `▷` form inside L^▷: `▷(¬φ) ↔ ¬DeltaProp`.

Three details worth recording, because they are what make the exactness work:
`θ` at `t` already forces `¬m(t)`, so no constraint on `m`'s values in the past is needed;
`ν` is false above `t`, so `R`'s `⊞` sees only past points even though it scans the whole future;
and `Δ'` is an `snce` whose every referenced point is `< t`, so it is past-determined outright.

**F4. The witness frame exists over every duration — and *Limit* is why that needed work**
(`cRel`, `cRel_reflection`, `cRel_comp`, `cRel_serial`, `cRel_zero`, `colourFibre`,
`colourFibre_isRegular`; compiled).

The obvious witness frame is the permissive one: four colours (`p`-bit × `m`-bit), every function
`D → Colour` a history. **It is not regular over a dense duration.** `TaskFrame.Limit` reads
`∀ w u, (∀ x > 0, ∃ y, |y| < x ∧ R w y u) → u = w`, so for `u ≠ w` there is a positive radius
within which `R w · u` fails. Along a history, `R (τ s) (t - s) (τ t)` must hold for all `s, t`;
with finitely many colours this forces a uniform minimum spacing between state changes, so over ℚ
every history is a uniformly-discrete step function. Run order types are then `ℤ`-like, nothing
accumulates, and there is no gap for `Δ'` to be anchored at. (The repository's own
`Frames/Standard.lean` records the same fact from the other side: `permissiveFrame` takes a
`SuccOrder` hypothesis.)

The repository already contains the fix. `colourClock`
(`Semantics/Frames/TranslationProduct.lean`) turns any **finite** reflective, serial,
compositional relation with trivial zero-fibres into a regular frame over **any** temporal order:
states are `Colour × ↑D`, the clock advances with the duration, *Limit* comes from the clock
(`prodRel_limit`, "No Limit hypothesis: the clock supplies it") and *Saturation* from finiteness
(`saturation_of_finite`). Taking

```
cRel w d u  :=  (d = 0 → u = w)
```

— free at every nonzero duration — the four conditions are discharged in the probe
(`cRel_comp` is the only non-trivial one: `0 ≤ x`, `0 ≤ y`, `x + y = 0` forces `x = y = 0`), and
`colourFibre D` is a regular frame over every `D`, `ℚ` included.

Its histories are exactly the arbitrary colour functions with a clock offset. This last step is
read off `prodRel`'s shape (`prodRel R a x b ↔ R a.1 x b.1 ∧ b.2 = a.2 + x`): `t ↦ (f t, c + t)`
respects the task relation iff `cRel (f s) (t - s) (f t)` — vacuous for `t ≠ s` — and
`c + t = (c + s) + (t - s)`, an abelian-group identity. It is stated, not compiled: the
`colourClock` wrapper's internal `Nonempty ↑D` instance blocks `ofReflectiveRegular_taskRel` from
unifying without plumbing this probe does not need (§Risks). Consequence: `hmarkers` holds at
`colourFibre D` for every `D` — the marker future is just another colour function.

**F5. The collapse, and the two witness structures** (paper step; the argument in full).

Fix `D := ℚ` and `F := colourFibre D`. Model: `p ↦` first colour bit, `m ↦` second, every other
atom false; the valuation ignores the clock. Let `N` be the class of histories with the `m`-bit
false everywhere whose `p`-set is a union of maximal runs, each run a `ℚ`-interval (hence with no
endpoints), alternating, with both `p` and `¬p` cofinal in both directions from every point —
GHR's "nice", transposed.

*Claim.* Every L⁺ formula is uniformly equivalent, on `N`, to one of `p`, `¬p`, `⊤`, `⊥`.

By induction. Atoms: `p ↦ p`, `m ↦ ⊥`, every other atom `↦ ⊥`. `imp`/`bot`: Boolean, and the four
are closed under Boolean combination. For `untl α β` with `α, β` among the four, at a point `t`:

| `α` | result | reason |
|---|---|---|
| `⊤` | `⊤` for `β ∈ {p, ¬p, ⊤}`, `⊥` for `β = ⊥` | both labels cofinal upward |
| `⊥` | `⊥` | `(t, s)` is never empty in `ℚ` |
| `p` | `untl p p ≡ p`, `untl p ⊤ ≡ p`, `untl p ¬p ≡ ⊥`, `untl p ⊥ ≡ ⊥` | `p` on `(t, s)` needs `s` inside `t`'s `p`-run, which has no max; the next `¬p` run has no min, so `β = ¬p` is unreachable |
| `¬p` | the mirror | — |

`snce` is the time-reflection of the same table. **These values do not depend on the run order
type** — only on "runs have no endpoints" and "both labels cofinal both ways" — which is exactly
what makes the two structures below indistinguishable. (`untl p p ≡ p` is GHR's own sample
computation; `untl p ¬p ≡ ⊥` is their gap-blindness.)

`stab` and `box` are handled by translation invariance. `colourFibre D`'s worlds are closed under
time translation (shift the colour function and the offset together), and the valuation is
time-independent, so L⁺ truth transports along translations. Hence `⊡ψ` at `(τ, s)` depends only on
the colour at `s` — a Boolean function of the `p`- and `m`-bits, so on `N` (where the `m`-bit is
false) a Boolean function of `p` — and `□ψ`, which quantifies over all worlds, is a constant. Both
land in the four, with the *same* value for every history, which is what "uniformly" needs. ∎

*The two structures.* Both have `t` inside a `p`-run, so both have `p(t)` true.

- **σ**: runs indexed by `ℤ`, alternating, `t` in run `0`. Then `t`'s `p`-run has an immediate
  predecessor run (run `−1`, labelled `¬p`). Take `u` in run `−1`: `¬p(u)`, and `(u, t)` is
  (the rest of run `−1`, all `¬p`) ∪ (run `0` below `t`, all inside `t`'s run). So
  **`DeltaProp` is true.**
- **τ**: runs indexed by `ω + 1 + ω`, alternating, `t` inside the middle run. The middle run has
  `ω`-many predecessor runs and *no immediate predecessor*, so the runs accumulate at `G`, the gap
  at the bottom of `t`'s run. For any `u < t` with `¬p(u)`, `u` lies below `G`, and between `u`'s
  index and the middle there are infinitely many runs, including `p`-runs; a point `v` in such a
  `p`-run has `p(v)` and is not in `t`'s run (there is `¬p` between `v` and `t`). So
  **`DeltaProp` is false.**

Both are in `N`: each run is a `ℚ`-interval, alternation makes both labels cofinal both ways, and
`Σ` over `ℤ` or over `ω + 1 + ω` of copies of `ℚ` is a countable dense order without endpoints,
hence `≅ ℚ` (Cantor). By the claim, `σ` and `τ` satisfy the same L⁺ formulas at `t`; by the
computation they disagree on `DeltaProp`. **So `DeltaProp` is not L⁺-expressible on
`colourFibre (TemporalOrder.of ℚ)`.**

**F6. The conclusion** (`not_definable_of_deltaProp_inexpressible`; compiled).

```
hmarkers → (∀ ψ, ∃ M τ t, ¬m(t) ∧ ¬(DeltaProp M τ t ↔ PlusTruthAt M τ t ψ)) → ¬ Definable F
```

The proof takes `ψ := (tr (▷¬φ)).neg` and contradicts `hinexpr` at it. F4 supplies `hmarkers` at
`colourFibre (TemporalOrder.of ℚ)`, F5 supplies `hinexpr`, and that frame is regular with a
densely ordered duration, so it satisfies `Sat .Base` and `Sat .Dense`. Hence **▷ is not definable
at `.Base` and not definable at `.Dense`.** The mirror for ◁ is the time-reflection throughout
(`opast_futDet` and the reflected gadget); `Semantics/Reversal.lean` and `PlusReversal.lean` are
the transport of record, not exercised here.

### External Resources

All held in the corpus; chunk paths under `/home/benjamin/Projects/Literature/sources/`.

- **GHR 1994 vol. 1, §12.4, Lemma 12.4.2** — `gabbay_1994/ch1202_124-expressive-power.md`: "In
  general linear time, `{U, S}` is not expressively complete. There are even flows of time with a
  single non-isolated gap on which `γ⁺` is not expressible in terms of `{U, S}`." The flow `T`,
  the definition of *nice*, the collapse to `p, ¬p, ⊤, ⊥`, and the two-structure separation.
  **Held.** This is the template F5 transposes; §12.5's `γ_π⁺` remark ("open intervals of `p` being
  true, and open intervals of `p` being false replace rational numbers in an interval") is the
  accumulating-run idea F5's `τ` realizes.
- **GHR 1994 vol. 1, §12.4, Lemma 12.4.1** — same chunk: over flows with **only isolated gaps**,
  `{U, S}` *is* expressively complete, via `U'(A, B) = γ⁺(B) ∧ U(∼B, γ₀⁺(B) ∨ A)`. **Held.** This
  is the boundary: it is why the witness duration must have non-isolated gaps, and why `ℤ ×ₗ ℤ`
  (whose gaps are discretely arranged) would *not* work while `ℚ`, `ℚ ×ₗ ℤ` and `ℚ ×ₗ ℚ` do.
- **GHR 1994 vol. 1, §12.4, Lemma 12.4.7 and §12.5** — same chunk: `{U, S, γ₀±}` is expressively
  complete over general linear time, and `γ₀⁺(p) = U_ng(p, p)`. **Held.** Confirms that `γ₀±` is
  exactly the missing expressive power, which is what `DeltaProp` (a `γ₀⁻` shape) instantiates.
- **Rabinovich 2014, §7** — `rabinovich_2014/chunk_0023.md`: "The temporal logic with the
  modalities Until and Since is not expressively complete for FOMLO over the rationals."
  **Held** (not an UNVERIFIED entry); §2.3 (`chunk_0008.md`) states Kamp's theorem for
  Dedekind-complete chains and names ℚ as not Dedekind complete. **Held.** This is the
  independent corroboration that `ℚ` is on the right side of the boundary; F5 does not depend on
  it, but F5 would be suspect if it contradicted it.
- **GHR 1994 vol. 1, §9.4–9.5** — `gabbay_1994/ch903_94-the-generalized-separation-property.md`:
  the Generalized Separation Theorem (9.4.2) and Corollary 9.5.2. **Held but UNVERIFIED** in the
  briefing. Read and *not* used: it gives separation ⇒ expressive completeness for a family of
  region predicates, which is the parent round's positive direction, not this round's negative one.
- **Repository docstrings**: `TranslationProduct.lean`'s module docstring and `colourClock`
  ("No Limit hypothesis: the clock supplies it"); `Frames/Standard.lean`'s `permissiveFrame`
  signature (`SuccOrder`); `FrameClassValidity.lean`'s `Sat` table.

**One recalled, non-held claim, labelled as such and used only for orientation**: that `▷φ` is
always FOMLO-definable over the ordered sum `τ|≤t ⌢ f` by a Feferman–Vaught/Shelah composition
argument. It is what says a ▷-reachable property must be *some* FOMLO past property, and hence
that a `γ₀±`-shaped target is the right place to look. **It is not used in F1–F6**, and the verdict
does not rest on it.

### Recommendations

**R1. Record the verdict as the completed class split.** Positive at `.ZTime`/`.RTime` (parent
round), negative at `.Base`/`.Dense` (this round). The parent round's "single open item" is closed.
Update 559 and the ROADMAP accordingly (see Decisions).

**R2. The L^▷ proof-system programme (856) is now live, and confined.** Its rationale is intact at
`.Base` and `.Dense` — ▷ says strictly more than L⁺ there, so an L^▷ proof system is not notation
for an L⁺ one — and is empty at `.ZTime`/`.RTime`. 856 should be entered **at `.Base`/`.Dense`
only**, with the ZTime/RTime translation cited as the reason not to bother there.

**R3. A sorry-free path to a fully machine-checked negative verdict exists, and is sizeable.**
Formalize F5: the class `N`, the collapse induction (the `untl`/`snce` table, plus translation
invariance for `⊡`/`□`), the two run-order-type structures over `ℚ`, and the Cantor isomorphism
that realizes them. Estimate: comparable to the parent round's R4 (Gabbay's eight eliminations),
i.e. a multi-phase implementation task, with the `ℚ`-combinatorics (`Σ` over `ω + 1 + ω` of `ℚ`
is `≅ ℚ`) the part Mathlib helps least with. Propose as an implementation task **only if a
consumer needs the machine-checked negative**; the verdict itself does not need it, and the
compiled half already carries the part that was genuinely unknown.

**R4. A cheap, high-value follow-up: compile the "every colour function is a history" step.**
This is one lemma (F4's last paragraph) blocked only by an instance-unification detail in
`colourClock`'s wrapper. Landing it — e.g. by adding a `@[simp]` `colourClock_taskRel` bridge in
`Frames/TranslationProduct.lean`, in the style the module's own docstring recommends ("Each frame
built this way states its own `@[simp]` bridge instead") — would make `hmarkers` compiled rather
than stated, and would leave F5 as the single paper step. Small, self-contained, and useful beyond
this task.

**R5. The marker gadget should be reused, not rediscovered.** `θ`/`ν` give a definable singleton
and a definable closed past on **any** frame over **any** duration, at the cost of one atom. Any
future "is operator X definable" question in this tree — and the dependency-tracing and
independence work generally — can use it to turn an unbounded-quantifier property into an L⁺
formula. It belongs in a context file (see Context Extension Recommendations).

## Decisions

- **D1. The verdict is stated as definite-negative, with its one paper step named.** This matches
  the evidentiary standard the parent round set for the positive half, which rested on GHR
  Thm 10.2.9 as a held theorem statement. The asymmetry is recorded honestly in §Risks: the
  positive half's paper step was *quoting* a held theorem; this one is *deriving* a new argument
  in the style of a held one (GHR Lemma 12.4.2), which is a weaker tier.
- **D2. The frame is `colourFibre` over `ℚ`, not plain `ℚ` with a bare colour-state frame.**
  Forced by *Limit* (F4). Recorded as a decision rather than a detail because the parent round's
  R2 proposed "ℚ the natural first choice, `ℚ ×ₗ ℤ` the natural second" without noticing that the
  *frame* over ℚ, not the duration, was the obstruction.
- **D3. `ℚ` rather than `ℚ ×ₗ ℤ` or `ℚ ×ₗ ℚ`.** All three work (all have non-isolated gaps, so
  GHR Lemma 12.4.1 does not apply). `ℚ` is simplest, is densely ordered so one frame settles both
  `.Base` and `.Dense`, and is the duration the parent round and the task description both name.
  `ℚ ×ₗ ℤ` would settle only `.Base`; `ℚ ×ₗ ℚ` would work for both but adds nothing.
- **D4. `DeltaProp`, not `γ₀⁺` or `γ_π⁺` directly.** Forced by F1: ▷ yields pure-past properties,
  and GHR's `γ⁺`-family is future-side. `DeltaProp` is the past-side (`γ₀⁻`-shaped) transposition,
  and the probe states it semantically so the same declaration serves any frame.
- **D5. `hmarkers`/`hinexpr` as hypotheses rather than a fully instantiated frame.** The same
  design the parent probe used for `SeparationOver`: the frame-independent content compiles, and
  the frame-specific content is named and audited. It also makes the result reusable — any frame
  satisfying the two hypotheses refutes definability there.
- **D6. No `paste` dependency.** The elimination route needed `paste` (and hence regularity) to
  move a world's future onto another's past. The marker gadget needs only *one* world with the
  marker future, which is strictly weaker, so `dofut_probe_iff` carries no `[F.IsRegular]` binder.
  Regularity still enters, through `colourFibre_isRegular`, only to put the witness frame in the
  class.
- **D7. Literature discipline.** Four held chunks are cited; the one UNVERIFIED chunk read
  (§9.4) is explicitly not relied on; the one recalled claim (Feferman–Vaught composition) is
  labelled recalled and excluded from F1–F6.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **F5 (the collapse) is a new argument, not a quoted theorem.** This is the weakest link and the verdict rests on it. | It is written out in full above, case by case: the `untl` table has four rows and each is two lines; `snce` is the reflection; `⊡`/`□` go through one translation-invariance induction. Each case uses only "runs have no endpoints" and "both labels cofinal both ways". It is the transposition of a **held** argument (GHR Lemma 12.4.2) whose conclusion over `ℚ` is independently **held** (Rabinovich §7), so a mistake would have to be one that preserves both. R3 names the formalization that removes the risk entirely. |
| The transposition from GHR's flow `T` to `ℚ` changes the little copies of `ℤ` into `ℚ`-intervals | The collapse computation is redone from scratch above for `ℚ`-runs; the only places the block type enters are "no max/no min inside a run" (true for `ℚ`-intervals) and "the next run has no first point" (likewise). GHR's `U(p, p) ≡ p` and `U(p, ¬p) ≡ ⊥` come out the same. Note the one genuine difference from `T`: over a *discrete* duration `untl α ⊤ ≡ ⊤` (take `s := t + 1`, guard vacuous) where over `ℚ` it is `≡ α` — still inside the four, and `ℚ` is the duration used. |
| "Every colour function is a history" is stated, not compiled, so `hmarkers` is not machine-checked | The claim is one abelian-group identity plus a vacuity (F4, last paragraph), and `prodRel`'s definition is quoted. R4 is the cheap fix. If it were false, `colourFibre` would have *fewer* histories, which would only make `⊡` finer — it would not make `DeltaProp` expressible, but it would break the `←` half of `dofut_probe_iff` at that frame. |
| *Limit* might obstruct the witness structures too, not just the naive frame | It does not: at `colourFibre`, states are `(colour, clock)` and two states with different clock readings are related at exactly one duration, so *Limit* is satisfied with no constraint whatever on how the colour varies (F4). This is precisely `prodRel_limit`'s content, and it is the repository's own lemma. |
| The verdict might be read as contradicting the ZTime/RTime positive | `ℚ` is neither `IsZTime` (not discrete) nor `IsRTime` (not Dedekind complete), and `.ZTime ⊄ .Dense`. The two verdicts are about disjoint frame sets. GHR Lemma 12.4.1 explains the boundary: isolated gaps are fine, non-isolated ones are not. |
| `Definable` as stated is truth-level, while the parent round's results are validity-level | Truth-level definability implies the validity-level transfer, so refuting the truth-level notion is the weaker, correct target for a negative result — a validity-level translation could in principle exist without a truth-level one. **This is a real residual gap**: nothing here refutes a validity-level-only translation at `.Base`/`.Dense`. Recorded as the one thing the verdict does *not* settle. |
| `Classical.choice` in the main theorems read as a weakness | Forced by the statements' Boolean structure (`or`/`neg` are classical in `PlusTruth`), exactly as in the parent probe; the two purely structural results (`ofut_pastDet`, `opast_futDet`) report `[propext]` alone. |

## Tactic Survey Results

Every goal closed on the first or second substantive attempt with structural term proofs
(`forall_congr'`, `imp_congr_right`, `and_congr`, `exists_congr`, `Iff.rfl`) and `rw` with the
clause lemmas. No LeanHammer-style search was needed; `lean_multi_attempt` and
`lean_hammer_premise` were not used. The only automation called was `abel` (and it failed — see the
row below), `decide` for atom distinctness, and `le_antisymm`/`le_add_of_nonneg_right` for the
`Compositional` arithmetic.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `θ` at `s` ↔ `s = t` (`theta_eq_iff`) | `rw [theta_iff]` + `lt_trichotomy` + term proof | success | `MarkedAt`, `allFuture_iff` |
| `ν` at `v` ↔ `v ≤ t` (`nu_iff_le`) | `rw [or_iff, someFuture_iff]` + `lt_or_eq_of_le` | success after one fix | first attempt used `rcases ... | rfl`, which substituted `t` away and broke the later `theta_eq_iff` application; replaced by a named `heq` |
| `R` at `v` ↔ `PRun` (`run_iff`) | `and_congr` + `forall_congr'` + `imp_congr_right` | success | `nu_iff_le`, `allFuture_iff`, `imp_iff` |
| `Δ'` ↔ `DeltaProp` (`delta_iff`) | `rw [snce_iff]` + `exists_congr`/`and_congr` + `not_not` | success | `run_iff`, `neg_iff`, `and_iff` |
| `DeltaProp` past-determined | `intro`/`rintro` + `rw [hag ...]` on each state | success | `AgreeUpTo` |
| `▷` computes `DeltaProp` (`dofut_probe_iff`) | `constructor` + term proofs both ways | success | `theta_iff`, `delta_iff`, `deltaProp_pastDet` |
| non-definability (`not_definable_of_deltaProp_inexpressible`) | `rintro ⟨tr, htr⟩` + `rw` chain + `(not_not).symm` | success | `ofut_neg_probe_iff` |
| `cRel` compositional | `by_cases` + `le_antisymm`/`le_add_of_nonneg_right` | success | needed the `0 ≤ x, 0 ≤ y, x + y = 0 ⇒ x = y = 0` step explicitly |
| `c + t = (c + s) + (t - s)` in `colourHist` | `abel` | **fail** (left `c + t = t + (-1 • s + (c + s))`) | replaced by `add_add_sub_cancel c t s`; the lemma is exact and `abel`'s `-1 • _` normal form on the `TemporalOrder` carrier was the blocker |
| `(colourFibre D).TaskRel ... ` via `ofReflectiveRegular_taskRel` | `exact ... .mpr ⟨_, _⟩` | **fail** (cannot synthesize the five implicit constraint proofs through `colourClock`'s wrapper, whose internal `haveI : Nonempty ↑D` does not match the ambient instance) | dropped the lemma; see R4 for the fix |

## Context Extension Recommendations

- **Topic**: the marker gadget — naming the point of evaluation, and hence a half-line, from
  inside a temporal object language.
- **Gap**: `context/project/logic/` has Kripke-semantics orientation, and the parent round already
  recommended a `separation-and-expressive-completeness.md`. Neither would contain this: the
  gadget is not a separation technique but a way to *simulate a bounded quantifier* in U/S, which
  is what every "is operator X definable" question in this tree runs into. It is also exactly the
  kind of device that is painful to rediscover.
- **Recommendation**: add `context/project/logic/domain/marker-gadget.md` with `θ`/`ν`/`R`'s
  definitions, the three compiled lemmas and the one-line reason each works, the "the marker atom
  must be installable by the operator under test" precondition, and a pointer to
  `specs/859_.../probes/01_*.lean`. Fold the parent round's recommended
  `separation-and-expressive-completeness.md` in alongside it, extended with GHR's isolated/
  non-isolated gap boundary (Lemmas 12.4.1–12.4.2, 12.4.7) and the `ℤ`/`ℝ`/`ℚ`/`ℚ ×ₗ ℤ` status
  table, since that boundary is what decides the class split.
- **Second topic**: the *Limit* constraint as a modelling obstruction.
- **Gap**: nothing records that *Limit* forces finite-state histories over a dense duration to be
  uniformly-discrete step functions, nor that `colourClock` is the sanctioned way around it. This
  cost a detour in this round and will cost it again.
- **Recommendation**: a short subsection in whichever context file covers frame construction,
  pointing at `Frames/Standard.lean`'s `permissiveFrame` (`SuccOrder` hypothesis) and
  `Frames/TranslationProduct.lean`'s `colourClock` as the two ends of the trade-off.

## Appendix

**Search queries used**
- `Read` on `gabbay_1994/ch1202_124-expressive-power.md` (§12.4–12.5, the whole chunk) — Lemmas
  12.4.1–12.4.7, the flow `T`, *nice* structures, `γ_π⁺`.
- `Read` on `gabbay_1994/ch903_94-the-generalized-separation-property.md` (§9.4–9.5) — read and
  set aside (positive direction).
- `Read` on `rabinovich_2014/chunk_0023.md`; `grep -i "rational|Dedekind|Stavi"` across
  `rabinovich_2014/*.md` → `chunk_0008.md` (§2.3, Kamp's theorem), `chunk_0024.md` (Stavi's
  theorem).
- Codebase `grep`: `AgreeUpTo|AgreeFrom|SameState`, `def PlusTruthAt`, `structure TaskModel`,
  `def Compositional|Serial|Limit|Saturation`, `trivialFrame|staticFrame|permissiveFrame`,
  `colourClock`, `ofReflectiveRegular_taskRel`, `WorldHistory.ofTotal`, `FrameClass` `Sat` table.
- lean-lsp: not used for search. The probe was compiled directly against the repository's own
  oleans; the `lean-readiness-context` reported the server reachable, but no LSP-backed lookup was
  needed, so no evidence here rests on a `lean_local_search` empty result.

**Compile command (exit 0; no `sorry`, no `error`, no `warning` in source or log)**
```
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
LEAN_PATH="$LP" ~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean \
  specs/859_qtime_open_future_definability_base_dense/probes/01_ofut-marker-gadget-and-nondefinability.lean
```

**Axiom report** (`#print axioms`): `ofut_pastDet`, `opast_futDet` → `[propext]`; `theta_eq_iff`,
`nu_iff_le`, `run_iff`, `delta_iff`, `dofut_probe_iff`, `ofut_neg_probe_iff`,
`not_definable_of_deltaProp_inexpressible` → `[propext, Classical.choice, Quot.sound]`.

**References**
- D. M. Gabbay, I. M. Hodkinson, M. A. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*, vol. 1 (1994): Thm 9.3.1, Thm 9.4.2, Cor 9.5.2, Thm 10.2.9, Thm 10.3.20,
  Lemmas 12.4.1–12.4.7, §12.5 (`γ_π⁺`, `ρ±`, `U_ng`).
- A. Rabinovich, *A Proof of Kamp's Theorem* (2014), §2.3, §7.
- J. Stavi's connectives, via Gabbay–Pnueli–Shelah–Stavi, as reported in Rabinovich 2014
  `chunk_0024.md` (not read in the original).
- `FormalSystem/Semantics/Frames/TranslationProduct.lean` (`prodRel`, `prodRel_limit`,
  `colourClock`, `colourClock_isRegular`), `Frames/Standard.lean` (`permissiveFrame`),
  `Semantics/TaskFrame.lean` (`Compositional`, `Serial`, `Limit`, `Saturation`,
  `ofReflectiveRegular_taskRel`), `Semantics/PartialHistory.lean` (`WorldHistory.ofTotal`),
  `Semantics/FrameClassValidity.lean` (`FrameClass.Sat`).
- `specs/854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md`
  (the positive half, R2 and R3) and its probe
  `probes/01_ofut-elimination-and-translation.lean`.
