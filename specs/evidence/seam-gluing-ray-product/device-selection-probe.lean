/-
Probe 732 (E3): device-selection comparison — header finalized in Phase 3.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

/-! The E3 device-selection comparison core. Over an ARBITRARY finite step graph, the universal
summary of the `Fp` shape reduces to ultimately periodic (lasso) paths by PIGEONHOLE ALONE -- no
Ramsey, no automata, no determinization. The per-path property "eventually P" is recognised by a
2-state DETERMINISTIC automaton, so Safra/Safraless have nothing to do on this shape. -/

namespace Probe732Device

variable {S : Type} [Finite S]

/-- A forward root path from `w₀` in the step graph `R`. -/
def IsPath (R : S → S → Prop) (w₀ : S) (g : ℕ → S) : Prop := g 0 = w₀ ∧ ∀ n, R (g n) (g (n + 1))

/-- Ultimately periodic: from index `i` on, period `p > 0`. -/
def IsLasso (g : ℕ → S) : Prop := ∃ i p : ℕ, 0 < p ∧ ∀ n, i ≤ n → g (n + p) = g n

/-- The universal (`⊡(Fp)`-shaped) summary: every root path meets `P` at a positive time. -/
def AllPathsMeet (R : S → S → Prop) (P : S → Prop) (w₀ : S) : Prop :=
  ∀ g, IsPath R w₀ g → ∃ n, 0 < n ∧ P (g n)

/-- The lasso index: identity below `j`, then wraps into the cycle `[i, j)`. -/
def lassoIdx (i j n : ℕ) : ℕ := if n < j then n else i + (n - i) % (j - i)

theorem lassoIdx_pos (i j n : ℕ) (hi : 0 < i) (hn : 0 < n) : 0 < lassoIdx i j n := by
  unfold lassoIdx; split_ifs <;> omega

theorem lassoIdx_lt (i j n : ℕ) (hij : i < j) : lassoIdx i j n < j := by
  unfold lassoIdx
  split_ifs with h
  · exact h
  · have := Nat.mod_lt (n - i) (by omega : 0 < j - i)
    omega

omit [Finite S] in
/-- Build the lasso from a path `g` and a repeat `g i = g j`, `0 < i < j`. -/
theorem exists_lasso_of_repeat (R : S → S → Prop) (w₀ : S) (g : ℕ → S) (hg : IsPath R w₀ g)
    (i j : ℕ) (hi : 0 < i) (hij : i < j) (hrep : g i = g j) :
    ∃ g', IsPath R w₀ g' ∧ IsLasso g' ∧ ∀ n, 0 < n → ∃ m, 0 < m ∧ g' n = g m := by
  refine ⟨fun n => g (lassoIdx i j n), ⟨?_, ?_⟩, ⟨j, j - i, by omega, ?_⟩, ?_⟩
  · show g (lassoIdx i j 0) = w₀
    simp [lassoIdx, show 0 < j by omega, hg.1]
  · intro n
    show R (g (lassoIdx i j n)) (g (lassoIdx i j (n + 1)))
    unfold lassoIdx
    by_cases h1 : n + 1 < j
    · rw [if_pos (by omega), if_pos h1]; exact hg.2 n
    · rw [if_neg h1]
      by_cases h0 : n < j
      · -- n = j - 1 : step from g (j-1) to g i = g j
        rw [if_pos h0]
        have hn : n = j - 1 := by omega
        have : (n + 1 - i) % (j - i) = 0 := by
          rw [show n + 1 - i = j - i by omega]; exact Nat.mod_self _
        rw [this, Nat.add_zero, hrep, hn]
        have := hg.2 (j - 1)
        rwa [show j - 1 + 1 = j by omega] at this
      · rw [if_neg h0]
        -- n ≥ j: both indices wrap
        have hrlt : (n - i) % (j - i) < j - i := Nat.mod_lt _ (by omega)
        have hmod : (n + 1 - i) % (j - i) = ((n - i) % (j - i) + 1) % (j - i) := by
          rw [show n + 1 - i = (n - i) + 1 by omega, Nat.mod_add_mod]
        by_cases hr1 : (n - i) % (j - i) + 1 < j - i
        · rw [hmod, Nat.mod_eq_of_lt hr1, ← Nat.add_assoc]; exact hg.2 _
        · have hr2 : (n - i) % (j - i) + 1 = j - i := by omega
          rw [hmod, hr2, Nat.mod_self, Nat.add_zero, hrep]
          have := hg.2 (i + (n - i) % (j - i))
          rwa [show i + (n - i) % (j - i) + 1 = j by omega] at this
  · intro n hn
    show g (lassoIdx i j (n + (j - i))) = g (lassoIdx i j n)
    unfold lassoIdx
    rw [if_neg (by omega), if_neg (by omega)]
    congr 2
    rw [show n + (j - i) - i = (n - i) + (j - i) by omega, Nat.add_mod_right]
  · intro n hn
    exact ⟨lassoIdx i j n, lassoIdx_pos i j n hi hn, rfl⟩

