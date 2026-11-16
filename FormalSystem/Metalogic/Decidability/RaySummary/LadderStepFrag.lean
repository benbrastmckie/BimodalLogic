/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize

/-!
# The step system: a back-and-forth on ladder states, and the cell agreement on the step fragment

The **step fragment** `StepFrag` admits every connective of the language, `⊡` and `□` included,
with `untl` and `snce` admitted only at the guard `⊥` — that is, as `X` and its mirror. On that
fragment this module lands a derived relation on ladder states, its one-step back-and-forth, the
path-level link the `⊡` clause needs, the truth lemma, and the agreement of cells as a corollary,
for an ARBITRARY finite object `(step, pend, lab)`.

## What is landed

* `Zrel a b` — a relation on ladder states indexed by a budget of `a` backward and `b` forward
  steps: same object state, countdowns equal or both `≥ 2 (a + b)`, registers equal or both
  `≥ 2 (a + b)`, gaps `n - c` equal, or both `≥ 2 a`, or both `≤ -(2 b + 2)`.
* `Zrel.succ`, `Zrel.pred` — the one-step back-and-forth, for every object `(step, pend)`.
* `exists_linked_path` — the path forth: a state related to the state a ladder path visits lies on
  a ladder path linked to it (`Lnk`) on the whole window. This is the `⊡` clause.
* `truth_iff_of_lnk` — the truth lemma on the step fragment, `⊡` and `□` included.
* `cellAt_eq_of_Zrel` — related states have the same cell.

Supporting declarations: `glue`, `glue_isPath`, `exists_path_through`, `Lnk`, `Lnk.succ`,
`Lnk.pred`, `StepFrag`, `frag_of_mem`, `truth_nxt`, `truth_prv`, `cellAt_subset_of_Zrel`.

The row link and the truth lemma over it are landed beside it; the path forth that would PRODUCE
row-linked pairs at a positive budget is not:

* `LnkRow a b g g' t t'` — the row link: the states at position `t` of `g` and `t'` of `g'` are
  related at the budget `(a, b)`, and for each jump the budget still allows the jump condition
  (`FwdJump`, `BwdJump`) holds in both directions at the budget left after it.
* `LnkRow.symm`, `LnkRow.mono`, `LnkRow.zero` — symmetry, monotonicity in the two budgets, and
  the state relation at the linked pair.
* `LnkRow.succ`, `LnkRow.pred`, `LnkRow.toLnk` — a jump to the adjacent position is answered at
  the adjacent position, so a row link at one position of both paths restricts to the window link
  `Lnk a b` there.
* `exists_rowLinked_path_zero` — the `⊡` clause against the row link at the budget `(0, 0)`.
* `LnkRow.refl` — every position of a row answers itself.
* `RowFrag`, `truth_iff_of_lnkRow` — the truth lemma over the row link at the `⊡`-free level:
  two ladder histories whose paths are row-linked at `(t, t')` agree there on every formula with
  no `⊡` and no `□`, `untl` and `snce` at EVERY guard.  No path is constructed in it.
* `LnkRow.first_zero`, `LnkRow.region_end_obj` — a NECESSARY condition on a row link: with one
  forward jump and one further unit of budget, the two current pending regions end at the same
  object state.

The residue-carrying relation is landed beside the row link, and it is not the hypothesis of the
owed path forth either:

* `Srel P a b` — `Zrel a b` with the two countdowns congruent modulo `P + 1`, the modulus `(K1)`
  constrains.  `Srel.refl`, `Srel.symm`, `Srel.mono`, `Srel.toZrel`.

The threshold-carrying relation is landed beside it, with NO verdict on it either way:

* `Mrel P a b` — `Srel P a b` with the two countdowns equal or both at least `(P + 1) * (a + b)`.
  `Mrel.refl`, `Mrel.symm`, `Mrel.mono`, `Mrel.toSrel`, `Mrel.toZrel`.  Neither a path forth from
  it nor a refutation of one is landed; see the section docstring for what was attacked and what
  the attacks compiled instead.

## Two properties of the system, and one obligation it leaves owed

1. **The agreement follows from the truth lemma with no `ParamsOk` hypothesis.**
   `cellAt_eq_of_Zrel` consumes `truth_iff_of_lnk` and nothing from the parameter layer. The
   parameters enter only where a `kappa`-collision is turned into membership of `Zrel`, a bridge
   stated in the wired probe
   `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean` and not in this
   module. The parameter conditions are a BRIDGE from the counter-class invariant to the derived
   relation, not an input to the agreement itself.
2. **The thresholds are SOLUTIONS of one-step closure conditions, not choices.** Writing `G⁺`,
   `G⁻` for the upper and lower gap thresholds and `T`, `N` for the countdown and register
   thresholds at the budget `(a, b)`, the one-step lemmas need
   `G⁺(a, b) ≥ G⁺(a−1, b) + 2`, `G⁻(a, b) ≥ G⁻(a, b−1) + 2`, `T(a, b) ≥ N(a−1, b)`,
   `N(a, b) ≥ T(a, b−1)` and `N(a, b) − 1 ≥ G⁺(a−1, b)`, whose solution is `G⁺ = 2 a`,
   `G⁻ = 2 b + 2`, `T = N = 2 (a + b)`. The relation is indexed by TWO budgets deliberately: a
   single budget `a + b` gives a gap clip of `2 (dBack + dFwd)` but hides that the two arms
   differ — `2 * dBack` against `2 * dFwd + 2` — an asymmetry `paramsOkK4`'s clip
   `max (2 dBack + 1) (2 dFwd + 1) 2` does not carry.
3. **OWED, NOT DISCHARGED.** Wherever the system is instantiated at a formula, the thresholds
   `2 * (dBack φ + dFwd φ) ≤ Tc` and `2 * (dBack φ + dFwd φ) ≤ Tn` arrive as EXPLICIT HYPOTHESES.
   That they lie below `Tcof` and `Tnof` is plausible and is compiled nowhere; nothing in this
   module asserts it.

## The row link, and the two jump clauses it leaves owed

Dropping the guard `⊥` from the `untl` case of `truth_iff_of_lnk` leaves, with
`M := ladderModel step pend fwd bwd lab`,

```
hl : Lnk a b g g' t
⊢ PlusTruthAt M τ t (γ.untl α) ↔ PlusTruthAt M τ' t (γ.untl α)
```

whose two sides unfold to `∃ s, t < s ∧ PlusTruthAt M τ s α ∧ ∀ r, t < r → r < s →
PlusTruthAt M τ r γ` and the same over `τ'`. `Lnk` constrains the positions of `[t - a, t + b]`
only, so a witness `s > t + b` is unconstrained: the gap is in the link relation, not in the
induction. `LnkRow` is the relation that goal reads, with nothing added: a witness on one row is
answered by a witness on the other, every position the answer passes is answered back, and the
answering pairs are linked at the budget left after the jump. It relates a position of one path to
a position of the other, since the answer to a far witness need not sit at the same distance; the
window is recovered as a theorem (`LnkRow.toLnk`), not assumed.

**The truth lemma over the row link** is `truth_iff_of_lnkRow`, with `RowFrag` the predicate "no
`⊡` and no `□`".  Its `untl` case reads the two forward jump conditions of the link and its
`snce` case the two backward ones.  It is a statement about pairs of paths that ARE row-linked
and produces none: on its own it yields no agreement of cells.

**The path forth with a whole-row correspondence is OWED.** It is written here as text, and no
declaration of this module carries its name:

```
exists_rowLinked_path :
  IsLadderPath step pend h → S a b (h t) y →
    ∃ h', IsLadderPath step pend h' ∧ h' t = y ∧ LnkRow a b h h' t t
```

for a state relation `S a b` that is NOT fixed here. Four facts bound what it can be.

0. **`S a b` cannot be `Zrel A B` at ANY budgets `(A, B)`, nor any relation that leaves the
   countdown unconstrained above a threshold.** `LnkRow.region_end_obj` shows a row link at a
   budget `(a, b + 1)` with `1 ≤ a + b` forces the two current pending regions to end at the same
   object state: `objAt g' (t' + cntAt g' t') = objAt g (t + cntAt g t)`.  When the countdowns
   differ these are walks of two different lengths, and on an object whose pending part is a
   `2`-cycle the two ends differ whenever the countdowns differ in parity.  The wired probe
   `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` compiles
   this (`no_rowLinked_path_of_Zrel`): for every `(A, B)` there are `Zrel A B`-related states
   with a ladder path through the first and NO row-linked ladder path through the second.  So
   `S` must carry a condition that depends on the OBJECT — a residue of the countdown — and
   `Zrel`'s own shape (thresholds that are solutions of one-step closure conditions, for every
   object) does not survive a jump.  The attempt at the path forth stops at its first step, the
   choice of `h'`, at the goal

   ```
   hq : (h t).1.1 = y.1.1
   hc : 1 ≤ cntAt h t
   hne : cntAt h t ≠ y.1.2.1
   hbig : 2 * (a + (b + 2) + 1 + (a + (b + 2))) ≤ cntAt h t ∧
     2 * (a + (b + 2) + 1 + (a + (b + 2))) ≤ y.1.2.1
   ⊢ ∃ h', IsLadderPath step pend h' ∧ h' t = y ∧ LnkRow a (b + 2) h h' t t
   ```

   which the probe shows has no solution on that object.
1. **`S a b` cannot be `Zrel a b`, for a second and independent reason.** The wired probe
   `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` compiles a
   formula family `mixC a k` (`k ≥ 1`) with `dBack = a`, `dFwd = k + 2` that holds throughout
   the cell at the gap `2 a + k` (`mixC_mem`) and fails throughout the cell at every gap
   `≥ 2 a + k + 1` (`mixC_not_mem`). Two pending states with one countdown, registers both
   `≥ 2 (a + k + 2)` and those two gaps satisfy `Zrel a (k + 2)` — both gaps are `≥ 2 a` — and
   have different cells, so `S a b := Zrel a b` would contradict the two owed clauses taken with
   their `⊡` lift. This consequence is ARGUED from the two compiled statements and the
   definition of `Zrel`; it is compiled nowhere.
