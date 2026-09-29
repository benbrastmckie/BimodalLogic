/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Compression.Types
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Cycle
import FormalSystem.Semantics.Periodicity
import Mathlib.Data.Int.LeastGreatest

/-!
# Good Cycles over L⁺ Type Space, with an Explicit Length Bound

The L⁺ twin of `WitnessFamily/Compression/Cycle.lean`: the same combinatorial core over
`PlusTypeState C`, subsets of the L⁺ certificate closure.

## What is reused and what is transcribed

The `Formula`-side module's pigeonhole pair `exists_iterT_lt_card_aux` / `exists_iterT_lt_card`
is stated over an abstract `{W : Type} [Finite W] [Nonempty W]` and a bare relation
`R : W → W → Prop`. Neither signature mentions `Formula` or `TypeState C` anywhere, load-bearing
or otherwise, so both are **reused by import** rather than re-proved. This module therefore
imports the `Formula`-side `Compression/Cycle.lean` for exactly those two declarations, and the
import is recorded here so it is a decision rather than an accident.

Everything else is transcribed, because everything else is monomorphic in `Formula` through
`TypeState C = {S : Finset Formula // S ∈ C.powerset}`. No instantiation reaches it: `Formula`
and `PlusFormula` are separate inductives sharing no supertype, so `Finset Formula` and
`Finset PlusFormula` are unrelated types and the subtype cannot be re-indexed.

**The trigger that retires the duplication** is the same one the `Formula`-side module records:
once a shared periodic-label presentation lands, both cores should be redefined as its instances
and the duplicated plumbing deleted.

## The derived bound

`(2k + 1) · 2^k` with `k = C.card`, identical in shape to the `Formula` side and for the same
reason: each mark is reached by an out-and-back excursion `x ⟶ mark ⟶ x`, contributing **two**
shortened segments rather than one, so `2m` segments for the marks plus one base cycle, with
`m ≤ k`. The L⁺ closure is larger than the `Formula` closure of a corresponding formula — it has
a `stab` tier — but the bound's *form* is unchanged, because `⊡` contributes no event and so no
excursion. That is Phase 4's observation, carried here for the arithmetic.

## Main Definitions

- `PlusTypeState` — the finite datum space: subsets of the L⁺ target closure
- `plusTypeOfT` — the type component of a datum
- `PlusSeqStepT` — the edge relation induced by an arbitrary L⁺ datum sequence
- `plusJoinPathT` — concatenation of two walks

## Main Results

- `natCard_plusTypeState` — the datum space has exactly `2 ^ C.card` elements
- `iter_plusSeqStepT` — a stretch of the datum sequence is an iterate of its edge relation
- `plusJoinPathT_left` / `plusJoinPathT_right` / `plusJoinPathT_steps` — the joining interface
- `exists_recurring_plusTypeState` — some datum recurs at arbitrarily large indices

