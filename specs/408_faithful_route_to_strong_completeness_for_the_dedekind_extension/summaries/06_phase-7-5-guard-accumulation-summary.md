# Phase 7.5 — the guard-accumulation invariant and the payoff implication (R3d-1)

- **Task**: 408 — faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Plan**: `plans/06_strong-completeness-dedekind-v6.md`, Phase 7.5
- **Type**: lean4, hard mode, single-phase dispatch
- **Date**: 2026-07-27
- **Outcome**: **COMPLETED**. All three chartered deliverables landed sorry-free. Family `Q` is
  **excluded** by the invariant (Outcome A). The Outcome-B trigger did not fire.

## Files touched

| File | Change |
|---|---|
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean` | **new**, 481 lines |
| `FormalSystem/Metalogic/BXCanonical.lean` | one import line |

No construction file was touched. `CounterexampleElimination.lean`, `ChronicleConstruction.lean`,
`ChronicleTypes.lean`, `ChronicleToCountermodelBasic.lean`, `Bundle/RealExtensionBundle.lean` and
every declaration landed by Phases 7.3/7.4 are byte-identical.

## The chosen invariant, verbatim

```lean
structure AscendsToGap (D : Set Rat) (S₀ : Set Rat) : Prop where
  subset    : S₀ ⊆ D
  nonempty  : S₀.Nonempty
  no_max    : ∀ a ∈ S₀, ∃ b ∈ S₀, a < b
  bdd_above : ∃ c ∈ D, ∀ a ∈ S₀, a < c
  ub_no_min : ∀ c ∈ D, (∀ a ∈ S₀, a < c) → ∃ c' ∈ D, (∀ a ∈ S₀, a < c') ∧ c' < c

def CofinalBelowGap (D : Set Rat) (m : Rat → Set Formula) (S₀ : Set Rat) (A : Formula) : Prop :=
  ∀ a ∈ D, (∃ b ∈ S₀, a < b) → ∃ q ∈ D, a < q ∧ (∃ b ∈ S₀, q < b) ∧ A ∈ m q

def NoGuardAccumulation (D : Set Rat) (m : Rat → Set Formula) (G : Set Formula) : Prop :=
  ∀ ψ ∈ G, ∀ φ : Formula, ∀ S₀ : Set Rat, AscendsToGap D S₀ →
    (∀ q ∈ S₀, Formula.neg ψ ∈ m q) →
    ¬ (CofinalBelowGap D m S₀ (Formula.untl φ ψ) ∨ CofinalBelowGap D m S₀ (Formula.snce φ ψ))
```

Phases 7.6-7.9 are held to exactly this form.

### Why this form

1. **Conditioned on the obligation.** The charter's prohibition is respected: the invariant never
   asserts that a closure formula is eventually true below a gap unconditionally (that is false —
   formulas oscillate). `CofinalBelowGap` is the ℚ-level shadow of `BFMCS.LimitGuardEventual`'s own
   antecedent, weak enough that ultrafilter membership implies it.
2. **No mention of `ℝ`.** A gap is a cut of the order — four clauses using only `<`, boundedness,
   maxima and minima, all relative to `D`. This is the order-theoretic characterization of report
   `05 §4.2` written into the statement, and it is what makes the invariant transportable.
3. **Domain-parametric.** `D` is a parameter so that the invariant can be maintained on the finite
   stage domains and on `LimitDom`, and then *pulled back to all of `ℚ`* along an order
   isomorphism. That pull-back is landed here, not deferred: `noGuardAccumulation_transport`.
4. **`Set Formula`, not `Finset Formula`.** `BFMCS.LimitGuardEventual` carries no closure
   hypothesis (deliberately — see its docstring), so the payoff needs `G = Set.univ`. A `Set`
   parameter serves both that use and the finitely-indexed construction-side use;
   `noGuardAccumulation_mono_guards` moves between them.
5. **Literal `¬ψ`-points.** The guard-failure clause is `Formula.neg ψ ∈ m q`, not `ψ ∉ m q`. Under
   maximal consistency these agree (the bridge is `SetMaximalConsistent.negation_complete`, used in
   the payoff exactly as the plan specified), but the `¬ψ` form is the one a state class can carry.

## Deliverables

### D1 — the invariant (P1/P2/P3 all landed)

`NoGuardAccumulation`, above. Deviation from the sketched signature, recorded inline in the plan:
domain parameter `D` added; `Finset Formula` replaced by `Set Formula`. Rationale as in (3), (4).

### D2 — the payoff implication (P1)

```lean
theorem limitGuardEventual_of_noGuardAccumulation {fc : FrameClass} (B : BFMCS (fc := fc) Rat)
    (h : ∀ fam ∈ B.families, NoGuardAccumulation Set.univ fam.mcs Set.univ) :
    B.LimitGuardEventual
