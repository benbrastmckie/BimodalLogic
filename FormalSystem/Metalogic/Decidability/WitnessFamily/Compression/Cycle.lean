/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Types
import FormalSystem.Semantics.Periodicity
import Mathlib.Data.Int.LeastGreatest

/-!
# Good Cycles over Type Space, with an Explicit Length Bound

`BiLasso/GoodCycle.lean` extracts bounded cycles that *deliver* their eventualities, over the
datum space `PigeonState P φ = Fin P.card × {S // S ∈ (subformulaClosure φ).powerset}`. The
compression half of the witness-family route needs the same construction over the
**presentation-free** datum space: subsets of the certificate closure and nothing else.

## Why this is transcribed rather than instantiated

`WitnessFamily/README.md` states as a directory invariant that the only dependency on
`../BiLasso/` is `Periodic.lean`. Importing `BiLasso/GoodCycle.lean` would break it. Instantiating
that file at a one-state dummy `IntPresentation` would keep the invariant nominally but thread a
semantically empty `P` through every statement in this subdirectory, and would restrict the
closure to `subformulaClosure φ` rather than `closureOf (Γ ++ Del)`.

So the combinatorial core is transcribed here over `TypeState C`, with the state component
deleted. The deletion is a genuine simplification, not a rename: the `PigeonState` product's
first factor is read by exactly one clause of `BiLasso.CoherentEdge` (the atom clause), and that
clause does not exist in `WitnessFamily.LocalCoherentLab`.

**The trigger that retires the duplication**: once a shared periodic-label presentation lands,
`BiLasso/GoodCycle.lean`'s core and this file's should be redefined as its two instances and the
duplicated pigeonhole plumbing deleted. That refactor belongs to whichever task owns the shared
abstraction, and doing it here would put a large refactor under `BiLasso/`'s live `check`.

## The derived bound

`(2k + 1) · 2^k` with `k = C.card`, for the same reason `BiLasso/GoodCycle.lean` derives
`(2k + 1) · N`: each mark is reached by an out-and-back excursion `x ⟶ mark ⟶ x`, contributing
**two** shortened segments rather than one, so `2m` segments for the marks plus one base cycle,
with `m ≤ k`.

Cross-check, compiled during research: instantiating `BiLasso/GoodCycle.lean`'s `cycleBound` at a
one-state `IntPresentation` gives `(2k + 1) · 2^k` with `k = subformulaClosureCard φ` — the same
closed form as `cycleBoundC` at `C = subformulaClosure φ`. That is a cross-check on the
transcribed arithmetic; it is **not** the implementation route.

## Main Definitions

- `TypeState` — the finite datum space: subsets of the target closure
- `SeqStep` — the edge relation induced by an arbitrary datum sequence
- `joinPath` — concatenation of two walks
- `untlEvent` / `snceEvent` — the event of an eventuality formula, as a partial function
- `cycleBoundC` — the closed arithmetic bound `(2k + 1) · 2^k`

## Main Results

- `natCard_typeState` — the datum space has exactly `2 ^ C.card` elements
- `exists_iter_lt_card` — any iterate shortens below the carrier's cardinality
- `exists_recurring_datum` — some datum recurs at arbitrarily large indices
- `exists_base_cycle` — an unmarked cycle through a recurring datum
- `exists_good_cycle_of_typeSeq` — **the good-cycle construction**

