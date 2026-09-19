import Mathlib

/-!
# Probes, round 04: semantics-native facts at an ARBITRARY temporal order

Rounds 01-03 worked in a ℤ-specialised mirror (bi-infinite walks of a digraph). This file mirrors
`PlusTruthAt` over an arbitrary totally ordered abelian group `D`, with the task relation a
duration-indexed family `R : D → W → W → Prop` and `H_F` = all total histories (`Hist`). No frame
axiom is assumed unless a theorem names it. Mathlib-only, sorry-free, compiles alone with bare
`lean`. Contents:

* Part P — `TD` (the truth recursion), `Hist`, `shiftD`, `TD_shift` (the manuscript's
  `lem:history-time-shift-preservation` for the language with `⊡`), `stab_state_only`: the truth
  of `⊡φ` depends on the present world STATE alone — not on the history, and not on the time.
* Part Q — the state-naming rule: from `⊢ (q ∧ ⋀_ψ NOM_q(ψ)) → φ`, `q` fresh for `φ`, infer `⊢ φ`
  (`state_name_sound`). It is sound frame by frame, over every temporal order, with no frame axiom
  used: a fresh atom can always be made to name the present world state, because sentence letters
  are interpreted by sets of world states.
* Part R — the clock product `clockP` at every `D`: `clock_hist_iff` (histories of `F × D` are
  exactly (history of `F`, clock offset) pairs, so lifts are unique), `clock_no_recurrence`,
  `clock_comp`, `clock_serial`, `clock_limit` (Limit holds in `F × D` as soon as `⇒₀` is the
  identity in `F`), and `clock_invariance` (truth is preserved by the projection).
  So the language with `⊡` cannot see that a world state recurs, and Limit adds no validity
  beyond Nullity.
* Part S — `repar_invariance`: truth is invariant under order-automorphic reparametrisation of
  time, history by history. The language with `⊡` sees the ORDER of time only, never a duration.
* Part T — `⊡` is not Ockhamist historical necessity: the Ockhamist axiom HN `Pα → □P◇α`,
  transposed to `⊡`, is refuted on a three-state ℤ-frame (`hn_stab_refuted`), while it holds for
  the manuscript's open-future modality `▷` (`hn_open`).
-/

set_option linter.unusedSectionVars false

namespace Probe559d

/-- Mirror of `PlusFormula`. -/
inductive Fm : Type where
  | atom : ℕ → Fm
  | bot : Fm
  | imp : Fm → Fm → Fm
  | box : Fm → Fm
  | untl : Fm → Fm → Fm
  | snce : Fm → Fm → Fm
  | stab : Fm → Fm

namespace Fm
def neg (φ : Fm) : Fm := imp φ bot
def top : Fm := imp bot bot
def and (φ ψ : Fm) : Fm := neg (imp φ (neg ψ))
def somePast (φ : Fm) : Fm := snce top φ
def dstab (φ : Fm) : Fm := neg (stab (neg φ))
end Fm

/-- A bundled model over the temporal order `D`. -/
structure DModel (D : Type) where
  C : Type
  V : C → ℕ → Prop
  B : Set (D → C)

section Truth
variable {D : Type} [LinearOrder D]

/-- Mirror of `PlusTruthAt` over an arbitrary linear order of times. -/
def TD (M : DModel D) (σ : D → M.C) (t : D) : Fm → Prop
  | .atom p => M.V (σ t) p
  | .bot => False
  | .imp φ ψ => TD M σ t φ → TD M σ t ψ
  | .box φ => ∀ ρ ∈ M.B, TD M ρ t φ
  | .untl ψ φ => ∃ s, t < s ∧ TD M σ s φ ∧ ∀ r, t < r → r < s → TD M σ r ψ
  | .snce ψ φ => ∃ s, s < t ∧ TD M σ s φ ∧ ∀ r, s < r → r < t → TD M σ r ψ
  | .stab φ => ∀ ρ ∈ M.B, σ t = ρ t → TD M ρ t φ

variable (M : DModel D) (σ : D → M.C) (t : D)

theorem and_iff (φ ψ : Fm) : TD M σ t (φ.and ψ) ↔ TD M σ t φ ∧ TD M σ t ψ := by
  simp only [Fm.and, Fm.neg, TD]; tauto