```

Sorry-free. The argument is the contrapositive: a guard not eventually true below the unselected
`r` has a failure set cofinal there; `SetMaximalConsistent.negation_complete` turns the failures
into literal `¬ψ`-points; `ascendsToGap_univ_of_cofinal_below` shows they ascend to a gap of `ℚ`
(unselectedness of `r` is used exactly once, to rule out a rational sitting *at* the cut); and
`cofinalBelowGap_of_mem_limitMCSBelow` — a consumer of `limitMCSBelow_cofinal_below` — shows the
surviving `untl`/`snce` obligation is cofinal in that approach. That is the forbidden
configuration. `BFMCS.LimitGuardEventual` is consumed verbatim and is not restated; the ultrafilter
is untouched.

### D2b — satisfiability (P2), landed as Lean

- `AscendsToGap.infinite` — a set ascending to a gap is infinite.
- `noGuardAccumulation_of_finite : D.Finite → NoGuardAccumulation D m G`.
- `noGuardAccumulation_singleton (x : Rat) : NoGuardAccumulation {x} m G` — **stage 0 passes.** The
  initial chronicle stage has a one-point domain, so this is the check the charter demanded, and it
  passes for the structural reason one wants (nothing can accumulate in a finite domain), not
  because the guard set happens to be empty.
- `noGuardAccumulation_of_guard_never_fails` — a second, *infinite-domain* satisfiability witness,
  recorded so that satisfiability is not an artefact of finiteness.

### D3 — the family-`Q` exclusion (P3), landed as Lean

```lean
theorem not_noGuardAccumulation_of_cofinal_guard_failure
    (m : Rat → Set Formula) (G : Set Formula) (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r)
    (φ ψ : Formula) (hψG : ψ ∈ G)
    (hfail : ∀ z : ℝ, z < r → ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < r ∧ Formula.neg ψ ∈ m q)
    (hlive : ∀ z : ℝ, z < r → ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < r ∧ Formula.untl φ ψ ∈ m q) :
    ¬ NoGuardAccumulation Set.univ m G

structure FamilyQShape (m : Rat → Set Formula) (P : Formula) (T : ℝ) : Prop where
  gap : ¬ ∃ q : Rat, (q : ℝ) = T
  guard_fails_cofinally :
    ∀ z : ℝ, z < T → ∃ t : Rat, z < (t : ℝ) ∧ (t : ℝ) < T ∧ Formula.neg (Formula.neg P) ∈ m t
  until_below : ∀ q : Rat, (q : ℝ) < T → Formula.untl P (Formula.neg P) ∈ m q

theorem familyQ_violates_noGuardAccumulation (m : Rat → Set Formula) (P : Formula) (T : ℝ)
    (hQ : FamilyQShape m P T) (G : Set Formula) (hmem : Formula.neg P ∈ G) :
    ¬ NoGuardAccumulation Set.univ m G
