/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Periodic
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.FrameClassValidity
import Mathlib.Data.Fintype.Pi
import Mathlib.Data.Int.SuccPred
import Mathlib.Order.SuccPred.LinearLocallyFinite

/-!
# The Label-Free Branching Substrate

`SharingWitnessFamily` carries two independent data: a **label row** — the lassos, their decoded
`Finset Formula` labels, and the box guess — and a **periodic representative structure** — three
segments of maps `Fin n → Fin n` whose decoding says which lasso indices name the same world
state at each time.

Every construction the branching device is built from stands on the second datum alone. The
per-time equivalence `share`, the threads that step across it, the quotient frame over `intOrder`
and the world histories that frame admits are all functions of the representative structure; not
one of them inspects a label, a formula, or the box guess.

## The measurement that licenses this module

`Sharing/{Basic,Thread,Frame,Histories}.lean` together are 1,065 lines, and across all four the
tokens `Formula`, `.L `, `.lab` and `.bx` occur **zero** times. The substrate is not
*approximately* language-agnostic; it is exactly language-agnostic, and the `Formula` indexing it
used to carry was incidental.

`SharingSkeleton` is that datum on its own. A certificate indexed by any formula type projects
onto it and inherits the whole branching theory rather than re-proving it, and
`SharingWitnessFamily` becomes one such certificate: `Sharing/Basic.lean` and its three siblings
keep every name they exported, at its original statement, as a thin delegation through
`SharingWitnessFamily.skeleton`.

## `share` is the kernel of a map, not a relation field

The sharing datum could have been three lists of *relations* on `Fin n` together with a proof
that each is an equivalence. It is instead three lists of **representative maps**
`Fin n → Fin n`, with

```
share u i j  :=  rep u i = rep u j
```

Two consequences, both deliberate:

* `share u` is an equivalence relation *for free* — it is the kernel of a function — so
  `share_refl`, `share_symm` and `share_trans` are `rfl`, `Eq.symm` and `Eq.trans` and the
  structure carries no `share_equiv` field to discharge.
* The datum decodes through `Periodic.unrollOf`, exactly as labels do, so the leftward and
  rightward periodicities are instantiations of `Periodic.unrollOf_sub_back_length` and
  `Periodic.unrollOf_add_fwd_length` with no new arithmetic.

The out-of-range default of the decoding is the identity map, so outside the three encoded
segments `share` degenerates to equality — the deterministic reading — rather than to an
arbitrary collapse.

`rep_idem` is not needed for the equivalence laws; it is what makes the decoded map an honest
*choice of representatives* (`rep u i` is itself `share u`-equivalent to `i`), which is what the
quotient carrier and the specialization consume.

## Main Definitions

- `SharingSkeleton` — three periodic segments of representative maps on `Fin n`
- `SharingSkeleton.rep` — the decoded bi-infinite representative map
- `SharingSkeleton.share` — the per-time equivalence, as the kernel of `rep`

## Main Results

- `SharingSkeleton.share_refl` / `share_symm` / `share_trans` — the equivalence laws
- `SharingSkeleton.rep_sub_back_length` / `rep_add_fwd_length` — the two periodicities
- `SharingSkeleton.rep_idem'` — the decoded map is idempotent
- `SharingSkeleton.decidableShare` — `share` is decidable
-/

namespace FormalSystem.Metalogic.Decidability

/--
The `Inhabited` instance the representative-map decoding runs at: out of range, the identity.

Declared as a plain `abbrev` rather than an `instance`, so it never competes with
`Pi.instInhabited` during synthesis; every use site passes it explicitly with `@`.
-/
abbrev repIdInhabited (n : ℕ) : Inhabited (Fin n → Fin n) := ⟨id⟩

/--
The `Inhabited` instance the succession-matrix decoding runs at: out of range, the identity
relation. The twin of `repIdInhabited`, and declared as an `abbrev` for the same reason — it
must never compete with `Pi.instInhabited` during synthesis, so every use site passes it
explicitly with `@`.
-/
abbrev transEqInhabited (n : ℕ) : Inhabited (Fin n → Fin n → Bool) :=
  ⟨fun i j => decide (i = j)⟩

/-! ## The raw substrate layer

Everything in this section is stated over *explicitly passed* periodic data rather than over a
`SharingSkeleton`. That is what lets `SharingSkeleton` carry `LiftableRaw` as one of its own
well-formedness fields: a field may mention only the fields declared before it, never the
structure being defined. It is the same reason `Periodic.unrollOf` is a function of three lists
rather than of a structure.

Once the structure exists, each of these is definitionally the corresponding projection
(`K.rep`, `K.share`, `K.Step`, `K.trans`), so nothing downstream has to reason through the two
layers separately.
-/

/-- The decoded representative map, over raw data. `SharingSkeleton.rep` is this at the
structure's own fields. -/
def repOf (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n)) (u : ℤ) : Fin n → Fin n :=
  @Periodic.unrollOf _ (repIdInhabited n) repBack repMid repFwd u

/-- Naming the same world state at time `u`, over raw data. -/
def shareOf (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n)) (u : ℤ) (i j : Fin n) : Prop :=
  repOf n repBack repMid repFwd u i = repOf n repBack repMid repFwd u j

theorem shareOf_refl (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n)) (u : ℤ) (i : Fin n) :
    shareOf n repBack repMid repFwd u i i := rfl

theorem shareOf_symm {n : ℕ} {repBack repMid repFwd : List (Fin n → Fin n)} {u : ℤ} {i j : Fin n}
    (h : shareOf n repBack repMid repFwd u i j) : shareOf n repBack repMid repFwd u j i := h.symm

theorem shareOf_trans {n : ℕ} {repBack repMid repFwd : List (Fin n → Fin n)} {u : ℤ}
    {i j k : Fin n} (hij : shareOf n repBack repMid repFwd u i j)
    (hjk : shareOf n repBack repMid repFwd u j k) : shareOf n repBack repMid repFwd u i k :=
  hij.trans hjk

/-- The class-level one-step relation, over raw data. `SharingSkeleton.Step` is this at the
structure's own fields. -/
def stepOf (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n)) (u : ℤ) (i j : Fin n) : Prop :=
  ∃ i', shareOf n repBack repMid repFwd u i i' ∧ shareOf n repBack repMid repFwd (u + 1) i' j

/-- The decoded succession matrix, over raw data. -/
def transMatOf (n : ℕ) (transBack transMid transFwd : List (Fin n → Fin n → Bool)) (u : ℤ) :
    Fin n → Fin n → Bool :=
  @Periodic.unrollOf _ (transEqInhabited n) transBack transMid transFwd u

/--
**Succession, over raw data, pruned by arrival renaming.**

Two conjuncts, and the second is what keeps the frame untouched by the redesign: a `trans`-step
from `i` at `u` may go only to an index `j` that names the state the step actually arrives in.
Without that conjunct `Step` and `trans` would be independent relations and every frame lemma
would need re-proving; with it, `trans` refines `share (u+1)` and the frame section is a
consequence rather than a rewrite.
-/
def transOf (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n))
    (transBack transMid transFwd : List (Fin n → Fin n → Bool)) (u : ℤ) (i j : Fin n) : Prop :=
  transMatOf n transBack transMid transFwd u i j = true ∧
    shareOf n repBack repMid repFwd (u + 1) i j

/-- A list lookup with a default either hits the list or returns the default. -/
private theorem getD_mem_or_eq' {α : Type*} (l : List α) (d : α) (k : ℕ) :
    l.getD k d ∈ l ∨ l.getD k d = d := by
  rcases lt_or_ge k l.length with hk | hk
  · left
    rw [(List.getElem_eq_getD (l := l) (i := k) (h := hk) d).symm]
    exact List.getElem_mem hk
  · right
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_none hk]
    rfl

/-- The three-segment decoding returns either a listed value or the out-of-range default. The
file-scope twin of `SharingSkeleton.unrollOf_mem_or_default`, available before the structure. -/
private theorem unrollOf_mem_or_default' {α : Type*} (inst : Inhabited α)
    (back mid fwd : List α) (t : ℤ) :
    @Periodic.unrollOf α inst back mid fwd t ∈ back ++ mid ++ fwd ∨
      @Periodic.unrollOf α inst back mid fwd t = @default α inst := by
  have hun : @Periodic.unrollOf α inst back mid fwd t
      = if t < 0 then back.getD ((t % (back.length : ℤ)).toNat) (@default α inst)
        else if t < (mid.length : ℤ) then mid.getD t.toNat (@default α inst)
        else fwd.getD (((t - (mid.length : ℤ)) % (fwd.length : ℤ)).toNat) (@default α inst) :=
    rfl
  rw [hun]
  split
  · rcases getD_mem_or_eq' back (@default α inst) ((t % (back.length : ℤ)).toNat) with h | h
    · exact Or.inl (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl h))))
    · exact Or.inr h
  · split
    · rcases getD_mem_or_eq' mid (@default α inst) t.toNat with h | h
      · exact Or.inl (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inr h))))
      · exact Or.inr h
    · rcases getD_mem_or_eq' fwd (@default α inst)
        (((t - (mid.length : ℤ)) % (fwd.length : ℤ)).toNat) with h | h
      · exact Or.inl (List.mem_append.mpr (Or.inr h))
      · exact Or.inr h

/-- A list lookup inside the list's range hits the list. -/
private theorem getD_mem_of_lt {α : Type*} (l : List α) (d : α) {k : ℕ} (hk : k < l.length) :
    l.getD k d ∈ l := by
  rw [(List.getElem_eq_getD (l := l) (i := k) (h := hk) d).symm]
  exact List.getElem_mem hk

/--
With both cycles non-empty the three-segment decoding never falls through to the default.

