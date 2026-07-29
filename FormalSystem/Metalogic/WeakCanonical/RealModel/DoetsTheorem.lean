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

/-! ## Layer 5 — Reynolds' `G`, and its minimization

Printed p.187, the choice that opens the contradiction:

> Choose `a < b` from `M` such that
>
> - `a ≁ b` and
> - `G = {γᵢ | i = 1, …, s and ∃ ∼-class E strictly between a and b such that M | E ⊨ γᵢ}` has
>   minimal size.

and the use the choice is put to, three sentences later:

> Also, by minimality of `G`, all the `γᵢ`'s in `G` are satisfied densely in `I`.

**Two rendering decisions, both stated rather than assumed.**

*Reynolds' `G` is a set of sentences; this is a `Finset` of normal forms.* `gammaSentences`
(`EpsilonDense.lean:239`) is literally `(goodNFs sig k).toList.map nfToSentence`, so the `γᵢ` and
the elements of `goodNFs sig k` are the same data presented twice. The minimization is done at
the normal-form level because that is where `Finset.card` is available without needing
`nfToSentence` to be injective — and injectivity is not part of what the argument uses. The only
property of the size measure the proof consumes is that it is monotone under inclusion and
strictly so on proper subsets, which `Finset.card` supplies.

*`E` is named by a representative point.* A `∼`-class is `{x | x ∼ e}` for any of its members, so
*"∃ `∼`-class `E` strictly between `a` and `b`"* becomes *"∃ `e` all of whose `∼`-equals lie in
`(a,b)`"* (`ClassStrictlyBetween`). Reynolds' *"strictly between `a` and `b`"* is a condition on
the whole class, not on the representative — the classes are intervals but need not be singletons,
so quantifying over the class is what makes the monotonicity below true.
-/

/-- *"`E` is a `∼`-class strictly between `a` and `b`"* (printed p.187), with the class named by
a representative `e`: every point `∼`-equal to `e` lies strictly inside `(a,b)`.

