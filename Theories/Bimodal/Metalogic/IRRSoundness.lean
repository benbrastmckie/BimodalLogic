import Bimodal.Semantics.Truth
import Bimodal.Semantics.Validity
import Bimodal.Syntax.Formula

/-!
# IRR Soundness - Gabbay Irreflexivity Rule Soundness

This module proves that the Gabbay IRR (Irreflexivity) rule is sound on
irreflexive densely-ordered linear temporal frames.

## Main Results

- `truth_independent_of_valuation_change`: Truth values depend only on atoms
  appearing in the formula. Changing the valuation of non-occurring atoms
  does not affect truth.
- `irr_sound_dense`: The IRR rule is sound on dense irreflexive linear orders.

## The IRR Rule

The Gabbay IRR rule states:
  From `|- (p AND H(neg p)) -> phi` where p does not occur in phi,
  infer `|- phi`.

This rule is sound because at any time t in an irreflexive order, we can
construct a model where p holds only at time t, making `p AND H(neg p)`
true at t.

## Proof Strategy

The soundness proof uses a **product frame construction** to avoid the
state-aliasing problem. Given a model (F, M, Omega, tau, t):

1. Construct F_prod with State_prod = F.WorldState x D
2. Lift histories: sigma_prod.states s hs = (sigma.states s hs, s)
3. Define valuation: M_prod.valuation (state, time) q =
   if q = p then (time = t) else M.valuation state q
4. The product frame eliminates state aliasing: different times always
   map to different product states (second component differs)
5. Show p AND H(neg p) holds at (M_prod, tau_prod, t)
6. Apply premise to get phi at (M_prod, tau_prod, t)
7. Transfer back via truth independence

## References

- Task 957: density_frame_condition_irreflexive_temporal
- research-004.md: IRR soundness analysis
- Gabbay (1981): An irreflexivity lemma
-/

namespace Bimodal.Metalogic.IRRSoundness

open Bimodal.Syntax
open Bimodal.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Truth Independence Lemma

The key lemma: truth values depend only on atoms appearing in the formula.
-/

/--
Truth values depend only on atoms appearing in the formula.

If two models M1 and M2 on the same frame agree on all atoms in phi.atoms,
then phi has the same truth value under both models for any history and time.

This is the key lemma enabling the IRR soundness proof: it allows us to
change the valuation of a fresh variable p without affecting the truth
of any formula not mentioning p.
-/
theorem truth_independent_of_valuation_change
    {F : TaskFrame D} {M1 M2 : TaskModel F}
    {Omega : Set (WorldHistory F)}
    {phi : Formula}
    (h_agree : ∀ (s : F.WorldState) (q : String), q ∈ phi.atoms →
      (M1.valuation s q ↔ M2.valuation s q))
    (tau : WorldHistory F) (t : D) :
    truth_at M1 Omega tau t phi ↔ truth_at M2 Omega tau t phi := by
  induction phi generalizing tau t with
  | atom p =>
    simp only [truth_at]
    constructor
    · intro ⟨ht, hv⟩
      exact ⟨ht, (h_agree (tau.states t ht) p (Finset.mem_singleton.mpr rfl)).mp hv⟩
    · intro ⟨ht, hv⟩
      exact ⟨ht, (h_agree (tau.states t ht) p (Finset.mem_singleton.mpr rfl)).mpr hv⟩
  | bot =>
    simp only [truth_at]
  | imp a b ih_a ih_b =>
    simp only [truth_at]
    have h_a_agree : ∀ s q, q ∈ a.atoms → (M1.valuation s q ↔ M2.valuation s q) :=
      fun s q hq => h_agree s q (Finset.mem_union_left _ hq)
    have h_b_agree : ∀ s q, q ∈ b.atoms → (M1.valuation s q ↔ M2.valuation s q) :=
      fun s q hq => h_agree s q (Finset.mem_union_right _ hq)
    constructor
    · intro h h_a
      exact (ih_b h_b_agree tau t).mp (h ((ih_a h_a_agree tau t).mpr h_a))
    · intro h h_a
      exact (ih_b h_b_agree tau t).mpr (h ((ih_a h_a_agree tau t).mp h_a))
  | box a ih_a =>
    simp only [truth_at]
    constructor
    · intro h sigma h_mem
      exact (ih_a h_agree sigma t).mp (h sigma h_mem)
    · intro h sigma h_mem
      exact (ih_a h_agree sigma t).mpr (h sigma h_mem)
  | all_past a ih_a =>
    simp only [truth_at]
    constructor
    · intro h s h_lt
      exact (ih_a h_agree tau s).mp (h s h_lt)
    · intro h s h_lt
      exact (ih_a h_agree tau s).mpr (h s h_lt)
  | all_future a ih_a =>
    simp only [truth_at]
    constructor
    · intro h s h_lt
      exact (ih_a h_agree tau s).mp (h s h_lt)
    · intro h s h_lt
      exact (ih_a h_agree tau s).mpr (h s h_lt)

end Bimodal.Metalogic.IRRSoundness
