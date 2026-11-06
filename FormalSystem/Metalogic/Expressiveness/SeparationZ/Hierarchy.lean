/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.NormalForm

/-!
# GHR Lemma 10.2.5's input hypothesis — one `untl` type, nesting unconstrained

[GHR][gabbay1994] vol. 1, Lemma 10.2.5 reads, verbatim:

> Suppose that A and B are wffs built without S or U and that the only appearance of U in the wff
> D is as U(A, B). Then D is equivalent to a syntactically separated wff in which U only appears
> as the formula U(A, B).

The phrase "the only appearance of U ... is as U(A, B)" places **no restriction on nesting**: the
single admitted `untl` type may sit under arbitrarily many `snce` nodes, and removing exactly
those nestings is what the lemma is for. `IsUSingleType` below is that hypothesis.

## Why `NormalForm.lean`'s `IsUTyped` cannot serve at this input position

`IsUTyped A B` admits a `snce` only through
`snce {ψ φ} : IsSOnly ψ → IsSOnly φ → IsUTyped A B (USForm.snce ψ φ)`, i.e. only when both
arguments are `untl`-free. That forbids precisely the `untl`-under-`snce` configuration
Lemma 10.2.5 exists to remove, so handing 10.2.5 that hypothesis would make it vacuous at every
input it is for. `IsUSingleType` differs from `IsUTyped` in exactly one constructor: its `snce`
recurses rather than demanding `IsSOnly` of its two arguments.

`IsUSingleType` is therefore **strictly weaker** than `IsUTyped`, and the two are not
interchangeable at an input position. The implication runs one way only
(`isUSingleType_of_isUTyped`), and the converse is refuted here rather than claimed in prose:
`not_isUTyped_snce_untl` and `isUSingleType_snce_untl` exhibit the gap at the single concrete
formula `S(⊥, U(A,B))`. The ruling of `NormalForm.lean`'s module docstring — an input position
asking for a stronger predicate than the step needs is a defect, not a strengthening — applies
verbatim one predicate further out.

## There is deliberately no `isSeparated_of_isUSingleType`

`NormalForm.lean:179`'s `isSeparated_of_isUTyped` has **no** counterpart here, and none can
exist: a `snce` carrying an `untl` argument is not syntactically separated, which is the precise
content of "strictly weaker". Producing Lemma 10.2.5's separated form is the work of `sepU`, not
a closure property of this predicate — see the `Hierarchy`-consuming layer for that construction.

## Main Results

- `IsUSingleType`: GHR Lemma 10.2.5's input hypothesis
- `IsUSingleType.ofIsSOnly`, `.neg`, `.and`, `.or`: the Boolean closure lemmas
- `isUSingleType_of_isUTyped`: the one-way implication from `NormalForm.lean`'s predicate
- `not_isUTyped_snce_untl`, `isUSingleType_snce_untl`: the strictness, proved at one formula

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemma 10.2.5
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## GHR 10.2.5's precondition -/

/--
`φ` is **of single `untl` type `(A,B)`**: every `untl` occurring in `φ` is the single type
`untl B A`, with nesting otherwise unconstrained. This is GHR Lemma 10.2.5's input hypothesis,
quoted in full in the module docstring.

It is **strictly weaker** than `NormalForm.lean`'s `IsUTyped A B`, whose `snce` constructor
additionally demands that both arguments be `untl`-free. That restriction forbids exactly the
configuration Lemma 10.2.5 removes, so `IsUTyped` must never replace this predicate at an input
position: doing so makes the lemma vacuous at every input it is for. The implication
`isUSingleType_of_isUTyped` runs one way only, and `not_isUTyped_snce_untl` together with
`isUSingleType_snce_untl` refutes the converse at `S(⊥, U(A,B))`.

There is deliberately no `isSeparated_of_isUSingleType` counterpart to `isSeparated_of_isUTyped`,
and none can exist: a `snce` carrying an `untl` argument is not syntactically separated, which is
what "strictly weaker" means here. Producing the separated form is `sepU`'s work, not a closure
property of this predicate.
-/
inductive IsUSingleType (A B : USForm) : USForm → Prop
  /-- Every leaf is of single `untl` type `(A,B)`. -/
  | leaf (i : ℕ) : IsUSingleType A B (.leaf i)
  /-- Bottom is of single `untl` type `(A,B)`. -/
  | bot : IsUSingleType A B .bot
  /-- `imp` preserves the property, carrying `neg`, `and`, `or` and `iff` with it. -/
  | imp {φ ψ : USForm} :
      IsUSingleType A B φ → IsUSingleType A B ψ → IsUSingleType A B (.imp φ ψ)
  /-- The one admitted `untl`. -/
  | untl : IsUSingleType A B (USForm.untl B A)
  /-- A `snce` preserves the property: this is the one and only difference from `IsUTyped`,
  whose `snce` constructor demands `IsSOnly` of both arguments instead of recursing. -/
  | snce {ψ φ : USForm} :
      IsUSingleType A B ψ → IsUSingleType A B φ → IsUSingleType A B (USForm.snce ψ φ)

