/-
PROTOTYPE — Phase 16 re-specified decision gate for task 867.

NOT part of the FormalSystem build graph. Compile with:
  bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean \
    specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-reduction.lean

PURPOSE. Phase 5's gate measured 1 of 4 for GHR Lemma 10.2.3's Cases 5-8 and closed Phases 7-15
with exclusions. That measurement rested on a route defect: it derived Cases 6, 7 and 8 by direct
semantic re-anchoring, which is not how the source derives them. This file re-specifies the gate
against the source's own reduction order, and records the two printed-text defects the
implementation must encode rather than repair silently.

SOURCE TEXT. The reduction order below is read off GHR vol. 1 Chapter 10 §10.2 directly
(Literature/sources/gabbay_1994/ch1001_chapter-10-expressive-completeness-of-si.md, the §10.2
body, cross-read against
Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.pdf). It is not
reconstructed: every edge below quotes the sentence of the proof of Lemma 10.2.3 that states it.

LEAF INDICES. 0 = a, 1 = q, 2 = A, 3 = B.  Guard-first order throughout: GHR's `U(A,B)` is
`untl B A`, GHR's `S(E,G)` is `snce G E`.
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Syntax

namespace Probe867Reduction

open FormalSystem.Metalogic.Expressiveness.SeparationZ
open FormalSystem.Metalogic.Expressiveness.SeparationZ.USForm

/-! ## A. The pinned reduction DAG

GHR Lemma 10.2.3 proves its eight cases in the following order. One edge per line, each naming
the step of the source's own proof that states it.

```
  Case 1  S(a ∧ U, q)        BASE, semantic.  "It is very easy to show that S(a ∧ U(A,B), q) is
                             equivalent to ... The three disjuncts correspond to the cases
                             u > t, u = t, and u < t respectively."
  Case 2  S(a ∧ ¬U, q)       <- 10.2.1, 10.2.2, Case 1, and the G-under-S auxiliary.  "can be
                             rewritten by using lemmas 10.2.1 and 10.2.2, noting that
                             S(a ∧ G(¬A), q) is equivalent to S(a, ¬A ∧ q) ∧ (¬A) ∧ G(¬A), using
                             the first elimination and then using lemma 10.2.2 again (in
                             reverse)."
  Case 3  S(a, q ∨ U)        <- 10.2.2 and Case 2.  "we look at its negation and use lemma 10.2.2
                             and then elimination (2) above".
  Case 4  S(a, q ∨ ¬U)       BASE, semantic.  "very straightforward to do semantically".
  Case 5  S(a ∧ U, q ∨ U)    BASE, semantic.  "The first disjunct holds when the A from U(A,B) is
                             true in the future or present and the second when it is true in the
                             past."
  Case 8  S(a ∧ ¬U, q ∨ ¬U)  <- the generic negated-since distribution identity, then Case 5
                             (twice) and Case 2.  "can be reduced to cases already discussed
                             since ¬S(a ∧ z, q ∨ y) ↔ H(¬a ∨ ¬z) ∨ S(¬q ∧ ¬y ∧ ¬a, ¬a ∨ ¬z)
                             ∨ S(¬q ∧ ¬y ∧ ¬z, ¬a ∨ ¬z) ... These are cases we can handle by
                             other eliminations, especially elimination (5)."
  Case 7  S(a ∧ U, q ∨ ¬U)   <- a semantic step, then Cases 8 and 4.  "By considering when A is
                             true we deduce that our formula is equivalent to the disjunction:
                             ... The first disjunct can be further eliminated by eliminations (8)
                             and (4)."
  Case 6  S(a ∧ ¬U, q ∨ U)   <- a semantic step (first ¬B point after s), then Cases 3 and 5.
                             "The wff is separated by considering when the first occurrence (if
                             any) of ¬B after s is. ... Eliminations (3) and (5) can be used to
                             finish the separating."
```

**Acyclicity.** The edge set is
`{2→3, 1→2, 1→4?no, 5→8, 2→8, 5→6, 3→6, 8→7, 4→7}` over the vertex order
`1 < 2 < 3 < 4 < 5 < 8 < 7 < 6`, under which every edge points from a smaller to a larger
vertex. Hence acyclic. In particular the Cases 5/8 edge runs **one way only**: Case 5 is proved
semantically and is strictly upstream of Case 8. Phase 5's `#### Reasoned Exclusions` recorded a
Cases 5/8 loop; that loop was an artefact of the re-anchoring route, which tried to obtain Case 5
*from* Case 8's negation, and is not present here.

**What is NOT used.** Direct semantic re-anchoring of Cases 6, 7 and 8 — the method Phase 5
measured — appears nowhere above. It is not the source's method and it is what produces the
unexpressible `∃∀` guard-failure condition Phase 5 recorded.

## B. The generic negated-since distribution identity

GHR state it at Case 8, generic in the event rider `z` and the guard rider `y`:

