/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ForMathlib

/-!
# Isolated-import smoke checks for `FormalSystem/ForMathlib/`

Everything under `FormalSystem/ForMathlib/` is a Mathlib-shaped extension intended for
upstreaming, importing nothing from `FormalSystem.*`. Until this module existed, those files were
exercised only *transitively*, through the seven `FormalSystem` modules that consume them — which
means nothing checked that they stand up on their own, which is precisely the property an upstream
PR is judged on.

**The single import is the artifact.** This module imports only `FormalSystem.ForMathlib`; a
second `FormalSystem.*` import would defeat the whole point, since the isolation is what makes
this a PR-readiness check rather than an incidental by-product of the in-tree consumers. The
`grep -c "^import"` criterion in the governing plan pins exactly that.

It is deliberately **one** module, not one per file, and deliberately `#check`/`example` only:
a `#check` per public declaration reaches each file's whole surface, and one minimal instantiating
`example` per file shows the headline declaration is usable at a concrete type rather than merely
well-formed. Nothing here proves a new theorem — a full test module per `ForMathlib` file would be
the over-built shape, and these files' own correctness obligations are discharged where they are
stated.

## Files reached

* `FormalSystem/ForMathlib/Order/BallSpace.lean` — `Order.IsNest` and the spherical-completeness
  reduction
* `FormalSystem/ForMathlib/Order/PFilter.lean` — the proper/maximal/prime filter API and
  `Order.PrimeFilter`
* `FormalSystem/ForMathlib/Combinatorics/SimpleGraphAcyclic.lean` —
  `SimpleGraph.isAcyclic_of_rank_parent`
* `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` —
  `Nat.exists_strictMono_const_pair_colour`
* `FormalSystem/ForMathlib/Topology/Sierpinski.lean` — the locally-constant locus and the
  countable-range form of Sierpiński's theorem
-/

namespace BimodalTest.ForMathlib.SmokeTest

/-! ## `Order/BallSpace.lean` -/

#check @Order.IsNest
#check @Order.IsNest.exists_subset_inter
#check @Order.SphericallyComplete
#check @Order.HasCofinalNest
#check @Order.sInter_nonempty_of_sphericallyComplete

example : Order.IsNest ({Set.univ} : Set (Set ℕ)) :=
  ⟨⟨Set.univ, rfl⟩, by simp [IsChain, Set.Pairwise]⟩

example {W : Type} {S : Set (Set W)} (h : Order.IsNest S) (s : Set W) (hs : s ∈ S) :
    ∃ s' ∈ S, s' ⊆ s ∩ s := h.exists_subset_inter s hs s hs

/-! ## `Order/PFilter.lean` -/

#check @Order.PFilter.mem_dual_iff
#check @Order.PFilter.le_iff_dual_le
#check @Order.PFilter.lt_iff_dual_lt
#check @Order.PFilter.coe_eq_univ_iff
#check @Order.PFilter.IsProper
#check @Order.PFilter.isProper_of_notMem
#check @Order.PFilter.IsProper.exists_notMem
#check @Order.PFilter.isProper_iff_dual
#check @Order.PFilter.IsMaximal
#check @Order.PFilter.isMaximal_iff_dual
#check @Order.PFilter.IsPrime.toIsProper
#check @Order.PFilter.isPrime_iff_dual
#check @Order.PFilter.IsProper.bot_notMem
#check @Order.PFilter.isProper_iff_bot_notMem
#check @Order.PFilter.IsProper.exists_le_maximal
#check @Order.PFilter.IsMaximal.isPrime
#check @Order.PFilter.IsProper.notMem_of_compl_mem
#check @Order.PFilter.IsProper.notMem_or_compl_notMem
#check @Order.PFilter.IsPrime.mem_or_compl_mem
#check @Order.PFilter.IsPrime.compl_mem_of_notMem
#check @Order.PFilter.IsPrime.compl_notMem_of_mem
#check @Order.PFilter.IsPrime.mem_iff_compl_notMem
#check @Order.PFilter.IsPrime.compl_mem_iff_notMem
#check @Order.PFilter.isPrime_of_mem_or_compl_mem
#check @Order.PFilter.isPrime_iff_mem_or_compl_mem
#check @Order.PFilter.IsPrime.isMaximal
#check @Order.PFilter.IsProper.exists_le_prime
#check @DistribLattice.prime_filter_of_disjoint_filter_ideal
#check @Order.PrimeFilter
#check @Order.PrimeFilter.mem_iff
#check @Order.PrimeFilter.ext

example {P : Type} [Preorder P] [OrderBot P] {F : Order.PFilter P} (h : (⊥ : P) ∉ F) :
    F.IsProper := Order.PFilter.isProper_iff_bot_notMem.mpr h

example {P : Type} [Preorder P] {U : Order.PrimeFilter P} {x : P} (h : x ∈ U.1) : x ∈ U :=
  Order.PrimeFilter.mem_iff.mpr h

/-! ## `Combinatorics/SimpleGraphAcyclic.lean` -/

#check @SimpleGraph.isAcyclic_of_rank_parent

example : (⊥ : SimpleGraph ℕ).IsAcyclic :=
  SimpleGraph.isAcyclic_of_rank_parent (fun _ => 0) id (fun _ => le_rfl)
    fun {_ _} h => absurd h (by simp)

/-! ## `Combinatorics/InfiniteRamseyPairs.lean` -/

#check @Nat.exists_strictMono_const_pair_colour

example (c : ℕ → ℕ → Bool) :
    ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : Bool, ∀ i j : ℕ, i < j → c (g i) (g j) = τ :=
  Nat.exists_strictMono_const_pair_colour c

/-! ## `Topology/Sierpinski.lean` -/

#check @Sierpinski.levelSet
#check @Sierpinski.locallyConstantLocus
#check @Sierpinski.mem_levelSet
#check @Sierpinski.isOpen_locallyConstantLocus
#check @Sierpinski.mem_locallyConstantLocus_iff
#check @Sierpinski.const_of_isPreconnected
#check @Sierpinski.const_of_isClosed_levelSet
#check @Sierpinski.const_of_countable_range

example (c : Bool) : IsOpen (Sierpinski.locallyConstantLocus (fun _ : ℝ => c)) :=
  Sierpinski.isOpen_locallyConstantLocus _

/-- The level sets of a constant `ℝ → Bool` are `Set.univ` and `∅`, both closed, so the
countable-range form of Sierpiński's theorem applies. The two branches need different `simp`
calls: a `simpa` form and an explicit `isClosed_empty` were both measured to fail here, and under
this repository's zero warning budget an `unnecessarySimpa` warning is itself a gate failure. -/
example (c : Bool) : ∀ s t : ℝ, (fun _ : ℝ => c) s = (fun _ : ℝ => c) t := by
  refine Sierpinski.const_of_countable_range (fun _ : ℝ => c) (Set.to_countable _) ?_
  intro a
  rcases eq_or_ne a c with rfl | hac
  · simp [Sierpinski.levelSet]
  · simp [Sierpinski.levelSet, Ne.symm hac]

end BimodalTest.ForMathlib.SmokeTest
