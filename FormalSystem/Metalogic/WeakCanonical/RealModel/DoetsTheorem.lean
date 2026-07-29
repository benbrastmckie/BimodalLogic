/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.RealModel.ShuffleReal
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Singletons

/-!
# Doets' Theorem — Reynolds §8 Theorem 6

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§8 *"Doets' Theorem"*, printed **pp.185-188**; attributed there to Doets 1987, 3.3.9, with
Reynolds' own note that

> This statement is slightly stronger than Doets' and the proof is a little different because of
> the contemporaneity notion.

## The source statement, verbatim (printed p.185)

> **THEOREM 6** *Suppose that `M` is a temporal structure in a finite language whose flow of time
> is countable, dense and without end points. Suppose further that for any contemporaneous
> equivalence relation `∼` on `M`,*
>
> *D1) the `∼` classes do not end in gaps and*
>
> *D2) if `M/∼` is densely ordered then `M/∼` has a dense set of singletons.*
>
> *Then for all `k < ω`, there is a temporal structure with flow of time the real numbers
> satisfying the same monadic first order sentences of quantifier depth at most `k` as `M` does.*

## What this module lands, and what it does not

This module is the **assembly point** for Block H. Its job is to take the finished Phase 24-28
assets and turn them into the `ℝ`-flow transfer statement that Reynolds' §9 Theorem 7 consumes.
Four layers, bottom-up:

1. **`ℝ`-flow normalization** (`exists_realFlow_witness`). `goodDense` hands back *some* interval
   of `ℝ`. Reynolds' conclusion asks for *the* real line. For a structure with no end points the
   two are the same up to order isomorphism, and the normalization is the same argument
   `exists_ioo_witness` (`GoodDense.lean:713`) already makes for bounded open intervals, with
   `Set.univ` as the target instead of `(c,d)`.
2. **`≅o ℝ ⇒ good`** (`goodDense_of_orderIso_real`). The converse direction: a structure whose
   flow is order-isomorphic to `ℝ` is good, with `Set.univ` as the witnessing interval. This is
   what makes Phase 28's `orderIsoRealOfDedekindDenseSeparable` usable as an *input* to goodness
   rather than only as an output.
3. **The `ℝ`-model transfer** (`goodDense_shuffleReal`, `goodDense_shuffle`). Reynolds' printed
   p.188 chain, composed: `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)` (`kEquiv_shuffle_shuffleReal`, Phase
   27 + `doets_lemma_1_5`), the flow of `Σ_{r∈ℝ} σ*(r)` is `≅o ℝ`
   (`nonempty_orderIso_real_shuffleReal`, Phase 27's five order facts + Phase 28's
   characterization), hence **both** shuffles are good. This is the step the printed proof states
   in one sentence and the step every remaining branch of Theorem 6 routes through.
4. **The theorem** (`doets_theorem_dense`), with D1 and D2 spelled as explicit hypotheses in the
   form Phase 30 consumes them.

## Honesty charter — the state of the main branch

Reynolds' proof of Theorem 6 (printed pp.187-188) is a proof by contradiction whose core is a
**minimality argument over the finite `γ`-palette `G`**: choose `a < b` with `a ≁ b` and `G`
minimal among all such choices, then show `M | (a,b)` is very good — contradicting `a ≁ b` via
Lemma 11. That minimality argument is **not landed here**; see `doets_theorem_dense_core` below,
which carries it as a single named, tracked hypothesis rather than as an unproved assertion
buried in a tactic block. Everything Reynolds routes *through* that argument — the shuffle
identification, the `ℝ`-extension, the order-isomorphism to `ℝ`, and the `ℝ`-flow normalization —
**is** landed here, sorry-free.

## Source-to-implementation map

