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
content of "strictly weaker". Producing Lemma 10.2.5's separated form is the work of `sepU`
below, not a closure property of this predicate.

## Lemma 10.2.5 in full, and the induction that is deliberately not formalized

`sepU`, `usTruth_sepU`, `isSeparated_sepU` and `isUTyped_sepU` are GHR Lemma 10.2.5 in full:
the equivalence, the separatedness of the equivalent, and its conclusion's remaining clause
that in the equivalent "`U` only appears as the formula `U(A, B)`".

GHR prove the lemma "by induction on the maximum number k of nested Ss above any U(A, B)". That
induction is **deliberately not formalized**: `sepU` is a plain structural recursion over
`USForm`, with no depth measure, no decision procedure for whether a subformula contains an
`untl`, and no one-level rewriting operator.
The structural recursion reaches the same conclusion because the two landed halves of
Lemma 10.2.4 chain at every `snce` node — `usTruth_sepSnce` supplies the equivalence and
`isUTyped_sepSnce` supplies the typedness the node above then requires as its own hypothesis —
so the nested-`S` depth never has to be measured, only recursed through.

## Main Results

- `IsUSingleType`: GHR Lemma 10.2.5's input hypothesis
- `IsUSingleType.ofIsSOnly`, `.neg`, `.and`, `.or`: the Boolean closure lemmas
- `isUSingleType_of_isUTyped`: the one-way implication from `NormalForm.lean`'s predicate
- `not_isUTyped_snce_untl`, `isUSingleType_snce_untl`: the strictness, proved at one formula
- `sepU`: the separated form of a single-`untl`-type formula
- `isUTyped_sepU`, `usTruth_sepU`, `isSeparated_sepU`: GHR Lemma 10.2.5's three conclusions

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

/-! ## GHR Lemma 10.2.5 by structural recursion -/

/--
The **separated form of a single-`untl`-type formula**: GHR Lemma 10.2.5's construction, by plain
structural recursion over `USForm`.

**Why the `untl` equation is the identity.** Under `IsUSingleType A B` the only `untl` node is
`untl B A`, so this equation needs no case analysis, no decidable-equality test and no
`sepU A B A = A` lemma: `IsUTyped.untl` applies to the returned node directly. A decidable
equality test here has reconstructed a case analysis the precondition already supplies.

**The `snce`/`sepSnce` argument crossing.** `USForm.snce` takes the **guard first and the event
second**, while `sepSnce A B C F` takes the **event `C` first and the guard `F` second**, so the
two arguments cross at the `snce` equation. `usTruth_sepSnce`'s own statement,
`usTruth v t (USForm.snce F C) ↔ usTruth v t (sepSnce A B C F)`, is the authority on that
crossing; an uncrossed transcription typechecks and is wrong.

This is a plain `def`, deliberately not `noncomputable`: the downstream ZTime translation's
executability deliverable consumes it transitively.
-/
def sepU (A B : USForm) : USForm → USForm
  | .leaf i => .leaf i
  | .bot => .bot
  | .imp φ ψ => .imp (sepU A B φ) (sepU A B ψ)
  | .untl ψ φ => .untl ψ φ
  | .snce ψ φ => sepSnce A B (sepU A B φ) (sepU A B ψ)

/--
**GHR Lemma 10.2.5**, the typedness half: in the separated equivalent, `untl` occurs only as
`untl B A`.

This is proved **before** the equivalence, because it supplies the hypotheses `usTruth_sepSnce`
demands at every `snce` node.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.5 (the conclusion's "`U` only appears as the formula
`U(A, B)`" clause)
-/
theorem isUTyped_sepU {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B) {φ : USForm}
    (h : IsUSingleType A B φ) : IsUTyped A B (sepU A B φ) := by
  induction h with
  | leaf i => exact IsUTyped.leaf i
  | bot => exact IsUTyped.bot
  | imp _ _ ihφ ihψ => exact IsUTyped.imp ihφ ihψ
  | untl => exact IsUTyped.untl
  | snce _ _ ihψ ihφ => exact isUTyped_sepSnce hAs hBs ihφ ihψ

/--
**GHR Lemma 10.2.5**, the equivalence half: a formula whose only `untl` type is `untl B A` is
equivalent to its separated form at every leaf valuation and every time.

The `snce` case chains `usTruth_snce_congr` at the two induction hypotheses with
`usTruth_sepSnce` at the `isUTyped_sepU` witnesses; Lemma 10.2.4 is cited, never re-derived here.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.5 (the equivalence)
-/
theorem usTruth_sepU {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B) {φ : USForm}
    (h : IsUSingleType A B φ) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (sepU A B φ) ↔ usTruth v t φ := by
  induction h generalizing v t with
  | leaf i => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    change (usTruth v t (sepU A B _) → usTruth v t (sepU A B _)) ↔ _
    exact imp_congr (ihφ v t) (ihψ v t)
  | untl => exact Iff.rfl
  | snce hψ hφ ihψ ihφ =>
    exact ((usTruth_sepSnce (isUTyped_sepU hAs hBs hφ) (isUTyped_sepU hAs hBs hψ) v t).symm).trans
      (usTruth_snce_congr (fun w r => ihψ w r) (fun w r => ihφ w r) v t)

/--
**GHR Lemma 10.2.5**, the separatedness half: the equivalent is syntactically separated.

A one-line composite of `isSeparated_of_isUTyped` and `isUTyped_sepU` — not a second induction,
which would be a sign the typedness lemma had been stated too weakly. The two `IsUOnly`
hypotheses are GHR's standing "`A` and `B` are wffs built without `S` or `U`".

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.5 (the conclusion's separatedness)
-/
theorem isSeparated_sepU {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A)
    (hBu : IsUOnly B) {φ : USForm} (h : IsUSingleType A B φ) : IsSeparated (sepU A B φ) :=
  isSeparated_of_isUTyped hAu hBu (isUTyped_sepU hAs hBs h)

end FormalSystem.Metalogic.Expressiveness.SeparationZ