Argument order is **guard first**: `PlusFormula.untl g e`, `PlusFormula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-! ## The L⁺ datum space -/

/--
The presentation-free L⁺ pigeonhole datum: a subset of the L⁺ target closure.

Declared `abbrev` rather than `def` so that the subtype's `Fintype`, `DecidableEq` and `Finite`
instances are available without restating them, exactly as `TypeState` is.
-/
abbrev PlusTypeState (C : Finset PlusFormula) : Type := {S : Finset PlusFormula // S ∈ C.powerset}

variable {C : Finset PlusFormula}

/-- The type component of an L⁺ datum, as a plain `Finset PlusFormula`. -/
def plusTypeOfT (x : PlusTypeState C) : Finset PlusFormula := x.1

/-- A datum's type is a set of closure formulas — the subtype's own side condition, unpacked. -/
theorem plusTypeOfT_subset (x : PlusTypeState C) : plusTypeOfT x ⊆ C :=
  Finset.mem_powerset.mp x.2

/-- **The cardinality of the L⁺ datum type**, in `Fintype.card` normal form. -/
theorem card_plusTypeState (C : Finset PlusFormula) :
    Fintype.card (PlusTypeState C) = 2 ^ C.card := by
  rw [Fintype.card_coe, Finset.card_powerset]

/--
The same count in `Nat.card` normal form.

**This is the form the downstream bounds use**, because `Semantics/Periodicity.lean`'s
`exists_lt_iter_of_card_le` is stated with `Nat.card`.
-/
theorem natCard_plusTypeState (C : Finset PlusFormula) :
    Nat.card (PlusTypeState C) = 2 ^ C.card := by
  rw [Nat.card_eq_fintype_card, card_plusTypeState]

/-- The L⁺ datum type is inhabited by the empty subset. -/
instance instInhabitedPlusTypeState : Inhabited (PlusTypeState C) :=
  ⟨⟨∅, Finset.mem_powerset.mpr (Finset.empty_subset _)⟩⟩

@[simp] theorem plusTypeOfT_default :
    plusTypeOfT (default : PlusTypeState C) = (∅ : Finset PlusFormula) := rfl

/-! ## Walks in an L⁺ datum sequence -/

/--
The edge relation induced by an L⁺ datum sequence: `x` steps to `y` when some index carries `x`
and its successor carries `y`.

Generic in the sequence, which is what lets the backward cycle reuse the forward construction at
the reversed sequence `fun u => d (-u)` rather than duplicating the construction with the
temporal direction flipped.
-/
def PlusSeqStepT (d : ℤ → PlusTypeState C) : PlusTypeState C → PlusTypeState C → Prop :=
  fun x y => ∃ u : ℤ, d u = x ∧ d (u + 1) = y

/-- A stretch of the L⁺ datum sequence is an iterate of its edge relation. -/
theorem iter_plusSeqStepT (d : ℤ → PlusTypeState C) (a : ℤ) (n : ℕ) :
    iter (PlusSeqStepT d) n (d a) (d (a + (n : ℤ))) := by
  induction n with
  | zero => simp
  | succ n ih =>
    refine ⟨d (a + (n : ℤ)), ih, ⟨a + (n : ℤ), rfl, ?_⟩⟩
    congr 1
    omega

/-! ### Concatenating walks -/

/-- Concatenation of two walks: `p` on `[0, L]`, then `q` shifted to start at `L`. -/
def plusJoinPathT (p q : ℕ → PlusTypeState C) (L : ℕ) : ℕ → PlusTypeState C :=
  fun j => if j ≤ L then p j else q (j - L)

theorem plusJoinPathT_left (p q : ℕ → PlusTypeState C) {L j : ℕ} (h : j ≤ L) :
    plusJoinPathT p q L j = p j := if_pos h

theorem plusJoinPathT_right (p q : ℕ → PlusTypeState C) (L : ℕ) (hpq : p L = q 0) (i : ℕ) :
    plusJoinPathT p q L (L + i) = q i := by
  rcases Nat.eq_zero_or_pos i with rfl | hi
  · simp [plusJoinPathT, hpq]
  · have hnot : ¬ (L + i ≤ L) := by omega
    have hsub : L + i - L = i := by omega
    simp only [plusJoinPathT, if_neg hnot, hsub]

theorem plusJoinPathT_steps {d : ℤ → PlusTypeState C} (p q : ℕ → PlusTypeState C) (L L' : ℕ)
    (hpq : p L = q 0)
    (hp : ∀ j, j < L → PlusSeqStepT d (p j) (p (j + 1)))
    (hq : ∀ j, j < L' → PlusSeqStepT d (q j) (q (j + 1))) :
    ∀ j, j < L + L' → PlusSeqStepT d (plusJoinPathT p q L j) (plusJoinPathT p q L (j + 1)) := by
  intro j hj
  rcases lt_or_ge j L with h | h
  · rw [plusJoinPathT_left p q (le_of_lt h), plusJoinPathT_left p q (by omega : j + 1 ≤ L)]
    exact hp j h
  · obtain ⟨i, rfl⟩ : ∃ i, j = L + i := ⟨j - L, by omega⟩
    rw [plusJoinPathT_right p q L hpq i, show L + i + 1 = L + (i + 1) by omega,
      plusJoinPathT_right p q L hpq (i + 1)]
    exact hq i (by omega)

/-! ## Recurrence -/

/--
**Some L⁺ datum recurs at arbitrarily large indices.**

Pure finiteness: if every datum had a last occurrence, the finitely many last occurrences would
have an upper bound, and the datum at that bound would occur after its own last occurrence.
-/
theorem exists_recurring_plusTypeState (d : ℤ → PlusTypeState C) :
    ∃ x : PlusTypeState C, ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x := by
  classical
  by_contra hcon
  push Not at hcon
  choose f hf using hcon
  have hne : (Finset.univ : Finset (PlusTypeState C)).Nonempty := Finset.univ_nonempty
  have hle : f (d (Finset.univ.sup' hne f)) ≤ Finset.univ.sup' hne f :=
    Finset.le_sup' f (Finset.mem_univ _)
  exact hf _ _ hle rfl


/-! ## Good cycles -/

/--
The event of an L⁺ `untl`-formula, as a partial function.

**There is deliberately no `stab` decoder beside this one and `plusSnceEventT`.** `⊡` is not an
eventuality: it has no unfolding clause in (C1') by design, so it generates no excursion demand
and contributes nothing to a good cycle. Its obligation is (C5), which is same-time and
cross-index and is discharged by the Phase 8 saturation, not by a cycle. The two decoders
therefore stay at `untl` and `snce` exactly as on the `Formula` side, and the cycle bound keeps
its `Formula`-side shape.
-/
def plusUntlEventT : PlusFormula → Option PlusFormula
  | PlusFormula.untl _ e => some e
  | _ => none

/-- The event of an L⁺ `snce`-formula, as a partial function. -/
def plusSnceEventT : PlusFormula → Option PlusFormula
  | PlusFormula.snce _ e => some e
  | _ => none

@[simp] theorem plusUntlEventT_untl (g e : PlusFormula) :
    plusUntlEventT (PlusFormula.untl g e) = some e := rfl

@[simp] theorem plusSnceEventT_snce (g e : PlusFormula) :
    plusSnceEventT (PlusFormula.snce g e) = some e := rfl

/-- `⊡` carries no event, so it never demands an excursion. -/
@[simp] theorem plusUntlEventT_stab (φ : PlusFormula) :
    plusUntlEventT (PlusFormula.stab φ) = none := rfl

/-- The past-tense mirror of `plusUntlEventT_stab`. -/
@[simp] theorem plusSnceEventT_stab (φ : PlusFormula) :
    plusSnceEventT (PlusFormula.stab φ) = none := rfl

/-- A `plusUntlEventT` witness identifies its formula as an `untl` with that event. -/
theorem plusUntlEventT_eq_some :
    ∀ {f e : PlusFormula}, plusUntlEventT f = some e → ∃ g, f = PlusFormula.untl g e
  | PlusFormula.untl g _, _, rfl => ⟨g, rfl⟩

/-- A `plusSnceEventT` witness identifies its formula as a `snce` with that event. -/
theorem plusSnceEventT_eq_some :
    ∀ {f e : PlusFormula}, plusSnceEventT f = some e → ∃ g, f = PlusFormula.snce g e
  | PlusFormula.snce g _, _, rfl => ⟨g, rfl⟩

/--
**The explicit L⁺ cycle bound**: `(2k + 1) · 2^k` with `k = C.card`.

A closed arithmetic expression in the closure's size — not an existentially quantified `n`, which
the enumeration could not consume. `Extract.lean`'s `plusCompressionBound` is defined from this,
so the derived quantity and its consumer cannot drift apart.

The form is the `Formula` side's verbatim, and that is a result rather than a coincidence: the
L⁺ closure is strictly larger, since it carries a `stab` tier, but `⊡` contributes no event and
so no excursion, so the per-mark accounting is unchanged and only `k` grows.

Stated as an **upper** bound at every use site, for the same reason the `Formula`-side bound is:
a consuming search at bound `n` represents exactly the periods dividing `n`, so representability
rather than magnitude is what the folding decides.
-/
def plusCycleBoundC (C : Finset PlusFormula) : ℕ := (2 * C.card + 1) * 2 ^ C.card

theorem plusCycleBoundC_eq (C : Finset PlusFormula) :
    plusCycleBoundC C = (2 * C.card + 1) * Nat.card (PlusTypeState C) := by
  rw [plusCycleBoundC, natCard_plusTypeState]

/--
A cycle through a recurring L⁺ datum, with no marks: length at least one and at most one full
residue system.

The first step is taken from the sequence directly and only the *return* leg is shortened, which
is what keeps the length positive. A cycle shortened as a whole could collapse to length zero —
the excision of the entire loop — and a zero-length cycle discharges nothing and cannot serve as
a bi-lasso segment, since `PlusLabelledLasso.back_ne` and `fwd_ne` forbid empty cycles.
-/
theorem exists_base_plusCycleT (d : ℤ → PlusTypeState C) (x : PlusTypeState C)
    (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x) :
    ∃ (L : ℕ) (p : ℕ → PlusTypeState C),
      1 ≤ L ∧ L ≤ Nat.card (PlusTypeState C) ∧ p 0 = x ∧ p L = x ∧
      ∀ j, j < L → PlusSeqStepT d (p j) (p (j + 1)) := by
  obtain ⟨u₀, -, hu₀⟩ := hrec 0
  obtain ⟨u₁, hu₁le, hu₁⟩ := hrec (u₀ + 1)
  have hit : iter (PlusSeqStepT d) (u₁ - (u₀ + 1)).toNat (d (u₀ + 1)) x := by
    have h := iter_plusSeqStepT d (u₀ + 1) (u₁ - (u₀ + 1)).toNat
    rwa [show u₀ + 1 + (((u₁ - (u₀ + 1)).toNat : ℕ) : ℤ) = u₁ by omega, hu₁] at h
  obtain ⟨b, hb, hbiter⟩ := exists_iterT_lt_card (PlusSeqStepT d) hit
  obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (PlusSeqStepT d) b _ _ hbiter
  refine ⟨b + 1, fun j => if j = 0 then x else pb (j - 1), by omega, by omega, by simp, ?_, ?_⟩
  · simpa using hpbb
  · intro j hj
    rcases Nat.eq_zero_or_pos j with rfl | hjpos
    · simp only [hpb0]
      exact ⟨u₀, hu₀, rfl⟩
    · have h1 : ¬ j = 0 := by omega
      have h2 : ¬ j + 1 = 0 := by omega
      simp only [if_neg h1, if_neg h2]
      have hstep := hpbst (j - 1) (by omega)
      rwa [show j - 1 + 1 = j + 1 - 1 by omega] at hstep

/--
**The good-cycle construction, at an arbitrary L⁺ type sequence.**

Given a datum `x` that recurs at arbitrarily large indices, and a sequence that discharges its
own eventualities, this produces a cycle through `x` of length between `1` and
`plusCycleBoundC C` whose positions realise the event of every eventuality carried by `x`.

The construction is an induction over the *type* of `x` as a `Finset`, starting from
`exists_base_plusCycleT` and appending, for each formula with an event, an out-and-back excursion
`x ⟶ mark ⟶ x` whose two legs are separately shortened. Two facts make it work:

- **The excursion is available**: the sequence's own fulfilment supplies a later index carrying
  the event, and recurrence supplies a still later index carrying `x` again.
- **Shortening cannot destroy a mark**: the mark sits at the junction of the two legs, and
  `exists_iterT_lt_card` preserves endpoints.

Formulas with no event contribute nothing and reuse the cycle built so far, which is exactly the
branch every `stab` member of the L⁺ closure takes; the bound is stated per-formula, so unused
budget is simply not spent.

The statement is generic in the sequence and in the event decoder, so that the backward cycle can
instantiate it at `fun u => d (-u)` rather than duplicating the construction with the temporal
direction flipped.

**Statement diff against `exists_good_cycle_of_typeSeq`.** The two signatures agree
component-for-component: same hypothesis list, same conclusion shape, same bound
`(2 * C.card + 1) * 2 ^ C.card`. The only substitution is `Formula` by `PlusFormula` in the
closure, the datum subtype and the event decoder's domain and codomain. There is **no**
structural divergence to explain, and in particular no extra hypothesis and no weakened bound —
which is the substantive finding, because it is what records that the `stab` tier of the L⁺
closure costs the cycle construction nothing beyond enlarging `C.card`.
-/
theorem exists_good_cycle_of_plusTypeSeq (C : Finset PlusFormula)
    (d : ℤ → {S : Finset PlusFormula // S ∈ C.powerset}) (ev : PlusFormula → Option PlusFormula)
    (x : {S : Finset PlusFormula // S ∈ C.powerset})
    (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x)
    (hful : ∀ (u : ℤ) (f e : PlusFormula), f ∈ (d u).1 → ev f = some e →
      ∃ s : ℤ, u < s ∧ e ∈ (d s).1) :
    ∃ (L : ℕ) (p : ℕ → {S : Finset PlusFormula // S ∈ C.powerset}),
      1 ≤ L ∧ L ≤ (2 * C.card + 1) * 2 ^ C.card ∧ p 0 = x ∧ p L = x ∧
      (∀ j, j < L → ∃ u : ℤ, d u = p j ∧ d (u + 1) = p (j + 1)) ∧
      (∀ f e : PlusFormula, f ∈ x.1 → ev f = some e →
        ∃ j, j < L ∧ e ∈ (p (j + 1)).1) := by
  classical
  have hkey : ∀ S : Finset PlusFormula, S ⊆ x.1 →
      ∃ (L : ℕ) (p : ℕ → PlusTypeState C),
        1 ≤ L ∧ L ≤ (2 * S.card + 1) * Nat.card (PlusTypeState C) ∧ p 0 = x ∧ p L = x ∧
        (∀ j, j < L → PlusSeqStepT d (p j) (p (j + 1))) ∧
        (∀ f e : PlusFormula, f ∈ S → ev f = some e →
          ∃ j, j < L ∧ e ∈ (p (j + 1)).1) := by
    intro S
    induction S using Finset.induction_on with
    | empty =>
      intro _
      obtain ⟨L, p, h1, h2, h3, h4, h5⟩ := exists_base_plusCycleT d x hrec
      refine ⟨L, p, h1, ?_, h3, h4, h5, ?_⟩
      · simpa using h2
      · intro f e hf _
        exact absurd hf (Finset.notMem_empty f)
    | @insert f S hf ih =>
      intro hsub
      obtain ⟨L', p', h1, h2, h3, h4, h5, h6⟩ :=
        ih (fun y hy => hsub (Finset.mem_insert_of_mem hy))
      rw [Finset.card_insert_of_notMem hf]
      cases hev : ev f with
      | none =>
        refine ⟨L', p', h1, le_trans h2 (Nat.mul_le_mul (by omega) (le_refl _)), h3, h4, h5, ?_⟩
        intro f' e hf' hev'
        rcases Finset.mem_insert.mp hf' with rfl | hf'S
        · rw [hev] at hev'
          exact absurd hev' (by simp)
        · exact h6 f' e hf'S hev'
      | some e =>
        obtain ⟨u₀, -, hu₀⟩ := hrec 0
        have hfx : f ∈ (d u₀).1 := by
          rw [hu₀]; exact hsub (Finset.mem_insert_self f S)
        obtain ⟨s, hs, hes⟩ := hful u₀ f e hfx hev
        obtain ⟨u₁, hu₁le, hu₁⟩ := hrec (s + 1)
        have hitA : iter (PlusSeqStepT d) (s - u₀).toNat x (d s) := by
          have h := iter_plusSeqStepT d u₀ (s - u₀).toNat
          rw [hu₀] at h
          rwa [show u₀ + (((s - u₀).toNat : ℕ) : ℤ) = s by omega] at h
        obtain ⟨a, ha, haiter⟩ := exists_iterT_lt_card (PlusSeqStepT d) hitA
        have hitB : iter (PlusSeqStepT d) (u₁ - s).toNat (d s) x := by
          have h := iter_plusSeqStepT d s (u₁ - s).toNat
          rwa [show s + (((u₁ - s).toNat : ℕ) : ℤ) = u₁ by omega, hu₁] at h
        obtain ⟨b, hb, hbiter⟩ := exists_iterT_lt_card (PlusSeqStepT d) hitB
        obtain ⟨pa, hpa0, hpaa, hpast⟩ := exists_path_of_iter (PlusSeqStepT d) a _ _ haiter
        obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (PlusSeqStepT d) b _ _ hbiter
        have hseam : pa a = pb 0 := by rw [hpaa, hpb0]
        -- the excursion `x ⟶ d s ⟶ x`, as one walk of length `a + b`
        have hq0 : plusJoinPathT pa pb a 0 = x := by
          rw [plusJoinPathT_left pa pb (Nat.zero_le a), hpa0]
        have hqa : plusJoinPathT pa pb a a = d s := by
          rw [plusJoinPathT_left pa pb (le_refl a), hpaa]
        have hqab : plusJoinPathT pa pb a (a + b) = x := by
          rw [plusJoinPathT_right pa pb a hseam b, hpbb]
        have hqst := plusJoinPathT_steps pa pb a b hseam hpast hpbst
        have hp'q : p' L' = plusJoinPathT pa pb a 0 := by rw [h4, hq0]
        refine ⟨L' + (a + b), plusJoinPathT p' (plusJoinPathT pa pb a) L', by omega,
          ?_, ?_, ?_, ?_, ?_⟩
        · obtain ⟨A, hA⟩ : ∃ A, (2 * S.card + 1) * Nat.card (PlusTypeState C) = A := ⟨_, rfl⟩
          have harith : (2 * (S.card + 1) + 1) * Nat.card (PlusTypeState C)
              = A + 2 * Nat.card (PlusTypeState C) := by
            rw [← hA, show 2 * (S.card + 1) + 1 = (2 * S.card + 1) + 2 by omega, Nat.add_mul]
          rw [hA] at h2
          rw [harith]
          omega
        · rw [plusJoinPathT_left p' _ (Nat.zero_le L'), h3]
        · rw [plusJoinPathT_right p' _ L' hp'q (a + b), hqab]
        · exact plusJoinPathT_steps p' _ L' (a + b) hp'q h5 hqst
        · intro f' e' hf' hev'
          rcases Finset.mem_insert.mp hf' with rfl | hf'S
          · -- the newly marked formula: its event sits at the junction of the two legs
            have hee : e' = e := by rw [hev] at hev'; exact (Option.some.injEq _ _ ▸ hev').symm
            subst hee
            refine ⟨L' + a - 1, by omega, ?_⟩
            rw [show L' + a - 1 + 1 = L' + a by omega, plusJoinPathT_right p' _ L' hp'q a, hqa]
            exact hes
          · -- an older mark: it lives in the prefix, which the join leaves untouched
            obtain ⟨j, hj, hjmem⟩ := h6 f' e' hf'S hev'
            exact ⟨j, by omega, by rwa [plusJoinPathT_left p' _ (by omega : j + 1 ≤ L')]⟩
  obtain ⟨L, p, h1, h2, h3, h4, h5, h6⟩ := hkey x.1 (Finset.Subset.refl _)
  refine ⟨L, p, h1, ?_, h3, h4, h5, h6⟩
  have hb : L ≤ (2 * C.card + 1) * Nat.card (PlusTypeState C) := by
    refine le_trans h2 (Nat.mul_le_mul ?_ (le_refl _))
    have hc : x.1.card ≤ C.card := Finset.card_le_card (Finset.mem_powerset.mp x.2)
    omega
  rwa [natCard_plusTypeState] at hb

end FormalSystem.Metalogic.Decidability