2. **The lower-bound envelope.** Any gap clip `F (dBack, dFwd)` under which the agreement holds
   on the whole language satisfies `F (a, b) ≥ max (2 a + b - 1) (2 b + 2)`, by three compiled
   families of the wired probes: `sigC b` (depths `(1, b)`, needs `2 b + 2`), `thetaC` (depths
   `(1, 1)`, needs `4`), `mixC a k` (depths `(a, k + 2)`, needs `2 a + k + 1`). The clip
   `2 (a + b) + 2` dominates the envelope; the candidate `S a b := Zrel (a + b + 1) (a + b)`
   carries that clip on both gap arms.
3. **What is proved and what is refuted.** The step-fragment clip
   `max (2 dBack) (2 dFwd + 2)` is PROVED and TIGHT on the forward arm. The clip `2 (a + b) + 2`
   does NOT suffice on the whole language: the family `dblC j` of the wired probe
   `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` pays one `snce`
   at the guard `p` per doubling of the idle register, has depths `(j, 3)`, and separates the gap
   `2 ^ (j + 1) - 1` from the gap one modulus above it (`repaired_clip_refuted`,
   `gap_clip_below_exponential_refuted`). So `F (a, 3) ≥ 2 ^ (a + 1)`: no clip polynomial in the
   two depths works, and whether a clip exponential in `dBack` does is OPEN.

## The fragment boundary

No AGREEMENT OF CELLS here concerns a formula with an `untl` or `snce` at a guard other than `⊥`.
The truth lemma's window `Lnk` has width `a + b` and says nothing about a witness further away,
which is what an unbounded jump reads; `truth_iff_of_lnkRow` does read it, but only between paths
already row-linked, and no such pair is produced at a positive budget. The separating families
`thetaC` and `mixC` each use one such jump and are NOT covered, so nothing landed here weakens,
qualifies or bears on
`cellAt_const_of_kappa_eq_schema_refuted` or `no_fibre_equation_over_kappa`. No agreement over
`kappa`-classes, no fibre equation, no soundness or lift statement and no certificate inclusion is
stated in this module; every quantity named is a count, and no complexity bound is claimed.
-/

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-! ### The derived state relation -/

section StateSys

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE DERIVED RELATION.** Two ladder states are related at the budget `(a, b)` — `a` backward
steps and `b` forward steps still to be read — when they carry the same object state, their
countdowns are equal or both at least `2 (a + b)`, their registers are equal or both at least
`2 (a + b)`, and their gaps `n - c` are equal, or both at least `2 a`, or both at most
`-(2 b + 2)`.  Every threshold is the solution of a one-step closure condition
(`Zrel.succ`, `Zrel.pred`); none is chosen. -/
def Zrel (a b : ℕ) (x y : LadderState Q pend) : Prop :=
  x.1.1 = y.1.1 ∧
  (x.1.2.1 = y.1.2.1 ∨ (2 * (a + b) ≤ x.1.2.1 ∧ 2 * (a + b) ≤ y.1.2.1)) ∧
  (x.1.2.2 = y.1.2.2 ∨ (2 * (a + b) ≤ x.1.2.2 ∧ 2 * (a + b) ≤ y.1.2.2)) ∧
  ((x.1.2.2 : ℤ) - x.1.2.1 = (y.1.2.2 : ℤ) - y.1.2.1 ∨
    (2 * (a : ℤ) ≤ (x.1.2.2 : ℤ) - x.1.2.1 ∧ 2 * (a : ℤ) ≤ (y.1.2.2 : ℤ) - y.1.2.1) ∨
    ((x.1.2.2 : ℤ) - x.1.2.1 ≤ -(2 * (b : ℤ) + 2) ∧
      (y.1.2.2 : ℤ) - y.1.2.1 ≤ -(2 * (b : ℤ) + 2)))

theorem Zrel.refl (a b : ℕ) (x : LadderState Q pend) : Zrel a b x x :=
  ⟨rfl, Or.inl rfl, Or.inl rfl, Or.inl rfl⟩

theorem Zrel.symm {a b : ℕ} {x y : LadderState Q pend} (h : Zrel a b x y) : Zrel a b y x := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨h1.symm, ?_, ?_, ?_⟩ <;> omega

theorem Zrel.mono {a b a' b' : ℕ} {x y : LadderState Q pend} (ha : a' ≤ a) (hb : b' ≤ b)
    (h : Zrel a b x y) : Zrel a' b' x y := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨h1, ?_, ?_, ?_⟩ <;> omega