theorem dstab_iff (φ : Fm) :
    TD M σ t φ.dstab ↔ ∃ ρ ∈ M.B, σ t = ρ t ∧ TD M ρ t φ := by
  simp only [Fm.dstab, Fm.neg, TD]
  constructor
  · intro h; by_contra hc; exact h fun ρ hρ he hφ => hc ⟨ρ, hρ, he, hφ⟩
  · rintro ⟨ρ, hρ, he, hφ⟩ h; exact h ρ hρ he hφ

theorem somePast_iff (φ : Fm) : TD M σ t φ.somePast ↔ ∃ s, s < t ∧ TD M σ s φ := by
  simp only [Fm.somePast, Fm.top, TD]
  constructor
  · rintro ⟨s, hs, h, -⟩; exact ⟨s, hs, h⟩
  · rintro ⟨s, hs, h⟩; exact ⟨s, hs, h, fun _ _ _ h => h⟩

end Truth

/-! ## Part P — histories, shifts, and state-locality of `⊡` -/

section Shift
variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {W : Type}

/-- A total history of the duration-indexed task relation `R` (only `R x` with `0 ≤ x` is used;
the manuscript's reflection convention makes the other half redundant). -/
def Hist (R : D → W → W → Prop) (τ : D → W) : Prop :=
  ∀ x y, x ≤ y → R (y - x) (τ x) (τ y)

/-- The all-histories model of `R`. -/
abbrev fullD (R : D → W → W → Prop) (V : W → ℕ → Prop) : DModel D :=
  ⟨W, V, {τ | Hist R τ}⟩

/-- Translate of a history (`app:auto_existence`). -/
def shiftD (σ : D → W) (c : D) : D → W := fun n => σ (n + c)

theorem hist_shift {R : D → W → W → Prop} {τ : D → W} (h : Hist R τ) (c : D) :
    Hist R (shiftD τ c) := by
  intro x y hxy
  have := h (x + c) (y + c) (by simpa using hxy)
  rwa [add_sub_add_right_eq_sub] at this

theorem shift_shift_neg (ρ : D → W) (c : D) : shiftD (shiftD ρ (-c)) c = ρ := by
  funext n; simp [shiftD]

/-- `lem:history-time-shift-preservation`, for the language with `⊡`. -/
theorem TD_shift (R : D → W → W → Prop) (V : W → ℕ → Prop) :
    ∀ (φ : Fm) (σ : D → W) (t c : D),
      TD (fullD R V) (shiftD σ c) t φ ↔ TD (fullD R V) σ (t + c) φ := by
  intro φ
  induction φ with
  | atom p => intro σ t c; exact Iff.rfl
  | bot => intro σ t c; exact Iff.rfl
  | imp a b ih1 ih2 => intro σ t c; exact imp_congr (ih1 σ t c) (ih2 σ t c)
  | box a ih =>
    intro σ t c
    constructor
    · intro h ρ hρ; exact (ih ρ t c).1 (h _ (hist_shift hρ c))
    · intro h ρ hρ
      have := (ih (shiftD ρ (-c)) t c).2 (h _ (hist_shift hρ (-c)))
      rwa [shift_shift_neg] at this
  | untl a b ih1 ih2 =>
    intro σ t c
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      refine ⟨s + c, by simpa using hs, (ih2 σ s c).1 h1, fun r hr1 hr2 => ?_⟩
      have := (ih1 σ (r - c) c).1
        (h2 (r - c) (lt_sub_iff_add_lt.2 hr1) (sub_lt_iff_lt_add.2 hr2))
      rwa [sub_add_cancel] at this
    · rintro ⟨s, hs, h1, h2⟩
      refine ⟨s - c, lt_sub_iff_add_lt.2 hs, (ih2 σ (s - c) c).2 (by rwa [sub_add_cancel]),
        fun r hr1 hr2 => (ih1 σ r c).2 (h2 (r + c) (by simpa using hr1) ?_)⟩
      exact lt_sub_iff_add_lt.1 hr2
  | snce a b ih1 ih2 =>
    intro σ t c
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      refine ⟨s + c, by simpa using hs, (ih2 σ s c).1 h1, fun r hr1 hr2 => ?_⟩
      have := (ih1 σ (r - c) c).1
        (h2 (r - c) (lt_sub_iff_add_lt.2 hr1) (sub_lt_iff_lt_add.2 hr2))
      rwa [sub_add_cancel] at this
    · rintro ⟨s, hs, h1, h2⟩
      refine ⟨s - c, sub_lt_iff_lt_add.2 hs, (ih2 σ (s - c) c).2 (by rwa [sub_add_cancel]),
        fun r hr1 hr2 => (ih1 σ r c).2 (h2 (r + c) ?_ (by simpa using hr2))⟩
      exact sub_lt_iff_lt_add.1 hr1
  | stab a ih =>
    intro σ t c
    constructor
    · intro h ρ hρ he; exact (ih ρ t c).1 (h _ (hist_shift hρ c) he)
    · intro h ρ hρ he
      have h1 := h (shiftD ρ (-c)) (hist_shift hρ (-c))
        (by show σ (t + c) = ρ (t + c + -c); rw [add_neg_cancel_right]; exact he)
      have := (ih (shiftD ρ (-c)) t c).2 h1
      rwa [shift_shift_neg] at this

/-- The truth of `⊡φ` is a function of the present WORLD STATE: same state, at any two times of
any two functions, same verdict. This is the manuscript's "the alternatives at a time are fixed by
the current state", and it uses translation-closure of `H_F` and nothing else. -/
theorem stab_state_only (R : D → W → W → Prop) (V : W → ℕ → Prop) (a : Fm)
    {σ ρ : D → W} {t s : D} (h : σ t = ρ s)
    (H : TD (fullD R V) σ t a.stab) : TD (fullD R V) ρ s a.stab := by
  intro η hη he
  have e : t + (s - t) = s := by abel
  have h1 := H (shiftD η (s - t)) (hist_shift hη _)
    (by show σ t = η (t + (s - t)); rw [e]; exact h.trans he)
  have := (TD_shift R V a η t (s - t)).1 h1
  rwa [e] at this

end Shift

/-! ## Part Q — the state-naming rule -/

/-- `q` does not occur in the formula. -/
def Fm.fresh (q : ℕ) : Fm → Prop
  | .atom p => p ≠ q
  | .bot => True
  | .imp a b => Fm.fresh q a ∧ Fm.fresh q b
  | .box a => Fm.fresh q a
  | .untl a b => Fm.fresh q a ∧ Fm.fresh q b
  | .snce a b => Fm.fresh q a ∧ Fm.fresh q b
  | .stab a => Fm.fresh q a

theorem TD_fresh {D : Type} [LinearOrder D] {C : Type} (B : Set (D → C))
    (V V' : C → ℕ → Prop) (q : ℕ) (hV : ∀ c p, p ≠ q → (V c p ↔ V' c p)) :
    ∀ φ : Fm, φ.fresh q → ∀ (σ : D → C) (t : D),
      (TD ⟨C, V, B⟩ σ t φ ↔ TD ⟨C, V', B⟩ σ t φ) := by
  intro φ
  induction φ with
  | atom p => intro hq σ t; exact hV _ _ hq
  | bot => intro _ σ t; exact Iff.rfl
  | imp a b ih1 ih2 => intro hq σ t; exact imp_congr (ih1 hq.1 σ t) (ih2 hq.2 σ t)
  | box a ih =>
    intro hq σ t
    exact forall_congr' fun ρ => imp_congr Iff.rfl (ih hq ρ t)
  | untl a b ih1 ih2 =>
    intro hq σ t
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 hq.2 σ s).1 h1, fun r a1 a2 => (ih1 hq.1 σ r).1 (h2 r a1 a2)⟩
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 hq.2 σ s).2 h1, fun r a1 a2 => (ih1 hq.1 σ r).2 (h2 r a1 a2)⟩
  | snce a b ih1 ih2 =>
    intro hq σ t
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 hq.2 σ s).1 h1, fun r a1 a2 => (ih1 hq.1 σ r).1 (h2 r a1 a2)⟩
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 hq.2 σ s).2 h1, fun r a1 a2 => (ih1 hq.1 σ r).2 (h2 r a1 a2)⟩
  | stab a ih =>
    intro hq σ t
    exact forall_congr' fun ρ => imp_congr Iff.rfl (imp_congr Iff.rfl (ih hq ρ t))

