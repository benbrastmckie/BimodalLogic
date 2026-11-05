/-
PROTOTYPE — Phase 5 decision gate for task 867.

NOT part of the FormalSystem build graph. Compile with:
  bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean \
    specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean

PURPOSE. GHR Lemma 10.2.3's Cases 5-8 eliminate an `untl` from under a `snce` when BOTH the
event and the guard argument carry the same `untl B A`, positively or negatively. The printed
Case 5 formula is refuted over integer time (see reports/01, "GHR's printed Case 5 formula is
refuted over integer time"), and Cases 6-8 are published only as reductions with acknowledged
gaps. This file re-derives candidates from the semantics and probes them on concrete `ℤ` leaf
valuations before any proof is attempted in the library.

LEAF INDICES. 0 = a, 1 = q, 2 = A, 3 = B.  Guard-first order throughout: GHR's `U(A,B)` is
`untl B A`, GHR's `S(E,G)` is `snce G E`.
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Syntax

namespace Probe867

open FormalSystem.Metalogic.Expressiveness.SeparationZ
open FormalSystem.Metalogic.Expressiveness.SeparationZ.USForm

/-! ## The abbreviations the candidates are written in -/

/-- Leaf `a` (GHR's untl-free event parameter). -/
abbrev a : USForm := .leaf 0
/-- Leaf `q` (GHR's untl-free guard parameter). -/
abbrev q : USForm := .leaf 1
/-- Leaf `A` (the event of the `untl` being eliminated). -/
abbrev A : USForm := .leaf 2
/-- Leaf `B` (the guard of the `untl` being eliminated). -/
abbrev B : USForm := .leaf 3

/-- `U(A,B)` in guard-first order. -/
abbrev Uf : USForm := USForm.untl B A
/-- `K := ¬A ∧ ¬B` — the "dead point" predicate the re-anchoring runs on. -/
abbrev Kf : USForm := A.neg.and B.neg
/-- `¬K`, written positively as `A ∨ B`. -/
abbrev nK : USForm := A.or B
/-- `¬A ∧ B`. -/
abbrev NAB : USForm := A.neg.and B
/-- `S(¬q, ¬A ∧ B)`. -/
abbrev Sqn : USForm := USForm.snce NAB q.neg
/-- `N := K ∧ S(¬q, ¬A ∧ B)` — the re-anchored "bad guard point" marker. -/
abbrev Nf : USForm := Kf.and Sqn
/-- `S(¬K, A ∧ S(¬K, a))` — the inner pure-past witness chain. -/
abbrev Inner : USForm := USForm.snce nK (A.and (USForm.snce nK a))
/-- `K ∧ ¬S(¬q,¬A∧B) ∧ Inner` — the event of the re-anchored outer `S`. -/
abbrev Ev : USForm := Kf.and (Sqn.neg.and Inner)

/-! ### Shape helpers for the two compound leaves -/

theorem usTruth_Kf_iff (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t Kf ↔ ¬ usTruth v t A ∧ ¬ usTruth v t B := by
  rw [show Kf = A.neg.and B.neg from rfl, usTruth_and_iff, usTruth_neg_iff, usTruth_neg_iff]

theorem usTruth_nK_iff (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t nK ↔ usTruth v t A ∨ usTruth v t B :=
  usTruth_or_iff v t A B

/--
`P` — the pure-past core of the Case 5 candidate: the re-anchored form of
`∃s<t: a(s) ∧ ¬bad*(s) ∧ (no N-point in (s,t])`, where
`bad*(r) := ∃x ∈ (r,t]: K(x) ∧ (¬A ∧ B) on (r,x)`.
-/
abbrev P : USForm :=
  (nK.and (USForm.snce nK a)).or (Ev.or (Nf.neg.and (USForm.snce Nf.neg Ev)))

/-- GHR 10.2.3 Case 5's left-hand side: `S(a ∧ U(A,B), q ∨ U(A,B))`. -/
abbrev case5LHS : USForm := USForm.snce (q.or Uf) (a.and Uf)

/--
**The pinned Case 5 candidate.**

```
   P ∧ (U(A,B) ∨ A ∨ ¬B)
 ∨ (¬U(A,B) ∧ ¬A ∧ B ∧ S(q ∧ ¬A ∧ B, (A ∨ ¬B) ∧ q ∧ P))
```

Derivation (NOT a transcription of the printed formula). Write `bad*(r)` for
`∃x ∈ (r,t]: K(x) ∧ (¬A ∧ B) on (r,x)` and `C(r)` for `(¬A ∧ B) on (r,t]`. Then for `r < t`:

* `U(A,B)@r ↔ Q(r) ∨ (Bint(r) ∧ U(A,B)@t)` where `Q(r) := ∃u ∈ (r,t]: A(u) ∧ B on (r,u)` and
  `Bint(r) := B on (r,t]`;
* with `U(A,B)@t`: `U(A,B)@r ↔ ¬bad*(r)`;
* with `¬U(A,B)@t`: `U(A,B)@r ↔ ¬bad*(r) ∧ ¬C(r)`.

Splitting on `U(A,B)@t` (a pure-future formula) and re-anchoring the guard-failure condition at
its own rightmost witness collapses the `U(A,B)@t` branch to `U(A,B)@t ∧ P`: the branch in which
the greatest `N`-point of `(s,t]` exists is **impossible**, because `q` on `(s,x_g)` forces
`S(¬q, ¬A∧B)@x_g`'s witness to lie at or below `s`, which hands `bad*(s)` the witness `x_g` and
contradicts the event. The `¬U(A,B)@t` branch splits on `A(t) ∨ ¬B(t)` (where `C` is identically
false, giving the same `P`) against `¬A(t) ∧ B(t)` (where the greatest `(A ∨ ¬B)`-point of
`(s,t)` becomes the outer witness, giving the second disjunct).
-/
abbrev case5RHS : USForm :=
  (P.and (Uf.or (A.or B.neg))).or
    (Uf.neg.and (A.neg.and (B.and
      (USForm.snce (q.and NAB) ((A.or B.neg).and (q.and P))))))

/-! ## Probe model 1 — the refuting model of `reports/01`

`a(0)`, `A(1)`, `B` identically false, `q(1)` and `q(2)`; everything else false; evaluated at
`t = 3`. The printed Case 5 formula is **false** here while the left-hand side is **true**, which
is the published defect. A surviving candidate must be **true** at `t = 3`. -/

/-- The refuting model: `a(0)`, `q ∈ {1,2}`, `A(1)`, `B ≡ ⊥`. -/
def v₀ : ℕ → ℤ → Prop
  | 0 => fun x => x = 0
  | 1 => fun x => x = 1 ∨ x = 2
  | 2 => fun x => x = 1
  | _ => fun _ => False

theorem v₀_a_iff (x : ℤ) : usTruth v₀ x a ↔ x = 0 := Iff.rfl

theorem v₀_q_iff (x : ℤ) : usTruth v₀ x q ↔ (x = 1 ∨ x = 2) := Iff.rfl

theorem v₀_A_iff (x : ℤ) : usTruth v₀ x A ↔ x = 1 := Iff.rfl

theorem v₀_B (x : ℤ) : ¬ usTruth v₀ x B := fun h => h

/-- `U(A,B)` is false at every point of model 1 except those strictly below the single
`A`-point, where the adjacency degeneracy makes the guard vacuous. -/
theorem v₀_Uf_iff (t : ℤ) : usTruth v₀ t Uf ↔ t < 1 ∧ (∀ r : ℤ, t < r → r < 1 → False) := by
  rw [usTruth_untl_iff]
  constructor
  · rintro ⟨u, htu, hA, hg⟩
    have hu : u = 1 := hA
    subst hu
    exact ⟨htu, fun r h1 h2 => v₀_B r (hg r h1 h2)⟩
  · rintro ⟨h1, hg⟩
    exact ⟨1, h1, rfl, fun r hr1 hr2 => absurd (hg r hr1 hr2) not_false⟩

theorem v₀_Uf_0 : usTruth v₀ 0 Uf := by
  rw [v₀_Uf_iff]; exact ⟨by omega, fun r h1 h2 => by omega⟩

theorem v₀_not_Uf_1 : ¬ usTruth v₀ 1 Uf := by
  rw [v₀_Uf_iff]; rintro ⟨h, _⟩; omega

theorem v₀_not_Uf_3 : ¬ usTruth v₀ 3 Uf := by
  rw [v₀_Uf_iff]; rintro ⟨h, _⟩; omega

/-- `S(¬q, ¬A ∧ B)` is, on a model with `B ≡ ⊥`, exactly `¬q` one step back: a guard over an
empty open interval is vacuous, so only the adjacent witness survives. -/
theorem v₀_Sqn_iff (t : ℤ) : usTruth v₀ t Sqn ↔ ¬ usTruth v₀ (t - 1) q := by
  rw [usTruth_snce_iff]
  constructor
  · rintro ⟨s, hst, hev, hg⟩
    rcases lt_or_eq_of_le (show s ≤ t - 1 by omega) with h | h
    · exact absurd ((usTruth_and_iff v₀ (t-1) A.neg B).mp (hg (t-1) h (by omega))).2 (v₀_B _)
    · exact h ▸ hev
  · intro h
    exact ⟨t - 1, by omega, h, fun r h1 h2 => absurd h2 (by omega)⟩

theorem v₀_not_Sqn_2 : ¬ usTruth v₀ 2 Sqn := by
  rw [v₀_Sqn_iff]
  intro h
  exact h ((v₀_q_iff (2 - 1)).mpr (by omega))

theorem v₀_not_Sqn_3 : ¬ usTruth v₀ 3 Sqn := by
  rw [v₀_Sqn_iff]
  intro h
  exact h ((v₀_q_iff (3 - 1)).mpr (by omega))

theorem v₀_not_A_2 : ¬ usTruth v₀ 2 A := by rw [v₀_A_iff]; omega

theorem v₀_not_A_3 : ¬ usTruth v₀ 3 A := by rw [v₀_A_iff]; omega

/-- **Probe 1a**: the left-hand side of Case 5 is TRUE at `t = 3` on the refuting model. -/
theorem probe1_LHS : usTruth v₀ 3 case5LHS := by
  rw [usTruth_snce_iff]
  refine ⟨0, by omega,
    (usTruth_and_iff v₀ 0 a Uf).mpr ⟨(v₀_a_iff 0).mpr rfl, v₀_Uf_0⟩, fun r h1 h2 => ?_⟩
  exact (usTruth_or_iff v₀ r q Uf).mpr (Or.inl ((v₀_q_iff r).mpr (by omega)))

/-- **Probe 1b**: the pinned candidate is also TRUE at `t = 3` on the refuting model, so it
survives the counterexample that refutes the printed formula. -/
theorem probe1_RHS : usTruth v₀ 3 case5RHS := by
  refine (usTruth_or_iff v₀ 3 _ _).mpr (Or.inl ((usTruth_and_iff v₀ 3 P _).mpr ⟨?_, ?_⟩))
  · -- `P` holds at 3 through its third disjunct, with the re-anchored witness `x = 2`.
    refine (usTruth_or_iff v₀ 3 _ _).mpr (Or.inr ((usTruth_or_iff v₀ 3 Ev _).mpr (Or.inr ?_)))
    refine (usTruth_and_iff v₀ 3 Nf.neg _).mpr ⟨?_, ?_⟩
    · exact fun h => v₀_not_Sqn_3 ((usTruth_and_iff v₀ 3 _ Sqn).mp h).2
    · rw [usTruth_snce_iff]
      refine ⟨2, by omega, ?_, fun r h1 h2 => absurd h2 (by omega)⟩
      refine (usTruth_and_iff v₀ 2 _ _).mpr
        ⟨(usTruth_Kf_iff v₀ 2).mpr ⟨v₀_not_A_2, v₀_B 2⟩, ?_⟩
      refine (usTruth_and_iff v₀ 2 Sqn.neg Inner).mpr ⟨v₀_not_Sqn_2, ?_⟩
      rw [usTruth_snce_iff]
      refine ⟨1, by omega, ?_, fun r h1 h2 => absurd h2 (by omega)⟩
      refine (usTruth_and_iff v₀ 1 A _).mpr ⟨(v₀_A_iff 1).mpr rfl, ?_⟩
      rw [usTruth_snce_iff]
      exact ⟨0, by omega, (v₀_a_iff 0).mpr rfl, fun r h1 h2 => absurd h2 (by omega)⟩
  · -- `U(A,B) ∨ A ∨ ¬B` holds at 3 through `¬B`.
    exact (usTruth_or_iff v₀ 3 Uf _).mpr (Or.inr
      ((usTruth_or_iff v₀ 3 A B.neg).mpr (Or.inr (v₀_B 3))))

/-! ## Probe model 2 — the adjacency degeneracy with a future `A`-witness

`a(-1)`, `A(5)`, `B` on `[-1,5]`, `q ≡ ⊥`; evaluated at `t = 0`. The outer `S`-guard is the
empty interval `(-1,0)`, which is the degeneracy that refuted the printed formula; the
`A`-witness lies strictly beyond `t`. Both sides must be TRUE. -/

/-- The adjacency model: `a(-1)`, `q ≡ ⊥`, `A(5)`, `B` on `[-1,5]`. -/
def v₁ : ℕ → ℤ → Prop
  | 0 => fun x => x = -1
  | 1 => fun _ => False
  | 2 => fun x => x = 5
  | _ => fun x => -1 ≤ x ∧ x ≤ 5

theorem v₁_a_iff (x : ℤ) : usTruth v₁ x a ↔ x = -1 := Iff.rfl

theorem v₁_A_iff (x : ℤ) : usTruth v₁ x A ↔ x = 5 := Iff.rfl

theorem v₁_B_iff (x : ℤ) : usTruth v₁ x B ↔ (-1 ≤ x ∧ x ≤ 5) := Iff.rfl

theorem v₁_Uf (t : ℤ) (ht : -1 ≤ t) (ht' : t < 5) : usTruth v₁ t Uf := by
  rw [usTruth_untl_iff]
  exact ⟨5, by omega, (v₁_A_iff 5).mpr rfl,
    fun r h1 h2 => (v₁_B_iff r).mpr ⟨by omega, by omega⟩⟩

/-- **Probe 2a**: the left-hand side is TRUE at `t = 0`, with the vacuous outer guard. -/
theorem probe2_LHS : usTruth v₁ 0 case5LHS := by
  rw [usTruth_snce_iff]
  exact ⟨-1, by omega,
    (usTruth_and_iff v₁ (-1) a Uf).mpr
      ⟨(v₁_a_iff (-1)).mpr rfl, v₁_Uf (-1) (by omega) (by omega)⟩,
    fun r h1 h2 => absurd h2 (by omega)⟩

/-- **Probe 2b**: the pinned candidate is TRUE at `t = 0`, through its first disjunct with
`U(A,B)` supplying the future conjunct and `¬K(0)` the first disjunct of `P`. -/
theorem probe2_RHS : usTruth v₁ 0 case5RHS := by
  refine (usTruth_or_iff v₁ 0 _ _).mpr (Or.inl ((usTruth_and_iff v₁ 0 P _).mpr ⟨?_, ?_⟩))
  · refine (usTruth_or_iff v₁ 0 _ _).mpr (Or.inl ((usTruth_and_iff v₁ 0 nK _).mpr ⟨?_, ?_⟩))
    · exact (usTruth_nK_iff v₁ 0).mpr (Or.inr ((v₁_B_iff 0).mpr ⟨by omega, by omega⟩))
    · rw [usTruth_snce_iff]
      exact ⟨-1, by omega, (v₁_a_iff (-1)).mpr rfl, fun r h1 h2 => absurd h2 (by omega)⟩
  · exact (usTruth_or_iff v₁ 0 Uf _).mpr (Or.inl (v₁_Uf 0 (by omega) (by omega)))

/-! ## Probe model 3 — the past `A`-witness with a failing guard

`a(0)`, `A(1)`, `B ≡ ⊥`, `q ≡ ⊥`; evaluated at `t = 3`. The `A`-witness lies strictly in the
past of `t`, and the guard fails at `r = 1`. Both sides must be FALSE — this is the probe that
would catch a candidate that is merely *implied by* the left-hand side. -/

/-- The past-witness model: `a(0)`, `q ≡ ⊥`, `A(1)`, `B ≡ ⊥`. -/
def v₂ : ℕ → ℤ → Prop
  | 0 => fun x => x = 0
  | 2 => fun x => x = 1
  | _ => fun _ => False

theorem v₂_a_iff (x : ℤ) : usTruth v₂ x a ↔ x = 0 := Iff.rfl

theorem v₂_A_iff (x : ℤ) : usTruth v₂ x A ↔ x = 1 := Iff.rfl

theorem v₂_B (x : ℤ) : ¬ usTruth v₂ x B := fun h => h

theorem v₂_q (x : ℤ) : ¬ usTruth v₂ x q := fun h => h

theorem v₂_not_A_2 : ¬ usTruth v₂ 2 A := by rw [v₂_A_iff]; omega

theorem v₂_not_A_3 : ¬ usTruth v₂ 3 A := by rw [v₂_A_iff]; omega

theorem v₂_Uf_iff (t : ℤ) : usTruth v₂ t Uf ↔ t < 1 ∧ (∀ r : ℤ, t < r → r < 1 → False) := by
  rw [usTruth_untl_iff]
  constructor
  · rintro ⟨u, htu, hA, hg⟩
    have hu : u = 1 := hA
    subst hu
    exact ⟨htu, fun r h1 h2 => v₂_B r (hg r h1 h2)⟩
  · rintro ⟨h1, hg⟩
    exact ⟨1, h1, (v₂_A_iff 1).mpr rfl, fun r hr1 hr2 => absurd (hg r hr1 hr2) not_false⟩

/-- **Probe 3a**: the left-hand side is FALSE at `t = 3`: the only `a`-point is `0`, and the
guard `q ∨ U(A,B)` fails at `r = 1`. -/
theorem probe3_LHS : ¬ usTruth v₂ 3 case5LHS := by
  rw [usTruth_snce_iff]
  rintro ⟨s, hs, hev, hg⟩
  have hs0 : s = 0 := (v₂_a_iff s).mp ((usTruth_and_iff v₂ s a Uf).mp hev).1
  subst hs0
  rcases (usTruth_or_iff v₂ 1 q Uf).mp (hg 1 (by omega) (by omega)) with h | h
  · exact v₂_q 1 h
  · exact absurd ((v₂_Uf_iff 1).mp h).1 (by omega)

/-- `S(¬q, ¬A ∧ B)` on model 3: again only the adjacent witness, and `¬q` holds everywhere, so
it holds at every point. -/
theorem v₂_Sqn (t : ℤ) : usTruth v₂ t Sqn := by
  rw [usTruth_snce_iff]
  exact ⟨t - 1, by omega, v₂_q (t-1), fun r h1 h2 => absurd h2 (by omega)⟩

/-- **Probe 3b**: the pinned candidate is FALSE at `t = 3`. The second disjunct needs `B(3)`,
which fails; the first needs `P`, whose every disjunct is blocked because `N(2)` holds. -/
theorem probe3_RHS : ¬ usTruth v₂ 3 case5RHS := by
  have hN3 : usTruth v₂ 3 Nf :=
    (usTruth_and_iff v₂ 3 Kf Sqn).mpr
      ⟨(usTruth_Kf_iff v₂ 3).mpr ⟨v₂_not_A_3, v₂_B 3⟩, v₂_Sqn 3⟩
  intro h
  rcases (usTruth_or_iff v₂ 3 _ _).mp h with h1 | h2
  · -- the first disjunct: `P` must hold at 3
    have hP := ((usTruth_and_iff v₂ 3 P _).mp h1).1
    rcases (usTruth_or_iff v₂ 3 _ _).mp hP with hd | hd
    · -- `¬K(3)` fails: `A(3)` and `B(3)` are both false
      exact ((usTruth_nK_iff v₂ 3).mp ((usTruth_and_iff v₂ 3 nK _).mp hd).1).elim
        (fun hA => v₂_not_A_3 hA) (fun hB => v₂_B 3 hB)
    · rcases (usTruth_or_iff v₂ 3 Ev _).mp hd with he | he
      · -- `Ev(3)` needs `¬S(¬q,¬A∧B)@3`, but it holds
        exact ((usTruth_and_iff v₂ 3 Sqn.neg Inner).mp
          ((usTruth_and_iff v₂ 3 Kf _).mp he).2).1 (v₂_Sqn 3)
      · -- the third disjunct needs `¬N(3)`, but `N(3)` holds
        exact ((usTruth_and_iff v₂ 3 Nf.neg _).mp he).1 hN3
  · -- the second disjunct needs `B(3)`
    exact v₂_B 3 ((usTruth_and_iff v₂ 3 B _).mp
      ((usTruth_and_iff v₂ 3 A.neg _).mp ((usTruth_and_iff v₂ 3 Uf.neg _).mp h2).2).2).1

/-! ## Gate measurement

**Case 5 — candidate pinned and surviving (3 of 3 probes).** `case5RHS` above. Probed on the
refuting model of `reports/01` (both sides TRUE at `t = 3`), on the adjacency-degeneracy model
with a future `A`-witness (both sides TRUE at `t = 0`), and on the past-`A`-witness model with a
failing guard (both sides FALSE at `t = 3`). Nothing here *proves* the equivalence; it records
that the candidate is not refuted by the models that refute the printed formula.

**Cases 6, 7, 8 — NO candidate pinned.** The derivation method that works for Case 5 is: split
on the pure-future `U(A,B)@t`; rewrite `U(A,B)@r` for `r < t` as `¬bad*(r)` (resp.
`¬bad*(r) ∧ ¬C(r)`); then re-anchor the guard-failure condition
`∃r ∈ (s,t): ¬q(r) ∧ ¬(guard disjunct at r)` at its own rightmost witness, so that the outer
`S`'s event sits at that witness and its guard becomes a point-local, pure-past condition.

For Case 5 that re-anchoring **collapses**: the branch in which a greatest `N`-point of `(s,t]`
exists is impossible, because `q` on `(s,x_g)` forces `S(¬q,¬A∧B)@x_g`'s own witness to lie at
or below `s`, which hands `bad*(s)` the witness `x_g` and contradicts the event conjunct
`U(A,B)@s`. That collapse is what keeps the candidate finite.

For the three cases whose **guard** carries `¬U(A,B)` (Cases 7 and 8) the guard-failure
condition is `∃r ∈ (s,t): ¬q(r) ∧ ¬bad*(r)`, and `¬bad*` is itself a *universal* over
`x ∈ (r,t]`. Re-anchoring an `∃∀` requires two nested witness choices (the `A`-point `y` and the
`K`-point `x > y`), and the resulting condition retains a genuinely `s`-bounded **forward**
conjunct — `∃r ∈ (s,y): ¬q(r)` under a further `∃x ∈ (y,t]: K(x)` — with no collapse analogous
to Case 5's. A forward-looking-but-`t`-bounded condition at `r` is not a formula at `r`, so it
cannot be an `S`-guard, and the re-anchoring does not terminate at a fixed finite formula.
Case 6, whose guard carries `+U(A,B)` and whose event carries `¬U(A,B)`, inherits the same
difficulty from its event conjunct `bad*(s)`, which is the `∃` whose negation was what made
Case 5's collapse available.

**VERDICT: 1 of 4 candidates survived (Case 5). Cases 6, 7 and 8: no candidate produced.**
The gate criterion is 4 of 4, so it is NOT met, and the primary contingency branch of the plan's
`## Rollback/Contingency` applies: Phase 7 and the phases downstream of it close as
`[COMPLETED WITH EXCLUSIONS]` citing this measurement, while Phases 1-6 and 14-15 land.

**Precisely located obstruction.** The eliminations that resist formalization are GHR 10.2.3
Cases 6, 7 and 8. The reason is not a tactic failure: it is that their guard-failure conditions
are `∃∀` over the window `(s,t]` whose re-anchoring leaves an `s`-bounded forward conjunct,
whereas Case 5's is an `∃∃` whose re-anchoring collapses. What would unblock them is either a
published correct form of Cases 6-8 over the integer flow (the source gives only reductions with
acknowledged gaps), or a different measure-carrying device that bounds the re-anchoring chain —
over `ℤ` each re-anchoring step crosses one `¬B` point, and the window `(s,t]` is finite, so a
*bounded* chain exists for every fixed model; what is missing is a single finite formula serving
every model.
-/

end Probe867
