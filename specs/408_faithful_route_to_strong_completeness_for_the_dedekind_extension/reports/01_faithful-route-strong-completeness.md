# Research Report: Faithful Route to Strong Completeness for `FrameClass.Dedekind`

- **Date**: 2026-07-27
- **Task type**: lean4 (hard mode: H2, H3, H4, H5)
- **Reference grounding tier**: Tier 1 (literature-backed) — Reynolds 1992, verbatim from
  `/home/benjamin/Projects/Literature/sources/reynolds_1992/`
- **Status**: researched

---

## Executive Summary

**Verdict: strong completeness for `FrameClass.Dedekind` is the correct terminus, it is
reachable, and — the finding that reframes this task — it is not harder than weak completeness
in this tree.** `Context` is `List Formula` (`FormalSystem/Syntax/Context.lean:60`), i.e.
*finite*. Finite-context strong completeness and single-formula completeness are
inter-derivable through the deduction theorem, which already exists frame-class-generically
(`Metalogic/Core/DeductionTheorem.lean:325`, `:447`). The premise that motivated this task —
"Reynolds' Theorem 7 delivers only *weak* completeness, so this route may not reach strong
completeness" — is true but does not bite: it bites only for *infinite* Γ, which this tree's
`Context` type cannot express.

**But the engine is a different story, and the blocking reason is one that report 390 did not
surface.** Reynolds' route to a real-flowed model runs through Doets' theorem, whose hypotheses
D1 and D2 are Reynolds' Theorems 4 and 5. Read verbatim, those two theorems invoke
**expressive completeness of {U,S} over Prior structures** at *seven* separate points
(`sec03:30,52,58,70,76,102` and `sec04:31`). Expressive completeness is Reynolds' Theorem 3,
which rests on Theorem 2 (Kamp/Stavi expressive completeness over all linear flows) — a result
Reynolds *cites and does not prove*. Formalizing it is an independently major undertaking,
absent from this tree and from Mathlib. Reynolds' route additionally terminates in an
order-theoretic characterization of ℝ (`sec04:155`) that Mathlib does not have (verified: only
*field*-theoretic uniqueness exists).

**The faithful route is therefore not Reynolds' transfer.** It is the direct construction of the
countermodel on ℝ from a *Dedekind*-MCS, inside the tree's own parametric canonical
architecture — which report 390 already compile-verified instantiates at ℝ with no
modification. The single new mathematical ingredient this needs is the limit-MCS assignment at
points of `ℝ \ X`, and report 390's own Finding 2 establishes that the Prior axioms are exactly
the condition that makes it sound. Those axioms now exist (`ProofSystem/Axioms.lean:377,387,398`).
Section 4 below gives the argument in full.

---

## Finding 1 (decisive): `Context` is finite, so strong completeness is the *cheap* terminus

```lean
-- FormalSystem/Syntax/Context.lean:60
abbrev Context := List Formula
```

Three consequences, each verified against the tree:

**(a) The soundness half is already stated in strong form.** `soundness_dedekind`
(`Metalogic/Soundness.lean:1910`) takes an arbitrary `Γ : Context` and the hypothesis
`h_ctx : ∀ ψ ∈ Γ, TruthAt M Omega τ t ψ`, concluding `TruthAt M Omega τ t φ`. It is *not* a
weak-soundness statement. A weak-completeness terminus would leave the metalogic asymmetric:
strong soundness paired with weak completeness. The strong-completeness terminus is the exact
converse of a theorem the tree already has, which is the strongest available evidence that it
is the right shape.

**(b) The consequence relation is *local*.** `h_ctx` and the conclusion are evaluated at the
*same* `(τ, t)` — as is `SemanticConsequence` (`Semantics/Validity.lean:103-109`). Combined with
`TruthAt M Omega τ t (φ.imp ψ) = (TruthAt … φ → TruthAt … ψ)` (`Semantics/Truth.lean:132`), the
semantic deduction lemma

> `SemanticConsequenceDedekindDense Γ φ ↔ ValidDedekindDense (Γ.foldr Formula.imp φ)`

is a direct induction on the list. No frame-condition reasoning enters; it is pure
propositional bookkeeping.

**(c) The syntactic half already exists and is generic in `fc`.**

```lean
-- Metalogic/Core/DeductionTheorem.lean:325
noncomputable def deductionTheorem {fc : FrameClass} (Γ : Context) (A B : Formula) …
-- Metalogic/Core/DeductionTheorem.lean:447
def deductionConverse {fc : FrameClass} (Γ : Context) (A B : Formula)
    (h : Γ ⊢[fc] A.imp B) : (A :: Γ) ⊢[fc] B
-- Metalogic/Core/DeductionTheorem.lean:467
theorem Derivable.deduction {fc : FrameClass} {Γ} {A B}
    (h : Derivable fc (A :: Γ) B) : Derivable fc Γ (A.imp B)
```

`{fc : FrameClass}` is implicit and unconstrained, so all three instantiate at
`FrameClass.Dedekind` today with zero new work.

**The architecture is therefore:**

```
Γ ⊨_DedDense φ
  ──(semantic deduction lemma, induction on the list)──▶  ⊨_DedDense (Γ.foldr imp φ)
  ──(single-formula engine — Section 4)──────────────────▶  ⊢[Dedekind] [] (Γ.foldr imp φ)
  ──(iterated deductionConverse)─────────────────────────▶  ⊢[Dedekind] Γ φ
```

and `completeness_dedekind φ` is literally `strong_completeness_dedekind [] φ` after
`simp` discharges `∀ ψ ∈ [], _`. Weak completeness falls out as a corollary, as the task
requires, and it does so *definitionally* rather than by a separate proof.

**This is not a dodge and it is not a bridge.** For finite Γ the deduction theorem is the
canonical relationship between local consequence and implication in a Hilbert system; it is the
reason Hilbert systems are formulated with `→` at all. What it is *not* is a proof of
compactness — see Finding 2.

---

## Finding 2 (honest scope boundary): where the "weak" in Reynolds' Theorem 7 actually bites

Reynolds' Theorem 7 (`sec07:5`, printed p.189) reads verbatim:

> **Theorem 7.** *The system **US/R** is sound and weakly complete for the semantics over
> structures with real flow.*

The word "weakly" is load-bearing, and the proof shows precisely where. Step 4 (`sec07:19`):

> Let `k` be one greater than the quantifier depth of the table `α(t)` of `A₀`. We have a
> temporal structure `ℛ`, with flow of time the reals, satisfying the same monadic sentences of
> **quantifier depth at most `k`** as `M` does.