`unrollOf_mem_or_default` is the unconditional form and suffices wherever the default is as good
as a listed value (`rep`'s identity is idempotent, the identity succession matrix is reflexive).
It is not enough for a property the default lacks — being the *full* relation is one — which is
what this strengthening is for.
-/
private theorem unrollOf_mem {α : Type*} (inst : Inhabited α) (back mid fwd : List α)
    (hb : back ≠ []) (hf : fwd ≠ []) (t : ℤ) :
    @Periodic.unrollOf α inst back mid fwd t ∈ back ++ mid ++ fwd := by
  have hbl : 0 < back.length := List.length_pos_iff.mpr hb
  have hfl : 0 < fwd.length := List.length_pos_iff.mpr hf
  have hun : @Periodic.unrollOf α inst back mid fwd t
      = if t < 0 then back.getD ((t % (back.length : ℤ)).toNat) (@default α inst)
        else if t < (mid.length : ℤ) then mid.getD t.toNat (@default α inst)
        else fwd.getD (((t - (mid.length : ℤ)) % (fwd.length : ℤ)).toNat) (@default α inst) :=
    rfl
  rw [hun]
  split_ifs with h1 h2
  · refine List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl ?_)))
    refine getD_mem_of_lt _ _ ?_
    have h₁ : 0 ≤ t % (back.length : ℤ) :=
      Int.emod_nonneg _ (by exact_mod_cast hbl.ne')
    have h₂ : t % (back.length : ℤ) < (back.length : ℤ) :=
      Int.emod_lt_of_pos _ (by exact_mod_cast hbl)
    omega
  · exact List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inr
      (getD_mem_of_lt _ _ (by omega)))))
  · refine List.mem_append.mpr (Or.inr ?_)
    refine getD_mem_of_lt _ _ ?_
    have h₁ : 0 ≤ (t - (mid.length : ℤ)) % (fwd.length : ℤ) :=
      Int.emod_nonneg _ (by exact_mod_cast hfl.ne')
    have h₂ : (t - (mid.length : ℤ)) % (fwd.length : ℤ) < (fwd.length : ℤ) :=
      Int.emod_lt_of_pos _ (by exact_mod_cast hfl)
    omega

/-- The all-true succession matrix: free succession, the pre-redesign substrate. -/
def transFull (n : ℕ) : Fin n → Fin n → Bool := fun _ _ => true

/--
**A producer whose listed matrices are all full decodes to a full relation at every time.**

The hypothesis `liftable_of_full` asks for, discharged from the producer's own lists. Both
cycles have to be non-empty, because the out-of-range default is the *identity* relation rather
than the full one — the one place where the strengthened `unrollOf_mem` is needed.
-/
theorem transMatOf_full (n : ℕ) (transBack transMid transFwd : List (Fin n → Fin n → Bool))
    (hb : transBack ≠ []) (hf : transFwd ≠ [])
    (hall : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀ i j : Fin n, r i j = true)
    (u : ℤ) (i j : Fin n) : transMatOf n transBack transMid transFwd u i j = true :=
  hall _ (unrollOf_mem (transEqInhabited n) transBack transMid transFwd hb hf u) i j

/-- Every listed matrix being reflexive makes the decoding reflexive, default included. -/
theorem transMatOf_refl (n : ℕ) (transBack transMid transFwd : List (Fin n → Fin n → Bool))
    (hall : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀ i : Fin n, r i i = true)
    (u : ℤ) (i : Fin n) : transMatOf n transBack transMid transFwd u i i = true := by
  rcases unrollOf_mem_or_default' (transEqInhabited n) transBack transMid transFwd u with h | h
  · exact hall _ h i
  · rw [transMatOf, h]
    exact decide_eq_true rfl

/--
**Thread lifting: every state path of the frame is tracked by a succession path.**

The well-formedness obligation the fourth datum creates. While succession *was* `share (u+1)`,
"every world history is a thread's trace" came free: a `Step`-path's own intermediates already
formed a thread. Once succession is a separate, possibly sparser relation, that is no longer
automatic — a `Step`-path may cross between indices that no `trans`-step connects — and the
histories characterization has to be *demanded* rather than derived.

Demanding it label-free, as a skeleton field, is what keeps `total_eq_thread`,
`plusTruth_iff_mem` and `plusRefutes_of_certifies` stated exactly as they were.

The tracking is up to `share`, not on the nose: a lifted path need only name the same state as
the original at every time, which is all the histories characterization ever consumes.
-/
def LiftableRaw (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n))
    (transBack transMid transFwd : List (Fin n → Fin n → Bool)) : Prop :=
  ∀ σ : ℤ → Fin n, (∀ u : ℤ, stepOf n repBack repMid repFwd u (σ u) (σ (u + 1))) →
    ∃ τ : ℤ → Fin n,
      (∀ u : ℤ, transOf n repBack repMid repFwd transBack transMid transFwd u (τ u) (τ (u + 1))) ∧
      (∀ u : ℤ, shareOf n repBack repMid repFwd u (σ u) (τ u))

/--
**For the free-succession producer: a full `trans` is liftable.**

This is the gluing half of the pre-redesign `total_eq_thread`, lifted out to stand on raw paths.
A `Step`-path's own intermediates `b u` — the index it rides from `u` to `u + 1` — are
consecutive in `share (u+1)`, hence arrival-consistent, and a full succession matrix relates
everything, so they form the wanted path. Every producer that does not mean to constrain
succession discharges `lift` this way, and the tree it presents is exactly the pre-redesign one.
-/
theorem liftable_of_full (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n))
    (transBack transMid transFwd : List (Fin n → Fin n → Bool))
    (hfull : ∀ (u : ℤ) (i j : Fin n), transMatOf n transBack transMid transFwd u i j = true) :
    LiftableRaw n repBack repMid repFwd transBack transMid transFwd := by
  intro σ hstep
  choose b hb₁ hb₂ using hstep
  exact ⟨b, fun u => ⟨hfull _ _ _, shareOf_trans (hb₂ u) (hb₁ (u + 1))⟩, hb₁⟩

/-! ### The free-succession bundle

What a producer supplies when it does not mean to constrain succession at all: one full matrix
per representative map, so the decoded relation is full at every time and the presented tree is
exactly the pre-redesign one. Every producer landed before the redesign uses this, which is why
adding the fourth datum changes no theorem's content.
-/

/-- One full succession matrix per representative map, so the lengths agree by construction. -/
def transFullOf (n : ℕ) (l : List (Fin n → Fin n)) : List (Fin n → Fin n → Bool) :=
  l.map (fun _ => transFull n)

@[simp]
theorem transFullOf_length (n : ℕ) (l : List (Fin n → Fin n)) :
    (transFullOf n l).length = l.length := List.length_map _

theorem eq_transFull_of_mem_transFullOf {n : ℕ} {l : List (Fin n → Fin n)}
    {r : Fin n → Fin n → Bool} (h : r ∈ transFullOf n l) : r = transFull n := by
  obtain ⟨_, _, hr⟩ := List.mem_map.mp h
  exact hr.symm

theorem transFullOf_ne {n : ℕ} {l : List (Fin n → Fin n)} (hl : l ≠ []) :
    transFullOf n l ≠ [] := by
  intro h
  exact hl (List.eq_nil_of_length_eq_zero (by
    have := transFullOf_length n l
    rw [h, List.length_nil] at this
    omega))

theorem transFullOf_all (n : ℕ) (lb lm lf : List (Fin n → Fin n)) :
    ∀ r ∈ transFullOf n lb ++ transFullOf n lm ++ transFullOf n lf, ∀ i j : Fin n,
      r i j = true := by
  intro r hr i j
  have hfull : r = transFull n := by
    rcases List.mem_append.mp hr with h | h
    · rcases List.mem_append.mp h with h' | h' <;> exact eq_transFull_of_mem_transFullOf h'
    · exact eq_transFull_of_mem_transFullOf h
  rw [hfull]; rfl

theorem transFullOf_refl (n : ℕ) (lb lm lf : List (Fin n → Fin n)) :
    ∀ r ∈ transFullOf n lb ++ transFullOf n lm ++ transFullOf n lf, ∀ i : Fin n, r i i = true :=
  fun r hr i => transFullOf_all n lb lm lf r hr i i

/-- **The free-succession bundle is liftable**, so every pre-redesign producer discharges `lift`
with this one term. -/
theorem liftable_of_transFullOf (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n))
    (hb : repBack ≠ []) (hf : repFwd ≠ []) :
    LiftableRaw n repBack repMid repFwd
      (transFullOf n repBack) (transFullOf n repMid) (transFullOf n repFwd) :=
  liftable_of_full n repBack repMid repFwd _ _ _
    (transMatOf_full n _ _ _ (transFullOf_ne hb) (transFullOf_ne hf)
      (transFullOf_all n repBack repMid repFwd))

/--
**Splice closure**: any two indices naming the same state at `u` have a common index that copies
the first strictly before `u` and the second from `u` on.

The hop-free design's condition, kept here as the general sufficient condition for `lift`. It
says the presented index set is closed under cutting two histories at a shared state and
exchanging their halves, which is exactly what a state path does when it crosses between
indices.
-/
def SpliceClosedRaw (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n)) : Prop :=
  ∀ (u : ℤ) (i j : Fin n), shareOf n repBack repMid repFwd u i j →
    ∃ k : Fin n, (∀ v : ℤ, v < u → shareOf n repBack repMid repFwd v k i) ∧
      (∀ v : ℤ, u ≤ v → shareOf n repBack repMid repFwd v k j)

/-- Pigeonhole on a finite codomain: some value is taken arbitrarily late. -/
private theorem exists_cofinal_value {n : ℕ} (F : ℕ → Fin n) :
    ∃ k : Fin n, ∀ N : ℕ, ∃ M : ℕ, N ≤ M ∧ F M = k := by
  classical
  by_contra h
  push Not at h
  choose B hB using h
  set C : ℕ := (Finset.univ : Finset (Fin n)).sup B with hC
  have hle : B (F C) ≤ C := by
    rw [hC]; exact Finset.le_sup (Finset.mem_univ (F C))
  exact (hB (F C) C hle rfl).elim

/--
**For the hop-free producer: a splice-closed index set is liftable.**