| Printed source | Implementation |
|---|---|
| p.185, Theorem 6 statement | `doets_theorem_dense` |
| p.185, *"if `M` is good we are done"* | `exists_realFlow_witness` |
| p.186, Lemma 11 | `reynolds_lemma11_no_endpoints` (`GoodDense.lean:1115`) |
| p.187, Lemma 13 | `reynolds_lemma13` (`Shuffle.lean:232`) |
| p.187, *"`M | (⋃I) ≡ₖ Σ_{q∈ℚ} σ(q)`"* | `kEquiv_blocks_shuffle` (`Shuffle.lean:460`) |
| p.188, *"`Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`"* | `kEquiv_shuffle_shuffleReal` (`ShuffleReal.lean:232`) |
| p.188, *"`R` is dense … Dedekind complete … countable dense subflow"* | `isRealLike_shuffleReal` (`ShuffleReal.lean:625`) |
| p.188, *"so `R` is isomorphic to the reals"* | `nonempty_orderIso_real_shuffleReal` (`ShuffleReal.lean:647`) |
| p.188, *"and hence `Σ_{r∈ℝ} σ*(r)` is good"* | `goodDense_shuffleReal` (this module) |
| p.188, the `G`-minimality contradiction | `doets_theorem_dense_core` hypothesis (this module) |
| p.187, *"`M | (c,d) ≡ₖ X + R + Y`"* | `doets_lemma_1_4` (`OrderedSum.lean:46`) |
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-! ## Layer 1 — `ℝ`-flow normalization

Reynolds' conclusion is *"a temporal structure with flow of time the real numbers"*, not *"an
interval of the real numbers"*. `goodDense` supplies the latter. For a structure with no end
points the gap is closed by `exists_orderIso_ioo01_of_ordConnected` (`GoodDense.lean:644`),
exactly as `exists_ioo_witness` closes it for a prescribed bounded open interval.
-/

/--
A `RIntervalStructure` whose flow is **all** of `ℝ`: the shape Reynolds' *"flow of time the real
numbers"* asks for.

`realLine` (`GoodDense.lean:1015`) is the same carrier set assembled from `ℤ`-indexed blocks;
this is the free-standing predicate on an already-built `RIntervalStructure`.
-/
def RIntervalStructure.IsRealFlow (R : RIntervalStructure sig) : Prop :=
  R.carrierSet = Set.univ