`k` is a function of the *single* input formula `A₀`, and step 2 (`sec07:17`) additionally
discards all atoms not occurring in `A₀`, restricting to a *finite* language. Both bounds are
essential to Doets' theorem (`sec04:43`, which explicitly hypothesizes "a temporal structure in
a **finite** language"). An infinite Γ has unbounded quantifier depth and may use infinitely
many atoms, so the transfer step admits no infinite-context generalization by this method.

Notably, the *input* to Reynolds' construction is already strong: Theorem 1 (`sec02:52`)
states the Burgess–Xu system is "sound and **strongly complete** for the US logic on the class
of all linear frames." Strength is available at step 1 and is destroyed at step 4. That
localizes the barrier exactly.

**Consequence for this tree.** Because `Γ.foldr imp φ` is a *single* formula, `k` is
well-defined and finite for any `Γ : Context`. The barrier is invisible at `List Formula`. It
would become real, and would block this route outright, only if `Context` were changed to
`Set Formula`. That change is not proposed here and should not be undertaken casually: it would
require compactness of the Dedekind-class consequence relation, which is a separate open
question this report does not resolve in either direction. **Stated plainly: this report's
verdict is a verdict about finite-context strong completeness, which is what this tree's types
express.**

---

## Finding 3 (new; not in report 390): the Reynolds route is blocked on expressive completeness

