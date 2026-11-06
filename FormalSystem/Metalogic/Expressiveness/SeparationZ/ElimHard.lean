/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Eliminations

/-!
# GHR Lemma 10.2.3 — the eliminations, Cases 5-8

[GHR][gabbay1994] vol. 1, Lemma 10.2.3's remaining four cases: those in which the same
`untl B A` occurs in **both** the event argument and the guard argument of a `snce`.

| Case | GHR | guard-first |
|------|-----|-------------|
| 5 | `S(a ∧ U(A,B), q ∨ U(A,B))` | `snce (q ∨ untl B A) (a ∧ untl B A)` |
| 6 | `S(a ∧ ¬U(A,B), q ∨ U(A,B))` | `snce (q ∨ untl B A) (a ∧ ¬untl B A)` |
| 7 | `S(a ∧ U(A,B), q ∨ ¬U(A,B))` | `snce (q ∨ ¬untl B A) (a ∧ untl B A)` |
| 8 | `S(a ∧ ¬U(A,B), q ∨ ¬U(A,B))` | `snce (q ∨ ¬untl B A) (a ∧ ¬untl B A)` |

Only Case 5 is proved semantically. Cases 6, 7 and 8 are *reductions* to earlier cases, in the
source's own acyclic order — `8` from the generic negated-since distribution identity plus `5`
(twice) and `2`; `7` from `8` and `4` after one semantic step; `6` from `3` and `5` after one
semantic step. The direct semantic re-anchoring of Cases 6-8 that an earlier dispatch attempted
is *not* the source's method, and it is what produced the unexpressible `∃∀` guard-failure
condition recorded as an obstruction in `Eliminations.lean`'s module docstring. That record
describes the defect of that route, not a defect of Lemma 10.2.3.

## GHR's printed Case 5 is refuted over `ℤ`

The printed formula is

```
  S(a, B) ∧ [A ∨ (B ∧ U(A, B))]
∨ S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A)) ∧ [A ∨ (B ∧ U(A, B))] ∧ ¬S(¬q, ¬A).
```

It is **false** over the integer flow, and so is the bracketing that attaches
`[A ∨ (B ∧ U(A,B))]` to the first disjunct only. Two models refute them, both compiled in
`specs/867_formalize_gabbay_separation_ztime/prototype/`:

* `a(0)`, `q ∈ {1,2}`, `A(1)`, `B ≡ ⊥`, at `t = 3`. The left-hand side holds — the event's
  `U(A,B)@0` is witnessed by the adjacent `A`-point `1` over an empty guard interval, and the
  outer guard is met by `q` throughout — while `[A ∨ (B ∧ U(A,B))]` fails at `3`. This refutes
  every bracketing that makes that conjunct a conjunct of **both** disjuncts.
* `a(0)`, `q ≡ ⊥`, `A ∈ {1,5}`, `B` on `{2,3,4}`, at `t = 2`. The left-hand side holds, with the
  outer guard met at `r = 1` by `U(A,B)@1`, whose witness `5` lies beyond the evaluation point;
  but `S(a,B)@2` fails because `B(1)` is false, and `¬S(¬q,¬A)@2` fails because `¬q(1)` holds
  with no `A`-point in `(1,2)`. This refutes the first-disjunct-only bracketing too.

**The landed form is a repair, not the printed formula.** It keeps GHR's own pure-past core —
`case5Core`, which is `S(a,B) ∨ S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A))` verbatim — and GHR's
`¬S(¬q,¬A)` verbatim, and moves `[A ∨ (B ∧ U(A,B))]` from a shared conjunct to a **case split**.
Do not restore the printed form: both models above are compiled refutations of it.

## Why the split on `W := A ∨ (B ∧ U(A,B))` is the right one