/-- Finite conjunction. -/
def conj : List Fm → Fm
  | [] => Fm.top
  | φ :: l => Fm.and φ (conj l)

theorem conj_iff {D : Type} [LinearOrder D] (M : DModel D) (σ : D → M.C) (t : D) (l : List Fm) :
    TD M σ t (conj l) ↔ ∀ φ ∈ l, TD M σ t φ := by
  induction l with
  | nil => simp [conj, Fm.top, TD]
  | cons a l ih => simp [conj, and_iff, ih]

/-- `NOM_q(ψ)`: whatever the present state settles about `⟐ψ` and `⊡ψ`, every `q`-point settles
the same way. True whenever `q` names the present world state. -/
def nomClause (q : ℕ) (ψ : Fm) : Fm :=
  ((ψ.dstab).imp (((Fm.atom q).imp ψ.dstab).box)).and
    ((ψ.stab).imp (((Fm.atom q).imp ψ.stab).box))

/-- The antecedent of the state-naming rule. -/
def nomAnte (q : ℕ) (Ψ : List Fm) : Fm := (Fm.atom q).and (conj (Ψ.map (nomClause q)))

/-- The valuation that makes `q` name the state `w` and leaves every other letter alone. -/
def nameV {W : Type} (V : W → ℕ → Prop) (q : ℕ) (w : W) : W → ℕ → Prop :=
  fun c p => if p = q then c = w else V c p

