/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.NegationEquiv
import FormalSystem.Metalogic.Expressiveness.SeparationZ.LeafAbstraction

/-!
# GHR Lemma 10.2.3 — the eliminations, Cases 1-4

[GHR][gabbay1994] vol. 1, Lemma 10.2.3 pulls an `until` out from under a `since`. Its eight
cases are the sign combinations of `±U(A,B)` in the event argument and in the guard argument of
an `S`. This module carries the four cases in which the `untl` occurs in **exactly one** of the
two arguments:

| Case | GHR | guard-first |
|------|-----|-------------|
| 1 | `S(a ∧ U(A,B), q)` | `snce q (a ∧ untl B A)` |
| 2 | `S(a ∧ ¬U(A,B), q)` | `snce q (a ∧ ¬untl B A)` |
| 3 | `S(a, q ∨ U(A,B))` | `snce (q ∨ untl B A) a` |
| 4 | `S(a, q ∨ ¬U(A,B))` | `snce (q ∨ ¬untl B A) a` |

The four cases in which it occurs in **both** arguments (GHR's Cases 5-8) are **not** in this
module, and no declaration here depends on them. GHR's printed Case 5 is refuted over the
integer flow by a counterexample on a `ℤ` model with `B` identically false, where the adjacency
degeneracy `(t, t+1) ∩ ℤ = ∅` makes the `B`-guard vacuous; Cases 6-8 are published only as
reductions with acknowledged gaps. The obstruction is structural rather than tactical: the
guard-failure condition of a case whose **guard** carries `¬U(A,B)` is an `∃∀` over the window
`(s,t]`, and re-anchoring it at its own rightmost witness retains a forward-looking,
`t`-bounded conjunct, which is not a formula at the guard's own evaluation point and so cannot
be an `S`-guard. The single-sign cases below have no such condition.

## Arbitrary parameters, not atoms

Every statement below takes **arbitrary** `USForm` parameters `a`, `q`, `A`, `B`. GHR's
atomicity hypothesis on them exists only to license their substitution step, and plays no part
in the semantic arguments; abstracting the leaves (see `Syntax.lean`'s module docstring) removes
the need for any substitution lemma. What atomicity *is* needed for is the **separatedness** of
each right-hand side, and that is taken as an explicit `IsSOnly`/`IsUOnly` side condition on the
four parameters and discharged as a theorem, never asserted in prose.

## Which reduction each case uses

* **Case 1** is proved directly, by the trichotomy of the `untl` witness `u` against the
  evaluation point `t`: `u < t` re-anchors the outer `S` at `u`; `u = t` reads `A` off `t`; and
  `u > t` splits the `B`-guard at `t`, leaving `U(A,B)` as the one pure-future conjunct.
* **Case 2** is `usTruth_neg_untl` (GHR 10.2.2) in the event argument, then the event-disjunction
  distributivity of GHR 10.2.1, then Case 1 on one summand and `usTruth_snce_allFuture` on the
  other.
* **Case 3** is `usTruth_neg_snce` (GHR 10.2.2's mirror) applied to the *negation* of the
  statement, which moves the guard's `U(A,B)` into the event argument as `¬U(A,B)` — Case 2's
  shape. The result is the negation of a separated formula, which is separated.
* **Case 4** is the same move, landing on Case 1's shape instead, since the guard's `¬U(A,B)`
  becomes `¬¬U(A,B)`, i.e. `U(A,B)`.

## Main Definitions

- `IsSeparated`: a `USForm` in which no `untl` sits under a `snce` and no `snce` under an `untl`
- `case1Rhs`, `case2Rhs`, `case3Rhs`, `case4Rhs`: the four separated right-hand sides
- `case2RhsPrinted`, `case3RhsPrinted`: GHR's printed Case 2 form and the Case 3 form over it,
  whose only `untl` occurrence is `untl B A`

## Main Results

- `usTruth_snce_congr`, `usTruth_untl_congr`: congruence for the two binary temporal operators
- `usTruth_snce_allFuture`: `S(a ∧ GX, q) ↔ X ∧ GX ∧ S(a, q ∧ X)` — the `G`-under-`S` elimination
- `usTruth_case1` … `usTruth_case4`: the four eliminations
- `isSeparated_case1Rhs` … `isSeparated_case4Rhs`: their separatedness, discharged
- `usTruth_case2_printed`, `usTruth_case3_printed`: the same two eliminations at the printed
  right-hand sides, with `isSeparated_case2RhsPrinted` and `isSeparated_case3RhsPrinted`

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemma 10.2.3, Cases 1-4
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## Congruence for the binary temporal operators -/

/-- Congruence for `snce` under pointwise `usTruth` equivalence of both arguments. -/
theorem usTruth_snce_congr {G G' E E' : USForm}
    (hG : ∀ (w : ℕ → ℤ → Prop) (r : ℤ), usTruth w r G ↔ usTruth w r G')
    (hE : ∀ (w : ℕ → ℤ → Prop) (r : ℤ), usTruth w r E ↔ usTruth w r E')
    (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce G E) ↔ usTruth v t (USForm.snce G' E') := by
  rw [usTruth_snce_iff, usTruth_snce_iff]
  exact exists_congr fun s => and_congr_right fun _ =>
    and_congr (hE v s) (forall_congr' fun r => imp_congr_right fun _ =>
      imp_congr_right fun _ => hG v r)

/-- Congruence for `untl` under pointwise `usTruth` equivalence of both arguments. -/
theorem usTruth_untl_congr {G G' E E' : USForm}
    (hG : ∀ (w : ℕ → ℤ → Prop) (r : ℤ), usTruth w r G ↔ usTruth w r G')
    (hE : ∀ (w : ℕ → ℤ → Prop) (r : ℤ), usTruth w r E ↔ usTruth w r E')
    (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.untl G E) ↔ usTruth v t (USForm.untl G' E') := by
  rw [usTruth_untl_iff, usTruth_untl_iff]
  exact exists_congr fun s => and_congr_right fun _ =>
    and_congr (hE v s) (forall_congr' fun r => imp_congr_right fun _ =>
      imp_congr_right fun _ => hG v r)

/-! ## Syntactic separatedness -/

/--
`ψ` is **syntactically separated**: no `untl` occurrence sits under a `snce` and no `snce`
occurrence under an `untl`. Equivalently, every temporal subformula at the top Boolean level is
pure — `untl` with `IsUOnly` arguments, `snce` with `IsSOnly` arguments.
-/
inductive IsSeparated : USForm → Prop
  /-- Every leaf is separated. -/
  | leaf (i : ℕ) : IsSeparated (.leaf i)
  /-- Bottom is separated. -/
  | bot : IsSeparated .bot
  /-- `imp` preserves separatedness, which carries `neg`, `and`, `or` and `iff` with it. -/
  | imp {φ ψ : USForm} : IsSeparated φ → IsSeparated ψ → IsSeparated (.imp φ ψ)
  /-- An `untl` is separated when both its arguments are `untl`-only. -/
  | untl {ψ φ : USForm} : IsUOnly ψ → IsUOnly φ → IsSeparated (USForm.untl ψ φ)
  /-- A `snce` is separated when both its arguments are `snce`-only. -/
  | snce {ψ φ : USForm} : IsSOnly ψ → IsSOnly φ → IsSeparated (USForm.snce ψ φ)

namespace IsSeparated

/-- A pure-past formula is separated. -/
theorem ofIsSOnly {φ : USForm} (h : IsSOnly φ) : IsSeparated φ := by
  induction h with
  | leaf i => exact IsSeparated.leaf i
  | bot => exact IsSeparated.bot
  | imp _ _ ihφ ihψ => exact IsSeparated.imp ihφ ihψ
  | snce hψ hφ _ _ => exact IsSeparated.snce hψ hφ

/-- A pure-future formula is separated. -/
theorem ofIsUOnly {φ : USForm} (h : IsUOnly φ) : IsSeparated φ := by
  induction h with
  | leaf i => exact IsSeparated.leaf i
  | bot => exact IsSeparated.bot
  | imp _ _ ihφ ihψ => exact IsSeparated.imp ihφ ihψ
  | untl hψ hφ _ _ => exact IsSeparated.untl hψ hφ

theorem neg {φ : USForm} (h : IsSeparated φ) : IsSeparated φ.neg :=
  IsSeparated.imp h IsSeparated.bot

theorem and {φ ψ : USForm} (hφ : IsSeparated φ) (hψ : IsSeparated ψ) :
    IsSeparated (φ.and ψ) :=
  (IsSeparated.imp hφ hψ.neg).neg

theorem or {φ ψ : USForm} (hφ : IsSeparated φ) (hψ : IsSeparated ψ) :
    IsSeparated (φ.or ψ) :=
  IsSeparated.imp hφ.neg hψ

end IsSeparated

/-! ## The `G`-under-`S` elimination -/

/--
**`S(a ∧ GX, q) ↔ X ∧ GX ∧ S(a, q ∧ X)`.** A universal future claim made at a past point `s`
splits at `t` into its `(s,t)` part, its value at `t`, and its `(t,∞)` part; the first two join
the guard and the third is the one pure-future conjunct. This is the auxiliary Case 2's first
summand needs, and it consumes no discreteness.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_snce_allFuture (a q X : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce q (a.and (USForm.allFuture X))) ↔
      usTruth v t (X.and ((USForm.allFuture X).and (USForm.snce (q.and X) a))) := by
  simp only [usTruth_and_iff, usTruth_snce_iff, usTruth_allFuture_iff]
  constructor
  · rintro ⟨s, hst, ⟨ha, hG⟩, hq⟩
    exact ⟨hG t hst, fun u htu => hG u (by omega),
      ⟨s, hst, ha, fun r h1 h2 => ⟨hq r h1 h2, hG r h1⟩⟩⟩
  · rintro ⟨hXt, hGt, ⟨s, hst, ha, hqX⟩⟩
    refine ⟨s, hst, ⟨ha, fun u hsu => ?_⟩, fun r h1 h2 => (hqX r h1 h2).1⟩
    rcases lt_trichotomy u t with h | h | h
    · exact (hqX u hsu h).2
    · exact h ▸ hXt
    · exact hGt u h

/-! ## The four separated right-hand sides -/

/--
Case 1's separated right-hand side. The three disjuncts are the three positions of the `untl`
witness `u` relative to `t`: strictly before it (a nested `snce`), at it (`A` read off `t`), and
strictly after it (the `U(A,B)` conjunct, the only pure-future part).
-/
def case1Rhs (a q A B : USForm) : USForm :=
  (USForm.snce q (A.and (q.and (USForm.snce (B.and q) a)))).or
    ((A.and (USForm.snce (q.and B) a)).or
      (B.and ((USForm.untl B A).and (USForm.snce (q.and B) a))))

/-- Case 2's separated right-hand side: the `G`-eliminated summand, plus Case 1's right-hand
side at the parameters GHR 10.2.2 produces. -/
def case2Rhs (a q A B : USForm) : USForm :=
  (A.neg.and ((USForm.allFuture A.neg).and (USForm.snce (q.and A.neg) a))).or
    (case1Rhs a q (A.neg.and B.neg) A.neg)

/-- Case 3's separated right-hand side: the negation of `H¬a ∨ (Case 2's right-hand side at the
negated parameters)`. -/
def case3Rhs (a q A B : USForm) : USForm :=
  ((USForm.allPast a.neg).or (case2Rhs (a.neg.and q.neg) a.neg A B)).neg

/-- Case 4's separated right-hand side: the negation of `H¬a ∨ (Case 1's right-hand side at the
negated parameters)`. -/
def case4Rhs (a q A B : USForm) : USForm :=
  ((USForm.allPast a.neg).or (case1Rhs (a.neg.and q.neg) a.neg A B)).neg

/-! ## Case 1 -/

/--
**GHR 10.2.3, Case 1**: `S(a ∧ U(A,B), q)` is separated.

Proved directly, by the trichotomy of the `untl` witness `u` against `t`. The `u < t` branch
re-anchors the outer `S` at `u`, whose guard then carries `q` and whose event carries
`A ∧ q ∧ S(a, B ∧ q)`; the `u = t` branch reads `A` off `t`; the `u > t` branch splits the
`B`-guard of `(s,u)` at `t`, leaving `B ∧ U(A,B)` at `t` beside the pure-past `S(a, q ∧ B)`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case1 (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce q (a.and (USForm.untl B A))) ↔
      usTruth v t (case1Rhs a q A B) := by
  simp only [case1Rhs, usTruth_or_iff, usTruth_and_iff, usTruth_snce_iff, usTruth_untl_iff]
  constructor
  · rintro ⟨s, hst, ⟨ha, u, hsu, hA, hB⟩, hq⟩
    rcases lt_trichotomy u t with h | h | h
    · exact Or.inl ⟨u, h, ⟨hA, hq u hsu h, s, hsu, ha,
        fun y hy1 hy2 => ⟨hB y hy1 hy2, hq y hy1 (by omega)⟩⟩,
        fun r hr1 hr2 => hq r (by omega) hr2⟩
    · exact Or.inr (Or.inl ⟨h ▸ hA, s, hst, ha,
        fun y hy1 hy2 => ⟨hq y hy1 hy2, hB y hy1 (by omega)⟩⟩)
    · exact Or.inr (Or.inr ⟨hB t hst h, ⟨u, h, hA, fun y hy1 hy2 => hB y (by omega) hy2⟩,
        s, hst, ha, fun y hy1 hy2 => ⟨hq y hy1 hy2, hB y hy1 (by omega)⟩⟩)
  · rintro (⟨u, hut, ⟨hA, hqu, s, hsu, ha, hBq⟩, hq⟩ |
      ⟨hAt, s, hst, ha, hqB⟩ | ⟨hBt, ⟨u, htu, hA, hB⟩, s, hst, ha, hqB⟩)
    · refine ⟨s, by omega, ⟨ha, u, hsu, hA, fun y hy1 hy2 => (hBq y hy1 hy2).1⟩,
        fun r hr1 hr2 => ?_⟩
      rcases lt_trichotomy r u with h | h | h
      · exact (hBq r hr1 h).2
      · exact h ▸ hqu
      · exact hq r h hr2
    · exact ⟨s, hst, ⟨ha, t, hst, hAt, fun y hy1 hy2 => (hqB y hy1 hy2).2⟩,
        fun r hr1 hr2 => (hqB r hr1 hr2).1⟩
    · refine ⟨s, hst, ⟨ha, u, by omega, hA, fun y hy1 hy2 => ?_⟩,
        fun r hr1 hr2 => (hqB r hr1 hr2).1⟩
      rcases lt_trichotomy y t with h | h | h
      · exact (hqB y hy1 h).2
      · exact h ▸ hBt
      · exact hB y h hy2

/-! ## Case 2 -/

/--
**GHR 10.2.3, Case 2**: `S(a ∧ ¬U(A,B), q)` is separated.

The reduction: `usTruth_neg_untl` (GHR 10.2.2) rewrites the event's `¬U(A,B)` as
`G¬A ∨ U(¬A ∧ ¬B, ¬A)`; the event-disjunction distributivity `usTruth_snce_or_event`
(GHR 10.2.1) splits the `S`; `usTruth_snce_allFuture` finishes the `G¬A` summand and
`usTruth_case1` the other, at the parameters `A := ¬A ∧ ¬B`, `B := ¬A`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case2 (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce q (a.and (USForm.untl B A).neg)) ↔
      usTruth v t (case2Rhs a q A B) := by
  have hstep : usTruth v t (USForm.snce q (a.and (USForm.untl B A).neg)) ↔
      usTruth v t (USForm.snce q
        ((a.and (USForm.allFuture A.neg)).or
          (a.and (USForm.untl A.neg (A.neg.and B.neg))))) := by
    refine usTruth_snce_congr (fun _ _ => Iff.rfl) (fun w r => ?_) v t
    rw [usTruth_and_iff, usTruth_neg_untl A B w r]
    simp only [usTruth_or_iff, usTruth_and_iff]
    tauto
  rw [hstep, usTruth_snce_or_event, case2Rhs, usTruth_or_iff, usTruth_or_iff,
    usTruth_snce_allFuture, usTruth_case1]

/-! ## Cases 3 and 4 -/

/--
**GHR 10.2.3, Case 3**: `S(a, q ∨ U(A,B))` is separated.

The reduction goes through the *negation*: `usTruth_neg_snce` (GHR 10.2.2's mirror) rewrites
`¬S(a, q ∨ U(A,B))` as `H¬a ∨ S(¬a ∧ ¬q ∧ ¬U(A,B), ¬a)`, whose second disjunct is Case 2's
shape at `a := ¬a ∧ ¬q`, `q := ¬a`. The right-hand side is therefore the negation of a separated
formula, which is separated.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case3 (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce (q.or (USForm.untl B A)) a) ↔
      usTruth v t (case3Rhs a q A B) := by
  have hneg := usTruth_neg_snce a (q.or (USForm.untl B A)) v t
  have hev : usTruth v t (USForm.snce a.neg (a.neg.and (q.or (USForm.untl B A)).neg)) ↔
      usTruth v t (case2Rhs (a.neg.and q.neg) a.neg A B) := by
    refine Iff.trans (usTruth_snce_congr (G' := a.neg)
      (E' := (a.neg.and q.neg).and (USForm.untl B A).neg)
      (fun _ _ => Iff.rfl) (fun w r => ?_) v t) (usTruth_case2 _ _ A B v t)
    simp only [usTruth_and_iff, usTruth_or_iff, usTruth_neg_iff]
    tauto
  rw [case3Rhs, usTruth_neg_iff, usTruth_or_iff, ← hev]
  rw [usTruth_neg_iff, usTruth_or_iff] at hneg
  exact not_not.symm.trans (not_congr hneg)

/--
**GHR 10.2.3, Case 4**: `S(a, q ∨ ¬U(A,B))` is separated.

The same move as Case 3, landing on Case 1's shape instead: the guard's `¬U(A,B)` becomes
`¬¬U(A,B)`, i.e. `U(A,B)`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case4 (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce (q.or (USForm.untl B A).neg) a) ↔
      usTruth v t (case4Rhs a q A B) := by
  have hneg := usTruth_neg_snce a (q.or (USForm.untl B A).neg) v t
  have hev : usTruth v t (USForm.snce a.neg (a.neg.and (q.or (USForm.untl B A).neg).neg)) ↔
      usTruth v t (case1Rhs (a.neg.and q.neg) a.neg A B) := by
    refine Iff.trans (usTruth_snce_congr (G' := a.neg)
      (E' := (a.neg.and q.neg).and (USForm.untl B A))
      (fun _ _ => Iff.rfl) (fun w r => ?_) v t) (usTruth_case1 _ _ A B v t)
    simp only [usTruth_and_iff, usTruth_or_iff, usTruth_neg_iff]
    tauto
  rw [case4Rhs, usTruth_neg_iff, usTruth_or_iff, ← hev]
  rw [usTruth_neg_iff, usTruth_or_iff] at hneg
  exact not_not.symm.trans (not_congr hneg)

/-! ## Separatedness of the four right-hand sides

Each is discharged as a theorem from `IsSOnly`/`IsUOnly` side conditions on the four
parameters, never asserted in prose. In the intended application (GHR 10.2.4) the parameters are
`untl`/`snce`-free, so both side conditions hold of all four. -/

/-- Case 1's right-hand side is syntactically separated whenever the four parameters are.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSeparated_case1Rhs {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A) (hBu : IsUOnly B) :
    IsSeparated (case1Rhs a q A B) := by
  refine IsSeparated.or (IsSeparated.ofIsSOnly (IsSOnly.snce hq
    (hAs.and (hq.and (IsSOnly.snce (hBs.and hq) ha))))) (IsSeparated.or ?_ ?_)
  · exact IsSeparated.ofIsSOnly (hAs.and (IsSOnly.snce (hq.and hBs) ha))
  · exact IsSeparated.and (IsSeparated.ofIsSOnly hBs)
      (IsSeparated.and (IsSeparated.untl hBu hAu)
        (IsSeparated.ofIsSOnly (IsSOnly.snce (hq.and hBs) ha)))

/-- Case 2's right-hand side is syntactically separated whenever the four parameters are.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSeparated_case2Rhs {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A) (hBu : IsUOnly B) :
    IsSeparated (case2Rhs a q A B) := by
  refine IsSeparated.or (IsSeparated.and (IsSeparated.ofIsSOnly hAs.neg)
    (IsSeparated.and (IsSeparated.ofIsUOnly hAu.neg.allFuture)
      (IsSeparated.ofIsSOnly (IsSOnly.snce (hq.and hAs.neg) ha)))) ?_
  exact isSeparated_case1Rhs ha hq (hAs.neg.and hBs.neg) hAs.neg
    (hAu.neg.and hBu.neg) hAu.neg

/-- Case 3's right-hand side is syntactically separated whenever the four parameters are.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSeparated_case3Rhs {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A) (hBu : IsUOnly B) :
    IsSeparated (case3Rhs a q A B) :=
  (IsSeparated.or (IsSeparated.ofIsSOnly ha.neg.allPast)
    (isSeparated_case2Rhs (ha.neg.and hq.neg) ha.neg hAs hBs hAu hBu)).neg

/-- Case 4's right-hand side is syntactically separated whenever the four parameters are.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSeparated_case4Rhs {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A) (hBu : IsUOnly B) :
    IsSeparated (case4Rhs a q A B) :=
  (IsSeparated.or (IsSeparated.ofIsSOnly ha.neg.allPast)
    (isSeparated_case1Rhs (ha.neg.and hq.neg) ha.neg hAs hBs hAu hBu)).neg

/-! ## The printed-form siblings of Cases 2 and 3

GHR's printed Case 2 has a **third** step the landed `usTruth_case2` omits: "using lemma 10.2.2
again (in reverse)", which folds `G¬A ∨ U(¬A ∧ ¬B, ¬A)` back into `¬U(A,B)`. The landed form is
correct and is kept unchanged; what it costs is that `case2Rhs` carries the two extra `untl`
types `untl A.neg (A.neg.and B.neg)` and `untl USForm.top A.neg.neg`, so no downstream induction
that counts `untl` **types** can be run over it.

The siblings below are the printed forms. Their only `untl` occurrence is `untl B A`, so they
are `IsUTyped A B` (witnesses in `NormalForm.lean`), and each is a drop-in replacement for its
landed counterpart at the same six-hypothesis separatedness shape. The fold is `usTruth_neg_untl`
used in the `←` direction; no new semantic argument, module or import is needed.

**Term order**: GHR's `S(a, q)` is `USForm.snce q a` — guard first, event second. Every
quotation below is in GHR's notation; every Lean term is in `snce guard event` order. -/

/--
**GHR 10.2.3, Case 2's printed right-hand side.** Verbatim from
`gabbay_1994/ch1001_chapter-10-expressive-completeness-of-si.md`, Lemma 10.2.3, Case 2:

```
[S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A, B)]
∨ [¬A ∧ ¬B ∧ S(a, ¬A ∧ q)]
∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q).
```

Its only `untl` occurrence is the `¬U(A,B)` of the first disjunct, which is exactly `untl B A`.
`case2Rhs` and `usTruth_case2` are retained unchanged beside this; neither is weakened.
-/
def case2RhsPrinted (a q A B : USForm) : USForm :=
  ((USForm.snce (q.and A.neg) a).and (A.neg.and (USForm.untl B A).neg)).or
    ((A.neg.and (B.neg.and (USForm.snce (A.neg.and q) a))).or
      (USForm.snce q (((A.neg.and B.neg).and q).and (USForm.snce (A.neg.and q) a))))

/--
**GHR 10.2.3, Case 2 at the printed right-hand side**: `S(a ∧ ¬U(A,B), q)` is equivalent to
`case2RhsPrinted a q A B`.

Not a second semantic derivation of Case 2. The landed `usTruth_case2` supplies the equivalence;
`usTruth_neg_untl` (GHR 10.2.2) supplies the fold GHR's printed Case 2 performs in its third step
and the landed proof omits, used here in the `←` direction. The remaining work is Boolean: the
printed first disjunct `S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A,B)` splits under the fold into exactly
`case2Rhs`'s `G¬A` summand and its `U(¬A ∧ ¬B, ¬A)` disjunct, and the printed second and third
disjuncts are `case1Rhs`'s middle and first disjuncts up to associativity and the commutation of
`q ∧ ¬A`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case2_printed (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce q (a.and (USForm.untl B A).neg)) ↔
      usTruth v t (case2RhsPrinted a q A B) := by
  have hsw : ∀ (w : ℕ → ℤ → Prop) (r : ℤ),
      usTruth w r (USForm.snce (q.and A.neg) a) ↔
        usTruth w r (USForm.snce (A.neg.and q) a) := fun w r =>
    usTruth_snce_congr (fun w' r' => by simp only [usTruth_and_iff]; tauto)
      (fun _ _ => Iff.rfl) w r
  have hP3 : usTruth v t (USForm.snce q
        (((A.neg.and B.neg).and q).and (USForm.snce (A.neg.and q) a))) ↔
      usTruth v t (USForm.snce q
        ((A.neg.and B.neg).and (q.and (USForm.snce (A.neg.and q) a)))) :=
    usTruth_snce_congr (fun _ _ => Iff.rfl)
      (fun w r => by simp only [usTruth_and_iff]; tauto) v t
  have hfold : usTruth v t (USForm.untl B A).neg ↔
      (usTruth v t (USForm.allFuture A.neg) ∨
        usTruth v t (USForm.untl A.neg (A.neg.and B.neg))) :=
    (usTruth_neg_untl A B v t).trans (usTruth_or_iff v t _ _)
  rw [usTruth_case2 a q A B v t, case2Rhs, case2RhsPrinted, case1Rhs]
  simp only [usTruth_or_iff, usTruth_and_iff, hsw v t, hP3, hfold]
  tauto

/-- Case 2's printed right-hand side is syntactically separated whenever the four parameters are.
A drop-in for `isSeparated_case2Rhs` at the same six-hypothesis shape.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSeparated_case2RhsPrinted {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A) (hBu : IsUOnly B) :
    IsSeparated (case2RhsPrinted a q A B) :=
  IsSeparated.or
    (IsSeparated.and (IsSeparated.ofIsSOnly (IsSOnly.snce (hq.and hAs.neg) ha))
      (IsSeparated.and (IsSeparated.ofIsSOnly hAs.neg) (IsSeparated.untl hBu hAu).neg))
    (IsSeparated.or
      (IsSeparated.and (IsSeparated.ofIsSOnly hAs.neg)
        (IsSeparated.and (IsSeparated.ofIsSOnly hBs.neg)
          (IsSeparated.ofIsSOnly (IsSOnly.snce (hAs.neg.and hq) ha))))
      (IsSeparated.ofIsSOnly (IsSOnly.snce hq
        (((hAs.neg.and hBs.neg).and hq).and (IsSOnly.snce (hAs.neg.and hq) ha)))))

/-- Case 3's printed-form right-hand side: `case3Rhs` with its one `case2Rhs` slot taken at
`case2RhsPrinted`. The substituted position sits under `or` and `neg` only. -/
def case3RhsPrinted (a q A B : USForm) : USForm :=
  ((USForm.allPast a.neg).or (case2RhsPrinted (a.neg.and q.neg) a.neg A B)).neg

/--
**GHR 10.2.3, Case 3 at the printed right-hand side.** Boolean congruence from
`usTruth_case2_printed` at the parameters `a := ¬a ∧ ¬q`, `q := ¬a`, not a re-derivation of
Case 3: the substituted position sits under `or` and `neg` only.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_case3_printed (a q A B : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce (q.or (USForm.untl B A)) a) ↔
      usTruth v t (case3RhsPrinted a q A B) := by
  have hc : usTruth v t (case2Rhs (a.neg.and q.neg) a.neg A B) ↔
      usTruth v t (case2RhsPrinted (a.neg.and q.neg) a.neg A B) :=
    (usTruth_case2 (a.neg.and q.neg) a.neg A B v t).symm.trans
      (usTruth_case2_printed (a.neg.and q.neg) a.neg A B v t)
  rw [usTruth_case3 a q A B v t, case3Rhs, case3RhsPrinted]
  simp only [usTruth_neg_iff, usTruth_or_iff, hc]

/-- Case 3's printed right-hand side is syntactically separated whenever the four parameters are.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isSeparated_case3RhsPrinted {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A) (hBu : IsUOnly B) :
    IsSeparated (case3RhsPrinted a q A B) :=
  (IsSeparated.or (IsSeparated.ofIsSOnly ha.neg.allPast)
    (isSeparated_case2RhsPrinted (ha.neg.and hq.neg) ha.neg hAs hBs hAu hBu)).neg

end FormalSystem.Metalogic.Expressiveness.SeparationZ