Every state path is class-equal to a *constant* path. Splicing extends an index that tracks the
path on `[-N, N]` to one that tracks it on `[-(N+1), N+1]`, one end at a time and each extension
two splices: one to reach the new time, one to graft that onto the index already tracking the
interior. Pigeonhole on the finitely many indices then picks a single index that works for
arbitrarily large `N`, and hence for every time.

The succession relation only has to be reflexive, because the lifted path never moves.
-/
theorem liftable_of_spliceClosed (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n))
    (transBack transMid transFwd : List (Fin n → Fin n → Bool))
    (hsp : SpliceClosedRaw n repBack repMid repFwd)
    (hrefl : ∀ (u : ℤ) (i : Fin n), transMatOf n transBack transMid transFwd u i i = true) :
    LiftableRaw n repBack repMid repFwd transBack transMid transFwd := by
  classical
  intro σ hstep
  -- Replace the state path by its own intermediates, which are `share (u+1)`-consecutive.
  choose ρ hρ₀ hρ₁ using hstep
  have hρstep : ∀ u : ℤ, shareOf n repBack repMid repFwd (u + 1) (ρ u) (ρ (u + 1)) :=
    fun u => shareOf_trans (hρ₁ u) (hρ₀ (u + 1))
  -- One index tracks `ρ` on every bounded window.
  have hwin : ∀ N : ℕ, ∃ k : Fin n, ∀ v : ℤ, -(N : ℤ) ≤ v → v ≤ (N : ℤ) →
      shareOf n repBack repMid repFwd v k (ρ v) := by
    intro N
    induction N with
    | zero =>
      refine ⟨ρ 0, fun v h₁ h₂ => ?_⟩
      have : v = 0 := by omega
      subst this
      exact shareOf_refl _ _ _ _ _ _
    | succ N ih =>
      obtain ⟨k, hk⟩ := ih
      -- Extend one step to the right.
      obtain ⟨k₀, hk₀l, hk₀r⟩ := hsp ((N : ℤ) + 1) (ρ (N : ℤ)) (ρ ((N : ℤ) + 1)) (hρstep (N : ℤ))
      have hkN : shareOf n repBack repMid repFwd (N : ℤ) k (ρ (N : ℤ)) := hk _ (by omega) le_rfl
      have hk₀N : shareOf n repBack repMid repFwd (N : ℤ) k₀ (ρ (N : ℤ)) :=
        hk₀l _ (by omega)
      obtain ⟨k₁, hk₁l, hk₁r⟩ :=
        hsp (N : ℤ) k k₀ (shareOf_trans hkN (shareOf_symm hk₀N))
      have hk₁ : ∀ v : ℤ, -(N : ℤ) ≤ v → v ≤ (N : ℤ) + 1 →
          shareOf n repBack repMid repFwd v k₁ (ρ v) := by
        intro v h₁ h₂
        rcases lt_or_ge v (N : ℤ) with hv | hv
        · exact shareOf_trans (hk₁l _ hv) (hk _ h₁ (by omega))
        · rcases lt_or_ge v ((N : ℤ) + 1) with hv' | hv'
          · have : v = (N : ℤ) := by omega
            subst this
            exact shareOf_trans (hk₁r _ le_rfl) hk₀N
          · have : v = (N : ℤ) + 1 := by omega
            subst this
            exact shareOf_trans (hk₁r _ (by omega)) (hk₀r _ le_rfl)
      -- Extend one step to the left.
      have hleft : shareOf n repBack repMid repFwd (-(N : ℤ))
          (ρ (-(N : ℤ) - 1)) (ρ (-(N : ℤ))) := by
        have := hρstep (-(N : ℤ) - 1)
        rwa [show -(N : ℤ) - 1 + 1 = -(N : ℤ) by omega] at this
      have hk₁N : shareOf n repBack repMid repFwd (-(N : ℤ)) k₁ (ρ (-(N : ℤ))) :=
        hk₁ _ le_rfl (by omega)
      obtain ⟨k₂, hk₂l, hk₂r⟩ :=
        hsp (-(N : ℤ)) (ρ (-(N : ℤ) - 1)) k₁ (shareOf_trans hleft (shareOf_symm hk₁N))
      refine ⟨k₂, fun v h₁ h₂ => ?_⟩
      rw [Nat.cast_succ] at h₁ h₂
      rcases lt_or_ge v (-(N : ℤ)) with hv | hv
      · have : v = -(N : ℤ) - 1 := by omega
        subst this
        exact hk₂l _ (by omega)
      · exact shareOf_trans (hk₂r _ hv) (hk₁ _ hv (by omega))
  choose F hF using hwin
  obtain ⟨k, hk⟩ := exists_cofinal_value F
  refine ⟨fun _ => k, fun u => ⟨hrefl _ _, shareOf_refl _ _ _ _ _ _⟩, fun u => ?_⟩
  obtain ⟨M, hM₁, hM₂⟩ := hk u.natAbs
  have hbound : -(M : ℤ) ≤ u ∧ u ≤ (M : ℤ) := by
    have : (u.natAbs : ℤ) ≤ (M : ℤ) := by exact_mod_cast hM₁
    omega
  have := hF M u hbound.1 hbound.2
  rw [hM₂] at this
  exact shareOf_trans (hρ₀ u) (shareOf_symm this)

/--
**For the gate families: constant below a cut, one class above it, is liftable.**

The shape both gate families have, and the reason neither needs splice closure. Below the cut
every `share`-class is a singleton, so a `Step`-path cannot move; at or above it every two
indices share, so a constant path tracks anything. The constant path at the path's own value
just below the cut therefore tracks it everywhere, and again succession only has to be
reflexive.
-/
theorem liftable_of_constant_below (n : ℕ) (repBack repMid repFwd : List (Fin n → Fin n))
    (transBack transMid transFwd : List (Fin n → Fin n → Bool)) (c : ℤ)
    (hdisc : ∀ u : ℤ, u < c → ∀ i j : Fin n, shareOf n repBack repMid repFwd u i j → i = j)
    (htot : ∀ u : ℤ, c ≤ u → ∀ i j : Fin n, shareOf n repBack repMid repFwd u i j)
    (hrefl : ∀ (u : ℤ) (i : Fin n), transMatOf n transBack transMid transFwd u i i = true) :
    LiftableRaw n repBack repMid repFwd transBack transMid transFwd := by
  intro σ hstep
  have hconst : ∀ m : ℕ, σ (c - 1 - (m : ℤ)) = σ (c - 1) := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      obtain ⟨w, h₁, h₂⟩ := hstep (c - 1 - ((m + 1 : ℕ) : ℤ))
      rw [show c - 1 - ((m + 1 : ℕ) : ℤ) + 1 = c - 1 - (m : ℤ) by omega] at h₂
      have e₁ := hdisc _ (by omega) _ _ h₁
      have e₂ := hdisc _ (by omega) _ _ h₂
      rw [e₁, e₂, ih]
  refine ⟨fun _ => σ (c - 1), fun u => ⟨hrefl _ _, shareOf_refl _ _ _ _ _ _⟩, fun u => ?_⟩
  rcases lt_or_ge u c with hu | hu
  · have := hconst (c - 1 - u).toNat
    rw [show c - 1 - (((c - 1 - u).toNat : ℕ) : ℤ) = u by omega] at this
    rw [this]
    exact shareOf_refl _ _ _ _ _ _
  · exact htot u hu _ _

/--
**The label-free branching substrate.**

A count of indices together with three periodic segments of representative maps on them. This is
the whole datum the branching device stands on: the per-time equivalence `share`, the threads,
the quotient frame and its histories are all functions of it, and none of them inspects a label
or a formula.
-/
structure SharingSkeleton where
  /-- The number of indices. -/
  n : ℕ
  /-- There is at least one index. -/
  n_pos : 0 < n
  /-- Representative maps for the leftward cycle, indexed left-to-right in time. -/
  repBack : List (Fin n → Fin n)
  /-- Representative maps for the finite window `[0, |repMid|)`. -/
  repMid : List (Fin n → Fin n)
  /-- Representative maps for the rightward cycle, indexed left-to-right in time. -/
  repFwd : List (Fin n → Fin n)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  repBack_ne : repBack ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  repFwd_ne : repFwd ≠ []
  /-- Every listed map is idempotent, so it is a choice of class representatives. -/
  rep_idem : ∀ f ∈ repBack ++ repMid ++ repFwd, ∀ i, f (f i) = f i
  /-- Succession matrices for the leftward cycle, indexed left-to-right in time. -/
  transBack : List (Fin n → Fin n → Bool)
  /-- Succession matrices for the window `[0, |transMid|)`. -/
  transMid : List (Fin n → Fin n → Bool)
  /-- Succession matrices for the rightward cycle, indexed left-to-right in time. -/
  transFwd : List (Fin n → Fin n → Bool)
  /-- The succession cycles have the representatives' periods, so `share` and `trans` are
  periodic together and one window decides both. -/
  transBack_len : transBack.length = repBack.length
  /-- The succession window has the representative window's length. -/
  transMid_len : transMid.length = repMid.length
  /-- The forward succession cycle has the forward representative cycle's period. -/
  transFwd_len : transFwd.length = repFwd.length
  /-- Every listed matrix is reflexive: staying on one index is always a legitimate step. -/
  trans_refl : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀ i, r i i = true
  /-- **Thread lifting.** Every state path of the frame is tracked by a succession path. While
  succession *was* `share (u+1)` this came free; once succession is a separate relation it has
  to be demanded, and demanding it here — label-free, beside `rep_idem` — is what keeps
  `total_eq_thread` stated exactly as it was. -/
  lift : LiftableRaw n repBack repMid repFwd transBack transMid transFwd

namespace SharingSkeleton

