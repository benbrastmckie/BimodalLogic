import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.WorldHistory
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred
import FormalSystem.Metalogic.Independence.LoopingDuration

open FormalSystem.Syntax FormalSystem.Semantics
open scoped Classical

namespace Scratch511c

/-!
# Probes for E2: does `FwdRec` force periodicity?

Companion to `02_probes.lean`. `Covers`, `FwdRec` and `density_iff_fwdRec` are *copied verbatim*
from `02_probes.lean` §Probe C, because probe files are standalone and not on the Lake module
path; nothing about them is changed here.
-/

/-! ## Copied from `02_probes.lean` §Probe C (verbatim) -/

namespace Corr

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-- `s` is an immediate successor of `t` in `(D, <)`. -/
def Covers (t s : D) : Prop := t < s ∧ ∀ r : D, t < r → r < s → False

/-- The candidate correspondent (report 02 §3.2). -/
def FwdRec (F : TaskFrame D) : Prop :=
  ∀ (τ : WorldHistory F) (hτ : τ.IsTotal) (t s : D), Covers t s →
    ∀ A : F.WorldState → Prop,
      (∀ r : D, s < r → A (τ.states r (hτ r))) → A (τ.states s (hτ s))

/-- Exact per-frame correspondence for the **atomic** density schema (report 02, §3.2). -/
theorem density_iff_fwdRec (F : TaskFrame D) :
    (∀ (p : Atom) (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal → ∀ t : D,
        TruthAt M τ t ((Formula.atom p).allFuture.allFuture.imp (Formula.atom p).allFuture))
      ↔ FwdRec F := by
  constructor
  · intro h τ hτ t s hcov A hA
    let M : TaskModel F := ⟨fun w _ => A w⟩
    have hgg : TruthAt M τ t (Formula.atom (Atom.mk "p" none)).allFuture.allFuture := by
      rw [Truth.future_iff]
      intro u hu
      rw [Truth.future_iff]
      intro r hr
      have hsu : s ≤ u := by
        by_contra hlt
        exact hcov.2 u hu (lt_of_not_ge hlt)
      exact ⟨hτ r, hA r (lt_of_le_of_lt hsu hr)⟩
    have hg := h (Atom.mk "p" none) M τ hτ t hgg
    rw [Truth.future_iff] at hg
    have hx : ∃ hd : τ.domain s, M.valuation (τ.states s hd) (Atom.mk "p" none) :=
      hg s hcov.1
    obtain ⟨hd, hv⟩ := hx
    exact hv
  · intro h p M τ hτ t hgg
    rw [Truth.future_iff]
    intro s hst
    rw [Truth.future_iff] at hgg
    by_cases hmid : ∃ r : D, t < r ∧ r < s
    · obtain ⟨r, h1, h2⟩ := hmid
      have := hgg r h1
      rw [Truth.future_iff] at this
      exact this s h2
    · push_neg at hmid
      have hcov : Covers t s := ⟨hst, fun r hr1 hr2 => absurd hr2 (not_lt.mpr (hmid r hr1))⟩
      have hA : ∀ r : D, s < r → M.valuation (τ.states r (hτ r)) p := by
        intro r hr
        have := hgg s hst
        rw [Truth.future_iff] at this
        have hx : ∃ hd : τ.domain r, M.valuation (τ.states r hd) p := this r hr
        obtain ⟨hd, hv⟩ := hx
        exact hv
      exact ⟨hτ s, h τ hτ t s hcov (fun w => M.valuation w p) hA⟩

end Corr

/-! ## Probe G: the "lead" frame is legal — the permissive class works at any carrier. -/

/--
The permissive frame over an **arbitrary** nonempty carrier. `natFrame` is the `W = ℕ`
instance; every field is discharged by the same Helper-B lemmas, none of which mentions `ℕ`.

At `D = ℤ` its one-step digraph `R w u := TaskRel w 1 u` is the **complete digraph** on `W`
(every edge present, loops included). At `W = Bool` this is the full 2-shift.
-/
def freeFrame (W : Type) [Nonempty W] {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] [SuccOrder D] [NoMaxOrder D] : TaskFrame D where
  WorldState := W
  nonempty := inferInstance
  TaskRel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h; right; exact h
  comp := TaskFrame.comp_of (TaskFrame.interpolates_of_permissive fun _ _ _ => Iff.rfl)
    fun w u v x y hx hy h1 h2 => by
      cases h1 with
      | inl hxne =>
        left
        intro heq
        have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
        have h1 : 0 ≤ -x := hy_eq ▸ hy
        exact hxne (le_antisymm (neg_nonneg.mp h1) hx)
      | inr hw =>
        cases h2 with
        | inl hyne =>
          left
          intro heq
          have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
          have h1 : 0 ≤ -y := hx_eq ▸ hx
          exact hyne (le_antisymm (neg_nonneg.mp h1) hy)
        | inr hu => right; exact hw.trans hu
  serial := TaskFrame.serial_of_permissive fun _ _ _ => Iff.rfl
  limit := TaskFrame.limit_of_permissive fun _ _ _ => Iff.rfl
  spherical := TaskFrame.spherical_of_permissive fun _ _ _ => Iff.rfl
  converse := fun w d u => by
    constructor
    · intro h
      cases h with
      | inl hd => left; simp [hd]
      | inr heq => right; exact heq.symm
    · intro h
      cases h with
      | inl hnd => left; simp only [ne_eq, neg_eq_zero] at hnd; exact hnd
      | inr heq => right; exact heq.symm

/-- The one-off history `… a a a b a a a …` over the full 2-shift. -/
def blipHist : WorldHistory (freeFrame Bool (D := ℤ)) where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => decide (t = 0)
  respects_task := by
    intro s t _ _
    by_cases h : t - s = 0
    · right
      have : t = s := by omega
      subst this; rfl
    · left; exact h
  convex := fun _ _ _ _ _ _ _ => trivial

theorem blipHist_isTotal : blipHist.IsTotal := fun _ => trivial

/--
**The lead fails.** The full 2-shift *is* a legal task frame (`freeFrame Bool`), so report 02
§2's digraph reformulation is faithful here — `limit` does not exclude it. But the frame does
**not** satisfy `FwdRec`, because `FwdRec` quantifies over *all* total histories, and the walk
`… a a a b a a a …` visits `b` exactly once. So the aperiodic-but-recurrent walk is not a
counterexample to E2: E2 asks whether *every* walk being forward-recurrent forces periodicity.
-/
theorem freeFrame_bool_not_fwdRec : ¬ Corr.FwdRec (freeFrame Bool (D := ℤ)) := by
  intro h
  have hcov : Corr.Covers (-1 : ℤ) 0 := ⟨by omega, fun r h1 h2 => by omega⟩
  have := h blipHist blipHist_isTotal (-1) 0 hcov (fun b => b = false) ?_
  · simp [blipHist] at this
  · intro r hr
    show decide (r = 0) = false
    simp only [decide_eq_false_iff_not]
    omega

/-! ## Probe H: walks in a digraph — `AllRec` forces determinism, hence periodicity. -/

namespace Walk

variable {W : Type} {R : W → W → Prop}

/-- A bi-infinite walk in the digraph `R`. -/
def IsWalk (R : W → W → Prop) (σ : ℤ → W) : Prop := ∀ n : ℤ, R (σ n) (σ (n + 1))

/-- **The hypothesis under test**: every walk revisits, later, every state it occupies. -/
def AllRec (R : W → W → Prop) : Prop :=
  ∀ σ : ℤ → W, IsWalk R σ → ∀ n : ℤ, ∃ m : ℤ, n < m ∧ σ m = σ n

theorem isWalk_shift {σ : ℤ → W} (h : IsWalk R σ) (k : ℤ) :
    IsWalk R (fun n => σ (n + k)) := by
  intro n
  have h1 := h (n + k)
  have e : n + k + 1 = n + 1 + k := by ring
  rwa [e] at h1

/-- Periodic extension of a closed walk `σ 0 = σ m`. -/
def per (σ : ℤ → W) (m : ℤ) : ℤ → W := fun n => σ (n % m)

theorem per_isWalk {σ : ℤ → W} (h : IsWalk R σ) {m : ℤ} (hm : 0 < m) (hc : σ m = σ 0) :
    IsWalk R (per σ m) := by
  intro n
  show R (σ (n % m)) (σ ((n + 1) % m))
  have hk0 : 0 ≤ n % m := Int.emod_nonneg n (ne_of_gt hm)
  have hk1 : n % m < m := Int.emod_lt_of_pos n hm
  have hstep : (n + 1) % m = (n % m + 1) % m := by
    conv_rhs => rw [Int.add_emod, Int.emod_emod_of_dvd _ (dvd_refl m), ← Int.add_emod]
  by_cases hc' : n % m + 1 = m
  · rw [hstep, hc', Int.emod_self]
    have hstep2 := h (n % m)
    rw [hc', hc] at hstep2
    exact hstep2
  · have h2 : (n % m + 1) % m = n % m + 1 := Int.emod_eq_of_lt (by omega) (by omega)
    rw [hstep, h2]
    exact h (n % m)

theorem per_base (σ : ℤ → W) (m : ℤ) : per σ m 0 = σ 0 := by
  show σ (0 % m) = σ 0
  rw [Int.zero_emod]

theorem per_period (σ : ℤ → W) (m n : ℤ) : per σ m (n + m) = per σ m n := by
  show σ ((n + m) % m) = σ (n % m)
  rw [Int.add_emod_right]

theorem per_val (σ : ℤ → W) {m n : ℤ} (h0 : 0 ≤ n) (h1 : n < m) : per σ m n = σ n := by
  show σ (n % m) = σ n
  rw [Int.emod_eq_of_lt h0 h1]

/-- A **minimal closed walk** through `x`: length-minimal among all closed walks at `x`. -/
structure MinCyc (R : W → W → Prop) (x : W) where
  len : ℤ
  pos : 0 < len
  walk : ℤ → W
  isWalk : IsWalk R walk
  base : walk 0 = x
  perd : ∀ n : ℤ, walk (n + len) = walk n
  minimal : ∀ m : ℤ, 0 < m → m < len → ∀ ρ : ℤ → W, IsWalk R ρ → ρ 0 = x → ρ m ≠ x

theorem exists_minCyc (hH : AllRec R) {σ : ℤ → W} (hσ : IsWalk R σ) {x : W} (hx : σ 0 = x) :
    Nonempty (MinCyc R x) := by
  classical
  have hP : ∃ k : ℕ, 0 < k ∧ ∃ ρ : ℤ → W, IsWalk R ρ ∧ ρ 0 = x ∧ ρ (k : ℤ) = x := by
    obtain ⟨m, hm, hval⟩ := hH σ hσ 0
    refine ⟨m.toNat, by omega, σ, hσ, hx, ?_⟩
    have e : ((m.toNat : ℤ)) = m := by omega
    rw [e, hval, hx]
  obtain ⟨hlpos, ρ, hρ, hρ0, hρl⟩ := Nat.find_spec hP
  have hlZ : (0 : ℤ) < (Nat.find hP : ℤ) := by exact_mod_cast hlpos
  refine ⟨{ len := (Nat.find hP : ℤ), pos := hlZ, walk := per ρ (Nat.find hP : ℤ),
            isWalk := per_isWalk hρ hlZ (by rw [hρl, hρ0]),
            base := by rw [per_base]; exact hρ0,
            perd := fun n => per_period ρ _ n,
            minimal := ?_ }⟩
  intro m hm0 hmlt ν hν hν0 hcon
  have hlt : m.toNat < Nat.find hP := by omega
  refine Nat.find_min hP hlt ⟨by omega, ν, hν, hν0, ?_⟩
  have e : ((m.toNat : ℤ)) = m := by omega
  rw [e]; exact hcon

theorem MinCyc.walk_add_mul {x : W} (M : MinCyc R x) (n : ℤ) :
    ∀ q : ℤ, M.walk (n + M.len * q) = M.walk n := by
  intro q
  induction q using Int.induction_on with
  | zero => simp
  | succ i ih =>
      have e : n + M.len * ((i : ℤ) + 1) = (n + M.len * (i : ℤ)) + M.len := by ring
      rw [e, M.perd, ih]
  | pred i ih =>
      have e : (n + M.len * (-(i : ℤ) - 1)) + M.len = n + M.len * (-(i : ℤ)) := by ring
      have h1 := M.perd (n + M.len * (-(i : ℤ) - 1))
      rw [e] at h1
      rw [← h1, ih]

theorem MinCyc.walk_emod {x : W} (M : MinCyc R x) (k : ℤ) :
    M.walk (k % M.len) = M.walk k := by
  have h := M.walk_add_mul k (-(k / M.len))
  have e : k + M.len * (-(k / M.len)) = k % M.len := by
    rw [Int.emod_def]; ring
  rwa [e] at h

theorem exists_nonneg_eq (hH : AllRec R) {γ : ℤ → W} (hγ : IsWalk R γ) (n : ℤ) :
    ∃ k : ℤ, 0 ≤ k ∧ γ k = γ n := by
  suffices h : ∀ j : ℕ, ∀ n : ℤ, -n ≤ (j : ℤ) → ∃ k : ℤ, 0 ≤ k ∧ γ k = γ n by
    exact h (-n).toNat n (by omega)
  intro j
  induction j with
  | zero => intro n hn; exact ⟨n, by omega, rfl⟩
  | succ j ih =>
      intro n hn
      by_cases h0 : 0 ≤ n
      · exact ⟨n, h0, rfl⟩
      · obtain ⟨m, hm, hval⟩ := hH γ hγ n
        obtain ⟨k, hk0, hk⟩ := ih m (by push_cast at hn ⊢; omega)
        exact ⟨k, hk0, by rw [hk, hval]⟩

/--
**Containment.** Every state a closed walk at `x` occupies lies on the minimal cycle at `x`.

The proof grafts the closed walk's periodic extension onto the *past* of the minimal cycle's
future, and reads the conclusion off `AllRec` at the grafted point.
-/
theorem minCyc_mem (hH : AllRec R) {x : W} (M : MinCyc R x) {θ : ℤ → W} (hθ : IsWalk R θ)
    (h0 : θ 0 = x) {m : ℤ} (hm : 0 < m) (hcyc : θ m = x) {i : ℤ} (hi : 0 ≤ i) (him : i < m) :
    ∃ k : ℤ, 0 ≤ k ∧ k < M.len ∧ θ i = M.walk k := by
  classical
  have hPw : IsWalk R (per θ m) := per_isWalk hθ hm (by rw [hcyc, h0])
  have hneg1 : (-1 : ℤ) % m = m - 1 := by
    have e : (-1 : ℤ) = (m - 1) + m * (-1) := by ring
    rw [e, Int.add_mul_emod_self_left, Int.emod_eq_of_lt (by omega) (by omega)]
  set γ : ℤ → W := fun n => if n < 0 then per θ m n else M.walk n with hγdef
  have hγ : IsWalk R γ := by
    intro n
    by_cases hn : n < 0
    · by_cases hn1 : n + 1 < 0
      · simp only [hγdef, if_pos hn, if_pos hn1]; exact hPw n
      · have hn' : n = -1 := by omega
        subst hn'
        simp only [hγdef, if_pos (by omega : (-1 : ℤ) < 0),
          if_neg (by omega : ¬((-1 : ℤ) + 1 < 0))]
        have hj : per θ m (-1) = θ (m - 1) := by
          show θ ((-1 : ℤ) % m) = θ (m - 1); rw [hneg1]
        have hstep := hθ (m - 1)
        have e : m - 1 + 1 = m := by ring
        rw [e, hcyc] at hstep
        have e0 : (-1 : ℤ) + 1 = 0 := by norm_num
        rw [hj, e0, M.base]
        exact hstep
    · have hn1 : ¬(n + 1 < 0) := by omega
      simp only [hγdef, if_neg hn, if_neg hn1]
      exact M.isWalk n
  have hval : γ (i - m) = θ i := by
    have hlt : i - m < 0 := by omega
    simp only [hγdef, if_pos hlt]
    show θ ((i - m) % m) = θ i
    rw [Int.sub_emod_right, Int.emod_eq_of_lt hi him]
  obtain ⟨k, hk0, hk⟩ := exists_nonneg_eq hH hγ (i - m)
  have hkw : γ k = M.walk k := by simp only [hγdef, if_neg (by omega : ¬(k < 0))]
  refine ⟨k % M.len, Int.emod_nonneg k (ne_of_gt M.pos), Int.emod_lt_of_pos k M.pos, ?_⟩
  rw [M.walk_emod, ← hkw, hk, hval]

/--
**Determinism at a point.** If `AllRec R` holds, two walks agreeing at time `0` agree at time `1`.

This is the heart of E2: a state cannot have two distinct walk-successors.
-/
theorem succ_unique (hH : AllRec R) {σ ρ : ℤ → W} (hσ : IsWalk R σ) (hρ : IsWalk R ρ)
    (h0 : σ 0 = ρ 0) : σ 1 = ρ 1 := by
  classical
  by_contra hne
  obtain ⟨M⟩ := exists_minCyc hH hσ (rfl : σ 0 = σ 0)
  have key : ∀ θ : ℤ → W, IsWalk R θ → θ 0 = σ 0 → θ 1 ≠ M.walk 1 → False := by
    intro θ hθ hθ0 hw
    obtain ⟨m, hm, hmv⟩ := hH θ hθ 0
    have hcyc : θ m = σ 0 := by rw [hmv, hθ0]
    have hstep0 : R (σ 0) (θ 1) := by
      have h1 := hθ 0
      rw [show (0 : ℤ) + 1 = 1 by norm_num] at h1
      rw [hθ0] at h1
      exact h1
    by_cases hwx : θ 1 = σ 0
    · -- `x` has a loop, so the minimal cycle has length 1 and `M.walk 1 = x`
      have hloop : R (σ 0) (σ 0) := by
        have h1 := hstep0
        rw [hwx] at h1
        exact h1
      have hconst : IsWalk R (fun _ : ℤ => σ 0) := fun _ => hloop
      have hlen1 : M.len = 1 := by
        by_contra hcon
        have h2 : (1 : ℤ) < M.len := by have := M.pos; omega
        exact M.minimal 1 (by norm_num) h2 (fun _ => σ 0) hconst rfl rfl
      have : M.walk 1 = σ 0 := by
        have := M.perd 0
        rw [hlen1] at this
        rw [show (1 : ℤ) = 0 + 1 by ring, this, M.base]
      exact hw (by rw [this, hwx])
    · have hm2 : (1 : ℤ) < m := by
        rcases lt_trichotomy m 1 with h | h | h
        · omega
        · exact absurd (by rw [← h]; exact hcyc) hwx
        · exact h
      obtain ⟨k, hk0, hkl, hkv⟩ := minCyc_mem hH M hθ hθ0 hm hcyc (by norm_num : (0 : ℤ) ≤ 1) hm2
      rcases lt_trichotomy k 1 with hk1 | hk1 | hk1
      · have : k = 0 := by omega
        subst this
        rw [M.base] at hkv
        exact hwx hkv
      · subst hk1; exact hw hkv
      · -- `k ≥ 2`: splice a strictly shorter closed walk at `x`
        set ν : ℤ → W := fun n => if n ≤ 0 then M.walk n else M.walk (n + (k - 1)) with hνdef
        have hν : IsWalk R ν := by
          intro n
          by_cases hn : n ≤ 0
          · by_cases hn1 : n + 1 ≤ 0
            · simp only [hνdef, if_pos hn, if_pos hn1]; exact M.isWalk n
            · have hn' : n = 0 := by omega
              subst hn'
              simp only [hνdef, if_pos (le_refl (0 : ℤ)),
                if_neg (by omega : ¬((0 : ℤ) + 1 ≤ 0))]
              have e : (0 : ℤ) + 1 + (k - 1) = k := by ring
              rw [e, M.base, ← hkv]
              exact hstep0
          · have hn1 : ¬(n + 1 ≤ 0) := by omega
            simp only [hνdef, if_neg hn, if_neg hn1]
            have e : n + 1 + (k - 1) = (n + (k - 1)) + 1 := by ring
            rw [e]
            exact M.isWalk _
        have hν0 : ν 0 = σ 0 := by
          simp only [hνdef, if_pos (le_refl (0 : ℤ))]; exact M.base
        have hmpos : (0 : ℤ) < M.len - k + 1 := by omega
        have hmlt : M.len - k + 1 < M.len := by omega
        refine M.minimal (M.len - k + 1) hmpos hmlt ν hν hν0 ?_
        simp only [hνdef, if_neg (by omega : ¬(M.len - k + 1 ≤ 0))]
        have e : M.len - k + 1 + (k - 1) = 0 + M.len := by ring
        rw [e, M.perd, M.base]
  by_cases hs : σ 1 = M.walk 1
  · exact key ρ hρ h0.symm (by rw [← hs]; exact fun h => hne h.symm)
  · exact key σ hσ rfl hs

theorem succ_unique' (hH : AllRec R) {σ ρ : ℤ → W} (hσ : IsWalk R σ) (hρ : IsWalk R ρ)
    {a b : ℤ} (h : σ a = ρ b) : σ (a + 1) = ρ (b + 1) := by
  have hs := succ_unique hH (isWalk_shift hσ a) (isWalk_shift hρ b)
    (show σ (0 + a) = ρ (0 + b) by simpa using h)
  have hs' : σ (1 + a) = ρ (1 + b) := hs
  rw [show a + 1 = 1 + a by ring, show b + 1 = 1 + b by ring]
  exact hs'

theorem det (hH : AllRec R) {σ ρ : ℤ → W} (hσ : IsWalk R σ) (hρ : IsWalk R ρ)
    {a b : ℤ} (h : σ a = ρ b) : ∀ i : ℕ, σ (a + i) = ρ (b + i) := by
  intro i
  induction i with
  | zero => simpa using h
  | succ i ih =>
      have hs := succ_unique' hH hσ hρ ih
      have e1 : a + (i : ℤ) + 1 = a + ((i + 1 : ℕ) : ℤ) := by push_cast; ring
      have e2 : b + (i : ℤ) + 1 = b + ((i + 1 : ℕ) : ℤ) := by push_cast; ring
      rwa [e1, e2] at hs

/--
**E2, digraph form: YES.** If every bi-infinite walk in `(W, R)` is forward-recurrent at every
position, then every bi-infinite walk is periodic.
-/
theorem periodic (hH : AllRec R) {σ : ℤ → W} (hσ : IsWalk R σ) :
    ∃ π : ℤ, 0 < π ∧ ∀ n : ℤ, σ (n + π) = σ n := by
  obtain ⟨m, hm, hmv⟩ := hH σ hσ 0
  refine ⟨m, hm, ?_⟩
  intro n
  have hfwd : ∀ k : ℤ, 0 ≤ k → σ (k + m) = σ k := by
    intro k hk
    have hd := det hH hσ hσ hmv k.toNat
    have e1 : ((k.toNat : ℤ)) = k := by omega
    rw [e1] at hd
    rw [show k + m = m + k by ring, hd, zero_add]
  obtain ⟨k, hk0, hkv⟩ := exists_nonneg_eq hH hσ n
  have hd := det hH hσ hσ hkv.symm m.toNat
  have e1 : ((m.toNat : ℤ)) = m := by omega
  rw [e1] at hd
  rw [hd, hfwd k hk0, hkv]

end Walk

/-! ## Probe I: per-history periodicity gives the **full** density schema. -/

/--
**Truth periodicity from a *per-history* period.** `LoopingDuration.truthAt_add_period` needs a
*frame-uniform* period, because its `□` case reaches into other histories. Here the `□` case is
discharged instead by `Truth.box_time_const` — a boxed formula's truth value is a constant of the
model — so a period belonging to `τ` alone suffices, and no `BoxFree` restriction is needed.
-/
theorem truthAt_add_hist_period {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] {F : TaskFrame D} (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) {π : D}
    (hper : ∀ x : D, τ.states (x + π) (hτ (x + π)) = τ.states x (hτ x)) :
    ∀ (φ : Formula) (t : D), (TruthAt M τ t φ ↔ TruthAt M τ (t + π) φ) := by
  intro φ
  induction φ with
  | atom p =>
      intro t
      simp only [TruthAt]
      constructor
      · rintro ⟨_, hv⟩
        exact ⟨hτ _, by rw [hper t]; exact hv⟩
      · rintro ⟨_, hv⟩
        exact ⟨hτ _, by rw [← hper t]; exact hv⟩
  | bot => intro _; exact Iff.rfl
  | imp ψ χ ihψ ihχ =>
      intro t
      simp only [TruthAt]
      exact ⟨fun hi hψ => (ihχ t).mp (hi ((ihψ t).mpr hψ)),
             fun hi hψ => (ihχ t).mpr (hi ((ihψ t).mp hψ))⟩
  | box ψ _ =>
      intro t
      exact Truth.box_time_const M τ hτ t (t + π) ψ
  | untl χ ψ ihχ ihψ =>
      intro t
      simp only [TruthAt]
      constructor
      · rintro ⟨s, hs, hev, hg⟩
        refine ⟨s + π, (add_lt_add_iff_right π).mpr hs, (ihψ s).mp hev, ?_⟩
        intro r hr1 hr2
        have hrl : t < r - π := lt_sub_iff_add_lt.mpr hr1
        have hrr : r - π < s := sub_lt_iff_lt_add.mpr hr2
        have hkey := (ihχ (r - π)).mp (hg (r - π) hrl hrr)
        rwa [sub_add_cancel] at hkey
      · rintro ⟨s, hs, hev, hg⟩
        have hs' : t < s - π := lt_sub_iff_add_lt.mpr hs
        refine ⟨s - π, hs', ?_, ?_⟩
        · exact (ihψ (s - π)).mpr (by rwa [sub_add_cancel])
        · intro r hr1 hr2
          have hrl : t + π < r + π := (add_lt_add_iff_right π).mpr hr1
          have hrr : r + π < s := by
            have h9 := (add_lt_add_iff_right π).mpr hr2
            rwa [sub_add_cancel] at h9
          exact (ihχ r).mpr (hg (r + π) hrl hrr)
  | snce χ ψ ihχ ihψ =>
      intro t
      simp only [TruthAt]
      constructor
      · rintro ⟨s, hs, hev, hg⟩
        refine ⟨s + π, (add_lt_add_iff_right π).mpr hs, (ihψ s).mp hev, ?_⟩
        intro r hr1 hr2
        have hrl : s < r - π := lt_sub_iff_add_lt.mpr hr1
        have hrr : r - π < t := sub_lt_iff_lt_add.mpr hr2
        have hkey := (ihχ (r - π)).mp (hg (r - π) hrl hrr)
        rwa [sub_add_cancel] at hkey
      · rintro ⟨s, hs, hev, hg⟩
        have hs' : s - π < t := sub_lt_iff_lt_add.mpr hs
        refine ⟨s - π, hs', ?_, ?_⟩
        · exact (ihψ (s - π)).mpr (by rwa [sub_add_cancel])
        · intro r hr1 hr2
          have hrl : s < r + π := by
            have h9 := (add_lt_add_iff_right π).mpr hr1
            rwa [sub_add_cancel] at h9
          have hrr : r + π < t + π := (add_lt_add_iff_right π).mpr hr2
          exact (ihχ r).mpr (hg (r + π) hrl hrr)

/-- **Per-history periodicity suffices for the full density schema**, over an arbitrary `D`. -/
theorem density_of_hist_periodic {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (F : TaskFrame D)
    (h : ∀ (τ : WorldHistory F) (hτ : τ.IsTotal), ∃ π : D, 0 < π ∧
        ∀ x : D, τ.states (x + π) (hτ (x + π)) = τ.states x (hτ x))
    (φ : Formula) (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : D) :
    TruthAt M τ t (φ.allFuture.allFuture.imp φ.allFuture) := by
  obtain ⟨π, hπ, hper⟩ := h τ hτ
  intro hgg
  rw [Truth.future_iff]
  intro s hs
  rw [Truth.future_iff] at hgg
  have h1 := hgg s hs
  rw [Truth.future_iff] at h1
  have h2 : TruthAt M τ (s + π) φ := h1 (s + π) (by simpa using hπ)
  exact (truthAt_add_hist_period M τ hτ hper φ s).mpr h2

/-! ## Probe J: the bridge — a task frame over `ℤ` is a digraph, histories are its walks. -/

namespace Bridge

/-- The one-step digraph of a task frame over `ℤ`. -/
def step (F : TaskFrame ℤ) : F.WorldState → F.WorldState → Prop := fun w u => F.TaskRel w 1 u

theorem taskRel_nat (F : TaskFrame ℤ) {σ : ℤ → F.WorldState} (h : Walk.IsWalk (step F) σ)
    (s : ℤ) : ∀ k : ℕ, F.TaskRel (σ s) (k : ℤ) (σ (s + (k : ℤ))) := by
  intro k
  induction k with
  | zero => simpa using F.nullity (σ s)
  | succ k ih =>
      have h1 : F.TaskRel (σ (s + (k : ℤ))) 1 (σ (s + (k : ℤ) + 1)) := h (s + (k : ℤ))
      have h2 := F.forward_comp (σ s) (σ (s + (k : ℤ))) (σ (s + (k : ℤ) + 1)) (k : ℤ) 1
        (by positivity) (by norm_num) ih h1
      have e1 : ((k : ℤ) + 1) = ((k + 1 : ℕ) : ℤ) := by push_cast; ring
      have e2 : s + (k : ℤ) + 1 = s + ((k + 1 : ℕ) : ℤ) := by push_cast; ring
      rw [e1, e2] at h2
      exact h2

/-- **Every bi-infinite walk is a total history**: `comp` + `converse` + `nullity` give `Rₙ = R₁ⁿ`. -/
theorem taskRel_diff (F : TaskFrame ℤ) {σ : ℤ → F.WorldState} (h : Walk.IsWalk (step F) σ)
    (s t : ℤ) : F.TaskRel (σ s) (t - s) (σ t) := by
  rcases le_total s t with hst | hst
  · have hk := taskRel_nat F h s (t - s).toNat
    rw [show (((t - s).toNat : ℤ)) = t - s by omega, show s + (t - s) = t by ring] at hk
    exact hk
  · have hk := taskRel_nat F h t (s - t).toNat
    rw [show (((s - t).toNat : ℤ)) = s - t by omega, show t + (s - t) = s by ring] at hk
    have hc := (F.converse (σ t) (s - t) (σ s)).mp hk
    rw [show -(s - t) = t - s by ring] at hc
    exact hc

def ofWalk (F : TaskFrame ℤ) {σ : ℤ → F.WorldState} (h : Walk.IsWalk (step F) σ) :
    WorldHistory F where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => σ t
  respects_task := fun s t _ _ => taskRel_diff F h s t
  convex := fun _ _ _ _ _ _ _ => trivial

theorem ofWalk_isTotal (F : TaskFrame ℤ) {σ : ℤ → F.WorldState} (h : Walk.IsWalk (step F) σ) :
    (ofWalk F h).IsTotal := fun _ => trivial

/-- **Every total history is a bi-infinite walk.** -/
theorem hist_isWalk (F : TaskFrame ℤ) (τ : WorldHistory F) (hτ : τ.IsTotal) :
    Walk.IsWalk (step F) (fun n => τ.states n (hτ n)) := by
  intro n
  have h := τ.respects_task n (n + 1) (hτ n) (hτ (n + 1))
  rw [show n + 1 - n = (1 : ℤ) by ring] at h
  exact h

/-- **`FwdRec` over `ℤ` is exactly the digraph hypothesis `AllRec`.** -/
theorem allRec_of_fwdRec (F : TaskFrame ℤ) (hF : Corr.FwdRec F) : Walk.AllRec (step F) := by
  intro σ hσ n
  have hcov : Corr.Covers (n - 1) n := ⟨by omega, fun r h1 h2 => by omega⟩
  exact hF (ofWalk F hσ) (ofWalk_isTotal F hσ) (n - 1) n hcov
    (fun w => ∃ m : ℤ, n < m ∧ σ m = w) (fun r hr => ⟨r, hr, rfl⟩)

/-- **E2, answered: YES.** Over `D = ℤ`, `FwdRec F` forces every total history to be periodic. -/
theorem hist_periodic (F : TaskFrame ℤ) (hF : Corr.FwdRec F) (τ : WorldHistory F)
    (hτ : τ.IsTotal) :
    ∃ π : ℤ, 0 < π ∧ ∀ n : ℤ, τ.states (n + π) (hτ (n + π)) = τ.states n (hτ n) :=
  Walk.periodic (allRec_of_fwdRec F hF) (hist_isWalk F τ hτ)

/--
**The structural shape of a `FwdRec` frame over `ℤ`**, sharpening report 02 §6's conjecture that
the surviving frames are "permutations with all orbits finite": the one-step relation is
*deterministic* along histories — two total histories that agree at one time agree one step later.
-/
theorem hist_deterministic (F : TaskFrame ℤ) (hF : Corr.FwdRec F)
    (τ ρ : WorldHistory F) (hτ : τ.IsTotal) (hρ : ρ.IsTotal) (t : ℤ)
    (h : τ.states t (hτ t) = ρ.states t (hρ t)) :
    τ.states (t + 1) (hτ (t + 1)) = ρ.states (t + 1) (hρ (t + 1)) :=
  Walk.succ_unique' (allRec_of_fwdRec F hF) (hist_isWalk F τ hτ) (hist_isWalk F ρ hρ) h

/--
**Full-schema exactness over `ℤ`.**

`F` validates *every* instance of `GGφ → Gφ` — `φ` ranging over all formulas, not just atoms —
**iff** `FwdRec F`. This closes report 02 §6's open point E2 in the affirmative at `D = ℤ`.
-/
theorem density_schema_iff_fwdRec (F : TaskFrame ℤ) :
    (∀ (φ : Formula) (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal → ∀ t : ℤ,
        TruthAt M τ t (φ.allFuture.allFuture.imp φ.allFuture)) ↔ Corr.FwdRec F := by
  constructor
  · intro h
    exact (Corr.density_iff_fwdRec F).mp fun p M τ hτ t => h (Formula.atom p) M τ hτ t
  · intro hF φ M τ hτ t
    exact density_of_hist_periodic F (fun τ' hτ' => hist_periodic F hF τ' hτ') φ M τ hτ t

end Bridge

#print axioms Scratch511c.freeFrame_bool_not_fwdRec
#print axioms Scratch511c.Walk.succ_unique
#print axioms Scratch511c.Walk.periodic
#print axioms Scratch511c.truthAt_add_hist_period
#print axioms Scratch511c.density_of_hist_periodic
#print axioms Scratch511c.Bridge.hist_deterministic
#print axioms Scratch511c.Bridge.hist_periodic
#print axioms Scratch511c.Bridge.density_schema_iff_fwdRec

end Scratch511c