section Naming
variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {W : Type}

/-- **The state-naming rule is sound**, frame by frame, over every temporal order, and with no
frame axiom: if `(q ∧ ⋀_{ψ ∈ Ψ} NOM_q(ψ)) → φ` holds at every point of every model on the frame
`R` and `q` does not occur in `φ`, then so does `φ`. (`Ψ` is arbitrary and may mention `q`.) -/
theorem state_name_sound (R : D → W → W → Prop) (q : ℕ) (φ : Fm) (Ψ : List Fm)
    (hq : φ.fresh q)
    (H : ∀ (V : W → ℕ → Prop) (σ : D → W), Hist R σ → ∀ t,
      TD (fullD R V) σ t ((nomAnte q Ψ).imp φ)) :
    ∀ (V : W → ℕ → Prop) (σ : D → W), Hist R σ → ∀ t, TD (fullD R V) σ t φ := by
  intro V σ hσ t
  have hV : ∀ c p, p ≠ q → (V c p ↔ nameV V q (σ t) c p) := by
    intro c p hp; simp [nameV, hp]
  refine (TD_fresh {τ | Hist R τ} V (nameV V q (σ t)) q hV φ hq σ t).2 (H _ σ hσ t ?_)
  refine (and_iff _ _ _ _ _).2 ⟨by show nameV V q (σ t) (σ t) q; simp [nameV], ?_⟩
  refine (conj_iff _ _ _ _).2 fun χ hχ => ?_
  obtain ⟨ψ, -, rfl⟩ := List.mem_map.1 hχ
  refine (and_iff _ _ _ _ _).2 ⟨?_, ?_⟩
  · intro hd ρ hρ hqρ
    have e : ρ t = σ t := by
      have : nameV V q (σ t) (ρ t) q := hqρ
      simpa [nameV] using this
    intro hst
    exact hd (stab_state_only R _ ψ.neg e hst)
  · intro hs ρ hρ hqρ
    have e : ρ t = σ t := by
      have : nameV V q (σ t) (ρ t) q := hqρ
      simpa [nameV] using this
    exact stab_state_only R _ ψ e.symm hs

end Naming

/-! ## Part R — the clock product at every temporal order -/

section Clock
variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {W : Type}
variable (R : D → W → W → Prop)

/-- The clock product `F × D`: a task of duration `x` advances the clock by `x`. -/
def clockP : D → W × D → W × D → Prop := fun x a b => R x a.1 b.1 ∧ b.2 = a.2 + x