/-- A list lookup with a default either hits the list or returns the default. -/
private theorem getD_mem_or_eq {α : Type*} (l : List α) (d : α) (k : ℕ) :
    l.getD k d ∈ l ∨ l.getD k d = d := by
  rcases lt_or_ge k l.length with hk | hk
  · left
    rw [(List.getElem_eq_getD (l := l) (i := k) (h := hk) d).symm]
    exact List.getElem_mem hk
  · right
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_none hk]
    rfl

/--
The three-segment decoding returns either a listed value or the out-of-range default.

Stated with the `Inhabited` argument **explicit**, because the decoding here runs at
`repIdInhabited`, which is deliberately not an instance: a `rw [Periodic.unrollOf]` would ask
instance synthesis for it and fail.
-/
private theorem unrollOf_mem_or_default {α : Type*} (inst : Inhabited α)
    (back mid fwd : List α) (t : ℤ) :
    @Periodic.unrollOf α inst back mid fwd t ∈ back ++ mid ++ fwd ∨
      @Periodic.unrollOf α inst back mid fwd t = @default α inst := by
  have hun : @Periodic.unrollOf α inst back mid fwd t
      = if t < 0 then back.getD ((t % (back.length : ℤ)).toNat) (@default α inst)
        else if t < (mid.length : ℤ) then mid.getD t.toNat (@default α inst)
        else fwd.getD (((t - (mid.length : ℤ)) % (fwd.length : ℤ)).toNat) (@default α inst) :=
    rfl
  rw [hun]
  split
  · rcases getD_mem_or_eq back (@default α inst) ((t % (back.length : ℤ)).toNat) with h | h
    · exact Or.inl (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl h))))
    · exact Or.inr h
  · split
    · rcases getD_mem_or_eq mid (@default α inst) t.toNat with h | h
      · exact Or.inl (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inr h))))
      · exact Or.inr h
    · rcases getD_mem_or_eq fwd (@default α inst)
        (((t - (mid.length : ℤ)) % (fwd.length : ℤ)).toNat) with h | h
      · exact Or.inl (List.mem_append.mpr (Or.inr h))
      · exact Or.inr h

/-- The decoded bi-infinite representative map, by the same three-segment scheme that decodes
the labels. Out of range it is the identity. -/
def rep (K : SharingSkeleton) (u : ℤ) : Fin K.n → Fin K.n :=
  @Periodic.unrollOf _ (repIdInhabited _) K.repBack K.repMid K.repFwd u

theorem rep_def (K : SharingSkeleton) (u : ℤ) :
    K.rep u = @Periodic.unrollOf _ (repIdInhabited _) K.repBack K.repMid K.repFwd u := rfl

/-- The backward representative-cycle length, as an integer. -/
abbrev nbr (K : SharingSkeleton) : ℤ := (K.repBack.length : ℤ)

/-- The representative-window length, as an integer. -/
abbrev nmr (K : SharingSkeleton) : ℤ := (K.repMid.length : ℤ)

/-- The forward representative-cycle length, as an integer. -/
abbrev nfr (K : SharingSkeleton) : ℤ := (K.repFwd.length : ℤ)

theorem nbr_pos (K : SharingSkeleton) : 0 < K.nbr :=
  Periodic.length_pos_int K.repBack_ne

theorem nfr_pos (K : SharingSkeleton) : 0 < K.nfr :=
  Periodic.length_pos_int K.repFwd_ne

theorem nmr_nonneg (K : SharingSkeleton) : 0 ≤ K.nmr := Int.natCast_nonneg _

/-- **Leftward periodicity.** Strictly left of the origin the representatives have period
`|repBack|`. Instantiated from `Periodic.unrollOf_sub_back_length`; no new arithmetic. -/
theorem rep_sub_back_length (K : SharingSkeleton) {u : ℤ} (hu : u < 0) :
    K.rep (u - K.nbr) = K.rep u :=
  @Periodic.unrollOf_sub_back_length _ (repIdInhabited _)
    K.repBack K.repMid K.repFwd K.repBack_ne u hu

/-- **Rightward periodicity.** At or past `|repMid|` the representatives have period `|repFwd|`.
Instantiated from `Periodic.unrollOf_add_fwd_length`; no new arithmetic. -/
theorem rep_add_fwd_length (K : SharingSkeleton) {u : ℤ} (hu : K.nmr ≤ u) :
    K.rep (u + K.nfr) = K.rep u :=
  @Periodic.unrollOf_add_fwd_length _ (repIdInhabited _)
    K.repBack K.repMid K.repFwd K.repFwd_ne u hu

/--
**Two indices name the same world state at time `u`.**

The kernel of `rep u`, so an equivalence relation with nothing to prove.
-/
def share (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) : Prop :=
  K.rep u i = K.rep u j