/-- **Lasso sufficiency for the `Fp` shape, by pigeonhole alone.** Over a finite step graph the
universal summary agrees with its restriction to ultimately periodic paths. -/
theorem allPathsMeet_iff_lasso (R : S → S → Prop) (P : S → Prop) (w₀ : S) :
    AllPathsMeet R P w₀ ↔ ∀ g, IsPath R w₀ g → IsLasso g → ∃ n, 0 < n ∧ P (g n) := by
  constructor
  · intro h g hg _; exact h g hg
  · intro h g hg
    by_contra hno
    simp only [not_exists, not_and] at hno
    -- pigeonhole on the shifted sequence so every repeat index is positive
    obtain ⟨a, b, hab, heq⟩ := Finite.exists_ne_map_eq_of_infinite (fun n => g (n + 1))
    rcases Nat.lt_or_gt_of_ne hab with hlt | hlt
    · obtain ⟨g', hg', hl, hm⟩ :=
        exists_lasso_of_repeat R w₀ g hg (a + 1) (b + 1) (by omega) (by omega) heq
      obtain ⟨n, hn, hPn⟩ := h g' hg' hl
      obtain ⟨m, hm0, hgm⟩ := hm n hn
      exact hno m hm0 (hgm ▸ hPn)
    · obtain ⟨g', hg', hl, hm⟩ :=
        exists_lasso_of_repeat R w₀ g hg (b + 1) (a + 1) (by omega) (by omega) heq.symm
      obtain ⟨n, hn, hPn⟩ := h g' hg' hl
      obtain ⟨m, hm0, hgm⟩ := hm n hn
      exact hno m hm0 (hgm ▸ hPn)

/-- The `Pp` (backward) shape is the same statement on the reversed graph: nothing new. -/
theorem allBwdPathsMeet_iff_lasso (R : S → S → Prop) (P : S → Prop) (w₀ : S) :
    AllPathsMeet (fun a b => R b a) P w₀ ↔
      ∀ g, IsPath (fun a b => R b a) w₀ g → IsLasso g → ∃ n, 0 < n ∧ P (g n) :=
  allPathsMeet_iff_lasso _ P w₀

/-! ## The per-path automaton for the `Fp` shape is already deterministic -/

/-- Two-state deterministic acceptor for "eventually `P`": state `true` = seen `P`. -/
def detRun (P : S → Prop) [DecidablePred P] (g : ℕ → S) : ℕ → Bool
  | 0 => false
  | n + 1 => detRun P g n || decide (P (g (n + 1)))

omit [Finite S] in
theorem detRun_true_iff (P : S → Prop) [DecidablePred P] (g : ℕ → S) (n : ℕ) :
    detRun P g n = true ↔ ∃ m, 0 < m ∧ m ≤ n ∧ P (g m) := by
  induction n with
  | zero => simp [detRun]
  | succ n ih =>
    simp only [detRun, Bool.or_eq_true, decide_eq_true_eq, ih]
    constructor
    · rintro (⟨m, hm0, hmn, hP⟩ | hP)
      · exact ⟨m, hm0, by omega, hP⟩
      · exact ⟨n + 1, by omega, le_rfl, hP⟩
    · rintro ⟨m, hm0, hmn, hP⟩
      rcases Nat.lt_or_eq_of_le hmn with h | h
      · exact Or.inl ⟨m, hm0, by omega, hP⟩
      · exact Or.inr (h ▸ hP)

