# Loogle Search Results: update

**Search Pattern**: update  
**Date**: Sun Dec 21 2025  
**Matches Found**: 375+ (showing categorized results from suggestions)

## Overview

The search for "update" functions in the Lean ecosystem reveals a rich collection of utilities for modifying values at specific positions in various data structures. The primary pattern centers around `Function.update`, which serves as the foundation for updating functions at specific points, with specialized versions for different mathematical and computational structures.

## Mathlib Matches

### Core Function Update

1. **Function.update** : `{α : Sort u} {β : α → Sort v} [DecidableEq α] (f : (a : α) → β a) (a' : α) (v : β a') (a : α) : β a`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib
   - Description: Replacing the value of a function at a given point by a given value.

2. **Function.update_injective** : `{α : Sort u} {β : α → Sort v} [DecidableEq α] (f : (a : α) → β a) (a' : α) : Function.Injective (Function.update f a')`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

3. **Function.update_eq_self** : `{α : Sort u} {β : α → Sort v} [DecidableEq α] (a : α) (f : (a : α) → β a) : Function.update f a (f a) = f`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

4. **Function.update_self** : `{α : Sort u} {β : α → Sort v} [DecidableEq α] (a : α) (v : β a) (f : (a : α) → β a) : Function.update f a v a = v`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

5. **Function.update_of_ne** : `{α : Sort u} {β : α → Sort v} [DecidableEq α] {a a' : α} (h : a ≠ a') (v : β a') (f : (a : α) → β a) : Function.update f a' v a = f a`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

6. **Function.update_apply** : `{α : Sort u} [DecidableEq α] {β : Sort u_1} (f : α → β) (a' : α) (b : β) (a : α) : Function.update f a' b a = if a = a' then b else f a`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib
   - Description: On non-dependent functions, `Function.update` can be expressed as an `ite`

7. **Function.update_idem** : `{α : Sort u_2} [DecidableEq α] {β : α → Sort u_1} {a : α} (v w : β a) (f : (a : α) → β a) : Function.update (Function.update f a v) a w = Function.update f a w`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

8. **Function.update_comm** : `{α : Sort u_2} [DecidableEq α] {β : α → Sort u_1} {a b : α} (h : a ≠ b) (v : β a) (w : β b) (f : (a : α) → β a) : Function.update (Function.update f a v) b w = Function.update (Function.update f b w) a v`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

9. **Function.update_comp_eq_of_injective** : `{α : Sort u} {α' : Sort w} [DecidableEq α] [DecidableEq α'] {β : Sort u_1} (g : α' → β) {f : α → α'} (hf : Function.Injective f) (i : α) (a : β) : Function.update g (f i) a ∘ f = Function.update (g ∘ f) i a`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib
   - Description: Non-dependent version of `Function.update_comp_eq_of_injective'`

10. **Function.forall_update_iff** : `{α : Sort u} {β : α → Sort v} [DecidableEq α] (f : (a : α) → β a) {a : α} {b : β a} (p : (a : α) → β a → Prop) : (∀ (x : α), p x (Function.update f a b x)) ↔ p a b ∧ ∀ (x : α), x ≠ a → p x (f x)`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

11. **Function.exists_update_iff** : `{α : Sort u} {β : α → Sort v} [DecidableEq α] (f : (a : α) → β a) {a : α} {b : β a} (p : (a : α) → β a → Prop) : (∃ x, p x (Function.update f a b x)) ↔ p a b ∨ ∃ x, x ≠ a ∧ p x (f x)`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

12. **Function.eq_update_iff** : `{α : Sort u} {β : α → Sort v} [DecidableEq α] {a : α} {b : β a} {f g : (a : α) → β a} : g = Function.update f a b ↔ g a = b ∧ ∀ (x : α), x ≠ a → g x = f x`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

### Pi Type Updates

13. **Pi.mulSingle.eq_1** : `{ι : Type u_1} {M : ι → Type u_6} [(i : ι) → One (M i)] [DecidableEq ι] (i : ι) (x : M i) : Pi.mulSingle i x = Function.update 1 i x`
   - Module: `Mathlib.Algebra.Notation.Pi.Basic`
   - Library: Mathlib