/-- The lift of a history with clock offset `c`. -/
def liftC (ρ : D → W) (c : D) : D → W × D := fun x => (ρ x, c + x)

variable {R}

theorem lift_hist {ρ : D → W} (h : Hist R ρ) (c : D) : Hist (clockP R) (liftC ρ c) := by
  intro x y hxy
  refine ⟨h x y hxy, ?_⟩
  show c + y = c + x + (y - x)
  abel

/-- Histories of the clock product are exactly (history, offset) pairs: lifts are unique, so no
Extension Theorem is needed to move between `F` and `F × D`. -/
theorem clock_hist_iff {τ' : D → W × D} :
    Hist (clockP R) τ' ↔ Hist R (fun x => (τ' x).1) ∧ ∀ x, (τ' x).2 = (τ' 0).2 + x := by
  constructor
  · intro H
    refine ⟨fun x y h => (H x y h).1, fun x => ?_⟩
    rcases le_total 0 x with h | h
    · have := (H 0 x h).2
      rwa [sub_zero] at this
    · have := (H x 0 h).2
      rw [this]; abel
  · rintro ⟨H1, H2⟩ x y h
    refine ⟨H1 x y h, ?_⟩
    rw [H2 y, H2 x]; abel

/-- No history of the clock product visits a world state twice: recurrence of world states is
invisible to any language whose truth the projection preserves (`clock_invariance`). -/
theorem clock_no_recurrence {τ' : D → W × D} (H : Hist (clockP R) τ') {x y : D}
    (h : τ' x = τ' y) : x = y := by
  have h2 := (clock_hist_iff.1 H).2
  have : (τ' 0).2 + x = (τ' 0).2 + y := by rw [← h2 x, ← h2 y, h]
  exact add_left_cancel this

/-- Compositionality (both directions) is inherited. -/
theorem clock_comp
    (hC : ∀ x y, 0 ≤ x → 0 ≤ y → ∀ w v, R (x + y) w v ↔ ∃ u, R x w u ∧ R y u v) :
    ∀ x y, 0 ≤ x → 0 ≤ y → ∀ a b,
      clockP R (x + y) a b ↔ ∃ u, clockP R x a u ∧ clockP R y u b := by
  intro x y hx hy a b
  constructor
  · rintro ⟨h1, h2⟩
    obtain ⟨u, hu1, hu2⟩ := (hC x y hx hy _ _).1 h1
    exact ⟨(u, a.2 + x), ⟨hu1, rfl⟩, ⟨hu2, by rw [h2]; show a.2 + (x + y) = a.2 + x + y; abel⟩⟩
  · rintro ⟨u, ⟨h1, h2⟩, ⟨h3, h4⟩⟩
    exact ⟨(hC x y hx hy _ _).2 ⟨u.1, h1, h3⟩, by rw [h4, h2]; abel⟩

/-- Seriality (both directions) is inherited. -/
theorem clock_serial (hS : ∀ x, 0 ≤ x → ∀ w, (∃ u, R x w u) ∧ (∃ v, R x v w)) :
    ∀ x, 0 ≤ x → ∀ a, (∃ b, clockP R x a b) ∧ (∃ b, clockP R x b a) := by
  intro x hx a
  obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := hS x hx a.1
  exact ⟨⟨(u, a.2 + x), hu, rfl⟩, ⟨(v, a.2 - x), hv, by show a.2 = a.2 - x + x; abel⟩⟩

/-- The task relation extended to negative durations by the reflection convention. -/
def RrD (R : D → W → W → Prop) (y : D) (w u : W) : Prop :=
  (0 ≤ y ∧ R y w u) ∨ (y < 0 ∧ R (-y) u w)

/-- The manuscript's Limit: `⋂_{x > 0} (w)_x ⊆ {w}` (the other inclusion is Nullity). -/
def LimitD (R : D → W → W → Prop) : Prop :=
  ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ RrD R y w u) → u = w

/-- **Limit is free in the clock product**: it holds as soon as `⇒₀` is contained in the identity
in `F`, whatever the cones of `F` look like. -/
theorem clock_limit (hD : ∃ x : D, 0 < x) (hN : ∀ w v, R 0 w v → w = v) :
    LimitD (clockP R) := by
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