namespace IsUSingleType

variable {A B : USForm}

/-- An `untl`-free formula is of single `untl` type `(A,B)` for every `A` and `B`. -/
theorem ofIsSOnly {φ : USForm} (h : IsSOnly φ) : IsUSingleType A B φ := by
  induction h with
  | leaf i => exact IsUSingleType.leaf i
  | bot => exact IsUSingleType.bot
  | imp _ _ ihφ ihψ => exact IsUSingleType.imp ihφ ihψ
  | snce _ _ ihψ ihφ => exact IsUSingleType.snce ihψ ihφ

/-- Negation preserves single `untl` typedness. -/
theorem neg {φ : USForm} (h : IsUSingleType A B φ) : IsUSingleType A B φ.neg :=
  IsUSingleType.imp h IsUSingleType.bot

/-- Conjunction preserves single `untl` typedness. -/
theorem and {φ ψ : USForm} (hφ : IsUSingleType A B φ) (hψ : IsUSingleType A B ψ) :
    IsUSingleType A B (φ.and ψ) :=
  (IsUSingleType.imp hφ hψ.neg).neg

/-- Disjunction preserves single `untl` typedness. -/
theorem or {φ ψ : USForm} (hφ : IsUSingleType A B φ) (hψ : IsUSingleType A B ψ) :
    IsUSingleType A B (φ.or ψ) :=
  IsUSingleType.imp hφ.neg hψ

end IsUSingleType

/--
**The one-way implication.** GHR Lemma 10.2.4's precondition implies Lemma 10.2.5's: relaxing the
`snce` constructor from "both arguments `untl`-free" to "both arguments recursively of single
`untl` type" only admits more formulas. The `snce` case goes through `IsUSingleType.ofIsSOnly` at
each argument.

The converse fails — see `not_isUTyped_snce_untl` and `isUSingleType_snce_untl`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no
separation theorem and carries no label for one)
-/
theorem isUSingleType_of_isUTyped {A B φ : USForm} (h : IsUTyped A B φ) :
    IsUSingleType A B φ := by
  induction h with
  | leaf i => exact IsUSingleType.leaf i
  | bot => exact IsUSingleType.bot
  | imp _ _ ihφ ihψ => exact IsUSingleType.imp ihφ ihψ
  | untl => exact IsUSingleType.untl
  | snce hψ hφ => exact IsUSingleType.snce (IsUSingleType.ofIsSOnly hψ) (IsUSingleType.ofIsSOnly hφ)

/-! ## The strictness, proved at one concrete formula

`S(⊥, U(A,B))` — a `snce` whose event argument is the single admitted `untl` — separates the two
predicates. The pair below is the proof that `IsUSingleType` is *strictly* weaker than
`IsUTyped`, so no later reader takes the direction of `isUSingleType_of_isUTyped` on trust. -/

/-- `IsUTyped` rejects `S(⊥, U(A,B))`: its `snce` constructor demands `IsSOnly (untl B A)`, and
`IsSOnly` has no `untl` constructor.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no
separation theorem and carries no label for one) -/
theorem not_isUTyped_snce_untl {A B : USForm} :
    ¬ IsUTyped A B (USForm.snce USForm.bot (USForm.untl B A)) := by
  intro h
  cases h with
  | snce _ hφ => cases hφ

/-- `IsUSingleType` accepts `S(⊥, U(A,B))`, which with `not_isUTyped_snce_untl` exhibits the gap
between the two predicates at one formula.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no
separation theorem and carries no label for one) -/
theorem isUSingleType_snce_untl {A B : USForm} :
    IsUSingleType A B (USForm.snce USForm.bot (USForm.untl B A)) :=
  IsUSingleType.snce IsUSingleType.bot IsUSingleType.untl

end FormalSystem.Metalogic.Expressiveness.SeparationZ
