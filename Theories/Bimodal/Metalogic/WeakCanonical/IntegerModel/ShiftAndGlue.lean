import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps
import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery

/-!
# Shift-and-Glue Construction: Very-Good to Good via Reynolds Lemma 16

Very good to good (Reynolds Lemma 16), half-open partition, shift-and-glue
helpers, and chronicle-is-good theorem.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core

/-! ## Very Good → Good (Reynolds Lemma 16) -/

/--
Helper: Choose Z-interval witnesses for a family of good structures.
-/
private noncomputable def choose_good_witness (sig : MonadicSignature) (k : Nat)
    (ms : ℤ → OrderedMonadicStructure sig) (h : ∀ i, good sig k (ms i)) :
    (i : ℤ) → ZIntervalStructure sig :=
  fun i => (h i).choose

private theorem choose_good_witness_spec (sig : MonadicSignature) (k : Nat)
    (ms : ℤ → OrderedMonadicStructure sig) (h : ∀ i, good sig k (ms i)) :
    ∀ i, k_equiv sig k (ms i) ((choose_good_witness sig k ms h i).toOrdered sig) :=
  fun i => (h i).choose_spec

/-- Positive half of cofinal sequence: strictly increasing, above all enumerated elements. -/
private noncomputable def cofinal_pos_seq {α : Type} [LinearOrder α] [NoMaxOrder α]
    (enum : ℕ → α) : ℕ → α :=
  Nat.rec (enum 0) (fun n prev => (exists_gt (max prev (enum n))).choose)

/-- Negative half of cofinal sequence: strictly decreasing, below all enumerated elements. -/
private noncomputable def cofinal_neg_seq {α : Type} [LinearOrder α] [NoMinOrder α]
    (start : α) (enum : ℕ → α) : ℕ → α :=
  Nat.rec (exists_lt (min start (enum 0))).choose
    (fun n prev => (exists_lt (min prev (enum (n + 1)))).choose)

/-- Combined cofinal sequence: positive indices use pos_seq, negative use neg_seq. -/
private noncomputable def mk_cofinal_seq {α : Type} [LinearOrder α]
    [NoMaxOrder α] [NoMinOrder α] (enum : ℕ → α) : ℤ → α := fun i =>
  if i ≥ 0 then cofinal_pos_seq enum i.toNat
  else cofinal_neg_seq (enum 0) enum (-i - 1).toNat

private theorem cofinal_pos_seq_lt_succ {α : Type} [LinearOrder α] [NoMaxOrder α]
    (enum : ℕ → α) (n : ℕ) : cofinal_pos_seq enum n < cofinal_pos_seq enum (n + 1) := by
  show cofinal_pos_seq enum n < (exists_gt (max (cofinal_pos_seq enum n) (enum n))).choose
  exact lt_of_le_of_lt (le_max_left _ _)
    (exists_gt (max (cofinal_pos_seq enum n) (enum n))).choose_spec

private theorem cofinal_pos_seq_above_enum {α : Type} [LinearOrder α] [NoMaxOrder α]
    (enum : ℕ → α) (m : ℕ) : enum m < cofinal_pos_seq enum (m + 1) := by
  show enum m < (exists_gt (max (cofinal_pos_seq enum m) (enum m))).choose
  exact lt_of_le_of_lt (le_max_right _ _)
    (exists_gt (max (cofinal_pos_seq enum m) (enum m))).choose_spec

private theorem cofinal_neg_seq_succ_lt {α : Type} [LinearOrder α] [NoMinOrder α]
    (start : α) (enum : ℕ → α) (n : ℕ) :
    cofinal_neg_seq start enum (n + 1) < cofinal_neg_seq start enum n := by
  show (exists_lt (min (cofinal_neg_seq start enum n) (enum (n + 1)))).choose <
    cofinal_neg_seq start enum n
  exact lt_of_lt_of_le
    (exists_lt (min (cofinal_neg_seq start enum n) (enum (n + 1)))).choose_spec
    (min_le_left _ _)

private theorem cofinal_neg_seq_below_enum {α : Type} [LinearOrder α] [NoMinOrder α]
    (start : α) (enum : ℕ → α) (m : ℕ) :
    cofinal_neg_seq start enum m < enum m := by
  induction m with
  | zero =>
    show (exists_lt (min start (enum 0))).choose < enum 0
    exact lt_of_lt_of_le (exists_lt (min start (enum 0))).choose_spec (min_le_right _ _)
  | succ n _ =>
    show (exists_lt (min (cofinal_neg_seq start enum n) (enum (n + 1)))).choose < enum (n + 1)
    exact lt_of_lt_of_le
      (exists_lt (min (cofinal_neg_seq start enum n) (enum (n + 1)))).choose_spec
      (min_le_right _ _)

private theorem cofinal_neg_seq_below_start {α : Type} [LinearOrder α] [NoMinOrder α]
    (start : α) (enum : ℕ → α) : cofinal_neg_seq start enum 0 < start := by
  show (exists_lt (min start (enum 0))).choose < start
  exact lt_of_lt_of_le (exists_lt (min start (enum 0))).choose_spec (min_le_left _ _)