theorem share_def (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.share u i j ↔ K.rep u i = K.rep u j := Iff.rfl

@[refl]
theorem share_refl (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.share u i i := rfl

theorem share_symm {K : SharingSkeleton} {u : ℤ} {i j : Fin K.n}
    (h : K.share u i j) : K.share u j i := h.symm

theorem share_trans {K : SharingSkeleton} {u : ℤ} {i j k : Fin K.n}
    (hij : K.share u i j) (hjk : K.share u j k) : K.share u i k := hij.trans hjk

/-- Sharing is periodic leftward, with the representatives. -/
theorem share_sub_back_length (K : SharingSkeleton) {u : ℤ} (hu : u < 0) (i j : Fin K.n) :
    K.share (u - K.nbr) i j ↔ K.share u i j := by
  simp only [share, K.rep_sub_back_length hu]

/-- Sharing is periodic rightward, with the representatives. -/
theorem share_add_fwd_length (K : SharingSkeleton) {u : ℤ} (hu : K.nmr ≤ u) (i j : Fin K.n) :
    K.share (u + K.nfr) i j ↔ K.share u i j := by
  simp only [share, K.rep_add_fwd_length hu]

/-! ## The fourth periodic datum: succession, pruned by arrival renaming -/

/-- The decoded bi-infinite succession matrix, by the same three-segment scheme. Out of range it
is the identity relation. -/
def transRaw (K : SharingSkeleton) (u : ℤ) : Fin K.n → Fin K.n → Bool :=
  transMatOf K.n K.transBack K.transMid K.transFwd u

theorem transRaw_def (K : SharingSkeleton) (u : ℤ) :
    K.transRaw u
      = @Periodic.unrollOf _ (transEqInhabited _) K.transBack K.transMid K.transFwd u := rfl

/-- The leftward succession cycle is non-empty, because it has the leftward representative
cycle's length. -/
theorem transBack_ne (K : SharingSkeleton) : K.transBack ≠ [] := by
  intro h
  exact K.repBack_ne (List.eq_nil_of_length_eq_zero (by
    rw [← K.transBack_len, h, List.length_nil]))

/-- The rightward succession cycle is non-empty, for the same reason. -/
theorem transFwd_ne (K : SharingSkeleton) : K.transFwd ≠ [] := by
  intro h
  exact K.repFwd_ne (List.eq_nil_of_length_eq_zero (by
    rw [← K.transFwd_len, h, List.length_nil]))

/-- **Leftward periodicity of succession**, at the representatives' own period. The length
equalities are what let this be stated with `nbr` rather than a second set of moduli. -/
theorem transRaw_sub_back_length (K : SharingSkeleton) {u : ℤ} (hu : u < 0) :
    K.transRaw (u - K.nbr) = K.transRaw u := by
  have h := @Periodic.unrollOf_sub_back_length _ (transEqInhabited _)
    K.transBack K.transMid K.transFwd K.transBack_ne u hu
  rw [transRaw_def, transRaw_def, show K.nbr = (K.transBack.length : ℤ) by
    rw [K.transBack_len]]
  exact h

/-- **Rightward periodicity of succession**, at the representatives' own period. -/
theorem transRaw_add_fwd_length (K : SharingSkeleton) {u : ℤ} (hu : K.nmr ≤ u) :
    K.transRaw (u + K.nfr) = K.transRaw u := by
  have hmid : (K.transMid.length : ℤ) = K.nmr := by rw [K.transMid_len]
  have h := @Periodic.unrollOf_add_fwd_length _ (transEqInhabited _)
    K.transBack K.transMid K.transFwd K.transFwd_ne u (by rw [hmid]; exact hu)
  rw [transRaw_def, transRaw_def, show K.nfr = (K.transFwd.length : ℤ) by
    rw [K.transFwd_len]]
  exact h

/-- **The decoded succession relation is reflexive**, listed matrices and default alike. -/
theorem transRaw_refl (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.transRaw u i i = true :=
  transMatOf_refl K.n K.transBack K.transMid K.transFwd K.trans_refl u i

/--
**Succession, arrival-pruned.**

The redesign's whole content in one definition. `transRaw` is free data; the second conjunct
prunes it so a step may go only to an index naming the state the step arrives in. That is what
keeps `Step` and every frame lemma byte-identical: `trans u` refines `share (u+1)`, which is
exactly what `Thread.step` used to assert outright.
-/
def trans (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) : Prop :=
  K.transRaw u i j = true ∧ K.share (u + 1) i j

theorem trans_def (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.trans u i j ↔ (K.transRaw u i j = true ∧ K.share (u + 1) i j) := Iff.rfl

/-- **Succession is reflexive**, from the field and reflexivity of `share`. -/
@[refl]
theorem trans_refl' (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.trans u i i :=
  ⟨K.transRaw_refl u i, K.share_refl (u + 1) i⟩

/-- **Arrival pruning, projected.** A succession step names the state it arrives in. This is the
half of `trans` every pre-redesign consumer of `Thread.step` actually used. -/
theorem share_succ_of_trans {K : SharingSkeleton} {u : ℤ} {i j : Fin K.n}
    (h : K.trans u i j) : K.share (u + 1) i j := h.2

instance instDecidableTrans (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    Decidable (K.trans u i j) := by
  unfold trans share
  infer_instance

/-! ### Bridges to the raw layer

Each is `rfl`: the structure's projections *are* the raw functions at its own fields. They are
named so that `K.lift`, whose statement is necessarily raw, applies to `K.Step`-paths without a
rewrite at every use site.
-/

theorem rep_eq_repOf (K : SharingSkeleton) (u : ℤ) :
    K.rep u = repOf K.n K.repBack K.repMid K.repFwd u := rfl

theorem share_iff_shareOf (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.share u i j ↔ shareOf K.n K.repBack K.repMid K.repFwd u i j := Iff.rfl

theorem transRaw_eq_transMatOf (K : SharingSkeleton) (u : ℤ) :
    K.transRaw u = transMatOf K.n K.transBack K.transMid K.transFwd u := rfl

theorem trans_iff_transOf (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.trans u i j ↔
      transOf K.n K.repBack K.repMid K.repFwd K.transBack K.transMid K.transFwd u i j := Iff.rfl

/-- The decoded map is either one of the listed maps or the identity. -/
theorem rep_mem_or_id (K : SharingSkeleton) (u : ℤ) :
    K.rep u ∈ K.repBack ++ K.repMid ++ K.repFwd ∨ K.rep u = id :=
  unrollOf_mem_or_default (repIdInhabited _) K.repBack K.repMid K.repFwd u

/-- **The decoded map is idempotent**, so `rep u` is a genuine choice of representatives. -/
theorem rep_idem' (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) :
    K.rep u (K.rep u i) = K.rep u i := by
  rcases K.rep_mem_or_id u with h | h
  · exact K.rep_idem _ h i
  · rw [h]; rfl

/-- Every index shares its own representative. -/
theorem share_rep (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.share u i (K.rep u i) :=
  (K.rep_idem' u i).symm

/-- Sharing is exactly having the same representative. -/
theorem share_iff_rep_eq (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.share u i j ↔ K.rep u i = K.rep u j := Iff.rfl

instance decidableShare (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    Decidable (K.share u i j) :=
  inferInstanceAs (Decidable (K.rep u i = K.rep u j))

/-! ## Threads: the branching analogue of a lasso orbit

On the deterministic device a world history *is* a lasso, shifted. Once two indices may name the
same state at a time, a history can cross from one to the other there, and the object that
replaces "a lasso" is a **thread**: a bi-infinite choice of index that only ever changes across a
shared state.

Three relations, and why all three are needed:

* `Thread` — the bi-infinite object. Its step field is the *tight* one,
  `share (u+1) (idx u) (idx (u+1))`: the thread stays on index `idx u` from `u` to `u + 1` and
  then re-names the state it lands in. This is not a loss of generality, because a history's
  index at `u` may be chosen *knowing* the step it is about to take.
* `Step` — the *class-level* one-step relation, `∃ i', share u i i' ∧ share (u+1) i' j`. This is
  the relation the frame's task relation is built from, and the existential is exactly the
  branching: the state `⟦(i,u)⟧` has one successor for each index passing through it, not one
  successor full stop.
* `ReachN` — `n` iterated `Step`s, with `ReachN 0` the sharing relation itself. This is the
  finite-duration reachability the frame's `PosRel` quantifies over.

`Step` is invariant under `share u` on the left and `share (u+1)` on the right, and `ReachN n`
under `share u` and `share (u + n)`; those four congruences are what let the whole development
descend to the quotient carrier, with no compatibility field added to the structure.

**What is deliberately absent: a thread time-shift.** A thread cannot be time-shifted. `share` is
decoded from three *periodic segments* indexed by absolute time, so `share u` and `share (u + d)`
are different relations for a general `d`, and `fun u => θ.idx (u + d)` fails the step field.
Time offsets therefore live in the *history's* parametrization — `total_eq_thread` carries an
explicit `s : ℤ` and reads `θ.idx (s + t)` at time `s + t` — never in the thread.
-/

/-- Regrouping a successor time offset, used wherever an induction on the step count meets the
integer time coordinate. -/
private theorem int_succ_shift (u : ℤ) (m : ℕ) :
    u + ((m + 1 : ℕ) : ℤ) = u + 1 + (m : ℤ) := by
  omega

/-- Erasing a zero step count from a time offset. -/
private theorem int_zero_shift (u : ℤ) : u + ((0 : ℕ) : ℤ) = u := by
  omega

/--
**A bi-infinite choice of index, stepping only across shared states.**

The step field is the tight form: the thread rides index `idx u` from `u` to `u + 1`, and the
state it arrives at, `⟦(idx u, u+1)⟧`, is the state `⟦(idx (u+1), u+1)⟧` it is recorded as
holding. Threads replace lasso orbits as the objects the frame's histories are traces of.
-/
structure Thread (K : SharingSkeleton) where
  /-- The index held at each time. -/
  idx : ℤ → Fin K.n
  /-- Consecutive indices stand in the succession relation. Arrival pruning makes this imply
  that they name the same world state at the later time, which is what the field used to say
  outright; what it no longer implies is that *every* such pair is a step. -/
  step : ∀ u : ℤ, K.trans u (idx u) (idx (u + 1))

namespace Thread

variable {K : SharingSkeleton}

/-- Threads are determined by their index function. -/
@[ext]
theorem ext {θ η : K.Thread} (h : ∀ u, θ.idx u = η.idx u) : θ = η := by
  cases θ with
  | mk i₁ s₁ =>
    cases η with
    | mk i₂ s₂ =>
      have hi : i₁ = i₂ := funext h
      subst hi
      rfl

end Thread

/-- The constant thread at index `i`: staying on one index forever is always legitimate,
because `trans_refl` makes every listed succession matrix reflexive. -/
def Thread.const (K : SharingSkeleton) (i : Fin K.n) : K.Thread where
  idx := fun _ => i
  step := fun u => K.trans_refl' u i

instance instNonemptyThread (K : SharingSkeleton) : Nonempty K.Thread :=
  ⟨Thread.const K ⟨0, K.n_pos⟩⟩

@[simp]
theorem Thread.const_idx (K : SharingSkeleton) (i : Fin K.n) (u : ℤ) :
    (Thread.const K i).idx u = i := rfl

/--
**The class-level one-step relation.**

From index `i` at time `u`, a history may continue along *any* index `i'` naming the same state
at `u`, and then re-name the state it lands in at `u + 1`. The existential over `i'` is the
branching: on the deterministic device it collapses to `i' = i` and `Step u i j ↔ j = i`.
-/
def Step (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) : Prop :=
  ∃ i', K.share u i i' ∧ K.share (u + 1) i' j

theorem step_iff_stepOf (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.Step u i j ↔ stepOf K.n K.repBack K.repMid K.repFwd u i j := Iff.rfl

theorem step_of_share_succ {K : SharingSkeleton} {u : ℤ} {i j : Fin K.n}
    (h : K.share (u + 1) i j) : K.Step u i j :=
  ⟨i, K.share_refl u i, h⟩

theorem step_refl (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.Step u i i :=
  step_of_share_succ (K.share_refl (u + 1) i)

/-- `Step` only sees the `share u`-class of its source. -/
theorem step_congr_left {K : SharingSkeleton} {u : ℤ} {i i' j : Fin K.n}
    (h : K.share u i' i) (hs : K.Step u i j) : K.Step u i' j := by
  obtain ⟨k, hk, hkj⟩ := hs
  exact ⟨k, SharingSkeleton.share_trans h hk, hkj⟩

/-- `Step` only sees the `share (u+1)`-class of its target. -/
theorem step_congr_right {K : SharingSkeleton} {u : ℤ} {i j j' : Fin K.n}
    (hs : K.Step u i j) (h : K.share (u + 1) j j') : K.Step u i j' := by
  obtain ⟨k, hk, hkj⟩ := hs
  exact ⟨k, hk, SharingSkeleton.share_trans hkj h⟩

instance decidableStep (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    Decidable (K.Step u i j) :=
  inferInstanceAs (Decidable (∃ i', K.share u i i' ∧ K.share (u + 1) i' j))

/--
**`n`-step reachability.** At `n = 0` it is the sharing relation — same time, same state — and
each successor step is one `Step`.
-/
def ReachN (K : SharingSkeleton) : ℕ → ℤ → Fin K.n → Fin K.n → Prop
  | 0, u, i, j => K.share u i j
  | (n + 1), u, i, j => ∃ k, K.Step u i k ∧ ReachN K n (u + 1) k j

@[simp]
theorem reachN_zero (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.ReachN 0 u i j ↔ K.share u i j := Iff.rfl

theorem reachN_succ (K : SharingSkeleton) (n : ℕ) (u : ℤ) (i j : Fin K.n) :
    K.ReachN (n + 1) u i j ↔ ∃ k, K.Step u i k ∧ K.ReachN n (u + 1) k j := Iff.rfl

/-- Reachability only sees the `share u`-class of its source. -/
theorem reachN_congr_left {K : SharingSkeleton} {n : ℕ} {u : ℤ} {i i' j : Fin K.n}
    (h : K.share u i' i) (hr : K.ReachN n u i j) : K.ReachN n u i' j := by
  cases n with
  | zero => exact SharingSkeleton.share_trans h hr
  | succ m =>
    obtain ⟨k, hk, hrest⟩ := hr
    exact ⟨k, step_congr_left h hk, hrest⟩

/-- Reachability only sees the `share (u + n)`-class of its target. -/
theorem reachN_congr_right {K : SharingSkeleton} {n : ℕ} {u : ℤ} {i j j' : Fin K.n}
    (hr : K.ReachN n u i j) (h : K.share (u + (n : ℤ)) j j') : K.ReachN n u i j' := by
  induction n generalizing u i with
  | zero =>
    rw [int_zero_shift] at h
    exact SharingSkeleton.share_trans hr h
  | succ m ih =>
    obtain ⟨k, hk, hrest⟩ := hr
    refine ⟨k, hk, ih hrest ?_⟩
    rw [← int_succ_shift]
    exact h

/-- Staying on one index is reachability of every length. -/
theorem reachN_const (K : SharingSkeleton) (n : ℕ) (u : ℤ) (i : Fin K.n) : K.ReachN n u i i := by
  induction n generalizing u with
  | zero => exact K.share_refl u i
  | succ m ih => exact ⟨i, step_refl K u i, ih (u + 1)⟩

/-- One step of reachability is one `Step`. -/
theorem reachN_one (K : SharingSkeleton) (u : ℤ) (i j : Fin K.n) :
    K.ReachN 1 u i j ↔ K.Step u i j := by
  constructor
  · rintro ⟨k, hk, hr⟩
    exact step_congr_right hk hr
  · intro h
    exact ⟨j, h, K.share_refl (u + 1) j⟩

/--
**Concatenation and splitting.** Reachability of length `m + n` factors through an intermediate
state at time `u + m`, in both directions. This is the whole content of the *Compositionality*
discharge for the branching frame.
-/
theorem reachN_add (K : SharingSkeleton) (m n : ℕ) (u : ℤ) (i j : Fin K.n) :
    K.ReachN (m + n) u i j ↔ ∃ k, K.ReachN m u i k ∧ K.ReachN n (u + (m : ℤ)) k j := by
  induction m generalizing u i with
  | zero =>
    rw [Nat.zero_add]
    constructor
    · intro h
      refine ⟨i, K.share_refl u i, ?_⟩
      rw [int_zero_shift]
      exact h
    · rintro ⟨k, hik, hr⟩
      rw [int_zero_shift] at hr
      exact reachN_congr_left hik hr
  | succ m ih =>
    have hidx : m + 1 + n = (m + n) + 1 := by omega
    rw [hidx, reachN_succ]
    constructor
    · rintro ⟨k, hk, hr⟩
      obtain ⟨k', hk', hr'⟩ := (ih (u + 1) k).mp hr
      refine ⟨k', ?_, ?_⟩
      · exact ⟨k, hk, hk'⟩
      · rw [int_succ_shift]
        exact hr'
    · rintro ⟨k', hseg, hr'⟩
      rw [reachN_succ] at hseg
      obtain ⟨k, hk, hk'⟩ := hseg
      refine ⟨k, hk, (ih (u + 1) k).mpr ⟨k', hk', ?_⟩⟩
      rw [← int_succ_shift]
      exact hr'

instance decidableReachN (K : SharingSkeleton) :
    ∀ (n : ℕ) (u : ℤ) (i j : Fin K.n), Decidable (K.ReachN n u i j)
  | 0, u, i, j => inferInstanceAs (Decidable (K.share u i j))
  | (n + 1), u, i, j =>
      letI : ∀ (v : ℤ) (a b : Fin K.n), Decidable (K.ReachN n v a b) :=
        fun v a b => decidableReachN K n v a b
      inferInstanceAs (Decidable (∃ k, K.Step u i k ∧ K.ReachN n (u + 1) k j))

/--
**A thread's step, read as the arrival-time sharing fact.**

The single point through which every consumer reads a thread's step. While `Thread.step` *is*
this fact the two are interchangeable; once the step field becomes succession, this is its
arrival-pruning projection and every consumer below keeps working unedited. Introducing it
before the substrate switch is what makes that switch touch definition sites only.
-/
theorem thread_share_succ {K : SharingSkeleton} (θ : K.Thread) (u : ℤ) :
    K.share (u + 1) (θ.idx u) (θ.idx (u + 1)) := (θ.step u).2

namespace Thread

variable {K : SharingSkeleton}

/-- A thread's one-step move is a `Step` of the class-level relation. -/
theorem step' (θ : K.Thread) (u : ℤ) : K.Step u (θ.idx u) (θ.idx (u + 1)) :=
  step_of_share_succ (thread_share_succ θ u)

/-- **A thread realizes reachability between its own positions.** -/
theorem reachN (θ : K.Thread) (n : ℕ) (u : ℤ) :
    K.ReachN n u (θ.idx u) (θ.idx (u + (n : ℤ))) := by
  induction n generalizing u with
  | zero => simpa using K.share_refl u (θ.idx u)
  | succ m ih =>
    refine ⟨θ.idx (u + 1), θ.step' u, ?_⟩
    rw [int_succ_shift]
    exact ih (u + 1)

end Thread

/-! ## The quotient frame

The deterministic device presents its model through `ShiftSet`, whose task relation is the
functional shift relation. That route is closed here by construction: a branching task relation
is not a function, so this section builds a `FrameOver intOrder` **directly**, and
`Semantics/ShiftSet.lean` is neither used nor modified.

**The carrier is a quotient, and only within a single time.** World states are `share`-classes of
index/time pairs: `(i, u)` and `(j, u)` name the same state exactly when `share u i j`. Pairs at
*different* times are never identified, so time is a well-defined function on states (`time`) and
the frame is still a "flow" whose duration is recoverable from its endpoints. That per-time
restriction is what makes the quotient lift of the task relation go through with no extra
compatibility field: the four congruences `reachN_congr_left`, `reachN_congr_right`,
`step_congr_left` and `step_congr_right` are all the compatibility the lift needs, and each is a
consequence of `share` being an equivalence.

**One two-sided relation, not two.** `FrameOver` takes its primitive on the positive cone and
extends it by the reflection convention. Rather than discharging each constraint against that
extension, this section defines the two-sided relation `RelZ` once, proves the reflection law for
it, and then cites `TaskFrame.compositional_reflect_of_reflective` and its three siblings — the
same route `ShiftSet.fibre_isRegular` takes. `RelZ` factors through `Conn`, a *duration-free*
connectivity predicate on raw pairs: forward reachability when the source is earlier, backward
when it is later. Because `Conn` mentions no duration, the reflection law is `conn_symm` plus an
`omega` on the time coordinate, rather than a case split on the sign of the duration inside every
proof.
-/
section Frame

open FormalSystem.Semantics

/--
**The per-time sharing equivalence** on index/time pairs: `(i, u)` and `(j, v)` name the same
world state exactly when `u = v` and `share u i j`.

Pairs at different times are never identified, which is what keeps `time` well defined on the
quotient and the frame a flow.
-/
def shareSetoid (K : SharingSkeleton) : Setoid (Fin K.n × ℤ) where
  r p q := p.2 = q.2 ∧ K.share p.2 p.1 q.1
  iseqv :=
    { refl := fun p => ⟨rfl, K.share_refl p.2 p.1⟩
      symm := by
        rintro p q ⟨ht, hs⟩
        exact ⟨ht.symm, by rw [← ht]; exact K.share_symm hs⟩
      trans := by
        rintro p q r ⟨ht₁, hs₁⟩ ⟨ht₂, hs₂⟩
        refine ⟨ht₁.trans ht₂, SharingSkeleton.share_trans hs₁ ?_⟩
        rw [ht₁]
        exact hs₂ }

/-- The frame's carrier: `share`-classes of index/time pairs. -/
abbrev WorldState (K : SharingSkeleton) : Type := Quotient K.shareSetoid

/-- The class of an index at a time. -/
def cls (K : SharingSkeleton) (i : Fin K.n) (u : ℤ) : K.WorldState :=
  Quotient.mk K.shareSetoid (i, u)

theorem cls_eq {K : SharingSkeleton} {i j : Fin K.n} {u v : ℤ}
    (hu : u = v) (hs : K.share u i j) : K.cls i u = K.cls j v :=
  Quotient.sound (⟨hu, hs⟩ : K.shareSetoid.r (i, u) (j, v))

theorem share_of_cls_eq {K : SharingSkeleton} {i j : Fin K.n} {u v : ℤ}
    (h : K.cls i u = K.cls j v) : u = v ∧ K.share u i j :=
  Quotient.exact h

/-- Time is well defined on states, because the setoid never crosses a time. -/
def time (K : SharingSkeleton) (C : K.WorldState) : ℤ :=
  Quotient.liftOn C (fun p => p.2) (fun _ _ h => h.1)

@[simp]
theorem time_cls (K : SharingSkeleton) (i : Fin K.n) (u : ℤ) : K.time (K.cls i u) = u := rfl

/--
**Duration-free connectivity between raw positions.** Forward reachability when the source is
no later than the target, backward reachability otherwise. Symmetric by `conn_symm`, which is
what makes the reflection law cheap.
-/
def Conn (K : SharingSkeleton) (p q : Fin K.n × ℤ) : Prop :=
  if p.2 ≤ q.2 then K.ReachN (q.2 - p.2).toNat p.2 p.1 q.1
  else K.ReachN (p.2 - q.2).toNat q.2 q.1 p.1

theorem conn_of_reachN {K : SharingSkeleton} {n : ℕ} {u : ℤ} {i j : Fin K.n}
    (h : K.ReachN n u i j) : K.Conn (i, u) (j, u + (n : ℤ)) := by
  change (if u ≤ u + (n : ℤ) then K.ReachN ((u + (n : ℤ)) - u).toNat u i j
        else K.ReachN (u - (u + (n : ℤ))).toNat (u + (n : ℤ)) j i)
  rw [if_pos (by omega : u ≤ u + (n : ℤ)),
    show ((u + (n : ℤ)) - u).toNat = n from by omega]
  exact h

theorem conn_symm {K : SharingSkeleton} {p q : Fin K.n × ℤ} (h : K.Conn p q) : K.Conn q p := by
  unfold Conn at h ⊢
  rcases lt_trichotomy p.2 q.2 with hlt | heq | hgt
  · rw [if_pos hlt.le] at h
    rw [if_neg (by omega)]
    exact h
  · rw [if_pos heq.le] at h
    rw [if_pos heq.ge]
    have h0 : (q.2 - p.2).toNat = 0 := by omega
    have h0' : (p.2 - q.2).toNat = 0 := by omega
    rw [h0] at h
    rw [h0', reachN_zero]
    rw [reachN_zero] at h
    rw [← heq]
    exact K.share_symm h
  · rw [if_neg (by omega)] at h
    rw [if_pos hgt.le]
    exact h

theorem conn_congr_left {K : SharingSkeleton} {p p' q : Fin K.n × ℤ}
    (hp : p.2 = p'.2) (hs : K.share p.2 p.1 p'.1) (h : K.Conn p q) : K.Conn p' q := by
  unfold Conn at h ⊢
  rw [← hp]
  split at h
  · rename_i hle
    rw [if_pos hle]
    exact reachN_congr_left (K.share_symm hs) h
  · rename_i hle
    rw [if_neg hle]
    refine reachN_congr_right h ?_
    have hn : q.2 + (((p.2 - q.2).toNat : ℕ) : ℤ) = p.2 := by omega
    rw [hn]
    exact hs

theorem conn_congr_right {K : SharingSkeleton} {p q q' : Fin K.n × ℤ}
    (hq : q.2 = q'.2) (hs : K.share q.2 q.1 q'.1) (h : K.Conn p q) : K.Conn p q' :=
  conn_symm (conn_congr_left hq hs (conn_symm h))

/--
**The two-sided task relation on states.** A duration `d` takes `C` to `C'` when the times
differ by `d` and the two raw positions are connected.
-/
def RelZ (K : SharingSkeleton) (C : K.WorldState) (d : ℤ) (C' : K.WorldState) : Prop :=
  Quotient.liftOn₂ C C' (fun p q => q.2 = p.2 + d ∧ K.Conn p q)
    (by
      intro p₁ q₁ p₂ q₂ hp hq
      apply propext
      obtain ⟨hpt, hps⟩ := hp
      obtain ⟨hqt, hqs⟩ := hq
      constructor
      · rintro ⟨ht, hc⟩
        exact ⟨by omega, conn_congr_right hqt hqs (conn_congr_left hpt hps hc)⟩
      · rintro ⟨ht, hc⟩
        refine ⟨by omega, ?_⟩
        refine conn_congr_right hqt.symm ?_ (conn_congr_left hpt.symm ?_ hc)
        · rw [← hqt]; exact K.share_symm hqs
        · rw [← hpt]; exact K.share_symm hps)

@[simp]
theorem relZ_cls (K : SharingSkeleton) (i j : Fin K.n) (u v d : ℤ) :
    K.RelZ (K.cls i u) d (K.cls j v) ↔ (v = u + d ∧ K.Conn (i, u) (j, v)) := Iff.rfl

/-- **The reflection law.** Reversing a duration reverses the relation; `Conn` is duration-free
and symmetric, so only the time coordinate has to move. -/
theorem relZ_reflection (K : SharingSkeleton) :
    ∀ (C : K.WorldState) (d : ℤ) (C' : K.WorldState), K.RelZ C d C' ↔ K.RelZ C' (-d) C := by
  intro C d C'
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C' using Quotient.inductionOn with
    | _ q =>
      constructor
      · rintro ⟨ht, hc⟩
        exact ⟨by omega, conn_symm hc⟩
      · rintro ⟨ht, hc⟩
        exact ⟨by omega, conn_symm hc⟩

/-- Every state is the class of some index at its own time. -/
theorem exists_cls (K : SharingSkeleton) (C : K.WorldState) :
    ∃ i : Fin K.n, C = K.cls i (K.time C) := by
  induction C using Quotient.inductionOn with
  | _ p => exact ⟨p.1, by cases p; rfl⟩

/-- **Compositionality** for the branching relation, from `reachN_add`. -/
theorem relZ_comp (K : SharingSkeleton) : TaskFrame.Compositional K.RelZ := by
  intro C C'' x y hx hy
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C'' using Quotient.inductionOn with
    | _ r =>
      constructor
      · rintro ⟨ht, hc⟩
        have hle : p.2 ≤ r.2 := by omega
        unfold Conn at hc
        rw [if_pos hle] at hc
        have hsplit : (r.2 - p.2).toNat = x.toNat + y.toNat := by omega
        rw [hsplit] at hc
        obtain ⟨k, h₁, h₂⟩ := (K.reachN_add x.toNat y.toNat p.2 p.1 r.1).mp hc
        refine ⟨K.cls k (p.2 + x), ⟨by omega, ?_⟩, ⟨by omega, ?_⟩⟩
        · have := conn_of_reachN h₁
          have hx' : p.2 + ((x.toNat : ℕ) : ℤ) = p.2 + x := by omega
          rwa [hx'] at this
        · have := conn_of_reachN (u := p.2 + ((x.toNat : ℕ) : ℤ)) h₂
          have hx' : p.2 + ((x.toNat : ℕ) : ℤ) = p.2 + x := by omega
          rw [hx'] at this
          have hy' : p.2 + x + ((y.toNat : ℕ) : ℤ) = r.2 := by omega
          rwa [hy'] at this
      · rintro ⟨C', h₁, h₂⟩
        revert h₁ h₂
        induction C' using Quotient.inductionOn with
        | _ q =>
          rintro ⟨ht₁, hc₁⟩ ⟨ht₂, hc₂⟩
          refine ⟨by omega, ?_⟩
          unfold Conn at hc₁ hc₂ ⊢
          rw [if_pos (by omega : p.2 ≤ q.2)] at hc₁
          rw [if_pos (by omega : q.2 ≤ r.2)] at hc₂
          rw [if_pos (by omega : p.2 ≤ r.2)]
          have hsplit : (r.2 - p.2).toNat = (q.2 - p.2).toNat + (r.2 - q.2).toNat := by omega
          rw [hsplit]
          refine (K.reachN_add _ _ p.2 p.1 r.1).mpr ⟨q.1, hc₁, ?_⟩
          have hq' : p.2 + (((q.2 - p.2).toNat : ℕ) : ℤ) = q.2 := by omega
          rw [hq']
          exact hc₂

/-- **Seriality** for the branching relation: staying on one index is always available in both
directions. -/
theorem relZ_serial (K : SharingSkeleton) : TaskFrame.Serial K.RelZ := by
  intro C x hx
  induction C using Quotient.inductionOn with
  | _ p =>
    obtain ⟨i, u⟩ := p
    refine ⟨⟨K.cls i (u + x), ?_⟩, ⟨K.cls i (u - x), ?_⟩⟩
    · refine ⟨rfl, ?_⟩
      have h := conn_of_reachN (K.reachN_const x.toNat u i)
      rwa [show u + ((x.toNat : ℕ) : ℤ) = u + x from by omega] at h
    · refine ⟨show (u : ℤ) = u - x + x from by omega, ?_⟩
      have h := conn_of_reachN (K.reachN_const x.toNat (u - x) i)
      rwa [show u - x + ((x.toNat : ℕ) : ℤ) = u from by omega] at h

/--
**The branching frame.** Built as a literal `FrameOver intOrder`; nothing here routes through
`ShiftSet`, whose task relation is functional by construction.
-/
def frame (K : SharingSkeleton) : FrameOver intOrder where
  WorldState := K.WorldState
  worldNonempty := ⟨K.cls ⟨0, K.n_pos⟩ 0⟩
  PosRel := fun C x C' => K.RelZ C (x : ↑intOrder) C'

/-- **The frame's task relation is the two-sided relation.** The frame's primitive is `RelZ`
restricted to the positive cone, and `RelZ` satisfies the reflection law, so the reflection
convention recovers it on the nose. -/
@[simp]
theorem frame_taskRel (K : SharingSkeleton) (C : K.WorldState) (d : ℤ) (C' : K.WorldState) :
    K.frame.TaskRel C d C' ↔ K.RelZ C d C' :=
  TaskFrame.reflect_restrict_iff (R := K.RelZ) K.relZ_reflection

/-- *Compositionality* at the frame's own task relation. -/
theorem frame_comp (K : SharingSkeleton) : TaskFrame.Compositional K.frame.TaskRel :=
  TaskFrame.compositional_reflect_of_reflective K.relZ_reflection K.relZ_comp

/-- *Seriality* at the frame's own task relation. -/
theorem frame_serial (K : SharingSkeleton) : TaskFrame.Serial K.frame.TaskRel :=
  TaskFrame.serial_reflect_of_reflective K.relZ_reflection K.relZ_serial

/-! ### The four `def:frame` constraints, and the ℤ-time instances

Limit and Saturation need **no new frame-axiom argument**: the first is
`TaskFrame.limit_of_succOrder` at the zero-duration law, which asks only that a zero-duration
transition is the identity — never that the relation is functional; the second is
`TaskFrame.saturation_of_fib_finite`, whose docstring names exactly this case, an infinite
carrier with finite fibres. Determinism is nowhere used.
-/

/-- **The zero-duration law.** A zero-duration transition is the identity of states — the whole
hypothesis `TaskFrame.limit_of_succOrder` needs. -/
theorem relZ_zero (K : SharingSkeleton) : ∀ C C' : K.WorldState, K.RelZ C 0 C' → C' = C := by
  intro C C'
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C' using Quotient.inductionOn with
    | _ q =>
      rintro ⟨ht, hc⟩
      have heq : p.2 = q.2 := by omega
      unfold Conn at hc
      rw [if_pos (le_of_eq heq)] at hc
      rw [show (q.2 - p.2).toNat = 0 from by omega, reachN_zero] at hc
      refine Quotient.sound (⟨heq.symm, ?_⟩ : K.shareSetoid.r q p)
      rw [← heq]
      exact K.share_symm hc

/-- The time coordinate advances by the duration. -/
theorem time_of_relZ (K : SharingSkeleton) (d : ℤ) :
    ∀ C C' : K.WorldState, K.RelZ C d C' → K.time C' = K.time C + d := by
  intro C C'
  induction C using Quotient.inductionOn with
  | _ p =>
    induction C' using Quotient.inductionOn with
    | _ q => exact fun h => h.1

/-- **Limit**, by `TaskFrame.limit_of_succOrder`: over the discrete integer duration the only
arbitrarily-small transition is the zero one. -/
theorem relZ_limit (K : SharingSkeleton) :
    ∀ C C' : K.WorldState, (∀ x : ℤ, 0 < x → ∃ y, |y| < x ∧ K.RelZ C y C') → C' = C :=
  TaskFrame.limit_of_succOrder K.relZ_zero

/-- **Fibres are finite.** At a fixed source and duration, every target lies at one fixed time,
where there are at most `n` classes. The carrier itself is infinite, which is exactly the case
`TaskFrame.saturation_of_fib_finite` is for. -/
theorem relZ_fib_finite (K : SharingSkeleton) (C : K.WorldState) (d : ℤ) :
    (TaskFrame.Fib K.RelZ C d).Finite := by
  refine Set.Finite.subset (Set.finite_range
    (fun i : Fin K.n => K.cls i (K.time C + d))) ?_
  intro C' hC'
  have ht := K.time_of_relZ d C C' hC'
  obtain ⟨j, hj⟩ := K.exists_cls C'
  exact ⟨j, by rw [← ht]; exact hj.symm⟩

/-- **Saturation**, by `TaskFrame.saturation_of_fib_finite`. -/
theorem relZ_saturation (K : SharingSkeleton) : TaskFrame.Saturation K.RelZ :=
  TaskFrame.saturation_of_fib_finite K.relZ_fib_finite

/-- *Limit* at the frame's own task relation. -/
theorem frame_limit (K : SharingSkeleton) : TaskFrame.Limit K.frame.TaskRel :=
  TaskFrame.limit_reflect_of_reflective K.relZ_reflection K.relZ_limit

/-- *Saturation* at the frame's own task relation. -/
theorem frame_saturation (K : SharingSkeleton) : TaskFrame.Saturation K.frame.TaskRel :=
  TaskFrame.saturation_reflect_of_reflective K.relZ_reflection K.relZ_saturation

/-- **The branching frame is regular.** All four constraints, none of them using determinism. -/
instance instIsRegular (K : SharingSkeleton) : K.frame.IsRegular where
  comp := K.frame_comp
  serial := K.frame_serial
  limit := K.frame_limit
  saturation := K.frame_saturation

/-- Regularity at the total space as well as at the fibre: instance synthesis does not project
through `FrameOver.toTaskFrame` on its own. -/
instance instIsRegularTask (K : SharingSkeleton) : K.frame.toTaskFrame.IsRegular :=
  K.instIsRegular

/-- **The branching frame is a ℤ-time frame.** Applied with an explicit `@` and four
`inferInstanceAs` arguments: a `haveI` shadows the `SuccOrder` instance that `IsSuccArchimedean`
is indexed by, and the application then fails to elaborate. -/
theorem frame_isZTime (K : SharingSkeleton) : K.frame.toTaskFrame.IsZTime :=
  @TaskFrame.isZTime_of_instances K.frame.toTaskFrame
    (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (PredOrder ℤ))
    (inferInstanceAs (IsSuccArchimedean ℤ)) (inferInstanceAs (IsPredArchimedean ℤ))

/-- The branching frame satisfies the ℤ-time frame class. -/
theorem frame_sat_ztime (K : SharingSkeleton) :
    FormalSystem.ProofSystem.FrameClass.ZTime.Sat K.frame.toTaskFrame :=
  ⟨inferInstance, K.frame_isZTime⟩

/-- The branching frame satisfies the unconstrained frame class, by antitonicity. -/
theorem frame_sat_base (K : SharingSkeleton) :
    FormalSystem.ProofSystem.FrameClass.Base.Sat K.frame.toTaskFrame :=
  FormalSystem.ProofSystem.FrameClass.Sat.anti (by decide) K.frame_sat_ztime

end Frame

/-! ## The histories characterization

`ShiftSet.total_eq_orbit` says that every world history of the deterministic device's frame is a
lasso orbit. It is true **because the task relation is functional**: `respects_task 0` alone pins
every state. Once two indices may share a state a history can cross between them, that argument
fails, and with it the box case of the truth lemma, which is calibrated against "every position
of every lasso". This section supplies the replacement: every world history of `frame` is the
trace of a **thread**, and conversely every thread traces a world history.

**Why the tight `Thread.step` suffices.** `Thread`'s step field is
`share (u+1) (idx u) (idx (u+1))`, which is *narrower* than the frame's one-step relation
`Step u i j = ∃ i', share u i i' ∧ share (u+1) i' j`. That costs nothing here, because a
history's index at `u` may be chosen **knowing the step it is about to take**: the witness `i'`
supplied by `Step` at `u` is itself a legitimate name for the state at `u`, and is exactly the
index the thread records. The construction below does precisely that — it reads the
representatives off the steps, not off the states. There is therefore no two-directional
recursion and no gluing: the choice at each time is independent, and the step law follows from
transitivity of `share` at `u + 1`.

**The deterministic case degenerates to `total_eq_orbit`'s content.** Under
`share u i j := (i = j)` a thread's step field forces `idx (u+1) = idx u`, so `idx` is constant
and `Thread ≃ Fin n`. The statement below then says that every history is the trace of a single
index from some offset — which is `ShiftSet.total_eq_orbit`'s content, read through the frame
isomorphism of `Sharing/Specialize.lean`.
-/
section Histories

open FormalSystem.Semantics

/-- **Any two positions of a thread are connected**, in either time order. -/
theorem conn_thread (K : SharingSkeleton) (θ : K.Thread) (u v : ℤ) :
    K.Conn (θ.idx u, u) (θ.idx v, v) := by
  rcases le_total u v with h | h
  · have hc := conn_of_reachN (θ.reachN (v - u).toNat u)
    rwa [show u + (((v - u).toNat : ℕ) : ℤ) = v from by omega] at hc
  · have hc := conn_of_reachN (θ.reachN (u - v).toNat v)
    rw [show v + (((u - v).toNat : ℕ) : ℤ) = u from by omega] at hc
    exact conn_symm hc

/--
**The world history traced by a thread from a time offset.**

The offset is carried here rather than inside the thread: `share` is decoded from periodic
segments indexed by absolute time, so a thread cannot be time-shifted.
-/
def hist (K : SharingSkeleton) (θ : K.Thread) (s : ℤ) : WorldHistory K.frame.toTaskFrame :=
  WorldHistory.ofTotal K.frame.toTaskFrame (fun t => K.cls (θ.idx (s + t)) (s + t)) <| by
    intro a b
    refine (K.frame_taskRel _ _ _).mpr ?_
    exact (K.relZ_cls _ _ _ _ _).mpr ⟨by omega, conn_thread K θ (s + a) (s + b)⟩

@[simp]
theorem hist_state (K : SharingSkeleton) (θ : K.Thread) (s t : ℤ) :
    (K.hist θ s).state t = K.cls (θ.idx (s + t)) (s + t) := rfl

/-- **A thread's trace is a world history.** This is what the `box` case of the truth lemma
consumes in the other direction from `total_eq_thread`. -/
theorem thread_is_history (K : SharingSkeleton) (θ : K.Thread) (s : ℤ) :
    ∃ σ : WorldHistory K.frame.toTaskFrame,
      ∀ t : ℤ, σ.state t = K.cls (θ.idx (s + t)) (s + t) :=
  ⟨K.hist θ s, fun _ => rfl⟩

/--
**The histories characterization.**

Every world history of the branching frame is the trace of a thread, from some time offset.
This replaces `ShiftSet.total_eq_orbit`, which holds only because the deterministic device's
task relation is functional.

Paper: — (the branching frame is the formalization's own construction, with no paper counterpart)
-/
theorem total_eq_thread (K : SharingSkeleton) (σ : WorldHistory K.frame.toTaskFrame) :
    ∃ θ : K.Thread, ∃ s : ℤ, ∀ t : ℤ, σ.state t = K.cls (θ.idx (s + t)) (s + t) := by
  classical
  set s := K.time (σ.state 0) with hs
  have htime : ∀ t : ℤ, K.time (σ.state t) = s + t := by
    intro t
    have h := (K.frame_taskRel _ _ _).mp (σ.respects_task 0 t)
    have h2 := K.time_of_relZ (t - 0) _ _ h
    omega
  have hrep : ∀ t : ℤ, ∃ i : Fin K.n, σ.state t = K.cls i (s + t) := by
    intro t
    obtain ⟨i, hi⟩ := K.exists_cls (σ.state t)
    exact ⟨i, by rw [hi, htime t]⟩
  choose a ha using hrep
  have hstep : ∀ t : ℤ, K.Step (s + t) (a t) (a (t + 1)) := by
    intro t
    have h := (K.frame_taskRel _ _ _).mp (σ.respects_task t (t + 1))
    rw [ha t, ha (t + 1)] at h
    obtain ⟨_, hc⟩ := (K.relZ_cls _ _ _ _ _).mp h
    unfold Conn at hc
    rw [if_pos (by omega : (a t, s + t).2 ≤ (a (t + 1), s + (t + 1)).2)] at hc
    rw [show ((a (t + 1), s + (t + 1)).2 - (a t, s + t).2).toNat = 1 from by omega] at hc
    exact (K.reachN_one _ _ _).mp hc
  -- The extraction half is unchanged: `a` is a `Step`-path, re-indexed to absolute time.
  have hpath : ∀ u : ℤ, K.Step u (a (u - s)) (a (u + 1 - s)) := by
    intro u
    have h := hstep (u - s)
    rw [show s + (u - s) = u from by omega, show u - s + 1 = u + 1 - s from by omega] at h
    exact h
  -- The gluing half is now the `lift` field rather than an argument: with succession a
  -- separate relation, a `Step`-path's own intermediates need not be `trans`-consecutive, so
  -- the tracking path has to be supplied by the skeleton's own well-formedness.
  obtain ⟨τ, hτstep, hτshare⟩ := K.lift (fun u => a (u - s)) hpath
  refine ⟨⟨τ, hτstep⟩, s, ?_⟩
  intro t
  have hsh : K.share (s + t) (a t) (τ (s + t)) := by
    have h := hτshare (s + t)
    rwa [show s + t - s = t from by omega] at h
  rw [ha t]
  exact cls_eq rfl hsh

end Histories

end SharingSkeleton

end FormalSystem.Metalogic.Decidability
