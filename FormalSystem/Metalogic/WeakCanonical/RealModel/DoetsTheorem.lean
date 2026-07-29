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
2. ~~**The `G`-minimality argument.**~~ **Discharged (Layer 5).** `gammaBetween` is Reynolds' `G`
   at a pair, `exists_minimal_gammaBetween` is *"the following choice makes sense"*,
   `gammaBetween_eq_of_minimal` is the *"by minimality of `G`"* step, and
   `gammaBetween_dense_of_minimal` is *"all the `γᵢ`'s in `G` are satisfied densely in `I`"* in the
   form the shuffle construction consumes. All sorry-free.
3. ~~**The order-type-`ℚ` step.**~~ **Discharged (Layers 6-7).** `M/∼` is now built
   (`IsConvexEquiv.ClassQuot`, with `instLinearOrderClassQuot`), Reynolds' `I` is
   `IsConvexEquiv.ClassBetween`, and `nonempty_orderIso_rat_classBetween` is *"the classes in `I`
   have order type `ℚ`"* by `Order.iso_of_countable_dense`. Its `QuotientDenselyOrdered`
   hypothesis is itself discharged from D1 by `quotientDenselyOrdered_epsDense` (Layer 7 — *"by
   lemma 13 and D1 … thus we have density of `M/∼`"*), and
   `nonempty_orderIso_rat_classBetween_epsDense` states the whole thing at Reynolds' own `∼_M`
   with no abstract hypothesis left. All sorry-free.

**What remains, and it is now one thing rather than three: the assembly.** Every ingredient
Reynolds names is landed; what is not landed is the chain that puts them together, printed
p.187 line 141 through p.188:

- **The shuffle map.** Transport `Σ_{E ∈ I} M|E` to `Σ_{q ∈ ℚ} σ(q)` along the `I ≃o ℚ` above,
  choosing `N_γ ⊨ γ` for each `γ ∈ G` and `σ` from `gammaBetween_dense_of_minimal`. The transport
  layer is `kEquiv_orderedSum_blocks` (`Shuffle.lean:424`) plus the reindexing section below it;
  the density input is landed; what has to be written is the choice of `σ` and the discharge of
  `IsShuffleMap`.
- **The `ℝ`-extension and the flow.** `doets_lemma_1_5` and Phase 28's `≅o ℝ` characterization,
  both landed and sorry-free — this step is application, not mathematics.
- **The three-summand decomposition.** `M|(c,d) = M|(c,c'] + M|⋃I + M|[d',d)` with `c'` the right
  end point of `c`'s class and `d'` the left end point of `d`'s. **This is the one place a new
  ingredient is needed**: `c'` and `d'` exist by Lemma 13, but the decomposition of `M|(c,d)` into
  the three pieces, and `M|(c,d) ≡ₖ X + 𝓡 + Y` via `doets_lemma_1_4`, has no counterpart yet.

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