Report 390 identified three preconditions for the Reynolds route (its VERDICT section, "the
input model does not exist", "the Doets machinery is ℤ-specialized"). A verbatim read of
Reynolds §§6-8 surfaces a fourth that dominates all of them.

Doets' theorem (`sec04:43-51`, Theorem 6) has hypotheses D1 and D2. Those are supplied by
Reynolds' Theorem 4 (§6) and Theorem 5 (§7). **Both proofs are built on expressive
completeness.** Verbatim occurrences:

| Location | Verbatim |
|---|---|
| `sec03:30` | "Now by the **expressive completeness** of `U` and `S` there is temporal `R` true in any Prior structure exactly where `ρ(x)` is." |
| `sec03:52` | "Let `B` be the temporal formula saying that the `∼`-class we are now in begins with a point satisfying `R ∧ K⁻(¬R)`. `B` exists by **expressive completeness**." |
| `sec03:58` | "By **expressive completeness**, the formula …" |
| `sec03:70` | "Using **expressive completeness** and `ε`, find `B` which is true at points only if `A` occurs somewhere in their `∼`-class." |
| `sec03:76` | "By **expressive completeness** this is equivalent to a temporal formula." |
| `sec03:102` | "Using `ε` and **expressive completeness** we can find a temporal formula `C` …" |
| `sec04:31` | (Theorem 5 / D2) "Let the temporal formula `C` be true exactly at points who are the left hand end points of their classes. … **We use expressive completeness here.**" |

Expressive completeness of {U,S} over Prior structures is Reynolds' **Theorem 3**
(`sec06:55`). Its proof (`sec06:57`) begins: *"By the expressive completeness of
`{U, S, U', S'}` over all linear structures, it suffices to prove …"* — i.e. it reduces to
**Theorem 2** (`sec06:49`), for which Reynolds says (`sec06:51`): *"This result is mentioned in
[10] without proof. The first published proof — a direct proof — is in [9]."* Theorem 2 is the
Kamp/Stavi expressive-completeness theorem. Reynolds does not prove it.

**Assessment.** Taking the Reynolds route faithfully means formalizing, in Lean, over
`TaskFrame`/`WorldHistory`/`Omega` semantics:

1. the monadic first-order language and the table translation `A ↦ ψ_A` (`sec06:13`);
2. Stavi's connectives `U'`, `S'` with their first-order tables (`sec06:41-46`);
3. Theorem 2 — expressive completeness of `{U,S,U',S'}` over all linear flows;
4. Theorem 3 — the reduction to `{U,S}` over Prior structures;
5. Theorems 4 and 5 (D1, D2) — seven pages resting on (3)-(4);
6. Doets' theorem: `≡_k`, `good`/`very good`, lexicographic sums, **shuffles** (`sec04:69`),
   and two Ehrenfeucht–Fraïssé game lemmas (`sec04:67`, `sec04:147`);
7. the final order-characterization step (`sec04:155`).

**Correction to my own first draft (H4).** I initially wrote that items 1-2 "require a
monadic-FO layer that does not exist in this tree in order-generic form." That is **wrong**, and
a targeted inventory of `WeakCanonical/` refuted it. The following are order-generic today
(`{sig : MonadicSignature}`, arbitrary `LinearOrder` carrier, zero `Int`/`SuccOrder` markers):

- `WeakCanonical/MonadicFO.lean` — `MonadicSignature` (`:60`), `OrderedMonadicStructure`
  (`:189`), `eval` (`:306`), `relativize`/`relativize_correct` (`:551`,`:648`)
- `Kamp/Translation.lean` — `translateEF1_correct` (`:253`), `buildLeft/Right_correct`
- `Kamp/MonadicFormulaMap.lean`, `Kamp/NfDepth0Generalized.lean` (`:1625`), `Kamp/NfZoneDepthK.lean`
- `EFGames/` GHR93 game stack: `CustomGame.lean`, `Decomposition.lean`, `Composition.lean`,
  `TypeFormulas.lean`, `CharacteristicFormula.lean`, `GapDetection.lean` — all order-generic,
  and `StaviNEquiv` (`EFGames/Defs.lean:190`) plus `Expressiveness/Claim1.lean` show existing
  Stavi-side work
- `NEquivalence.lean` — `KEquiv` (`:81`), `orderedSumPt` (`:155`); `Transfer.lean` —
  `k_equiv_preserves_sentence` (`:328`), `truth_transfer` (`:361`)

So items 1, 2, and part of 6 have real assets. **The blocking items are unchanged**: item 3
(Theorem 2, Kamp/Stavi expressive completeness — no top-level statement exists anywhere in the
tree), items 4-5 (which consume item 3 seven times over), the *shuffle* construction, and item
7. Item 3 alone is a landmark formalization. Item 7 is addressed in Finding 4.

Also confirmed by the inventory, sharpening report 390's precondition 3: `good`
(`IntegerModel/GoodStructures.lean:78`) and `VeryGood` (`:86`) are **not** merely
"ℤ-flavoured" — their *bodies* quantify over `ZIntervalStructure sig`, whose fields are
`lo hi : Option ℤ` and `interp : sig.preds → ℤ → Prop` (`:35-42`). They are hard-wired to ℤ and
must be rewritten, not generalized. And `subinterval_finite_of_succ_archimedean` (`:253`) is not
just inapplicable but **false** for dense orders. Reynolds' §8 primitives would have to be
rebuilt from scratch for the dense case.

---

## Finding 4: Mathlib has no order-theoretic characterization of ℝ (verified)

Reynolds' Doets proof ends (`sec04:149-155`):

> Let `ℛ = Σ_{r ∈ ℝ} σ*(r)` and let `R` be the flow of time of `ℛ`. It is clear that `R` is
> dense and does not have end points. In fact `R` is Dedekind complete. … We can also show that
> `R` has a countable dense subflow. … But then `R` being **Dedekind complete, dense, without
> end points and with a countable dense subset must be isomorphic to the reals.**

That final implication — the Cantor–Dedekind order-characterization of ℝ — is **absent from
Mathlib**. Searches (`lean_leansearch`, `lean_leanfinder`) return only:

- `Order.iso_of_countable_dense` (`Mathlib.Order.CountableDenseLinearOrder`) — Cantor's theorem
  for *countable* dense orders without endpoints (i.e. ≅ ℚ, not ≅ ℝ);
- `LinearOrderedField.uniqueOrderRingIso` / `inducedOrderRingIso`
  (`Mathlib.Algebra.Order.CompleteField`) — uniqueness of order-ring isomorphism between
  *conditionally complete linear ordered **fields***.

Every uniqueness result in Mathlib is **field**-theoretic. There is no
`(Dedekind complete) + (dense) + (no endpoints) + (separable) → ≃o ℝ`.

**Why this is load-bearing for this tree specifically.** `ValidDedekindDense`
(`Semantics/Validity.lean:255`) quantifies over `D` carrying `AddCommGroup D`,
`IsOrderedAddMonoid D`, `DenselyOrdered D`, `Nontrivial D`, plus the lub hypothesis. Reynolds'
`ℛ` is a lexicographic sum of arbitrary structures — it carries **no group structure at all**.
To refute `ValidDedekindDense` you must land on a `D` that is an ordered abelian group; ℝ is
the only candidate; and reaching it from `ℛ` requires exactly the missing theorem. This is the
concrete form of report 390's warning that grafting a monadic-FO transfer argument onto
history-indexed semantics is "genuinely new work not present in any source read."

---

## Finding 5: the faithful route — direct Dedekind-MCS countermodel on ℝ

### 5.1 The route

Build the countermodel *on ℝ from the start*, inside the tree's existing parametric canonical
architecture. Never leave that architecture; never construct a monadic-FO layer; never invoke a
transfer theorem.

1. **Dedekind-MCS.** From `¬Derivable FrameClass.Dedekind [] ψ`, obtain
   `h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Dedekind) ψ` and
   `set_lindenbaum` gives an MCS `A` with `ψ.neg ∈ A`. Both are already generic in `fc`
   (`Metalogic/BXCanonical/Completeness.lean:72`, verified by report 390's Finding 7). **This
   sidesteps the Base-MCS trap by construction**: the MCS is of the Dedekind class from the
   first step, so Prior-U/Prior-S/Sep are in it. Obstruction 2 of the task description is
   dissolved, not bridged.

2. **Non-dense branch closes for free.** `Axiom.dense_indicator.minFrameClass = .Dense`
   (`Axioms.lean:~`) and `Dense ≤ Dedekind` (`Axioms.lean`, regression `example` at
   `Dense ≤ Dedekind := by decide`). So the exact non-dense branch of `completeness_dense`
   (`Completeness.lean:268-276`) transcribes verbatim with `FrameClass.Dense` replaced by
   `FrameClass.Dedekind`. Roughly ten lines, mechanical.

3. **Chronicle over a countable dense `X ⊆ ℚ`, unchanged.** The whole chronicle layer is
   already class-generic with `fc` as a real positional parameter:

   | Declaration | Location | `fc` | Carrier |
   |---|---|---|---|
   | `countermodel_dense_enriched` | `BXCanonical/Completeness.lean:133` | `{fc : FrameClass}` | `Rat` |
   | `rootedCantorFmcsDense` | `Chronicle/ChronicleToCountermodelBasic.lean:500` | `(fc : FrameClass)` explicit | `Rat` |
   | `cantorBfmcsDense` | `ChronicleToCountermodelBasic.lean:552` | `(fc : FrameClass)` explicit | `BFMCS (fc := fc) Rat` |
   | `cantor_bfmcs_dense_restricted_tc` / `_buc` / `_fuc` | `:629`, `:680`, `:755` | `(fc : FrameClass)` explicit | `Rat` |

   Instantiating at `FrameClass.Dedekind` needs **no new chronicle theory**. The `Rat` is not
   incidental: Cantor's back-and-forth requires a *countable* dense order without endpoints, so
   this layer cannot be re-run on `ℝ` and should not be. It stays exactly as it is.

4. **The one new ingredient — extend `BFMCS (fc := fc) Rat` to `BFMCS (fc := fc) ℝ`.** The layer
   *beneath* the chronicle is already generic in `D` as well as `fc`:

   ```lean
   -- Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:45
   variable {fc : FrameClass} {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
   -- :417
   theorem fully_restricted_parametric_completeness_from_neg_membership
       (B : BFMCS (fc := fc) D) (root : Formula)
       (h_rtc : B.RestrictedTemporallyCoherent root) … (h_neg_in : φ.neg ∈ fam.mcs t) :
       ¬TruthAt (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B) … φ
   ```

   No `DenselyOrdered`, no `SuccOrder`, no `Rat`. **It accepts `D := ℝ` unchanged.** So the
   entire gap between what exists and what is needed is one declaration: a function
   `BFMCS (fc := fc) Rat → BFMCS (fc := fc) ℝ` extending the family along `ℚ ↪ ℝ`, together with
   its three coherence proofs. Define, at `r ∈ ℝ \ ℚ`,

   > `mcs(r) := { A : ∃ z < r, ∀ y ∈ ℚ ∩ (z, r), A ∈ mcs(y) }`

   (the "eventually true approaching `r` from below" set), with the dual for the past side.

   *Well-definedness and maximality are exactly what the Prior axioms buy.* Reynolds §5,
   printed p.176 (`sec06:27`) defines `γ⁺(A)`: it "holds exactly when `A` remains true for a
   while after now but only up until a gap after which `A` is arbitrarily soon false", and
   `sec06:53` states: *"Call a linear temporal structure a Prior structure if it satisfies all
   substitution instances of Prior-U and Prior-S. It is easy to see that then there are no
   definable gaps."* The proof (`sec06:61`) is one line: *"By Prior-U applied to `B` we have
   `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction."*

   Since `Prior-U`/`Prior-S` are axioms at `FrameClass.Dedekind`, they are in every
   Dedekind-MCS, hence — by the truth lemma the tree already has
   (`Metalogic/Algebraic/ParametricTruthLemma.lean:240`, sorry-free per report 390) — true
   throughout the chronicle model. Therefore **no formula oscillates arbitrarily close to `r`**:
   for each `A`, exactly one of `A`, `A.neg` is eventually constant on some `X ∩ (z, r)`. The
   limit set is consistent (it is a directed union of subsets of MCSs) and negation-complete
   (by the preceding sentence), hence an MCS. The three coherence conditions
   (`TemporallyCoherent`, `ForwardUntilSinceCoherent`, `BackwardUntilSinceCoherent`) then follow
   because Prior-U/Prior-S supply the definable endpoints that forward/backward coherence
   demands — this is precisely the configuration report 390's Finding 2 identified as the sole
   failure mode, together with its stated repair.

   *There are already assets for exactly this argument, and they are order-generic.*
   `Kamp/PriorINF.lean` and `Kamp/DedekindINF.lean` formalize the Prior-axioms-to-definable-
   endpoint content directly, over `{sig : MonadicSignature}` with an arbitrary carrier:
   `HasDefinableINF`/`HasDefinableSUP` (`PriorINF.lean:114`,`:127`),
   `HasAttainedINF`/`HasAttainedSUP` (`:208`,`:260`),
   `HasDedekindINF`/`HasDedekindSUP` (`DedekindINF.lean:136`,`:153`), the shims
   `HasAttainedINF.toHasDedekindINF` (`:172`) and `HasDefinableINF.toHasDedekindINF` (`:185`),
   and — most directly — `prior_hasDedekindINF` / `prior_hasDedekindSUP` (`:232`,`:240`), plus
   `hasDedekindINF_admits_kplus_shape` (`:264`) and
   `hasDefinableINF_incompatible_with_kplus` (`:283`). The `DedekindINF.lean` header notes the
   re-base onto this carrier is deferred. **A planner should read this file first**: it may
   already contain most of step 4's order-theoretic core, in which case the new work is the
   MCS-valued packaging rather than the mathematics.

   One small supporting declaration is missing and will be needed: a named corollary
   *"every `fc`-theorem is true at every point of the parametric canonical model."* It does not
   exist, but it is a one-line composition of `theorem_in_mcs`
   (`Core/MaximalConsistent.lean:491`, generic in `fc`) with the `.mp` of
   `parametric_shifted_truth_lemma` (`Algebraic/ParametricTruthLemma.lean:379`). This is how
   Prior-U/Prior-S get from "in the MCS" to "true in the model", so it is load-bearing, not
   cosmetic.

5. **Assembly.** `ValidDedekindDense` is refuted at `D := ℝ`, which carries
   `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `DenselyOrdered`, `Nontrivial` and (via
   `Real.instConditionallyCompleteLinearOrder`) the lub hypothesis. Report 390 compile-verified
   that `ParametricCanonicalTaskFrame (fc := fc) ℝ` and
   `ParametricCanonicalTaskModel (fc := fc) ℝ` elaborate with zero errors.

6. **Wrap in the deduction-theorem architecture of Finding 1** to reach
   `strong_completeness_dedekind`, with `completeness_dedekind` as the `Γ = []` corollary.

### 5.2 Why this is the faithful route, and Reynolds' transfer the rejected alternative

Apply the user's own test — *"if a proposed step exists only to connect two artifacts the tree
happens to already have, that is evidence the route is wrong."*

| | **Route B (recommended): direct on ℝ** | **Route A (rejected): Reynolds transfer** |
|---|---|---|
| Monadic-FO translation layer | not needed | required (Finding 3, items 1-2) |
| Kamp/Stavi expressive completeness | not needed | required, seven use sites (Finding 3) |
| EF games, shuffles, `≡_k` | not needed | required (Finding 3, item 6) |
| Order-characterization of ℝ | not needed (ℝ is the domain from step 1) | required, **absent from Mathlib** (Finding 4) |
| Group structure on the carrier | free (it *is* ℝ) | must be transported across a missing iso |
| Bimodal graft onto `TaskFrame`/`Omega` | none — stays in the tree's own architecture | the whole transfer must be re-derived over history-indexed semantics |
| New mathematics required | one lemma: the limit-MCS assignment (§5.1 step 4) | items 1-7 |
| Literature grounding of the new part | Reynolds §5 p.176 (Theorem 3 proof, `sec06:53,61`) | Reynolds §§6-9, but with an unproved Theorem 2 at the base |

Route A's items 1-7 exist *only* to connect a countable model to a pre-existing ℝ. Route B
never separates them, so nothing needs connecting. Route A is bridge almost end to end.

**The honest cost of Route B.** Step 4 is new mathematics. Neither Reynolds nor GHR 1994
performs a completion — report 390's Finding 3 established this and it is confirmed here
(`sec04`, `sec07`: Reynolds transfers onto a fixed ℝ; GHR assumes Dedekind completeness as a
frame condition). Route B is faithful to the *tree's* architecture and to Reynolds' *axioms*
and his *no-definable-gaps* lemma, but the limit-MCS construction itself is not transcribed
from a source. It is argued above from Reynolds §5 rather than cited. **This should be stated
in the plan as the single high-risk item, and it is where a `[BLOCKED]` could legitimately
emerge.** It should not be papered over with a `sorry`.

---

## Finding 6: reused assets versus needless bridges

### Genuinely reused (no new work, verified generic)

| Asset | Location | Why it is genuine reuse |
|---|---|---|
| `deductionTheorem`, `deductionConverse`, `Derivable.deduction` | `Core/DeductionTheorem.lean:325,447,467` | `{fc : FrameClass}` implicit and unconstrained; instantiates at `.Dedekind` today |
| `neg_consistent_of_not_derivable` | `BXCanonical/Completeness.lean:72` | generic in `fc` (verified by report 390 Finding 7) |
| `set_lindenbaum`, `SetMaximalConsistent.*`, `theorem_in_mcs` | `Core/MaximalConsistent.lean` | generic in `fc`, used identically by `completeness_dense`/`_discrete` |
| `countermodel_dense_enriched` and its chronicle dependencies | `BXCanonical/Completeness.lean:133-162` | declared `{fc : FrameClass}`, threads `fc` explicitly at `:141`,`:157-159` |
| `ParametricCanonicalTaskFrame/Model`, `parametric_canonical_truth_lemma`, `parametric_shifted_truth_lemma` | `Metalogic/Algebraic/ParametricTruthLemma.lean:240,379` | generic in `D` *and* `fc`; report 390 compile-verified instantiation at `ℝ` |
| `fully_restricted_parametric_completeness_from_neg_membership` | `Algebraic/RestrictedParametricTruthLemma.lean:417` (vars at `:45`) | binders are `{fc} {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` — no `DenselyOrdered`, no `Rat`. **Accepts `D := ℝ` unchanged.** The single most important reuse in the route |
| `theorem_in_mcs` | `Core/MaximalConsistent.lean:491` | generic in `fc`; ~20 existing call sites |
| `HasDefinableINF/SUP`, `HasDedekindINF/SUP`, `prior_hasDedekindINF/SUP` | `Kamp/PriorINF.lean:114,127`; `Kamp/DedekindINF.lean:136,153,232,240` | order-generic; formalize exactly the Prior-axioms-to-definable-endpoint content that Route B step 4 needs |
| `DedekindTemporalFrame.of_conditionallyComplete` | `FrameConditions/FrameClass.lean:287` | derives the `lub_exists` field from `ConditionallyCompleteLinearOrder`; the tree's only `csSup` use, and it lands the ℝ frame condition |
| `Real.instConditionallyCompleteLinearOrder` | `Mathlib.Data.Real.Archimedean` | discharges the `lub` hypothesis of `ValidDedekindDense` directly |
| The non-dense branch of `completeness_dense` | `Completeness.lean:268-276` | transcribes verbatim at `.Dedekind` since `Dense ≤ Dedekind` |
| `soundness_dedekind` | `Metalogic/Soundness.lean:1910` | already strong-form; fixes the exact shape of the completeness converse |

### Needless bridges — do not build

| Proposed bridge | Verdict |
|---|---|
| **Phase-5 gap-freeness bridge: `IsEmpty (Gap D)` ⟺ conditionally complete** (report 390 phase 5) | **DROP.** `ValidDedekindDense` already carries the lub property as an explicit `Prop` hypothesis (`Validity.lean:258`) — there is nothing to bridge *to*. `structure Gap` (`EFGames/Defs.lean:248`) was built for the ℤ/EF-game route: the ℤ side eliminates gaps via *finiteness* of intervals (`subinterval_finite_of_succ_archimedean:253` → `discrete_no_gaps:544`), and the inventory confirms **no `Dedekind completeness ⇒ IsEmpty (Gap T)` lemma exists**. That absence is exactly what makes this look like a gap worth filling — and exactly why it is a bridge. Route B never touches `Gap`: its notion is *definable* gap-freeness (γ⁺ never true), a **consequence of Prior-U via the truth lemma**, not an order-theoretic side condition. Build it only if Route A is revived. Correctly flagged as unauthorized. |
| ℤ-side `good` / `VeryGood` / `ContempEquiv` "generalized" to the dense case | **DROP — and note it is not a generalization but a rewrite.** Their bodies quantify over `ZIntervalStructure sig` with fields `lo hi : Option ℤ`, `interp : sig.preds → ℤ → Prop` (`GoodStructures.lean:35-42,78,86,729`). And `subinterval_finite_of_succ_archimedean` (`:253`) is **false** for dense orders. Route B needs no EF layer at all, so the question does not arise. |
| `countermodel_discrete_reynolds_v2` used as a template | **DROP.** It hard-codes `fc := FrameClass.Discrete` (not a `{fc}` binder) and emits `SuccOrder`/`PredOrder`/`IsSuccArchimedean`/`IsPredArchimedean` in its existential (`IntegerModel/ReynoldsBridge.lean:739`). The correct template is `countermodel_dense_enriched`, which *is* `fc`-generic. |
| Re-running the Cantor back-and-forth layer (`cantorIsoDense`, `cantorZeroDense`, `CantorFDense`) on `ℝ` | **DROP — impossible, and unnecessary.** Cantor's theorem requires a *countable* dense order without endpoints. The chronicle layer stays at `Rat`; only the `D`-generic layer beneath it moves to `ℝ`. Any attempt to lift the chronicle itself to `ℝ` is the wrong seam. |
| A `Base`-MCS → `Dedekind`-MCS transfer lemma | **DROP — and note it is *not* needed.** The trap in `Completeness.lean:182-193` arises only when a countermodel demands an MCS of a class different from the one Lindenbaum produced. Route B produces a Dedekind-MCS at step 1 and feeds it to an `fc`-generic construction. No transfer occurs, so no transfer lemma is needed. |
| A separate `completeness_dedekind` proved independently and then strengthened | **DROP.** `completeness_dedekind` is `strong_completeness_dedekind []`. Proving it separately would duplicate the engine. |

### Genuinely new, and genuinely required

| Item | Why it is not a bridge |
|---|---|
| `SemanticConsequenceDedekindDense` (new def) | Without it the terminus cannot be *stated* — `SemanticConsequence` (`Validity.lean:103`) quantifies over all `D` and cannot express Dedekind-class consequence. It is the hypothesis-and-conclusion of `soundness_dedekind` packaged as a definition; nothing more. |
| Semantic deduction lemma | Pure induction on `List Formula` against `Truth.lean:132`. Required to connect the terminus to any single-formula engine, whichever engine is chosen. |
| `BFMCS (fc := fc) Rat → BFMCS (fc := fc) ℝ` (the limit-MCS extension) + its three coherence proofs | The engine itself. This is the mathematics, not scaffolding. `Kamp/DedekindINF.lean` may already hold its order-theoretic core |
| "Every `fc`-theorem is true at every point of the parametric canonical model" | Load-bearing: it is how Prior-U/Prior-S get from MCS membership to model truth. A one-line composition of `theorem_in_mcs` (`Core/MaximalConsistent.lean:491`) with `parametric_shifted_truth_lemma.mp` (`ParametricTruthLemma.lean:379`), but no such named corollary exists |

---

## Finding 7: relationship to the existing strong-completeness axis

Tasks 361 and 362 are both `not_started`; **neither has a report or plan directory on disk**
(verified: only `specs/362_.../` exists, and it is empty). So there is nothing to defer to yet.
From their state.json descriptions:

- **361** scopes "per-class `semantic_consequence_X` (paralleling `valid`/`valid_discrete` …
  since the current `⊨`/`semantic_consequence` quantifies over ALL ordered abelian groups D, so
  a Discrete/Dense restriction must be defined), the semantic deduction lemma
  (`Γ ⊨ φ ↔ ⊨ Γ.foldr imp φ`), and iterated use of the existing syntactic `deduction_theorem`".
- **362** scopes `strong_completeness_X` for `X ∈ {Base, Dense, Discrete}` "with weak
  completeness re-exposed as the `Γ=[]` corollary".

**This is the same architecture Finding 1 derives independently, and that convergence is
itself evidence it is right.** Stating it plainly, as the task instructs: **the Dedekind case
is a special case of the 361/362 architecture, differing only in the frame class.** The correct
sequencing is:

1. Land 361's architecture (per-class consequence predicate + semantic deduction lemma) as a
   *four*-class family from the outset, including `Dedekind`. The predicate and the lemma are
   frame-class-shaped, not frame-class-specific; adding the fourth instance costs a
   copy-and-adjust of the binder list.
2. Then `strong_completeness_dedekind` is 362's pattern with the Dedekind engine plugged in.

**Do not propose a parallel construction for Dedekind.** The only thing Dedekind does not share
with Base/Dense/Discrete is its engine, and that is Finding 5.

Note one asymmetry 362 will hit: `strong_completeness_base` inherits the live `sorryAx` at
`WeakCanonical/Transfer.lean:1242` (the Base-MCS discrete branch), whereas the Dense and
Discrete instances are clean. Dedekind is on neither side of that: it is blocked on its own
engine, independently.

---

## H3 Reference Grounding — Tier 1 Lemma Mapping Table

Tier 1 (literature-backed). Citations are chunk-relative line anchors into
`/home/benjamin/Projects/Literature/sources/reynolds_1992/` plus Reynolds' printed pages.

| Source | Prop / Location | Lean Identifier | Type Signature / Statement | Status |
|---|---|---|---|---|
| Reynolds 1992 | Thm 7, §9 printed p.189 (`sec07:5`) | — | "US/R is sound and **weakly** complete … over structures with real flow" | Read verbatim. **Not the terminus**; used only to localize where strength is lost (Finding 2) |
| Reynolds 1992 | Thm 1, §4 printed p.171 (`sec02:52`) | — | Burgess–Xu is "sound and **strongly** complete … on the class of all linear frames" | Read verbatim. Shows strength is available at step 1 and destroyed at step 4 |
| Reynolds 1992 | Thm 6 (Doets), §8 printed pp.184-188 (`sec04:43-51`) | `doets_real_transfer` | countable + dense + no endpoints + D1 + D2 ⟹ ∀k, ∃ real-flowed `≡_k` structure | **ABSENT and REJECTED** — Route A. Requires Findings 3 and 4 |
| Reynolds 1992 | Thm 4 (D1), §6 (`sec03:168`) | `contemp_classes_no_gaps` | `∼`-classes do not end in gaps | **ABSENT and REJECTED** — proof uses expressive completeness at `sec03:30,52,58,70,76,102` |
| Reynolds 1992 | Thm 5 (D2), §7 (`sec04:23-25`) | `dense_singleton_classes` | Prior + Sep ⟹ `M/∼` dense has a dense set of singletons | **ABSENT and REJECTED** — "We use expressive completeness here" (`sec04:31`) |
| Reynolds 1992 | Thm 3, §5 printed p.176 (`sec06:55`) | — | `{U,S}` expressively complete over Prior structures | **ABSENT.** The blocking dependency of D1/D2; reduces to Thm 2 |
| Reynolds 1992 | Thm 2, §5 printed p.176 (`sec06:49`) | — | `{U,S,U',S'}` expressively complete over linear flows | **ABSENT.** Reynolds: "mentioned in [10] without proof" (`sec06:51`). Kamp/Stavi |
| Reynolds 1992 | §5 printed p.176 (`sec06:53`) | — | "Call a linear temporal structure a *Prior structure* if it satisfies all substitution instances of Prior-U and Prior-S. It is easy to see that then there are **no definable gaps**." | **PRESENT as axioms** (`Axioms.lean:377,387`). **This is the literature grounding for Route B step 4** |
| Reynolds 1992 | §5 printed p.176 (`sec06:61`) | — | "By Prior-U applied to `B` we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction." | Read verbatim. The one-line proof of no-definable-gaps that Route B step 4 rests on |
| Reynolds 1992 | §5 printed p.176 (`sec06:27`) | — | `γ⁺(A)` "holds exactly when `A` remains true for a while after now but only up until a gap after which `A` is arbitrarily soon false" | Read verbatim. The oscillation pattern Route B step 4 must exclude |
| Reynolds 1992 | Prior-U, printed p.168 | `Axiom.prior_U_gap` | `U(⊤,φ) ∧ F¬φ → U(¬φ ∨ K⁺(¬φ), φ)` | **PRESENT** — `ProofSystem/Axioms.lean:377` |
| Reynolds 1992 | Prior-S, printed p.168 | `Axiom.prior_S_gap` | `S(⊤,φ) ∧ P¬φ → S(¬φ ∨ K⁻(¬φ), φ)` | **PRESENT** — `Axioms.lean:387` |
| Reynolds 1992 | Sep, printed p.168 | `Axiom.sep` | `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)` | **PRESENT** — `Axioms.lean:398`; validity proved (`Soundness.lean`) |
| Reynolds 1992 | Lemma 10, §7 printed p.184 (`sec04:5-19`) | `sound_sep` | Sep valid over real flows; proof by uncountably-many-disjoint-intervals | **PRESENT** — soundness complete per task description |
| Reynolds 1992 | Doets proof, §8 (`sec04:155`) | — | "Dedekind complete, dense, without end points and with a countable dense subset must be isomorphic to the reals" | **ABSENT from Mathlib** (Finding 4). Only field-theoretic uniqueness exists |
| Reynolds 1992 | §8 (`sec04:69`, `:67`, `:147`) | — | shuffles; "lexicographic sums of `k`-equivalent structures are themselves `k`-equivalent"; shuffle-mixing preserves `≡_k` | **ABSENT** — Route A only |
| GHR 1994 ch.10 §10.3 | Lemmas 10.3.5-10.3.8 | — | Dedekind completeness as a standing **hypothesis** on flows, used only to take a supremum | Confirms neither source performs a completion (report 390 Finding 3) |

---

## Adversarial Self-Verification

Applied after the draft was complete, challenging each load-bearing claim.

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `Context = List Formula`, so contexts are finite | `FormalSystem/Syntax/Context.lean:60` | Direct file read (`grep -n "abbrev Context"`) | High |
| `deductionTheorem` / `deductionConverse` / `Derivable.deduction` are generic in `fc` and instantiate at `.Dedekind` with no new work | `Core/DeductionTheorem.lean:325,447,467` — all declared `{fc : FrameClass}` with no `fc`-constraining hypothesis | Direct source read of the three signatures | High |
| `TruthAt` of `imp` is pointwise implication at the same `(τ,t)`, so the semantic deduction lemma is a plain list induction | `Semantics/Truth.lean:132`: `\| Formula.imp φ ψ => TruthAt M Omega τ t φ → TruthAt M Omega τ t ψ` | Direct source read | High |
| `soundness_dedekind` is already stated in strong (arbitrary-Γ) form | `Metalogic/Soundness.lean:1910-1924`: takes `(Γ : Context)` and `h_ctx : ∀ ψ ∈ Γ, TruthAt …` | Direct source read of the full signature | High |
| Reynolds' Thm 7 is explicitly *weak* completeness and the weakness enters at the Doets step via bounded `k` and finite language | `sec07:5` ("sound and weakly complete"), `sec07:17` (discard atoms → finite language), `sec07:19` (`k` = 1 + qdepth of `A₀`'s table), `sec04:43` (Doets hypothesizes a *finite* language) | Verbatim read of both chunks | High |
| Burgess–Xu (Reynolds Thm 1) is *strongly* complete, so strength is available at step 1 | `sec02:52` verbatim | Verbatim read | High |
| Reynolds' D1 and D2 rest on expressive completeness, which he does not prove | Seven verbatim occurrences: `sec03:30,52,58,70,76,102`; `sec04:31`. Reduction chain `Thm 5/4 → Thm 3 (sec06:57) → Thm 2 (sec06:49)`, with `sec06:51` "mentioned in [10] **without proof**" | Verbatim read + `grep -n "expressive"` across `sec03` | High |
| Mathlib lacks the order-theoretic characterization of ℝ | `lean_leansearch` and `lean_leanfinder` both return only `Order.iso_of_countable_dense` (≅ ℚ case) and `LinearOrderedField.uniqueOrderRingIso` / `inducedOrderRingIso` / `OrderRingIso.subsingleton_left/right` — every uniqueness result carries `Field`/`ConditionallyCompleteLinearOrderedField` | Two named rate-limited search tools, results cross-read | High — *absence* proofs are inherently weaker than presence proofs; see Limitation 1 |
| `countermodel_dense_enriched` is generic in `fc`, so a Dedekind-MCS feeds it directly and the Base-MCS trap does not arise | `BXCanonical/Completeness.lean:133` declares `{fc : FrameClass}`; `:141` passes `fc` to `Chronicle.cantorBfmcsDense`; `:157-159` pass `fc` to the three restricted-coherence lemmas | Direct source read of lines 125-162 | High |
| `Dense ≤ Dedekind`, so `dense_indicator` is admissible at `.Dedekind` and the non-dense branch transcribes verbatim | `Axioms.lean`: `LE` instance case `\| .Dense, .Dedekind => True`; regression `example : FrameClass.Dense ≤ FrameClass.Dedekind := by decide`; `Axiom.minFrameClass \| dense_indicator => .Dense` | Direct source read | High |
| The parametric canonical scaffolding instantiates at `ℝ` unmodified | Report 390's compile-verified probe (`noncomputable example (fc : FrameClass) : TaskFrame ℝ := ParametricCanonicalTaskFrame (fc := fc) ℝ`, "zero errors") | **Second-hand** — read from report 390 lines 429-444, not re-run here. See Limitation 2 | Medium |
| Route B step 4 (limit MCS) is well-defined: no formula oscillates arbitrarily close to `r` because Prior-U/Prior-S exclude definable gaps | `sec06:53` ("Prior structure … then there are no definable gaps") + `sec06:61` (the one-line proof) + `sec06:27` (definition of `γ⁺`), combined with the tree's truth lemma `ParametricTruthLemma.lean:240` | Verbatim literature read + report 390's Finding 2 statement of the iff | **Medium** — the *ingredients* are sourced; the *assembly* into a coherent BFMCS over ℝ is my argument, not a transcription. See Limitation 3 |
| **CORRECTED CLAIM.** First draft: "items 1-2 require a monadic-FO layer that does not exist in this tree in order-generic form." | **Refuted.** `WeakCanonical/MonadicFO.lean` (`:60,189,306,551,648`), `Kamp/Translation.lean:253`, `Kamp/MonadicFormulaMap.lean`, `Kamp/NfDepth0Generalized.lean:1625`, `Kamp/NfZoneDepthK.lean`, the whole `EFGames/` GHR93 stack, `KEquiv` (`NEquivalence.lean:81`), `k_equiv_of_iso` (`GoodStructures.lean:97`), `orderedSumPt` (`:155`), `k_equiv_preserves_sentence`/`truth_transfer` (`Transfer.lean:328,361`) are all `{sig : MonadicSignature}` + arbitrary `LinearOrder` carrier with zero Z-markers | Dedicated file-level inventory subagent: `grep -n` signatures + typeclass-hypothesis scan across `WeakCanonical/` | High — claim retracted in Finding 3; **the Route A verdict is unaffected** because it rests on Theorem 2's absence and Finding 4, not on this |
| `good`/`VeryGood`/`ContempEquiv` are hard-wired to ℤ and cannot be generalized, only rewritten | Bodies quantify over `ZIntervalStructure sig` with `lo hi : Option ℤ`, `interp : sig.preds → ℤ → Prop` (`GoodStructures.lean:35-42,78,86,729`); `subinterval_finite_of_succ_archimedean` (`:253`) carries `[SuccOrder][IsSuccArchimedean]` and is *false* for dense orders | Inventory subagent, full signatures read | High |
| `fully_restricted_parametric_completeness_from_neg_membership` accepts `D := ℝ` unchanged — the crux of Route B | `RestrictedParametricTruthLemma.lean:45` `variable {fc : FrameClass} {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`; theorem at `:417`. No `DenselyOrdered`, no `SuccOrder`, no `Rat` | Inventory subagent, signature + variable-block read | High |
| The chronicle layer is `Rat`-bound and must stay there (Cantor needs countability) | `cantorBfmcsDense` returns `BFMCS (fc := fc) Rat` (`ChronicleToCountermodelBasic.lean:552`); the `cantor*Dense` back-and-forth requires countable dense without endpoints | Inventory subagent | High |
| `Kamp/DedekindINF.lean` may already contain Route B step 4's order-theoretic core | `HasDedekindINF/SUP` (`:136,153`), `prior_hasDedekindINF/SUP` (`:232,240`), `hasDedekindINF_admits_kplus_shape` (`:264`), `HasDefinableINF/SUP` (`PriorINF.lean:114,127`) — order-generic, Rabinovich eq 5.2 | Inventory subagent — signatures only, **file contents not read by me** | **Low-Medium** — this is a lead for the planner, not a verified claim. See Limitation 4 |
| No "`fc`-theorems are true everywhere in the canonical model" corollary exists | Inventory found only the membership half (`theorem_in_mcs`, `Core/MaximalConsistent.lean:491`) and the truth-lemma half (`ParametricTruthLemma.lean:240,379`), never composed | Inventory subagent | High |
| The phase-5 gap-freeness bridge is unnecessary | `Validity.lean:258` carries the lub property as an explicit `Prop` hypothesis, so there is no order-theoretic side condition to bridge to; `structure Gap` (`EFGames/Defs.lean:248`) is used only by the ℤ/EF route, which Route B does not touch | Direct source read of both anchors | High |
| Tasks 361/362 have no artifacts to defer to | `specs/362_.../` exists and is empty; `specs/361_.../` does not exist; both `not_started` in `state.json` | `find` + `jq` on `state.json` | High |