omit [Finite S] in
/-- Acceptance (the run eventually reaches `true`) is exactly the per-path `Fp` property. No
nondeterminism is involved, so no determinization device acts on this shape. -/
theorem detRun_accepts_iff (P : S → Prop) [DecidablePred P] (g : ℕ → S) :
    (∃ n, detRun P g n = true) ↔ ∃ m, 0 < m ∧ P (g m) := by
  constructor
  · rintro ⟨n, hn⟩
    obtain ⟨m, hm0, -, hP⟩ := (detRun_true_iff P g n).mp hn
    exact ⟨m, hm0, hP⟩
  · rintro ⟨m, hm0, hP⟩
    exact ⟨m, (detRun_true_iff P g m).mpr ⟨m, hm0, le_rfl, hP⟩⟩

/-! ## The falsifier: pigeonhole-tier lasso sufficiency FAILS on an infinite acyclic fibre -/

/-- The descending chain on `ℤ`: the one-step relation `a → a - 1`. Acyclic and infinite. -/
def chainR (a b : ℤ) : Prop := b = a - 1

theorem chain_path_strictAnti (w₀ : ℤ) (g : ℕ → ℤ) (hg : g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) :
    ∀ n, g n = w₀ - n := by
  intro n
  induction n with
  | zero => simp [hg.1]
  | succ n ih => have := hg.2 n; unfold chainR at this; rw [this, ih]; push_cast; ring

/-- No forward path in the chain is a lasso. -/
theorem chain_no_lasso (w₀ : ℤ) (g : ℕ → ℤ) (hg : g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) :
    ¬ (∃ i p : ℕ, 0 < p ∧ ∀ n, i ≤ n → g (n + p) = g n) := by
  rintro ⟨i, p, hp, hper⟩
  have h := hper i le_rfl
  rw [chain_path_strictAnti w₀ g hg, chain_path_strictAnti w₀ g hg] at h
  push_cast at h
  omega

/-- **The falsifier.** On the infinite chain, with `P` never holding, the universal summary is
False (the chain itself avoids `P`) while its lasso restriction is vacuously True. Pigeonhole-tier
lasso sufficiency is therefore NOT a device for infinite fibres: the `⊡(Fp)`/`⊡(Pp)` shapes on
FINITE fixtures cannot see this, which is exactly why they do not discriminate the candidates. -/
theorem not_lasso_sufficient_on_chain (w₀ : ℤ) :
    ¬ ((∀ g : ℕ → ℤ, (g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) → ∃ n, 0 < n ∧ False) ↔
       (∀ g : ℕ → ℤ, (g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) →
          (∃ i p : ℕ, 0 < p ∧ ∀ n, i ≤ n → g (n + p) = g n) → ∃ n, 0 < n ∧ False)) := by
  intro hiff
  have hrhs : ∀ g : ℕ → ℤ, (g 0 = w₀ ∧ ∀ n, chainR (g n) (g (n + 1))) →
      (∃ i p : ℕ, 0 < p ∧ ∀ n, i ≤ n → g (n + p) = g n) → ∃ n, 0 < n ∧ False :=
    fun g hg hl => absurd hl (chain_no_lasso w₀ g hg)
  obtain ⟨_, _, h⟩ := hiff.mpr hrhs (fun n => w₀ - n) ⟨by simp, fun n => by unfold chainR; push_cast; ring⟩
  exact h

end Probe732Device

#print axioms Probe732Device.allPathsMeet_iff_lasso
#print axioms Probe732Device.allBwdPathsMeet_iff_lasso
#print axioms Probe732Device.detRun_accepts_iff
#print axioms Probe732Device.not_lasso_sufficient_on_chain