14. **Pi.single.eq_1** : `{ι : Type u_1} {M : ι → Type u_6} [(i : ι) → Zero (M i)] [DecidableEq ι] (i : ι) (x : M i) : Pi.single i x = Function.update 0 i x`
   - Module: `Mathlib.Algebra.Notation.Pi.Basic`
   - Library: Mathlib

15. **Pi.map_update** : `{ι : Sort u_1} [DecidableEq ι] {α : ι → Sort u_2} {β : ι → Sort u_3} {f : (i : ι) → α i → β i} (g : (i : ι) → α i) (i : ι) (a : α i) : Pi.map f (Function.update g i a) = Function.update (Pi.map f g) i (f i a)`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

### Sum Type Updates

16. **Sum.update_inl_apply_inr** : `{α : Type u} {β : Type v} {γ : Type u_1} [DecidableEq (α ⊕ β)] {f : α ⊕ β → γ} {i : α} {j : β} {x : γ} : Function.update f (Sum.inl i) x (Sum.inr j) = f (Sum.inr j)`
   - Module: `Mathlib.Data.Sum.Basic`
   - Library: Mathlib

17. **Sum.update_inr_apply_inl** : `{α : Type u} {β : Type v} {γ : Type u_1} [DecidableEq (α ⊕ β)] {f : α ⊕ β → γ} {i : α} {j : β} {x : γ} : Function.update f (Sum.inr j) x (Sum.inl i) = f (Sum.inl i)`
   - Module: `Mathlib.Data.Sum.Basic`
   - Library: Mathlib

18. **Sum.update_elim_inl** : `{α : Type u} {β : Type v} {γ : Type u_1} [DecidableEq α] [DecidableEq (α ⊕ β)] {f : α → γ} {g : β → γ} {i : α} {x : γ} : Function.update (Sum.elim f g) (Sum.inl i) x = Sum.elim (Function.update f i x) g`
   - Module: `Mathlib.Data.Sum.Basic`
   - Library: Mathlib

19. **Sum.update_elim_inr** : `{α : Type u} {β : Type v} {γ : Type u_1} [DecidableEq β] [DecidableEq (α ⊕ β)] {f : α → γ} {g : β → γ} {i : β} {x : γ} : Function.update (Sum.elim f g) (Sum.inr i) x = Sum.elim f (Function.update g i x)`
   - Module: `Mathlib.Data.Sum.Basic`
   - Library: Mathlib

20. **Sum.elim_update_left** : `{α : Type u} {β : Type v} {γ : Sort u_3} [DecidableEq α] [DecidableEq β] (f : α → γ) (g : β → γ) (a : α) (x : γ) : Sum.elim (Function.update f a x) g = Function.update (Sum.elim f g) (Sum.inl a) x`
   - Module: `Mathlib.Data.Sum.Basic`
   - Library: Mathlib

21. **Sum.elim_update_right** : `{α : Type u} {β : Type v} {γ : Sort u_3} [DecidableEq α] [DecidableEq β] (f : α → γ) (g : β → γ) (b : β) (x : γ) : Sum.elim f (Function.update g b x) = Function.update (Sum.elim f g) (Sum.inr b) x`
   - Module: `Mathlib.Data.Sum.Basic`
   - Library: Mathlib

### Option Type Updates

22. **Option.rec_update** : `{α : Type u_1} {β : Option α → Sort u_2} [DecidableEq α] (f : β none) (g : (a : α) → β (some a)) (a : α) (x : β (some a)) : (fun t => Option.rec f (Function.update g a x) t) = Function.update (fun t => Option.rec f g t) (some a) x`
   - Module: `Mathlib.Logic.Function.Basic`
   - Library: Mathlib