### Counter-arguments considered and their resolution

**"Isn't the deduction-theorem reduction just relabelling weak completeness as strong?"**
Partly — and the report says so explicitly rather than hiding it. For finite Γ the two are
inter-derivable, so no mathematical strength is manufactured. What changes, and what the task
asked for, is which theorem is the *terminus*: `strong_completeness_dedekind` is the exact
converse of the strong-form `soundness_dedekind` the tree already has, and
`completeness_dedekind` becomes its `Γ = []` instance rather than a separate result. That is a
real architectural difference, not a cosmetic one. The place where a genuine strengthening
would be required is infinite Γ, and Finding 2 states plainly that this report does not reach
there and that `Context` cannot currently express it.

**"Route B contradicts report 390's Finding 2, which says completion is unsound."**
It does not. Report 390's Finding 2 states an *iff*: completion is sound for the truth lemma
**iff** the model already validates Prior-U/Prior-S. When 390 was written those axioms did not
exist in the tree, so the condition was unsatisfiable and the conclusion was "unsound". They
now exist at `Axioms.lean:377,387` and are in every Dedekind-MCS. The premise changed; the
conclusion follows. This is the single most important reason the verdict differs from 390's.

**"Report 390 recommends the Reynolds route; are you overriding a completed research task?"**
Yes, deliberately, and on new evidence 390 did not have: the expressive-completeness dependency
of D1/D2 (Finding 3, seven verbatim citations) and the Mathlib absence of the ℝ
order-characterization (Finding 4). Report 390's own VERDICT already conditioned its
recommendation — "if the target theorem is strong completeness, this route does not reach it
and the verdict changes." The verdict has changed, and the reasons are stronger than the one
390 anticipated.