```

**Outcome: A — the invariant excludes family `Q`.** `FamilyQShape` is report `05 §5.1`'s family
transcribed as a ℚ-intrinsic hypothesis package: one atom `P`, a gap `T`, the guard `ψ := ¬P`
failing cofinally below `T` along the ascending `P`-points, and `U(P, ¬P)` true at every rational
below `T`. The liveness hypothesis of the general refutation is discharged from `Q`'s own data at
the same witness rationals, so the exclusion is not conditional on anything extra.

**What is not claimed.** Nothing here says family `Q` is unrealizable at `FrameClass.Dedekind`. The
charter explicitly forbade attempting that (it needs EF / modal-depth machinery), and it was not
attempted. `FamilyQShape` is a *shape*, not an existence claim. The invariant excludes the pattern;
whether the pattern is realizable is open, and the docstrings say so.

### Beyond charter — the transport lemma

```lean
theorem noGuardAccumulation_transport {D : Set Rat} (e : Rat → Rat) (hmono : StrictMono e)
    (hmaps : ∀ q : Rat, e q ∈ D) (hsurj : ∀ x ∈ D, ∃ q : Rat, e q = x)
    (m : Rat → Set Formula) (G : Set Formula) (h : NoGuardAccumulation D m G) :
    NoGuardAccumulation Set.univ (fun q => m (e q)) G
```

The charter asked that the invariant be *stated* so as to be transportable through the Cantor
isomorphism. It is stronger to land the transport than to assert transportability, so this is
landed: an invariant established on a countable dense sub-order arrives at `Set.univ` — the form
the payoff consumes — with **no edit to `cantorIsoDense`**. This is the 7.9 consumer, available
four sub-phases early.

## Honesty charter compliance

Every declaration carries a docstring stating the no-source fact. The module docstring states it
first and in full. The only source citations in the module are:

- **ADAPTED-FROM: Burgess 1982 I §2.10, printed pp.372-373** — fresh-point witness placement, cited
  as the discipline whose accumulation behaviour is constrained, never as a source for the
  constraint.
- **ADAPTED-FROM: Burgess 1984 §2.7, printed pp.109-110** — the A7a far-side placement, cited as an
  analogy that carries *no guard*, which is what makes the question here non-trivial.
- **Reynolds 1992, printed p.175** — cited for the `γ⁺` / left-gap *statement being discharged*,
  and explicitly disclaimed for the discharge.

No task-number citations appear in any deliverable file.

## Verification

| Check | Result |
|---|---|
| `lake build …Chronicle.ChronicleGuardAccumulation` | green |
| full `lake build` | green |
| new `sorry` | 0 |
| live sorries outside `Boneyard/` | unchanged: exactly `WeakCanonical/Transfer.lean:1242` |
| vacuous definitions (`:= True` / `:= trivial` / `:= Unit`) | 0 |
| new axioms | 0 |
| `#print axioms limitGuardEventual_of_noGuardAccumulation` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms familyQ_violates_noGuardAccumulation` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms noGuardAccumulation_transport` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms noGuardAccumulation_singleton` | `[propext, Classical.choice, Quot.sound]` |

## What 7.6 inherits

- The invariant form above, frozen.
- `noGuardAccumulation_of_finite` — the stage-0 base case of the induction 7.8 will run, already
  proved, and the reason every *finite* stage is free: the obligation only bites in the limit.
- `noGuardAccumulation_transport` — 7.9's consumer, already proved.
- The falsification target: any `c5_forward_walk` / `c5_backward_walk` insertion discipline that
  produces `FamilyQShape`'s pattern is *detected* by `familyQ_violates_noGuardAccumulation` rather
  than silently tolerated.

The residual risk is therefore concentrated exactly where the plan predicted: the limit step. Every
finite stage satisfies the invariant for free, so 7.8's induction cannot be a routine
"preserved-at-each-step" argument — it must produce a bound uniform in the stage. That is the next
real question, and it is now isolated.
