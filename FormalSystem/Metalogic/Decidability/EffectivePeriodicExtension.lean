/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.EffectiveOrbit

/-!
# The Extension Theorem over an Enumerated Carrier, Choice-Free

A bounded convex history over a regular ℤ-frame whose carrier arrives as **data** extends to a
possible world that is ultimately periodic in both directions, with both periods bounded by the
length of the enumeration — and the whole thing measures `[propext, Quot.sound]`.

This is the effective form of the cut footnote's claim. Quoting the sentence it turns on,
verbatim from `JPL/appendix_cut_material.tex`:

> In this case, the conclusion of \textbf{\ref{thm:extension}} becomes effective without appeal
> to Zorn's lemma.

The existing distinction is preserved exactly: **no Zorn** is an import-graph fact — nothing here
imports the Extension Theorem or mentions `exists_maximal_extension` — and **choice-freedom** is
a separate and strictly stronger claim about a different axiom. Here both hold, and the second is
measured rather than asserted.

## Relation to `FrameOver.extend_periodic`

`FormalSystem.Semantics.FrameOver.extend_periodic` is the `[Finite W]` version, which is the
hypothesis the paper's own sentence literally supports. It is **left exactly as it is**, and it
is choice-carrying for two measured reasons, neither of them removable in place:

- its bound is `Nat.card F.WorldState`, and `Nat.card` goes through `Cardinal.toNat`, so the
  bound carries `Classical.choice` **in the statement** — before the proof is read;
- its successor and predecessor are `Classical.choose` of *Seriality*'s existentials, and its
  `Inhabited` instance is `Classical.inhabited_of_nonempty`.

No bridge between the two is attempted, and none exists.
`FormalSystem/Semantics/Extension/PeriodicExtension.lean`'s own module docstring explains why:
`Finite` is a `Prop` asserting that a bijection with some `Fin n` exists without producing one,
and every route out of it (`Fintype.ofFinite`, `Finset.toList`, `Multiset.toList`) measures
choice-carrying. The theorem below is proved directly, from the enumeration it is handed.

## The three substitutions, and the two traps

The construction is `extend_periodic`'s, with three substitutions: `succOfEnum` / `predOfEnum`
for the two `Classical.choose` selections, `exists_dup_of_enum` for `exists_repeat_of_card_le`,
and `worldHistoryOfStepPathInt` for `worldHistoryOfStepPath` at the final step.

Two things are deliberately **not** done, and both would silently restore `Classical.choice`:

- the proof never opens with `classical`, which installs `Classical.dec` and contaminates the
  profile wholesale, and it never reaches for Mathlib's `eq_or_lt_of_le`, which measures
  `[propext, Classical.choice, Quot.sound]` and quietly carries the same contamination into an
  otherwise clean proof — each of its two case splits over ℤ is discharged by `omega` instead;
- it never cases on `τ.domain t`, which carries no `Decidable` instance. The domain is rewritten
  through `hdom` to `a ≤ t ∧ t ≤ b` instead, which is decidable over ℤ, and the off-window filler
  is the window's own left endpoint value rather than a `default` drawn from an `Inhabited`
  instance that would have to be manufactured from `F.worldNonempty`.

## Main Definitions

- `fwdRun` / `bwdRun` — the two orbit segments as **lists**, in increasing time order, so the
  certificate layer can be assembled from this construction rather than re-deriving it

## Main Results

- `extend_periodic_enum` — the choice-free extension theorem
- `iterate_periodic_of_eq` — a repeat at `m < n` makes an iterate periodic with period `n - m`
  from index `m` onward

## Tags

effective · choice-free · extension-theorem · ultimately-periodic
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Semantics

/-- An orbit that repeats at `m < n` is periodic with period `n - m` from index `m` onward.