```
  ¬S(a ∧ z, q ∨ y) ↔ H(¬a ∨ ¬z)
                   ∨ S(¬q ∧ ¬y ∧ ¬a, ¬a ∨ ¬z)
                   ∨ S(¬q ∧ ¬y ∧ ¬z, ¬a ∨ ¬z).
```

It is not a new principle: it is `usTruth_neg_snce` (GHR 10.2.2's `S`/`H` mirror, landed in
`NegationEquiv.lean`) at event `a ∧ z` and guard `q ∨ y`, followed by
`usTruth_snce_or_event` (GHR 10.2.1's second distributivity, landed in `Distributivity.lean`)
splitting the event `(¬a ∨ ¬z) ∧ ¬q ∧ ¬y` into `(¬a ∧ ¬q ∧ ¬y) ∨ (¬z ∧ ¬q ∧ ¬y)`, plus Boolean
congruence. Phase 18 therefore **consumes** the two landed lemmas rather than adding a third.

Substituting `y = z = ¬U(A,B)` (so `¬y = ¬z = U(A,B)`) gives

```
  ¬S(a ∧ ¬U, q ∨ ¬U) ↔ H(¬a ∨ U)                   -- Case 2 at q := ⊤, negated
                      ∨ S(¬q ∧ ¬a ∧ U, ¬a ∨ U)     -- Case 5 at a := ¬q ∧ ¬a, q := ¬a
                      ∨ S(¬q ∧ U, ¬a ∨ U).         -- Case 5 at a := ¬q,      q := ¬a
```
-/

/-! ## C. The formula abbreviations the candidates are written in -/

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

/-- `S(a, B)` — the pure-past core GHR's Case 5 is built around. -/
abbrev Sab : USForm := USForm.snce B a
/-- `S(¬q, ¬A)`. At `t` this says: `q` holds throughout `[z, t)`, where `z` is the greatest
`A`-point below `t` (and throughout `(-∞, t)` when there is none). -/
abbrev Sqa : USForm := USForm.snce A.neg q.neg
/-- GHR's re-anchoring guard `A ∨ B ∨ ¬S(¬q, ¬A)`. -/
abbrev reanchorGuard : USForm := A.or (B.or Sqa.neg)
/-- GHR's own pure-past core of Case 5: `S(a,B) ∨ S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A))`. -/
abbrev Core : USForm := Sab.or (USForm.snce reanchorGuard (A.and Sab))
/-- `W := A ∨ (B ∧ U(A,B))` — GHR's `[A ∨ (B ∧ U(A,B))]`. At `t` this says exactly
`∃x ≥ t, A(x) ∧ B on [t,x)`: the `U(A,B)` witness is at or after the evaluation point. This is
the only place `U(A,B)` occurs in any candidate below, and it is never under an `S`. -/
abbrev Wf : USForm := A.or (B.and Uf)

/-- GHR 10.2.3 Case 5's left-hand side: `S(a ∧ U(A,B), q ∨ U(A,B))`. -/
abbrev case5LHS : USForm := USForm.snce (q.or Uf) (a.and Uf)

/-! ### Candidate 1 — the printed formula's two-disjunct bracketing repair

The repair the blocker research proposed: GHR's `[A ∨ (B ∧ U(A,B))]` attached to the first
disjunct **only**, with `S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A)) ∧ ¬S(¬q,¬A)` as the second.
-/
abbrev twoDisjRhs : USForm :=
  (Sab.and Wf).or ((USForm.snce reanchorGuard (A.and Sab)).and Sqa.neg)

/-! ### Candidate 2 — `case5RHS`, the heavy candidate Phase 5 pinned

Recorded here by reference only. Its text is
`prototype/cases-5-8-probe.lean`'s `case5RHS`; it survived three probe models at Phase 5 and no
derivation of its correctness exists in this task's record.
-/

/-! ### Candidate 3 — the pinned candidate

```
   (W ∧ Core)
 ∨ (¬W ∧ ¬S(¬q,¬A) ∧ S(A ∧ Core, ¬A))
```

This keeps GHR's `Core` and GHR's `¬S(¬q,¬A)` verbatim and repairs **where `W` sits**: `W` is a
case *split*, not a conjunct of both disjuncts. Derivation, at an evaluation point `t`:

1. `LHS@t ⟺ D1 ∨ D2`, splitting on whether the `U(A,B)` witness `u` for the event conjunct
   `U(A,B)@s` can be taken `≥ t`:
   * `D1 := S(a,B)@t ∧ W@t` is the `u ≥ t` branch. Its outer guard is automatic, since every
     `r ∈ (s,t)` has `B on (r,u)` and so `U(A,B)@r`.
   * `D2 := ∃u<t, A(u) ∧ S(a,B)@u ∧ (q∨U)@u ∧ (q∨U) on (u,t)` is the `u < t` branch. The guard on
     `(s,u)` is automatic for the same reason, which is why `S(a,B)@u` — not
     `S(a, B ∧ (q∨U))@u` — is the right event.
2. **Under `W@t`**: `B on (r,t) → U(A,B)@r` for every `r < t`. Hence (proved as Claim C below)
   `(q∨U) on [u,t) ⟺ (A ∨ B ∨ ¬S(¬q,¬A)) on (u,t)` whenever `A(u)` and `u < t`. So
   `D2 ⟺ S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A))@t`, and `D1 ⟺ S(a,B)@t`; together `Core@t`.
3. **Under `¬W@t`**: `U(A,B)@r` is false for every `r ∈ [z,t)`, where `z` is the greatest
   `A`-point below `t`, so the guard forces `q on [z,t)`, which is exactly `¬S(¬q,¬A)@t`; and the
   residue below `z` is `LHS@z`. Since `A(z)` makes `W@z` true, step 2 applies at `z` and gives
   `Core@z`. Picking `z` out at `t` is `S(A ∧ Core, ¬A)@t`.

**Claim C** (the step 2 equivalence). Let `u < t`, `A(u)`, and `W@t`. Then
`∀r∈[u,t), q(r) ∨ U(A,B)@r` iff `∀r∈(u,t), A(r) ∨ B(r) ∨ ¬S(¬q,¬A)@r`.
* (⇐) Take `r ∈ [u,t)` and let `n` be the least `¬B` point above `r`. If `n ≥ t` then
  `B on (r,t)`, so `W@t` gives `U(A,B)@r`. Otherwise `n ∈ (u,t)` and `¬B(n)`, so `A(n)` — giving
  the `U(A,B)@r` witness `n` — or `¬S(¬q,¬A)@n`, whose instance at `y := r` gives `q(r)` or an
  `A`-point in `(r,n)`, again a `U(A,B)@r` witness.
* (⇒) Take `r ∈ (u,t)` with `¬A(r) ∧ ¬B(r)`, and `y < r`. If `y < u` then `A(u) ∈ (y,r)`.
  Otherwise `y ∈ [u,r)`, so `q(y) ∨ U(A,B)@y`; and a `U(A,B)@y` witness lies in `(y, n(y)]` with
  `n(y) ≤ r`, hence in `(y,r)` because `¬A(r)`.

`U(A,B)` occurs only inside `W`, never under an `S`, so the candidate meets GHR 10.2.3's
conclusion. Separatedness: `Core`, `Sqa` and `S(A ∧ Core, ¬A)` are `snce`-only whenever
`a, q, A, B` are, and `Wf` is a Boolean combination of leaves with one `untl`-only conjunct.
-/
abbrev case5Rhs : USForm :=
  (Wf.and Core).or (Wf.neg.and (Sqa.neg.and (USForm.snce A.neg (A.and Core))))

/-! ## D. Probe model 1 — the refuting model of `reports/01`

`a(0)`, `q ∈ {1,2}`, `A(1)`, `B ≡ ⊥`; evaluated at `t = 3`. GHR's printed Case 5 formula is
FALSE here while the left-hand side is TRUE. A surviving candidate must be TRUE at `t = 3`. -/

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

theorem v₀_Uf_0 : usTruth v₀ 0 Uf := by
  rw [usTruth_untl_iff]
  exact ⟨1, by omega, (v₀_A_iff 1).mpr rfl, fun r h1 h2 => (by omega : False).elim⟩

/-- **Probe 1a**: the left-hand side is TRUE at `t = 3` on the refuting model. -/
theorem v₀_LHS : usTruth v₀ 3 case5LHS := by
  rw [usTruth_snce_iff]
  refine ⟨0, by omega,
    (usTruth_and_iff v₀ 0 a Uf).mpr ⟨(v₀_a_iff 0).mpr rfl, v₀_Uf_0⟩, fun r h1 h2 => ?_⟩
  exact (usTruth_or_iff v₀ r q Uf).mpr (Or.inl ((v₀_q_iff r).mpr (by omega)))

theorem v₀_not_Wf_3 : ¬ usTruth v₀ 3 Wf := by
  intro h
  rcases (usTruth_or_iff v₀ 3 A _).mp h with hA | hB
  · exact absurd ((v₀_A_iff 3).mp hA) (by omega)
  · exact v₀_B 3 ((usTruth_and_iff v₀ 3 B Uf).mp hB).1

theorem v₀_not_Sqa_3 : ¬ usTruth v₀ 3 Sqa := by
  rw [usTruth_snce_iff]
  rintro ⟨s, hs, hev, hg⟩
  have hev' := (usTruth_neg_iff v₀ s q).mp hev
  have h1 : s ≠ 1 := fun h => hev' ((v₀_q_iff s).mpr (Or.inl h))
  have h2 : s ≠ 2 := fun h => hev' ((v₀_q_iff s).mpr (Or.inr h))
  have hA1 := (usTruth_neg_iff v₀ 1 A).mp (hg 1 (by omega) (by omega))
  exact hA1 ((v₀_A_iff 1).mpr rfl)

/-- **Probe 1b**: the pinned candidate is TRUE at `t = 3`, through its second disjunct: `W` fails
at `3`, `¬S(¬q,¬A)` holds because `q` covers `[1,3)`, and the greatest `A`-point below `3` is `1`,
where `Core` holds through `S(a,B)`. -/
theorem v₀_case5Rhs : usTruth v₀ 3 case5Rhs := by
  refine (usTruth_or_iff v₀ 3 _ _).mpr (Or.inr ((usTruth_and_iff v₀ 3 Wf.neg _).mpr
    ⟨v₀_not_Wf_3, (usTruth_and_iff v₀ 3 Sqa.neg _).mpr ⟨v₀_not_Sqa_3, ?_⟩⟩))
  rw [usTruth_snce_iff]
  refine ⟨1, by omega, (usTruth_and_iff v₀ 1 A Core).mpr ⟨(v₀_A_iff 1).mpr rfl, ?_⟩,
    fun r h1 h2 => ?_⟩
  · refine (usTruth_or_iff v₀ 1 Sab _).mpr (Or.inl ?_)
    rw [usTruth_snce_iff]
    exact ⟨0, by omega, (v₀_a_iff 0).mpr rfl, fun r h1 h2 => (by omega : False).elim⟩
  · exact (usTruth_neg_iff v₀ r A).mpr fun hA => absurd ((v₀_A_iff r).mp hA) (by omega)

/-! ## E. Probe model 2 — the adjacency degeneracy with a future `A`-witness

`a(-1)`, `q ≡ ⊥`, `A(5)`, `B` on `[-1,5]`; evaluated at `t = 0`. The outer `S`-guard is the empty
interval `(-1,0)`, the degeneracy that refuted the printed formula. Both sides must be TRUE. -/

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
theorem v₁_LHS : usTruth v₁ 0 case5LHS := by
  rw [usTruth_snce_iff]
  exact ⟨-1, by omega,
    (usTruth_and_iff v₁ (-1) a Uf).mpr
      ⟨(v₁_a_iff (-1)).mpr rfl, v₁_Uf (-1) (by omega) (by omega)⟩,
    fun r h1 h2 => (by omega : False).elim⟩

/-- **Probe 2b**: the pinned candidate is TRUE at `t = 0`, through its first disjunct, with `W`
supplied by `B(0) ∧ U(A,B)@0` and `Core` by `S(a,B)@0`. -/
theorem v₁_case5Rhs : usTruth v₁ 0 case5Rhs := by
  refine (usTruth_or_iff v₁ 0 _ _).mpr (Or.inl ((usTruth_and_iff v₁ 0 Wf Core).mpr ⟨?_, ?_⟩))
  · refine (usTruth_or_iff v₁ 0 A _).mpr (Or.inr ((usTruth_and_iff v₁ 0 B Uf).mpr ⟨?_, ?_⟩))
    · exact (v₁_B_iff 0).mpr ⟨by omega, by omega⟩
    · exact v₁_Uf 0 (by omega) (by omega)
  · refine (usTruth_or_iff v₁ 0 Sab _).mpr (Or.inl ?_)
    rw [usTruth_snce_iff]
    exact ⟨-1, by omega, (v₁_a_iff (-1)).mpr rfl, fun r h1 h2 => (by omega : False).elim⟩

/-! ## F. Probe model 3 — the past `A`-witness with a failing guard

`a(0)`, `q ≡ ⊥`, `A(1)`, `B ≡ ⊥`; evaluated at `t = 3`. Both sides must be FALSE — this is the
probe that catches a candidate merely *implied by* the left-hand side. -/

/-- The past-witness model: `a(0)`, `q ≡ ⊥`, `A(1)`, `B ≡ ⊥`. -/
def v₂ : ℕ → ℤ → Prop
  | 0 => fun x => x = 0
  | 2 => fun x => x = 1
  | _ => fun _ => False

theorem v₂_a_iff (x : ℤ) : usTruth v₂ x a ↔ x = 0 := Iff.rfl
theorem v₂_A_iff (x : ℤ) : usTruth v₂ x A ↔ x = 1 := Iff.rfl
theorem v₂_B (x : ℤ) : ¬ usTruth v₂ x B := fun h => h
theorem v₂_q (x : ℤ) : ¬ usTruth v₂ x q := fun h => h

theorem v₂_Uf_iff (t : ℤ) : usTruth v₂ t Uf ↔ t < 1 ∧ (∀ r : ℤ, t < r → r < 1 → False) := by
  rw [usTruth_untl_iff]
  constructor
  · rintro ⟨u, htu, hA, hg⟩
    have hu : u = 1 := (v₂_A_iff u).mp hA
    subst hu
    exact ⟨htu, fun r h1 h2 => v₂_B r (hg r h1 h2)⟩
  · rintro ⟨h1, hg⟩
    exact ⟨1, h1, (v₂_A_iff 1).mpr rfl, fun r hr1 hr2 => absurd (hg r hr1 hr2) not_false⟩

/-- **Probe 3a**: the left-hand side is FALSE at `t = 3`: the only `a`-point is `0`, and the guard
`q ∨ U(A,B)` fails at `r = 1`. -/
theorem v₂_not_LHS : ¬ usTruth v₂ 3 case5LHS := by
  rw [usTruth_snce_iff]
  rintro ⟨s, hs, hev, hg⟩
  have hs0 : s = 0 := (v₂_a_iff s).mp ((usTruth_and_iff v₂ s a Uf).mp hev).1
  subst hs0
  rcases (usTruth_or_iff v₂ 1 q Uf).mp (hg 1 (by omega) (by omega)) with h | h
  · exact v₂_q 1 h
  · exact absurd ((v₂_Uf_iff 1).mp h).1 (by omega)

theorem v₂_not_Wf_3 : ¬ usTruth v₂ 3 Wf := by
  intro h
  rcases (usTruth_or_iff v₂ 3 A _).mp h with hA | hB
  · exact absurd ((v₂_A_iff 3).mp hA) (by omega)
  · exact v₂_B 3 ((usTruth_and_iff v₂ 3 B Uf).mp hB).1

theorem v₂_Sqa_3 : usTruth v₂ 3 Sqa := by
  rw [usTruth_snce_iff]
  exact ⟨2, by omega, (usTruth_neg_iff v₂ 2 q).mpr (v₂_q 2),
    fun r h1 h2 => (by omega : False).elim⟩

/-- **Probe 3b**: the pinned candidate is FALSE at `t = 3`. `W` fails, and `¬S(¬q,¬A)` fails
because `¬q(2)` holds with no `A`-point in `(2,3)`. -/
theorem v₂_not_case5Rhs : ¬ usTruth v₂ 3 case5Rhs := by
  intro h
  rcases (usTruth_or_iff v₂ 3 _ _).mp h with h1 | h2
  · exact v₂_not_Wf_3 ((usTruth_and_iff v₂ 3 Wf Core).mp h1).1
  · exact ((usTruth_and_iff v₂ 3 Sqa.neg _).mp
      ((usTruth_and_iff v₂ 3 Wf.neg _).mp h2).2).1 v₂_Sqa_3

/-! ## G. Probe model 4 — the model that REFUTES the two-disjunct bracketing repair

`a(0)`, `q ≡ ⊥`, `A ∈ {1,5}`, `B` on `{2,3,4}`; evaluated at `t = 2`.

The left-hand side is TRUE with `s = 0`: the event's `U(A,B)@0` is witnessed by the adjacent
`A`-point `1` over the empty guard interval, and the outer guard at `r = 1` is met not by `q` but
by `U(A,B)@1`, whose witness `5` lies **beyond** the evaluation point.

Both bracketings of GHR's printed Case 5 — and hence the two-disjunct repair, which keeps
`¬S(¬q,¬A)` as a conjunct of its second disjunct — are FALSE here:
* `S(a,B)@2` fails, because `B(1)` is false, so the first disjunct fails whatever `W` does;
* `¬S(¬q,¬A)@2` fails, because `¬q(1)` holds with no `A`-point in `(1,2)`, so the second
  disjunct fails.

This is a **new** refutation, not the one in `reports/01`: that model refutes the printed
formula through its *first* disjunct's `W` conjunct, which the two-disjunct repair was proposed to
fix. This one refutes the repair itself. -/

/-- The repair-refuting model: `a(0)`, `q ≡ ⊥`, `A ∈ {1,5}`, `B` on `{2,3,4}`. -/
def v₃ : ℕ → ℤ → Prop
  | 0 => fun x => x = 0
  | 1 => fun _ => False
  | 2 => fun x => x = 1 ∨ x = 5
  | _ => fun x => 2 ≤ x ∧ x ≤ 4

theorem v₃_a_iff (x : ℤ) : usTruth v₃ x a ↔ x = 0 := Iff.rfl
theorem v₃_q (x : ℤ) : ¬ usTruth v₃ x q := fun h => h
theorem v₃_A_iff (x : ℤ) : usTruth v₃ x A ↔ (x = 1 ∨ x = 5) := Iff.rfl
theorem v₃_B_iff (x : ℤ) : usTruth v₃ x B ↔ (2 ≤ x ∧ x ≤ 4) := Iff.rfl

theorem v₃_Uf_0 : usTruth v₃ 0 Uf := by
  rw [usTruth_untl_iff]
  exact ⟨1, by omega, (v₃_A_iff 1).mpr (Or.inl rfl), fun r h1 h2 => (by omega : False).elim⟩

theorem v₃_Uf_1 : usTruth v₃ 1 Uf := by
  rw [usTruth_untl_iff]
  exact ⟨5, by omega, (v₃_A_iff 5).mpr (Or.inr rfl),
    fun r h1 h2 => (v₃_B_iff r).mpr ⟨by omega, by omega⟩⟩

theorem v₃_Uf_2 : usTruth v₃ 2 Uf := by
  rw [usTruth_untl_iff]
  exact ⟨5, by omega, (v₃_A_iff 5).mpr (Or.inr rfl),
    fun r h1 h2 => (v₃_B_iff r).mpr ⟨by omega, by omega⟩⟩

/-- **Probe 4a**: the left-hand side is TRUE at `t = 2`. -/
theorem v₃_LHS : usTruth v₃ 2 case5LHS := by
  rw [usTruth_snce_iff]
  refine ⟨0, by omega,
    (usTruth_and_iff v₃ 0 a Uf).mpr ⟨(v₃_a_iff 0).mpr rfl, v₃_Uf_0⟩, fun r h1 h2 => ?_⟩
  have hr : r = 1 := by omega
  subst hr
  exact (usTruth_or_iff v₃ 1 q Uf).mpr (Or.inr v₃_Uf_1)

theorem v₃_not_Sab_2 : ¬ usTruth v₃ 2 Sab := by
  rw [usTruth_snce_iff]
  rintro ⟨s, hs, hev, hg⟩
  have hs0 : s = 0 := (v₃_a_iff s).mp hev
  subst hs0
  have := (v₃_B_iff 1).mp (hg 1 (by omega) (by omega))
  omega

theorem v₃_Sqa_2 : usTruth v₃ 2 Sqa := by
  rw [usTruth_snce_iff]
  exact ⟨1, by omega, (usTruth_neg_iff v₃ 1 q).mpr (v₃_q 1),
    fun r h1 h2 => (by omega : False).elim⟩

/-- **Probe 4b**: the two-disjunct bracketing repair is FALSE at `t = 2`. The repair is therefore
**refuted** and is not the candidate Phase 17 implements. -/
theorem v₃_not_twoDisjRhs : ¬ usTruth v₃ 2 twoDisjRhs := by
  intro h
  rcases (usTruth_or_iff v₃ 2 _ _).mp h with h1 | h2
  · exact v₃_not_Sab_2 ((usTruth_and_iff v₃ 2 Sab Wf).mp h1).1
  · exact ((usTruth_and_iff v₃ 2 _ Sqa.neg).mp h2).2 v₃_Sqa_2

/-- **Probe 4c**: the pinned candidate is TRUE at `t = 2`, through its first disjunct: `W` holds
via `B(2) ∧ U(A,B)@2`, and `Core` via the re-anchored `S` at the `A`-point `1`. -/
theorem v₃_case5Rhs : usTruth v₃ 2 case5Rhs := by
  refine (usTruth_or_iff v₃ 2 _ _).mpr (Or.inl ((usTruth_and_iff v₃ 2 Wf Core).mpr ⟨?_, ?_⟩))
  · refine (usTruth_or_iff v₃ 2 A _).mpr (Or.inr ((usTruth_and_iff v₃ 2 B Uf).mpr ⟨?_, v₃_Uf_2⟩))
    exact (v₃_B_iff 2).mpr ⟨by omega, by omega⟩
  · refine (usTruth_or_iff v₃ 2 Sab _).mpr (Or.inr ?_)
    rw [usTruth_snce_iff]
    refine ⟨1, by omega, ?_, fun r h1 h2 => (by omega : False).elim⟩
    refine (usTruth_and_iff v₃ 1 A Sab).mpr ⟨(v₃_A_iff 1).mpr (Or.inl rfl), ?_⟩
    rw [usTruth_snce_iff]
    exact ⟨0, by omega, (v₃_a_iff 0).mpr rfl, fun r h1 h2 => (by omega : False).elim⟩

/-! ## H. Case 8's printed third disjunct is NOT redundant

GHR write, of the three-disjunct expansion of `¬D` for `D = S(a ∧ ¬U(A,B), q ∨ ¬U(A,B))`:
"Notice the last disjunct in ¬D is redundant." That is **false**, and the error is an
orientation error: of the two `S` disjuncts

```
  d₂ := S(¬q ∧ ¬a ∧ U(A,B), ¬a ∨ U(A,B))
  d₃ := S(¬q ∧ U(A,B),      ¬a ∨ U(A,B))
```

`d₂`'s event strictly implies `d₃`'s, and `S` is monotone in its event argument, so it is `d₂` —
the **second** — that is redundant, never `d₃`. The model below exhibits a point at which `d₃` is
the only true disjunct of the three, so dropping it would make the expansion unsound.

`a ∈ {0,4}`, `q ≡ ⊥`, `A(5)`, `B(5)`; evaluated at `t = 5`. Here `U(A,B)` is true at exactly one
point, `4`: the single `A`-point is `5`, and the guard interval `(t,5)` is non-empty and `B`-free
for every `t < 4`.
* `d₁ := H(¬a ∨ U(A,B))` fails, witnessed at `0`: `a(0)` holds and `U(A,B)@0` does not.
* `d₂` fails: its event needs `U(A,B)`, hence the point `4`, where `¬a` fails.
* `d₃` holds with witness `4`: `¬q(4)` and `U(A,B)@4`, over the empty guard interval `(4,5)`.

Phase 18 therefore keeps all three disjuncts and cites this model at the definition. -/

/-- The Case 8 non-redundancy model: `a ∈ {0,4}`, `q ≡ ⊥`, `A(5)`, `B(5)`. -/
def v₄ : ℕ → ℤ → Prop
  | 0 => fun x => x = 0 ∨ x = 4
  | 1 => fun _ => False
  | 2 => fun x => x = 5
  | _ => fun x => x = 5

theorem v₄_a_iff (x : ℤ) : usTruth v₄ x a ↔ (x = 0 ∨ x = 4) := Iff.rfl
theorem v₄_q (x : ℤ) : ¬ usTruth v₄ x q := fun h => h
theorem v₄_A_iff (x : ℤ) : usTruth v₄ x A ↔ x = 5 := Iff.rfl
theorem v₄_B_iff (x : ℤ) : usTruth v₄ x B ↔ x = 5 := Iff.rfl

/-- On this model `U(A,B)` is true at exactly the point `4`. -/
theorem v₄_Uf_iff (t : ℤ) : usTruth v₄ t Uf ↔ t = 4 := by
  rw [usTruth_untl_iff]
  constructor
  · rintro ⟨u, htu, hA, hg⟩
    have hu : u = 5 := (v₄_A_iff u).mp hA
    subst hu
    by_contra hne
    have h4 : t < 4 := by omega
    have := (v₄_B_iff 4).mp (hg 4 (by omega) (by omega))
    omega
  · intro ht
    subst ht
    exact ⟨5, by omega, (v₄_A_iff 5).mpr rfl, fun r h1 h2 => (by omega : False).elim⟩

/-- Case 8's first printed disjunct, `H(¬a ∨ U(A,B))`. -/
abbrev case8d₁ : USForm := USForm.allPast (a.neg.or Uf)
/-- Case 8's second printed disjunct, `S(¬q ∧ ¬a ∧ U(A,B), ¬a ∨ U(A,B))`. -/
abbrev case8d₂ : USForm := USForm.snce (a.neg.or Uf) ((q.neg.and a.neg).and Uf)
/-- Case 8's third printed disjunct, `S(¬q ∧ U(A,B), ¬a ∨ U(A,B))`. -/
abbrev case8d₃ : USForm := USForm.snce (a.neg.or Uf) (q.neg.and Uf)

/-- **Probe 5a**: Case 8's first printed disjunct is FALSE at `t = 5`. -/
theorem v₄_not_case8d₁ : ¬ usTruth v₄ 5 case8d₁ := by
  rw [usTruth_allPast_iff]
  intro h
  rcases (usTruth_or_iff v₄ 0 a.neg Uf).mp (h 0 (by omega)) with hna | hU
  · exact (usTruth_neg_iff v₄ 0 a).mp hna ((v₄_a_iff 0).mpr (Or.inl rfl))
  · exact absurd ((v₄_Uf_iff 0).mp hU) (by omega)

/-- **Probe 5b**: Case 8's second printed disjunct is FALSE at `t = 5`. -/
theorem v₄_not_case8d₂ : ¬ usTruth v₄ 5 case8d₂ := by
  rw [usTruth_snce_iff]
  rintro ⟨s, hs, hev, hg⟩
  have hU := ((usTruth_and_iff v₄ s _ Uf).mp hev).2
  have hs4 : s = 4 := (v₄_Uf_iff s).mp hU
  subst hs4
  have hna := ((usTruth_and_iff v₄ 4 q.neg a.neg).mp ((usTruth_and_iff v₄ 4 _ Uf).mp hev).1).2
  exact (usTruth_neg_iff v₄ 4 a).mp hna ((v₄_a_iff 4).mpr (Or.inr rfl))

/-- **Probe 5c**: Case 8's third printed disjunct is TRUE at `t = 5`. With Probes 5a and 5b this
records the gate's criterion (c): the third disjunct is the only true one, so GHR's redundancy
claim about it is refuted. -/
theorem v₄_case8d₃ : usTruth v₄ 5 case8d₃ := by
  rw [usTruth_snce_iff]
  refine ⟨4, by omega, ?_, fun r h1 h2 => (by omega : False).elim⟩
  exact (usTruth_and_iff v₄ 4 q.neg Uf).mpr
    ⟨(usTruth_neg_iff v₄ 4 q).mpr (v₄_q 4), (v₄_Uf_iff 4).mpr rfl⟩

/-- **Probe 5d**: and `D` itself is FALSE at `t = 5`, as `¬D`'s truth requires — a consistency
check on the expansion, not a gate criterion. -/
theorem v₄_not_case8LHS : ¬ usTruth v₄ 5 (USForm.snce (q.or Uf.neg) (a.and Uf.neg)) := by
  rw [usTruth_snce_iff]
  rintro ⟨s, hs, hev, hg⟩
  have ha := (v₄_a_iff s).mp ((usTruth_and_iff v₄ s a Uf.neg).mp hev).1
  have hnU := (usTruth_neg_iff v₄ s Uf).mp ((usTruth_and_iff v₄ s a Uf.neg).mp hev).2
  rcases ha with h0 | h4
  · subst h0
    rcases (usTruth_or_iff v₄ 4 q Uf.neg).mp (hg 4 (by omega) (by omega)) with hq | hnU4
    · exact v₄_q 4 hq
    · exact (usTruth_neg_iff v₄ 4 Uf).mp hnU4 ((v₄_Uf_iff 4).mpr rfl)
  · subst h4
    exact hnU ((v₄_Uf_iff 4).mpr rfl)

/-! ## I. Gate measurement

**This measurement supersedes Phase 5's gate verdict for Cases 6, 7 and 8.** Phase 5 measured
1 of 4 against a route — direct semantic re-anchoring of each of the four hard cases — that the
source does not use, and against a separatedness bar (`IsSeparated` at every input position)
that GHR 10.2.4 does not itself meet. Section A above reads the source's own reduction order off
the §10.2 text; under it, Cases 6, 7 and 8 are never re-anchored and the Cases 5/8 loop Phase 5
recorded does not arise. Phase 5's record stands as the measurement of the superseded route; its
"precisely located obstruction" paragraph describes that route's `∃∀` condition, not a
mathematical obstruction to Lemma 10.2.3.

**Criterion (a) — a Case 5 candidate surviving all three recorded probe models: MET.**
The pinned candidate is `case5Rhs` of section C, candidate 3. Probed TRUE at `t = 3` on model 1
(`v₀_case5Rhs`, beside `v₀_LHS`), TRUE at `t = 0` on model 2 (`v₁_case5Rhs`, beside `v₁_LHS`),
and FALSE at `t = 3` on model 3 (`v₂_not_case5Rhs`, beside `v₂_not_LHS`). It additionally survives
the new model 4 (`v₃_case5Rhs`, beside `v₃_LHS`), which refutes the two other candidates'
shared conjunct.

**Deviation from the phase's task list, recorded rather than annotated.** The phase instructed
Phase 17 to implement either the two-disjunct bracketing repair (preferred) or Phase 5's
`case5RHS` (fallback). Neither is implemented:
* the **two-disjunct repair is refuted** by model 4 (`v₃_not_twoDisjRhs`), which was not among the
  three recorded models and which the blocker research did not test. Both bracketings of GHR's
  printed Case 5 keep `¬S(¬q,¬A)` as a conjunct of the second disjunct, and model 4 is a point at
  which the left-hand side holds while `S(a,B)` and `¬S(¬q,¬A)` both fail. Implementing a refuted
  formula is not an option the plan intends;
* Phase 5's `case5RHS` remains unrefuted but carries **no derivation of its correctness**
  anywhere in this task's record — its own docstring presents it as a reconstruction whose
  guard-failure re-anchoring "collapses", not as a proved equivalence.
The pinned candidate is neither a third reconstruction nor a weakening: it keeps GHR's `Core` and
GHR's `¬S(¬q,¬A)` verbatim and repairs only **where `W` sits** — a case split on a pure
present-and-future formula, rather than a conjunct of both disjuncts. Section C, candidate 3
carries its full semantic derivation, including the one new lemma it needs (Claim C), so Phase 17
proves a stated equivalence rather than searching for one.

**Criterion (b) — the reduction edges recorded, each naming its source step, and the DAG
acyclic: MET.** Section A. All five edges the plan names are present and each quotes the sentence
of GHR's proof of Lemma 10.2.3 that states it; the topological order
`1 < 2 < 3 < 4 < 5 < 8 < 7 < 6` witnesses acyclicity. Two refinements of the plan's edge list,
both from the source text rather than from reconstruction: Case 8 consumes Case 5 **twice** (at
two different instantiations) and additionally Case 2 at `q := ⊤` for its `H` disjunct; and
Case 7's and Case 6's reductions each need one semantic step of their own before the named
earlier cases apply, which the source states and the plan's one-line summary compresses.

**Criterion (c) — a model and a point at which Case 8's third printed disjunct is the only true
one: MET.** Section H, model `v₄` at `t = 5`: `v₄_not_case8d₁`, `v₄_not_case8d₂`,
`v₄_case8d₃`. The orientation of GHR's error is also recorded there: it is the **second**
disjunct that is redundant, by event-monotonicity of `S`, never the third.

**VERDICT: 3 of 3 criteria met.** The gate is MET and Phases 17-27 proceed as written, with the
one recorded candidate deviation above. The reduction-edge contingency branch of the plan's
`## Rollback/Contingency` does not apply.
-/

end Probe867Reduction
