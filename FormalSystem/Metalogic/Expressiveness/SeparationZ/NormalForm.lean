/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.ElimHard

/-!
# GHR Lemma 10.2.4 — one `snce` of a single `untl` type, separated

[GHR][gabbay1994] vol. 1, Lemma 10.2.4: if `A` and `B` are `untl`/`snce`-free and both arguments
of a `snce` mention `untl` only as `untl B A` and never under a `snce`, then that `snce` has a
syntactically separated equivalent.

## The precondition is its own predicate, not `IsSeparated`

`IsUTyped A B` is the hypothesis this lemma consumes: every `untl` occurrence is the single type
`untl B A`, and every `snce` subformula is `untl`-free. It is **strictly weaker** than the
`IsSeparated` of `Eliminations.lean`, and the two are not interchangeable at an input position:

* `IsUTyped A B φ` says nothing about `A` and `B` themselves. With `A := snce q p` the formula
  `untl B A` satisfies `IsUTyped A B` and is **not** `IsSeparated`, since `IsSeparated.untl`
  demands `IsUOnly` arguments. `isSeparated_of_isUTyped` therefore takes `IsUOnly A` and
  `IsUOnly B` as extra hypotheses — exactly GHR's standing "`A` and `B` are wffs in which `U` and
  `S` do not appear".
* `IsSeparated φ` says nothing about which `untl` types occur, so it does not imply
  `IsUTyped A B φ` either.

Giving this lemma's input position the stronger `IsSeparated` bar is what made an earlier
dispatch's decision gate unmeetable: it held each candidate right-hand side to a standard the
source does not meet at this step. Do not re-impose it here or downstream.

## The normal form this takes, and what it replaces

The plan this module executes called for general disjunctive and conjunctive normal forms on the
Boolean skeleton of a `USForm`, followed by a clause-by-clause match of each resulting clause
against one of GHR's eight cases. What is built instead is the **`untl`-literal normal form** —
the specialization of those normal forms that isolates `±untl B A`, which is the only thing
Lemma 10.2.4 consumes. This is a recorded deviation, not an oversight: the plan's Phase 20
`#### Reasoned Exclusions` table carries the full record.

The device is `substU`: replace every `untl B A` occurrence by `⊤` or by `⊥`. Under
`IsUTyped A B` the recursion never has to enter a `snce` (those are `untl`-free) and never meets
another `untl` type, so one structural pass suffices and both results are `untl`-free. Then at
every point `r`, writing `U` for `untl B A`:

```
  C   ↔ (Cᵁ ∧ U) ∨ (C⁰ ∧ ¬U)        -- the event's disjunctive split
  F   ↔ (Fᵁ ∨ ¬U) ∧ (F⁰ ∨ U)        -- the guard's conjunctive split
```

Feeding these through GHR 10.2.1's event-disjunction and guard-conjunction distributivities
(`usTruth_snce_or_event`, `usTruth_snce_and_guard`) turns `S(C,F)` into a conjunction of
disjunctions of exactly **four** instances, one per hard case:

| instance | case | at |
|----------|------|-----|
| `S(Cᵁ ∧ U, Fᵁ ∨ ¬U)` | 7 | `a := Cᵁ`, `q := Fᵁ` |
| `S(Cᵁ ∧ U, F⁰ ∨ U)` | 5 | `a := Cᵁ`, `q := F⁰` |
| `S(C⁰ ∧ ¬U, Fᵁ ∨ ¬U)` | 8 | `a := C⁰`, `q := Fᵁ` |
| `S(C⁰ ∧ ¬U, F⁰ ∨ U)` | 6 | `a := C⁰`, `q := F⁰` |

General normal forms would reach the same four instances by a longer road, and would additionally
have to dispose of clauses carrying both `U` and `¬U` and clauses carrying neither — cases the
substitution split never produces. The mathematical content is GHR's; only the route to it is
shorter.

## Both conclusion halves, and why `sepSnce` routes through the printed-form siblings