/-- **Truth is preserved by the clock projection**, at every temporal order and with no frame
axiom. Together with `clock_no_recurrence`: every model is equivalent, for the language with `⊡`,
to one in which no history revisits a world state. -/
theorem clock_invariance (R : D → W → W → Prop) (V : W → ℕ → Prop) :
    ∀ (φ : Fm) (τ' : D → W × D) (t : D), Hist (clockP R) τ' →
      (TD (fullD (clockP R) (fun a => V a.1)) τ' t φ ↔
        TD (fullD R V) (fun x => (τ' x).1) t φ) := by
  intro φ
  induction φ with
  | atom p => intro τ' t _; exact Iff.rfl
  | bot => intro τ' t _; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t h; exact imp_congr (ih1 τ' t h) (ih2 τ' t h)
  | box a ih =>
    intro τ' t _
    constructor
    · intro h ρ hρ
      exact (ih (liftC ρ 0) t (lift_hist hρ 0)).1 (h _ (lift_hist hρ 0))
    · intro h ρ' hρ'
      exact (ih ρ' t hρ').2 (h _ (clock_hist_iff.1 hρ').1)
  | untl a b ih1 ih2 =>
    intro τ' t hτ
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 τ' s hτ).1 h1, fun r a1 a2 => (ih1 τ' r hτ).1 (h2 r a1 a2)⟩
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 τ' s hτ).2 h1, fun r a1 a2 => (ih1 τ' r hτ).2 (h2 r a1 a2)⟩
  | snce a b ih1 ih2 =>
    intro τ' t hτ
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 τ' s hτ).1 h1, fun r a1 a2 => (ih1 τ' r hτ).1 (h2 r a1 a2)⟩
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 τ' s hτ).2 h1, fun r a1 a2 => (ih1 τ' r hτ).2 (h2 r a1 a2)⟩
  | stab a ih =>
    intro τ' t _
    constructor
    · intro h ρ hρ he
      have he' : (τ' t).1 = ρ t := he
      have hl := lift_hist hρ ((τ' t).2 - t)
      have e : τ' t = liftC ρ ((τ' t).2 - t) t := by
        apply Prod.ext
        · exact he'
        · show (τ' t).2 = (τ' t).2 - t + t
          abel
      exact (ih _ t hl).1 (h _ hl e)
    · intro h ρ' hρ' he
      exact (ih ρ' t hρ').2 (h _ (clock_hist_iff.1 hρ').1 (by show (τ' t).1 = (ρ' t).1; rw [he]))

end Clock

/-! ## Part S — reparametrisation invariance: the language sees order, never duration -/

section Repar
variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {W : Type}

/-- All order-automorphic reparametrisations of histories of `R`. -/
def reparB (R : D → W → W → Prop) : Set (D → W) :=
  {η | ∃ τ, Hist R τ ∧ ∃ f : D ≃o D, η = τ ∘ f}

/-- Re-timing histories independently, by arbitrary order automorphisms of `D`, changes no truth
value. So no formula of the language with `⊡` can say that two histories through the present state
reach anything *after the same duration*; synchrony across histories is what the stored-time
registers of the starred language add. -/
theorem repar_invariance (R : D → W → W → Prop) (V : W → ℕ → Prop) :
    ∀ (φ : Fm) (τ : D → W) (f : D ≃o D) (t : D),
      TD ⟨W, V, reparB R⟩ (τ ∘ f) t φ ↔ TD (fullD R V) τ (f t) φ := by
  intro φ
  induction φ with
  | atom p => intro τ f t; exact Iff.rfl
  | bot => intro τ f t; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ f t; exact imp_congr (ih1 τ f t) (ih2 τ f t)
  | box a ih =>
    intro τ f t
    constructor
    · intro h ρ hρ
      exact (ih ρ f t).1 (h _ ⟨ρ, hρ, f, rfl⟩)
    · rintro h η ⟨τ₁, hτ₁, g, rfl⟩
      refine (ih τ₁ g t).2 ?_
      have e : f t + (g t - f t) = g t := by abel
      have := (TD_shift R V a τ₁ (f t) (g t - f t)).1 (h _ (hist_shift hτ₁ _))
      rwa [e] at this
  | untl a b ih1 ih2 =>
    intro τ f t
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      refine ⟨f s, f.lt_iff_lt.2 hs, (ih2 τ f s).1 h1, fun r hr1 hr2 => ?_⟩
      have := (ih1 τ f (f.symm r)).1
        (h2 (f.symm r) (by rw [f.lt_symm_apply]; exact hr1) (by rw [f.symm_apply_lt]; exact hr2))
      rwa [f.apply_symm_apply] at this
    · rintro ⟨s, hs, h1, h2⟩
      refine ⟨f.symm s, by rw [f.lt_symm_apply]; exact hs,
        (ih2 τ f (f.symm s)).2 (by rwa [f.apply_symm_apply]), fun r hr1 hr2 => ?_⟩
      exact (ih1 τ f r).2 (h2 (f r) (f.lt_iff_lt.2 hr1) (by rw [← f.lt_symm_apply]; exact hr2))
  | snce a b ih1 ih2 =>
    intro τ f t
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      refine ⟨f s, f.lt_iff_lt.2 hs, (ih2 τ f s).1 h1, fun r hr1 hr2 => ?_⟩
      have := (ih1 τ f (f.symm r)).1
        (h2 (f.symm r) (by rw [f.lt_symm_apply]; exact hr1) (by rw [f.symm_apply_lt]; exact hr2))
      rwa [f.apply_symm_apply] at this
    · rintro ⟨s, hs, h1, h2⟩
      refine ⟨f.symm s, by rw [f.symm_apply_lt]; exact hs,
        (ih2 τ f (f.symm s)).2 (by rwa [f.apply_symm_apply]), fun r hr1 hr2 => ?_⟩
      exact (ih1 τ f r).2 (h2 (f r) (by rw [← f.symm_apply_lt]; exact hr1) (f.lt_iff_lt.2 hr2))
  | stab a ih =>
    intro τ f t
    constructor
    · intro h ρ hρ he
      exact (ih ρ f t).1 (h _ ⟨ρ, hρ, f, rfl⟩ he)
    · rintro h η ⟨τ₁, hτ₁, g, rfl⟩ he
      refine (ih τ₁ g t).2 ?_
      have e : f t + (g t - f t) = g t := by abel
      have he' : τ (f t) = τ₁ (g t) := he
      have := (TD_shift R V a τ₁ (f t) (g t - f t)).1
        (h _ (hist_shift hτ₁ _) (by show τ (f t) = τ₁ (f t + (g t - f t)); rw [e]; exact he'))
      rwa [e] at this

end Repar

/-! ## Part T — `⊡` is not Ockhamist historical necessity -/

section HN

/-- Three world states: two sources and a sink. -/
inductive S3 : Type where
  | a | b | c
  deriving DecidableEq

/-- `⇒₀` is the identity; for `n > 0`, `x ⇒ₙ y` iff `y = x` or `y = c`. The one-step relation is
reflexive and transitive, so `⇒ₙ` is its `n`-fold composite; `W` is finite, so Saturation holds
(`cor:saturation-finite`); Limit is automatic over ℤ. A genuine ℤ-time task frame. -/
def R3 : ℤ → S3 → S3 → Prop :=
  fun n x y => (n = 0 ∧ x = y) ∨ (0 < n ∧ (x = y ∨ y = S3.c))

def V3 : S3 → ℕ → Prop := fun x _ => x = S3.a
def σ3 : ℤ → S3 := fun n => if n < 0 then S3.a else S3.c
def ρ3 : ℤ → S3 := fun n => if n < 0 then S3.b else S3.c

theorem σ3_hist : Hist R3 σ3 := by
  intro x y h
  rcases eq_or_lt_of_le h with rfl | h'
  · left; simp
  · right
    refine ⟨by omega, ?_⟩
    by_cases hy : y < 0
    · left; simp [σ3, hy, (by omega : x < 0)]
    · right; simp [σ3, hy]

theorem ρ3_hist : Hist R3 ρ3 := by
  intro x y h
  rcases eq_or_lt_of_le h with rfl | h'
  · left; simp
  · right
    refine ⟨by omega, ?_⟩
    by_cases hy : y < 0
    · left; simp [ρ3, hy, (by omega : x < 0)]
    · right; simp [ρ3, hy]

/-- Compositionality of `R3`, both directions. -/
theorem R3_comp : ∀ x y : ℤ, 0 ≤ x → 0 ≤ y → ∀ w v,
    R3 (x + y) w v ↔ ∃ u, R3 x w u ∧ R3 y u v := by
  intro x y hx hy w v
  constructor
  · rintro (⟨h0, rfl⟩ | ⟨hpos, h⟩)
    · exact ⟨w, Or.inl ⟨by omega, rfl⟩, Or.inl ⟨by omega, rfl⟩⟩
    · rcases eq_or_lt_of_le hx with rfl | hx'
      · exact ⟨w, Or.inl ⟨rfl, rfl⟩, Or.inr ⟨by omega, h⟩⟩
      · exact ⟨v, Or.inr ⟨hx', h⟩, by
          rcases eq_or_lt_of_le hy with rfl | hy'
          · exact Or.inl ⟨rfl, rfl⟩
          · exact Or.inr ⟨hy', Or.inl rfl⟩⟩
  · rintro ⟨u, (⟨hx0, rfl⟩ | ⟨hxp, h1⟩), (⟨hy0, rfl⟩ | ⟨hyp, h2⟩)⟩
    · exact Or.inl ⟨by omega, rfl⟩
    · exact Or.inr ⟨by omega, h2⟩
    · exact Or.inr ⟨by omega, h1⟩
    · refine Or.inr ⟨by omega, ?_⟩
      rcases h2 with rfl | h2
      · exact h1
      · exact Or.inr h2

/-- The Ockhamist axiom HN, `Pα → □P◇α`, transposed to `⊡`. -/
def hnStab : Fm := ((Fm.atom 0).somePast).imp (((Fm.atom 0).dstab.somePast).stab)

/-- **HN fails for `⊡`**: histories through the present state need not share any of its past. -/
theorem hn_stab_refuted : ¬ TD (fullD R3 V3) σ3 0 hnStab := by
  intro h
  have h1 : TD (fullD R3 V3) σ3 0 (Fm.atom 0).somePast :=
    (somePast_iff _ _ _ _).2 ⟨-1, by norm_num, by show V3 (σ3 (-1)) 0; simp [V3, σ3]⟩
  have h2 := h h1 ρ3 ρ3_hist (by simp [σ3, ρ3])
  obtain ⟨s, hs, hd⟩ := (somePast_iff _ _ _ _).1 h2
  obtain ⟨η, -, he, hp⟩ := (dstab_iff _ _ _ _).1 hd
  have hp' : η s = S3.a := hp
  have he' : ρ3 s = η s := he
  rw [hp'] at he'
  simp [ρ3, hs] at he'

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {W : Type}

/-- HN does hold for the manuscript's open-future modality `▷` (`|τ⟩_x`: agree with `τ` at every
time up to and including `x`), the task-semantic counterpart of Ockhamist historical necessity. -/
theorem hn_open (R : D → W → W → Prop) (V : W → ℕ → Prop) (α : Fm) {σ : D → W} (hσ : Hist R σ)
    {t : D} (h : TD (fullD R V) σ t α.somePast) :
    ∀ ρ, Hist R ρ → (∀ n, n ≤ t → ρ n = σ n) → TD (fullD R V) ρ t α.dstab.somePast := by
  intro ρ _ hag
  obtain ⟨s, hs, hα⟩ := (somePast_iff _ _ _ _).1 h
  exact (somePast_iff _ _ _ _).2 ⟨s, hs, (dstab_iff _ _ _ _).2 ⟨σ, hσ, hag s hs.le, hα⟩⟩

/-- `⟨τ⟩_x ⊇ |τ⟩_x`: `⊡` is the stronger necessity, `▷` the weaker. -/
theorem stab_imp_open (B : Set (D → W)) (P : (D → W) → Prop) (σ : D → W) (t : D)
    (h : ∀ ρ ∈ B, σ t = ρ t → P ρ) : ∀ ρ ∈ B, (∀ n, n ≤ t → ρ n = σ n) → P ρ :=
  fun ρ hρ hag => h ρ hρ (hag t le_rfl).symm

end HN

end Probe559d