`W` holds at `t` exactly when `∃x ≥ t, A(x) ∧ B on [t,x)` — the `U(A,B)` witness is at or after
the evaluation point. Under `W`, `B on (r,t)` already forces `U(A,B)@r` for every `r < t`, which
is what makes GHR's re-anchoring guard `A ∨ B ∨ ¬S(¬q,¬A)` equivalent to the real guard
`q ∨ U(A,B)` above an `A`-point (`usTruth_case5_guard_iff`, the one lemma this development adds
to the source). Under `¬W` every `U(A,B)` witness lies strictly below `t`, so the guard dies at
and above the greatest `A`-point `z` below `t`, forcing `q on [z,t)` — which is exactly
`¬S(¬q,¬A)@t` — and leaving the left-hand side at `z`, where `A(z)` makes `W` true again and the
first branch applies. `S(A ∧ case5Core, ¬A)` is how `z` is named at `t`.

## Main Definitions

- `case5W`, `case5Core`, `case5Rhs`: the split, GHR's pure-past core, and Case 5's right-hand side

## Main Results

- `exists_greatest_below`: the greatest-witness device over `ℤ`, dual to `exists_least_above`
- `usTruth_case5_guard_iff`: the guard equivalence (Claim C of the Phase 16 gate record)
- `usTruth_case5`: GHR 10.2.3, Case 5
- `isSeparated_case5Rhs`: its separatedness, discharged

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemma 10.2.3, Case 5
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## The greatest-witness device -/

/--
**The greatest witness strictly below `t`.** The exact dual of `exists_least_above`, and the
discreteness of `ℤ` in the form the `¬W` branch of Case 5 consumes: the greatest `A`-point below
the evaluation point is where the outer guard stops being satisfiable by `U(A,B)`.

Paper: — (formalization-native; the manuscript carries no greatest-witness device for the
integer flow)
-/
theorem exists_greatest_below {P : ℤ → Prop} {t : ℤ} (h : ∃ s : ℤ, s < t ∧ P s) :
    ∃ m : ℤ, m < t ∧ P m ∧ ∀ r : ℤ, m < r → r < t → ¬ P r := by
  obtain ⟨ub, ⟨hub1, hub2⟩, hmax⟩ :=
    Int.exists_greatest_of_bdd (P := fun z => z < t ∧ P z) ⟨t - 1, fun z hz => by omega⟩ h
  exact ⟨ub, hub1, hub2, fun r hr1 hr2 hPr => absurd (hmax r ⟨hr2, hPr⟩) (by omega)⟩

/-! ## Case 5's right-hand side -/

/--
`W := A ∨ (B ∧ U(A,B))`. At `t` this says `∃x ≥ t, A(x) ∧ B on [t,x)`: the `U(A,B)` witness is at
or after the evaluation point. This is the **only** place `untl` occurs in `case5Rhs`, and it is
never under a `snce`.
-/
def case5W (A B : USForm) : USForm := A.or (B.and (USForm.untl B A))

/--
GHR's own pure-past core of Case 5, transcribed verbatim:
`S(a,B) ∨ S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A))`.
-/
def case5Core (a q A B : USForm) : USForm :=
  (USForm.snce B a).or
    (USForm.snce (A.or (B.or (USForm.snce A.neg q.neg).neg)) (A.and (USForm.snce B a)))

/--
Case 5's separated right-hand side: GHR's core under a case split on `W`, with the `¬W` branch
re-anchored at the greatest `A`-point below the evaluation point. See the module docstring for
the two compiled models that refute the printed formula this repairs.
-/
def case5Rhs (a q A B : USForm) : USForm :=
  ((case5W A B).and (case5Core a q A B)).or
    ((case5W A B).neg.and
      ((USForm.snce A.neg q.neg).neg.and
        (USForm.snce A.neg (A.and (case5Core a q A B)))))