GHR 10.2.4's conclusion has two halves: the equivalent is *separated*, and in it *`untl` occurs
only as `untl B A`*. Both are proved here, as `isSeparated_sepSnce` and `isUTyped_sepSnce`
respectively. The second is what makes an induction counting `untl` **types** well-posed over
this layer; an induction counting `untl` occurrences lying *under a `snce`* is already driven to
zero by the first.

The typedness half is what fixes which of the two available Case 2 routes `sepSnce` consumes.
`Eliminations.lean` carries both, side by side and neither weakening the other:

* `case2Rhs` / `usTruth_case2` is built as `… ∨ case1Rhs a q (A.neg.and B.neg) A.neg` together
  with `allFuture A.neg`, so it mentions the `untl` types `untl A.neg (A.neg.and B.neg)` and
  `untl USForm.top A.neg.neg` beside `untl B A`. It is retained exactly as it stands — nothing
  here weakens its statement — and it is not `IsUTyped A B`.
* `case2RhsPrinted` / `usTruth_case2_printed` is GHR's printed three-disjunct Case 2, whose only
  `untl` occurrence is `untl B A`. It is obtained from the landed equivalence by
  `usTruth_neg_untl` (Lemma 10.2.2) in the `←` direction — GHR's own third step, "using lemma
  10.2.2 again (in reverse)".

`case3RhsPrinted`, and `ElimHard.lean`'s `case6RhsPrinted`, `case7RhsPrinted` and
`case8RhsPrinted`, are the same substitution propagated one slot at a time: each is identical to
its sibling except where it reaches Case 2 or Case 3. `case1Rhs`, `case4Rhs`, `case5W`,
`case5Core` and `case5Rhs` mention `untl B A` alone already and are shared by both routes.
`sepSnce`'s body therefore takes `case7RhsPrinted`, `case5Rhs`, `case8RhsPrinted` and
`case6RhsPrinted` at the four `substU` parameter pairs, and the printed-form siblings are the
route every downstream measure over this layer consumes.

## Main Definitions

- `IsUTyped`: GHR 10.2.4's actual precondition
- `substU`: the `untl`-literal substitution
- `sepSnce`: the separated equivalent of `snce F C`

## Main Results

- `isSeparated_of_isUTyped`: the relationship to `IsSeparated`, with its two extra hypotheses
- `usTruth_substU`, `isSOnly_substU`: the substitution's truth preservation and `untl`-freeness
- `usTruth_event_split`, `usTruth_guard_split`: the two halves of the normal form
- `isUTyped_case1Rhs`, `isUTyped_case2RhsPrinted`, `isUTyped_case3RhsPrinted`,
  `isUTyped_case4Rhs`, `isUTyped_case5W`, `isUTyped_case5Rhs`, `isUTyped_case6RhsPrinted`,
  `isUTyped_case7RhsPrinted`, `isUTyped_case8RhsPrinted`: the nine typedness witnesses for the
  right-hand sides the printed-form route reaches
- `usTruth_sepSnce`: GHR Lemma 10.2.4's equivalence
- `isSeparated_sepSnce`: its conclusion's separatedness, discharged
- `isUTyped_sepSnce`: its conclusion's single `untl` type, discharged

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemma 10.2.4
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## GHR 10.2.4's precondition -/

/--
`φ` is **`(A,B)`-typed**: every `untl` occurring in `φ` is the single type `untl B A`, and every
`snce` subformula of `φ` is `untl`-free. This is GHR Lemma 10.2.4's input hypothesis.

It is strictly weaker than `IsSeparated` and does not imply it — see the module docstring. An
input position asking for `IsSeparated` where this suffices is a defect, not a strengthening.