Stated over the whole class rather than over `e` alone. That is what the source means and it is
also what `gammaBetween_subset` needs: shrinking `(a,b)` must not admit new classes. -/
def ClassStrictlyBetween (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (a b e : M.carrier) : Prop :=
  ∀ x : M.carrier, ContempEquivDense M ε e x → a < x ∧ x < b

/-- **`M | E`** — the substructure of `M` on the `∼`-class of `e`.

`restrictSet` (`Shuffle.lean:409`) is the general set-shaped cut; the tree's other cuts are all
interval-shaped, and a `∼`-class is given here as a set rather than by endpoints. That the classes
*are* intervals is Lemma 13's content and is not needed to state this. -/
def contempClassStructure (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (e : M.carrier) : OrderedMonadicStructure sig :=
  M.restrictSet sig {x : M.carrier | ContempEquivDense M ε e x}

open scoped Classical in
/-- **Reynolds' `G`**, at the pair `(a,b)` — printed p.187. The `γ`-palette entries realized by
some `∼`-class lying strictly between `a` and `b`. -/
noncomputable def gammaBetween (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig) (a b : M.carrier) :
    Finset (NormalForm sig k 0) :=
  (goodNFs sig k).filter fun nf => ∃ e : M.carrier, ClassStrictlyBetween M ε a b e ∧
    NfEvalNf (contempClassStructure sig M ε e) k 0 Fin.elim0 nf

/-- Membership in `G`, unfolded once so no later proof has to re-derive the filter instance. -/
theorem mem_gammaBetween {k : Nat} {ε : MonadicFormula sig 2} {M : OrderedMonadicStructure sig}
    {a b : M.carrier} {nf : NormalForm sig k 0} :
    nf ∈ gammaBetween sig k ε M a b ↔ nf ∈ goodNFs sig k ∧
      ∃ e : M.carrier, ClassStrictlyBetween M ε a b e ∧
        NfEvalNf (contempClassStructure sig M ε e) k 0 Fin.elim0 nf := by
  classical
  simp only [gammaBetween, Finset.mem_filter]

/-- **`G` is monotone in the interval** — narrowing `(a,b)` can only lose classes, never gain
them. This is the one structural fact the minimality argument runs on. -/
theorem gammaBetween_subset {k : Nat} {ε : MonadicFormula sig 2} {M : OrderedMonadicStructure sig}
    {a b a' b' : M.carrier} (hlo : a ≤ a') (hhi : b' ≤ b) :
    gammaBetween sig k ε M a' b' ⊆ gammaBetween sig k ε M a b := by
  intro nf hnf
  obtain ⟨hgood, e, hbet, hev⟩ := mem_gammaBetween.mp hnf
  refine mem_gammaBetween.mpr ⟨hgood, e, ?_, hev⟩
  intro x hx
  exact ⟨lt_of_le_of_lt hlo (hbet x hx).1, lt_of_lt_of_le (hbet x hx).2 hhi⟩

/--
**The choice makes sense** — printed p.187, *"Choose `a < b` from `M` such that `a ≁ b` and `G`
has minimal size"*.

`Finset.card ∘ gammaBetween` maps the (nonempty, by
`exists_not_simDense_of_not_goodDense`) set of `≁`-pairs into `ℕ`, and `ℕ` is well-ordered. So
this is `Nat.find` and nothing more; the only reason it is a named lemma is that Reynolds' phrase
*"The following choice makes sense"* is a proof obligation and this is it.
-/
theorem exists_minimal_gammaBetween (k : Nat) (ε : MonadicFormula sig 2)
    (M : OrderedMonadicStructure sig)
    (hex : ∃ a b : M.carrier, a < b ∧ ¬ SimDense sig k M a b) :
    ∃ a b : M.carrier, a < b ∧ ¬ SimDense sig k M a b ∧
      ∀ a' b' : M.carrier, a' < b' → ¬ SimDense sig k M a' b' →
        (gammaBetween sig k ε M a b).card ≤ (gammaBetween sig k ε M a' b').card := by
  classical
  set P : Nat → Prop := fun n => ∃ a b : M.carrier, a < b ∧ ¬ SimDense sig k M a b ∧
    (gammaBetween sig k ε M a b).card = n with hP
  have hPex : ∃ n, P n := by
    obtain ⟨a, b, hab, hns⟩ := hex
    exact ⟨(gammaBetween sig k ε M a b).card, a, b, hab, hns, rfl⟩
  obtain ⟨a, b, hab, hns, hcard⟩ := Nat.find_spec hPex
  refine ⟨a, b, hab, hns, ?_⟩
  intro a' b' hab' hns'
  rw [hcard]
  exact Nat.find_le ⟨a', b', hab', hns', rfl⟩

/--
**Minimality forces equality** — the step printed p.187 compresses into *"by minimality of `G`"*.

For `a < c < d < b` with `c ≁ d`, `G(c,d) ⊆ G(a,b)` by `gammaBetween_subset` and
`|G(a,b)| ≤ |G(c,d)|` by minimality, so the inclusion is an equality: **every** `γ` of the
minimal palette is already realized by a class strictly inside `(c,d)`.
-/
theorem gammaBetween_eq_of_minimal {k : Nat} {ε : MonadicFormula sig 2}
    {M : OrderedMonadicStructure sig} {a b : M.carrier}
    (hmin : ∀ a' b' : M.carrier, a' < b' → ¬ SimDense sig k M a' b' →
      (gammaBetween sig k ε M a b).card ≤ (gammaBetween sig k ε M a' b').card)
    {c d : M.carrier} (hac : a ≤ c) (hcd : c < d) (hdb : d ≤ b)
    (hns : ¬ SimDense sig k M c d) :
    gammaBetween sig k ε M c d = gammaBetween sig k ε M a b :=
  Finset.eq_of_subset_of_card_le (gammaBetween_subset hac hdb) (hmin c d hcd hns)

/--
**All the `γᵢ` in `G` are satisfied densely in `I`** — printed p.187, the sentence the shuffle
construction consumes:

> Also, by minimality of `G`, all the `γᵢ`'s in `G` are satisfied densely in `I`.

*Densely* is unpacked into the form the construction uses: given any sub-pair `c ≤ c' < d' ≤ d`
that is itself a `≁`-pair, every `γ` of the minimal palette is realized by a `∼`-class lying
strictly inside `(c',d')`. Since the classes strictly between `c` and `d` are Reynolds' `I`, this
says exactly that each `γ ∈ G` recurs in every subinterval of `I` cut out by a `≁`-pair — density
in `I`.

It is a corollary of `gammaBetween_eq_of_minimal` applied at `(c',d')` rather than at `(c,d)`,
which is why minimality has to be carried as a hypothesis about *all* `≁`-pairs and not merely
about the one pair `(c,d)`.
-/
theorem gammaBetween_dense_of_minimal {k : Nat} {ε : MonadicFormula sig 2}
    {M : OrderedMonadicStructure sig} {a b : M.carrier}
    (hmin : ∀ a' b' : M.carrier, a' < b' → ¬ SimDense sig k M a' b' →
      (gammaBetween sig k ε M a b).card ≤ (gammaBetween sig k ε M a' b').card)
    {c' d' : M.carrier} (hac' : a ≤ c') (hc'd' : c' < d') (hd'b : d' ≤ b)
    (hns' : ¬ SimDense sig k M c' d')
    {nf : NormalForm sig k 0} (hnf : nf ∈ gammaBetween sig k ε M a b) :
    ∃ e : M.carrier, ClassStrictlyBetween M ε c' d' e ∧
      NfEvalNf (contempClassStructure sig M ε e) k 0 Fin.elim0 nf := by
  have hmem : nf ∈ gammaBetween sig k ε M c' d' := by
    rw [gammaBetween_eq_of_minimal hmin hac' hc'd' hd'b hns']
    exact hnf
  exact (mem_gammaBetween.mp hmem).2

/-! ## Layer 6 — `M/∼` as a linear order, and the order type of Reynolds' `I`

Printed p.187:

> Since we have density of `M / ∼`, the classes in `I = {E | E is a ∼-class strictly between c and
> d}` have order type `ℚ`.

**Why a quotient type is constructed here when §6/§7 deliberately avoid one.** `Singletons.lean`'s
header states the §6/§7 convention outright: *"All four are stated below directly in terms of `∼`
itself, with no quotient type constructed"*, and for `QuotientDenselyOrdered` /
`HasDenseSingletons` that is right — each is a property of `∼` on `M`, expressible pointwise.
*"Order type `ℚ`"* is not of that kind. It is a statement about `I` **as an ordered set**: it
asserts an order isomorphism, so there must be a type carrying the order for the isomorphism to
land on. `Order.iso_of_countable_dense` cannot be applied to a pointwise predicate.

So this layer builds `M/∼` — and nothing above it needs to, which is why it lives here rather
than in `Singletons.lean`. The two §6/§7 predicates are used **unchanged** as the hypotheses of
the results below; `QuotientDenselyOrdered` is exactly what supplies `DenselyOrdered (M/∼)`, and
that is the whole reason it was stated pointwise in the first place.

**What the order needs, and what it does not.** The order on classes is well defined precisely
because classes are convex — clause (ii) of *"contemporaneous equivalence relation"*. Together
with clause (i) (`Equivalence`) that is all of it: `IsConvexEquiv` below bundles the two at a
**single** structure `M`, which is what `IsContempEquivDenseCD` yields at a countable dense flow.
Clause (iii) is not used, and neither is D1 — D1's role is upstream, in establishing
`QuotientDenselyOrdered` from Lemma 13, and that step is not this layer's.
-/

/-- The two clauses of *"contemporaneous equivalence relation"* the quotient order needs, taken at
one structure: `∼` is an equivalence and its classes are convex.

Bundling them at a single `M` (rather than quantifying over all structures, as
`IsContempEquivDense` and `IsContempEquivDenseCD` do) is what lets the quotient type below depend
on one proof term. `isConvexEquiv_of_contempEquivDenseCD` is the bridge from Reynolds' `ε`. -/
structure IsConvexEquiv (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2) : Prop where
  /-- Clause (i) at `M`. -/
  equiv : Equivalence (ContempEquivDense M ε)
  /-- Clause (ii) at `M`: classes are convex. -/
  convex : ∀ a b c : M.carrier, a ≤ b → b ≤ c →
    ContempEquivDense M ε a c → ContempEquivDense M ε a b

/-- Reynolds' `ε` gives `IsConvexEquiv` at every countable dense flow — the two clauses of
`IsContempEquivDenseCD` read at one structure.

Not named `IsContempEquivDenseCD.atStructure`: `IsContempEquivDenseCD` is declared in the
`DenseModelSurgery` namespace, so a declaration of that name here would sit in a different
namespace and could never be reached by dot notation. -/
theorem isConvexEquiv_of_contempEquivDenseCD {ε : MonadicFormula sig 2}
    (hε : IsContempEquivDenseCD ε) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] : IsConvexEquiv M ε :=
  ⟨hε.equiv M, hε.convex M⟩

/-- **`a`'s class lies strictly below `b`'s** — the relation `M/∼` is ordered by, before it is
known to descend to the quotient. -/
def ContempLtPt (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (a b : M.carrier) : Prop :=
  a < b ∧ ¬ ContempEquivDense M ε a b

namespace IsConvexEquiv

variable {ε : MonadicFormula sig 2} {M : OrderedMonadicStructure sig}

/-- **`ContempLtPt` is `∼`-invariant in both arguments** — the well-definedness fact the quotient
order rests on, and the only place convexity is used essentially.

The content is that two distinct classes are *totally* separated, not merely separated at the
chosen representatives: if `a < b` with `a ≁ b`, then every member of `a`'s class is below every
member of `b`'s. Convexity is what rules out the interleaving that would otherwise be possible. -/
theorem ltPt_congr (h : IsConvexEquiv M ε) {a a' b b' : M.carrier}
    (ha : ContempEquivDense M ε a a') (hb : ContempEquivDense M ε b b')
    (hlt : ContempLtPt M ε a b) : ContempLtPt M ε a' b' := by
  obtain ⟨hab, hnab⟩ := hlt
  have hna'b' : ¬ ContempEquivDense M ε a' b' := fun hc =>
    hnab (h.equiv.trans ha (h.equiv.trans hc (h.equiv.symm hb)))
  refine ⟨?_, hna'b'⟩
  rcases lt_trichotomy a' b' with hlt' | heq' | hgt'
  · exact hlt'
  · exact absurd (heq' ▸ h.equiv.refl a') hna'b'
  · -- `b' < a'` is impossible: it forces `a ∼ b`.
    exfalso
    rcases lt_or_ge a b' with hab' | hb'a
    · -- `a < b' < a'` with `a ∼ a'`, so `a ∼ b'` by convexity.
      have hab'' : ContempEquivDense M ε a b' :=
        h.convex a b' a' (le_of_lt hab') (le_of_lt hgt') ha
      exact hnab (h.equiv.trans hab'' (h.equiv.symm hb))
    · -- `b' ≤ a < b` with `b' ∼ b`, so `b' ∼ a` by convexity.
      have hb'a' : ContempEquivDense M ε b' a :=
        h.convex b' a b hb'a (le_of_lt hab) (h.equiv.symm hb)
      exact hnab (h.equiv.trans (h.equiv.symm hb'a') (h.equiv.symm hb))

/-- The setoid of `∼` on `M`. -/
def setoid (h : IsConvexEquiv M ε) : Setoid M.carrier where
  r := ContempEquivDense M ε
  iseqv := h.equiv

/-- **`M/∼`** — the type of `∼`-classes. -/
abbrev ClassQuot (h : IsConvexEquiv M ε) : Type := Quotient h.setoid

/-- The class of a point. -/
abbrev cls (h : IsConvexEquiv M ε) (x : M.carrier) : h.ClassQuot := Quotient.mk h.setoid x

theorem cls_eq_cls_iff (h : IsConvexEquiv M ε) {a b : M.carrier} :
    h.cls a = h.cls b ↔ ContempEquivDense M ε a b := Quotient.eq

/-- The strict order on `M/∼`, descended from `ContempLtPt` by `ltPt_congr`. -/
def classLt (h : IsConvexEquiv M ε) : h.ClassQuot → h.ClassQuot → Prop :=
  Quotient.lift₂ (ContempLtPt M ε) fun _ _ _ _ ha hb =>
    propext ⟨fun hh => h.ltPt_congr ha hb hh,
      fun hh => h.ltPt_congr (h.equiv.symm ha) (h.equiv.symm hb) hh⟩

@[simp] theorem classLt_cls (h : IsConvexEquiv M ε) {a b : M.carrier} :
    h.classLt (h.cls a) (h.cls b) ↔ ContempLtPt M ε a b := Iff.rfl

theorem classLt_irrefl (h : IsConvexEquiv M ε) (A : h.ClassQuot) : ¬ h.classLt A A :=
  Quotient.inductionOn A fun a hh => absurd hh.1 (lt_irrefl a)

theorem classLt_trans (h : IsConvexEquiv M ε) {A B C : h.ClassQuot} :
    h.classLt A B → h.classLt B C → h.classLt A C := by
  refine Quotient.inductionOn₃ A B C fun a b c hab hbc => ?_
  obtain ⟨hab₁, hab₂⟩ := hab
  obtain ⟨hbc₁, _⟩ := hbc
  exact ⟨lt_trans hab₁ hbc₁,
    fun hac => hab₂ (h.convex a b c (le_of_lt hab₁) (le_of_lt hbc₁) hac)⟩

theorem classLt_trichotomous (h : IsConvexEquiv M ε) (A B : h.ClassQuot) :
    h.classLt A B ∨ A = B ∨ h.classLt B A := by
  refine Quotient.inductionOn₂ A B fun a b => ?_
  by_cases hab : ContempEquivDense M ε a b
  · exact Or.inr (Or.inl (Quotient.sound hab))
  · rcases lt_trichotomy a b with hlt | heq | hgt
    · exact Or.inl ⟨hlt, hab⟩
    · exact absurd (heq ▸ h.equiv.refl a) hab
    · exact Or.inr (Or.inr ⟨hgt, fun hc => hab (h.equiv.symm hc)⟩)

open scoped Classical in
/-- **`M/∼` is a linear order.** `classLt` is irreflexive, transitive and trichotomous, so this is
`linearOrderOfSTO` and nothing more. -/
noncomputable instance instLinearOrderClassQuot (h : IsConvexEquiv M ε) :
    LinearOrder h.ClassQuot :=
  letI : IsTrans h.ClassQuot h.classLt := ⟨fun _ _ _ => h.classLt_trans⟩
  letI : IsIrrefl h.ClassQuot h.classLt := ⟨h.classLt_irrefl⟩
  letI : IsTrichotomous h.ClassQuot h.classLt := ⟨fun a b hab hba => by
    rcases h.classLt_trichotomous a b with hc | hc | hc
    · exact absurd hc hab
    · exact hc
    · exact absurd hc hba⟩
  letI : IsStrictOrder h.ClassQuot h.classLt := {}
  letI : IsStrictTotalOrder h.ClassQuot h.classLt := {}
  letI : DecidableRel h.classLt := fun _ _ => Classical.dec _
  linearOrderOfSTO h.classLt

theorem cls_lt_cls (h : IsConvexEquiv M ε) {a b : M.carrier} :
    h.cls a < h.cls b ↔ ContempLtPt M ε a b := Iff.rfl

/-- **A point strictly inside `(c,d)` and inequivalent to both ends has its whole class inside** —
convexity again, and the workhorse of every density argument below. -/
theorem classStrictlyBetween_of_between (h : IsConvexEquiv M ε) {c d e : M.carrier}
    (hce : c < e) (hed : e < d) (hnce : ¬ ContempEquivDense M ε c e)
    (hned : ¬ ContempEquivDense M ε e d) : ClassStrictlyBetween M ε c d e := by
  intro x hx
  refine ⟨?_, ?_⟩
  · rcases lt_or_ge c x with hcx | hxc
    · exact hcx
    · -- `x ≤ c ≤ e` with `x ∼ e` forces `x ∼ c`, hence `c ∼ e`.
      have hxc' : ContempEquivDense M ε x c :=
        h.convex x c e hxc (le_of_lt hce) (h.equiv.symm hx)
      exact absurd (h.equiv.trans (h.equiv.symm hxc') (h.equiv.symm hx)) hnce
  · rcases lt_or_ge x d with hxd | hdx
    · exact hxd
    · exact absurd (h.convex e d x (le_of_lt hed) hdx hx) hned

/-- Reynolds' `I` as a predicate on `M/∼`: *"`E` is a `∼`-class strictly between `c` and `d`"*.
`ClassStrictlyBetween` is `∼`-invariant because it quantifies over the whole class. -/
def ClassStrictlyBetweenQ (h : IsConvexEquiv M ε) (c d : M.carrier) : h.ClassQuot → Prop :=
  Quotient.lift (ClassStrictlyBetween M ε c d) fun a b hab =>
    propext ⟨fun hh x hx => hh x (h.equiv.trans hab hx),
      fun hh x hx => hh x (h.equiv.trans (h.equiv.symm hab) hx)⟩

@[simp] theorem classStrictlyBetweenQ_cls (h : IsConvexEquiv M ε) {c d e : M.carrier} :
    h.ClassStrictlyBetweenQ c d (h.cls e) ↔ ClassStrictlyBetween M ε c d e := Iff.rfl

/-- **Reynolds' `I`** (printed p.187) — *"`I = {E | E is a ∼-class strictly between c and d}`"*,
as an ordered type: the classes strictly inside `(c,d)`, ordered as a subtype of `M/∼`. -/
abbrev ClassBetween (h : IsConvexEquiv M ε) (c d : M.carrier) : Type :=
  {A : h.ClassQuot // h.ClassStrictlyBetweenQ c d A}

/-- A class strictly between `c` and `d` has its representative strictly between them. -/
theorem lt_of_classStrictlyBetween (h : IsConvexEquiv M ε) {c d e : M.carrier}
    (hbet : ClassStrictlyBetween M ε c d e) : c < e ∧ e < d :=
  hbet e (h.equiv.refl e)

/-- A class strictly between `c` and `d` is distinct from `c`'s class and from `d`'s. -/
theorem not_contempEquiv_ends (h : IsConvexEquiv M ε) {c d e : M.carrier}
    (hbet : ClassStrictlyBetween M ε c d e) :
    ¬ ContempEquivDense M ε c e ∧ ¬ ContempEquivDense M ε e d := by
  refine ⟨fun hc => ?_, fun hd => ?_⟩
  · exact absurd (hbet c (h.equiv.symm hc)).1 (lt_irrefl c)
  · exact absurd (hbet d hd).2 (lt_irrefl d)

/-- **`I` is nonempty** — from `c ≁ d` and density of `M/∼`. -/
theorem nonempty_classBetween (h : IsConvexEquiv M ε) (hq : QuotientDenselyOrdered M ε)
    {c d : M.carrier} (hcd : c < d) (hns : ¬ ContempEquivDense M ε c d) :
    Nonempty (h.ClassBetween c d) := by
  obtain ⟨e, hce, hed, hnce, hned⟩ := hq c d hcd hns
  exact ⟨⟨h.cls e, h.classStrictlyBetween_of_between hce hed hnce hned⟩⟩

/-- **`I` is densely ordered** — this is `QuotientDenselyOrdered` read at the quotient, which is
exactly what it was stated pointwise in order to supply. -/
theorem denselyOrdered_classBetween (h : IsConvexEquiv M ε) (hq : QuotientDenselyOrdered M ε)
    (c d : M.carrier) : DenselyOrdered (h.ClassBetween c d) := by
  constructor
  rintro ⟨A, hA⟩ ⟨B, hB⟩ hAB
  induction A using Quotient.ind with
  | _ a =>
  induction B using Quotient.ind with
  | _ b =>
  obtain ⟨hab, hnab⟩ := hAB
  obtain ⟨e, hae, heb, hnae, hneb⟩ := hq a b hab hnab
  have hbet : ClassStrictlyBetween M ε c d e := by
    intro x hx
    obtain ⟨hcx, hxb⟩ := h.classStrictlyBetween_of_between hae heb hnae hneb x hx
    exact ⟨lt_trans (h.lt_of_classStrictlyBetween hA).1 hcx,
      lt_trans hxb (h.lt_of_classStrictlyBetween hB).2⟩
  exact ⟨⟨h.cls e, hbet⟩, ⟨hae, hnae⟩, ⟨heb, hneb⟩⟩

/-- **`I` has no least element** — there is always a further class between `c` and the given one,
because a class strictly inside `(c,d)` is inequivalent to `c`. -/
theorem noMinOrder_classBetween (h : IsConvexEquiv M ε) (hq : QuotientDenselyOrdered M ε)
    (c d : M.carrier) : NoMinOrder (h.ClassBetween c d) := by
  constructor
  rintro ⟨A, hA⟩
  induction A using Quotient.ind with
  | _ a =>
  obtain ⟨hca, had⟩ := h.lt_of_classStrictlyBetween hA
  obtain ⟨hnca, -⟩ := h.not_contempEquiv_ends hA
  obtain ⟨e, hce, hea, hnce, hnea⟩ := hq c a hca hnca
  refine ⟨⟨h.cls e, ?_⟩, ⟨hea, hnea⟩⟩
  intro x hx
  obtain ⟨hcx, hxa⟩ := h.classStrictlyBetween_of_between hce hea hnce hnea x hx
  exact ⟨hcx, lt_trans hxa had⟩

/-- **`I` has no greatest element** — the mirror of `noMinOrder_classBetween`. -/
theorem noMaxOrder_classBetween (h : IsConvexEquiv M ε) (hq : QuotientDenselyOrdered M ε)
    (c d : M.carrier) : NoMaxOrder (h.ClassBetween c d) := by
  constructor
  rintro ⟨A, hA⟩
  induction A using Quotient.ind with
  | _ a =>
  obtain ⟨hca, had⟩ := h.lt_of_classStrictlyBetween hA
  obtain ⟨-, hnad⟩ := h.not_contempEquiv_ends hA
  obtain ⟨e, hae, hed, hnae, hned⟩ := hq a d had hnad
  refine ⟨⟨h.cls e, ?_⟩, ⟨hae, hnae⟩⟩
  intro x hx
  obtain ⟨hax, hxd⟩ := h.classStrictlyBetween_of_between hae hed hnae hned x hx
  exact ⟨lt_trans hca hax, hxd⟩

/--
**`I` has order type `ℚ`** — Reynolds 1992, printed p.187:

> Since we have density of `M / ∼`, the classes in `I = {E | E is a ∼-class strictly between c and
> d}` have order type `ℚ`.

Cantor's isomorphism theorem (`Order.iso_of_countable_dense`) at the four properties established
above: countable (a quotient of a countable carrier, then a subtype), densely ordered, and without
end points — the last two both from `QuotientDenselyOrdered`, which is D2's antecedent and is what
D1 plus Lemma 13 supply upstream.
-/
theorem nonempty_orderIso_rat_classBetween (h : IsConvexEquiv M ε) [Countable M.carrier]
    (hq : QuotientDenselyOrdered M ε) {c d : M.carrier} (hcd : c < d)
    (hns : ¬ ContempEquivDense M ε c d) : Nonempty (h.ClassBetween c d ≃o ℚ) := by
  haveI := h.denselyOrdered_classBetween hq c d
  haveI := h.noMinOrder_classBetween hq c d
  haveI := h.noMaxOrder_classBetween hq c d
  haveI := h.nonempty_classBetween hq hcd hns
  exact Order.iso_of_countable_dense (α := h.ClassBetween c d) (β := ℚ)

end IsConvexEquiv

/-! ## Layer 7 — density of `M/∼` from D1

Printed p.187, the sentence between *"there are at least two `∼`-classes"* and the choice of
`a < b`:

> By lemma 13 and D1, we know that between any such classes is a third. Thus we have density of
> `M / ∼` and D2 says that we have density of singleton classes.

This is what turns D1 into the `QuotientDenselyOrdered` hypothesis Layer 6 runs on, and it is
also D2's antecedent — so the same lemma discharges the input of `doetsD2_epsDense`.
-/

/--
**Density of `M/∼`** — printed p.187, *"By lemma 13 and D1, we know that between any such classes
is a third. Thus we have density of `M / ∼`."*

The argument the printed sentence compresses: given `a ≁ b` with `a < b`, Lemma 13 gives `a`'s
class a **last** point `z` (it is bounded above, by `b`) and `b`'s class a **first** point `w`
(bounded below, by `a`). Convexity puts `z < w`, density of `M` produces a point strictly between
them, and that point is in neither class precisely because `z` is last and `w` is first.

Density of `M`'s own flow is used, and is one of Theorem 6's standing hypotheses. Without it the
`∼`-classes could be adjacent with nothing between them and the conclusion would be false, not
merely unproved.
-/
theorem quotientDenselyOrdered_epsDense (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] (D1 : DoetsD1 sig M) :
    QuotientDenselyOrdered M (epsDense sig k) := by
  have hnogap : ∀ t : M.carrier, ¬ EndsInGapOnRight M (epsDense sig k) t ∧
      ¬ EndsInGapOnLeft M (epsDense sig k) t := fun t => doetsD1_epsDense sig k hk M D1 t
  intro a b hab hnab
  rw [contempEquivDense_epsDense_iff] at hnab
  -- `a`'s class has a last point `z`, and `b`'s class a first point `w`.
  obtain ⟨z, hza, hzlast⟩ := (reynolds_lemma13 k hk M hnogap a).1 ⟨b, hab, hnab⟩
  obtain ⟨w, hwb, hwfirst⟩ := (reynolds_lemma13 k hk M hnogap b).2
    ⟨a, hab, fun hc => hnab (simDense_symm hc)⟩
  -- `a ≤ z`: `a` is in its own class, so it cannot lie strictly above the last point.
  have haz : a ≤ z := by
    rcases le_or_gt a z with h | h
    · exact h
    · exact absurd (simDense_refl k M a) (hzlast a h)
  -- `w ≤ b`, by the mirror argument.
  have hwb' : w ≤ b := by
    rcases le_or_gt w b with h | h
    · exact h
    · exact absurd (simDense_refl k M b) (hwfirst b h)
  -- `a < w`: otherwise `w ∼ a` by convexity of `b`'s class, hence `a ∼ b`.
  have haw : a < w := by
    rcases lt_or_ge a w with h | h
    · exact h
    · have hwa : SimDense sig k M w a :=
        simDense_convex k M w a b h (le_of_lt hab) (simDense_symm hwb)
      exact absurd (simDense_trans k hk M (simDense_symm hwa) (simDense_symm hwb)) hnab
  -- `z < w`: otherwise `a ∼ w` by convexity of `a`'s class, hence `a ∼ b`.
  have hzw : z < w := by
    rcases lt_or_ge z w with h | h
    · exact h
    · exact absurd (simDense_trans k hk M
        (simDense_convex k M a w z (le_of_lt haw) h hza) (simDense_symm hwb)) hnab
  -- Density of `M` supplies a point strictly between the two attained bounds.
  obtain ⟨c, hzc, hcw⟩ := exists_between hzw
  refine ⟨c, lt_of_le_of_lt haz hzc, lt_of_lt_of_le hcw hwb', ?_, ?_⟩
  · rw [contempEquivDense_epsDense_iff]
    exact hzlast c hzc
  · rw [contempEquivDense_epsDense_iff]
    exact fun hc => hwfirst c hcw (simDense_symm hc)

/-- `IsConvexEquiv` at Reynolds' own `∼_M` — Lemma 12's clauses read at one countable dense
structure, via the `ε`-adapter. -/
theorem isConvexEquiv_epsDense (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] : IsConvexEquiv M (epsDense sig k) :=
  isConvexEquiv_of_contempEquivDenseCD (epsDense_isContempEquivDenseCD k hk) M

/--
**Reynolds' `I` has order type `ℚ` at his own `∼_M`** — printed p.187, with every hypothesis
discharged from Theorem 6's own standing assumptions plus D1.

This is the capstone of Layers 6 and 7 together: nothing abstract is left as a hypothesis. `∼` is
`∼_M` (via `epsDense_isContempEquivDenseCD`), density of `M/∼` comes from D1 through Lemma 13
(`quotientDenselyOrdered_epsDense`), and `c ≁ d` is stated in `SimDense` — the form the residual
below actually has it in.
-/
theorem nonempty_orderIso_rat_classBetween_epsDense (k : Nat) (hk : 2 ≤ k)
    (M : OrderedMonadicStructure sig) [Countable M.carrier] [DenselyOrdered M.carrier]
    (D1 : DoetsD1 sig M) {c d : M.carrier} (hcd : c < d) (hns : ¬ SimDense sig k M c d) :
    Nonempty ((isConvexEquiv_epsDense k hk M).ClassBetween c d ≃o ℚ) :=
  (isConvexEquiv_epsDense k hk M).nonempty_orderIso_rat_classBetween
    (quotientDenselyOrdered_epsDense k hk M D1) hcd
    (fun hc => hns ((contempEquivDense_epsDense_iff k M c d).mp hc))

/-! ## Layer 8 — Reynolds' three-summand decomposition of `M | (c,d)`

Printed p.188, the closing step of Theorem 6's proof:

> Let `c'` be the right hand end point of `c`'s `∼`-class and `d'` be the left hand end point of
> `d`'s. Thus
>
> `M | (c,d) = M | (c,c'] + M | ⋃I + M | [d',d)`.
>
> As `c ∼ c'`, there is `X ≡ₖ M | (c,c']` with flow isomorphic to an interval of `ℝ` and similarly
> there is `Y ≡ₖ M | [d',d)`. Then
>
> `M | (c,d) ≡ₖ X + 𝓡 + Y`
>
> and this latter has flow of time isomorphic to `ℝ` as required.

**The displayed three-summand identity is two nested binary splits, and both are already landed.**
`kEquiv_openSub_split` (`EpsilonDense.lean:858`) cuts an open interval at an interior point,
putting that point at the head of the second block, and `goodDense_binSum_pointSum`
(`EpsilonDense.lean:832`) is literally *"`X + M | {b} + Y` is good"* — the `R₁ + R₂ + R₃` step
Reynolds had already used once, for transitivity of `∼` (printed p.187), and where the seam
closes up because `X` inherits its lack of a right end point across `≡ₖ`.

Applying that pair twice, at `c'` and then at `d'`, *is* Reynolds' identity: the first cut splits
off `M | (c,c')` and leaves `M | [c',d)`; the second splits `M | [c',d)` — whose head is `c'`, so
that `M | {c'} + M | (c',d')` is Reynolds' `M | (c,c']` shifted one seam to the right — into
`M | (c',d')` and `M | [d',d)`. The middle block `M | (c',d')` is `⋃I`
(`unionClasses_eq_openSub` below).

So this layer adds no mathematics: it is the composition, stated once, with the goodness of the
middle block left as the hypothesis it is. `M | (c,c')` and `M | (d',d)` are very good outright,
because `c ∼ c'` and `d' ∼ d`; `hmid` is the only input that is not immediate, and supplying it is
the shuffle step.
-/

/--
**Reynolds' `M | (c,d) ≡ₖ X + 𝓡 + Y`** — printed p.188, as a statement about goodness.

Two applications of `goodDense_binSum_pointSum`, at `d'` and then at `c'`. The inner one produces
goodness of `M | (c',d)` from the middle block and the right-hand tail; the outer one prefixes
`M | (c,c')` and the seam point `c'`.

The hypotheses are exactly Reynolds' three summands: `hleft` is *"`c ∼ c'`"*, `hright` is
*"`d' ∼ d`"*, and `hmid` is *"`M | ⋃I` is good"* — the one that costs the shuffle.
-/
theorem goodDense_openSub_of_mid (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] {c c' d' d : M.carrier}
    (hcc' : c < c') (hc'd' : c' < d') (hd'd : d' < d)
    (hleft : veryGoodDense sig k (M.openSubinterval sig c c'))
    (hmid : goodDense sig k (M.openSubinterval sig c' d'))
    (hright : veryGoodDense sig k (M.openSubinterval sig d' d)) :
    goodDense sig k (M.openSubinterval sig c d) := by
  have hc'd : c' < d := lt_trans hc'd' hd'd
  -- Countability, non-emptiness and end-point freedom for each of the four open blocks.
  haveI : Countable (M.openSubinterval sig c c').carrier :=
    inferInstanceAs (Countable {x : M.carrier // c < x ∧ x < c'})
  haveI : Countable (M.openSubinterval sig c' d').carrier :=
    inferInstanceAs (Countable {x : M.carrier // c' < x ∧ x < d'})
  haveI : Countable (M.openSubinterval sig d' d).carrier :=
    inferInstanceAs (Countable {x : M.carrier // d' < x ∧ x < d})
  haveI : Nonempty (M.openSubinterval sig c c').carrier := by
    obtain ⟨x, hx₁, hx₂⟩ := exists_between hcc'; exact ⟨⟨x, hx₁, hx₂⟩⟩
  haveI : Nonempty (M.openSubinterval sig c' d').carrier := by
    obtain ⟨x, hx₁, hx₂⟩ := exists_between hc'd'; exact ⟨⟨x, hx₁, hx₂⟩⟩
  haveI : Nonempty (M.openSubinterval sig d' d).carrier := by
    obtain ⟨x, hx₁, hx₂⟩ := exists_between hd'd; exact ⟨⟨x, hx₁, hx₂⟩⟩
  haveI : Nonempty (M.openSubinterval sig c' d).carrier := by
    obtain ⟨x, hx₁, hx₂⟩ := exists_between hc'd; exact ⟨⟨x, hx₁, hx₂⟩⟩
  haveI := noMaxOrder_openSubinterval sig M c c'
  haveI := noMinOrder_openSubinterval sig M c c'
  haveI := noMaxOrder_openSubinterval sig M c' d'
  haveI := noMinOrder_openSubinterval sig M c' d'
  haveI := noMaxOrder_openSubinterval sig M d' d
  haveI := noMinOrder_openSubinterval sig M d' d
  haveI := noMaxOrder_openSubinterval sig M c' d
  haveI := noMinOrder_openSubinterval sig M c' d
  -- Inner split, at `d'`: `M | (c',d) ≡ₖ M | (c',d') + M | {d'} + M | (d',d)`.
  have hinner : goodDense sig k (M.openSubinterval sig c' d) := by
    have hsplit : KEquiv sig k (M.openSubinterval sig c' d)
        (binSum sig (M.openSubinterval sig c' d')
          (pointSum sig M d' (M.openSubinterval sig d' d))) :=
      (kEquiv_openSub_split k M c' d' d hc'd' hd'd).trans
        (kEquiv_binSum k (rfl : KEquiv sig k (M.openSubinterval sig c' d') _)
          (kEquiv_halfOpen_pointSum sig k M d' d hd'd))
    exact goodDense_of_kEquiv sig k hsplit
      (goodDense_binSum_pointSum k hk M d' _ _ hmid (reynolds_lemma11 sig k hk _ hright))
  -- Outer split, at `c'`: `M | (c,d) ≡ₖ M | (c,c') + M | {c'} + M | (c',d)`.
  have hsplit : KEquiv sig k (M.openSubinterval sig c d)
      (binSum sig (M.openSubinterval sig c c')
        (pointSum sig M c' (M.openSubinterval sig c' d))) :=
    (kEquiv_openSub_split k M c c' d hcc' hc'd).trans
      (kEquiv_binSum k (rfl : KEquiv sig k (M.openSubinterval sig c c') _)
        (kEquiv_halfOpen_pointSum sig k M c' d hc'd))
  exact goodDense_of_kEquiv sig k hsplit
    (goodDense_binSum_pointSum k hk M c' _ _ (reynolds_lemma11 sig k hk _ hleft) hinner)

/--
**The decomposition with the degenerate cases admitted** — `c' = c` and `d' = d` are exactly the
cases in which `c`'s (resp. `d`'s) class is a singleton, and then Reynolds' `M | (c,c']` (resp.
`M | [d',d)`) is empty and the corresponding summand is absent.

Reynolds' *"Let `c'` be the right hand end point of `c`'s class"* passes over this silently. It is
not a corner case that can be assumed away: D2 supplies a **dense set of singleton classes**
(printed p.187), so singleton classes are the generic situation, and `c` or `d` landing on one is
routine rather than exceptional. All four combinations are discharged, the outer two by a single
split and the degenerate-degenerate one by the middle block alone.
-/
theorem goodDense_openSub_of_mid_le (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] {c c' d' d : M.carrier}
    (hcc' : c ≤ c') (hc'd' : c' < d') (hd'd : d' ≤ d)
    (hleft : c < c' → veryGoodDense sig k (M.openSubinterval sig c c'))
    (hmid : goodDense sig k (M.openSubinterval sig c' d'))
    (hright : d' < d → veryGoodDense sig k (M.openSubinterval sig d' d)) :
    goodDense sig k (M.openSubinterval sig c d) := by
  haveI : Countable (M.openSubinterval sig c c').carrier :=
    inferInstanceAs (Countable {x : M.carrier // c < x ∧ x < c'})
  haveI : Countable (M.openSubinterval sig d' d).carrier :=
    inferInstanceAs (Countable {x : M.carrier // d' < x ∧ x < d})
  haveI := noMaxOrder_openSubinterval sig M c c'
  haveI := noMinOrder_openSubinterval sig M c c'
  haveI := noMaxOrder_openSubinterval sig M c' d'
  haveI := noMinOrder_openSubinterval sig M c' d'
  haveI := noMaxOrder_openSubinterval sig M d' d
  haveI := noMinOrder_openSubinterval sig M d' d
  haveI : Nonempty (M.openSubinterval sig c' d').carrier := by
    obtain ⟨x, hx₁, hx₂⟩ := exists_between hc'd'; exact ⟨⟨x, hx₁, hx₂⟩⟩
  rcases eq_or_lt_of_le hcc' with rfl | hcc'
  · rcases eq_or_lt_of_le hd'd with rfl | hd'd
    · -- both classes singletons: `M | (c,d)` *is* the middle block
      exact hmid
    · -- only `c`'s class is a singleton: one split, at `d'`
      haveI : Nonempty (M.openSubinterval sig d' d).carrier := by
        obtain ⟨x, hx₁, hx₂⟩ := exists_between hd'd; exact ⟨⟨x, hx₁, hx₂⟩⟩
      have hsplit : KEquiv sig k (M.openSubinterval sig c d)
          (binSum sig (M.openSubinterval sig c d')
            (pointSum sig M d' (M.openSubinterval sig d' d))) :=
        (kEquiv_openSub_split k M c d' d hc'd' hd'd).trans
          (kEquiv_binSum k (rfl : KEquiv sig k (M.openSubinterval sig c d') _)
            (kEquiv_halfOpen_pointSum sig k M d' d hd'd))
      exact goodDense_of_kEquiv sig k hsplit
        (goodDense_binSum_pointSum k hk M d' _ _ hmid
          (reynolds_lemma11 sig k hk _ (hright hd'd)))
  · haveI : Nonempty (M.openSubinterval sig c c').carrier := by
      obtain ⟨x, hx₁, hx₂⟩ := exists_between hcc'; exact ⟨⟨x, hx₁, hx₂⟩⟩
    rcases eq_or_lt_of_le hd'd with rfl | hd'd
    · -- only `d`'s class is a singleton: one split, at `c'`
      have hsplit : KEquiv sig k (M.openSubinterval sig c d')
          (binSum sig (M.openSubinterval sig c c')
            (pointSum sig M c' (M.openSubinterval sig c' d'))) :=
        (kEquiv_openSub_split k M c c' d' hcc' hc'd').trans
          (kEquiv_binSum k (rfl : KEquiv sig k (M.openSubinterval sig c c') _)
            (kEquiv_halfOpen_pointSum sig k M c' d' hc'd'))
      exact goodDense_of_kEquiv sig k hsplit
        (goodDense_binSum_pointSum k hk M c' _ _
          (reynolds_lemma11 sig k hk _ (hleft hcc')) hmid)
    · exact goodDense_openSub_of_mid k hk M hcc' hc'd' hd'd (hleft hcc') hmid (hright hd'd)

/-! ## Layer 9 — Reynolds' `c'` and `d'`

Printed p.188: *"Let `c'` be the right hand end point of `c`'s `∼`-class and `d'` be the left hand
end point of `d`'s."*

That the two end points **exist** is Lemma 13 (`reynolds_lemma13_right` / `reynolds_lemma13_left`,
`Shuffle.lean:176,201`) together with D1: the classes do not end in gaps, so a class bounded on a
side attains its bound there. Reynolds' sentence reads as though the end points came for free;
they are exactly Lemma 13's content, which is the reason that lemma is proved at all.

What each construction adds beyond Lemma 13 is the **location** of the end point relative to the
opposite end of the interval — `c' < d` and `c < d'` — because that is what makes each a genuine
interior seam of `(c,d)`, and `c' < d'`, which is what makes the middle block non-degenerate. All
three are convexity plus transitivity of `∼` against `c ≁ d`, and all three fail without `c ≁ d`:
at `c ∼ d` the two classes coincide and there is no middle block at all. That is why Reynolds
disposes of `c ∼ d` first, by Lemma 11, before this paragraph begins.
-/

/--
**The right hand end point of `c`'s class** (printed p.188), from Lemma 13 and D1.

The conclusions are: `c'` lies in `c`'s class, `c` does not exceed it, `c'` still lies strictly
below `d`, and nothing above `c'` is `∼ c`. The last clause is what identifies `⋃I` with an
interval starting at `c'`.
-/
theorem exists_right_endpoint_class (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] (D1 : DoetsD1 sig M)
    {c d : M.carrier} (hcd : c < d) (hns : ¬ SimDense sig k M c d) :
    ∃ c' : M.carrier, SimDense sig k M c c' ∧ c ≤ c' ∧ c' < d ∧
      ∀ y : M.carrier, c' < y → ¬ SimDense sig k M c y := by
  obtain ⟨c', hsim, hlast⟩ :=
    reynolds_lemma13_right k hk M c (doetsD1_epsDense sig k hk M D1 c).1 ⟨d, hcd, hns⟩
  refine ⟨c', hsim, ?_, ?_, hlast⟩
  · -- `c` itself is `∼ c`, so it cannot lie strictly above the last point of its class.
    by_contra hlt
    exact hlast c (not_le.mp hlt) (simDense_refl k M c)
  · -- `d ≤ c'` would put `d` inside `c`'s class by convexity.
    by_contra hle
    exact hns (simDense_convex k M c d c' (le_of_lt hcd) (not_lt.mp hle) hsim)

/--
**The left hand end point of `d`'s class** (printed p.188) — the mirror of
`exists_right_endpoint_class`, from Lemma 13's left half.
-/
theorem exists_left_endpoint_class (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] (D1 : DoetsD1 sig M)
    {c d : M.carrier} (hcd : c < d) (hns : ¬ SimDense sig k M c d) :
    ∃ d' : M.carrier, SimDense sig k M d d' ∧ d' ≤ d ∧ c < d' ∧
      ∀ y : M.carrier, y < d' → ¬ SimDense sig k M d y := by
  obtain ⟨d', hsim, hfst⟩ :=
    reynolds_lemma13_left k hk M d (doetsD1_epsDense sig k hk M D1 d).2
      ⟨c, hcd, fun h => hns (simDense_symm h)⟩
  refine ⟨d', hsim, ?_, ?_, hfst⟩
  · by_contra hle
    exact hfst d (not_le.mp hle) (simDense_refl k M d)
  · -- `d' ≤ c` would put `c` inside `d`'s class, by convexity read from `d'` upwards.
    by_contra hlt
    have hd'c : SimDense sig k M d' c :=
      simDense_convex k M d' c d (not_lt.mp hlt) (le_of_lt hcd) (simDense_symm hsim)
    exact hns (simDense_trans k hk M (simDense_symm hd'c) (simDense_symm hsim))

/--
**The two end points do not cross** — `c' < d'`, so the middle block `M | (c',d')` is a genuine
non-empty open interval.

`d' ≤ c'` would place `d'` inside `c`'s class by convexity, and `d'` is in `d`'s class, so
transitivity would give `c ∼ d`.
-/
theorem endpoint_lt_endpoint (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] {c d c' d' : M.carrier}
    (hns : ¬ SimDense sig k M c d) (hsimc : SimDense sig k M c c')
    (hsimd : SimDense sig k M d d') (hcd' : c < d') : c' < d' := by
  by_contra hle
  have hcd'sim : SimDense sig k M c d' :=
    simDense_convex k M c d' c' (le_of_lt hcd') (not_lt.mp hle) hsimc
  exact hns (simDense_trans k hk M hcd'sim (simDense_symm hsimd))

/-! ## Layer 10 — `⋃I = (c',d')`

Reynolds writes the middle summand of his decomposition as `M | ⋃I`, with `I` the set of `∼`-classes
strictly between `c` and `d`, and the two outer summands as intervals cut at `c'` and `d'`. For the
decomposition and the shuffle to be about the *same* structure, `⋃I` has to be identified with the
open interval `(c',d')`, and the identification is where `c'` and `d'` earn their definitions:

* a point above `c'` is not `∼ c` and a point below `d'` is not `∼ d` — that is what *"end point of
  the class"* means, and it is the forward direction;
* a point of `(c,d)` that is `≁ c` and `≁ d` must lie above `c'` and below `d'` — convexity, and it
  is the backward direction.

`classStrictlyBetween_epsDense_iff` then lifts the pointwise identification to Reynolds' `I`
itself: a class lies strictly between `c` and `d` exactly when its points lie in `(c',d')`. That is
the form the shuffle step consumes, because the shuffle's block map is *"the `∼`-class of"* read on
`M | (c',d')` with `I` as its index.
-/

/--
**`⋃I = (c',d')`**, pointwise (printed p.188). The left side is membership in the middle block of
the decomposition; the right side is *"lies in `(c,d)` and is in neither end class"*, which is
membership in `⋃I`.
-/
theorem mem_openSub_endpoints_iff (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] {c d c' d' : M.carrier}
    (hsimc : SimDense sig k M c c') (hcc' : c ≤ c')
    (hlast : ∀ y : M.carrier, c' < y → ¬ SimDense sig k M c y)
    (hsimd : SimDense sig k M d d') (hd'd : d' ≤ d)
    (hfst : ∀ y : M.carrier, y < d' → ¬ SimDense sig k M d y) (x : M.carrier) :
    (c' < x ∧ x < d') ↔
      (c < x ∧ x < d ∧ ¬ SimDense sig k M c x ∧ ¬ SimDense sig k M d x) := by
  constructor
  · rintro ⟨hc'x, hxd'⟩
    exact ⟨lt_of_le_of_lt hcc' hc'x, lt_of_lt_of_le hxd' hd'd, hlast x hc'x, hfst x hxd'⟩
  · rintro ⟨hcx, hxd, hncx, hndx⟩
    refine ⟨?_, ?_⟩
    · -- `x ≤ c'` would put `x` inside `c`'s class.
      by_contra hle
      exact hncx (simDense_convex k M c x c' (le_of_lt hcx) (not_lt.mp hle) hsimc)
    · -- `d' ≤ x` would put `x` inside `d`'s class, read from `d'` upwards.
      by_contra hle
      exact hndx (simDense_trans k hk M hsimd
        (simDense_convex k M d' x d (not_lt.mp hle) (le_of_lt hxd) (simDense_symm hsimd)))

/--
**Reynolds' `I`, identified with the middle block** (printed p.188): a `∼`-class lies strictly
between `c` and `d` exactly when its representative lies in `(c',d')`.

This is `mem_openSub_endpoints_iff` composed with `classStrictlyBetween_of_between` and
`not_contempEquiv_ends` (Layer 6), read at Reynolds' own `∼_M` through
`contempEquivDense_epsDense_iff`.
-/
theorem classStrictlyBetween_epsDense_iff (k : Nat) (hk : 2 ≤ k)
    (M : OrderedMonadicStructure sig) [Countable M.carrier] [DenselyOrdered M.carrier]
    {c d c' d' : M.carrier}
    (hsimc : SimDense sig k M c c') (hcc' : c ≤ c')
    (hlast : ∀ y : M.carrier, c' < y → ¬ SimDense sig k M c y)
    (hsimd : SimDense sig k M d d') (hd'd : d' ≤ d)
    (hfst : ∀ y : M.carrier, y < d' → ¬ SimDense sig k M d y) (e : M.carrier) :
    ClassStrictlyBetween M (epsDense sig k) c d e ↔ (c' < e ∧ e < d') := by
  have hiff := mem_openSub_endpoints_iff k hk M hsimc hcc' hlast hsimd hd'd hfst e
  constructor
  · intro hbet
    obtain ⟨hce, hed⟩ := (isConvexEquiv_epsDense k hk M).lt_of_classStrictlyBetween hbet
    obtain ⟨hnce, hned⟩ := (isConvexEquiv_epsDense k hk M).not_contempEquiv_ends hbet
    refine hiff.mpr ⟨hce, hed, ?_, ?_⟩
    · exact fun h => hnce ((contempEquivDense_epsDense_iff k M c e).mpr h)
    · exact fun h => hned ((contempEquivDense_epsDense_iff k M e d).mpr (simDense_symm h))
  · intro hmem
    obtain ⟨hce, hed, hnce, hnde⟩ := hiff.mp hmem
    refine (isConvexEquiv_epsDense k hk M).classStrictlyBetween_of_between hce hed ?_ ?_
    · exact fun h => hnce ((contempEquivDense_epsDense_iff k M c e).mp h)
    · exact fun h => hnde (simDense_symm ((contempEquivDense_epsDense_iff k M e d).mp h))

/-! ## Layer 11 — the two-sided closed normalization of Reynolds' `N_γ`

Printed p.187, the choice this layer makes good on:

> For each `γᵢ` choose a structure `N_i ⊨ γᵢ` whose flow of time is an interval of the reals.

and printed p.188, the sharper form the shuffle actually consumes:

> because the `γᵢ`'s say so, the summands themselves are closed intervals of the reals.

`goodDense` hands back *some* order-connected set of reals. The shuffle's summand hypotheses —
`hne`, `hdense`, `hsum`, `hbot`, `hsep` of `goodDense_shuffle` (Layer 3) — are the five facts that
hold of a **closed bounded** interval and fail for the open one: an open interval has no least
element and is not closed under suprema. So the normalization has to be sharpened, and the
sharpening is what *"the `γᵢ`'s say so"* means: `γ` records that the class has a right hand and a
left hand end point, which is Lemma 13 together with D1 (Layer 9), and *"has an end point"* is a
depth-`2` sentence, so it travels across `≡ₖ` at `k ≥ 2` exactly as *"has no end point"* does in
`noMaxOrder_of_kEquiv`.

The two ends then pin the flow down completely: an order-connected set of reals with a least and a
greatest element **is** the closed interval between them, with no residual choice. That is
`ordConnected_eq_Icc`, and `isIccLike_of_carrierSet_eq_Icc` reads the five facts off it.

`exists_ioo_witness` (`GoodDense.lean:713`) is the end-point-**free** case of this same
normalization and `icoBlock` / `kEquiv_pointSum_icoBlock` the one-sided case; neither applies here,
because Reynolds' summands are the ones that *do* have both ends.
-/

section IccNormalization

/--
*"has a right hand end point"* transfers across `≡ₖ` for `k ≥ 2` — the positive counterpart of
`noMaxOrder_of_kEquiv` (`GoodDense.lean:469`), read off the same depth-`2` sentence `hasMaxSent`.
-/
theorem exists_max_of_kEquiv (k : Nat) (hk : 2 ≤ k) {M N : OrderedMonadicStructure sig}
    (h : KEquiv sig k M N) (hM : ∃ x : M.carrier, ∀ y : M.carrier, ¬ x < y) :
    ∃ x : N.carrier, ∀ y : N.carrier, ¬ x < y := by
  have hdepth : (hasMaxSent sig).quantifierDepth ≤ k := by
    simpa [hasMaxSent, MonadicFormula.quantifierDepth] using hk
  exact (eval_hasMaxSent sig N).mp
    ((eval_transfer_of_kEquiv sig k _ hdepth h).mp ((eval_hasMaxSent sig M).mpr hM))

/-- *"has a left hand end point"* transfers across `≡ₖ` for `k ≥ 2`. -/
theorem exists_min_of_kEquiv (k : Nat) (hk : 2 ≤ k) {M N : OrderedMonadicStructure sig}
    (h : KEquiv sig k M N) (hM : ∃ x : M.carrier, ∀ y : M.carrier, ¬ y < x) :
    ∃ x : N.carrier, ∀ y : N.carrier, ¬ y < x := by
  have hdepth : (hasMinSent sig).quantifierDepth ≤ k := by
    simpa [hasMinSent, MonadicFormula.quantifierDepth] using hk
  exact (eval_hasMinSent sig N).mp
    ((eval_transfer_of_kEquiv sig k _ hdepth h).mp ((eval_hasMinSent sig M).mpr hM))

/-- A normal form travels across `≡ₖ`: `k`-equivalence *is* equality of `k`-types, and the `k`-type
is the normal-form decision function. -/
theorem nfEvalNf_of_kEquiv (k : Nat) {M N : OrderedMonadicStructure sig} (h : KEquiv sig k M N)
    {nf : NormalForm sig k 0} (hM : NfEvalNf M k 0 Fin.elim0 nf) :
    NfEvalNf N k 0 Fin.elim0 nf := by
  have hp := congr_fun h nf
  simp only [kTypeOf, decide_eq_decide] at hp
  exact hp.mp hM

/--
**An order-connected set of reals with both ends attained is a closed interval.** This is the step
that makes Reynolds' *"the summands are closed intervals"* a theorem rather than a further choice:
once the two end points exist there is nothing left to choose.
-/
theorem ordConnected_eq_Icc {s : Set ℝ} (hc : s.OrdConnected) {x y : ℝ}
    (hx : IsLeast s x) (hy : IsGreatest s y) : s = Set.Icc x y :=
  Set.Subset.antisymm (fun _ hv => ⟨hx.2 hv, hy.2 hv⟩) (hc.out hx.1 hy.1)

/--
**The five order facts of a closed real interval** — precisely the summand hypotheses of
`goodDense_shuffle` (Layer 3), bundled so the shuffle step discharges them once per `γ` instead of
five times.

Reynolds never names this bundle: on p.188 it is the single phrase *"closed intervals of the
reals"*, used to license Dedekind completeness and the least element of each summand.
-/
def IsIccLike (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (N : OrderedMonadicStructure sig) : Prop :=
  Nonempty N.carrier ∧
    (∀ x y : N.carrier, x < y → ∃ z : N.carrier, x < z ∧ z < y) ∧
    (∀ s : Set N.carrier, s.Nonempty → ∃ u, IsLUB s u) ∧
    (∃ b : N.carrier, ∀ x : N.carrier, b ≤ x) ∧
    (∃ D : Set N.carrier, D.Countable ∧
      ∀ x y : N.carrier, x < y → ∃ d ∈ D, x < d ∧ d < y)

/--
**A closed-interval flow is `IsIccLike`.** Each clause is the corresponding standard fact about
`Set.Icc` in `ℝ`: density from `exists_between`, completeness from `sSup` of the image (the
interval is closed, so the supremum is attained *inside* it — the clause that fails for `Ioo` and
is the reason Reynolds needs the closed form), the least element is the left end point, and
separability is `exists_rat_btwn`.

Membership is transported through `hR` by `Set.ext_iff` rather than by `rw`: the carrier's own type
mentions `R.carrierSet`, so rewriting it breaks the motive (the same discipline as
`kEquiv_pointSum_icoBlock`, `GoodDense.lean:945`).
-/
theorem isIccLike_of_carrierSet_eq_Icc (R : RIntervalStructure sig) {x y : ℝ} (hxy : x ≤ y)
    (hR : R.carrierSet = Set.Icc x y) : IsIccLike sig (R.toOrdered sig) := by
  have hmem : ∀ v : ℝ, v ∈ R.carrierSet ↔ (x ≤ v ∧ v ≤ y) := by
    intro v
    rw [Set.ext_iff] at hR
    simpa [Set.mem_Icc] using hR v
  have hx0 : x ∈ R.carrierSet := (hmem x).mpr ⟨le_refl x, hxy⟩
  refine ⟨⟨⟨x, hx0⟩⟩, ?_, ?_, ⟨⟨x, hx0⟩, ?_⟩, ?_⟩
  · -- density: `Set.Icc` inherits `ℝ`'s density, and both bounds are preserved
    intro u v huv
    have huv' : u.val < v.val := huv
    obtain ⟨w, hw₁, hw₂⟩ := exists_between huv'
    have hwm : w ∈ R.carrierSet :=
      (hmem w).mpr ⟨le_trans ((hmem u.val).mp u.property).1 (le_of_lt hw₁),
        le_trans (le_of_lt hw₂) ((hmem v.val).mp v.property).2⟩
    exact ⟨⟨w, hwm⟩, hw₁, hw₂⟩
  · -- completeness: the supremum of the image lies in `[x,y]`, so it lies in the carrier
    intro s hs
    obtain ⟨w₀, hw₀⟩ := hs
    have hub : ∀ v ∈ Subtype.val '' s, v ≤ y := by
      rintro v ⟨u, -, rfl⟩
      exact ((hmem u.val).mp u.property).2
    have hbdd : BddAbove (Subtype.val '' s) := ⟨y, hub⟩
    have hne : (Subtype.val '' s).Nonempty := ⟨w₀.val, w₀, hw₀, rfl⟩
    have hle : sSup (Subtype.val '' s) ≤ y := csSup_le hne hub
    have hge : x ≤ sSup (Subtype.val '' s) :=
      le_trans ((hmem w₀.val).mp w₀.property).1 (le_csSup hbdd ⟨w₀, hw₀, rfl⟩)
    refine ⟨⟨sSup (Subtype.val '' s), (hmem _).mpr ⟨hge, hle⟩⟩, ?_, ?_⟩
    · intro v hv
      exact le_csSup hbdd ⟨v, hv, rfl⟩
    · intro b hb
      exact csSup_le hne (by rintro v ⟨u, hu, rfl⟩; exact hb hu)
  · -- the least element is the left end point
    intro v
    exact ((hmem v.val).mp v.property).1
  · -- separability: the rationals of the interval
    refine ⟨Subtype.val ⁻¹' (Set.range ((↑) : ℚ → ℝ)),
      (Set.countable_range ((↑) : ℚ → ℝ)).preimage Subtype.val_injective, ?_⟩
    intro u v huv
    have huv' : u.val < v.val := huv
    obtain ⟨q, hq₁, hq₂⟩ := exists_rat_btwn huv'
    have hqm : (q : ℝ) ∈ R.carrierSet :=
      (hmem q).mpr ⟨le_trans ((hmem u.val).mp u.property).1 (le_of_lt hq₁),
        le_trans (le_of_lt hq₂) ((hmem v.val).mp v.property).2⟩
    exact ⟨⟨(q : ℝ), hqm⟩, ⟨q, rfl⟩, hq₁, hq₂⟩

/--
**Reynolds' `N_γ`, with both ends** (printed p.187 sharpened by p.188): a good structure with a
right hand and a left hand end point has a `≡ₖ`-equivalent whose flow is a **closed** bounded
interval of the reals — hence `IsIccLike`.

The proof is the whole content of Layer 11: goodness supplies an order-connected flow, the two end
points travel across `≡ₖ` by `exists_max_of_kEquiv` / `exists_min_of_kEquiv`, and
`ordConnected_eq_Icc` then leaves no choice about which interval it is.
-/
theorem exists_iccLike_witness (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    (hgood : goodDense sig k M)
    (hmax : ∃ x : M.carrier, ∀ y : M.carrier, ¬ x < y)
    (hmin : ∃ x : M.carrier, ∀ y : M.carrier, ¬ y < x) :
    ∃ R : RIntervalStructure sig, IsIccLike sig (R.toOrdered sig) ∧
      KEquiv sig k M (R.toOrdered sig) := by
  obtain ⟨R, hR⟩ := hgood
  obtain ⟨xm, hxm⟩ := exists_max_of_kEquiv k hk hR hmax
  obtain ⟨xn, hxn⟩ := exists_min_of_kEquiv k hk hR hmin
  have hgreat : IsGreatest R.carrierSet xm.val :=
    ⟨xm.property, fun v hv => not_lt.mp (hxm ⟨v, hv⟩)⟩
  have hleast : IsLeast R.carrierSet xn.val :=
    ⟨xn.property, fun v hv => not_lt.mp (hxn ⟨v, hv⟩)⟩
  exact ⟨R, isIccLike_of_carrierSet_eq_Icc R (hleast.2 hgreat.1)
    (ordConnected_eq_Icc R.ordConnected hleast hgreat), hR⟩

/--
**Reynolds' `γ₁`** (printed p.188, *"`γ₁` is only satisfied by one point structures"*): the flow of
a one-point structure, with the flow itself exposed rather than hidden behind an existential.

`goodDense_of_subsingleton` (`GoodDense.lean:285`) proves goodness of a one-point structure, but
`hone` of `goodDense_shuffle` is a statement *about* `N γ₁`, so the shuffle needs the witness and
not merely its existence. The construction is `goodDense_of_subsingleton`'s, at the degenerate
interval `[0,0]`.
-/
theorem exists_icc_witness_of_subsingleton (k : Nat) (M : OrderedMonadicStructure sig)
    [Nonempty M.carrier] [Subsingleton M.carrier] :
    ∃ R : RIntervalStructure sig, R.carrierSet = Set.Icc (0 : ℝ) 0 ∧
      KEquiv sig k M (R.toOrdered sig) := by
  obtain ⟨a⟩ := ‹Nonempty M.carrier›
  refine ⟨{ carrierSet := Set.Icc (0 : ℝ) 0
            ordConnected := Set.ordConnected_Icc
            interp := fun p _ => M.interp p a }, rfl, ?_⟩
  have hone : ∀ u v : {w : ℝ // w ∈ Set.Icc (0 : ℝ) 0}, u = v := fun u v =>
    Subtype.ext ((le_antisymm u.property.2 u.property.1).trans
      (le_antisymm v.property.2 v.property.1).symm)
  let e : M.carrier ≃ {w : ℝ // w ∈ Set.Icc (0 : ℝ) 0} := {
    toFun := fun _ => ⟨0, le_refl 0, le_refl 0⟩
    invFun := fun _ => a
    left_inv := fun u => Subsingleton.elim a u
    right_inv := fun u => hone _ u }
  refine k_equiv_of_iso sig k _ _ (Equiv.toOrderIso e
    (fun u v _ => le_of_eq (congrArg e (Subsingleton.elim u v)))
    (fun u v _ => le_of_eq (congrArg e.symm (hone u v)))) ?_
  intro p u
  exact iff_of_eq (congrArg (M.interp p) (Subsingleton.elim u a))

/-- A degenerate closed-interval flow is a one-point flow — the `hone` clause of
`goodDense_shuffle`, read off `carrierSet = [x,x]`. -/
theorem subsingleton_of_carrierSet_eq_Icc_self (R : RIntervalStructure sig) {x : ℝ}
    (hR : R.carrierSet = Set.Icc x x) :
    ∀ u v : (R.toOrdered sig).carrier, u = v := by
  have hmem : ∀ v : ℝ, v ∈ R.carrierSet ↔ v = x := by
    intro v
    rw [Set.ext_iff] at hR
    simpa [Set.mem_Icc] using hR v
  intro u v
  exact Subtype.ext (((hmem u.val).mp u.property).trans ((hmem v.val).mp v.property).symm)

end IccNormalization

/-! ## Layer 12 — the `∼`-classes are Reynolds' closed-interval summands

Printed p.188, the clause Layer 11 was built to consume:

> because the `γᵢ`'s say so the summands themselves are closed intervals of the reals

The summands are the `∼`-classes `E ∈ I`. This layer discharges the three facts Layer 11 needs of
each of them, and each fact is one of Reynolds' own sentences read at a class:

* **`M | E` is good.** `x ∼ y` *means* that `M | (x,y)` is very good (`SimDense`, printed p.185),
  and convexity of the class (Lemma 12) puts `(x,y)` inside `E` whenever `x, y ∈ E`. So every open
  subinterval of `M | E` is an `M | (x,y)` with `x ∼ y`, which makes `M | E` very good, and
  Lemma 11 turns that into goodness.
* **`M | E` has a right hand end point**, and **a left hand one.** This is Layer 9's construction
  run at `(e,d)` and at `(c,e)` rather than at `(c,d)`: the class of a point strictly inside
  `(c,d)` is bounded on both sides — above by `d`, below by `c` — so Lemma 13 and D1 attain both
  bounds *inside the class*. Reynolds uses the same two end points at the outer classes of `c` and
  of `d`; at the interior classes they are what makes each summand closed.

The two `≡ₖ`-identifications at the head of the section are the bookkeeping that lets a class be
cut out of `M` or out of `M | (c',d')` interchangeably — `restrictSet` composed with
`openSubinterval` in each order. Reynolds writes `M | E` throughout and never distinguishes the
two; in Lean they are different types and the shuffle's block map consumes the second.
-/

section ClassSummands

/--
**Cutting a set-shaped restriction down to an interval is cutting `M` down to that interval** —
provided the interval lies inside the set, which for a `∼`-class is convexity (Lemma 12).

The dense analogue of `openSubOpenSubEquiv` (`EpsilonDense.lean:151`), for a `restrictSet` outer
cut rather than an `openSubinterval` one.
-/
theorem kEquiv_restrictSet_openSub (k : Nat) (M : OrderedMonadicStructure sig)
    (s : Set M.carrier) (u v : {x : M.carrier // x ∈ s})
    (hconv : ∀ x : M.carrier, u.val < x → x < v.val → x ∈ s) :
    KEquiv sig k ((M.restrictSet sig s).openSubinterval sig u v)
      (M.openSubinterval sig u.val v.val) :=
  k_equiv_of_iso sig k _ _ (Equiv.toOrderIso
    { toFun := fun x => ⟨x.val.val, x.property.1, x.property.2⟩
      invFun := fun y => ⟨⟨y.val, hconv y.val y.property.1 y.property.2⟩,
        y.property.1, y.property.2⟩
      left_inv := fun _ => rfl
      right_inv := fun _ => rfl }
    (fun _ _ h => h) (fun _ _ h => h)) (fun _ _ => Iff.rfl)

/--
**A class lying inside `(c',d')` is the same structure whether cut from `M` or from `M | (c',d')`**
— the identification the shuffle's block map needs, because the block map is *"the `∼`-class of"*
read on `M | (c',d')` while the `γ`-palette is defined by classes cut from `M`.
-/
theorem kEquiv_openSub_restrictSet (k : Nat) (M : OrderedMonadicStructure sig)
    {c' d' : M.carrier} (s : Set M.carrier) (hsub : ∀ x ∈ s, c' < x ∧ x < d') :
    KEquiv sig k ((M.openSubinterval sig c' d').restrictSet sig
        {v : (M.openSubinterval sig c' d').carrier | v.val ∈ s})
      (M.restrictSet sig s) :=
  k_equiv_of_iso sig k _ _ (Equiv.toOrderIso
    { toFun := fun x => ⟨x.val.val, x.property⟩
      invFun := fun y => ⟨⟨y.val, (hsub y.val y.property).1, (hsub y.val y.property).2⟩,
        y.property⟩
      left_inv := fun _ => rfl
      right_inv := fun _ => rfl }
    (fun _ _ h => h) (fun _ _ h => h)) (fun _ _ => Iff.rfl)

variable (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
  [Countable M.carrier] [DenselyOrdered M.carrier]

include hk

/--
**A `∼`-class is very good** — printed p.185's `∼` unwound at the class.

`x ∼ y` *is* very-goodness of `M | (x,y)`, and convexity puts `(x,y)` inside the class, so
`kEquiv_restrictSet_openSub` identifies each open subinterval of `M | E` with such an `M | (x,y)`.
Lemma 11 then supplies the goodness clause and density of `M` the non-emptiness clause.
-/
theorem veryGoodDense_contempClassStructure (h : IsConvexEquiv M (epsDense sig k)) (e : M.carrier) :
    veryGoodDense sig k (contempClassStructure sig M (epsDense sig k) e) := by
  intro u v huv
  have huv' : u.val < v.val := huv
  have huv'' : ContempEquivDense M (epsDense sig k) u.val v.val :=
    h.equiv.trans (h.equiv.symm u.property) v.property
  have hconv : ∀ x : M.carrier, u.val < x → x < v.val →
      x ∈ {y : M.carrier | ContempEquivDense M (epsDense sig k) e y} := by
    intro x hux hxv
    exact h.equiv.trans u.property (h.convex u.val x v.val (le_of_lt hux) (le_of_lt hxv) huv'')
  refine ⟨?_, ?_⟩
  · obtain ⟨z, hz₁, hz₂⟩ := exists_between huv'
    exact ⟨⟨⟨z, hconv z hz₁ hz₂⟩, hz₁, hz₂⟩⟩
  · have hvg : veryGoodDense sig k (M.openSubinterval sig u.val v.val) := by
      rcases (contempEquivDense_epsDense_iff k M u.val v.val).mp huv'' with heq | ⟨-, hv⟩ | ⟨hlt, -⟩
      · exact absurd heq (ne_of_lt huv')
      · exact hv
      · exact absurd hlt (asymm huv')
    haveI : Countable (M.openSubinterval sig u.val v.val).carrier :=
      inferInstanceAs (Countable {x : M.carrier // u.val < x ∧ x < v.val})
    exact goodDense_of_kEquiv sig k (kEquiv_restrictSet_openSub k M _ u v hconv)
      (reynolds_lemma11 sig k hk _ hvg)

/-- **A `∼`-class is good** — very-goodness through Lemma 11. -/
theorem goodDense_contempClassStructure (h : IsConvexEquiv M (epsDense sig k)) (e : M.carrier) :
    goodDense sig k (contempClassStructure sig M (epsDense sig k) e) := by
  haveI : Countable (contempClassStructure sig M (epsDense sig k) e).carrier :=
    inferInstanceAs (Countable {x : M.carrier // ContempEquivDense M (epsDense sig k) e x})
  exact reynolds_lemma11 sig k hk _ (veryGoodDense_contempClassStructure k hk M h e)

/--
**An interior class has a right hand end point** — Layer 9's construction run at `(e,d)`.

The class of a point strictly inside `(c,d)` is bounded above by `d` and is `≁ d`, so Lemma 13 and
D1 attain the bound inside the class.
-/
theorem exists_max_contempClass (D1 : DoetsD1 sig M) {c d e : M.carrier}
    (h : IsConvexEquiv M (epsDense sig k))
    (hbet : ClassStrictlyBetween M (epsDense sig k) c d e) :
    ∃ m : (contempClassStructure sig M (epsDense sig k) e).carrier,
      ∀ y : (contempClassStructure sig M (epsDense sig k) e).carrier, ¬ m < y := by
  have hed : e < d := (h.lt_of_classStrictlyBetween hbet).2
  have hns : ¬ SimDense sig k M e d := fun hc =>
    (h.not_contempEquiv_ends hbet).2 ((contempEquivDense_epsDense_iff k M e d).mpr hc)
  obtain ⟨e', hsim, -, -, hlast⟩ := exists_right_endpoint_class sig k hk M D1 hed hns
  refine ⟨⟨e', (contempEquivDense_epsDense_iff k M e e').mpr hsim⟩, ?_⟩
  intro y hy
  exact hlast y.val hy ((contempEquivDense_epsDense_iff k M e y.val).mp y.property)

/-- **An interior class has a left hand end point** — the mirror, at `(c,e)`. -/
theorem exists_min_contempClass (D1 : DoetsD1 sig M) {c d e : M.carrier}
    (h : IsConvexEquiv M (epsDense sig k))
    (hbet : ClassStrictlyBetween M (epsDense sig k) c d e) :
    ∃ m : (contempClassStructure sig M (epsDense sig k) e).carrier,
      ∀ y : (contempClassStructure sig M (epsDense sig k) e).carrier, ¬ y < m := by
  have hce : c < e := (h.lt_of_classStrictlyBetween hbet).1
  have hns : ¬ SimDense sig k M c e := fun hc =>
    (h.not_contempEquiv_ends hbet).1 ((contempEquivDense_epsDense_iff k M c e).mpr hc)
  obtain ⟨e', hsim, -, -, hfirst⟩ := exists_left_endpoint_class sig k hk M D1 hce hns
  refine ⟨⟨e', (contempEquivDense_epsDense_iff k M e e').mpr hsim⟩, ?_⟩
  intro y hy
  exact hfirst y.val hy ((contempEquivDense_epsDense_iff k M e y.val).mp y.property)

/--
**Reynolds' summand, normalized** — printed p.188, *"the summands themselves are closed intervals
of the reals"*, discharged: every `∼`-class strictly inside `(c,d)` is `≡ₖ` to a closed bounded
interval of `ℝ`, hence satisfies the five summand hypotheses of `goodDense_shuffle`.

This is Layers 11 and 12 composed, and it is the whole of Reynolds' *"choose an `N_γ`"* for the
interior classes.
-/
theorem exists_iccLike_contempClass (D1 : DoetsD1 sig M) {c d e : M.carrier}
    (h : IsConvexEquiv M (epsDense sig k))
    (hbet : ClassStrictlyBetween M (epsDense sig k) c d e) :
    ∃ R : RIntervalStructure sig, IsIccLike sig (R.toOrdered sig) ∧
      KEquiv sig k (contempClassStructure sig M (epsDense sig k) e) (R.toOrdered sig) :=
  exists_iccLike_witness k hk _ (goodDense_contempClassStructure k hk M h e)
    (exists_max_contempClass k hk M D1 h hbet) (exists_min_contempClass k hk M D1 h hbet)

end ClassSummands

/-! ## The residual, narrowed to the shuffle step

Layers 8-10 discharge Reynolds' closing paragraph *except* for the goodness of the middle block
`M | ⋃I`, which is the shuffle. `goodDense_unionClasses` below carries that one obligation, with
every input Reynolds names available in its hypotheses:

* `hmin` is the minimality of `G` — the input to `gammaBetween_dense_of_minimal` (Layer 5), which
  is *"all the `γᵢ`'s in `G` are satisfied densely in `I`"*;
* `D1` gives `I ≃o ℚ` through `nonempty_orderIso_rat_classBetween_epsDense` (Layers 6-7), which is
  *"the classes in `I` have order type `ℚ`"*;
* `D2` gives the dense set of singleton classes, which is the `γ₁` clause of Reynolds' `σ*`;
* `hI` is `⋃I = (c',d')` (Layer 10), so the block map on `M | (c',d')` is indexed by `I`.

**What is still missing, precisely.** Two things, and neither is the composition:

1. **The choice of `N_γ`.** Printed p.187, *"for each `γ ∈ G`, choose an `N_γ ⊨ γ` with flow of time
   an interval of `ℝ`"*, used on p.188 as *"because the `γᵢ`'s say so the summands themselves are
   closed intervals of the reals"*. `goodDense_shuffle` (Layer 3) asks for exactly that in six
   spellings — `hne`, `hdense`, `hsum`, `hbot`, `hone`, `hsep` — and discharging them needs a
   normalization lemma the tree does not have: *"a good, densely ordered, countable structure with
   a least and a greatest point has a `≡ₖ`-equivalent whose flow is a closed bounded interval of
   `ℝ`"*. `exists_ioo_witness` (`GoodDense.lean:713`) is the end-point-**free** case of the same
   normalization, and `icoBlock` / `kEquiv_pointSum_icoBlock` are the one-sided case; the two-sided
   closed case has no counterpart. Lemma 13 is what supplies the two end points on the `M` side.
2. **The choice of `σ`.** Printed p.187, *"we can choose `σ : ℚ → {N_γ | γ ∈ G}` appropriately"*.
   `σ` is not free: it is forced to be *"the `γ` realized by the class at that rational"*, i.e.
   `σ := colour ∘ e.symm` for `e : I ≃o ℚ`. With `σ` so defined, `hmatch` of
   `kEquiv_blocks_shuffle` holds by construction and `IsShuffleMap S σ` is exactly
   `gammaBetween_dense_of_minimal` transported along `e`. So this half is bookkeeping over landed
   assets — but it cannot be written before (1) fixes what `N` is.

The **order** matters: (1) determines the type `ι` and the family `N`, and `σ` lands in `ι`, so (1)
must be written first. Item (1) is genuinely new mathematics of the same kind
`exists_orderIso_ioo01_of_ordConnected` already does once; item (2) is not.
-/

/--
**`M | ⋃I` is good** — Reynolds 1992, §8, printed pp.187-188, the shuffle step:

> Since we have density of `M / ∼`, the classes in `I` have order type `ℚ`. Also, by minimality of
> `G`, all the `γᵢ`'s in `G` are satisfied densely in `I`. … `M | (⋃ I) = Σ_{E ∈ I} M | E ≡ₖ
> Σ_{q ∈ ℚ} σ(q)` … `Σ_{q ∈ ℚ} σ(q) ≡ₖ Σ_{r ∈ ℝ} σ*(r)` … `R` is isomorphic to the reals.

**This is the one remaining gap in Block H**, and it is carried here as a single named `sorry` at
the narrowest statement that still has all of Reynolds' inputs in scope. See the section header
above for the two items it still needs — the closed-interval normalization for `N_γ`, and then the
forced choice of `σ` — and for why they must be done in that order.

Everything this residual is *consumed by* is sorry-free: `goodDense_openSub_of_mid_le` (Layer 8),
the two end-point constructions (Layer 9), and the `⋃I` identification (Layer 10). Everything it
routes *through* is sorry-free: `gammaBetween_dense_of_minimal`,
`nonempty_orderIso_rat_classBetween_epsDense`, `kEquiv_blocks_shuffle`,
`kEquiv_shuffle_shuffleReal`, `nonempty_orderIso_real_shuffleReal`, `goodDense_shuffle`.
-/
theorem goodDense_unionClasses (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [Nonempty M.carrier] [DenselyOrdered M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (D1 : DoetsD1 sig M) (D2 : DoetsD2 sig M) {a b : M.carrier}
    (hmin : ∀ a' b' : M.carrier, a' < b' → ¬ SimDense sig k M a' b' →
      (gammaBetween sig k (epsDense sig k) M a b).card ≤
        (gammaBetween sig k (epsDense sig k) M a' b').card)
    {c d : M.carrier} (hac : a ≤ c) (hcd : c < d) (hdb : d ≤ b)
    (hns : ¬ SimDense sig k M c d) {c' d' : M.carrier} (hc'd' : c' < d')
    (hI : ∀ e : M.carrier, ClassStrictlyBetween M (epsDense sig k) c d e ↔ (c' < e ∧ e < d')) :
    goodDense sig k (M.openSubinterval sig c' d') := by
  sorry

/--
**Reynolds' §8 Theorem 6 contradiction** — printed pp.187-188, assembled.

> We are going to show that `M | (a,b)` is very good thus producing a contradiction.
>
> So suppose that `a < c < d < b`. We need only show that `M | (c,d)` is good. If `c ∼ d` then this
> follows from lemma 11. So suppose not.

The proof below is exactly that: `exists_minimal_gammaBetween` makes Reynolds' choice (Layer 5),
very-goodness of `M | (a,b)` is `SimDense` at `a,b` and so contradicts `a ≁ b` outright,
`veryGoodDense_openSubinterval_iff` reduces it to goodness of each `M | (c,d)`, the `c ∼ d` branch
is Lemma 11, and the `c ≁ d` branch is Layers 8-10 over `goodDense_unionClasses`.

**Honesty note.** This theorem is now free of a `sorry` in its own body, but it is *not* yet
sorry-free: it consumes `goodDense_unionClasses`, which carries the tracked residual. `#print
axioms` still reports `sorryAx` here, and will until the shuffle step lands.
-/
theorem reynolds_theorem6_contradiction (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [Nonempty M.carrier] [DenselyOrdered M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (D1 : DoetsD1 sig M) (D2 : DoetsD2 sig M)
    {a b : M.carrier} (hab : a < b) (hnsim : ¬ SimDense sig k M a b) : False := by
  -- Reynolds' choice: `a₀ < b₀` with `a₀ ≁ b₀` and `G` of minimal size.
  obtain ⟨a₀, b₀, hab₀, hns₀, hmin⟩ :=
    exists_minimal_gammaBetween k (epsDense sig k) M ⟨a, b, hab, hnsim⟩
  -- *"We are going to show that `M | (a,b)` is very good thus producing a contradiction."*
  refine hns₀ (Or.inr (Or.inl ⟨hab₀, ?_⟩))
  rw [veryGoodDense_openSubinterval_iff]
  intro c d hac hcd hdb
  haveI : Countable (M.openSubinterval sig c d).carrier :=
    inferInstanceAs (Countable {x : M.carrier // c < x ∧ x < d})
  refine ⟨?_, ?_⟩
  · obtain ⟨x, hx₁, hx₂⟩ := exists_between hcd; exact ⟨⟨x, hx₁, hx₂⟩⟩
  by_cases hsim : SimDense sig k M c d
  · -- *"If `c ∼ d` then this follows from lemma 11."*
    rcases hsim with heq | ⟨-, hvg⟩ | ⟨hdc, -⟩
    · exact absurd heq (ne_of_lt hcd)
    · exact reynolds_lemma11 sig k hk _ hvg
    · exact absurd hdc (asymm hcd)
  -- *"So suppose not."* — Layers 8-10.
  obtain ⟨c', hsimc, hcc', hc'd, hlast⟩ :=
    exists_right_endpoint_class sig k hk M D1 hcd hsim
  obtain ⟨d', hsimd, hd'd, hcd', hfst⟩ :=
    exists_left_endpoint_class sig k hk M D1 hcd hsim
  have hc'd' : c' < d' := endpoint_lt_endpoint k hk M hsim hsimc hsimd hcd'
  refine goodDense_openSub_of_mid_le k hk M hcc' hc'd' hd'd ?_ ?_ ?_
  · -- `c ∼ c'` with `c < c'`: the middle disjunct of `SimDense` is very-goodness of `M | (c,c')`.
    intro hlt
    rcases hsimc with heq | ⟨-, hvg⟩ | ⟨hc'c, -⟩
    · exact absurd heq (ne_of_lt hlt)
    · exact hvg
    · exact absurd hc'c (asymm hlt)
  · exact goodDense_unionClasses sig k hk M D1 D2 hmin (le_of_lt hac) hcd (le_of_lt hdb) hsim
      hc'd' (classStrictlyBetween_epsDense_iff k hk M hsimc hcc' hlast hsimd hd'd hfst)
  · -- `d ∼ d'` with `d' < d`: the last disjunct is very-goodness of `M | (d',d)`.
    intro hlt
    rcases hsimd with heq | ⟨hdd', -⟩ | ⟨-, hvg⟩
    · exact absurd heq.symm (ne_of_lt hlt)
    · exact absurd hdd' (asymm hlt)
    · exact hvg

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