### Limitations (stated, not resolved)

1. **Mathlib absence is search-based.** Two search tools agreeing that the order-characterization
   of ℝ is missing is strong but not a proof of absence. A planner should re-confirm with a
   direct `exact?`/`#check` probe before treating it as settled. It affects only Route A, which
   is rejected on independent grounds, so the risk is contained.
2. **The `ℝ`-instantiation probe was not re-run.** I relied on report 390's compile-verified
   claim. Since Route B's entire feasibility rests on it, **Phase 1 of any plan should re-run
   that probe as its first action** — it costs one `lake env lean` invocation and de-risks
   everything downstream.
3. **Route B step 4 is new mathematics.** The no-definable-gaps ingredient is sourced verbatim;
   the construction of a coherent `BFMCS ℝ` from it is not. Specifically unverified: that the
   limit MCS satisfies `ForwardUntilSinceCoherent` and `BackwardUntilSinceCoherent` as the tree
   states them (I read their *role* from report 390's Finding 2, not their Lean definitions).
   A planner must read those three predicates before sizing the phase. **This is the correct
   place for a `[BLOCKED]` if it does not go through — not a `sorry`.**
4. **`Kamp/DedekindINF.lean` was inventoried, not read.** I have its declaration names and
   signatures but not its proofs or its actual coverage. My claim that it "may already hold
   step 4's order-theoretic core" is a lead, not a finding. Its own header records that the
   re-base onto that carrier is deferred, which cuts both ways. Reading it is step 2 of the
   recommended sequence for exactly this reason.
5. **One draft claim was retracted during this pass** (the monadic-FO layer; see the table
   above). It is recorded rather than silently edited out. No other claim changed.

No contradictions between sources required resolution: report 390 and the Reynolds source agree
on all facts; the divergence is in the verdict drawn from them, and its cause is the axiom set
having changed between the two tasks.

---

## Recommended Next Step for the Planner

Sequence the work so that the terminus is `strong_completeness_dedekind` from the first phase
that writes a theorem statement, and so the highest-risk item is reached early enough to
`[BLOCK]` cheaply rather than after sunk cost.

1. **Re-run the ℝ-instantiation probe** (Limitation 2). One `lake env lean` call. Gate.
2. **Read the three coherence predicates** (`TemporallyCoherent`, `ForwardUntilSinceCoherent`,
   `BackwardUntilSinceCoherent`) and state the limit-MCS lemma precisely. Gate — this is the
   `[BLOCKED]` decision point, and it should be reached *before* any of the cheap work below.
3. `SemanticConsequenceDedekindDense` + the semantic deduction lemma. Coordinate with 361 so
   this lands as a four-class family, not a Dedekind-only one.
4. `strong_completeness_dedekind` stated, with the engine as an explicit hypothesis; the
   `Γ = []` corollary `completeness_dedekind` derived immediately. **This phase produces the
   terminus statement even though the engine is still open** — so the target is never in doubt
   and never drifts toward weak completeness.
5. The engine: the limit-MCS construction and the assembled Dedekind countermodel on ℝ.

Steps 3 and 4 are low-risk and mechanical. Step 5 is the whole cost. Step 2 exists to find out
whether step 5 is possible before paying for steps 3-4.

**No phase in this sequence terminates in weak completeness.**