`Hierarchy.lean`'s `IsUSingleType` is in turn strictly weaker than this predicate — it drops the
`untl`-freeness of `snce` arguments — and is GHR Lemma 10.2.5's input hypothesis, while this one
is Lemma 10.2.4's; `isUSingleType_of_isUTyped` is the one-way implication between them.
-/
inductive IsUTyped (A B : USForm) : USForm → Prop
  /-- Every leaf is `(A,B)`-typed. -/
  | leaf (i : ℕ) : IsUTyped A B (.leaf i)
  /-- Bottom is `(A,B)`-typed. -/
  | bot : IsUTyped A B .bot
  /-- `imp` preserves `(A,B)`-typedness, carrying `neg`, `and`, `or` and `iff` with it. -/
  | imp {φ ψ : USForm} : IsUTyped A B φ → IsUTyped A B ψ → IsUTyped A B (.imp φ ψ)
  /-- The one admitted `untl`. -/
  | untl : IsUTyped A B (USForm.untl B A)
  /-- A `snce` is `(A,B)`-typed when it is `untl`-free, which is the "not under any `S`" half. -/
  | snce {ψ φ : USForm} : IsSOnly ψ → IsSOnly φ → IsUTyped A B (USForm.snce ψ φ)

namespace IsUTyped

variable {A B : USForm}

/-- An `untl`-free formula is `(A,B)`-typed for every `A` and `B`. -/
theorem ofIsSOnly {φ : USForm} (h : IsSOnly φ) : IsUTyped A B φ := by
  induction h with
  | leaf i => exact IsUTyped.leaf i
  | bot => exact IsUTyped.bot
  | imp _ _ ihφ ihψ => exact IsUTyped.imp ihφ ihψ
  | snce hψ hφ _ _ => exact IsUTyped.snce hψ hφ

theorem neg {φ : USForm} (h : IsUTyped A B φ) : IsUTyped A B φ.neg :=
  IsUTyped.imp h IsUTyped.bot

theorem and {φ ψ : USForm} (hφ : IsUTyped A B φ) (hψ : IsUTyped A B ψ) :
    IsUTyped A B (φ.and ψ) :=
  (IsUTyped.imp hφ hψ.neg).neg

theorem or {φ ψ : USForm} (hφ : IsUTyped A B φ) (hψ : IsUTyped A B ψ) :
    IsUTyped A B (φ.or ψ) :=
  IsUTyped.imp hφ.neg hψ

end IsUTyped

/--
**The relationship to `IsSeparated`.** `(A,B)`-typedness implies separatedness exactly when the
two type parameters are themselves `untl`-only — GHR's standing hypothesis that `A` and `B`
contain neither `U` nor `S`. Without those two hypotheses the implication fails, which is the
precise sense in which the precondition is weaker.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem isSeparated_of_isUTyped {A B : USForm} (hAu : IsUOnly A) (hBu : IsUOnly B)
    {φ : USForm} (h : IsUTyped A B φ) : IsSeparated φ := by
  induction h with
  | leaf i => exact IsSeparated.leaf i
  | bot => exact IsSeparated.bot
  | imp _ _ ihφ ihψ => exact IsSeparated.imp ihφ ihψ
  | untl => exact IsSeparated.untl hBu hAu
  | snce hψ hφ => exact IsSeparated.snce hψ hφ

/-! ## `IsUTyped` witnesses for the elimination layer

GHR 10.2.4's conclusion has two halves: the equivalent is *separated*, and in it `untl` occurs
only as `untl B A`. The witnesses below are the second half, for every right-hand side the
printed-form route reaches. Each mirrors the shape of the corresponding `isSeparated_*` lemma,
with `IsUTyped.untl` where that lemma has `IsSeparated.untl`.

They take only the four `IsSOnly` hypotheses. The two `IsUOnly` halves of GHR's standing
hypothesis on `A` and `B` are needed for *separatedness*, never for typedness, so asking for
them here would be a gratuitous strengthening — and `isSeparated_of_isUTyped` is where they are
consumed. `case5Core` needs no witness of its own: it is `IsSOnly`, so `IsUTyped.ofIsSOnly`
covers it. -/

/-- Case 1's right-hand side mentions `untl` only as `untl B A`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case1Rhs {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsUTyped A B (case1Rhs a q A B) :=
  IsUTyped.or
    (IsUTyped.ofIsSOnly (IsSOnly.snce hq (hAs.and (hq.and (IsSOnly.snce (hBs.and hq) ha)))))
    (IsUTyped.or
      (IsUTyped.ofIsSOnly (hAs.and (IsSOnly.snce (hq.and hBs) ha)))
      (IsUTyped.and (IsUTyped.ofIsSOnly hBs)
        (IsUTyped.and IsUTyped.untl
          (IsUTyped.ofIsSOnly (IsSOnly.snce (hq.and hBs) ha)))))