`Semantics/Extension/PeriodicExtension.lean` carries the same lemma as a `private` declaration,
so it is restated here rather than imported; it is three lines of `Function.iterate` arithmetic
and mentions no frame. -/
theorem iterate_periodic_of_eq {W : Type} (g : W → W) (w : W) {m n : ℕ}
    (h : g^[m] w = g^[n] w) (hmn : m ≤ n) {k : ℕ} (hk : m ≤ k) :
    g^[k + (n - m)] w = g^[k] w := by
  obtain ⟨d, rfl⟩ : ∃ d, k = m + d := ⟨k - m, by omega⟩
  rw [show m + d + (n - m) = d + n by omega, show m + d = d + m by omega,
    Function.iterate_add_apply, Function.iterate_add_apply, h]

section Runs

variable (F : FrameOver intOrder) [F.IsRegular] [DecidableRel F.step]
  (enum : List F.WorldState) (henum : ∀ w, w ∈ enum)

/-- The orbit indexing used throughout: `iterSuccEnum` is literally iteration of `succOfEnum`. -/
theorem iterSuccEnum_eq_iterate (w : F.WorldState) (n : ℕ) :
    iterSuccEnum F enum henum w n = (succOfEnum F enum henum)^[n] w := by
  induction n with
  | zero => rfl
  | succ n ih => rw [iterSuccEnum_succ, ih, Function.iterate_succ_apply']

/-- The backward mirror. -/
theorem iterPredEnum_eq_iterate (w : F.WorldState) (n : ℕ) :
    iterPredEnum F enum henum w n = (predOfEnum F enum henum)^[n] w := by
  induction n with
  | zero => rfl
  | succ n ih => rw [iterPredEnum_succ, ih, Function.iterate_succ_apply']

/-- `fwdRun w n` is the list of the first `n` states strictly after `w` on its forward orbit,
in increasing time order: `[succ w, succ² w, …, succⁿ w]`.

This is the data the certificate layer assembles its forward tail and forward cycle from, so
that the certificate is built from this module's construction rather than from a second run of
the same orbit argument. -/
def fwdRun (w : F.WorldState) (n : ℕ) : List F.WorldState :=
  (List.range n).map fun k => (succOfEnum F enum henum)^[k + 1] w

/-- `bwdRun w n` is the list of the first `n` states strictly before `w` on its backward orbit,
in **increasing time order**: `[predⁿ w, …, pred¹ w]`. The reversal is what makes it drop
straight into a left-to-right segment convention. -/
def bwdRun (w : F.WorldState) (n : ℕ) : List F.WorldState :=
  ((List.range n).map fun k => (predOfEnum F enum henum)^[k + 1] w).reverse

@[simp]
theorem fwdRun_length (w : F.WorldState) (n : ℕ) : (fwdRun F enum henum w n).length = n := by
  simp [fwdRun]

@[simp]
theorem bwdRun_length (w : F.WorldState) (n : ℕ) : (bwdRun F enum henum w n).length = n := by
  simp [bwdRun]

theorem fwdRun_getElem (w : F.WorldState) (n k : ℕ) (hk : k < n) :
    (fwdRun F enum henum w n)[k]'(by simpa using hk) =
      (succOfEnum F enum henum)^[k + 1] w := by
  simp [fwdRun]

theorem bwdRun_getElem (w : F.WorldState) (n k : ℕ) (hk : k < n) :
    (bwdRun F enum henum w n)[k]'(by simpa using hk) =
      (predOfEnum F enum henum)^[n - k] w := by
  simp only [bwdRun, List.getElem_reverse, List.length_map, List.length_range,
    List.getElem_map, List.getElem_range]
  congr 1
  omega

end Runs

-- linter.unusedDecidableInType, suppressed deliberately: `[DecidableEq F.WorldState]` and
-- `[DecidableRel F.step]` are consumed by the PROOF -- the first by `exists_dup_of_enum`, the
-- second by `succOfEnum` / `predOfEnum` -- and by neither the statement nor the conclusion. A
-- deletion trial was run: with both binders removed and `classical` supplying the instances,
-- the theorem still compiles and `#print axioms` reports
-- `[propext, Classical.choice, Quot.sound]` instead of `[propext, Quot.sound]`, which is
-- exactly the property this theorem exists to have. Both binders stay.
set_option linter.unusedDecidableInType false in
/--
**The choice-free extension theorem.**

A partial history whose domain is exactly the integer interval `[a, b]` extends to a possible
world ultimately periodic in *both* directions, with both periods positive and bounded by the
length of the supplied enumeration: some `n₁` past which the world repeats with period `p₁`, and
some `n₀` before which it repeats with period `p₀`.

The carrier arrives as data — `enum` together with `henum : ∀ w, w ∈ enum` — which is what makes
the bound `enum.length` rather than `Nat.card F.WorldState`, and the whole theorem
`[propext, Quot.sound]` rather than choice-carrying. See this module's docstring for the
accounting, the relation to `FrameOver.extend_periodic`, and the two traps the proof avoids.

Both `[DecidableEq F.WorldState]` and `[DecidableRel F.step]` are load-bearing in the **proof**
— the first for `exists_dup_of_enum`, the second for `succOfEnum` / `predOfEnum` — and neither
appears in the **type**. The standing remedy for that lint, dropping the binders and reaching
for `classical`, is precisely the thing this theorem exists to avoid, so the binders stay and
the lint is scoped off above.

Paper: — (the specification is cut material; see
`docs/reference/paper-definitions-of-record.md`, "The finite-case effectiveness footnote")
-/
theorem extend_periodic_enum {F : FrameOver intOrder} [F.IsRegular]
    [DecidableEq F.WorldState] [DecidableRel F.step]
    (enum : List F.WorldState) (henum : ∀ w, w ∈ enum)
    (τ : PartialHistory F.toTaskFrame) (a b : ℤ) (hab : a ≤ b)
    (hdom : ∀ t : ℤ, τ.domain t ↔ a ≤ t ∧ t ≤ b) :
    ∃ σ : WorldHistory F, PartialHistory.Extends σ.val τ ∧
      ∃ n₀ p₀ n₁ p₁ : ℤ, 0 < p₀ ∧ 0 < p₁ ∧
        p₀ ≤ (enum.length : ℤ) ∧ p₁ ≤ (enum.length : ℤ) ∧
        (∀ x : ℤ, n₁ ≤ x → σ.path (x + p₁) = σ.path x) ∧
        (∀ x : ℤ, x ≤ n₀ → σ.path (x - p₀) = σ.path x) := by
  have ha : τ.domain a := (hdom a).mpr ⟨le_refl a, hab⟩
  set sc : F.WorldState → F.WorldState := succOfEnum F enum henum with hscdef
  set pr : F.WorldState → F.WorldState := predOfEnum F enum henum with hprdef
  have hsc : ∀ w, F.step w (sc w) := succOfEnum_step F enum henum
  have hpr : ∀ w, F.step (pr w) w := predOfEnum_step F enum henum
  -- The window's states, extended off the window by the window's own left endpoint value.
  -- The domain is read through `hdom`, which is decidable over ℤ; `τ.domain` itself is not.
  set g : ℤ → F.WorldState :=
    fun t => if h : a ≤ t ∧ t ≤ b then τ.states t ((hdom t).mpr h) else τ.states a ha with hg
  have hgdom : ∀ (t : ℤ) (ht : τ.domain t), g t = τ.states t ht := by
    intro t ht
    rw [hg]
    exact dif_pos ((hdom t).mp ht)
  -- The extended path: the window in the middle, the two orbits outside it.
  set f : ℤ → F.WorldState := fun t =>
    if t < a then pr^[(a - t).toNat] (g a)
    else if t ≤ b then g t
    else sc^[(t - b).toNat] (g b) with hfdef
  have hfa : f a = g a := by
    simp only [hfdef]
    rw [if_neg (by omega), if_pos hab]
  have hfb : f b = g b := by
    simp only [hfdef]
    rw [if_neg (by omega), if_pos (le_refl b)]
  have hflt : ∀ t : ℤ, t < a → f t = pr^[(a - t).toNat] (g a) := by
    intro t ht
    simp only [hfdef]
    rw [if_pos ht]
  have hfgt : ∀ t : ℤ, b < t → f t = sc^[(t - b).toNat] (g b) := by
    intro t ht
    simp only [hfdef]
    rw [if_neg (by omega), if_neg (by omega)]
  have hfmid : ∀ t : ℤ, a ≤ t → t ≤ b → f t = g t := by
    intro t h1 h2
    simp only [hfdef]
    rw [if_neg (by omega), if_pos h2]
  -- `f` is a bi-infinite step path: two orbits, two seams, and the window itself.
  have hstep : IsStepPath F f := by
    intro t
    rcases lt_or_ge t (a - 1) with h1 | h1
    · rw [hflt t (by omega), hflt (t + 1) (by omega),
        show (a - t).toNat = (a - (t + 1)).toNat + 1 by omega,
        Function.iterate_succ_apply']
      exact hpr _
    rcases (by omega : a - 1 = t ∨ a - 1 < t) with h2 | h2
    · rw [hflt t (by omega), show (a - t).toNat = 1 by omega,
        show t + 1 = a by omega, hfa]
      simpa using hpr (g a)
    rcases lt_or_ge t b with h3 | h3
    · have ht1 : τ.domain (t + 1) := (hdom (t + 1)).mpr ⟨by omega, by omega⟩
      have ht0 : τ.domain t := (hdom t).mpr ⟨by omega, by omega⟩
      rw [hfmid t (by omega) (by omega), hfmid (t + 1) (by omega) (by omega)]
      have hrel := τ.respects_task t (t + 1) ht0 ht1
      rw [show t + 1 - t = (1 : ℤ) by omega] at hrel
      rw [hgdom t ht0, hgdom (t + 1) ht1]
      exact (F.taskRel_one_iff_step _ _).mp hrel
    rcases (by omega : b = t ∨ b < t) with h4 | h4
    · rw [← h4, hfb, hfgt (b + 1) (by omega), show (b + 1 - b).toNat = 1 by omega]
      simpa using hsc (g b)
    · rw [hfgt t (by omega), hfgt (t + 1) (by omega),
        show (t + 1 - b).toNat = (t - b).toNat + 1 by omega,
        Function.iterate_succ_apply']
      exact hsc _
  refine ⟨FrameOver.worldHistoryOfStepPathInt F f hstep, ⟨fun _ _ => trivial, ?_⟩, ?_⟩
  · intro t ht
    obtain ⟨h1, h2⟩ := (hdom t).mp ht
    change f t = τ.states t ht
    rw [hfmid t h1 h2]
    exact hgdom t ht
  -- Both periodicities, from a revisit in each orbit — pigeonhole at `enum.length`.
  obtain ⟨i₁, j₁, hij₁, hj₁, heq₁⟩ :=
    exists_dup_of_enum enum henum (enum.length + 1) (by omega) (fun k => sc^[k] (g b))
  obtain ⟨i₀, j₀, hij₀, hj₀, heq₀⟩ :=
    exists_dup_of_enum enum henum (enum.length + 1) (by omega) (fun k => pr^[k] (g a))
  refine ⟨a - (i₀ : ℤ) - 1, ((j₀ - i₀ : ℕ) : ℤ), b + (i₁ : ℤ) + 1, ((j₁ - i₁ : ℕ) : ℤ),
    by omega, by omega, by omega, by omega, ?_, ?_⟩
  · intro x hx
    change f (x + ((j₁ - i₁ : ℕ) : ℤ)) = f x
    rw [hfgt _ (by omega), hfgt _ (by omega),
      show (x + ((j₁ - i₁ : ℕ) : ℤ) - b).toNat = (x - b).toNat + (j₁ - i₁) by omega]
    exact iterate_periodic_of_eq sc (g b) heq₁ (by omega) (by omega)
  · intro x hx
    change f (x - ((j₀ - i₀ : ℕ) : ℤ)) = f x
    rw [hflt _ (by omega), hflt _ (by omega),
      show (a - (x - ((j₀ - i₀ : ℕ) : ℤ))).toNat = (a - x).toNat + (j₀ - i₀) by omega]
    exact iterate_periodic_of_eq pr (g a) heq₀ (by omega) (by omega)

end FormalSystem.Metalogic.Decidability