23. **Option.elim'_update** : `{α : Type u_5} {β : Type u_6} [DecidableEq α] (f : β) (g : α → β) (a : α) (x : β) : Option.elim' f (Function.update g a x) = Function.update (Option.elim' f g) (some a) x`
   - Module: `Mathlib.Data.Option.Basic`
   - Library: Mathlib

### Set-Related Updates

24. **Set.eval_preimage** : `{ι : Type u_1} {α : ι → Type u_2} {i : ι} [DecidableEq ι] {s : Set (α i)} : Function.eval i ⁻¹' s = Set.univ.pi (Function.update (fun x => Set.univ) i s)`
   - Module: `Mathlib.Data.Set.Prod`
   - Library: Mathlib

25. **Set.univ_pi_update_univ** : `{ι : Type u_1} {α : ι → Type u_2} [DecidableEq ι] (i : ι) (s : Set (α i)) : Set.univ.pi (Function.update (fun j => Set.univ) i s) = Function.eval i ⁻¹' s`
   - Module: `Mathlib.Data.Set.Prod`
   - Library: Mathlib

26. **Set.update_preimage_univ_pi** : `{ι : Type u_1} {α : ι → Type u_2} {t : (i : ι) → Set (α i)} {i : ι} [DecidableEq ι] {f : (i : ι) → α i} (hf : ∀ (j : ι), j ≠ i → f j ∈ t j) : Function.update f i ⁻¹' Set.univ.pi t = t i`
   - Module: `Mathlib.Data.Set.Prod`
   - Library: Mathlib

27. **Set.update_image** : `{ι : Type u_1} {β : ι → Type u_3} [DecidableEq ι] (x : (i : ι) → β i) (i : ι) (s : Set (β i)) : Function.update x i '' s = Set.univ.pi (Function.update (fun j => {x j}) i s)`
   - Module: `Mathlib.Data.Set.Prod`
   - Library: Mathlib

28. **Set.update_preimage_pi** : `{ι : Type u_1} {α : ι → Type u_2} {s : Set ι} {t : (i : ι) → Set (α i)} {i : ι} [DecidableEq ι] {f : (i : ι) → α i} (hi : i ∈ s) (hf : ∀ j ∈ s, j ≠ i → f j ∈ t j) : Function.update f i ⁻¹' s.pi t = t i`
   - Module: `Mathlib.Data.Set.Prod`
   - Library: Mathlib

29. **Set.update_mem_pi_iff** : `{ι : Type u_1} {α : ι → Type u_2} {s : Set ι} {t : (i : ι) → Set (α i)} [DecidableEq ι] {a : (i : ι) → α i} {i : ι} {b : α i} : Function.update a i b ∈ s.pi t ↔ a ∈ (s \\ {i}).pi t ∧ (i ∈ s → b ∈ t i)`
   - Module: `Mathlib.Data.Set.Prod`
   - Library: Mathlib

30. **Set.piecewise_singleton** : `{α : Type u_1} {β : Type u_2} (x : α) [(y : α) → Decidable (y ∈ {x})] [DecidableEq α] (f g : α → β) : {x}.piecewise f g = Function.update g x (f x)`
   - Module: `Mathlib.Data.Set.Piecewise`
   - Library: Mathlib

31. **Set.piecewise_insert** : `{α : Type u_1} {δ : α → Sort u_7} (s : Set α) (f g : (i : α) → δ i) [(j : α) → Decidable (j ∈ s)] [DecidableEq α] (j : α) [(i : α) → Decidable (i ∈ insert j s)] : (insert j s).piecewise f g = Function.update (s.piecewise f g) j (f j)`
   - Module: `Mathlib.Data.Set.Piecewise`
   - Library: Mathlib

### Order-Related Updates

32. **lt_update_self_iff** : `{ι : Type u_1} {π : ι → Type u_4} [DecidableEq ι] [(i : ι) → Preorder (π i)] {x : (i : ι) → π i} {i : ι} {a : π i} : x < Function.update x i a ↔ x i < a`
   - Module: `Mathlib.Order.Basic`
   - Library: Mathlib

33. **update_lt_self_iff** : `{ι : Type u_1} {π : ι → Type u_4} [DecidableEq ι] [(i : ι) → Preorder (π i)] {x : (i : ι) → π i} {i : ι} {a : π i} : Function.update x i a < x ↔ a < x i`
   - Module: `Mathlib.Order.Basic`
   - Library: Mathlib

34. **le_update_self_iff** : `{ι : Type u_1} {π : ι → Type u_4} [DecidableEq ι] [(i : ι) → Preorder (π i)] {x : (i : ι) → π i} {i : ι} {a : π i} : x ≤ Function.update x i a ↔ x i ≤ a`
   - Module: `Mathlib.Order.Basic`
   - Library: Mathlib

35. **update_le_self_iff** : `{ι : Type u_1} {π : ι → Type u_4} [DecidableEq ι] [(i : ι) → Preorder (π i)] {x : (i : ι) → π i} {i : ι} {a : π i} : Function.update x i a ≤ x ↔ a ≤ x i`
   - Module: `Mathlib.Order.Basic`
   - Library: Mathlib

36. **update_le_update_iff** : `{ι : Type u_1} {π : ι → Type u_4} [DecidableEq ι] [(i : ι) → Preorder (π i)] {x y : (i : ι) → π i} {i : ι} {a b : π i} : Function.update x i a ≤ Function.update y i b ↔ a ≤ b ∧ ∀ (j : ι), j ≠ i → x j ≤ y j`
   - Module: `Mathlib.Order.Basic`
   - Library: Mathlib

37. **Function.update_mono** : `{ι : Type u_1} {π : ι → Type u_3} [DecidableEq ι] [(i : ι) → Preorder (π i)] {f : (i : ι) → π i} {i : ι} : Monotone (Function.update f i)`
   - Module: `Mathlib.Order.Monotone.Defs`
   - Library: Mathlib

38. **Function.update_strictMono** : `{ι : Type u_1} {π : ι → Type u_3} [DecidableEq ι] [(i : ι) → Preorder (π i)] {f : (i : ι) → π i} {i : ι} : StrictMono (Function.update f i)`
   - Module: `Mathlib.Order.Monotone.Defs`
   - Library: Mathlib

39. **Function.update_inf** : `{ι : Type u_1} {π : ι → Type u_2} [DecidableEq ι] [(i : ι) → SemilatticeInf (π i)] (f : (i : ι) → π i) (i : ι) (a b : π i) : Function.update f i (a ⊓ b) = Function.update f i a ⊓ Function.update f i b`
   - Module: `Mathlib.Order.Lattice`
   - Library: Mathlib

40. **Function.update_sup** : `{ι : Type u_1} {π : ι → Type u_2} [DecidableEq ι] [(i : ι) → SemilatticeSup (π i)] (f : (i : ι) → π i) (i : ι) (a b : π i) : Function.update f i (a ⊔ b) = Function.update f i a ⊔ Function.update f i b`
   - Module: `Mathlib.Order.Lattice`
   - Library: Mathlib

### Equivalence-Related Updates

41. **Equiv.swap_eq_update** : `{α : Sort u_1} [DecidableEq α] (i j : α) : ⇑(Equiv.swap i j) = Function.update (Function.update id j i) i j`
   - Module: `Mathlib.Logic.Equiv.Basic`
   - Library: Mathlib

42. **Equiv.comp_swap_eq_update** : `{α : Sort u_1} {β : Sort u_4} [DecidableEq α] (i j : α) (f : α → β) : f ∘ ⇑(Equiv.swap i j) = Function.update (Function.update f j (f i)) i (f j)`
   - Module: `Mathlib.Logic.Equiv.Basic`
   - Library: Mathlib

43. **Function.piCongrLeft'_update** : `{α : Sort u_1} {β : Sort u_4} [DecidableEq α] [DecidableEq β] (P : α → Sort u_10) (e : α ≃ β) (f : (a : α) → P a) (b : β) (x : P (e.symm b)) : (Equiv.piCongrLeft' P e) (Function.update f (e.symm b) x) = Function.update ((Equiv.piCongrLeft' P e) f) b x`
   - Module: `Mathlib.Logic.Equiv.Basic`
   - Library: Mathlib

### Group Action Updates

44. **Function.update_smul** : `{ι : Type u_1} {M : Type u_2} {α : ι → Type u_4} [(i : ι) → SMul M (α i)] [DecidableEq ι] (c : M) (f₁ : (i : ι) → α i) (i : ι) (x₁ : α i) : Function.update (c • f₁) i (c • x₁) = c • Function.update f₁ i x₁`
   - Module: `Mathlib.Algebra.Group.Action.Pi`
   - Library: Mathlib

45. **Function.update_vadd** : `{ι : Type u_1} {M : Type u_2} {α : ι → Type u_4} [(i : ι) → VAdd M (α i)] [DecidableEq ι] (c : M) (f₁ : (i : ι) → α i) (i : ι) (x₁ : α i) : Function.update (c +ᵥ f₁) i (c +ᵥ x₁) = c +ᵥ Function.update f₁ i x₁`
   - Module: `Mathlib.Algebra.Group.Action.Pi`
   - Library: Mathlib

### Support-Related Updates

46. **Function.support_update_of_ne_zero** : `{ι : Type u_1} {M : Type u_3} [Zero M] [DecidableEq ι] (f : ι → M) (x : ι) {y : M} (hy : y ≠ 0) : Function.support (Function.update f x y) = insert x (Function.support f)`
   - Module: `Mathlib.Algebra.Notation.Support`
   - Library: Mathlib

47. **Function.support_update_zero** : `{ι : Type u_1} {M : Type u_3} [Zero M] [DecidableEq ι] (f : ι → M) (x : ι) : Function.support (Function.update f x 0) = Function.support f \\ {x}`
   - Module: `Mathlib.Algebra.Notation.Support`
   - Library: Mathlib

48. **Function.mulSupport_update_of_ne_one** : `{ι : Type u_1} {M : Type u_3} [One M] [DecidableEq ι] (f : ι → M) (x : ι) {y : M} (hy : y ≠ 1) : Function.mulSupport (Function.update f x y) = insert x (Function.mulSupport f)`
   - Module: `Mathlib.Algebra.Notation.Support`
   - Library: Mathlib

49. **Function.mulSupport_update_one** : `{ι : Type u_1} {M : Type u_3} [One M] [DecidableEq ι] (f : ι → M) (x : ι) : Function.mulSupport (Function.update f x 1) = Function.mulSupport f \\ {x}`
   - Module: `Mathlib.Algebra.Notation.Support`
   - Library: Mathlib

### List-Related Updates

50. **List.Nodup.map_update** : `{α : Type u} {β : Type v} [DecidableEq α] {l : List α} (hl : l.Nodup) (f : α → β) (x : α) (y : β) : List.map (Function.update f x y) l = if x ∈ l then (List.map f l).set (List.idxOf x l) y else List.map f l`
   - Module: `Mathlib.Data.List.Nodup`
   - Library: Mathlib

### Finitely Supported Functions

51. **Finsupp.update** : `{α : Type u_1} {M : Type u_5} [Zero M] (f : α →₀ M) (a : α) (b : M) : α →₀ M`
   - Module: `Mathlib.Data.Finsupp.Single`
   - Library: Mathlib
   - Description: Replace the value of a `α →₀ M` at a given point `a : α` by a given value `b : M`. If `b = 0`, this amounts to removing `a` from the `Finsupp.support`. Otherwise, if `a` was not in the `Finsupp.support`, it is added to it. This is the finitely-supported version of `Function.update`.

52. **DFinsupp.update** : `{ι : Type u} {β : ι → Type v} [(i : ι) → Zero (β i)] [DecidableEq ι] (f : Π₀ (i : ι), β i) (i : ι) (b : β i) : Π₀ (i : ι), β i`
   - Module: `Mathlib.Data.DFinsupp.Defs`
   - Library: Mathlib
   - Description: Replace the value of a `Π₀ i, β i` at a given point `i : ι` by a given value `b : β i`. If `b = 0`, this amounts to removing `i` from the support. Otherwise, `i` is added to it. This is the (dependent) finitely-supported version of `Function.update`.

### Polynomial Updates

53. **Polynomial.update** : `{R : Type u} [Semiring R] (p : Polynomial R) (n : ℕ) (a : R) : Polynomial R`
   - Module: `Mathlib.Algebra.Polynomial.Basic`
   - Library: Mathlib
   - Description: Replace the coefficient of a `p : R[X]` at a given degree `n : ℕ` by a given value `a : R`. If `a = 0`, this is equal to `p.erase n`. If `p.natDegree < n` and `a ≠ 0`, this increases the degree to `n`.

### Topology-Related Updates

54. **Continuous.update** : `{X : Type u} {ι : Type u_5} {A : ι → Type u_6} [TopologicalSpace X] [T : (i : ι) → TopologicalSpace (A i)] {f : X → (i : ι) → A i} [DecidableEq ι] (hf : Continuous f) (i : ι) {g : X → A i} (hg : Continuous g) : Continuous fun a => Function.update (f a) i (g a)`
   - Module: `Mathlib.Topology.Constructions`
   - Library: Mathlib

55. **ContinuousAt.update** : `{X : Type u} {ι : Type u_5} {A : ι → Type u_6} [TopologicalSpace X] [T : (i : ι) → TopologicalSpace (A i)] {f : X → (i : ι) → A i} [DecidableEq ι] {x : X} (hf : ContinuousAt f x) (i : ι) {g : X → A i} (hg : ContinuousAt g x) : ContinuousAt (fun a => Function.update (f a) i (g a)) x`
   - Module: `Mathlib.Topology.Constructions`
   - Library: Mathlib

56. **Filter.Tendsto.update** : `{Y : Type v} {ι : Type u_5} {A : ι → Type u_6} [T : (i : ι) → TopologicalSpace (A i)] [DecidableEq ι] {l : Filter Y} {f : Y → (i : ι) → A i} {x : (i : ι) → A i} (hf : Filter.Tendsto f l (nhds x)) (i : ι) {g : Y → A i} {xi : A i} (hg : Filter.Tendsto g l (nhds xi)) : Filter.Tendsto (fun a => Function.update (f a) i (g a)) l (nhds (Function.update x i xi))`
   - Module: `Mathlib.Topology.Constructions`
   - Library: Mathlib

### Infinite Sum/Product Updates

57. **HasProd.update** : `{α : Type u_1} {β : Type u_2} {L : SummationFilter β} [CommGroup α] [TopologicalSpace α] [IsTopologicalGroup α] {f : β → α} {a₁ : α} [L.LeAtTop] (hf : HasProd f a₁ L) (b : β) [DecidableEq β] (a : α) : HasProd (Function.update f b a) (a / f b * a₁) L`
   - Module: `Mathlib.Topology.Algebra.InfiniteSum.Group`
   - Library: Mathlib

58. **HasSum.update** : `{α : Type u_1} {β : Type u_2} {L : SummationFilter β} [AddCommGroup α] [TopologicalSpace α] [IsTopologicalAddGroup α] {f : β → α} {a₁ : α} [L.LeAtTop] (hf : HasSum f a₁ L) (b : β) [DecidableEq β] (a : α) : HasSum (Function.update f b a) (a - f b + a₁) L`
   - Module: `Mathlib.Topology.Algebra.InfiniteSum.Group`
   - Library: Mathlib

59. **Summable.update** : `{α : Type u_1} {β : Type u_2} {L : SummationFilter β} [AddCommGroup α] [TopologicalSpace α] [IsTopologicalAddGroup α] {f : β → α} [L.LeAtTop] (hf : Summable f L) (b : β) [DecidableEq β] (a : α) : Summable (Function.update f b a) L`
   - Module: `Mathlib.Topology.Algebra.InfiniteSum.Group`
   - Library: Mathlib

60. **Multipliable.update** : `{α : Type u_1} {β : Type u_2} {L : SummationFilter β} [CommGroup α] [TopologicalSpace α] [IsTopologicalGroup α] {f : β → α} [L.LeAtTop] (hf : Multipliable f L) (b : β) [DecidableEq β] (a : α) : Multipliable (Function.update f b a) L`
   - Module: `Mathlib.Topology.Algebra.InfiniteSum.Group`
   - Library: Mathlib

### Miscellaneous Mathlib

61. **ULift.rec_update** : `{α : Type u} {β : ULift.{u_2, u} α → Type u_1} [DecidableEq α] (f : (a : α) → β { down := a }) (a : α) (x : β { down := a }) : (fun t => ULift.rec (Function.update f a x) t) = Function.update (fun t => ULift.rec f t) { down := a } x`
   - Module: `Mathlib.Data.ULift`
   - Library: Mathlib

62. **Sigma.curry_update** : `{α : Type u_1} {β : α → Type u_4} {γ : (a : α) → β a → Type u_7} [DecidableEq α] [(a : α) → DecidableEq (β a)] (i : (a : α) × β a) (f : (i : (a : α) × β a) → γ i.fst i.snd) (x : γ i.fst i.snd) : Sigma.curry (Function.update f i x) = Function.update (Sigma.curry f) i.fst (Function.update (Sigma.curry f i.fst) i.snd x)`
   - Module: `Mathlib.Data.Sigma.Basic`
   - Library: Mathlib

63. **Stream'.Seq.update** : `{α : Type u} (s : Stream'.Seq α) (n : ℕ) (f : α → α) : Stream'.Seq α`
   - Module: `Mathlib.Data.Seq.Defs`
   - Library: Mathlib
   - Description: Applies `f` to the `n`th element of the sequence, if it exists, replacing that element with the result.

64. **DependsOn.update** : `{ι : Type u_2} {π : ι → Type u_3} [DecidableEq ι] {α : Type u_1} {f : ((i : ι) → π i) → α} {s : Finset ι} (hf : DependsOn f ↑s) (i : ι) (y : π i) : DependsOn (fun x => f (Function.update x i y)) ↑(s.erase i)`
   - Module: `Mathlib.Data.Finset.Update`
   - Library: Mathlib
   - Description: If one replaces the variable indexed by `i`, then `f` no longer depends on this variable.

65. **SkewMonoidAlgebra.update** : `{M : Type u_4} {α : Type u_5} [AddCommMonoid M] (f : SkewMonoidAlgebra M α) (a : α) (b : M) : SkewMonoidAlgebra M α`
   - Module: `Mathlib.Algebra.SkewMonoidAlgebra.Single`
   - Library: Mathlib
   - Description: Replace the coefficient of an element `f` of a skew monoid algebra at a given point `a : α` by a given value `b : M`. If `b = 0`, this amounts to removing `a` from the support of `f`. Otherwise, if `a` was not in the `support` of `f`, it is added to it.

66. **MeromorphicAt.update** : `{𝕜 : Type u_1} [NontriviallyNormedField 𝕜] {E : Type u_2} [NormedAddCommGroup E] [NormedSpace 𝕜 E] [DecidableEq 𝕜] {f : 𝕜 → E} {z : 𝕜} (hf : MeromorphicAt f z) (w : 𝕜) (e : E) : MeromorphicAt (Function.update f w e) z`
   - Module: `Mathlib.Analysis.Meromorphic.Basic`
   - Library: Mathlib

67. **dite_comp_equiv_update** : `{α : Type u_1} {E : Type u_2} {β : Sort u_3} {γ : Sort u_4} {p : α → Prop} [EquivLike E { x // p x } β] (e : E) (v : β → γ) (w : α → γ) (j : β) (x : γ) [DecidableEq β] [DecidableEq α] [(j : α) → Decidable (p j)] : (fun i => if h : p i then Function.update v j x (e ⟨i, h⟩) else w i) = Function.update (fun i => if h : p i then v (e ⟨i, h⟩) else w i) (↑(EquivLike.inv e j)) x`
   - Module: `Mathlib.Logic.Equiv.Set`
   - Library: Mathlib
   - Description: The composition of an updated function with an equiv on a subtype can be expressed as an updated function.

## Lean Core Matches

68. **Lean.KVMap.update** : `{α : Type} [Lean.KVMap.Value α] (m : Lean.KVMap) (k : Lean.Name) (f : Option α → Option α) : Lean.KVMap`
   - Module: `Lean.Data.KVMap`
   - Library: Lean core

69. **Lean.Compiler.LCNF.FunDecl.update** : `(decl : Lean.Compiler.LCNF.FunDecl) (type : Lean.Expr) (params : Array Lean.Compiler.LCNF.Param) (value : Lean.Compiler.LCNF.Code) : Lean.Compiler.LCNF.CompilerM Lean.Compiler.LCNF.FunDecl`
   - Module: `Lean.Compiler.LCNF.CompilerM`
   - Library: Lean core

70. **Lean.Compiler.LCNF.LetDecl.update** : `(decl : Lean.Compiler.LCNF.LetDecl) (type : Lean.Expr) (value : Lean.Compiler.LCNF.LetValue) : Lean.Compiler.LCNF.CompilerM Lean.Compiler.LCNF.LetDecl`
   - Module: `Lean.Compiler.LCNF.CompilerM`
   - Library: Lean core

71. **Lean.Compiler.LCNF.Param.update** : `(p : Lean.Compiler.LCNF.Param) (type : Lean.Expr) : Lean.Compiler.LCNF.CompilerM Lean.Compiler.LCNF.Param`
   - Module: `Lean.Compiler.LCNF.CompilerM`
   - Library: Lean core

72. **Lean.Server.Watchdog.ImportData.update** : `(d : Lean.Server.Watchdog.ImportData) (uri : Lean.Lsp.DocumentUri) (imports : Std.TreeSet Lean.Lsp.DocumentUri compare) : Lean.Server.Watchdog.ImportData`
   - Module: `Lean.Server.Watchdog`
   - Library: Lean core
   - Description: Updates `d` with the new set of `imports` for the file `uri`.

## Std Library Matches

73. **Batteries.Random.MersenneTwister.State.update** : `{cfg : Batteries.Random.MersenneTwister.Config} (state : Batteries.Random.MersenneTwister.State cfg) (steps : ℕ := 1) : Batteries.Random.MersenneTwister.State cfg`
   - Module: `Batteries.Data.Random.MersenneTwister`
   - Library: Batteries (Std)
   - Description: Update the state by a number of generation steps (default 1).

## Tactic/Meta Matches

74. **Mathlib.Tactic.Linarith.update** : `(maxVar : ℕ) (comps : Mathlib.Tactic.Linarith.PCompSet) : Mathlib.Tactic.Linarith.LinarithM Unit`
   - Module: `Mathlib.Tactic.Linarith.Oracle.FourierMotzkin`
   - Library: Mathlib
   - Description: Updates the current state with a new max variable and comparisons, and calls `validate` to check for a contradiction.

## Summary

The Loogle search for "update" reveals **375+ matches** across the Lean ecosystem, with the vast majority residing in Mathlib. The results showcase a comprehensive ecosystem of update functions centered around the core `Function.update` primitive.

### Key Patterns

1. **Core Pattern**: `Function.update` serves as the foundational building block, providing the ability to modify a function at a single point while preserving all other values.

2. **Type-Specific Variants**: Specialized update functions exist for:
   - **Finitely-supported structures**: `Finsupp.update`, `DFinsupp.update`
   - **Polynomials**: `Polynomial.update`
   - **Algebraic structures**: `SkewMonoidAlgebra.update`
   - **Sequences**: `Stream'.Seq.update`

3. **Compositional Properties**: Extensive library of lemmas showing how `update` interacts with:
   - Type constructors (Sum, Option, Sigma, ULift)
   - Set operations (preimage, image, pi sets)
   - Order relations (≤, <, ⊓, ⊔)
   - Algebraic operations (smul, vadd)
   - Topological properties (continuity, limits, summability)
   - Function composition and injection

4. **Specialized Lemmas**: Over 300 supporting theorems covering:
   - Identity properties (`update_self`, `update_eq_self`)
   - Commutativity (`update_comm`, `update_idem`)
   - Equivalence characterizations (`eq_update_iff`, `update_eq_iff`)
   - Quantifier manipulation (`forall_update_iff`, `exists_update_iff`)
   - Support tracking (`support_update_zero`, `mulSupport_update_one`)

### Most Useful Matches

For general programming:
- **Function.update**: The core primitive for point-wise function updates
- **Function.update_apply**: Provides the if-then-else characterization
- **Finsupp.update**: For sparse data structures with finite support

For theorem proving:
- **Function.forall_update_iff**: Critical for reasoning about universal properties
- **Function.eq_update_iff**: Essential for equality reasoning
- **update_le_update_iff**: Key for order-theoretic arguments

For topology/analysis:
- **Continuous.update**: Preserves continuity when updating functions
- **HasSum.update**: Modifies summable sequences while tracking the sum
- **MeromorphicAt.update**: Preserves meromorphicity

### Implementation Notes

All update functions require `[DecidableEq α]` to determine whether we're updating at a specific index. The dependent type version allows the codomain to vary with the domain, making it extremely flexible for heterogeneous structures.

The pattern of having both the core operation and an extensive library of interaction lemmas makes the update operation highly composable and practical for both computation and reasoning in Lean.
