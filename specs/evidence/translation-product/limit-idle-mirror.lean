import Mathlib

/-!
# Probe 02 — *Limit* is idle beyond REFLEXIVITY of the zero task (Mathlib-only mirror)

Report 04 §4.1 recorded "Limit adds no validity beyond Nullity" (modulo Saturation of the
product, now compiled in probe 01). This file sharpens the claim in the `probe 559/04` mirror
(`Hist`, `TD` over an arbitrary ordered abelian group, no frame axiom assumed):

* `hist_zeroFix_iff` — replacing `R 0` by equality changes NO total history, provided `R 0` is
  reflexive. Total histories consult `R 0` only on the diagonal.
* `TD_zeroFix` — hence every truth value in the all-histories model is unchanged.
* `zeroFix_limit_clocked` — the clock product of `zeroFix R` satisfies *Limit* with NO
  hypothesis on `R 0` beyond reflexivity (and, via `clock_invariance`, the same truth values).

Conclusion: the whole content of *Limit* for L⁺-validity is exhausted by the reflexivity half
of `lem:nullity` — which is itself needed only so that histories exist at all. The injective
half (`⇒₀ ⊆ id`, `FrameOver.eq_of_taskRel_zero`) and the cone condition proper contribute no
validity. Sorry-free; compiles alone with `lake env lean` (Mathlib only).
-/

set_option linter.unusedSectionVars false

namespace Probe624Mirror

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {W : Type}

/-- Total history of a duration-indexed relation (as in `probe 559/04`). -/
def Hist (R : D → W → W → Prop) (τ : D → W) : Prop :=
  ∀ x y, x ≤ y → R (y - x) (τ x) (τ y)

/-- `R` with its zero-duration task replaced by equality. -/
def zeroFix (R : D → W → W → Prop) : D → W → W → Prop :=
  fun x w u => if x = 0 then w = u else R x w u

theorem zeroFix_zero (R : D → W → W → Prop) (w u : W) : zeroFix R 0 w u ↔ w = u := by
  simp [zeroFix]

theorem zeroFix_ne (R : D → W → W → Prop) {x : D} (hx : x ≠ 0) (w u : W) :
    zeroFix R x w u ↔ R x w u := by
  simp [zeroFix, hx]

/-- **Total histories are unchanged by fixing the zero task**, as long as `R 0` is reflexive. -/
theorem hist_zeroFix_iff (R : D → W → W → Prop) (hrefl : ∀ w, R 0 w w) (τ : D → W) :
    Hist (zeroFix R) τ ↔ Hist R τ := by
  constructor
  · intro H x y hxy
    rcases eq_or_lt_of_le hxy with rfl | hlt
    · rw [sub_self]; exact hrefl _
    · have hne : y - x ≠ 0 := sub_ne_zero.2 hlt.ne'
      exact (zeroFix_ne R hne _ _).1 (H x y hxy)
  · intro H x y hxy
    rcases eq_or_lt_of_le hxy with rfl | hlt
    · rw [sub_self]; exact (zeroFix_zero R _ _).2 rfl
    · have hne : y - x ≠ 0 := sub_ne_zero.2 hlt.ne'
      exact (zeroFix_ne R hne _ _).2 (H x y hxy)

/-- Mirror of `PlusFormula` (as in `probe 559/04`). -/
inductive Fm : Type where
  | atom : ℕ → Fm
  | bot : Fm
  | imp : Fm → Fm → Fm
  | box : Fm → Fm
  | untl : Fm → Fm → Fm
  | snce : Fm → Fm → Fm
  | stab : Fm → Fm

/-- Truth in the all-histories model of `R`, as in `probe 559/04`'s `TD (fullD R V)`. -/
def TD (R : D → W → W → Prop) (V : W → ℕ → Prop) (σ : D → W) (t : D) : Fm → Prop
  | .atom p => V (σ t) p
  | .bot => False
  | .imp φ ψ => TD R V σ t φ → TD R V σ t ψ
  | .box φ => ∀ ρ, Hist R ρ → TD R V ρ t φ
  | .untl ψ φ => ∃ s, t < s ∧ TD R V σ s φ ∧ ∀ r, t < r → r < s → TD R V σ r ψ
  | .snce ψ φ => ∃ s, s < t ∧ TD R V σ s φ ∧ ∀ r, s < r → r < t → TD R V σ r ψ
  | .stab φ => ∀ ρ, Hist R ρ → σ t = ρ t → TD R V ρ t φ

