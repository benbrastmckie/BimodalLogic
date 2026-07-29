/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.RealModel.ShuffleReal

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

end RealModelTransfer

end FormalSystem.Metalogic.WeakCanonical