/-- Case 2's **printed** right-hand side mentions `untl` only as `untl B A`. This is the clause
the landed `case2Rhs` fails, and the reason the printed-form siblings exist.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case2RhsPrinted {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsUTyped A B (case2RhsPrinted a q A B) :=
  IsUTyped.or
    (IsUTyped.and (IsUTyped.ofIsSOnly (IsSOnly.snce (hq.and hAs.neg) ha))
      (IsUTyped.and (IsUTyped.ofIsSOnly hAs.neg) (IsUTyped.neg IsUTyped.untl)))
    (IsUTyped.or
      (IsUTyped.ofIsSOnly (hAs.neg.and (hBs.neg.and (IsSOnly.snce (hAs.neg.and hq) ha))))
      (IsUTyped.ofIsSOnly (IsSOnly.snce hq
        (((hAs.neg.and hBs.neg).and hq).and (IsSOnly.snce (hAs.neg.and hq) ha)))))

/-- Case 3's printed right-hand side mentions `untl` only as `untl B A`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case3RhsPrinted {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsUTyped A B (case3RhsPrinted a q A B) :=
  IsUTyped.neg (IsUTyped.or (IsUTyped.ofIsSOnly ha.neg.allPast)
    (isUTyped_case2RhsPrinted (ha.neg.and hq.neg) ha.neg hAs hBs))

/-- Case 4's right-hand side mentions `untl` only as `untl B A`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case4Rhs {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsUTyped A B (case4Rhs a q A B) :=
  IsUTyped.neg (IsUTyped.or (IsUTyped.ofIsSOnly ha.neg.allPast)
    (isUTyped_case1Rhs (ha.neg.and hq.neg) ha.neg hAs hBs))

/-- `W := A ∨ (B ∧ U(A,B))` mentions `untl` only as `untl B A` — its single occurrence.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case5W {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B) :
    IsUTyped A B (case5W A B) :=
  IsUTyped.or (IsUTyped.ofIsSOnly hAs)
    (IsUTyped.and (IsUTyped.ofIsSOnly hBs) IsUTyped.untl)

/-- Case 5's right-hand side mentions `untl` only as `untl B A`: every occurrence is inside
`case5W`, since `case5Core` is `untl`-free.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case5Rhs {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsUTyped A B (case5Rhs a q A B) := by
  have hcore := isSOnly_case5Core ha hq hAs hBs
  have hW := isUTyped_case5W (A := A) (B := B) hAs hBs
  exact IsUTyped.or (IsUTyped.and hW (IsUTyped.ofIsSOnly hcore))
    (IsUTyped.and (IsUTyped.neg hW) (IsUTyped.ofIsSOnly
      ((IsSOnly.snce hAs.neg hq.neg).neg.and (IsSOnly.snce hAs.neg (hAs.and hcore)))))

/-- Case 8's printed right-hand side mentions `untl` only as `untl B A`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case8RhsPrinted {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsUTyped A B (case8RhsPrinted a q A B) :=
  IsUTyped.neg
    (IsUTyped.or (IsUTyped.neg (isUTyped_case2RhsPrinted ha IsSOnly.top hAs hBs))
      (IsUTyped.or (isUTyped_case5Rhs (hq.neg.and ha.neg) ha.neg hAs hBs)
        (isUTyped_case5Rhs hq.neg ha.neg hAs hBs)))

/-- Case 7's printed right-hand side mentions `untl` only as `untl B A`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case7RhsPrinted {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsUTyped A B (case7RhsPrinted a q A B) := by
  have hSabq : IsSOnly (USForm.snce (B.and q) a) := IsSOnly.snce (hBs.and hq) ha
  exact IsUTyped.or (isUTyped_case4Rhs ((hAs.and hSabq).and hq) hq hAs hBs)
    (IsUTyped.or (isUTyped_case8RhsPrinted (hAs.and hSabq) hq hAs hBs)
      (IsUTyped.or (IsUTyped.ofIsSOnly (hSabq.and hAs))
        (IsUTyped.and (IsUTyped.ofIsSOnly hSabq)
          (IsUTyped.and (IsUTyped.ofIsSOnly hBs) IsUTyped.untl))))

/-- Case 6's printed right-hand side mentions `untl` only as `untl B A`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one) -/
theorem isUTyped_case6RhsPrinted {a q A B : USForm} (ha : IsSOnly a) (hq : IsSOnly q)
    (hAs : IsSOnly A) (hBs : IsSOnly B) : IsUTyped A B (case6RhsPrinted a q A B) := by
  have hinner : IsSOnly (USForm.snce (q.and A.neg) a) := IsSOnly.snce (hq.and hAs.neg) ha
  have hcore : IsSOnly ((B.neg.and A.neg).and (USForm.snce (q.and A.neg) a)) :=
    (hBs.neg.and hAs.neg).and hinner
  exact IsUTyped.or
    (IsUTyped.and (IsUTyped.ofIsSOnly hinner)
      (IsUTyped.and (IsUTyped.ofIsSOnly hAs.neg)
        (IsUTyped.neg (IsUTyped.and (IsUTyped.ofIsSOnly hBs) IsUTyped.untl))))
    (IsUTyped.or (isUTyped_case3RhsPrinted (hcore.and hq) hq hAs hBs)
      (isUTyped_case5Rhs hcore hq hAs hBs))

/-! ## The `untl`-literal normal form -/

/--
Replace every occurrence of the `untl` formula `D` by `p`. Under `IsUTyped A B` at
`D := untl B A` the recursion is complete: it never has to enter a `snce` subformula, because
those are `untl`-free, and it never meets an `untl` other than `D`.
-/
def substU (D p : USForm) : USForm → USForm
  | .leaf i => .leaf i
  | .bot => .bot
  | .imp φ ψ => .imp (substU D p φ) (substU D p ψ)
  | .untl ψ φ => if USForm.untl ψ φ = D then p else USForm.untl ψ φ
  | .snce ψ φ => USForm.snce ψ φ

/--
**The substitution's truth preservation.** Substituting a formula that agrees with `untl B A`
*at the evaluation point* preserves truth there. One point suffices because the recursion
descends only through `imp`, which is evaluated locally.

Paper: — (formalization-native; the manuscript's normal-form step has no substitution lemma
because it works with atoms)
-/
theorem usTruth_substU {A B p : USForm} {φ : USForm} (h : IsUTyped A B φ)
    (v : ℕ → ℤ → Prop) (t : ℤ)
    (hp : usTruth v t p ↔ usTruth v t (USForm.untl B A)) :
    usTruth v t (substU (USForm.untl B A) p φ) ↔ usTruth v t φ := by
  induction h with
  | leaf i => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    simp only [substU, usTruth_imp_iff]
    exact imp_congr ihφ ihψ
  | untl => simpa [substU] using hp
  | snce hψ hφ => exact Iff.rfl

/--
**The substitution's `untl`-freeness.** Substituting an `untl`-free formula into an
`(A,B)`-typed one removes the last `untl`, which is what makes the four case parameters below
`IsSOnly`.

Paper: — (formalization-native)
-/
theorem isSOnly_substU {A B p : USForm} (hp : IsSOnly p) {φ : USForm} (h : IsUTyped A B φ) :
    IsSOnly (substU (USForm.untl B A) p φ) := by
  induction h with
  | leaf i => exact IsSOnly.leaf i
  | bot => exact IsSOnly.bot
  | imp _ _ ihφ ihψ => exact IsSOnly.imp ihφ ihψ
  | untl => simpa [substU] using hp
  | snce hψ hφ => exact IsSOnly.snce hψ hφ

/--
**The event's disjunctive split**: `C ↔ (Cᵁ ∧ U) ∨ (C⁰ ∧ ¬U)`, pointwise at every valuation and
time. This is the content GHR's disjunctive normal form supplies for the event argument,
specialized to the one literal that matters.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_event_split {A B C : USForm} (hC : IsUTyped A B C)
    (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t C ↔ usTruth v t
      (((substU (USForm.untl B A) USForm.top C).and (USForm.untl B A)).or
        ((substU (USForm.untl B A) USForm.bot C).and (USForm.untl B A).neg)) := by
  simp only [usTruth_or_iff, usTruth_and_iff, usTruth_neg_iff]
  by_cases hU : usTruth v t (USForm.untl B A)
  · have h := usTruth_substU hC v t (p := USForm.top)
      ⟨fun _ => hU, fun _ => usTruth_top v t⟩
    constructor
    · intro hC' ; exact Or.inl ⟨h.mpr hC', hU⟩
    · rintro (⟨hCU, -⟩ | ⟨-, hnU⟩)
      · exact h.mp hCU
      · exact absurd hU hnU
  · have h := usTruth_substU hC v t (p := USForm.bot)
      ⟨fun hb => absurd hb (usTruth_bot v t), fun hu => absurd hu hU⟩
    constructor
    · intro hC' ; exact Or.inr ⟨h.mpr hC', hU⟩
    · rintro (⟨-, hu⟩ | ⟨hCN, -⟩)
      · exact absurd hu hU
      · exact h.mp hCN

/--
**The guard's conjunctive split**: `F ↔ (Fᵁ ∨ ¬U) ∧ (F⁰ ∨ U)`, pointwise. The conjunctive
counterpart of `usTruth_event_split`, and what GHR's conjunctive normal form supplies for the
guard argument.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_guard_split {A B F : USForm} (hF : IsUTyped A B F)
    (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t F ↔ usTruth v t
      (((substU (USForm.untl B A) USForm.top F).or (USForm.untl B A).neg).and
        ((substU (USForm.untl B A) USForm.bot F).or (USForm.untl B A))) := by
  simp only [usTruth_and_iff, usTruth_or_iff, usTruth_neg_iff]
  by_cases hU : usTruth v t (USForm.untl B A)
  · have h := usTruth_substU hF v t (p := USForm.top)
      ⟨fun _ => hU, fun _ => usTruth_top v t⟩
    constructor
    · intro hF' ; exact ⟨Or.inl (h.mpr hF'), Or.inr hU⟩
    · rintro ⟨hl | hl, -⟩
      · exact h.mp hl
      · exact absurd hU hl
  · have h := usTruth_substU hF v t (p := USForm.bot)
      ⟨fun hb => absurd hb (usTruth_bot v t), fun hu => absurd hu hU⟩
    constructor
    · intro hF' ; exact ⟨Or.inr hU, Or.inl (h.mpr hF')⟩
    · rintro ⟨-, hr | hr⟩
      · exact h.mp hr
      · exact absurd hr hU

/-! ## GHR Lemma 10.2.4 -/

/--
The separated equivalent of `snce F C`, as the four-instance split produces it: Cases 7 and 5 on
the `U`-branch of the event, Cases 8 and 6 on the `¬U`-branch, each at the parameters tabulated
in the module docstring.
-/
def sepSnce (A B C F : USForm) : USForm :=
  ((case7RhsPrinted (substU (USForm.untl B A) USForm.top C)
      (substU (USForm.untl B A) USForm.top F) A B).and
    (case5Rhs (substU (USForm.untl B A) USForm.top C)
      (substU (USForm.untl B A) USForm.bot F) A B)).or
  ((case8RhsPrinted (substU (USForm.untl B A) USForm.bot C)
      (substU (USForm.untl B A) USForm.top F) A B).and
    (case6RhsPrinted (substU (USForm.untl B A) USForm.bot C)
      (substU (USForm.untl B A) USForm.bot F) A B))

/--
**GHR Lemma 10.2.4**, the equivalence half: a `snce` both of whose arguments are `(A,B)`-typed is
equivalent to `sepSnce A B C F` at every leaf valuation and every time.

The proof is the normal form of the module docstring followed by GHR 10.2.1's two
distributivities and then the four hard cases, in that order. No case is applied twice and no
clause is left over.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem usTruth_sepSnce {A B C F : USForm} (hC : IsUTyped A B C) (hF : IsUTyped A B F)
    (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (USForm.snce F C) ↔ usTruth v t (sepSnce A B C F) := by
  refine (usTruth_snce_congr (fun w r => usTruth_guard_split hF w r)
    (fun w r => usTruth_event_split hC w r) v t).trans ?_
  rw [sepSnce]
  simp only [usTruth_or_iff, usTruth_and_iff]
  rw [usTruth_snce_or_event, usTruth_or_iff, usTruth_snce_and_guard, usTruth_snce_and_guard,
    usTruth_and_iff, usTruth_and_iff]
  exact or_congr (and_congr (usTruth_case7_printed _ _ A B v t) (usTruth_case5 _ _ A B v t))
    (and_congr (usTruth_case8_printed _ _ A B v t) (usTruth_case6_printed _ _ A B v t))

/--
**GHR Lemma 10.2.4**, the separatedness half: `sepSnce A B C F` is syntactically separated. This
is a proved witness, not a prose claim.

The four hypotheses on `A` and `B` are GHR's standing "`A` and `B` are wffs in which `U` and `S`
do not appear", split into its `IsSOnly` and `IsUOnly` halves. The two hypotheses on `C` and `F`
are the weaker `IsUTyped` precondition, never `IsSeparated`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem isSeparated_sepSnce {A B C F : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B)
    (hAu : IsUOnly A) (hBu : IsUOnly B) (hC : IsUTyped A B C) (hF : IsUTyped A B F) :
    IsSeparated (sepSnce A B C F) := by
  have hCU : IsSOnly (substU (USForm.untl B A) USForm.top C) := isSOnly_substU IsSOnly.top hC
  have hCN : IsSOnly (substU (USForm.untl B A) USForm.bot C) := isSOnly_substU IsSOnly.bot hC
  have hFU : IsSOnly (substU (USForm.untl B A) USForm.top F) := isSOnly_substU IsSOnly.top hF
  have hFN : IsSOnly (substU (USForm.untl B A) USForm.bot F) := isSOnly_substU IsSOnly.bot hF
  exact IsSeparated.or
    (IsSeparated.and (isSeparated_case7RhsPrinted hCU hFU hAs hBs hAu hBu)
      (isSeparated_case5Rhs hCU hFN hAs hBs hAu hBu))
    (IsSeparated.and (isSeparated_case8RhsPrinted hCN hFU hAs hBs hAu hBu)
      (isSeparated_case6RhsPrinted hCN hFN hAs hBs hAu hBu))

/--
**GHR Lemma 10.2.4**, the typedness half: in `sepSnce A B C F`, `untl` occurs only as the single
type `untl B A`. This is the conclusion clause "in which `U` only appears as the formula
`U(A,B)`", as a proved witness rather than a prose claim.

It needs only the two `IsSOnly` hypotheses on `A` and `B`, never the `IsUOnly` halves and never
`IsSeparated` at an input position: typedness of the four case parameters comes from
`isSOnly_substU`, and each of the four right-hand sides the clean route uses carries its own
`isUTyped_*` witness.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no separation
theorem and carries no label for one)
-/
theorem isUTyped_sepSnce {A B C F : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B)
    (hC : IsUTyped A B C) (hF : IsUTyped A B F) : IsUTyped A B (sepSnce A B C F) := by
  have hCU : IsSOnly (substU (USForm.untl B A) USForm.top C) := isSOnly_substU IsSOnly.top hC
  have hCN : IsSOnly (substU (USForm.untl B A) USForm.bot C) := isSOnly_substU IsSOnly.bot hC
  have hFU : IsSOnly (substU (USForm.untl B A) USForm.top F) := isSOnly_substU IsSOnly.top hF
  have hFN : IsSOnly (substU (USForm.untl B A) USForm.bot F) := isSOnly_substU IsSOnly.bot hF
  exact IsUTyped.or
    (IsUTyped.and (isUTyped_case7RhsPrinted hCU hFU hAs hBs)
      (isUTyped_case5Rhs hCU hFN hAs hBs))
    (IsUTyped.and (isUTyped_case8RhsPrinted hCN hFU hAs hBs)
      (isUTyped_case6RhsPrinted hCN hFN hAs hBs))

end FormalSystem.Metalogic.Expressiveness.SeparationZ