/-- **Every truth value is unchanged by fixing the zero task.** -/
theorem TD_zeroFix (R : D → W → W → Prop) (hrefl : ∀ w, R 0 w w) (V : W → ℕ → Prop) :
    ∀ (φ : Fm) (σ : D → W) (t : D), TD (zeroFix R) V σ t φ ↔ TD R V σ t φ := by
  intro φ
  induction φ with
  | atom p => intro σ t; exact Iff.rfl
  | bot => intro σ t; exact Iff.rfl
  | imp a b ih1 ih2 => intro σ t; exact imp_congr (ih1 σ t) (ih2 σ t)
  | box a ih =>
    intro σ t
    exact forall_congr' fun ρ => imp_congr (hist_zeroFix_iff R hrefl ρ) (ih ρ t)
  | untl a b ih1 ih2 =>
    intro σ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 σ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 σ r)
  | snce a b ih1 ih2 =>
    intro σ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 σ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 σ r)
  | stab a ih =>
    intro σ t
    exact forall_congr' fun ρ => imp_congr (hist_zeroFix_iff R hrefl ρ)
      (imp_congr_right fun _ => ih ρ t)

/-- The clock product (as in `probe 559/04`, `clockP`). -/
def clockP (R : D → W → W → Prop) : D → W × D → W × D → Prop :=
  fun x a b => R x a.1 b.1 ∧ b.2 = a.2 + x

/-- The reflection-extended relation and the manuscript's *Limit*, as in `probe 559/04`. -/
def RrD (R : D → W → W → Prop) (y : D) (w u : W) : Prop :=
  (0 ≤ y ∧ R y w u) ∨ (y < 0 ∧ R (-y) u w)

def LimitD (R : D → W → W → Prop) : Prop :=
  ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ RrD R y w u) → u = w

/-- `probe 559/04`'s `clock_limit`, reproduced: Limit in the clock product from `⇒₀ ⊆ id`. -/
theorem clock_limit (R : D → W → W → Prop) (hD : ∃ x : D, 0 < x)
    (hN : ∀ w v, R 0 w v → w = v) : LimitD (clockP R) := by
  rintro ⟨w, d⟩ ⟨v, e⟩ h
  have key : ∀ y, RrD (clockP R) y (w, d) (v, e) → e = d + y := by
    rintro y (⟨-, -, h2⟩ | ⟨-, -, h2⟩)
    · exact h2
    · have h2' : d = e + -y := h2
      rw [h2']; abel
  have hed : e = d := by
    by_contra hne
    have hpos : 0 < |e - d| := abs_pos.mpr (sub_ne_zero.mpr hne)
    obtain ⟨y, hy, hr⟩ := h _ hpos
    have : e - d = y := by rw [key y hr]; abel
    rw [this] at hy
    exact lt_irrefl _ hy
  subst hed
  obtain ⟨x, hx⟩ := hD
  obtain ⟨y, -, hr⟩ := h x hx
  have hy0 : y = 0 := by
    have := key y hr
    have h' : e + 0 = e + y := by rw [add_zero]; exact this
    exact (add_left_cancel h').symm
  subst hy0
  rcases hr with ⟨-, h1, -⟩ | ⟨h1, -⟩
  · have : w = v := hN _ _ h1
    subst this; rfl
  · exact absurd h1 (lt_irrefl _)

/-- **Limit needs nothing of `R 0`**: the clock product of `zeroFix R` satisfies *Limit*
outright. Combined with `TD_zeroFix` and `probe 559/04`'s `clock_invariance`, every
all-histories model of a relation with a reflexive zero task is L⁺-equivalent to one on a
relation satisfying *Limit* (and Nullity, and recurrence-freeness). -/
theorem zeroFix_limit_clocked (R : D → W → W → Prop) (hD : ∃ x : D, 0 < x) :
    LimitD (clockP (zeroFix R)) :=
  clock_limit (zeroFix R) hD fun _ _ h => (zeroFix_zero R _ _).1 h

end Probe624Mirror