/-- Helper: find the last index in a finite range where the sequence is ≤ x. -/
private theorem find_last_index_below {α : Type} [LinearOrder α] (a : ℤ → α)
    (h_mono : StrictMono a) (x : α) (lo hi : ℤ) (h_lo : a lo ≤ x) (h_hi : x < a hi) :
    ∃ i : ℤ, lo ≤ i ∧ a i ≤ x ∧ x < a (i + 1) := by
  classical
  have h_lt : lo < hi := by
    by_contra h; push_neg at h
    exact absurd (lt_of_lt_of_le h_hi (h_mono.monotone h)) (not_lt.mpr h_lo)
  let S := (Finset.Icc lo (hi - 1)).filter (fun i => decide (a i ≤ x) = true)
  have hS_ne : S.Nonempty :=
    ⟨lo, Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨le_refl _, by omega⟩, by simp [h_lo]⟩⟩
  let j := S.max' hS_ne
  have hj_mem : j ∈ S := Finset.max'_mem S hS_ne
  have hj_le_x : a j ≤ x := by
    have := (Finset.mem_filter.mp hj_mem).2; simp at this; exact this
  have hj_lo : lo ≤ j := (Finset.mem_Icc.mp (Finset.mem_filter.mp hj_mem).1).1
  have hj_hi : j ≤ hi - 1 := (Finset.mem_Icc.mp (Finset.mem_filter.mp hj_mem).1).2
  have hj_next : x < a (j + 1) := by
    by_contra h_not_lt; push_neg at h_not_lt
    rcases le_or_gt (j + 1) (hi - 1) with h1 | h2
    · have hj1_in : j + 1 ∈ S := Finset.mem_filter.mpr
        ⟨Finset.mem_Icc.mpr ⟨by omega, h1⟩, by simp [h_not_lt]⟩
      exact absurd (Finset.le_max' S (j + 1) hj1_in) (by omega)
    · exact absurd (lt_of_lt_of_le h_hi ((show j + 1 = hi from by omega) ▸ h_not_lt))
        (lt_irrefl x)
  exact ⟨j, hj_lo, hj_le_x, hj_next⟩

/--
In a countable linear order without endpoints, there exists a strictly increasing
cofinal sequence indexed by ℤ.

Given Countable α + NoMaxOrder + NoMinOrder + Nonempty, we construct a : ℤ → α
that is strictly monotone and cofinal: for every x, there exists i with
a(i) ≤ x ≤ a(i+1).

Construction: Enumerate all elements via Countable. Build positive/negative halves
using NoMaxOrder/NoMinOrder to extend beyond each enumerated element. Combine into
a bi-infinite sequence and prove cofinality via the find-last-index argument on
finite ℤ-intervals.
-/
private theorem exists_cofinal_sequence {α : Type} [LinearOrder α] [Countable α]
    [NoMaxOrder α] [NoMinOrder α] [Nonempty α] :
    ∃ (a : ℤ → α), StrictMono a ∧ ∀ x : α, ∃ i : ℤ, a i ≤ x ∧ x ≤ a (i + 1) := by
  classical
  haveI : Infinite α := NoMaxOrder.infinite
  haveI : Encodable α := (nonempty_encodable α).some
  haveI : Inhabited α := Classical.inhabited_of_nonempty inferInstance
  let enum : ℕ → α := fun n => (Encodable.decode (α := α) n).iget
  have h_surj : Function.Surjective enum := Encodable.surjective_decode_iget α
  let a := mk_cofinal_seq enum
  refine ⟨a, ?_, ?_⟩
  · -- StrictMono: prove a(i) < a(i+1) for all i, then use strictMono_int_of_lt_succ
    apply strictMono_int_of_lt_succ
    intro i
    simp only [a, mk_cofinal_seq]
    by_cases h0 : i ≥ 0
    · -- i ≥ 0: both i and i+1 use cofinal_pos_seq
      have h1 : i + 1 ≥ 0 := by omega
      simp only [show (i ≥ 0) = True from eq_true h0, show (i + 1 ≥ 0) = True from eq_true h1,
        ↓reduceDIte]
      have h_eq : (i + 1).toNat = i.toNat + 1 := by omega
      rw [h_eq]
      exact cofinal_pos_seq_lt_succ enum i.toNat
    · by_cases h1 : i + 1 ≥ 0
      · -- i = -1: transition from neg to pos
        have hi_eq : i = -1 := by omega
        simp only [show ¬(i ≥ 0) from h0, show (i + 1 ≥ 0) = True from eq_true h1,
          ↓reduceDIte]
        have h_tonat1 : (i + 1).toNat = 0 := by omega
        have h_tonat2 : (-i - 1).toNat = 0 := by omega
        rw [h_tonat1, h_tonat2]
        -- Need: cofinal_neg_seq (enum 0) enum 0 < cofinal_pos_seq enum 0
        -- cofinal_pos_seq enum 0 = enum 0
        -- cofinal_neg_seq (enum 0) enum 0 < enum 0
        show cofinal_neg_seq (enum 0) enum 0 < cofinal_pos_seq enum 0
        exact cofinal_neg_seq_below_start (enum 0) enum
      · -- i ≤ -2: both use cofinal_neg_seq, strict anti gives the result
        simp only [show ¬(i ≥ 0) from h0, show ¬(i + 1 ≥ 0) from h1, ↓reduceDIte]
        have h_eq : (-i - 1).toNat = (-(i + 1) - 1).toNat + 1 := by omega
        rw [h_eq]
        exact cofinal_neg_seq_succ_lt (enum 0) enum (-(i + 1) - 1).toNat
  · -- Cofinality: for any x, there exists i with a(i) ≤ x ≤ a(i+1)
    intro x
    obtain ⟨m, hm⟩ := h_surj x
    -- x = enum(m). We have:
    -- a(m+1) = cofinal_pos_seq enum (m+1) > enum(m) = x  (from cofinal_pos_seq_above_enum)
    -- a(-(m+1)) = cofinal_neg_seq (enum 0) enum m < enum(m) = x (from cofinal_neg_seq_below_enum)
    have h_above : x < a (↑(m + 1)) := by
      rw [← hm]
      simp only [a, mk_cofinal_seq, show (↑(m + 1) : ℤ) ≥ 0 from by omega, ↓reduceDIte,
        show (↑(m + 1) : ℤ).toNat = m + 1 from by omega]
      exact cofinal_pos_seq_above_enum enum m
    have h_below : a (-(↑m + 1)) ≤ x := by
      rw [← hm]
      simp only [a, mk_cofinal_seq, show ¬((-(↑m + 1) : ℤ) ≥ 0) from by omega, ↓reduceDIte,
        show (-(-(↑m + 1) : ℤ) - 1).toNat = m from by omega]
      exact le_of_lt (cofinal_neg_seq_below_enum (enum 0) enum m)
    -- Apply find_last_index_below on the finite interval [-(m+1), m+1]
    obtain ⟨i, _, hi_le, hi_next⟩ :=
      find_last_index_below a (strictMono_int_of_lt_succ (fun j => by
        simp only [a, mk_cofinal_seq]
        by_cases h0 : j ≥ 0
        · have h1 : j + 1 ≥ 0 := by omega
          simp only [show (j ≥ 0) = True from eq_true h0, show (j + 1 ≥ 0) = True from eq_true h1,
            ↓reduceDIte]
          have h_eq : (j + 1).toNat = j.toNat + 1 := by omega
          rw [h_eq]; exact cofinal_pos_seq_lt_succ enum j.toNat
        · by_cases h1 : j + 1 ≥ 0
          · simp only [show ¬(j ≥ 0) from h0, show (j + 1 ≥ 0) = True from eq_true h1, ↓reduceDIte]
            have h_tonat1 : (j + 1).toNat = 0 := by omega
            have h_tonat2 : (-j - 1).toNat = 0 := by omega
            rw [h_tonat1, h_tonat2]
            exact cofinal_neg_seq_below_start (enum 0) enum
          · simp only [show ¬(j ≥ 0) from h0, show ¬(j + 1 ≥ 0) from h1, ↓reduceDIte]
            have h_eq : (-j - 1).toNat = (-(j + 1) - 1).toNat + 1 := by omega
            rw [h_eq]; exact cofinal_neg_seq_succ_lt (enum 0) enum (-(j + 1) - 1).toNat))
        x (-(↑m + 1)) (↑(m + 1)) h_below h_above
    exact ⟨i, hi_le, le_of_lt hi_next⟩

/-! ### Half-Open Partition Pieces -/

/--
Half-open subinterval [a, b) of an ordered monadic structure.
The carrier is `{x : M.carrier // a ≤ x ∧ x < b}`.
-/
def OrderedMonadicStructure.hoSubinterval (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a ≤ x ∧ x < b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance

/--
Uniqueness of the partition index: each x belongs to exactly one half-open piece [a(i), a(i+1)).
-/
private theorem partition_index_unique {α : Type} [LinearOrder α] (a : ℤ → α)
    (h_mono : StrictMono a) {x : α} {i j : ℤ}
    (hi : a i ≤ x ∧ x < a (i + 1)) (hj : a j ≤ x ∧ x < a (j + 1)) : i = j := by
  by_contra h
  rcases Ne.lt_or_lt h with h_lt | h_lt
  · -- i < j, so i + 1 ≤ j, hence a(i+1) ≤ a(j) ≤ x < a(i+1)
    have h1 : a (i + 1) ≤ a j := h_mono.monotone (Int.add_one_le_iff.mpr h_lt)
    exact absurd (lt_of_lt_of_le hi.2 (le_trans h1 hj.1)) (lt_irrefl x)
  · -- j < i, symmetric
    have h1 : a (j + 1) ≤ a i := h_mono.monotone (Int.add_one_le_iff.mpr h_lt)
    exact absurd (lt_of_lt_of_le hj.2 (le_trans h1 hi.1)) (lt_irrefl x)

/--
M is k-equivalent to the ordered sum of its half-open partition pieces along a cofinal sequence.

Given a strictly increasing cofinal sequence a : ℤ → M.carrier where every x lies in
some half-open interval [a(i), a(i+1)), M is order-isomorphic to the ordered sum
of the partition pieces, hence k-equivalent.

The half-open pieces [a(i), a(i+1)) form a DISJOINT partition of M (unlike the
closed subintervals [a(i), a(i+1)] which overlap at boundary points). The proof
constructs an explicit OrderIso and applies k_equiv_of_iso.

This is the corrected formulation of Reynolds's "cofinal decomposition" (Lemma 16).
The original closed-interval formulation is false: the ordered sum of closed intervals
has strictly more elements than M (duplicate boundary points), making the structures
non-isomorphic and non-k-equivalent in general.
-/
private theorem cofinal_decomposition_k_equiv (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (a : ℤ → M.carrier)
    (h_mono : StrictMono a)
    (h_cofinal : ∀ x : M.carrier, ∃ i : ℤ, a i ≤ x ∧ x < a (i + 1)) :
    k_equiv sig k M (orderedSum sig ℤ
      (fun i => M.hoSubinterval sig (a i) (a (i + 1)))) := by
  -- Step 1: Construct the forward map M → orderedSum
  have h_index : ∀ x : M.carrier, ∃ i : ℤ, a i ≤ x ∧ x < a (i + 1) := h_cofinal
  -- Use Exists.choose to pick the unique partition index for each x
  let idx : M.carrier → ℤ := fun x => (h_index x).choose
  have h_idx_spec : ∀ x, a (idx x) ≤ x ∧ x < a (idx x + 1) := fun x => (h_index x).choose_spec
  -- Forward map: x ↦ ⟨idx(x), ⟨x, proof⟩⟩
  let fwd : M.carrier → (orderedSum sig ℤ (fun i => M.hoSubinterval sig (a i) (a (i + 1)))).carrier :=
    fun x => ⟨idx x, ⟨x, h_idx_spec x⟩⟩
  -- Backward map: ⟨i, ⟨x, _⟩⟩ ↦ x
  let bwd : (orderedSum sig ℤ (fun i => M.hoSubinterval sig (a i) (a (i + 1)))).carrier → M.carrier :=
    fun s => s.2.val
  -- Step 2: Show these form an Equiv
  have h_left_inv : ∀ x, bwd (fwd x) = x := fun _ => rfl
  have h_right_inv : ∀ s, fwd (bwd s) = s := by
    intro ⟨i, ⟨x, hx⟩⟩
    show (⟨idx x, ⟨x, h_idx_spec x⟩⟩ : Sigma fun i => (M.hoSubinterval sig (a i) (a (i + 1))).carrier) = ⟨i, ⟨x, hx⟩⟩
    have h_idx_eq : idx x = i := partition_index_unique a h_mono (h_idx_spec x) hx
    exact Sigma.ext h_idx_eq (by subst h_idx_eq; rfl)
  let e : M.carrier ≃ (orderedSum sig ℤ (fun i => M.hoSubinterval sig (a i) (a (i + 1)))).carrier :=
    { toFun := fwd, invFun := bwd, left_inv := h_left_inv, right_inv := h_right_inv }
  -- Step 3: Show e is monotone (both directions), yielding an OrderIso.
  let S := orderedSum sig ℤ (fun i => M.hoSubinterval sig (a i) (a (i + 1)))
  -- Step 3: Prove inverse monotone first (clean because destructuring gives simple vars)
  have h_inv_mono : Monotone e.symm := by
    intro s1 s2 h12
    show bwd s1 ≤ bwd s2
    obtain ⟨i, ⟨x, hx⟩⟩ := s1
    obtain ⟨j, ⟨y, hy⟩⟩ := s2
    show x ≤ y
    rcases Sigma.Lex.le_def.mp h12 with h_lt_idx | ⟨h_eq_idx, h_le_snd⟩
    · -- i < j: x < a(i+1) ≤ a(j) ≤ y
      exact le_of_lt (lt_of_lt_of_le hx.2
        (le_trans (h_mono.monotone (Int.add_one_le_iff.mpr h_lt_idx)) hy.1))
    · -- i = j: extract x ≤ y from the subtype ordering
      cases h_eq_idx; exact h_le_snd
  -- Forward monotone: derived from inverse monotone + bijectivity.
  -- If x ≤ y and e y < e x, then y = e.symm(e y) ≤ e.symm(e x) = x, so x = y,
  -- contradicting e y < e x.
  have h_fwd_mono : Monotone e := by
    intro x y hxy
    rw [not_lt.symm]
    intro h_abs
    have h1 : e.symm (e y) ≤ e.symm (e x) := h_inv_mono (le_of_lt h_abs)
    simp only [Equiv.symm_apply_apply] at h1
    exact absurd (le_antisymm hxy h1 ▸ h_abs) (lt_irrefl _)
  let f : M.carrier ≃o S.carrier := Equiv.toOrderIso e h_fwd_mono h_inv_mono
  -- Step 4: Apply k_equiv_of_iso
  exact k_equiv_of_iso sig k M _ f (fun p x => Iff.rfl)

/-! ### Shift-and-Glue Helpers -/

/--
Cumulative offset for ℤ-indexed bounded integer intervals.
For non-negative indices, sums sizes from 0 to i-1.
For negative indices, negates the sum of sizes from i to -1.
-/
private noncomputable def cumulativeOffset (sz : ℤ → ℕ) : ℤ → ℤ :=
  fun i =>
    if h : i ≥ 0 then
      Finset.sum (Finset.Ico 0 i) (fun j => (sz j : ℤ))
    else
      -(Finset.sum (Finset.Ico i 0) (fun j => (sz j : ℤ)))

private theorem cumulativeOffset_zero (sz : ℤ → ℕ) : cumulativeOffset sz 0 = 0 := by
  simp [cumulativeOffset]

private theorem cumulativeOffset_step (sz : ℤ → ℕ) (i : ℤ) :
    cumulativeOffset sz (i + 1) = cumulativeOffset sz i + ↑(sz i) := by
  simp only [cumulativeOffset]
  by_cases h0 : i ≥ 0
  · have h1 : i + 1 ≥ 0 := by omega
    simp only [show (i ≥ 0) = True from eq_true h0, show (i + 1 ≥ 0) = True from eq_true h1,
      ↓reduceDIte]
    rw [show Finset.Ico 0 (i + 1) = (Finset.Ico 0 i) ∪ {i} from by
      ext j; simp [Finset.mem_Ico]; omega]
    rw [Finset.sum_union (by
      rw [Finset.disjoint_singleton_right]; simp [Finset.mem_Ico])]
    simp
  · push_neg at h0
    by_cases h1 : i + 1 ≥ 0
    · have hi_eq : i = -1 := by omega
      subst hi_eq
      simp only [show ¬((-1 : ℤ) ≥ 0) from by omega, show ((-1 : ℤ) + 1 ≥ 0) from by omega,
        ↓reduceDIte, show Finset.Ico (0 : ℤ) 0 = ∅ from Finset.Ico_self 0,
        Finset.sum_empty, show Finset.Ico (-1 : ℤ) 0 = {-1} from by
          ext j; simp [Finset.mem_Ico]; omega]
      simp
    · have hi_neg : ¬(i ≥ 0) := by omega
      have hi1_neg : ¬(i + 1 ≥ 0) := by omega
      simp only [show (i ≥ 0) = False from eq_false hi_neg,
        show (i + 1 ≥ 0) = False from eq_false hi1_neg, ↓reduceDIte]
      rw [show Finset.Ico i 0 = {i} ∪ Finset.Ico (i + 1) 0 from by
        ext j; simp [Finset.mem_Ico]; omega]
      rw [Finset.sum_union (by
        rw [Finset.disjoint_singleton_left]; simp [Finset.mem_Ico])]
      simp only [Finset.sum_singleton]; ring

private theorem cumulativeOffset_strictMono (sz : ℤ → ℕ) (h_pos : ∀ i, 0 < sz i) :
    StrictMono (cumulativeOffset sz) := by
  apply strictMono_int_of_lt_succ
  intro i
  rw [cumulativeOffset_step]
  linarith [Int.natCast_pos.mpr (h_pos i)]

/--
Transfer "has max/min" from source structures to Z-interval witnesses.
Given `ms i` has max and min, and `ms i ~_{k+2} (witnesses i).toOrdered sig`,
the witnesses also have `lo = some _` and `hi = some _`.
-/
private theorem witness_bounded (sig : MonadicSignature) (k'' : ℕ)
    (ms : ℤ → OrderedMonadicStructure sig)
    (h_good : ∀ i : ℤ, good sig (k'' + 2) (ms i))
    (h_has_max : ∀ i : ℤ, ∃ m : (ms i).carrier, ∀ x, x ≤ m)
    (h_has_min : ∀ i : ℤ, ∃ m : (ms i).carrier, ∀ x, m ≤ x)
    (i : ℤ) :
    (∃ v, (choose_good_witness sig (k'' + 2) ms h_good i).hi = some v) ∧
    (∃ v, (choose_good_witness sig (k'' + 2) ms h_good i).lo = some v) := by
  let witnesses := choose_good_witness sig (k'' + 2) ms h_good
  have h_equiv := choose_good_witness_spec sig (k'' + 2) ms h_good
  -- Bridge k_equiv to nf_eval_nf iff
  have h_same_nf : ∀ nf : NormalForm sig (k'' + 2) 0,
      nf_eval_nf (ms i) (k'' + 2) 0 Fin.elim0 nf ↔
      nf_eval_nf ((witnesses i).toOrdered sig) (k'' + 2) 0 Fin.elim0 nf := by
    intro nf; have h := congr_fun (h_equiv i) nf; simp [k_type_of] at h; exact_mod_cast h
  -- Define "has max" and "has min" sentences
  let has_max_sent : MonadicSentence sig := .ex (.all (.not (.lt 1 0)))
  let has_min_sent : MonadicSentence sig := .ex (.all (.not (.lt 0 1)))
  have h_depth_max : has_max_sent.quantifier_depth ≤ k'' + 2 := by
    simp [has_max_sent, MonadicFormula.quantifier_depth]
  have h_depth_min : has_min_sent.quantifier_depth ≤ k'' + 2 := by
    simp [has_min_sent, MonadicFormula.quantifier_depth]
  -- ms(i) has max and min
  obtain ⟨mx, h_mx⟩ := h_has_max i
  obtain ⟨mn, h_mn⟩ := h_has_min i
  have h_M_has_max : eval (ms i) Fin.elim0 has_max_sent := by
    simp only [has_max_sent, eval, Fin.cons]; exact ⟨mx, fun y => not_lt.mpr (h_mx y)⟩
  have h_M_has_min : eval (ms i) Fin.elim0 has_min_sent := by
    simp only [has_min_sent, eval, Fin.cons]; exact ⟨mn, fun y => not_lt.mpr (h_mn y)⟩
  -- Transfer to witnesses
  have h_W_has_max := (doets_lemma_1_1 (k'' + 2) 0 has_max_sent h_depth_max _ _ Fin.elim0 Fin.elim0 h_same_nf).mp h_M_has_max
  have h_W_has_min := (doets_lemma_1_1 (k'' + 2) 0 has_min_sent h_depth_min _ _ Fin.elim0 Fin.elim0 h_same_nf).mp h_M_has_min
  simp only [has_max_sent, has_min_sent, eval, Fin.cons] at h_W_has_max h_W_has_min
  obtain ⟨⟨z_hi, hz_hi⟩, h_max⟩ := h_W_has_max
  obtain ⟨⟨z_lo, hz_lo⟩, h_min⟩ := h_W_has_min
  constructor
  · -- hi = some _
    cases h_hi : (witnesses i).hi with
    | some v => exact ⟨v, rfl⟩
    | none =>
      exfalso
      have h_in : (witnesses i).lo.elim True (· ≤ z_hi + 1) ∧
          (witnesses i).hi.elim True ((z_hi + 1) ≤ ·) := by
        refine ⟨?_, by simp [h_hi, Option.elim]⟩
        have := hz_hi.1; cases h_lo : (witnesses i).lo with
        | none => simp [Option.elim]
        | some l => simp only [h_lo, Option.elim] at this ⊢; omega
      exact h_max ⟨z_hi + 1, h_in⟩ (by omega : z_hi < z_hi + 1)
  · -- lo = some _
    cases h_lo : (witnesses i).lo with
    | some v => exact ⟨v, rfl⟩
    | none =>
      exfalso
      have h_in : (witnesses i).lo.elim True (· ≤ z_lo - 1) ∧
          (witnesses i).hi.elim True ((z_lo - 1) ≤ ·) := by
        refine ⟨by simp [h_lo, Option.elim], ?_⟩
        have := hz_lo.2; cases h_hi : (witnesses i).hi with
        | none => simp [Option.elim]
        | some h => simp only [h_hi, Option.elim] at this ⊢; omega
      exact h_min ⟨z_lo - 1, h_in⟩ (by omega : z_lo - 1 < z_lo)

/--
Every integer lies in exactly one piece `[c(i), c(i+1))` of the cumulative offset.
-/
private theorem cumulativeOffset_covers (sz : ℤ → ℕ) (h_pos : ∀ i, 0 < sz i)
    (n : ℤ) : ∃ i : ℤ, cumulativeOffset sz i ≤ n ∧ n < cumulativeOffset sz (i + 1) := by
  have h_mono := cumulativeOffset_strictMono sz h_pos
  -- c(0) = 0. We handle the two halves: n ≥ 0 and n < 0.
  -- For any direction, since c is strictly increasing and unbounded, n must lie in some interval.
  -- We use the fact that c grows by at least 1 at each step.
  have h_step_pos : ∀ j, cumulativeOffset sz j < cumulativeOffset sz (j + 1) := by
    intro j; rw [cumulativeOffset_step]; linarith [Int.natCast_pos.mpr (h_pos j)]
  -- Find lower bound: some i₀ with c(i₀) ≤ n
  have h_exists_lo : ∃ i₀ : ℤ, cumulativeOffset sz i₀ ≤ n := by
    by_contra h_all; push_neg at h_all
    -- All c(i) > n, but c(0) = 0, so n < 0.
    -- As i decreases, c(i) decreases strictly. Since c(i) > n for all i,
    -- and c decreases by at least 1 per step going negative, we need
    -- c(-(n+1)) ≤ c(0) - (n+1) = -(n+1) ≤ n if n < -1... but c(i) > n for all i.
    -- Actually, let's use the Archimedean property more carefully.
    -- c(i) - c(i-1) = sz(i-1) ≥ 1 for all i, so c(i) ≤ c(0) + i = i for i ≥ 0
    -- and c(i) = c(0) - sum_{j=i}^{-1} sz(j) ≤ -|i| for i < 0.
    -- So for i < 0, c(i) ≤ i. Take i₀ = n, then c(n) ≤ n, contradiction.
    -- More precisely: c(-m) ≤ -m for m ≥ 0 (by induction).
    have h_neg : ∀ m : ℕ, cumulativeOffset sz (-(m : ℤ)) ≤ -(m : ℤ) := by
      intro m; induction m with
      | zero => simp [cumulativeOffset_zero]
      | succ m ih =>
        have h1 : cumulativeOffset sz (-(↑(m + 1) : ℤ)) <
            cumulativeOffset sz (-(↑(m + 1) : ℤ) + 1) := h_step_pos _
        have h2 : -(↑(m + 1) : ℤ) + 1 = -(↑m : ℤ) := by omega
        rw [h2] at h1; omega
    -- Take i₀ with c(i₀) ≤ n. We need c(-m) ≤ n for some m.
    -- Since c(-m) ≤ -m, take m large enough that -m ≤ n.
    have h_n_neg : n < 0 := by linarith [h_all 0, cumulativeOffset_zero sz]
    have := h_neg n.natAbs
    have h_key : -(n.natAbs : ℤ) = n := by omega
    rw [h_key] at this
    exact absurd this (not_le.mpr (h_all n))
  -- Find upper bound: some i₁ with n < c(i₁)
  have h_exists_hi : ∃ i₁ : ℤ, n < cumulativeOffset sz i₁ := by
    -- c(m) ≥ m for m ≥ 0 (by induction using c(m+1) ≥ c(m) + 1)
    have h_pos_growth : ∀ m : ℕ, (m : ℤ) ≤ cumulativeOffset sz (m : ℤ) := by
      intro m; induction m with
      | zero => simp [cumulativeOffset_zero]
      | succ m ih =>
        have h := h_step_pos (m : ℤ)
        have h2 : (↑(m + 1) : ℤ) = ↑m + 1 := by push_cast; ring
        rw [show cumulativeOffset sz ↑(m + 1) = cumulativeOffset sz (↑m + 1) from by rw [h2]]
        omega
    exact ⟨(n + 1).toNat, by
      have := h_pos_growth (n + 1).toNat
      have h1 : ((n + 1).toNat : ℤ) ≥ n + 1 := Int.toNat_le.mp le_rfl
      omega⟩
  -- Now use find_last_index_below with lo=i₀, hi=i₁
  obtain ⟨i₀, hi₀⟩ := h_exists_lo
  obtain ⟨i₁, hi₁⟩ := h_exists_hi
  obtain ⟨i, _, h_le, h_lt⟩ := find_last_index_below (cumulativeOffset sz)
    h_mono n i₀ i₁ hi₀ hi₁
  exact ⟨i, h_le, h_lt⟩

/--
The piece index for a given integer under cumulative offset is unique.
-/
private theorem cumulativeOffset_unique_piece (sz : ℤ → ℕ) (h_pos : ∀ i, 0 < sz i)
    (n : ℤ) (i j : ℤ) (hi : cumulativeOffset sz i ≤ n ∧ n < cumulativeOffset sz (i + 1))
    (hj : cumulativeOffset sz j ≤ n ∧ n < cumulativeOffset sz (j + 1)) : i = j := by
  have h_mono := cumulativeOffset_strictMono sz h_pos
  by_contra h_ne
  rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
  · -- i < j, so i + 1 ≤ j, so c(i+1) ≤ c(j) ≤ n < c(i+1)
    have := h_mono.monotone (show i + 1 ≤ j from Int.add_one_le_iff.mpr h_lt)
    linarith [hi.2, hj.1]
  · -- j < i, symmetric
    have := h_mono.monotone (show j + 1 ≤ i from Int.add_one_le_iff.mpr h_gt)
    linarith [hj.2, hi.1]

/--
An ordered sum of good structures indexed by ℤ, where each component has both
a maximum and minimum element, is itself good.

This is the "shift-and-glue" step from Reynolds Lemma 16. Each good component
ms(i) has a Z-interval witness Z_i. By doets_lemma_1_4, orderedSum ms ~k
orderedSum (Z_i.toOrdered). Since each Z_i inherits boundedness from ms(i)
(at k ≥ 2 via "has max/min" expressibility; at k ≤ 1 via good_one), the
concatenation of bounded Z-intervals indexed by ℤ is order-isomorphic to a
single unbounded Z-interval (the "shift-and-glue" construction), hence good.
-/
private theorem ordered_sum_of_good_bounded_is_good (sig : MonadicSignature) (k : Nat)
    (ms : ℤ → OrderedMonadicStructure sig)
    (h_good : ∀ i : ℤ, good sig k (ms i))
    (h_has_max : ∀ i : ℤ, ∃ m : (ms i).carrier, ∀ x, x ≤ m)
    (h_has_min : ∀ i : ℤ, ∃ m : (ms i).carrier, ∀ x, m ≤ x) :
    good sig k (orderedSum sig ℤ ms) := by
  cases k with
  | zero =>
    -- At depth 0, all structures have the same 0-type (AtomKind sig 0 is empty)
    refine ⟨⟨some 0, some 0, fun _ _ => True⟩, ?_⟩
    unfold k_equiv k_type_of; funext nf; simp only [decide_eq_decide]
    have h_empty : IsEmpty (AtomKind sig 0) :=
      ⟨fun a => match a with | .pred _ i => Fin.elim0 i | .order i _ _ => Fin.elim0 i⟩
    constructor <;> intro _ a <;> exact h_empty.elim a
  | succ k' =>
    cases k' with
    | zero =>
      -- At depth 1, all structures are good (good_one)
      exact good_one sig (orderedSum sig ℤ ms)
    | succ k'' =>
      -- At depth k''+2 ≥ 2: use doets_lemma_1_4 + shift-and-glue on witnesses.
      -- Each ms(i) has max and min. The witnesses Z_i inherit boundedness via
      -- doets_lemma_1_1 (transferring "has max/min" sentences at depth 2 ≤ k).
      -- The concatenation of bounded Z-intervals indexed by ℤ is order-isomorphic
      -- to ℤ via cumulative-offset shift-and-glue, hence good.
      -- NOTE: The SuccOrder/PredOrder/IsSuccArchimedean instances on the witness
      -- side (needed for orderIsoIntOfLinearSuccPredArch) are safe: the concatenated
      -- Z-intervals are explicitly integer-like by construction.
      -- Get Z-interval witnesses
      let witnesses := choose_good_witness sig (k'' + 2) ms h_good
      have h_equiv := choose_good_witness_spec sig (k'' + 2) ms h_good
      -- orderedSum ms ~k orderedSum witnesses via doets_lemma_1_4
      let wit_structs := fun i => (witnesses i).toOrdered sig
      have h_sum_equiv : k_equiv sig (k'' + 2) (orderedSum sig ℤ ms)
          (orderedSum sig ℤ wit_structs) :=
        doets_lemma_1_4 sig (k'' + 2) ℤ ms wit_structs h_equiv
      -- The ordered sum of bounded Z-interval witnesses is good
      -- (shift-and-glue: concatenation of bounded ℤ-intervals indexed by ℤ ≃o ℤ)
      have h_wit_good : good sig (k'' + 2) (orderedSum sig ℤ wit_structs) := by
        -- Shift-and-glue: each witness is bounded, build OrderIso to ℤ.
        -- Step 1: Each witness is bounded.
        have h_bnd := witness_bounded sig k'' ms h_good h_has_max h_has_min
        -- Step 2: Extract bounds and prove lo ≤ hi.
        classical
        -- Use witness_bounded + transferred has_max to get lo_i ≤ hi_i.
        -- First establish nonemptiness of each witness by transferring "has max" sentence.
        have h_lo_le_hi : ∀ i, ∃ (lo_v hi_v : ℤ),
            (witnesses i).lo = some lo_v ∧ (witnesses i).hi = some hi_v ∧ lo_v ≤ hi_v := by
          intro i
          obtain ⟨⟨hi_v, h_hi⟩, ⟨lo_v, h_lo⟩⟩ := h_bnd i
          refine ⟨lo_v, hi_v, h_lo, h_hi, ?_⟩
          -- Need lo_v ≤ hi_v. Transfer "∃x.∀y.¬(x<y)" from ms i to get witness in carrier.
          have h_same_nf : ∀ nf : NormalForm sig (k'' + 2) 0,
              nf_eval_nf (ms i) (k'' + 2) 0 Fin.elim0 nf ↔
              nf_eval_nf ((witnesses i).toOrdered sig) (k'' + 2) 0 Fin.elim0 nf := by
            intro nf; have hh := congr_fun (h_equiv i) nf
            simp [k_type_of] at hh; exact_mod_cast hh
          let has_max_sent : MonadicSentence sig := .ex (.all (.not (.lt 1 0)))
          have h_depth : has_max_sent.quantifier_depth ≤ k'' + 2 := by
            simp [has_max_sent, MonadicFormula.quantifier_depth]
          obtain ⟨mx, h_mx⟩ := h_has_max i
          have h_M : eval (ms i) Fin.elim0 has_max_sent := by
            simp only [has_max_sent, eval, Fin.cons]
            exact ⟨mx, fun y => not_lt.mpr (h_mx y)⟩
          have h_W := (doets_lemma_1_1 (k'' + 2) 0 has_max_sent h_depth _ _
            Fin.elim0 Fin.elim0 h_same_nf).mp h_M
          simp only [has_max_sent, eval, Fin.cons] at h_W
          obtain ⟨⟨z, hz⟩, _⟩ := h_W
          -- hz : lo.elim True (· ≤ z) ∧ hi.elim True (z ≤ ·) with lo = some lo_v, hi = some hi_v
          have hz1 : lo_v ≤ z := by
            have := hz.1; rw [show (witnesses i).lo = some lo_v from h_lo] at this
            simp [Option.elim] at this; exact this
          have hz2 : z ≤ hi_v := by
            have := hz.2; rw [show (witnesses i).hi = some hi_v from h_hi] at this
            simp [Option.elim] at this; exact this
          exact le_trans hz1 hz2
        -- Extract lo, hi as functions
        let lo_val : ℤ → ℤ := fun i => (h_lo_le_hi i).choose
        let hi_val : ℤ → ℤ := fun i => (h_lo_le_hi i).choose_spec.choose
        have h_specs : ∀ i, (witnesses i).lo = some (lo_val i) ∧
            (witnesses i).hi = some (hi_val i) ∧ lo_val i ≤ hi_val i :=
          fun i => (h_lo_le_hi i).choose_spec.choose_spec
        -- Step 3: Define size function and cumulative offset
        let sz : ℤ → ℕ := fun i => (hi_val i - lo_val i + 1).toNat
        have h_sz_pos : ∀ i, 0 < sz i := by
          intro i; show 0 < (hi_val i - lo_val i + 1).toNat
          exact Int.pos_iff_toNat_pos.mp (by have := (h_specs i).2.2; omega)
        -- Step 4: Build the Z-interval witness via shift-and-glue
        -- Use classical choice to define the inverse map (piece lookup)
        let piece_of : ℤ → ℤ := fun n' => (cumulativeOffset_covers sz h_sz_pos n').choose
        have h_piece_spec : ∀ n', cumulativeOffset sz (piece_of n') ≤ n' ∧
            n' < cumulativeOffset sz (piece_of n' + 1) :=
          fun n' => (cumulativeOffset_covers sz h_sz_pos n').choose_spec
        let Z_result : ZIntervalStructure sig := {
          lo := none
          hi := none
          interp := fun p n' => (witnesses (piece_of n')).interp p
            (lo_val (piece_of n') + (n' - cumulativeOffset sz (piece_of n')))
        }
        refine ⟨Z_result, ?_⟩
        -- Step 5: Build OrderIso
        -- Forward: ⟨i, z⟩ ↦ ⟨c(i) + (z - lo_i), trivial⟩
        -- Inverse: ⟨n', _⟩ ↦ ⟨piece_of n', lo + (n' - c(piece_of n'))⟩
        -- Helper: membership in witness carrier from lo/hi bounds
        have h_mem : ∀ i (z : ℤ), lo_val i ≤ z → z ≤ hi_val i →
            (witnesses i).lo.elim True (· ≤ z) ∧ (witnesses i).hi.elim True (z ≤ ·) := by
          intro i z hlz hzh
          constructor
          · rw [(h_specs i).1]; exact hlz
          · rw [(h_specs i).2.1]; exact hzh
        -- Inverse element is in carrier
        have h_inv_mem : ∀ n', lo_val (piece_of n') ≤ lo_val (piece_of n') +
            (n' - cumulativeOffset sz (piece_of n')) ∧
            lo_val (piece_of n') + (n' - cumulativeOffset sz (piece_of n')) ≤
            hi_val (piece_of n') := by
          intro n'
          have hp := h_piece_spec n'
          have hs := cumulativeOffset_step sz (piece_of n')
          constructor
          · omega
          · -- n' < c(piece+1) = c(piece) + sz(piece)
            -- lo + (n' - c) ≤ lo + (c + sz - 1 - c) = lo + sz - 1 = lo + (hi - lo + 1) - 1 = hi
            have h_sz_eq : (sz (piece_of n') : ℤ) = hi_val (piece_of n') - lo_val (piece_of n') + 1 := by
              simp only [sz]; rw [Int.toNat_of_nonneg (by have := (h_specs (piece_of n')).2.2; omega)]
            omega
        -- Build the Equiv using Equiv.mk
        let fwd_val : (Σ i : ℤ, (wit_structs i).carrier) → ℤ :=
          fun ⟨i, ⟨z, _⟩⟩ => cumulativeOffset sz i + (z - lo_val i)
        let inv_val : ℤ → (Σ i : ℤ, (wit_structs i).carrier) :=
          fun n' =>
            let i := piece_of n'
            ⟨i, ⟨lo_val i + (n' - cumulativeOffset sz i),
              h_mem i _ (h_inv_mem n').1 (h_inv_mem n').2⟩⟩
        -- Build the forward as map to intervalCarrier
        let fwd_ic : (orderedSum sig ℤ wit_structs).carrier → Z_result.intervalCarrier :=
          fun x => ⟨fwd_val x, trivial, trivial⟩
        let inv_ic : Z_result.intervalCarrier → (orderedSum sig ℤ wit_structs).carrier :=
          fun ⟨n', _⟩ => inv_val n'
        have h_left : ∀ x, inv_ic (fwd_ic x) = x := by
          intro ⟨i, ⟨z, hz⟩⟩
          simp only [fwd_ic, inv_ic, fwd_val, inv_val]
          -- piece_of (c(i) + (z - lo_i)) = i
          have hz_bounds : lo_val i ≤ z ∧ z ≤ hi_val i := by
            simp [(h_specs i).1, (h_specs i).2.1, Option.elim] at hz; exact hz
          have h_n_in : cumulativeOffset sz i ≤ cumulativeOffset sz i + (z - lo_val i) ∧
              cumulativeOffset sz i + (z - lo_val i) < cumulativeOffset sz (i + 1) := by
            constructor
            · omega
            · rw [cumulativeOffset_step]; simp only [sz]
              have := (h_specs i).2.2; omega
          have h_pi := cumulativeOffset_unique_piece sz h_sz_pos
            (cumulativeOffset sz i + (z - lo_val i)) (piece_of _) i
            (h_piece_spec _) h_n_in
          -- Use Sigma.eq_iff to handle dependent equality
          -- piece_of(c(i)+(z-lo_i)) = i by h_pi
          -- After substituting, second components have equal values (omega)
          -- piece_of(c(i)+(z-lo_i)) = i (h_pi) and lo_i + (c(i)+(z-lo_i) - c(i)) = z (omega).
          -- Since fwd_val is injective (strictly monotone), it suffices to show
          -- fwd_val (inv_ic (fwd_ic ⟨i, ⟨z, hz⟩⟩)) = fwd_val ⟨i, ⟨z, hz⟩⟩
          -- and then use injectivity.
          have h_fwd_inj : Function.Injective fwd_val := by
            intro ⟨a, ⟨va, hva⟩⟩ ⟨b, ⟨vb, hvb⟩⟩ h_eq
            simp only [fwd_val] at h_eq
            -- If a = b, then va = vb by h_eq. If a ≠ b, fwd_val is strict mono gives contradiction.
            by_cases hab : a = b
            · subst hab; congr 1; exact Subtype.ext (show va = vb by omega)
            · exfalso
              rcases lt_or_gt_of_ne hab with h | h
              · have hb_a : lo_val a ≤ va ∧ va ≤ hi_val a := by
                  constructor
                  · have := hva.1; rw [(h_specs a).1] at this; exact this
                  · have := hva.2; rw [(h_specs a).2.1] at this; exact this
                have : cumulativeOffset sz a + (va - lo_val a) < cumulativeOffset sz (a + 1) := by
                  rw [cumulativeOffset_step]; simp only [sz]
                  rw [Int.toNat_of_nonneg (by have := (h_specs a).2.2; omega)]; omega
                have : cumulativeOffset sz (a + 1) ≤ cumulativeOffset sz b :=
                  (cumulativeOffset_strictMono sz h_sz_pos).monotone (Int.add_one_le_iff.mpr h)
                have hb_b : lo_val b ≤ vb := by
                  have := hvb.1; rw [(h_specs b).1] at this; exact this
                omega
              · have hb_b : lo_val b ≤ vb ∧ vb ≤ hi_val b := by
                  constructor
                  · have := hvb.1; rw [(h_specs b).1] at this; exact this
                  · have := hvb.2; rw [(h_specs b).2.1] at this; exact this
                have : cumulativeOffset sz b + (vb - lo_val b) < cumulativeOffset sz (b + 1) := by
                  rw [cumulativeOffset_step]; simp only [sz]
                  rw [Int.toNat_of_nonneg (by have := (h_specs b).2.2; omega)]; omega
                have : cumulativeOffset sz (b + 1) ≤ cumulativeOffset sz a :=
                  (cumulativeOffset_strictMono sz h_sz_pos).monotone (Int.add_one_le_iff.mpr h)
                have hb_a : lo_val a ≤ va := by
                  have := hva.1; rw [(h_specs a).1] at this; exact this
                omega
          apply h_fwd_inj
          show fwd_val (inv_val (cumulativeOffset sz i + (z - lo_val i))) =
            cumulativeOffset sz i + (z - lo_val i)
          simp only [fwd_val, inv_val]
          rw [h_pi]; omega
        have h_right : ∀ y, fwd_ic (inv_ic y) = y := by
          intro ⟨n', hn'⟩
          apply Subtype.ext
          show cumulativeOffset sz (piece_of n') +
            (lo_val (piece_of n') + (n' - cumulativeOffset sz (piece_of n')) -
              lo_val (piece_of n')) = n'
          omega
        let e : (orderedSum sig ℤ wit_structs).carrier ≃ Z_result.intervalCarrier := {
          toFun := fwd_ic
          invFun := inv_ic
          left_inv := h_left
          right_inv := h_right
        }
        -- Monotonicity of e (forward)
        have h_fwd_mono : Monotone e := by
          intro ⟨i₁, ⟨z₁, hz₁⟩⟩ ⟨i₂, ⟨z₂, hz₂⟩⟩ h_le
          show cumulativeOffset sz i₁ + (z₁ - lo_val i₁) ≤
            cumulativeOffset sz i₂ + (z₂ - lo_val i₂)
          have hb₁ : lo_val i₁ ≤ z₁ ∧ z₁ ≤ hi_val i₁ := by
            simp [(h_specs i₁).1, (h_specs i₁).2.1, Option.elim] at hz₁; exact hz₁
          have hb₂ : lo_val i₂ ≤ z₂ ∧ z₂ ≤ hi_val i₂ := by
            simp [(h_specs i₂).1, (h_specs i₂).2.1, Option.elim] at hz₂; exact hz₂
          -- h_le is in Sigma.Lex order
          rcases Sigma.Lex.le_def.mp h_le with h_lt | ⟨h_eq, h_z_le⟩
          · -- i₁ < i₂
            have h1 : cumulativeOffset sz i₁ + (z₁ - lo_val i₁) <
                cumulativeOffset sz (i₁ + 1) := by
              rw [cumulativeOffset_step]; simp only [sz]
              have := (h_specs i₁).2.2; omega
            have h2 : cumulativeOffset sz (i₁ + 1) ≤ cumulativeOffset sz i₂ :=
              (cumulativeOffset_strictMono sz h_sz_pos).monotone
                (Int.add_one_le_iff.mpr h_lt)
            omega
          · -- i₁ = i₂ and z₁ ≤ z₂
            cases h_eq
            -- h_z_le : ⟨z₁, _⟩ ≤ ⟨z₂, _⟩ in the subtype order, i.e., z₁ ≤ z₂
            have : z₁ ≤ z₂ := h_z_le
            omega
        -- Monotonicity of e.symm (inverse)
        have h_inv_mono : Monotone e.symm := by
          intro a b (hab : a ≤ b)
          -- If inv(a) > inv(b), then e(inv(a)) > e(inv(b)) by monotonicity of e,
          -- i.e., a > b, contradicting hab.
          -- Equivalently: show ¬(inv(b) < inv(a))
          show e.symm a ≤ e.symm b
          by_contra h_not
          push_neg at h_not  -- h_not : e.symm b < e.symm a
          have h1 : e (e.symm b) ≤ e (e.symm a) := h_fwd_mono (le_of_lt h_not)
          simp only [Equiv.apply_symm_apply] at h1
          -- h1 : b ≤ a, combined with hab gives a = b
          exact absurd (le_antisymm hab h1 ▸ h_not) (lt_irrefl _)
        let fullIso := Equiv.toOrderIso e h_fwd_mono h_inv_mono
        apply k_equiv_of_iso sig (k'' + 2) _ _ fullIso
        -- Predicate preservation: show interp agrees across the isomorphism
        intro p ⟨i, ⟨z, hz⟩⟩
        -- LHS: (orderedSum sig ℤ wit_structs).interp p ⟨i, ⟨z, hz⟩⟩ = (witnesses i).interp p z
        -- RHS: Z_result.interp p (c(i) + (z - lo_i)) = (witnesses (piece_of ...)).interp p (lo + (n - c))
        -- Need: piece_of (c(i) + (z - lo_i)) = i and lo + (n - c) = z
        show (witnesses i).interp p z ↔
          (witnesses (piece_of (cumulativeOffset sz i + (z - lo_val i)))).interp p
            (lo_val (piece_of (cumulativeOffset sz i + (z - lo_val i))) +
              (cumulativeOffset sz i + (z - lo_val i) -
                cumulativeOffset sz (piece_of (cumulativeOffset sz i + (z - lo_val i)))))
        have hz_bounds : lo_val i ≤ z ∧ z ≤ hi_val i := by
          simp [(h_specs i).1, (h_specs i).2.1, Option.elim] at hz; exact hz
        set n' := cumulativeOffset sz i + (z - lo_val i) with hn'_def
        have h_n_in : cumulativeOffset sz i ≤ n' ∧ n' < cumulativeOffset sz (i + 1) := by
          constructor
          · simp [n']; omega
          · rw [cumulativeOffset_step]; simp only [sz, n']
            have := (h_specs i).2.2; omega
        have h_pi : piece_of n' = i :=
          cumulativeOffset_unique_piece sz h_sz_pos n' _ i (h_piece_spec n') h_n_in
        rw [h_pi]
        -- lo_val i + (n' - c(i)) = z because n' = c(i) + (z - lo_val i)
        have : lo_val i + (n' - cumulativeOffset sz i) = z := by rw [hn'_def]; omega
        rw [this]
      obtain ⟨Z_final, hZ_final⟩ := h_wit_good
      exact ⟨Z_final, h_sum_equiv.trans hZ_final⟩

/--
Closed-to-half-open k-equivalence: a half-open subinterval [a, b) is good when
a < b and the order has PredOrder, because [a, b) = [a, pred(b)] which is a
closed subinterval and hence good by very_good.
-/
private theorem hoSubinterval_good_of_very_good (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [PredOrder M.carrier]
    (a b : M.carrier) (h_lt : a < b) (h_very_good : very_good sig k M) :
    good sig k (M.hoSubinterval sig a b) := by
  have h_pred_lt : Order.pred b < b := Order.pred_lt_of_not_isMin (not_isMin_of_lt h_lt)
  have h_a_le_pred : a ≤ Order.pred b := Order.le_pred_of_lt h_lt
  have h_good_closed := h_very_good a (Order.pred b) h_a_le_pred
  have h_iff : ∀ x : M.carrier, (a ≤ x ∧ x < b) ↔ (a ≤ x ∧ x ≤ Order.pred b) := by
    intro x; exact ⟨fun ⟨h1, h2⟩ => ⟨h1, Order.le_pred_of_lt h2⟩,
                    fun ⟨h1, h2⟩ => ⟨h1, lt_of_le_of_lt h2 h_pred_lt⟩⟩
  let e : (M.hoSubinterval sig a b).carrier ≃ (M.subinterval sig a (Order.pred b)).carrier :=
    { toFun := fun ⟨x, hx⟩ => ⟨x, (h_iff x).mp hx⟩
      invFun := fun ⟨x, hx⟩ => ⟨x, (h_iff x).mpr hx⟩
      left_inv := fun ⟨_, _⟩ => rfl
      right_inv := fun ⟨_, _⟩ => rfl }
  let f : (M.hoSubinterval sig a b).carrier ≃o (M.subinterval sig a (Order.pred b)).carrier :=
    Equiv.toOrderIso e (fun _ _ h => h) (fun _ _ h => h)
  have h_k_equiv := k_equiv_of_iso sig k (M.hoSubinterval sig a b)
    (M.subinterval sig a (Order.pred b)) f (fun _ _ => Iff.rfl)
  obtain ⟨Z, hZ⟩ := h_good_closed
  exact ⟨Z, h_k_equiv.trans hZ⟩

/--
Reynolds Lemma 16: If M is a countable discrete linear order without endpoints and
every subinterval of M is good (very_good), then M itself is good.

The proof constructs a cofinal decomposition of M into half-open pieces [a(i), a(i+1))
which partition M disjointly (unlike closed intervals which overlap at boundaries).
M is order-isomorphic to the ordered sum of these pieces. Each half-open piece
is good (via PredOrder: [a(i), a(i+1)) = [a(i), pred(a(i+1))], a closed subinterval
that is good by very_good). The ordered sum of good bounded structures is itself good
(by the shift-and-glue OrderIso + doets_lemma_1_4 construction).

PredOrder is required to convert half-open pieces to closed subintervals for very_good.
-/
theorem very_good_implies_good (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [Nonempty M.carrier] [PredOrder M.carrier]
    (_h_countable : Countable M.carrier) (h_very_good : very_good sig k M) :
    good sig k M := by
  -- Step 1: Construct cofinal sequence
  obtain ⟨a, h_mono, h_cofinal_closed⟩ := @exists_cofinal_sequence M.carrier M.carrier_order
    _h_countable inferInstance inferInstance inferInstance
  -- Step 1b: Derive half-open cofinality from closed cofinality
  have h_cofinal : ∀ x : M.carrier, ∃ i : ℤ, a i ≤ x ∧ x < a (i + 1) := by
    intro x
    obtain ⟨i, hi_le, hi_le'⟩ := h_cofinal_closed x
    by_cases h : x < a (i + 1)
    · exact ⟨i, hi_le, h⟩
    · push_neg at h
      have h_eq : x = a (i + 1) := le_antisymm hi_le' h
      exact ⟨i + 1, h_eq ▸ le_refl _, h_eq ▸ h_mono (by omega : i + 1 < i + 1 + 1)⟩
  -- Step 2: Define the half-open pieces
  let pieces := fun i : ℤ => M.hoSubinterval sig (a i) (a (i + 1))
  -- Step 3: Each piece is good by very_good + PredOrder
  have h_pieces_good : ∀ i : ℤ, good sig k (pieces i) := fun i =>
    hoSubinterval_good_of_very_good sig k M (a i) (a (i + 1))
      (h_mono (Int.lt_add_one_iff.mpr le_rfl)) h_very_good
  -- Step 4: M ~k orderedSum ℤ pieces (cofinal decomposition via order isomorphism)
  have h_decomp : k_equiv sig k M (orderedSum sig ℤ pieces) :=
    cofinal_decomposition_k_equiv sig k M a h_mono h_cofinal
  -- Step 5: Each piece has max and min
  have h_has_max : ∀ i : ℤ, ∃ m : (pieces i).carrier, ∀ x, x ≤ m := by
    intro i
    have h_lt : a i < a (i + 1) := h_mono (Int.lt_add_one_iff.mpr le_rfl)
    have h_pred_lt : Order.pred (a (i + 1)) < a (i + 1) :=
      Order.pred_lt_of_not_isMin (not_isMin_of_lt h_lt)
    have h_a_le_pred : a i ≤ Order.pred (a (i + 1)) := Order.le_pred_of_lt h_lt
    refine ⟨⟨Order.pred (a (i + 1)), h_a_le_pred, h_pred_lt⟩, ?_⟩
    intro ⟨x, hx⟩; exact Order.le_pred_of_lt hx.2
  have h_has_min : ∀ i : ℤ, ∃ m : (pieces i).carrier, ∀ x, m ≤ x := by
    intro i
    have h_lt : a i < a (i + 1) := h_mono (Int.lt_add_one_iff.mpr le_rfl)
    exact ⟨⟨a i, le_refl _, h_lt⟩, fun ⟨_, hx⟩ => hx.1⟩
  -- Step 6: orderedSum pieces is good (shift-and-glue)
  have h_sum_good : good sig k (orderedSum sig ℤ pieces) :=
    ordered_sum_of_good_bounded_is_good sig k pieces h_pieces_good h_has_max h_has_min
  -- Step 7: Compose by transitivity of k-equiv
  obtain ⟨Z_final, hZ_final⟩ := h_sum_good
  exact ⟨Z_final, h_decomp.trans hZ_final⟩

/-! ## Chronicle is Good -/

-- NOTE: chronicle_is_good uses IsSuccArchimedean (via orderIsoIntOfLinearSuccPredArch)
-- which depends on succ_cofinal (sorry). It is NOT on the critical path for
-- completeness_discrete. The critical path goes through dd_countermodel_chronicle_discrete
-- (Path A), not through this function.
/--
The chronicle prior model is good at any finite depth.
-/
theorem chronicle_is_good {fc : FrameClass} (M : ChronicleAsPriorModel fc) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) (k : Nat) :
    good sig k (chronicleAsMonadicStructure M sig atomMap) := by
  haveI : Nonempty M.domain := M.domain_nonempty
  let f : M.domain ≃o ℤ := orderIsoIntOfLinearSuccPredArch
  let Z : ZIntervalStructure sig := {
    lo := none
    hi := none
    interp := fun p z => (atomMap p) ∈ M.fmcs (f.symm z)
  }
  refine ⟨Z, ?_⟩
  let val_iso : Z.intervalCarrier ≃o ℤ :=
    Equiv.toOrderIso
      { toFun := Subtype.val, invFun := fun z => ⟨z, trivial, trivial⟩,
        left_inv := by intro ⟨_, _⟩; rfl, right_inv := by intro _; rfl }
      (fun _ _ h => h) (fun _ _ h => h)
  let g : (chronicleAsMonadicStructure M sig atomMap).carrier ≃o (Z.toOrdered sig).carrier :=
    f.trans val_iso.symm
  apply k_equiv_of_iso sig k _ _ g
  intro p x
  show (atomMap p) ∈ M.fmcs x ↔ (atomMap p) ∈ M.fmcs (f.symm (f x))
  simp [OrderIso.symm_apply_apply]


/-! ## One-Class Implies Very Good -/

/--
If all points are contemporaneously equivalent (`one_class`), then the
structure is very good. The proof: `contemp_equiv a b` with `a ≤ b` gives
`very_good sig k (M.subinterval sig a b)`, which means every sub-subinterval
of [a,b] is good. In particular, [a,b] itself is good (by applying
`good_of_very_good_subinterval` with c=a, d=b).
-/
theorem one_class_implies_very_good (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    (h_one_class : ∀ (a b : M.carrier), contemp_equiv sig k M a b) :
    very_good sig k M := by
  intro a b hab
  have h_ce := h_one_class a b
  simp only [contemp_equiv, min_eq_left hab, max_eq_right hab] at h_ce
  exact good_of_very_good_subinterval sig k M a b hab h_ce a b (le_refl a) (le_refl b) hab

/-! ## Chronicle is Good (Direct via One-Class, no IsSuccArchimedean) -/

-- NOTE: chronicle_is_good_direct avoids IsSuccArchimedean but is used ONLY by
-- countermodel_discrete_reynolds (Transfer.lean:1004), which has an unsolvable sorry.
-- It is NOT on the critical path for completeness_discrete.
-- The critical path uses dd_countermodel_chronicle_discrete (Path A).
/--
The chronicle prior model is good at any finite depth, proved via the
Reynolds pipeline: `one_class` → `very_good` → `very_good_implies_good`.

This does NOT use `IsSuccArchimedean` or `orderIsoIntOfLinearSuccPredArch`.
Instead, it uses:
- `one_class` (which requires `no_gaps_discrete`)
- `one_class_implies_very_good` (sorry-free)
- `very_good_implies_good` (which uses `exists_cofinal_sequence`, needs only
  Countable + NoMaxOrder + NoMinOrder + Nonempty + PredOrder, NOT IsSuccArchimedean)

The caller must provide proofs of semantic Prior-UZ and Prior-SZ for the
chronicle monadic structure. These are discharged at the call site
(Transfer.lean) using `chronicle_temporal_truth` and the chronicle's
MCS-level Prior-UZ/SZ axioms.
-/
theorem chronicle_is_good_direct {fc : FrameClass} (M : ChronicleAsPriorModel fc) (sig : MonadicSignature)
    (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds)
    (k : Nat)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap_fwd (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ (chronicleAsMonadicStructure M sig atomMap_rev) atomMap_fwd)
    (h_prior_SZ : semantic_prior_SZ (chronicleAsMonadicStructure M sig atomMap_rev) atomMap_fwd) :
    good sig k (chronicleAsMonadicStructure M sig atomMap_rev) := by
  haveI : Nonempty M.domain := M.domain_nonempty
  let M_struct := chronicleAsMonadicStructure M sig atomMap_rev
  -- Step 1: Apply one_class via no_gaps_discrete_model_surgery (sorry-free)
  -- Inlined from one_class to bypass import cycle (GoodStructures ↔ GoodStructuresModelSurgery)
  have h_one_class : ∀ (a b : M_struct.carrier), contemp_equiv sig k M_struct a b := by
    intro a b
    by_contra h_diff
    obtain ⟨c, hac, h_not_succ⟩ := no_gaps_discrete_model_surgery sig k M_struct atomMap_fwd
      h_surj h_prior_UZ h_prior_SZ a b h_diff
    exact h_not_succ ((contemp_equiv_is_equiv sig k M_struct).trans hac
      (no_boundary_at_successor sig k M_struct c))
  -- Step 2: one_class_implies_very_good
  have h_very_good := one_class_implies_very_good sig k M_struct h_one_class
  -- Step 3: very_good_implies_good (uses Countable, NoMaxOrder, NoMinOrder, Nonempty, PredOrder)
  exact very_good_implies_good sig k M_struct M.domain_countable h_very_good

end Bimodal.Metalogic.WeakCanonical