/-- **ONE STEP FORWARD.** -/
theorem Zrel.succ {a b : ℕ} {x y x₁ : LadderState Q pend} {t : ℤ}
    (hZ : Zrel a (b + 1) x y) (hs : RladAdm step pend t x x₁) :
    ∃ y₁ : LadderState Q pend, RladAdm step pend t y y₁ ∧ Zrel a b x₁ y₁ := by
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  obtain ⟨⟨q', c', n'⟩, hy⟩ := y
  obtain ⟨⟨q₁, c₁, n₁⟩, hx₁⟩ := x₁
  obtain ⟨hq, hc, hn, hgap⟩ := hZ
  obtain ⟨hst, -, hdr, hcnt⟩ := hs
  dsimp only at hq hc hn hgap hst hdr hcnt
  subst hq
  have hx' : pend q = false → c = 0 := hx
  have hy' : pend q = false → c' = 0 := hy
  unfold Drift at hdr
  cases hp : pend q <;> cases hp1 : pend q₁
  · -- idle to idle
    have h0 : c = 0 := hx' hp
    have h0' : c' = 0 := hy' hp
    have hc1 : c₁ = 0 := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, 0, n' + n₁ - n), fun _ => rfl⟩, ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · change Count (pend q) (pend q₁) c' n' 0
      simp [Count, hp, hp1]
    · change c₁ = 0 ∨ _
      exact Or.inl hc1
    · change n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · change (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧ 2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- idle to pending: the countdown is handed the register
    have h0 : c = 0 := hx' hp
    have h0' : c' = 0 := hy' hp
    have hc1 : c₁ = n := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, n', n' + n₁ - n), fun h => by rw [hp1] at h; cases h⟩,
      ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · change Count (pend q) (pend q₁) c' n' n'
      simp [Count, hp, hp1]
    · change c₁ = n' ∨ (2 * (a + b) ≤ c₁ ∧ 2 * (a + b) ≤ n')
      omega
    · change n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · change (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧ 2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - (n' : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending to idle: the countdown is exhausted
    have hc1 : c₁ = 0 ∧ c = 0 := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, 0, n' + n₁ - n), fun _ => rfl⟩, ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · change Count (pend q) (pend q₁) c' n' 0
      have : c' = 0 := by omega
      simp [Count, hp, hp1, this]
    · change c₁ = 0 ∨ _
      exact Or.inl hc1.1
    · change n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · change (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧ 2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending to pending: the countdown falls by one
    have hc1 : c₁ + 1 = c := by simpa [Count, hp, hp1] using hcnt
    refine ⟨⟨(q₁, c' - 1, n' + n₁ - n), fun h => by rw [hp1] at h; cases h⟩,
      ⟨hst, hy, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift n' (n' + n₁ - n)
      unfold Drift; omega
    · change Count (pend q) (pend q₁) c' n' (c' - 1)
      have : c' - 1 + 1 = c' := by omega
      simp [Count, hp, hp1, this]
    · change c₁ = c' - 1 ∨ (2 * (a + b) ≤ c₁ ∧ 2 * (a + b) ≤ c' - 1)
      omega
    · change n₁ = n' + n₁ - n ∨ (2 * (a + b) ≤ n₁ ∧ 2 * (a + b) ≤ n' + n₁ - n)
      omega
    · change (n₁ : ℤ) - c₁ = ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ) ∨
        (2 * (a : ℤ) ≤ (n₁ : ℤ) - c₁ ∧
          2 * (a : ℤ) ≤ ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ)) ∨
        ((n₁ : ℤ) - c₁ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₁ - n : ℕ) : ℤ) - ((c' - 1 : ℕ) : ℤ) ≤ -(2 * (b : ℤ) + 2))
      omega

/-- **ONE STEP BACKWARD.** -/
theorem Zrel.pred {a b : ℕ} {x y x₀ : LadderState Q pend} {t : ℤ}
    (hZ : Zrel (a + 1) b x y) (hs : RladAdm step pend t x₀ x) :
    ∃ y₀ : LadderState Q pend, RladAdm step pend t y₀ y ∧ Zrel a b x₀ y₀ := by
  obtain ⟨⟨q, c, n⟩, hx⟩ := x
  obtain ⟨⟨q', c', n'⟩, hy⟩ := y
  obtain ⟨⟨q₀, c₀, n₀⟩, hx₀⟩ := x₀
  obtain ⟨hq, hc, hn, hgap⟩ := hZ
  obtain ⟨hst, hsrc, hdr, hcnt⟩ := hs
  dsimp only at hq hc hn hgap hst hsrc hdr hcnt
  subst hq
  have hx' : pend q = false → c = 0 := hx
  have hy' : pend q = false → c' = 0 := hy
  unfold Drift at hdr
  cases hp0 : pend q₀ <;> cases hp : pend q
  · -- idle before idle
    have h0 : c = 0 := hx' hp
    have h0' : c' = 0 := hy' hp
    have hc0 : c₀ = 0 := hsrc hp0
    refine ⟨⟨(q₀, 0, n' + n₀ - n), fun _ => rfl⟩, ⟨hst, fun _ => rfl, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · change Count (pend q₀) (pend q) 0 (n' + n₀ - n) c'
      simp [Count, hp0, hp, h0']
    · change c₀ = 0 ∨ _
      exact Or.inl hc0
    · change n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · change (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧ 2 * (a : ℤ) ≤ ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- idle before pending: a region entry, which pins the gap inside `[-1, 1]`
    have hc0 : c₀ = 0 := hsrc hp0
    have hcn : c = n₀ := by simpa [Count, hp0, hp] using hcnt
    refine ⟨⟨(q₀, 0, c'), fun _ => rfl⟩, ⟨hst, fun _ => rfl, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift c' n'
      unfold Drift; omega
    · change Count (pend q₀) (pend q) 0 c' c'
      simp [Count, hp0, hp]
    · change c₀ = 0 ∨ _
      exact Or.inl hc0
    · change n₀ = c' ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ c')
      omega
    · change (n₀ : ℤ) - c₀ = (c' : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧ 2 * (a : ℤ) ≤ (c' : ℤ) - (0 : ℕ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧ (c' : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending before idle: the last pending position
    have h0' : c' = 0 := hy' hp
    have hcc : c = 0 ∧ c₀ = 0 := by simpa [Count, hp0, hp] using hcnt
    refine ⟨⟨(q₀, 0, n' + n₀ - n), fun _ => rfl⟩, ⟨hst, fun _ => rfl, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · change Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · change Count (pend q₀) (pend q) 0 (n' + n₀ - n) c'
      simp [Count, hp0, hp, h0']
    · change c₀ = 0 ∨ _
      exact Or.inl hcc.2
    · change n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · change (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧ 2 * (a : ℤ) ≤ ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₀ - n : ℕ) : ℤ) - (0 : ℕ) ≤ -(2 * (b : ℤ) + 2))
      omega
  · -- pending before pending
    have hcc : c + 1 = c₀ := by simpa [Count, hp0, hp] using hcnt
    refine ⟨⟨(q₀, c' + 1, n' + n₀ - n), fun h => by rw [hp0] at h; cases h⟩,
      ⟨hst, ?_, ?_, ?_⟩, ⟨rfl, ?_, ?_, ?_⟩⟩
    · intro h
      rw [show pend (q₀, c' + 1, n' + n₀ - n).1 = pend q₀ from rfl, hp0] at h
      cases h
    · change Drift (n' + n₀ - n) n'
      unfold Drift; omega
    · change Count (pend q₀) (pend q) (c' + 1) (n' + n₀ - n) c'
      simp [Count, hp0, hp]
    · change c₀ = c' + 1 ∨ (2 * (a + b) ≤ c₀ ∧ 2 * (a + b) ≤ c' + 1)
      omega
    · change n₀ = n' + n₀ - n ∨ (2 * (a + b) ≤ n₀ ∧ 2 * (a + b) ≤ n' + n₀ - n)
      omega
    · change (n₀ : ℤ) - c₀ = ((n' + n₀ - n : ℕ) : ℤ) - ((c' + 1 : ℕ) : ℤ) ∨
        (2 * (a : ℤ) ≤ (n₀ : ℤ) - c₀ ∧
          2 * (a : ℤ) ≤ ((n' + n₀ - n : ℕ) : ℤ) - ((c' + 1 : ℕ) : ℤ)) ∨
        ((n₀ : ℤ) - c₀ ≤ -(2 * (b : ℤ) + 2) ∧
          ((n' + n₀ - n : ℕ) : ℤ) - ((c' + 1 : ℕ) : ℤ) ≤ -(2 * (b : ℤ) + 2))
      omega

end StateSys

/-! ### Paths: gluing, a path through every state, and the window link -/

section Paths

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- Follow `g₁` up to and including `z`, and `g₂` from `z + 1` on. -/
def glue (g₁ g₂ : ℤ → LadderState Q pend) (z : ℤ) : ℤ → LadderState Q pend :=
  fun v => if v ≤ z then g₁ v else g₂ v

theorem glue_isPath (g₁ g₂ : ℤ → LadderState Q pend)
    (h₁ : IsLadderPath step pend g₁) (h₂ : IsLadderPath step pend g₂) (z : ℤ)
    (hz : RladAdm step pend z (g₁ z) (g₂ (z + 1))) :
    IsLadderPath step pend (glue g₁ g₂ z) := by
  intro u
  unfold glue
  by_cases h : u + 1 ≤ z
  · rw [if_pos (by omega), if_pos h]
    exact h₁ u
  · by_cases h' : u ≤ z
    · have hu : u = z := by omega
      subst hu
      rw [if_pos le_rfl, if_neg h]
      exact hz
    · rw [if_neg h', if_neg h]
      exact h₂ u

theorem glue_of_le (g₁ g₂ : ℤ → LadderState Q pend) (z v : ℤ) (h : v ≤ z) :
    glue g₁ g₂ z v = g₁ v := by
  unfold glue; rw [if_pos h]

theorem glue_of_gt (g₁ g₂ : ℤ → LadderState Q pend) (z v : ℤ) (h : z < v) :
    glue g₁ g₂ z v = g₂ v := by
  unfold glue; rw [if_neg (by omega)]

/-- **A LADDER PATH THROUGH EVERY STATE, AT EVERY POSITION**, from the two seriality hypotheses
the frame is built on and nothing else. -/
theorem exists_path_through
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (x : LadderState Q pend) (z : ℤ) :
    ∃ g : ℤ → LadderState Q pend, IsLadderPath step pend g ∧ g z = x := by
  classical
  choose F hF using fwd 0
  choose G hG using bwd 0
  refine ⟨fun v => if z ≤ v then F^[(v - z).toNat] x else G^[(z - v).toNat] x, ?_, ?_⟩
  · intro u
    show RladAdm step pend u _ _
    beta_reduce
    by_cases h : z ≤ u
    · rw [if_pos h, if_pos (by omega),
        show (u + 1 - z).toNat = (u - z).toNat + 1 by omega, Function.iterate_succ_apply']
      exact hF _
    · by_cases h' : z ≤ u + 1
      · have hu : u + 1 = z := by omega
        rw [if_neg h, if_pos h', show (u + 1 - z).toNat = 0 by omega,
          show (z - u).toNat = 1 by omega]
        exact hG x
      · rw [if_neg h, if_neg h', show (z - u).toNat = (z - (u + 1)).toNat + 1 by omega,
          Function.iterate_succ_apply']
        exact hG _
  · change (if z ≤ z then F^[(z - z).toNat] x else G^[(z - z).toNat] x) = x
    rw [if_pos le_rfl, show (z - z).toNat = 0 by omega]
    rfl

/-- **THE WINDOW LINK.** Two paths are linked at `t` with budget `(a, b)` when their states at
`t + i` are related, for `-a ≤ i ≤ b`, at the budget left after `|i|` steps in the direction of
`i`. -/
def Lnk (a b : ℕ) (g g' : ℤ → LadderState Q pend) (t : ℤ) : Prop :=
  ∀ i : ℤ, -(a : ℤ) ≤ i → i ≤ (b : ℤ) →
    Zrel (a - (-i).toNat) (b - i.toNat) (g (t + i)) (g' (t + i))

theorem Lnk.symm {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a b g g' t) :
    Lnk a b g' g t :=
  fun i h1 h2 => Zrel.symm (h i h1 h2)

theorem Lnk.mono {a b a' b' : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ}
    (ha : a' ≤ a) (hb : b' ≤ b) (h : Lnk a b g g' t) : Lnk a' b' g g' t :=
  fun i h1 h2 => Zrel.mono (by omega) (by omega) (h i (by omega) (by omega))

theorem Lnk.zero {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a b g g' t) :
    Zrel a b (g t) (g' t) := by
  have := h 0 (by omega) (by omega)
  simpa using this

theorem Lnk.succ {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk a (b + 1) g g' t) :
    Lnk a b g g' (t + 1) := by
  intro i h1 h2
  have := h (i + 1) (by omega) (by push_cast; omega)
  rw [show t + (i + 1) = t + 1 + i by ring] at this
  exact Zrel.mono (by omega) (by omega) this

theorem Lnk.pred {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ} (h : Lnk (a + 1) b g g' t) :
    Lnk a b g g' (t - 1) := by
  intro i h1 h2
  have := h (i - 1) (by push_cast; omega) (by omega)
  rw [show t + (i - 1) = t - 1 + i by ring] at this
  exact Zrel.mono (by omega) (by omega) this

/-- **THE PATH FORTH.** A state related to the state a path visits at `t` lies on a path linked
to it there.  This is where the one-step closure conditions become a statement about histories,
and it is the `⊡` clause of the truth lemma below. -/
theorem exists_linked_path
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (a b : ℕ) (h : ℤ → LadderState Q pend) (hh : IsLadderPath step pend h) (t : ℤ)
    (y : LadderState Q pend) (hZ : Zrel a b (h t) y) :
    ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧ h' t = y ∧ Lnk a b h h' t := by
  -- forward half
  have hfw : ∀ j : ℕ, j ≤ b → ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧
      h' t = y ∧ ∀ i : ℕ, i ≤ j → Zrel a (b - i) (h (t + (i : ℤ))) (h' (t + (i : ℤ))) := by
    intro j
    induction j with
    | zero =>
      intro _
      obtain ⟨p, hp, hpt⟩ := exists_path_through fwd bwd y t
      refine ⟨p, hp, hpt, fun i hi => ?_⟩
      have hi0 : i = 0 := by omega
      subst hi0
      simpa [hpt] using hZ
    | succ j ih =>
      intro hj
      obtain ⟨h', hh', ht', hrel⟩ := ih (by omega)
      have hr := hrel j le_rfl
      rw [show b - j = (b - j - 1) + 1 by omega] at hr
      obtain ⟨y₁, hy₁, hZ₁⟩ := Zrel.succ hr (hh (t + (j : ℤ)))
      obtain ⟨p, hp, hpt⟩ := exists_path_through fwd bwd y₁ (t + (j : ℤ) + 1)
      refine ⟨glue h' p (t + (j : ℤ)), glue_isPath h' p hh' hp _ (by rw [hpt]; exact hy₁), ?_, ?_⟩
      · rw [glue_of_le _ _ _ _ (by omega)]
        exact ht'
      · intro i hi
        by_cases hij : i ≤ j
        · rw [glue_of_le _ _ _ _ (by omega)]
          exact hrel i hij
        · have hi1 : i = j + 1 := by omega
          subst hi1
          rw [glue_of_gt _ _ _ _ (by push_cast; omega),
            show t + ((j + 1 : ℕ) : ℤ) = t + (j : ℤ) + 1 by push_cast; ring, hpt]
          rw [show b - (j + 1) = b - j - 1 by omega]
          exact hZ₁
  obtain ⟨h₁, hh₁, ht₁, hrel₁⟩ := hfw b le_rfl
  -- backward half
  have hbw : ∀ j : ℕ, j ≤ a → ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧
      h' t = y ∧ (∀ i : ℕ, i ≤ b → Zrel a (b - i) (h (t + (i : ℤ))) (h' (t + (i : ℤ)))) ∧
      ∀ i : ℕ, i ≤ j → Zrel (a - i) b (h (t - (i : ℤ))) (h' (t - (i : ℤ))) := by
    intro j
    induction j with
    | zero =>
      intro _
      refine ⟨h₁, hh₁, ht₁, hrel₁, fun i hi => ?_⟩
      have hi0 : i = 0 := by omega
      subst hi0
      simpa [ht₁] using hZ
    | succ j ih =>
      intro hj
      obtain ⟨h', hh', ht', hfwd, hrel⟩ := ih (by omega)
      have hr := hrel j le_rfl
      rw [show a - j = (a - j - 1) + 1 by omega] at hr
      have hstep : RladAdm step pend (t - (j : ℤ) - 1) (h (t - (j : ℤ) - 1)) (h (t - (j : ℤ))) := by
        have := hh (t - (j : ℤ) - 1)
        rwa [show t - (j : ℤ) - 1 + 1 = t - (j : ℤ) by ring] at this
      obtain ⟨y₀, hy₀, hZ₀⟩ := Zrel.pred hr hstep
      obtain ⟨p, hp, hpt⟩ := exists_path_through fwd bwd y₀ (t - (j : ℤ) - 1)
      refine ⟨glue p h' (t - (j : ℤ) - 1), glue_isPath p h' hp hh' _ ?_, ?_, ?_, ?_⟩
      · rw [hpt, show t - (j : ℤ) - 1 + 1 = t - (j : ℤ) by ring]
        exact hy₀
      · rw [glue_of_gt _ _ _ _ (by omega)]
        exact ht'
      · intro i hi
        rw [glue_of_gt _ _ _ _ (by omega)]
        exact hfwd i hi
      · intro i hi
        by_cases hij : i ≤ j
        · rw [glue_of_gt _ _ _ _ (by omega)]
          exact hrel i hij
        · have hi1 : i = j + 1 := by omega
          subst hi1
          rw [show t - ((j + 1 : ℕ) : ℤ) = t - (j : ℤ) - 1 by push_cast; ring,
            glue_of_le _ _ _ _ le_rfl, hpt]
          rw [show a - (j + 1) = a - j - 1 by omega]
          exact hZ₀
  obtain ⟨h₂, hh₂, ht₂, hf₂, hb₂⟩ := hbw a le_rfl
  refine ⟨h₂, hh₂, ht₂, fun i h1 h2 => ?_⟩
  by_cases hi : 0 ≤ i
  · have := hf₂ i.toNat (by omega)
    rw [show ((i.toNat : ℕ) : ℤ) = i by omega] at this
    rw [show (-i).toNat = 0 by omega]
    simpa using this
  · have := hb₂ (-i).toNat (by omega)
    rw [show t - (((-i).toNat : ℕ) : ℤ) = t + i by omega] at this
    rw [show i.toNat = 0 by omega]
    simpa using this

end Paths

/-! ### The row link: the correspondence a jump reads

`Lnk` constrains the window `[t - a, t + b]` and nothing beyond it, and a witness of an `untl` or
`snce` at a guard other than `⊥` lies anywhere on the row.  `LnkRow` is the relation the two jump
clauses of `PlusTruthAt` read, with nothing added: a witness on one path is answered by a witness
on the other, every position the answer passes is answered back, and the answering pairs are
related at the budget left after the jump.  It relates a POSITION of one path to a POSITION of the
other, because the answer to a far witness need not sit at the same distance. -/

section Row

variable {Q : Type} {pend : Q → Bool}

/-- **THE FORWARD JUMP CONDITION.** Every position after `t` on the first row is answered by a
position after `t'` on the second, related by `R`, such that every position strictly between `t'`
and the answer is `R`-related to a position strictly between `t` and the witness. -/
def FwdJump (R : ℤ → ℤ → Prop) (t t' : ℤ) : Prop :=
  ∀ s : ℤ, t < s → ∃ s' : ℤ, t' < s' ∧ R s s' ∧
    ∀ r' : ℤ, t' < r' → r' < s' → ∃ r : ℤ, t < r ∧ r < s ∧ R r r'

/-- **THE BACKWARD JUMP CONDITION**, the mirror of `FwdJump`. -/
def BwdJump (R : ℤ → ℤ → Prop) (t t' : ℤ) : Prop :=
  ∀ s : ℤ, s < t → ∃ s' : ℤ, s' < t' ∧ R s s' ∧
    ∀ r' : ℤ, s' < r' → r' < t' → ∃ r : ℤ, s < r ∧ r < t ∧ R r r'

theorem FwdJump.mono {R R' : ℤ → ℤ → Prop} {t t' : ℤ} (h : ∀ s s', R s s' → R' s s')
    (hF : FwdJump R t t') : FwdJump R' t t' := by
  intro s hs
  obtain ⟨s', hs', hR, hbt⟩ := hF s hs
  refine ⟨s', hs', h _ _ hR, fun r' h1 h2 => ?_⟩
  obtain ⟨r, hr1, hr2, hRr⟩ := hbt r' h1 h2
  exact ⟨r, hr1, hr2, h _ _ hRr⟩

theorem BwdJump.mono {R R' : ℤ → ℤ → Prop} {t t' : ℤ} (h : ∀ s s', R s s' → R' s s')
    (hB : BwdJump R t t') : BwdJump R' t t' := by
  intro s hs
  obtain ⟨s', hs', hR, hbt⟩ := hB s hs
  refine ⟨s', hs', h _ _ hR, fun r' h1 h2 => ?_⟩
  obtain ⟨r, hr1, hr2, hRr⟩ := hbt r' h1 h2
  exact ⟨r, hr1, hr2, h _ _ hRr⟩

/-- **THE ROW LINK.** Position `t` of `g` and position `t'` of `g'` are row-linked at the budget
`(a, b)` when the two states are related at that budget and, for each jump the budget still
allows, the jump condition holds in both directions between the two rows at the budget left after
it: a forward jump spends one unit of `b`, a backward jump one unit of `a`.  No position of either
row is exempt, and no window appears. -/
def LnkRow (a b : ℕ) (g g' : ℤ → LadderState Q pend) (t t' : ℤ) : Prop :=
  Zrel a b (g t) (g' t') ∧
  (∀ b₀ : ℕ, b = b₀ + 1 →
    FwdJump (fun s s' => LnkRow a b₀ g g' s s') t t' ∧
    FwdJump (fun s' s => LnkRow a b₀ g g' s s') t' t) ∧
  (∀ a₀ : ℕ, a = a₀ + 1 →
    BwdJump (fun s s' => LnkRow a₀ b g g' s s') t t' ∧
    BwdJump (fun s' s => LnkRow a₀ b g g' s s') t' t)
termination_by a + b
decreasing_by all_goals omega

theorem LnkRow.zero {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t t' : ℤ}
    (h : LnkRow a b g g' t t') : Zrel a b (g t) (g' t') := by
  rw [LnkRow] at h
  exact h.1

theorem LnkRow.symm {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t t' : ℤ}
    (h : LnkRow a b g g' t t') : LnkRow a b g' g t' t := by
  induction hn : a + b using Nat.strong_induction_on generalizing a b t t' with
  | _ n ih =>
    rw [LnkRow] at h ⊢
    obtain ⟨hz, hf, hb⟩ := h
    refine ⟨Zrel.symm hz, fun b₀ hb₀ => ?_, fun a₀ ha₀ => ?_⟩
    · obtain ⟨h1, h2⟩ := hf b₀ hb₀
      exact ⟨FwdJump.mono (fun s s' hR => ih (a + b₀) (by omega) hR rfl) h2,
        FwdJump.mono (fun s s' hR => ih (a + b₀) (by omega) hR rfl) h1⟩
    · obtain ⟨h1, h2⟩ := hb a₀ ha₀
      exact ⟨BwdJump.mono (fun s s' hR => ih (a₀ + b) (by omega) hR rfl) h2,
        BwdJump.mono (fun s s' hR => ih (a₀ + b) (by omega) hR rfl) h1⟩

theorem LnkRow.mono {a b a' b' : ℕ} {g g' : ℤ → LadderState Q pend} {t t' : ℤ}
    (ha : a' ≤ a) (hb : b' ≤ b) (h : LnkRow a b g g' t t') : LnkRow a' b' g g' t t' := by
  induction hn : a' + b' using Nat.strong_induction_on generalizing a b a' b' t t' with
  | _ n ih =>
    rw [LnkRow] at h ⊢
    obtain ⟨hz, hf, hbk⟩ := h
    refine ⟨Zrel.mono ha hb hz, fun b₀ hb₀ => ?_, fun a₀ ha₀ => ?_⟩
    · obtain ⟨h1, h2⟩ := hf (b - 1) (by omega)
      exact ⟨FwdJump.mono (fun s s' hR => ih (a' + b₀) (by omega) ha (by omega) hR rfl) h1,
        FwdJump.mono (fun s s' hR => ih (a' + b₀) (by omega) ha (by omega) hR rfl) h2⟩
    · obtain ⟨h1, h2⟩ := hbk (a - 1) (by omega)
      exact ⟨BwdJump.mono (fun s s' hR => ih (a₀ + b') (by omega) (by omega) hb hR rfl) h1,
        BwdJump.mono (fun s s' hR => ih (a₀ + b') (by omega) (by omega) hb hR rfl) h2⟩

/-- A forward jump to the next position is answered at the next position: the answer has no
position strictly before it to answer back. -/
theorem LnkRow.succ {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t t' : ℤ}
    (h : LnkRow a (b + 1) g g' t t') : LnkRow a b g g' (t + 1) (t' + 1) := by
  rw [LnkRow] at h
  obtain ⟨h1, -⟩ := h.2.1 b rfl
  obtain ⟨s', hs', hR, hbt⟩ := h1 (t + 1) (by omega)
  by_cases he : s' = t' + 1
  · rw [← he]
    exact hR
  · obtain ⟨r, hr1, hr2, -⟩ := hbt (t' + 1) (by omega) (by omega)
    omega

/-- The mirror of `LnkRow.succ`. -/
theorem LnkRow.pred {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t t' : ℤ}
    (h : LnkRow (a + 1) b g g' t t') : LnkRow a b g g' (t - 1) (t' - 1) := by
  rw [LnkRow] at h
  obtain ⟨h1, -⟩ := h.2.2 a rfl
  obtain ⟨s', hs', hR, hbt⟩ := h1 (t - 1) (by omega)
  by_cases he : s' = t' - 1
  · rw [← he]
    exact hR
  · obtain ⟨r, hr1, hr2, -⟩ := hbt (t' - 1) (by omega) (by omega)
    omega

/-- **THE WINDOW RESTRICTION.** A row link at one position of both paths restricts to the window
link there, at the same budget: the window is the part of the row that steps alone reach. -/
theorem LnkRow.toLnk {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t : ℤ}
    (h : LnkRow a b g g' t t) : Lnk a b g g' t := by
  have hfw : ∀ j : ℕ, j ≤ b → LnkRow a (b - j) g g' (t + (j : ℤ)) (t + (j : ℤ)) := by
    intro j
    induction j with
    | zero => intro _; simpa using h
    | succ j ih =>
      intro hj
      have := ih (by omega)
      rw [show b - j = (b - (j + 1)) + 1 by omega] at this
      have := LnkRow.succ this
      rwa [show t + (j : ℤ) + 1 = t + ((j + 1 : ℕ) : ℤ) by push_cast; ring] at this
  have hbw : ∀ j : ℕ, j ≤ a → LnkRow (a - j) b g g' (t - (j : ℤ)) (t - (j : ℤ)) := by
    intro j
    induction j with
    | zero => intro _; simpa using h
    | succ j ih =>
      intro hj
      have := ih (by omega)
      rw [show a - j = (a - (j + 1)) + 1 by omega] at this
      have := LnkRow.pred this
      rwa [show t - (j : ℤ) - 1 = t - ((j + 1 : ℕ) : ℤ) by push_cast; ring] at this
  intro i h1 h2
  by_cases hi : 0 ≤ i
  · have := (hfw i.toNat (by omega)).zero
    rw [show ((i.toNat : ℕ) : ℤ) = i by omega] at this
    rw [show (-i).toNat = 0 by omega]
    simpa using this
  · have := (hbw (-i).toNat (by omega)).zero
    rw [show t - (((-i).toNat : ℕ) : ℤ) = t + i by omega] at this
    rw [show i.toNat = 0 by omega]
    simpa using this

/-- **THE `⊡` CLAUSE AGAINST THE ROW LINK, AT THE BUDGET `(0, 0)`.** With no jump left the row
link is the state relation, so the path forth is a path through the related state.  At a positive
budget the same statement is the path forth with a whole-row correspondence, and it is NOT proved
here: its conclusion contains a jump condition, which no one-step closure condition delivers. -/
theorem exists_rowLinked_path_zero {step : Q → Q → Bool}
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (h : ℤ → LadderState Q pend) (t : ℤ)
    (y : LadderState Q pend) (hZ : Zrel 0 0 (h t) y) :
    ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧ h' t = y ∧
      LnkRow 0 0 h h' t t := by
  obtain ⟨p, hp, hpt⟩ := exists_path_through fwd bwd y t
  refine ⟨p, hp, hpt, ?_⟩
  rw [LnkRow]
  refine ⟨by rw [hpt]; exact hZ, fun b₀ hb₀ => ?_, fun a₀ ha₀ => ?_⟩ <;> omega

end Row

/-! ### The step fragment and its truth lemma -/

/-- **THE STEP FRAGMENT.** Every connective of the language, with `untl` and `snce` admitted only
at the guard `⊥` — that is, as `X` and its mirror.  `⊡` and `□` are admitted without restriction.
What the fragment excludes is exactly the UNBOUNDED temporal jump. -/
def StepFrag : PlusFormula → Prop
  | .atom _ => True
  | .bot => True
  | .imp α β => StepFrag α ∧ StepFrag β
  | .box α => StepFrag α
  | .untl γ α => γ = .bot ∧ StepFrag α
  | .snce γ α => γ = .bot ∧ StepFrag α
  | .stab α => StepFrag α

/-- The fragment and the two exactness depths pass to subformulas. -/
theorem frag_of_mem : ∀ φ : PlusFormula, StepFrag φ → ∀ ψ ∈ PlusFormula.subformulas φ,
    StepFrag ψ ∧ dBack ψ ≤ dBack φ ∧ dFwd ψ ≤ dFwd φ := by
  intro φ
  induction φ with
  | atom p =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_singleton] at h
    subst h
    exact ⟨hf, le_rfl, le_rfl⟩
  | bot =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_singleton] at h
    subst h
    exact ⟨hf, le_rfl, le_rfl⟩
  | imp α β iha ihb =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · obtain ⟨h1, h2, h3⟩ := iha hf.1 ψ h
      exact ⟨h1, le_trans h2 (le_max_left _ _), le_trans h3 (le_max_left _ _)⟩
    · obtain ⟨h1, h2, h3⟩ := ihb hf.2 ψ h
      exact ⟨h1, le_trans h2 (le_max_right _ _), le_trans h3 (le_max_right _ _)⟩
  | box α iha =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons] at h
    rcases h with rfl | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · exact iha hf ψ h
  | untl γ α ihg iha =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · obtain ⟨h1, h2, h3⟩ := iha hf.2 ψ h
      exact ⟨h1, le_trans h2 (le_max_right _ _),
        le_trans h3 (le_trans (le_max_right _ _) (Nat.le_succ _))⟩
    · obtain ⟨h1, h2, h3⟩ := ihg (by rw [hf.1]; trivial) ψ h
      exact ⟨h1, le_trans h2 (le_max_left _ _),
        le_trans h3 (le_trans (le_max_left _ _) (Nat.le_succ _))⟩
  | snce γ α ihg iha =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with rfl | h | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · obtain ⟨h1, h2, h3⟩ := iha hf.2 ψ h
      exact ⟨h1, le_trans h2 (le_trans (le_max_right _ _) (Nat.le_succ _)),
        le_trans h3 (le_max_right _ _)⟩
    · obtain ⟨h1, h2, h3⟩ := ihg (by rw [hf.1]; trivial) ψ h
      exact ⟨h1, le_trans h2 (le_trans (le_max_left _ _) (Nat.le_succ _)),
        le_trans h3 (le_max_left _ _)⟩
  | stab α iha =>
    intro hf ψ h
    simp only [PlusFormula.subformulas, List.mem_cons] at h
    rcases h with rfl | h
    · exact ⟨hf, le_rfl, le_rfl⟩
    · exact iha hf ψ h

section Truth

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

theorem int_succ_lt_of_ne (t s : ℤ) (h : t < s) (hne : s ≠ t + 1) : t + 1 < s := by omega

theorem int_not_between (t r : ℤ) (h1 : t < r) (h2 : r < t + 1) : False := by omega

theorem int_lt_pred_of_ne (t s : ℤ) (h : s < t) (hne : s ≠ t - 1) : s < t - 1 := by omega

theorem int_pred_lt (t : ℤ) : t - 1 < t := by omega

theorem int_not_between_pred (t r : ℤ) (h1 : t - 1 < r) (h2 : r < t) : False := by omega

theorem truth_nxt
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt (ladderModel step pend fwd bwd lab) τ t (.untl .bot ψ) ↔
      PlusTruthAt (ladderModel step pend fwd bwd lab) τ (t + 1) ψ := by
  constructor
  · rintro ⟨s, hts, hs, hr⟩
    by_cases he : s = t + 1
    · rw [he] at hs
      exact hs
    · exact (hr (t + 1) (Int.lt_succ_self t) (int_succ_lt_of_ne t s hts he)).elim
  · intro h
    exact ⟨t + 1, Int.lt_succ_self t, h, fun r h1 h2 => (int_not_between t r h1 h2).elim⟩

theorem truth_prv
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (t : ℤ) (ψ : PlusFormula) :
    PlusTruthAt (ladderModel step pend fwd bwd lab) τ t (.snce .bot ψ) ↔
      PlusTruthAt (ladderModel step pend fwd bwd lab) τ (t - 1) ψ := by
  constructor
  · rintro ⟨s, hst, hs, hr⟩
    by_cases he : s = t - 1
    · rw [he] at hs
      exact hs
    · exact (hr (t - 1) (int_lt_pred_of_ne t s hst he) (int_pred_lt t)).elim
  · intro h
    exact ⟨t - 1, int_pred_lt t, h, fun r h1 h2 => (int_not_between_pred t r h1 h2).elim⟩

/-- **THE TRUTH LEMMA.** Two ladder histories whose paths are linked at `t` with a budget at
least the formula's two exactness depths agree on it at `t` — for every formula of the step
fragment, `⊡` and `□` included. -/
theorem truth_iff_of_lnk
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool) :
    ∀ ψ : PlusFormula, StepFrag ψ → ∀ a b : ℕ, dBack ψ ≤ a → dFwd ψ ≤ b →
      ∀ (τ τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (k k' : ℤ)
        (g g' : ℤ → LadderState Q pend) (t : ℤ),
        IsLadderPath step pend g → IsLadderPath step pend g' →
        (∀ u : ℤ, τ.state u = (u + k, g u)) → (∀ u : ℤ, τ'.state u = (u + k', g' u)) →
        Lnk a b g g' t →
        (PlusTruthAt (ladderModel step pend fwd bwd lab) τ t ψ ↔
          PlusTruthAt (ladderModel step pend fwd bwd lab) τ' t ψ) := by
  intro ψ
  induction ψ with
  | atom p =>
    intro _ a b _ _ τ τ' k k' g g' t _ _ hτ hτ' hl
    change lab (τ.state t).2.1.1 p = true ↔ lab (τ'.state t).2.1.1 p = true
    rw [hτ t, hτ' t]
    change lab (g t).1.1 p = true ↔ lab (g' t).1.1 p = true
    rw [(Lnk.zero hl).1]
  | bot =>
    intro _ a b _ _ τ τ' k k' g g' t _ _ _ _ _
    exact Iff.rfl
  | imp α β iha ihb =>
    intro hf a b hda hdb τ τ' k k' g g' t hg hg' hτ hτ' hl
    have h1 := iha hf.1 a b (le_trans (le_max_left _ _) hda) (le_trans (le_max_left _ _) hdb)
      τ τ' k k' g g' t hg hg' hτ hτ' hl
    have h2 := ihb hf.2 a b (le_trans (le_max_right _ _) hda) (le_trans (le_max_right _ _) hdb)
      τ τ' k k' g g' t hg hg' hτ hτ' hl
    exact ⟨fun hi x => h2.mp (hi (h1.mpr x)), fun hi x => h2.mpr (hi (h1.mp x))⟩
  | box α _ =>
    intro _ a b _ _ τ τ' k k' g g' t _ _ _ _ _
    exact Iff.rfl
  | untl γ α _ iha =>
    intro hf a b hda hdb τ τ' k k' g g' t hg hg' hτ hτ' hl
    obtain ⟨rfl, hfα⟩ := hf
    have hb1 : dFwd α + 1 ≤ b := le_trans (Nat.succ_le_succ (le_max_right _ _)) hdb
    rw [truth_nxt, truth_nxt]
    have hl' : Lnk a (b - 1) g g' (t + 1) := by
      apply Lnk.succ
      rw [show b - 1 + 1 = b by omega]
      exact hl
    exact iha hfα a (b - 1) (le_trans (le_max_right _ _) hda) (by omega)
      τ τ' k k' g g' (t + 1) hg hg' hτ hτ' hl'
  | snce γ α _ iha =>
    intro hf a b hda hdb τ τ' k k' g g' t hg hg' hτ hτ' hl
    obtain ⟨rfl, hfα⟩ := hf
    have ha1 : dBack α + 1 ≤ a := le_trans (Nat.succ_le_succ (le_max_right _ _)) hda
    rw [truth_prv, truth_prv]
    have hl' : Lnk (a - 1) b g g' (t - 1) := by
      apply Lnk.pred
      rw [show a - 1 + 1 = a by omega]
      exact hl
    exact iha hfα (a - 1) b (by omega) (le_trans (le_max_right _ _) hdb)
      τ τ' k k' g g' (t - 1) hg hg' hτ hτ' hl'
  | stab α iha =>
    intro hf a b hda hdb τ τ' k k' g g' t hg hg' hτ hτ' hl
    have key : ∀ (τ τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
        (k k' : ℤ) (g g' : ℤ → LadderState Q pend),
        (∀ u : ℤ, τ.state u = (u + k, g u)) → (∀ u : ℤ, τ'.state u = (u + k', g' u)) →
        Lnk a b g g' t →
        PlusTruthAt (ladderModel step pend fwd bwd lab) τ t (.stab α) →
        PlusTruthAt (ladderModel step pend fwd bwd lab) τ' t (.stab α) := by
      intro τ τ' k k' g g' hτ hτ' hl h σ' hσ'
      obtain ⟨kσ', gσ', hgσ', hpσ'⟩ := exists_isLadderPath_of_hist fwd bwd σ'
      have e : ((t + k', g' t) : (ladderFrameAdm step pend fwd bwd).WorldState)
          = (t + kσ', gσ' t) := (hτ' t).symm.trans (hσ'.trans (hpσ' t))
      have eg : g' t = gσ' t := congrArg Prod.snd e
      have hz : Zrel a b (gσ' t) (g t) := by
        rw [← eg]
        exact Zrel.symm (Lnk.zero hl)
      obtain ⟨gσ, hgσ, hgσt, hlσ⟩ := exists_linked_path fwd bwd a b gσ' hgσ' t (g t) hz
      obtain ⟨σ, hσ⟩ := exists_hist_of_isLadderPath_at_offset fwd bwd k gσ hgσ
      have hσt : τ.state t = σ.state t := by rw [hτ t, hσ t, hgσt]
      exact (iha hf a b hda hdb σ σ' k kσ' gσ gσ' t hgσ hgσ' hσ hpσ' (Lnk.symm hlσ)).mp
        (h σ hσt)
    exact ⟨key τ τ' k k' g g' hτ hτ' hl, key τ' τ k' k g' g hτ' hτ (Lnk.symm hl)⟩

/-- One inclusion of the agreement. -/
theorem cellAt_subset_of_Zrel
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (hφ : StepFrag φ) (x y : LadderState Q pend)
    (hZ : Zrel (dBack φ) (dFwd φ) x y) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, y) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  obtain ⟨g, τ, hg, hgz, hτ, rfl⟩ := (mem_cellAt_ladder_iff fwd bwd lab φ x z T).mp hT
  obtain ⟨g', hg', hg'z, hl⟩ :=
    exists_linked_path fwd bwd (dBack φ) (dFwd φ) g hg z y (by rw [hgz]; exact hZ)
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine (mem_cellAt_ladder_iff fwd bwd lab φ y z _).mpr ⟨g', τ', hg', hg'z, hτ', ?_⟩
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  have hiff : ψ ∈ plusSubformulaClosure φ →
      (PlusTruthAt (ladderModel step pend fwd bwd lab) τ z ψ ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) τ' z ψ) := by
    intro hm
    have hm' : ψ ∈ PlusFormula.subformulas φ := by
      simpa [plusSubformulaClosure] using hm
    obtain ⟨hf, h1, h2⟩ := frag_of_mem φ hφ ψ hm'
    exact truth_iff_of_lnk fwd bwd lab ψ hf _ _ h1 h2 τ τ' 0 0 g g' z hg hg'
      (fun u => by rw [hτ u, add_zero]) (fun u => by rw [hτ' u, add_zero]) hl
  constructor
  · rintro ⟨hm, ht⟩
    exact ⟨hm, (hiff hm).mpr ht⟩
  · rintro ⟨hm, ht⟩
    exact ⟨hm, (hiff hm).mp ht⟩

/-- **THE AGREEMENT ON THE STEP FRAGMENT, AS A COROLLARY OF THE BACK-AND-FORTH.** For every finite
object, every labelling and every formula of the step fragment — `⊡` and `□` included — two
ladder states related at the formula's own two exactness depths have the same cell.  No parameter
condition is assumed: the thresholds are the ones `Zrel` carries, and they were forced by
`Zrel.succ` and `Zrel.pred`. -/
theorem cellAt_eq_of_Zrel
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (hφ : StepFrag φ) (x y : LadderState Q pend)
    (hZ : Zrel (dBack φ) (dFwd φ) x y) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z =
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, y) : (ladderFrameAdm step pend fwd bwd).WorldState) z :=
  Set.Subset.antisymm (cellAt_subset_of_Zrel fwd bwd lab φ hφ x y hZ z)
    (cellAt_subset_of_Zrel fwd bwd lab φ hφ y x (Zrel.symm hZ) z)

end Truth

/-! ### The row link is reflexive, and what a row link forces at a region's end -/

section RowBasics

variable {Q : Type} {pend : Q → Bool}

/-- **THE ROW LINK IS REFLEXIVE**: every position of a row answers itself. -/
theorem LnkRow.refl (a b : ℕ) (g : ℤ → LadderState Q pend) (t : ℤ) : LnkRow a b g g t t := by
  induction hn : a + b using Nat.strong_induction_on generalizing a b t with
  | _ n ih =>
    rw [LnkRow]
    refine ⟨Zrel.refl a b _, fun b₀ hb₀ => ⟨?_, ?_⟩, fun a₀ ha₀ => ⟨?_, ?_⟩⟩
    · intro s hs
      exact ⟨s, hs, ih (a + b₀) (by omega) a b₀ s rfl,
        fun r' h1 h2 => ⟨r', h1, h2, ih (a + b₀) (by omega) a b₀ r' rfl⟩⟩
    · intro s hs
      exact ⟨s, hs, ih (a + b₀) (by omega) a b₀ s rfl,
        fun r' h1 h2 => ⟨r', h1, h2, ih (a + b₀) (by omega) a b₀ r' rfl⟩⟩
    · intro s hs
      exact ⟨s, hs, ih (a₀ + b) (by omega) a₀ b s rfl,
        fun r' h1 h2 => ⟨r', h1, h2, ih (a₀ + b) (by omega) a₀ b r' rfl⟩⟩
    · intro s hs
      exact ⟨s, hs, ih (a₀ + b) (by omega) a₀ b s rfl,
        fun r' h1 h2 => ⟨r', h1, h2, ih (a₀ + b) (by omega) a₀ b r' rfl⟩⟩

/-- **THE FIRST EXHAUSTED COUNTDOWN IS ANSWERED BY THE FIRST EXHAUSTED COUNTDOWN.** Under a row
link with one forward jump and at least one further unit of budget, the first position after `t`
at which the first row's countdown is `0` is answered by the first position after `t'` at which
the second row's countdown is `0`, and the two carry the same object state. -/
theorem LnkRow.first_zero {a b : ℕ} {g g' : ℤ → LadderState Q pend} {t t' : ℤ}
    (hab : 1 ≤ a + b) (h : LnkRow a (b + 1) g g' t t') {s : ℤ} (hts : t < s)
    (hs0 : cntAt g s = 0) (hpos : ∀ r : ℤ, t < r → r < s → cntAt g r ≠ 0) :
    ∃ s' : ℤ, t' < s' ∧ cntAt g' s' = 0 ∧ objAt g' s' = objAt g s ∧
      ∀ r' : ℤ, t' < r' → r' < s' → cntAt g' r' ≠ 0 := by
  rw [LnkRow] at h
  obtain ⟨h1, -⟩ := h.2.1 b rfl
  obtain ⟨s', hs', hR, hbt⟩ := h1 s hts
  obtain ⟨hq, hc, -, -⟩ := hR.zero
  refine ⟨s', hs', ?_, hq.symm, fun r' h1 h2 => ?_⟩
  · unfold cntAt at hs0 ⊢
    omega
  · obtain ⟨r, hr1, hr2, hRr⟩ := hbt r' h1 h2
    obtain ⟨-, hc', -, -⟩ := hRr.zero
    have := hpos r hr1 hr2
    unfold cntAt at this ⊢
    omega

/-- **A ROW LINK FORCES THE OBJECT STATE AT WHICH THE CURRENT REGION ENDS.** If two ladder paths
are row-linked at `(t, t')` with one forward jump and one further unit of budget, and the first is
pending at `t` with a positive countdown, then the last pending positions of the two current
regions — `cntAt g t` steps after `t` and `cntAt g' t'` steps after `t'` — carry the same object
state.  When the two countdowns differ this is a condition on the object's walks of two different
lengths, which no threshold on the counters expresses. -/
theorem LnkRow.region_end_obj {step : Q → Q → Bool} {a b : ℕ} {g g' : ℤ → LadderState Q pend}
    {t t' : ℤ} (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g')
    (hab : 1 ≤ a + b) (h : LnkRow a (b + 1) g g' t t') (hc : 1 ≤ cntAt g t) :
    objAt g' (t' + (cntAt g' t' : ℤ)) = objAt g (t + (cntAt g t : ℤ)) := by
  have hp : pend (objAt g t) = true := by
    by_contra hne
    have := cntAt_eq_zero_of_idle g hg t (by simpa using hne)
    omega
  have hsub := cntAt_sub_of_pend g hg t hp
  obtain ⟨s', hs', hs0', hobj, hpos'⟩ :=
    LnkRow.first_zero hab h (s := t + (cntAt g t : ℤ)) (by omega)
      (by have := (hsub (cntAt g t) le_rfl).2; omega)
      (fun r hr1 hr2 => by
        have := (hsub (r - t).toNat (by omega)).2
        rw [show t + (((r - t).toNat : ℕ) : ℤ) = r by omega] at this
        omega)
  have hc' : 1 ≤ cntAt g' t' := by
    obtain ⟨-, hcc, -, -⟩ := h.zero
    unfold cntAt at hc ⊢
    omega
  have hp' : pend (objAt g' t') = true := by
    by_contra hne
    have := cntAt_eq_zero_of_idle g' hg' t' (by simpa using hne)
    omega
  have hsub' := cntAt_sub_of_pend g' hg' t' hp'
  have hs'eq : s' = t' + (cntAt g' t' : ℤ) := by
    rcases lt_trichotomy s' (t' + (cntAt g' t' : ℤ)) with hlt | heq | hgt
    · have := (hsub' (s' - t').toNat (by omega)).2
      rw [show t' + (((s' - t').toNat : ℕ) : ℤ) = s' by omega] at this
      omega
    · exact heq
    · have h0 := (hsub' (cntAt g' t') le_rfl).2
      have := hpos' (t' + (cntAt g' t' : ℤ)) (by omega) hgt
      omega
  rw [← hs'eq]
  exact hobj

end RowBasics

/-! ### The truth lemma over the row link, at the `⊡`-free level -/

/-- **THE ROW FRAGMENT.** `untl` and `snce` at every guard, with no `⊡` and no `□`: the level at
which a formula is evaluated along ONE history, so that a correspondence between two rows is all
its truth reads. -/
def RowFrag : PlusFormula → Prop
  | .atom _ => True
  | .bot => True
  | .imp α β => RowFrag α ∧ RowFrag β
  | .box _ => False
  | .untl γ α => RowFrag γ ∧ RowFrag α
  | .snce γ α => RowFrag γ ∧ RowFrag α
  | .stab _ => False

section RowTruth

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE TRUTH LEMMA OVER THE ROW LINK, AT THE `⊡`-FREE LEVEL.** Two ladder histories whose paths
are row-linked at `(t, t')` with a budget at least the formula's two exactness depths agree on it
there, for every formula of the row fragment — `untl` and `snce` at EVERY guard.  The `untl` case
reads the two forward jump conditions of the link and the `snce` case the two backward ones; no
path is constructed.  The lemma says nothing about which pairs of paths ARE row-linked: that is
the path forth with a whole-row correspondence, which this module does not prove. -/
theorem truth_iff_of_lnkRow
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool) :
    ∀ ψ : PlusFormula, RowFrag ψ → ∀ a b : ℕ, dBack ψ ≤ a → dFwd ψ ≤ b →
      ∀ (τ τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (k k' : ℤ)
        (g g' : ℤ → LadderState Q pend) (t t' : ℤ),
        IsLadderPath step pend g → IsLadderPath step pend g' →
        (∀ u : ℤ, τ.state u = (u + k, g u)) → (∀ u : ℤ, τ'.state u = (u + k', g' u)) →
        LnkRow a b g g' t t' →
        (PlusTruthAt (ladderModel step pend fwd bwd lab) τ t ψ ↔
          PlusTruthAt (ladderModel step pend fwd bwd lab) τ' t' ψ) := by
  intro ψ
  induction ψ with
  | atom p =>
    intro _ a b _ _ τ τ' k k' g g' t t' _ _ hτ hτ' hl
    change lab (τ.state t).2.1.1 p = true ↔ lab (τ'.state t').2.1.1 p = true
    rw [hτ t, hτ' t']
    change lab (g t).1.1 p = true ↔ lab (g' t').1.1 p = true
    rw [(LnkRow.zero hl).1]
  | bot =>
    intro _ a b _ _ τ τ' k k' g g' t t' _ _ _ _ _
    exact Iff.rfl
  | imp α β iha ihb =>
    intro hf a b hda hdb τ τ' k k' g g' t t' hg hg' hτ hτ' hl
    have h1 := iha hf.1 a b (le_trans (le_max_left _ _) hda) (le_trans (le_max_left _ _) hdb)
      τ τ' k k' g g' t t' hg hg' hτ hτ' hl
    have h2 := ihb hf.2 a b (le_trans (le_max_right _ _) hda) (le_trans (le_max_right _ _) hdb)
      τ τ' k k' g g' t t' hg hg' hτ hτ' hl
    exact ⟨fun hi x => h2.mp (hi (h1.mpr x)), fun hi x => h2.mpr (hi (h1.mp x))⟩
  | box α _ =>
    intro hf
    exact hf.elim
  | untl γ α ihg iha =>
    intro hf a b hda hdb τ τ' k k' g g' t t' hg hg' hτ hτ' hl
    have hdb' : max (dFwd γ) (dFwd α) + 1 ≤ b := hdb
    obtain ⟨b₀, rfl⟩ : ∃ b₀ : ℕ, b = b₀ + 1 := ⟨b - 1, by omega⟩
    have hm : max (dFwd γ) (dFwd α) ≤ b₀ := Nat.le_of_succ_le_succ hdb'
    have hγa : dBack γ ≤ a := le_trans (le_max_left _ _) hda
    have hαa : dBack α ≤ a := le_trans (le_max_right _ _) hda
    have hγb : dFwd γ ≤ b₀ := le_trans (le_max_left _ _) hm
    have hαb : dFwd α ≤ b₀ := le_trans (le_max_right _ _) hm
    rw [LnkRow] at hl
    obtain ⟨hF1, hF2⟩ := hl.2.1 b₀ rfl
    constructor
    · rintro ⟨s, hts, hs, hr⟩
      obtain ⟨s', hs', hR, hbt⟩ := hF1 s hts
      refine ⟨s', hs', (iha hf.2 a b₀ hαa hαb τ τ' k k' g g' s s' hg hg' hτ hτ' hR).mp hs,
        fun r' h1 h2 => ?_⟩
      obtain ⟨r, hr1, hr2, hRr⟩ := hbt r' h1 h2
      exact (ihg hf.1 a b₀ hγa hγb τ τ' k k' g g' r r' hg hg' hτ hτ' hRr).mp (hr r hr1 hr2)
    · rintro ⟨s', hts, hs, hr⟩
      obtain ⟨s, hs', hR, hbt⟩ := hF2 s' hts
      refine ⟨s, hs', (iha hf.2 a b₀ hαa hαb τ τ' k k' g g' s s' hg hg' hτ hτ' hR).mpr hs,
        fun r h1 h2 => ?_⟩
      obtain ⟨r', hr1, hr2, hRr⟩ := hbt r h1 h2
      exact (ihg hf.1 a b₀ hγa hγb τ τ' k k' g g' r r' hg hg' hτ hτ' hRr).mpr (hr r' hr1 hr2)
  | snce γ α ihg iha =>
    intro hf a b hda hdb τ τ' k k' g g' t t' hg hg' hτ hτ' hl
    have hda' : max (dBack γ) (dBack α) + 1 ≤ a := hda
    obtain ⟨a₀, rfl⟩ : ∃ a₀ : ℕ, a = a₀ + 1 := ⟨a - 1, by omega⟩
    have hm : max (dBack γ) (dBack α) ≤ a₀ := Nat.le_of_succ_le_succ hda'
    have hγa : dBack γ ≤ a₀ := le_trans (le_max_left _ _) hm
    have hαa : dBack α ≤ a₀ := le_trans (le_max_right _ _) hm
    have hγb : dFwd γ ≤ b := le_trans (le_max_left _ _) hdb
    have hαb : dFwd α ≤ b := le_trans (le_max_right _ _) hdb
    rw [LnkRow] at hl
    obtain ⟨hB1, hB2⟩ := hl.2.2 a₀ rfl
    constructor
    · rintro ⟨s, hts, hs, hr⟩
      obtain ⟨s', hs', hR, hbt⟩ := hB1 s hts
      refine ⟨s', hs', (iha hf.2 a₀ b hαa hαb τ τ' k k' g g' s s' hg hg' hτ hτ' hR).mp hs,
        fun r' h1 h2 => ?_⟩
      obtain ⟨r, hr1, hr2, hRr⟩ := hbt r' h1 h2
      exact (ihg hf.1 a₀ b hγa hγb τ τ' k k' g g' r r' hg hg' hτ hτ' hRr).mp (hr r hr1 hr2)
    · rintro ⟨s', hts, hs, hr⟩
      obtain ⟨s, hs', hR, hbt⟩ := hB2 s' hts
      refine ⟨s, hs', (iha hf.2 a₀ b hαa hαb τ τ' k k' g g' s s' hg hg' hτ hτ' hR).mpr hs,
        fun r h1 h2 => ?_⟩
      obtain ⟨r', hr1, hr2, hRr⟩ := hbt r h1 h2
      exact (ihg hf.1 a₀ b hγa hγb τ τ' k k' g g' r r' hg hg' hτ hτ' hRr).mpr (hr r' hr1 hr2)
  | stab α _ =>
    intro hf
    exact hf.elim

end RowTruth

/-! ### The residue-carrying state relation

`Srel P a b` is `Zrel a b` with one conjunct added: the two countdowns are congruent modulo
`P + 1`.  The modulus is the one `paramsOkK1` already constrains — every pending cycle length of
the object divides `P + 1` — so the relation reads a residue the OBJECT determines and adds no
parameter.

**What the two necessary conditions on a row link say at `Srel`-related states.**  `LnkRow` is
stated over `Zrel`, so `LnkRow.first_zero` and `LnkRow.region_end_obj` are unchanged; what changes
is which pairs of states can satisfy them.

* `LnkRow.region_end_obj` asks the two current pending regions, of lengths the two countdowns, to
  end at one object state.  On an object whose pending walk is forced and periodic with a period
  dividing `P + 1`, congruent countdowns give equal ends, so the pairs that defeat `Zrel` by this
  lemma are not `Srel`-related.  On an object whose pending walk branches the lemma constrains the
  CHOICE of the second path's walk and the congruence does not by itself supply one.
* `LnkRow.first_zero` asks the first exhausted countdown after `t` to be answered by the first
  exhausted countdown after `t'`, with every position before the answer answered back.  The
  congruence says nothing about those intermediate positions: each one needs an answer carrying
  its own object state whose countdown is equal to its own or above `Zrel`'s threshold
  `2 (a + b)`, and that threshold does not depend on the object.

**`Srel` does NOT deliver the path forth with a whole-row correspondence.**  The second point is
an obstruction and not a remark: on an object with a pending `3`-cycle, at EVERY modulus `P + 1`
and every row budget `(a, b + 1)` with `1 ≤ a + b`, there are `Srel P a (b + 1)`-related states
with a ladder path through the first and no row-linked ladder path through the second.  The
shorter region has only `2` positions whose countdown stays above the threshold left after one
jump, and a `3`-cycle has three residues to answer.  This is compiled in the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`
(`no_rowLinked_path_of_Srel`).  So the hypothesis of the owed `exists_rowLinked_path` is not
`Srel P a b` either: a residue conjunct on the two STATES leaves `Zrel`'s object-independent
countdown threshold in place, and it is the threshold's margin against the object's cycle length
that the row link reads. -/

section Residue

variable {Q : Type} {pend : Q → Bool}

/-- **THE RESIDUE-CARRYING RELATION.** `Zrel a b` together with the congruence of the two
countdowns modulo `P + 1`. -/
def Srel (P a b : ℕ) (x y : LadderState Q pend) : Prop :=
  Zrel a b x y ∧ (x.1.2.1 : ℤ) ≡ (y.1.2.1 : ℤ) [ZMOD ((P : ℤ) + 1)]

/-- The residue-carrying relation refines the step system's relation at the same budget, so every
consumer of `Zrel a b` reads `Srel P a b` unchanged. -/
theorem Srel.toZrel {P a b : ℕ} {x y : LadderState Q pend} (h : Srel P a b x y) : Zrel a b x y :=
  h.1

theorem Srel.refl (P a b : ℕ) (x : LadderState Q pend) : Srel P a b x x :=
  ⟨Zrel.refl a b x, Int.ModEq.refl _⟩

theorem Srel.symm {P a b : ℕ} {x y : LadderState Q pend} (h : Srel P a b x y) : Srel P a b y x :=
  ⟨h.1.symm, h.2.symm⟩

theorem Srel.mono {P a b a' b' : ℕ} {x y : LadderState Q pend} (ha : a' ≤ a) (hb : b' ≤ b)
    (h : Srel P a b x y) : Srel P a' b' x y :=
  ⟨Zrel.mono ha hb h.1, h.2⟩

end Residue

/-! ### The threshold-carrying state relation

`Mrel P a b` is `Srel P a b` with one conjunct added: the two countdowns are equal, or both at
least `(P + 1) * (a + b)`.  The countdown threshold of `Zrel` has the margin `2` per unit of
budget whatever the object is; this one has the margin `P + 1`, the modulus `paramsOkK1`
constrains, so it grows with the object's pending cycle lengths.  Equal countdowns are congruent
countdowns, so the added conjunct is the countdown clause "equal, or congruent modulo `P + 1` and
both at least `(P + 1) * (a + b)`" conjoined with the rest of `Srel`.

**What the two necessary conditions on a row link say at `Mrel`-related states.**  `LnkRow` is
stated over `Zrel`, so `LnkRow.first_zero` and `LnkRow.region_end_obj` are unchanged; what changes
is which pairs of states can satisfy them.

* `LnkRow.region_end_obj` asks the two current pending regions to end at one object state.  At
  `Mrel`-related states the two countdowns are congruent modulo `P + 1` exactly as at
  `Srel`-related ones, and the raised threshold adds nothing to this condition: on an object
  whose pending walk is forced and periodic with a period dividing `P + 1` the ends agree, and on
  an object whose pending walk branches the condition is one on the CHOICE of the second path's
  walk, which no countdown threshold supplies.
* `LnkRow.first_zero` asks the first exhausted countdown after `t` to be answered by the first
  exhausted countdown after `t'`, with every position before the answer answered back.  The pair
  that defeats `Srel` — the shorter countdown exactly `2 (a + b) + 2` at the budget `(a, b + 1)` —
  is not `Mrel`-related when a pending cycle of length `≥ 3` divides `P + 1`: the shorter region
  now has at least `(P + 1) (a + b + 1)` positions, so on the countdown and the object state
  alone every residue of the longer region has an answer above the threshold left after one jump.
  What the lemma still does not say is what else an intermediate position must be answered ON:
  the row link relates the answer by `Zrel` at the budget left, which reads the gap `n - c`
  exactly inside a window of `2 (a + b) + 1` values, and neither `Mrel` nor `LnkRow.first_zero`
  mentions the register at an intermediate position.

**WHAT THIS SECTION DOES NOT CLAIM.**  No path forth with a whole-row correspondence is landed
over `Mrel`, and no refutation of one is landed either.  The round that stated this relation
attacked it on both fixtures of the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` and broke
neither; what it compiled instead is why each attack cannot break it, which is a statement about
the two attacks and not about the relation:

* On the forced pending `3`-cycle `R4`, the pair that refutes `Srel` is not `Mrel`-related at any
  `(K1)`-admissible parameters (`not_Mrel_xR_yR`), so the landed refutation does not transfer; and
  at a pair re-aimed ABOVE the raised threshold both necessary conditions are met rather than
  broken — the two regions end at one object state because `3 ∣ P + 1` (`region_end_agrees_R4`),
  which is the residue count the raised threshold was designed to survive.
* On the branching object `B5`, raising a countdown threshold indeed does nothing about a choice
  of walk — but the branching cuts the other way for a REFUTATION: it enlarges the second path's
  option set rather than shrinking it, and a walk of the longer region's length reaching the first
  region's end state always exists, because `2 ∣ P + 1` lets the second walk spend the difference
  in the `2`-cycle before copying the first (`region_end_matchable_B5`).

So `LnkRow.region_end_obj` is satisfied at `Mrel`-related states on BOTH fixtures, and the
coordinate that killed both predecessors is not available against this relation.  The coordinate
that remains unmeasured is the one the second bullet above names: what an INTERMEDIATE position of
the longer region must be answered on beyond its countdown and its object state.  `Zrel` at the
budget left reads the gap `n - c` exactly inside a window of `2 (a + b) + 1` values, and neither
`Mrel` nor either obstruction lemma constrains the register at an intermediate position, so
neither a refutation nor a path forth follows from what is compiled here.  Nothing is claimed
about a modulus that is a larger multiple of a cycle length. -/

section Threshold

variable {Q : Type} {pend : Q → Bool}

/-- **THE THRESHOLD-CARRYING RELATION.** `Srel P a b` together with the raised countdown clause:
the two countdowns are equal, or both at least `(P + 1) * (a + b)`. -/
def Mrel (P a b : ℕ) (x y : LadderState Q pend) : Prop :=
  Srel P a b x y ∧
    (x.1.2.1 = y.1.2.1 ∨ ((P + 1) * (a + b) ≤ x.1.2.1 ∧ (P + 1) * (a + b) ≤ y.1.2.1))

/-- The threshold-carrying relation refines the residue-carrying one at the same parameters. -/
theorem Mrel.toSrel {P a b : ℕ} {x y : LadderState Q pend} (h : Mrel P a b x y) :
    Srel P a b x y :=
  h.1

/-- The threshold-carrying relation refines the step system's relation at the same budget, so
every consumer of `Zrel a b` reads `Mrel P a b` unchanged. -/
theorem Mrel.toZrel {P a b : ℕ} {x y : LadderState Q pend} (h : Mrel P a b x y) : Zrel a b x y :=
  h.1.1

theorem Mrel.refl (P a b : ℕ) (x : LadderState Q pend) : Mrel P a b x x :=
  ⟨Srel.refl P a b x, Or.inl rfl⟩

theorem Mrel.symm {P a b : ℕ} {x y : LadderState Q pend} (h : Mrel P a b x y) : Mrel P a b y x :=
  ⟨h.1.symm, h.2.elim (fun e => Or.inl e.symm) (fun e => Or.inr ⟨e.2, e.1⟩)⟩

/-- Monotonicity in the budget, in the direction `Zrel.mono` has: the raised threshold
`(P + 1) * (a + b)` shrinks with the budget, as `Zrel`'s own thresholds do. -/
theorem Mrel.mono {P a b a' b' : ℕ} {x y : LadderState Q pend} (ha : a' ≤ a) (hb : b' ≤ b)
    (h : Mrel P a b x y) : Mrel P a' b' x y := by
  refine ⟨Srel.mono ha hb h.1, h.2.elim Or.inl fun e => Or.inr ?_⟩
  have hm : (P + 1) * (a' + b') ≤ (P + 1) * (a + b) := Nat.mul_le_mul_left _ (by omega)
  exact ⟨le_trans hm e.1, le_trans hm e.2⟩

/-! ### What the register coordinate measures at the `Mrel` pair

**THE REGISTER'S LOCAL LAW.**  `RladAdm` mentions the register `n` in exactly two of its four
conjuncts: in `Drift n n'`, a free `±1`/`0` walk, and inside `Count` ONLY at an idle-to-pending
transition, where `c' = n` seeds the new countdown.  Inside a pending region `Count` is `c' + 1 = c`
and does not mention the register; `Adm pend q` constrains the countdown, never the register.  Two
consequences are forced and nothing else is: the register falls by at most one per step, and since
the countdown inside a region falls by exactly one per step, the gap `n - c` is non-decreasing
along a region and rises by at most two per step.

**WHAT WAS MEASURED.**  At the landed `Mrel` pair, with the countdown coordinate settled by
`region_end_agrees_R4` and the object coordinate by `region_end_matchable_B5`, the register
coordinate is SATISFIABLE pointwise on both fixtures of the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`: every position
of the longer region admits an answering position of the shorter one at which all four `Zrel`
clauses at the budget left hold, with the answering register exhibited as a function of the offset.
Past the modulus every clause holds by equality; over the longer region's extra `P + 1` positions
no countdown-matching partner exists, and what carries them is the register's one-sided law, which
holds the shorter path's register above the threshold there while the gap clause is met by raising
the exhibited register by exactly the modulus.

**WHAT THIS DOES NOT SAY.**  It is not a path forth and not a row link: `LnkRow` additionally
demands the recursive jump structure and the back-matching condition at every budget, and on the
first fixture the exhibited register's two branches are each a `Drift` walk but are not shown to
join into one at the switch.  No relation is stated here, `Mrel` is unchanged, and nothing is
claimed about the clip, about `ladderLift`, or about `cellAt_const_of_kappa_eq`.
-/

end Threshold

end FormalSystem.Metalogic.Decidability.RaySummary