@[simp] theorem usTruth_case5W_iff (A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (case5W A B) ↔
      usTruth v t A ∨ (usTruth v t B ∧ usTruth v t (USForm.untl B A)) := by
  rw [case5W, usTruth_or_iff, usTruth_and_iff]

theorem usTruth_case5Core_iff (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (case5Core a q A B) ↔
      usTruth v t (USForm.snce B a) ∨
        ∃ w : ℤ, w < t ∧ (usTruth v w A ∧ usTruth v w (USForm.snce B a)) ∧
          ∀ r : ℤ, w < r → r < t →
            (usTruth v r A ∨ usTruth v r B ∨ ¬ usTruth v r (USForm.snce A.neg q.neg)) := by
  rw [case5Core, usTruth_or_iff]
  refine or_congr Iff.rfl ?_
  rw [usTruth_snce_iff]
  exact exists_congr fun w => and_congr_right fun _ =>
    and_congr (usTruth_and_iff v w A _)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => by
        rw [usTruth_or_iff, usTruth_or_iff, usTruth_neg_iff])

/-! ## The two auxiliary facts about `W` -/

/--
**Under `W` at `t`, a `B`-interval back to `t` already forces `U(A,B)`.** This is the whole
content of the `W` branch: it is what makes GHR's re-anchoring guard sufficient.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_untl_of_case5W (A B : USForm) (v : ℕ → ℤ → Prop) {r t : ℤ} (hrt : r < t)
    (hB : ∀ x : ℤ, r < x → x < t → usTruth v x B)
    (hW : usTruth v t (case5W A B)) :
    usTruth v r (USForm.untl B A) := by
  rcases (usTruth_case5W_iff A B v t).mp hW with hA | ⟨hBt, hUt⟩
  · exact (usTruth_untl_iff v r B A).mpr ⟨t, hrt, hA, hB⟩
  · obtain ⟨u, htu, hAu, hgu⟩ := (usTruth_untl_iff v t B A).mp hUt
    refine (usTruth_untl_iff v r B A).mpr ⟨u, by omega, hAu, fun x h1 h2 => ?_⟩
    rcases lt_trichotomy x t with h | h | h
    · exact hB x h1 h
    · exact h ▸ hBt
    · exact hgu x h h2

/--
**Under `¬W` at `t`, every `U(A,B)` witness below `t` is itself below `t`.** The dual fact, and
what kills the outer guard at and above the greatest `A`-point below `t`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem exists_atom_below_of_untl (A B : USForm) (v : ℕ → ℤ → Prop) {r t : ℤ} (hrt : r < t)
    (hnW : ¬ usTruth v t (case5W A B)) (hU : usTruth v r (USForm.untl B A)) :
    ∃ x : ℤ, r < x ∧ x < t ∧ usTruth v x A := by
  obtain ⟨u, hru, hAu, hgu⟩ := (usTruth_untl_iff v r B A).mp hU
  rcases lt_trichotomy u t with h | h | h
  · exact ⟨u, hru, h, hAu⟩
  · exact absurd ((usTruth_case5W_iff A B v t).mpr (Or.inl (h ▸ hAu))) hnW
  · refine absurd ((usTruth_case5W_iff A B v t).mpr (Or.inr ⟨hgu t hrt h, ?_⟩)) hnW
    exact (usTruth_untl_iff v t B A).mpr ⟨u, h, hAu, fun x h1 h2 => hgu x (by omega) h2⟩

/-! ## The guard equivalence

The one lemma this development adds to the source. Above an `A`-point, and under `W` at the
evaluation point, the real outer guard `q ∨ U(A,B)` and GHR's re-anchoring guard
`A ∨ B ∨ ¬S(¬q,¬A)` cut out the same windows. -/

/--
**The guard equivalence.** Let `u < t` with `A` true at `u`, and let `W` hold at `t`. Then
`q ∨ U(A,B)` holds throughout `[u,t)` iff `A ∨ B ∨ ¬S(¬q,¬A)` holds throughout `(u,t)`.

`←`: at `r ∈ [u,t)`, either `B` holds throughout `(r,t)` — and then `usTruth_untl_of_case5W`
gives `U(A,B)@r` — or the least `¬B` point `n` above `r` lies in `(u,t)`, where `B` fails, so
either `A(n)` witnesses `U(A,B)@r` or `¬S(¬q,¬A)@n` instantiated at `r` gives `q(r)` or an
`A`-point in `(r,n)`, which witnesses `U(A,B)@r`.

`→`: at `r ∈ (u,t)` with `¬A(r) ∧ ¬B(r)`, any `S(¬q,¬A)@r` witness `y` either lies below `u`,
where the `A`-point `u` itself falsifies its guard, or lies in `[u,r)`, where `q(y)` fails and so
`U(A,B)@y` holds, whose witness is forced into `(y,r)` by `¬B(r)` and `¬A(r)` — again falsifying
the guard.

Paper: — (formalization-native; the manuscript's printed Case 5 states no such equivalence and
the formula it states is refuted over `ℤ`, see this module's docstring)
-/
theorem usTruth_case5_guard_iff (q A B : USForm) (v : ℕ → ℤ → Prop) {u t : ℤ}
    (_hut : u < t) (hAu : usTruth v u A) (hW : usTruth v t (case5W A B)) :
    (∀ r : ℤ, u ≤ r → r < t → (usTruth v r q ∨ usTruth v r (USForm.untl B A))) ↔
      (∀ r : ℤ, u < r → r < t →
        (usTruth v r A ∨ usTruth v r B ∨
          ¬ usTruth v r (USForm.snce A.neg q.neg))) := by
  constructor
  · intro hg r hur hrt
    by_cases hA : usTruth v r A
    · exact Or.inl hA
    by_cases hB : usTruth v r B
    · exact Or.inr (Or.inl hB)
    refine Or.inr (Or.inr ?_)
    intro hS
    obtain ⟨y, hyr, hnq, hny⟩ := (usTruth_snce_iff v r A.neg q.neg).mp hS
    rcases (by omega : y < u ∨ u ≤ y) with hyu | hyu
    · exact (usTruth_neg_iff v u A).mp (hny u hyu (by omega)) hAu
    · rcases hg y hyu (by omega) with hq | hU
      · exact (usTruth_neg_iff v y q).mp hnq hq
      · obtain ⟨x, hyx, hAx, hgx⟩ := (usTruth_untl_iff v y B A).mp hU
        rcases lt_trichotomy x r with h | h | h
        · exact (usTruth_neg_iff v x A).mp (hny x hyx h) hAx
        · exact hA (h ▸ hAx)
        · exact hB (hgx r hyr h)
  · intro hg r hur hrt
    by_cases hBall : ∀ x : ℤ, r < x → x < t → usTruth v x B
    · exact Or.inr (usTruth_untl_of_case5W A B v hrt hBall hW)
    push Not at hBall
    obtain ⟨x₀, hrx₀, hx₀t, hnBx₀⟩ := hBall
    obtain ⟨n, hrn, hnBn, hminB⟩ :=
      exists_least_above (P := fun z => ¬ usTruth v z B) ⟨x₀, hrx₀, hnBx₀⟩
    have hnt : n < t := by
      by_contra hc
      exact (hminB x₀ hrx₀ (by omega)) hnBx₀
    have hBrn : ∀ x : ℤ, r < x → x < n → usTruth v x B := fun x h1 h2 =>
      not_not.mp (hminB x h1 h2)
    rcases hg n (by omega) hnt with hAn | hBn | hSn
    · exact Or.inr ((usTruth_untl_iff v r B A).mpr ⟨n, hrn, hAn, hBrn⟩)
    · exact absurd hBn hnBn
    · by_cases hq : usTruth v r q
      · exact Or.inl hq
      refine Or.inr ?_
      by_contra hnU
      refine hSn ((usTruth_snce_iff v n A.neg q.neg).mpr
        ⟨r, hrn, (usTruth_neg_iff v r q).mpr hq, fun x h1 h2 => ?_⟩)
      exact (usTruth_neg_iff v x A).mpr fun hAx =>
        hnU ((usTruth_untl_iff v r B A).mpr ⟨x, h1, hAx, fun y hy1 hy2 => hBrn y hy1 (by omega)⟩)

/-! ## The `W` branch -/

/--
**Case 5 under `W`.** When the `U(A,B)` witness may be taken at or after the evaluation point,
Case 5 collapses to GHR's pure-past core alone.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case5_of_case5W (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ)
    (hW : usTruth v t (case5W A B)) :
    usTruth v t (USForm.snce (q.or (USForm.untl B A)) (a.and (USForm.untl B A))) ↔
      usTruth v t (case5Core a q A B) := by
  rw [usTruth_case5Core_iff]
  constructor
  · intro h
    obtain ⟨s, hst, hev, hg⟩ :=
      (usTruth_snce_iff v t (q.or (USForm.untl B A)) (a.and (USForm.untl B A))).mp h
    obtain ⟨ha, hU⟩ := (usTruth_and_iff v s a (USForm.untl B A)).mp hev
    obtain ⟨u, hsu, hAu, hBu⟩ := (usTruth_untl_iff v s B A).mp hU
    have hg' : ∀ r : ℤ, s < r → r < t →
        (usTruth v r q ∨ usTruth v r (USForm.untl B A)) := fun r h1 h2 =>
      (usTruth_or_iff v r q (USForm.untl B A)).mp (hg r h1 h2)
    rcases (by omega : t ≤ u ∨ u < t) with hut | hut
    · exact Or.inl ((usTruth_snce_iff v t B a).mpr
        ⟨s, hst, ha, fun x h1 h2 => hBu x h1 (by omega)⟩)
    · refine Or.inr ⟨u, hut, ⟨hAu, (usTruth_snce_iff v u B a).mpr ⟨s, hsu, ha, hBu⟩⟩, ?_⟩
      exact (usTruth_case5_guard_iff q A B v hut hAu hW).mp
        (fun r h1 h2 => hg' r (by omega) h2)
  · rintro (hSab | ⟨w, hwt, ⟨hAw, hSabw⟩, hgw⟩)
    · obtain ⟨s, hst, ha, hB⟩ := (usTruth_snce_iff v t B a).mp hSab
      refine (usTruth_snce_iff v t (q.or (USForm.untl B A)) (a.and (USForm.untl B A))).mpr
        ⟨s, hst, (usTruth_and_iff v s a (USForm.untl B A)).mpr
          ⟨ha, usTruth_untl_of_case5W A B v hst (fun x h1 h2 => hB x h1 h2) hW⟩,
          fun r h1 h2 => ?_⟩
      exact (usTruth_or_iff v r q (USForm.untl B A)).mpr
        (Or.inr (usTruth_untl_of_case5W A B v h2 (fun x hx1 hx2 => hB x (by omega) hx2) hW))
    · have hguard := (usTruth_case5_guard_iff q A B v hwt hAw hW).mpr hgw
      obtain ⟨s, hsw, ha, hB⟩ := (usTruth_snce_iff v w B a).mp hSabw
      refine (usTruth_snce_iff v t (q.or (USForm.untl B A)) (a.and (USForm.untl B A))).mpr
        ⟨s, by omega, (usTruth_and_iff v s a (USForm.untl B A)).mpr
          ⟨ha, (usTruth_untl_iff v s B A).mpr ⟨w, hsw, hAw, hB⟩⟩, fun r h1 h2 => ?_⟩
      rcases (by omega : r < w ∨ w ≤ r) with hrw | hrw
      · exact (usTruth_or_iff v r q (USForm.untl B A)).mpr
          (Or.inr ((usTruth_untl_iff v r B A).mpr
            ⟨w, hrw, hAw, fun x hx1 hx2 => hB x (by omega) hx2⟩))
      · exact (usTruth_or_iff v r q (USForm.untl B A)).mpr (hguard r hrw h2)

/-! ## The `¬W` branch -/

/--
**Case 5 under `¬W`.** When every `U(A,B)` witness lies strictly below the evaluation point, the
outer guard dies at and above the greatest `A`-point `z` below `t`, which forces `q` throughout
`[z,t)` — exactly `¬S(¬q,¬A)@t` — and leaves the left-hand side at `z`, where `A(z)` restores
`W` and `usTruth_case5_of_case5W` applies.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case5_of_not_case5W (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ)
    (hnW : ¬ usTruth v t (case5W A B)) :
    usTruth v t (USForm.snce (q.or (USForm.untl B A)) (a.and (USForm.untl B A))) ↔
      (¬ usTruth v t (USForm.snce A.neg q.neg) ∧
        usTruth v t (USForm.snce A.neg (A.and (case5Core a q A B)))) := by
  constructor
  · intro h
    obtain ⟨s, hst, hev, hg⟩ :=
      (usTruth_snce_iff v t (q.or (USForm.untl B A)) (a.and (USForm.untl B A))).mp h
    obtain ⟨ha, hU⟩ := (usTruth_and_iff v s a (USForm.untl B A)).mp hev
    have hg' : ∀ r : ℤ, s < r → r < t →
        (usTruth v r q ∨ usTruth v r (USForm.untl B A)) := fun r h1 h2 =>
      (usTruth_or_iff v r q (USForm.untl B A)).mp (hg r h1 h2)
    obtain ⟨u, hsu, hut, hAu⟩ := exists_atom_below_of_untl A B v hst hnW hU
    obtain ⟨z, hzt, hAz, hmaxA⟩ :=
      exists_greatest_below (P := fun x => usTruth v x A) ⟨u, hut, hAu⟩
    have huz : u ≤ z := by
      by_contra hc
      exact hmaxA u (by omega) hut hAu
    -- `q` holds throughout `[z, t)`.
    have hqz : ∀ y : ℤ, z ≤ y → y < t → usTruth v y q := by
      intro y hzy hyt
      rcases hg' y (by omega) hyt with hq | hUy
      · exact hq
      · obtain ⟨x, hyx, hxt, hAx⟩ := exists_atom_below_of_untl A B v hyt hnW hUy
        exact absurd hAx (hmaxA x (by omega) hxt)
    refine ⟨?_, ?_⟩
    · intro hS
      obtain ⟨y, hyt, hnq, hny⟩ := (usTruth_snce_iff v t A.neg q.neg).mp hS
      rcases (by omega : y < z ∨ z ≤ y) with hyz | hyz
      · exact (usTruth_neg_iff v z A).mp (hny z hyz hzt) hAz
      · exact (usTruth_neg_iff v y q).mp hnq (hqz y hyz hyt)
    · refine (usTruth_snce_iff v t A.neg (A.and (case5Core a q A B))).mpr
        ⟨z, hzt, (usTruth_and_iff v z A (case5Core a q A B)).mpr ⟨hAz, ?_⟩,
          fun r h1 h2 => (usTruth_neg_iff v r A).mpr (hmaxA r h1 h2)⟩
      have hWz : usTruth v z (case5W A B) := (usTruth_case5W_iff A B v z).mpr (Or.inl hAz)
      refine (usTruth_case5_of_case5W a q A B v z hWz).mp ?_
      refine (usTruth_snce_iff v z (q.or (USForm.untl B A)) (a.and (USForm.untl B A))).mpr
        ⟨s, by omega, (usTruth_and_iff v s a (USForm.untl B A)).mpr ⟨ha, hU⟩,
          fun r h1 h2 => hg r h1 (by omega)⟩
  · rintro ⟨hnS, hS⟩
    obtain ⟨z, hzt, hev, hnA⟩ :=
      (usTruth_snce_iff v t A.neg (A.and (case5Core a q A B))).mp hS
    obtain ⟨hAz, hCore⟩ := (usTruth_and_iff v z A (case5Core a q A B)).mp hev
    have hWz : usTruth v z (case5W A B) := (usTruth_case5W_iff A B v z).mpr (Or.inl hAz)
    obtain ⟨s, hsz, hev', hg⟩ :=
      (usTruth_snce_iff v z (q.or (USForm.untl B A)) (a.and (USForm.untl B A))).mp
        ((usTruth_case5_of_case5W a q A B v z hWz).mpr hCore)
    -- `¬S(¬q,¬A)` at `t`, with no `A`-point in `(z,t)`, forces `q` throughout `[z,t)`.
    have hqz : ∀ y : ℤ, z ≤ y → y < t → usTruth v y q := by
      intro y hzy hyt
      by_contra hq
      refine hnS ((usTruth_snce_iff v t A.neg q.neg).mpr
        ⟨y, hyt, (usTruth_neg_iff v y q).mpr hq, fun x h1 h2 => ?_⟩)
      exact (usTruth_neg_iff v x A).mpr fun hAx =>
        (usTruth_neg_iff v x A).mp (hnA x (by omega) h2) hAx
    refine (usTruth_snce_iff v t (q.or (USForm.untl B A)) (a.and (USForm.untl B A))).mpr
      ⟨s, by omega, hev', fun r h1 h2 => ?_⟩
    rcases (by omega : r < z ∨ z ≤ r) with hrz | hrz
    · exact hg r h1 hrz
    · exact (usTruth_or_iff v r q (USForm.untl B A)).mpr (Or.inl (hqz r hrz h2))

/-! ## Case 5 -/

/--
**GHR 10.2.3, Case 5**: `S(a ∧ U(A,B), q ∨ U(A,B))` is separated.

Proved semantically, by a case split on `W := A ∨ (B ∧ U(A,B))` — the pure present-and-future
condition saying the `U(A,B)` witness may be taken at or after the evaluation point. The `W`
branch is `usTruth_case5_of_case5W` and collapses to GHR's own core; the `¬W` branch is
`usTruth_case5_of_not_case5W` and re-anchors at the greatest `A`-point below `t`.

**The landed right-hand side is not GHR's printed formula**: the printed formula is refuted over
`ℤ` by two compiled models, and so is the bracketing that attaches `[A ∨ (B ∧ U(A,B))]` to its
first disjunct alone. See this module's docstring; do not restore either form.

This case is proved **upstream** of GHR 10.2.4 and of the junction-depth induction, and depends
on neither: Cases 6, 7 and 8 reduce to it, never the reverse.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case5 (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce (q.or (USForm.untl B A)) (a.and (USForm.untl B A))) ↔
      usTruth v t (case5Rhs a q A B) := by
  have hsplit : usTruth v t (case5Rhs a q A B) ↔
      (usTruth v t (case5W A B) ∧ usTruth v t (case5Core a q A B)) ∨
        (¬ usTruth v t (case5W A B) ∧
          (¬ usTruth v t (USForm.snce A.neg q.neg) ∧
            usTruth v t (USForm.snce A.neg (A.and (case5Core a q A B))))) := by
    rw [case5Rhs, usTruth_or_iff, usTruth_and_iff, usTruth_and_iff, usTruth_and_iff,
      usTruth_neg_iff, usTruth_neg_iff]
  rw [hsplit]
  by_cases hW : usTruth v t (case5W A B)
  · constructor
    · intro h
      exact Or.inl ⟨hW, (usTruth_case5_of_case5W a q A B v t hW).mp h⟩
    · rintro (⟨_, h⟩ | ⟨hnW, _⟩)
      · exact (usTruth_case5_of_case5W a q A B v t hW).mpr h
      · exact absurd hW hnW
  · constructor
    · intro h
      exact Or.inr ⟨hW, (usTruth_case5_of_not_case5W a q A B v t hW).mp h⟩
    · rintro (⟨hWt, _⟩ | ⟨_, h⟩)
      · exact absurd hWt hW
      · exact (usTruth_case5_of_not_case5W a q A B v t hW).mpr h

/-! ## Separatedness -/

/-- GHR's pure-past core is `snce`-only whenever the four parameters are.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSOnly_case5Core {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsSOnly (case5Core a q A B) :=
  IsSOnly.or (IsSOnly.snce hBs ha)
    (IsSOnly.snce (IsSOnly.or hAs (IsSOnly.or hBs (IsSOnly.snce hAs.neg hq.neg).neg))
      (hAs.and (IsSOnly.snce hBs ha)))

/-- `W` is syntactically separated whenever the four parameters are: a Boolean combination of a
present leaf-level formula with one `untl`-only conjunct.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSeparated_case5W {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B)
    (hAu : IsUOnly A) (hBu : IsUOnly B) : IsSeparated (case5W A B) :=
  IsSeparated.or (IsSeparated.ofIsSOnly hAs)
    (IsSeparated.and (IsSeparated.ofIsSOnly hBs) (IsSeparated.untl hBu hAu))

/-- Case 5's right-hand side is syntactically separated whenever the four parameters are.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSeparated_case5Rhs {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A) (hBu : IsUOnly B) :
    IsSeparated (case5Rhs a q A B) := by
  have hcore := isSOnly_case5Core ha hq hAs hBs
  have hW := isSeparated_case5W hAs hBs hAu hBu
  exact IsSeparated.or (IsSeparated.and hW (IsSeparated.ofIsSOnly hcore))
    (IsSeparated.and hW.neg (IsSeparated.ofIsSOnly
      ((IsSOnly.snce hAs.neg hq.neg).neg.and (IsSOnly.snce hAs.neg (hAs.and hcore)))))

end FormalSystem.Metalogic.Expressiveness.SeparationZ