/--
**A good structure with no end points has an `ℝ`-flowed `k`-equivalent** (printed p.185,
*"if `M` is good we are done"* — read with the theorem's standing *"whose flow of time is
countable, dense and without end points"*).

Statement source: Reynolds, as quoted. Proof: the same three-step normalization
`exists_ioo_witness` (`GoodDense.lean:713`) makes — non-emptiness and both end-point conditions
travel across `≡ₖ` at `k ≥ 2`, so `exists_orderIso_ioo01_of_ordConnected` applies to the
witnessing interval — with `ℝ` itself as the destination rather than `(c,d)`.
-/
theorem exists_realFlow_witness (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Nonempty M.carrier] [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (hM : goodDense sig k M) :
    ∃ R : RIntervalStructure sig, R.IsRealFlow ∧ KEquiv sig k M (R.toOrdered sig) := by
  obtain ⟨R₀, hR₀⟩ := hM
  haveI hne : Nonempty {x : ℝ // x ∈ R₀.carrierSet} :=
    nonempty_of_kEquiv sig k (le_trans one_le_two hk) hR₀
  haveI : NoMaxOrder {x : ℝ // x ∈ R₀.carrierSet} := noMaxOrder_of_kEquiv sig k hk hR₀
  haveI : NoMinOrder {x : ℝ // x ∈ R₀.carrierSet} := noMinOrder_of_kEquiv sig k hk hR₀
  obtain ⟨φ⟩ := exists_orderIso_ioo01_of_ordConnected R₀.carrierSet R₀.ordConnected
    (by obtain ⟨x⟩ := hne; exact ⟨x.val, x.property⟩)
    (by
      intro x hx
      obtain ⟨y, hy⟩ := exists_gt (⟨x, hx⟩ : {v : ℝ // v ∈ R₀.carrierSet})
      exact ⟨y.val, y.property, hy⟩)
    (by
      intro x hx
      obtain ⟨y, hy⟩ := exists_lt (⟨x, hx⟩ : {v : ℝ // v ∈ R₀.carrierSet})
      exact ⟨y.val, y.property, hy⟩)
  obtain ⟨ψ⟩ : Nonempty (R₀.carrierSet ≃o (Set.univ : Set ℝ)) :=
    ⟨(φ.trans realIsoIoo01.symm).trans univIsoReal.symm⟩
  refine ⟨{ carrierSet := Set.univ
            ordConnected := Set.ordConnected_univ
            interp := fun p x => R₀.interp p (ψ.symm ⟨x, Set.mem_univ x⟩).val }, rfl, ?_⟩
  refine hR₀.trans (k_equiv_of_iso sig k _ _ ψ ?_)
  intro p x
  show R₀.interp p x.val ↔ R₀.interp p (ψ.symm ⟨(ψ x).val, Set.mem_univ _⟩).val
  -- `⟨(ψ x).val, _⟩` is definitionally `ψ x`, but `rw` cannot see through the subtype
  -- coercion here; go through `congrArg` exactly as `exists_ioo_witness` does.
  exact (iff_of_eq (congrArg (R₀.interp p)
    (congrArg Subtype.val (ψ.symm_apply_apply x)))).symm

/-! ## Layer 2 — a flow order-isomorphic to `ℝ` is good

The converse of Layer 1, and the step that makes Phase 28's characterization of `ℝ` an *input*
to goodness. Printed p.188 uses it in exactly this direction: having established that the flow
`R` of `Σ_{r∈ℝ} σ*(r)` *"is isomorphic to the reals"*, Reynolds concludes goodness and feeds it
back into Lemma 11's very-goodness test.
-/

/--
**A structure whose flow is order-isomorphic to `ℝ` is good** (printed p.188).

The witnessing interval is all of `ℝ`, with the predicates transported along the inverse
isomorphism, so the resulting `RIntervalStructure` also satisfies `IsRealFlow`.
-/
theorem goodDense_of_orderIso_real (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (M : OrderedMonadicStructure sig)
    (f : M.carrier ≃o ℝ) : goodDense sig k M := by
  refine ⟨{ carrierSet := Set.univ
            ordConnected := Set.ordConnected_univ
            interp := fun p x => M.interp p (f.symm x) }, ?_⟩
  refine k_equiv_of_iso sig k _ _ (f.trans univIsoReal.symm) ?_
  intro p x
  show M.interp p x ↔ M.interp p (f.symm (f x))
  rw [f.symm_apply_apply]

/--
The `ℝ`-flow strengthening of `goodDense_of_orderIso_real`: the witness produced is literally the
real line, so it already meets Reynolds' *"flow of time the real numbers"* without going back
through `exists_realFlow_witness`.
-/
theorem exists_realFlow_of_orderIso_real (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (M : OrderedMonadicStructure sig) (f : M.carrier ≃o ℝ) :
    ∃ R : RIntervalStructure sig, R.IsRealFlow ∧ KEquiv sig k M (R.toOrdered sig) := by
  refine ⟨{ carrierSet := Set.univ
            ordConnected := Set.ordConnected_univ
            interp := fun p x => M.interp p (f.symm x) }, rfl, ?_⟩
  refine k_equiv_of_iso sig k _ _ (f.trans univIsoReal.symm) ?_
  intro p x
  show M.interp p x ↔ M.interp p (f.symm (f x))
  rw [f.symm_apply_apply]

/-! ## Layer 3 — the `ℝ`-model transfer

Printed p.188, the whole paragraph:

> Now let `σ*` be the extension of `σ` to `ℝ` … By another simple game argument we have
> `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`.
>
> Let `R` be the flow of time of `Σ_{r∈ℝ} σ*(r)`. Clearly `R` is dense and without end points.
> `R` is also Dedekind complete … Also `R` has a countable dense subflow. Thus `R` is isomorphic
> to the reals.

Every clause of that paragraph is a finished theorem by the time this module is reached. What is
added here is the one-line consequence Reynolds leaves implicit and §9 Theorem 7 consumes: the
`ℚ`-shuffle — and hence, by Phase 26, `M | (⋃ I)` — is **good**, with the real line itself as its
flow.

The six hypotheses are exactly `isRealLike_shuffleReal`'s (`ShuffleReal.lean:625`), in the same
spelling: the summands are non-empty, internally dense, internally complete with a least element,
internally separable, and the distinguished colour `γ₁` names a one-point structure.
-/

section RealModelTransfer

variable {ι : Type} (N : ι → OrderedMonadicStructure sig) (γ₁ : ι) (σ : ℚ → ι)

/--
**`Σ_{r∈ℝ} σ*(r)` is good, with flow the real line** (printed p.188, *"Thus `R` is isomorphic to
the reals"*, and the goodness Reynolds immediately draws from it).

Statement source: Reynolds, as quoted. Proof: `nonempty_orderIso_real_shuffleReal` (Phase 27's
five order facts fed to Phase 28's `orderIsoRealOfDedekindDenseSeparable`) followed by
`goodDense_of_orderIso_real`.
-/
theorem goodDense_shuffleReal (k : Nat)
    (hne : ∀ i : ι, Nonempty (N i).carrier)
    (hdense : ∀ i : ι, ∀ x y : (N i).carrier, x < y → ∃ z : (N i).carrier, x < z ∧ z < y)
    (hsum : ∀ i : ι, ∀ s : Set (N i).carrier, s.Nonempty → ∃ u, IsLUB s u)
    (hbot : ∀ i : ι, ∃ b : (N i).carrier, ∀ x : (N i).carrier, b ≤ x)
    (hone : ∀ x y : (N γ₁).carrier, x = y)
    (hsep : ∀ i : ι, ∃ D : Set (N i).carrier, D.Countable ∧
      ∀ x y : (N i).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    goodDense sig k (shuffleReal N γ₁ σ) :=
  (nonempty_orderIso_real_shuffleReal N γ₁ σ hne hdense hsum hbot hone hsep).elim
    (fun f => goodDense_of_orderIso_real sig k _ f)

/--
The `ℝ`-flow form of `goodDense_shuffleReal`: the witness is literally the real line.
-/
theorem exists_realFlow_shuffleReal (k : Nat)
    (hne : ∀ i : ι, Nonempty (N i).carrier)
    (hdense : ∀ i : ι, ∀ x y : (N i).carrier, x < y → ∃ z : (N i).carrier, x < z ∧ z < y)
    (hsum : ∀ i : ι, ∀ s : Set (N i).carrier, s.Nonempty → ∃ u, IsLUB s u)
    (hbot : ∀ i : ι, ∃ b : (N i).carrier, ∀ x : (N i).carrier, b ≤ x)
    (hone : ∀ x y : (N γ₁).carrier, x = y)
    (hsep : ∀ i : ι, ∃ D : Set (N i).carrier, D.Countable ∧
      ∀ x y : (N i).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    ∃ R : RIntervalStructure sig, R.IsRealFlow ∧
      KEquiv sig k (shuffleReal N γ₁ σ) (R.toOrdered sig) :=
  (nonempty_orderIso_real_shuffleReal N γ₁ σ hne hdense hsum hbot hone hsep).elim
    (fun f => exists_realFlow_of_orderIso_real sig k _ f)

/--
**The `ℚ`-shuffle is good** (printed p.188, the two sentences composed).

This is the form the main proof consumes: Reynolds establishes goodness *of the real extension*
and then transports it back along `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)` to the shuffle that Phase 26's
`kEquiv_blocks_shuffle` identifies with `M | (⋃ I)`.
-/
theorem goodDense_shuffle (k : Nat) {S : Finset ι} (hγ : γ₁ ∈ S) (hσ : IsShuffleMap S σ)
    (hne : ∀ i : ι, Nonempty (N i).carrier)
    (hdense : ∀ i : ι, ∀ x y : (N i).carrier, x < y → ∃ z : (N i).carrier, x < z ∧ z < y)
    (hsum : ∀ i : ι, ∀ s : Set (N i).carrier, s.Nonempty → ∃ u, IsLUB s u)
    (hbot : ∀ i : ι, ∃ b : (N i).carrier, ∀ x : (N i).carrier, b ≤ x)
    (hone : ∀ x y : (N γ₁).carrier, x = y)
    (hsep : ∀ i : ι, ∃ D : Set (N i).carrier, D.Countable ∧
      ∀ x y : (N i).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    goodDense sig k (shuffle N σ) :=
  goodDense_of_kEquiv sig k (kEquiv_shuffle_shuffleReal k N hγ hσ)
    (goodDense_shuffleReal N γ₁ σ k hne hdense hsum hbot hone hsep)

/--
**Anything `k`-equivalent to the `ℚ`-shuffle is good, with flow the real line.**

This is the exact shape printed p.187's *"`M | (⋃ I) ≡ₖ Σ_{q∈ℚ} σ(q)`"* needs: `kEquiv_blocks_shuffle`
(`Shuffle.lean:460`) supplies the left-hand `≡ₖ` and this lemma converts it into an `ℝ`-flowed
witness in one step.
-/
theorem exists_realFlow_of_kEquiv_shuffle (k : Nat) {S : Finset ι} (hγ : γ₁ ∈ S)
    (hσ : IsShuffleMap S σ) {P : OrderedMonadicStructure sig}
    (hP : KEquiv sig k P (shuffle N σ))
    (hne : ∀ i : ι, Nonempty (N i).carrier)
    (hdense : ∀ i : ι, ∀ x y : (N i).carrier, x < y → ∃ z : (N i).carrier, x < z ∧ z < y)
    (hsum : ∀ i : ι, ∀ s : Set (N i).carrier, s.Nonempty → ∃ u, IsLUB s u)
    (hbot : ∀ i : ι, ∃ b : (N i).carrier, ∀ x : (N i).carrier, b ≤ x)
    (hone : ∀ x y : (N γ₁).carrier, x = y)
    (hsep : ∀ i : ι, ∃ D : Set (N i).carrier, D.Countable ∧
      ∀ x y : (N i).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    ∃ R : RIntervalStructure sig, R.IsRealFlow ∧ KEquiv sig k P (R.toOrdered sig) := by
  obtain ⟨R, hRflow, hR⟩ :=
    exists_realFlow_shuffleReal N γ₁ σ k hne hdense hsum hbot hone hsep
  exact ⟨R, hRflow, (hP.trans (kEquiv_shuffle_shuffleReal k N hγ hσ)).trans hR⟩

/--
**Anti-vacuity for Layer 3**: the `ℝ`-flow conclusion is genuinely inhabited, at the constant
one-point palette — the degenerate case Reynolds' own `γ₁` clause puts on the main path (printed
p.188, `γ₁` is *"only satisfied by one point structures"*).

The shuffle's carrier is a lexicographic `Sigma` over `ℝ`, not `ℝ`; the witness produced here is
an honest `RIntervalStructure` on `Set.univ` that is `k`-equivalent to it.
-/
theorem exists_realFlow_shuffleReal_point (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) :
    ∃ R : RIntervalStructure sig, R.IsRealFlow ∧
      KEquiv sig k (shuffleReal (sig := sig) (fun _ : PUnit => pointStructure sig) PUnit.unit
        (fun _ => PUnit.unit)) (R.toOrdered sig) :=
  (nonempty_orderIso_real_shuffleReal_point (sig := sig)).elim
    (fun f => exists_realFlow_of_orderIso_real sig k _ f)

end RealModelTransfer

/-! ## Layer 4 — Doets' Theorem

Reynolds' hypotheses D1 and D2 are quantified over *"any contemporaneous equivalence relation
`∼` on `M`"*; the two conclusions are `EndsInGapOnRight`/`EndsInGapOnLeft` (`Defs.lean`) and
`QuotientDenselyOrdered → HasDenseSingletons` (`Singletons.lean:190,200`).

## Which spelling of *"contemporaneous equivalence relation"*, and why it changed

The antecedent is `IsContempEquivDenseCD ε` (`Defs.lean`), the **countable-dense** bundle, not
the unrestricted `IsContempEquivDense ε` an earlier version of this file used. The reason is
forced, not stylistic:

Theorem 6 runs D1 and D2 at `ε := epsDense sig k`, Reynolds' own `ε(x,y)` of §8 Lemma 12. That
`ε` satisfies the unrestricted clause (iii) but satisfies clauses (i) and (ii) **only** at a
countable dense flow — `IsContempEquivDense (epsDense sig k)` is false, with the counterexample
in `EpsilonDense`'s module header. So the antecedent had to weaken to something `epsDense`
actually meets, or Theorem 6 could never apply its own hypotheses. `doetsD1_epsDense` /
`doetsD2_epsDense` below are that application, and they are the ε-adapter Phase 25's deviation
record asked for.

**What this costs, stated plainly.** Weakening an antecedent makes the hypothesis *harder* to
discharge. `no_gaps_dense_prior` / `no_gaps_dense_prior_left` (`NoGaps.lean:901`) and
`dense_singletons_of_sep` (`Singletons.lean:565`) each take the **unrestricted**
`hε : IsContempEquivDense ε`, and `IsContempEquivDense.toCD` runs the wrong way to help — from
`IsContempEquivDenseCD ε` there is no route to `IsContempEquivDense ε`. So whoever discharges
D1/D2 must first make §6 run on the countable-dense bundle.

**That is not a formality, and it has been measured rather than guessed.** Restricting
`IsContempEquivDense`'s clauses in place and propagating the instances through §6 leaves exactly
one irreducible failure: `NoGaps.lean`'s `reynolds_lemma9` projects the clauses at
`surgeredStructure M ε Q t` and demands `DenselyOrdered` of it. That structure collapses a bad
interval to a single `∼`-class, and Lemma 4 (*"no first class in any maximal interval"*)
guarantees the points below the surviving class are removed — so it has adjacent points and is
**not** densely ordered. Supplying the instance as a hypothesis would be worse than leaving it
open: the hypothesis is unsatisfiable in the intended situation, and §6 Theorem 4 would go
vacuous. The attempt is therefore reverted rather than kept, and the obligation is recorded here
in the type of D1/D2 where it cannot be lost.
-/

/-- **D1** — *"the `∼` classes do not end in gaps"* (printed p.185), for every contemporaneous
equivalence relation on `M` and at both ends. -/
def DoetsD1 (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) : Prop :=
  ∀ ε : MonadicFormula sig 2, IsContempEquivDenseCD ε →
    ∀ t : M.carrier, ¬ EndsInGapOnRight M ε t ∧ ¬ EndsInGapOnLeft M ε t

/-- **D2** — *"if `M/∼` is densely ordered then `M/∼` has a dense set of singletons"*
(printed p.185), for every contemporaneous equivalence relation on `M`. -/
def DoetsD2 (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) : Prop :=
  ∀ ε : MonadicFormula sig 2, IsContempEquivDenseCD ε →
    QuotientDenselyOrdered M ε → HasDenseSingletons M ε

/-- **The ε-adapter, D1 half** — D1 applied at Reynolds' own `∼_M`.

This is the step printed p.187 takes silently, and the one Phase 25's deviation record named as
*"the one adapter Phase 29 must supply"*: `epsDense_isContempEquivDenseCD` is what licenses
instantiating *"any contemporaneous equivalence relation on `M`"* at `∼_M` itself. -/
theorem doetsD1_epsDense (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig) (D1 : DoetsD1 sig M)
    (t : M.carrier) :
    ¬ EndsInGapOnRight M (epsDense sig k) t ∧ ¬ EndsInGapOnLeft M (epsDense sig k) t :=
  D1 (epsDense sig k) (epsDense_isContempEquivDenseCD k hk) t

/-- **The ε-adapter, D2 half** — D2 applied at Reynolds' own `∼_M`. -/
theorem doetsD2_epsDense (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig) (D2 : DoetsD2 sig M)
    (hq : QuotientDenselyOrdered M (epsDense sig k)) :
    HasDenseSingletons M (epsDense sig k) :=
  D2 (epsDense sig k) (epsDense_isContempEquivDenseCD k hk) hq

/--
**Failure of goodness produces two inequivalent points** — printed p.187, the opening move of
Theorem 6's proof by contradiction:

> So suppose that `M` is not good. Then `M` is not very good and so there are `a < b` in `M` with
> `a ≁ b`.

Both implications are Lemma 11 (`reynolds_lemma11_no_endpoints`, `GoodDense.lean:1115`) in
contrapositive form: applied at `M` itself for *"`M` is not very good"*, and applied at
`M | (t,u)` for the step from *"`M | (t,u)` is not good"* to *"`t ≁ u`"* — the middle clause of
`SimDense` (`EpsilonDense.lean:128`) asks for very-goodness of `M | (t,u)`, which at a countable
endpointless interval is goodness.

Density of `M` is what supplies `veryGoodDense`'s non-emptiness clause and both end-point
conditions on the open subintervals.
-/
theorem exists_not_simDense_of_not_goodDense (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [Nonempty M.carrier] [DenselyOrdered M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier] (hM : ¬ goodDense sig k M) :
    ∃ a b : M.carrier, a < b ∧ ¬ SimDense sig k M a b := by
  by_contra hcon
  push Not at hcon
  refine hM (reynolds_lemma11_no_endpoints sig k hk M (fun t u htu => ⟨?_, ?_⟩))
  · obtain ⟨c, hc₁, hc₂⟩ := exists_between htu
    exact ⟨⟨c, hc₁, hc₂⟩⟩
  · -- The middle clause of `SimDense t u` is very-goodness of `M | (t,u)`; Lemma 11 upgrades it.
    rcases hcon t u htu with heq | ⟨-, hvg⟩ | ⟨hut, -⟩
    · exact absurd heq (ne_of_lt htu)
    · haveI : Countable (M.openSubinterval sig t u).carrier :=
        (inferInstance : Countable {x : M.carrier // t < x ∧ x < u})
      haveI : Nonempty (M.openSubinterval sig t u).carrier := by
        obtain ⟨c, hc₁, hc₂⟩ := exists_between htu
        exact ⟨⟨c, hc₁, hc₂⟩⟩
      haveI := noMaxOrder_openSubinterval sig M t u
      haveI := noMinOrder_openSubinterval sig M t u
      exact reynolds_lemma11_no_endpoints sig k hk _ hvg
    · exact absurd hut (not_lt.mpr (le_of_lt htu))

/--
**The residual of Reynolds' §8 Theorem 6** — printed pp.187-188, everything after
`exists_not_simDense_of_not_goodDense` has produced `a < b` with `a ≁ b`:

> Now choose `a < b` in `M` with `a ≁ b` and `G` minimal. … Suppose `a < c < d < b` and `c ≁ d`.
> … the classes strictly between them have order type `ℚ` … and by minimality all the `γᵢ ∈ G`
> are dense in `I` … so `M | (⋃I) ≡ₖ` the shuffle … and `M | (c,d) ≡ₖ X + R + Y`. So `M | (a,b)`
> is very good, contradicting `a ≁ b`.

**This is the one gap in Block H, and it is carried here as a single named `sorry` rather than as
an unproved assertion buried in a longer tactic block.** What it still needs, precisely:

1. ~~**The `ε`-adapter.**~~ **Discharged.** D1 and D2 now take `IsContempEquivDenseCD` and
   `epsDense_isContempEquivDenseCD` (`EpsilonDense.lean`) discharges it, so `doetsD1_epsDense`
   and `doetsD2_epsDense` above apply Reynolds' hypotheses at `∼_M` outright. Nothing in the
   residual is blocked on it any more. The obligation it displaced — making §6 run on the
   countable-dense bundle, so that D1/D2 can be *discharged* — is recorded in the D1/D2 section
   header above, together with the measured obstruction at `surgeredStructure`.
2. **The `G`-minimality argument.** Reynolds' *"`G` minimal"* is a minimization over the finite
   `γ`-palette (`gammaSentences`, `EpsilonDense.lean:239`); it has no counterpart in the tree.
3. **The order-type-`ℚ` step.** *"the classes strictly between them have order type `ℚ`"* is
   Cantor's theorem at the `∼`-quotient, fed by D1 (Lemma 13 makes the classes closed intervals)
   and D2 (dense singletons). `Order.iso_of_countable_dense` supplies the isomorphism once the
   quotient is built; the quotient itself is not built.

Everything this residual routes *through* — `kEquiv_blocks_shuffle`, `kEquiv_shuffle_shuffleReal`,
`nonempty_orderIso_real_shuffleReal`, `goodDense_shuffle`, `doets_lemma_1_4` — is landed and
sorry-free.
-/
theorem reynolds_theorem6_contradiction (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [Nonempty M.carrier] [DenselyOrdered M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (D1 : DoetsD1 sig M) (D2 : DoetsD2 sig M)
    {a b : M.carrier} (hab : a < b) (hnsim : ¬ SimDense sig k M a b) : False := by
  sorry

/--
**`M` is good** — Reynolds' §8 Theorem 6 in the form the proof actually establishes: the
*"suppose that `M` is not good"* branch is impossible.
-/
theorem doets_goodDense (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [Nonempty M.carrier] [DenselyOrdered M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (D1 : DoetsD1 sig M) (D2 : DoetsD2 sig M) :
    goodDense sig k M := by
  by_contra hM
  obtain ⟨a, b, hab, hnsim⟩ := exists_not_simDense_of_not_goodDense sig k hk M hM
  exact reynolds_theorem6_contradiction sig k hk M D1 D2 hab hnsim

/--
**Doets' Theorem** — Reynolds 1992, §8 Theorem 6, printed pp.185-188; Doets 1987, 3.3.9.

> *Suppose that `M` is a temporal structure in a finite language whose flow of time is countable,
> dense and without end points. Suppose further that for any contemporaneous equivalence relation
> `∼` on `M`, D1) the `∼` classes do not end in gaps and D2) if `M/∼` is densely ordered then
> `M/∼` has a dense set of singletons. Then for all `k < ω`, there is a temporal structure with
> flow of time the real numbers satisfying the same monadic first order sentences of quantifier
> depth at most `k` as `M` does.*

Reynolds' own note on the attribution (printed p.185): *"This statement is slightly stronger than
Doets' and the proof is a little different because of the contemporaneity notion."*

`hk : 2 ≤ k` is not in the printed statement and is not a strengthening of it: at `k ≤ 1` the
end-point sentences `hasMaxSent`/`hasMinSent` exceed the quantifier depth budget, so *"without
end points"* does not travel across `≡ₖ` and Reynolds' *"flow of time the real numbers"* is not
determined. Every §8 result in this tree carries the same hypothesis.
-/
theorem doets_theorem_dense (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [Nonempty M.carrier] [DenselyOrdered M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (D1 : DoetsD1 sig M) (D2 : DoetsD2 sig M) :
    ∃ R : RIntervalStructure sig, R.IsRealFlow ∧ KEquiv sig k M (R.toOrdered sig) :=
  exists_realFlow_witness sig k hk M (doets_goodDense sig k hk M D1 D2)

end FormalSystem.Metalogic.WeakCanonical