Argument order is **guard first**: `Formula.untl g e`, `Formula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

/-! ## The datum space -/

/--
The presentation-free pigeonhole datum: a subset of the target closure.

Declared `abbrev` rather than `def` so that the subtype's `Fintype`, `DecidableEq` and `Finite`
instances are available without restating them — exactly as `PigeonState` is.
-/
abbrev TypeState (C : Finset Formula) : Type := {S : Finset Formula // S ∈ C.powerset}

variable {C : Finset Formula}

/-- The type component of a datum, as a plain `Finset Formula`. -/
def typeOfT (x : TypeState C) : Finset Formula := x.1

/-- A datum's type is a set of closure formulas — the subtype's own side condition, unpacked. -/
theorem typeOfT_subset (x : TypeState C) : typeOfT x ⊆ C :=
  Finset.mem_powerset.mp x.2

/-- **The cardinality of the datum type**, in `Fintype.card` normal form. -/
theorem card_typeState (C : Finset Formula) :
    Fintype.card (TypeState C) = 2 ^ C.card := by
  rw [Fintype.card_coe, Finset.card_powerset]

/--
The same count in `Nat.card` normal form.

**This is the form the downstream bounds use**, because `Semantics/Periodicity.lean`'s
`exists_lt_iter_of_card_le` is stated with `Nat.card`.
-/
theorem natCard_typeState (C : Finset Formula) :
    Nat.card (TypeState C) = 2 ^ C.card := by
  rw [Nat.card_eq_fintype_card, card_typeState]

/-- The datum type is inhabited by the empty subset. -/
instance instInhabitedTypeState : Inhabited (TypeState C) :=
  ⟨⟨∅, Finset.mem_powerset.mpr (Finset.empty_subset _)⟩⟩

@[simp] theorem typeOfT_default : typeOfT (default : TypeState C) = (∅ : Finset Formula) := rfl

/-! ## Walks in a datum sequence -/

/--
The edge relation induced by a datum sequence: `x` steps to `y` when some index carries `x` and
its successor carries `y`.

Generic in the sequence, which is what lets the backward cycle reuse the forward construction at
the reversed sequence `fun u => d (-u)` rather than duplicating two hundred lines with the
temporal direction flipped.
-/
def SeqStepT (d : ℤ → TypeState C) : TypeState C → TypeState C → Prop :=
  fun x y => ∃ u : ℤ, d u = x ∧ d (u + 1) = y

/-- A stretch of the datum sequence is an iterate of its edge relation. -/
theorem iter_seqStepT (d : ℤ → TypeState C) (a : ℤ) (n : ℕ) :
    iter (SeqStepT d) n (d a) (d (a + (n : ℤ))) := by
  induction n with
  | zero => simp
  | succ n ih =>
    refine ⟨d (a + (n : ℤ)), ih, ⟨a + (n : ℤ), rfl, ?_⟩⟩
    congr 1
    omega

/--
**Any iterate shortens to one of length below the carrier's cardinality**, between the same
endpoints.

Repeated application of `exists_lt_iter_of_card_le` (`Semantics/Periodicity.lean`). The fuel
parameter `k` is an artefact of doing the strong induction by ordinary recursion; the unfuelled
form below is what every call site uses. Fully generic in `W`, so this transcribes from
`BiLasso/GoodCycle.lean` with the type variable unchanged.
-/
theorem exists_iterT_lt_card_aux {W : Type} [Finite W] [Nonempty W] (R : W → W → Prop) :
    ∀ (k n : ℕ), n ≤ k → ∀ w u : W, iter R n w u → ∃ m, m < Nat.card W ∧ iter R m w u := by
  intro k
  induction k with
  | zero =>
    intro n hn w u h
    have hn0 : n = 0 := by omega
    subst hn0
    exact ⟨0, Nat.card_pos, h⟩
  | succ k ih =>
    intro n hn w u h
    rcases lt_or_ge n (Nat.card W) with hlt | hge
    · exact ⟨n, hlt, h⟩
    · obtain ⟨m, hm, hmiter⟩ := exists_lt_iter_of_card_le R h hge
      exact ih m (by omega) w u hmiter

theorem exists_iterT_lt_card {W : Type} [Finite W] [Nonempty W] (R : W → W → Prop) {n : ℕ}
    {w u : W} (h : iter R n w u) : ∃ m, m < Nat.card W ∧ iter R m w u :=
  exists_iterT_lt_card_aux R n n le_rfl w u h

/-! ### Concatenating walks -/

/-- Concatenation of two walks: `p` on `[0, L]`, then `q` shifted to start at `L`. -/
def joinPathT (p q : ℕ → TypeState C) (L : ℕ) : ℕ → TypeState C :=
  fun j => if j ≤ L then p j else q (j - L)

theorem joinPathT_left (p q : ℕ → TypeState C) {L j : ℕ} (h : j ≤ L) :
    joinPathT p q L j = p j := if_pos h

theorem joinPathT_right (p q : ℕ → TypeState C) (L : ℕ) (hpq : p L = q 0) (i : ℕ) :
    joinPathT p q L (L + i) = q i := by
  rcases Nat.eq_zero_or_pos i with rfl | hi
  · simp [joinPathT, hpq]
  · have hnot : ¬ (L + i ≤ L) := by omega
    have hsub : L + i - L = i := by omega
    simp only [joinPathT, if_neg hnot, hsub]

theorem joinPathT_steps {d : ℤ → TypeState C} (p q : ℕ → TypeState C) (L L' : ℕ)
    (hpq : p L = q 0)
    (hp : ∀ j, j < L → SeqStepT d (p j) (p (j + 1)))
    (hq : ∀ j, j < L' → SeqStepT d (q j) (q (j + 1))) :
    ∀ j, j < L + L' → SeqStepT d (joinPathT p q L j) (joinPathT p q L (j + 1)) := by
  intro j hj
  rcases lt_or_ge j L with h | h
  · rw [joinPathT_left p q (le_of_lt h), joinPathT_left p q (by omega : j + 1 ≤ L)]
    exact hp j h
  · obtain ⟨i, rfl⟩ : ∃ i, j = L + i := ⟨j - L, by omega⟩
    rw [joinPathT_right p q L hpq i, show L + i + 1 = L + (i + 1) by omega,
      joinPathT_right p q L hpq (i + 1)]
    exact hq i (by omega)

/-! ## Recurrence -/

/--
**Some datum recurs at arbitrarily large indices.**

Pure finiteness: if every datum had a last occurrence, the finitely many last occurrences would
have an upper bound, and the datum at that bound would occur after its own last occurrence.
-/
theorem exists_recurring_typeState (d : ℤ → TypeState C) :
    ∃ x : TypeState C, ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x := by
  classical
  by_contra hcon
  push_neg at hcon
  choose f hf using hcon
  have hne : (Finset.univ : Finset (TypeState C)).Nonempty := Finset.univ_nonempty
  have hle : f (d (Finset.univ.sup' hne f)) ≤ Finset.univ.sup' hne f :=
    Finset.le_sup' f (Finset.mem_univ _)
  exact hf _ _ hle rfl

/-! ## Good cycles -/

/-- The event of an `untl`-formula, as a partial function. -/
def untlEventT : Formula → Option Formula
  | Formula.untl _ e => some e
  | _ => none

/-- The event of a `snce`-formula, as a partial function. -/
def snceEventT : Formula → Option Formula
  | Formula.snce _ e => some e
  | _ => none

@[simp] theorem untlEventT_untl (g e : Formula) : untlEventT (Formula.untl g e) = some e := rfl
@[simp] theorem snceEventT_snce (g e : Formula) : snceEventT (Formula.snce g e) = some e := rfl

/-- An `untlEventT` witness identifies its formula as an `untl` with that event. -/
theorem untlEventT_eq_some : ∀ {f e : Formula}, untlEventT f = some e → ∃ g, f = Formula.untl g e
  | Formula.untl g _, _, rfl => ⟨g, rfl⟩

/-- A `snceEventT` witness identifies its formula as a `snce` with that event. -/
theorem snceEventT_eq_some : ∀ {f e : Formula}, snceEventT f = some e → ∃ g, f = Formula.snce g e
  | Formula.snce g _, _, rfl => ⟨g, rfl⟩

/--
**The explicit cycle bound**: `(2k + 1) · 2^k` with `k = C.card`.

A closed arithmetic expression in the closure's size — not an existentially quantified `n`, which
the enumeration could not consume. `Extract.lean`'s `compressionBound` is defined from this, so
the derived quantity and its consumer cannot drift apart.

Stated as an **upper** bound at every use site. A bound of the shape "segment lengths at least
`f(|C|)`" would be useless to the consuming model checker, whose registry folds `back`/`mid`/`fwd`
bounds by exact modulus: a search at bound `n` represents exactly the periods dividing `n`, so
representability, not magnitude, is what the folding decides.
-/
def cycleBoundC (C : Finset Formula) : ℕ := (2 * C.card + 1) * 2 ^ C.card

theorem cycleBoundC_eq (C : Finset Formula) :
    cycleBoundC C = (2 * C.card + 1) * Nat.card (TypeState C) := by
  rw [cycleBoundC, natCard_typeState]

/--
A cycle through a recurring datum, with no marks: length at least one and at most one full
residue system.

The first step is taken from the sequence directly and only the *return* leg is shortened, which
is what keeps the length positive. A cycle shortened as a whole could collapse to length zero —
the excision of the entire loop — and a zero-length cycle discharges nothing and cannot serve as
a bi-lasso segment, since `LabelledLasso.back_ne` and `fwd_ne` forbid empty cycles.
-/
theorem exists_base_cycleT (d : ℤ → TypeState C) (x : TypeState C)
    (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x) :
    ∃ (L : ℕ) (p : ℕ → TypeState C),
      1 ≤ L ∧ L ≤ Nat.card (TypeState C) ∧ p 0 = x ∧ p L = x ∧
      ∀ j, j < L → SeqStepT d (p j) (p (j + 1)) := by
  obtain ⟨u₀, -, hu₀⟩ := hrec 0
  obtain ⟨u₁, hu₁le, hu₁⟩ := hrec (u₀ + 1)
  have hit : iter (SeqStepT d) (u₁ - (u₀ + 1)).toNat (d (u₀ + 1)) x := by
    have h := iter_seqStepT d (u₀ + 1) (u₁ - (u₀ + 1)).toNat
    rwa [show u₀ + 1 + (((u₁ - (u₀ + 1)).toNat : ℕ) : ℤ) = u₁ by omega, hu₁] at h
  obtain ⟨b, hb, hbiter⟩ := exists_iterT_lt_card (SeqStepT d) hit
  obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (SeqStepT d) b _ _ hbiter
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
**The good-cycle construction, at an arbitrary type sequence.**

Given a datum `x` that recurs at arbitrarily large indices, and a sequence that discharges its
own eventualities, this produces a cycle through `x` of length between `1` and `cycleBoundC C`
whose positions realise the event of every eventuality carried by `x`.

The construction is an induction over the *type* of `x` as a `Finset`, starting from
`exists_base_cycleT` and appending, for each formula with an event, an out-and-back excursion
`x ⟶ mark ⟶ x` whose two legs are separately shortened. Two facts make it work:

- **The excursion is available**: the sequence's own fulfilment supplies a later index carrying
  the event, and recurrence supplies a still later index carrying `x` again.
- **Shortening cannot destroy a mark**: the mark sits at the junction of the two legs, and
  `exists_iterT_lt_card` preserves endpoints.

Formulas with no event contribute nothing and reuse the cycle built so far; the bound is stated
per-formula, so unused budget is simply not spent.

The statement is generic in the sequence so that the backward cycle can instantiate it at
`fun u => d (-u)` rather than duplicating the construction with the temporal direction flipped.
-/
theorem exists_good_cycle_of_typeSeq (C : Finset Formula)
    (d : ℤ → {S : Finset Formula // S ∈ C.powerset}) (ev : Formula → Option Formula)
    (x : {S : Finset Formula // S ∈ C.powerset})
    (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x)
    (hful : ∀ (u : ℤ) (f e : Formula), f ∈ (d u).1 → ev f = some e →
      ∃ s : ℤ, u < s ∧ e ∈ (d s).1) :
    ∃ (L : ℕ) (p : ℕ → {S : Finset Formula // S ∈ C.powerset}),
      1 ≤ L ∧ L ≤ (2 * C.card + 1) * 2 ^ C.card ∧ p 0 = x ∧ p L = x ∧
      (∀ j, j < L → ∃ u : ℤ, d u = p j ∧ d (u + 1) = p (j + 1)) ∧
      (∀ f e : Formula, f ∈ x.1 → ev f = some e →
        ∃ j, j < L ∧ e ∈ (p (j + 1)).1) := by
  classical
  have hkey : ∀ S : Finset Formula, S ⊆ x.1 →
      ∃ (L : ℕ) (p : ℕ → TypeState C),
        1 ≤ L ∧ L ≤ (2 * S.card + 1) * Nat.card (TypeState C) ∧ p 0 = x ∧ p L = x ∧
        (∀ j, j < L → SeqStepT d (p j) (p (j + 1))) ∧
        (∀ f e : Formula, f ∈ S → ev f = some e →
          ∃ j, j < L ∧ e ∈ (p (j + 1)).1) := by
    intro S
    induction S using Finset.induction_on with
    | empty =>
      intro _
      obtain ⟨L, p, h1, h2, h3, h4, h5⟩ := exists_base_cycleT d x hrec
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
        have hitA : iter (SeqStepT d) (s - u₀).toNat x (d s) := by
          have h := iter_seqStepT d u₀ (s - u₀).toNat
          rw [hu₀] at h
          rwa [show u₀ + (((s - u₀).toNat : ℕ) : ℤ) = s by omega] at h
        obtain ⟨a, ha, haiter⟩ := exists_iterT_lt_card (SeqStepT d) hitA
        have hitB : iter (SeqStepT d) (u₁ - s).toNat (d s) x := by
          have h := iter_seqStepT d s (u₁ - s).toNat
          rwa [show s + (((u₁ - s).toNat : ℕ) : ℤ) = u₁ by omega, hu₁] at h
        obtain ⟨b, hb, hbiter⟩ := exists_iterT_lt_card (SeqStepT d) hitB
        obtain ⟨pa, hpa0, hpaa, hpast⟩ := exists_path_of_iter (SeqStepT d) a _ _ haiter
        obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (SeqStepT d) b _ _ hbiter
        have hseam : pa a = pb 0 := by rw [hpaa, hpb0]
        -- the excursion `x ⟶ d s ⟶ x`, as one walk of length `a + b`
        have hq0 : joinPathT pa pb a 0 = x := by rw [joinPathT_left pa pb (Nat.zero_le a), hpa0]
        have hqa : joinPathT pa pb a a = d s := by rw [joinPathT_left pa pb (le_refl a), hpaa]
        have hqab : joinPathT pa pb a (a + b) = x := by
          rw [joinPathT_right pa pb a hseam b, hpbb]
        have hqst := joinPathT_steps pa pb a b hseam hpast hpbst
        have hp'q : p' L' = joinPathT pa pb a 0 := by rw [h4, hq0]
        refine ⟨L' + (a + b), joinPathT p' (joinPathT pa pb a) L', by omega, ?_, ?_, ?_, ?_, ?_⟩
        · obtain ⟨A, hA⟩ : ∃ A, (2 * S.card + 1) * Nat.card (TypeState C) = A := ⟨_, rfl⟩
          have harith : (2 * (S.card + 1) + 1) * Nat.card (TypeState C)
              = A + 2 * Nat.card (TypeState C) := by
            rw [← hA, show 2 * (S.card + 1) + 1 = (2 * S.card + 1) + 2 by omega, Nat.add_mul]
          rw [hA] at h2
          rw [harith]
          omega
        · rw [joinPathT_left p' _ (Nat.zero_le L'), h3]
        · rw [joinPathT_right p' _ L' hp'q (a + b), hqab]
        · exact joinPathT_steps p' _ L' (a + b) hp'q h5 hqst
        · intro f' e' hf' hev'
          rcases Finset.mem_insert.mp hf' with rfl | hf'S
          · -- the newly marked formula: its event sits at the junction of the two legs
            have hee : e' = e := by rw [hev] at hev'; exact (Option.some.injEq _ _ ▸ hev').symm
            subst hee
            refine ⟨L' + a - 1, by omega, ?_⟩
            rw [show L' + a - 1 + 1 = L' + a by omega, joinPathT_right p' _ L' hp'q a, hqa]
            exact hes
          · -- an older mark: it lives in the prefix, which the join leaves untouched
            obtain ⟨j, hj, hjmem⟩ := h6 f' e' hf'S hev'
            exact ⟨j, by omega, by rwa [joinPathT_left p' _ (by omega : j + 1 ≤ L')]⟩
  obtain ⟨L, p, h1, h2, h3, h4, h5, h6⟩ := hkey x.1 (Finset.Subset.refl _)
  refine ⟨L, p, h1, ?_, h3, h4, h5, h6⟩
  have hb : L ≤ (2 * C.card + 1) * Nat.card (TypeState C) := by
    refine le_trans h2 (Nat.mul_le_mul ?_ (le_refl _))
    have hc : x.1.card ≤ C.card := Finset.card_le_card (Finset.mem_powerset.mp x.2)
    omega
  rwa [natCard_typeState] at hb

end FormalSystem.Metalogic.Decidability
