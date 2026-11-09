/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.UNesting

/-!
# Junction depth, GHR Lemma 10.2.8 and the Separation Theorem over `ℤ`

[GHR][gabbay1994] vol. 1, Lemma 10.2.8 reads, verbatim:

> Any wff of the language with U and S is syntactically separable over the integer flow of time.

Theorem 10.2.9 is its restatement as the Separation Theorem over the integers. GHR define
*junction depth* occurrence-wise, through chains `C₁, …, Cₙ` of subformulae in which each `Cᵢ` is
a subformula of `Cᵢ₊₁`, each is an Until or a Since, and the kinds **alternate**; the junction
depth of a wff is the maximum over its appearances. Their proof inducts on it: at depth zero or
one the formula is already separated; above that, a `snce`-headed formula has `snce` subformulae
inside its maximal `untl`s, each maximal such subformula is abstracted to a fresh atom, the result
is separated by Lemma 10.2.7, and resubstituting gives an equivalent formula "of one less junction
depth". The `untl`-headed case is handled by duality: "because of the dual nature of the results
so far we need only demonstrate the syntactic separation of a wff of the form `S(D₁, D₂)`".

## The measure

Occurrence-level chains have no direct Lean counterpart, so the measure is restated structurally
as a mutual recursion: `jdU φ` is the length of the longest alternating chain in `φ` whose
outermost member is an `untl`, and `jdS φ` likewise for `snce`. At an `untl` node, `jdU` takes
the larger of "count this node as the chain's outermost member, and continue with a `snce`-headed
chain inside either argument" and "skip it"; at a `snce` node it only skips. `jdS` is the mirror
image, and `junctionDepth φ = max (jdU φ) (jdS φ)`. The "skip" branch is what makes this the
maximum over *all* appearances rather than over root-anchored chains alone. The definition is
checked against GHR's own worked example before anything is proved about it:
`junctionDepth_ghrExample` computes the source's stated value `3` for
`S(a ∧ U(A, S(C, D)), S(S(C, D), E))`, and `junctionDepth_ghrExample_right` the stated value `1`
for its right conjunct `S(S(C, D), E)`.

Two consequences carry the whole development: `jdS φ = 0 ↔ IsUOnly φ` and
`jdU φ = 0 ↔ IsSOnly φ` (every temporal node contributes at least `1` to its own measure), from
which `junctionDepth φ ≤ 1 ↔ IsSeparated φ` (`isSeparated_of_junctionDepth_le_one`, GHR's base
case, and its converse `junctionDepth_le_one_of_isSeparated`); and
`NoSnceUnderUntl φ → junctionDepth φ ≤ 2`, since a chain of length three is `U, S, U` or
`S, U, S` and both put an `S` beneath a `U`.

## The duality instruments

`jdU_swap`, `jdS_swap` and `junctionDepth_swap` show the measure is exchanged, hence preserved,
by the landed time reflection `USForm.swap`; `isSeparated_swap` shows separatedness is preserved.
GHR 10.2.7 is not self-dual — it constrains `S` under `U` — so its conjugate is a real obligation
and is landed as its own result: `NoUntlUnderSnce φ` is `NoSnceUnderUntl φ.swap`, and `sep7Dual`
with `isSeparated_sep7Dual` and `usTruth_sep7Dual` is the conjugated lemma, obtained from `sep7`
by `swap`, `swap_involutive` and `usTruth_swap` alone.

## The abstraction, and why it is `mapU` at a conjugated `mapU`

GHR abstract "the maximal `S` subformulae inside the maximal `U`s". The maximal `untl`s are
`uTypes φ`, which `mapU` reaches. Inside such an `untl`'s arguments the maximal `snce`s are those
not contained in another `snce`, and they may sit beneath further `untl`s — so the inner pass must
descend through `untl` and stop at `snce`, which is the mirror image of `mapU`. The landed `mapS`
is **not** that mirror: it stops at `untl` without descending, so it reaches only the
Boolean-level `snce`s and would leave `snce bot (untl bot (untl bot (snce bot p)))` — of junction
depth three — unabstracted and `sep7` inapplicable to it. The mirror is therefore taken as the
`swap`-conjugate of the landed operator,
`mapSDeep k φ = (mapU (fun u => (k u.swap).swap) φ.swap).swap`, whose five equations
`mapSDeep_leaf` … `mapSDeep_snce` are all that is ever used of it. No new
substitution operator is defined: `mapU`, `substLeaf`, `abstrFn` and `unabstrFn` are the landed
ones, used verbatim, and `abstrSnceArgs` is `mapU`'s argument exactly as `abstrArgs` is in
`UNesting.lean`. The collection of what is abstracted is the mirror API `sTypes` / `argSTypes` /
`innerSTypes`, the `snce`-side analogue of `uTypes` / `argUTypes` / `innerTypes`.

## The strict decrease, in three parts

Three obligations, each its own named result, none standing in for another:

- **(a)** `junctionDepth_mapU_abstrSnceArgs_le_two`: the abstracted formula satisfies
  `NoSnceUnderUntl` (`noSnceUnderUntl_mapU_abstrSnceArgs`), so its junction depth is at most two.
  The drop is strict exactly when the input's depth exceeds two
  (`junctionDepth_mapU_abstrSnceArgs_lt`); at depth two the abstraction leaves the measure where it
  is, and the step below still closes because what licenses the recursive call is part (c), not
  part (a).
- **(b)** `junctionDepth_sep7_le_one`: separation by 10.2.7 does not raise the measure. There is
  no landed counterpart and neither `uTypes_sepMulti` nor `untlDepth` transfers — but none is
  needed, because a separated formula has junction depth at most one outright.
- **(c)** `junctionDepth_sep8Step_snce_le`: for a `snce`-headed formula of junction depth `n ≥ 2`,
  the reindexed form has junction depth at most `n - 1`. GHR leave this implicit entirely; "of one
  less junction depth" is the whole of their argument. The proof is four substitution bounds
  (`jdS_substLeaf_le_of_isUOnly`, `jdU_substLeaf_le_of_isUOnly` and their `IsSOnly` mirrors),
  combined over a separated formula's three node kinds in `jd_substLeaf_le_of_isSeparated`, and
  two bounds on the abstracted list: every member `E` has `jdS E < jdU φ`
  (`jdS_lt_jdU_of_mem_innerSTypes`, since `E` sits inside a maximal `untl` of `φ`) and
  `jdU E + 2 ≤ jdU φ` (`jdU_add_two_le_jdU_of_mem_innerSTypes`, since `E` is `snce`-headed).
  These give `junctionDepth ≤ max (jdU φ) 1` for the reindexed form
  (`junctionDepth_substLeaf_unabstrFn_le`), which is `≤ n - 1` **only because `φ` is
  `snce`-headed**, where `jdU φ < jdS φ = n`. For a formula with `jdU φ = jdS φ` the bound is not
  strict, and such formulae exist at every depth `≥ 2` (a conjunction of an `untl`-headed and a
  `snce`-headed formula of equal depth). GHR's duality reduction is therefore a *precondition* of
  the bound rather than a convenience: the step must be applied at maximal temporal nodes, whose
  head kind forces the inequality, and the recursion below is shaped accordingly.

## The recursion

`sep8Body k` descends through the Boolean skeleton and, at each maximal temporal node, either
returns it unchanged (junction depth at most one, hence separated) or fires the recursive call `k`
at the reindexed form — `sep8Step` at a `snce` head, its conjugate `sep8StepDual` at an `untl`
head. `sep8Fuel` is structural on an explicit `ℕ` budget and `sep` instantiates the budget at the
measure, so the budget appears in no public statement. This is the budget idiom `Hierarchy.lean`
validates at Lemma 10.2.6 and `UNesting.lean` repeats at 10.2.7, for the reason recorded there:
the recursive call is fired at a formula that is not a subterm of the definition's argument, so
no `decreasing_by` goal can be stated for it. `sep` is a plain
`def` with no `noncomputable` keyword.

## Main Definitions

- `jdU`, `jdS`, `junctionDepth`: the junction-depth measure, as a mutual structural recursion
- `sTypes`, `argSTypes`, `innerSTypes`: the maximal `snce` subformulae, and those inside the
  maximal `untl`s
- `mapSDeep`, `abstrSnceArgs`: the abstraction of the inner `snce`s, through the landed operators
- `NoUntlUnderSnce`, `sep7Dual`: the conjugate of GHR 10.2.7's hypothesis and construction
- `sep8Step`, `sep8StepDual`, `sep8Body`, `sep8Fuel`, `sep`: GHR 10.2.8's construction in the
  budget idiom, and the Separation Theorem's separating function

## Main Results

- `junctionDepth_ghrExample`, `junctionDepth_ghrExample_right`: the measure agrees with GHR's
  worked example
- `isSeparated_of_junctionDepth_le_one`, `junctionDepth_le_one_of_isSeparated`: GHR's base case
  and its converse
- `jdU_swap`, `jdS_swap`, `junctionDepth_swap`, `isSeparated_swap`, `isSeparated_sep7Dual`,
  `usTruth_sep7Dual`: the duality instruments
- `junctionDepth_mapU_abstrSnceArgs_le_two`, `junctionDepth_sep7_le_one`,
  `junctionDepth_sep8Step_snce_le`: parts (a), (b) and (c) of the strict-decrease obligation
- `sep8Fuel_spec`, `isSeparated_sep`, `usTruth_sep_iff`: GHR Lemma 10.2.8 and Theorem 10.2.9

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemma 10.2.8 and Theorem 10.2.9
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## The junction-depth measure -/

mutual
/--
The longest alternating chain of nested temporal subformulae whose **outermost member is an
`untl`**, as a length; `0` when there is none. At an `untl` node the chain may either start here
and continue with a `snce`-headed chain inside an argument, or skip this node.
-/
def jdU : USForm → ℕ
  | .leaf _ => 0
  | .bot => 0
  | .imp φ ψ => max (jdU φ) (jdU ψ)
  | .untl ψ φ => max (1 + max (jdS ψ) (jdS φ)) (max (jdU ψ) (jdU φ))
  | .snce ψ φ => max (jdU ψ) (jdU φ)

/--
The longest alternating chain of nested temporal subformulae whose **outermost member is a
`snce`**, as a length; `0` when there is none. The mirror image of `jdU`.
-/
def jdS : USForm → ℕ
  | .leaf _ => 0
  | .bot => 0
  | .imp φ ψ => max (jdS φ) (jdS ψ)
  | .untl ψ φ => max (jdS ψ) (jdS φ)
  | .snce ψ φ => max (1 + max (jdU ψ) (jdU φ)) (max (jdS ψ) (jdS φ))
end

/--
GHR's **junction depth**: the length of the longest chain of nested temporal subformulae of
alternating kinds, taken over every appearance. This is the measure Lemma 10.2.8's induction runs
on and the quantity `sep8Fuel` consumes as its budget.
-/
def junctionDepth (φ : USForm) : ℕ := max (jdU φ) (jdS φ)

@[simp] theorem jdU_leaf (i : ℕ) : jdU (USForm.leaf i) = 0 := rfl

@[simp] theorem jdU_bot : jdU USForm.bot = 0 := rfl

@[simp] theorem jdU_imp (φ ψ : USForm) : jdU (USForm.imp φ ψ) = max (jdU φ) (jdU ψ) := rfl

@[simp] theorem jdU_untl (ψ φ : USForm) :
    jdU (USForm.untl ψ φ) = max (1 + max (jdS ψ) (jdS φ)) (max (jdU ψ) (jdU φ)) := rfl

@[simp] theorem jdU_snce (ψ φ : USForm) : jdU (USForm.snce ψ φ) = max (jdU ψ) (jdU φ) := rfl

@[simp] theorem jdS_leaf (i : ℕ) : jdS (USForm.leaf i) = 0 := rfl

@[simp] theorem jdS_bot : jdS USForm.bot = 0 := rfl

@[simp] theorem jdS_imp (φ ψ : USForm) : jdS (USForm.imp φ ψ) = max (jdS φ) (jdS ψ) := rfl

@[simp] theorem jdS_untl (ψ φ : USForm) : jdS (USForm.untl ψ φ) = max (jdS ψ) (jdS φ) := rfl

@[simp] theorem jdS_snce (ψ φ : USForm) :
    jdS (USForm.snce ψ φ) = max (1 + max (jdU ψ) (jdU φ)) (max (jdS ψ) (jdS φ)) := rfl

/-! ### GHR's worked example

The source states that in `S(a ∧ U(A, S(C, D)), S(S(C, D), E))` the first appearance of `C` has
junction depth 3, the second has 1, and the whole formula has junction depth 3. In this subtree's
guard-first order GHR's `S(X, Y)` is `snce Y X` and `U(X, Y)` is `untl Y X`; the leaves are
`a = 0`, `A = 1`, `C = 2`, `D = 3`, `E = 4`. -/

/-- GHR's `S(C, D)`, with `C = leaf 2` and `D = leaf 3`. -/
def ghrSCD : USForm := USForm.snce (.leaf 3) (.leaf 2)

/-- GHR's worked example `S(a ∧ U(A, S(C, D)), S(S(C, D), E))`. -/
def ghrExample : USForm :=
  USForm.snce (USForm.snce (.leaf 4) ghrSCD) ((USForm.leaf 0).and (USForm.untl ghrSCD (.leaf 1)))

/-- The measure agrees with the source: the whole formula has junction depth `3`.

Paper: — (GHR vol. 1, §10.2's worked example of junction depth; the manuscript states no
separation theorem) -/
theorem junctionDepth_ghrExample : junctionDepth ghrExample = 3 := by decide

/-- The two chains separately: `jdU` is `2` (the `U` with the first `S(C, D)` inside it) and `jdS`
is `3` (the outer `S` above that `U`). -/
theorem jd_ghrExample : jdU ghrExample = 2 ∧ jdS ghrExample = 3 := by decide

/-- The right conjunct `S(S(C, D), E)`, where the second appearance of `C` sits, has junction
depth `1`, as the source states. -/
theorem junctionDepth_ghrExample_right : junctionDepth (USForm.snce (.leaf 4) ghrSCD) = 1 := by
  decide

/-- The left conjunct's `U(A, S(C, D))`, where the first appearance of `C` sits, has junction
depth `2` on its own; the outer `S` adds the third link. -/
theorem junctionDepth_ghrExample_untl : junctionDepth (USForm.untl ghrSCD (.leaf 1)) = 2 := by
  decide

/-! ### Monotonicity: each immediate subformula measures at most the whole -/

theorem jdU_le_imp_left (φ ψ : USForm) : jdU φ ≤ jdU (USForm.imp φ ψ) := by
  rw [jdU_imp]; omega

theorem jdU_le_imp_right (φ ψ : USForm) : jdU ψ ≤ jdU (USForm.imp φ ψ) := by
  rw [jdU_imp]; omega

theorem jdU_le_untl_left (ψ φ : USForm) : jdU ψ ≤ jdU (USForm.untl ψ φ) := by
  rw [jdU_untl]; omega

theorem jdU_le_untl_right (ψ φ : USForm) : jdU φ ≤ jdU (USForm.untl ψ φ) := by
  rw [jdU_untl]; omega

theorem jdU_le_snce_left (ψ φ : USForm) : jdU ψ ≤ jdU (USForm.snce ψ φ) := by
  rw [jdU_snce]; omega

theorem jdU_le_snce_right (ψ φ : USForm) : jdU φ ≤ jdU (USForm.snce ψ φ) := by
  rw [jdU_snce]; omega

theorem jdS_le_imp_left (φ ψ : USForm) : jdS φ ≤ jdS (USForm.imp φ ψ) := by
  rw [jdS_imp]; omega

theorem jdS_le_imp_right (φ ψ : USForm) : jdS ψ ≤ jdS (USForm.imp φ ψ) := by
  rw [jdS_imp]; omega

theorem jdS_le_untl_left (ψ φ : USForm) : jdS ψ ≤ jdS (USForm.untl ψ φ) := by
  rw [jdS_untl]; omega

theorem jdS_le_untl_right (ψ φ : USForm) : jdS φ ≤ jdS (USForm.untl ψ φ) := by
  rw [jdS_untl]; omega

theorem jdS_le_snce_left (ψ φ : USForm) : jdS ψ ≤ jdS (USForm.snce ψ φ) := by
  rw [jdS_snce]; omega

theorem jdS_le_snce_right (ψ φ : USForm) : jdS φ ≤ jdS (USForm.snce ψ φ) := by
  rw [jdS_snce]; omega

theorem junctionDepth_le_imp_left (φ ψ : USForm) :
    junctionDepth φ ≤ junctionDepth (USForm.imp φ ψ) := by
  simp only [junctionDepth, jdU_imp, jdS_imp]; omega

theorem junctionDepth_le_imp_right (φ ψ : USForm) :
    junctionDepth ψ ≤ junctionDepth (USForm.imp φ ψ) := by
  simp only [junctionDepth, jdU_imp, jdS_imp]; omega

theorem junctionDepth_le_untl_left (ψ φ : USForm) :
    junctionDepth ψ ≤ junctionDepth (USForm.untl ψ φ) := by
  simp only [junctionDepth, jdU_untl, jdS_untl]; omega

theorem junctionDepth_le_untl_right (ψ φ : USForm) :
    junctionDepth φ ≤ junctionDepth (USForm.untl ψ φ) := by
  simp only [junctionDepth, jdU_untl, jdS_untl]; omega

theorem junctionDepth_le_snce_left (ψ φ : USForm) :
    junctionDepth ψ ≤ junctionDepth (USForm.snce ψ φ) := by
  simp only [junctionDepth, jdU_snce, jdS_snce]; omega

theorem junctionDepth_le_snce_right (ψ φ : USForm) :
    junctionDepth φ ≤ junctionDepth (USForm.snce ψ φ) := by
  simp only [junctionDepth, jdU_snce, jdS_snce]; omega

/-! ### The measure at zero and one -/

/-- An `snce`-free formula has no `snce`-headed chain. -/
theorem jdS_eq_zero_of_isUOnly {φ : USForm} (h : IsUOnly φ) : jdS φ = 0 := by
  induction h with
  | leaf i => rfl
  | bot => rfl
  | imp _ _ ihφ ihψ => rw [jdS_imp, ihφ, ihψ]; rfl
  | untl _ _ ihψ ihφ => rw [jdS_untl, ihψ, ihφ]; rfl

/-- An `untl`-free formula has no `untl`-headed chain. -/
theorem jdU_eq_zero_of_isSOnly {φ : USForm} (h : IsSOnly φ) : jdU φ = 0 := by
  induction h with
  | leaf i => rfl
  | bot => rfl
  | imp _ _ ihφ ihψ => rw [jdU_imp, ihφ, ihψ]; rfl
  | snce _ _ ihψ ihφ => rw [jdU_snce, ihψ, ihφ]; rfl

/-- An `snce`-free formula's `untl`-headed chains have length at most one. -/
theorem jdU_le_one_of_isUOnly {φ : USForm} (h : IsUOnly φ) : jdU φ ≤ 1 := by
  induction h with
  | leaf i => rw [jdU_leaf]; omega
  | bot => rw [jdU_bot]; omega
  | imp _ _ ihφ ihψ => rw [jdU_imp]; omega
  | @untl ψ φ hψ hφ ihψ ihφ =>
      rw [jdU_untl, jdS_eq_zero_of_isUOnly hψ, jdS_eq_zero_of_isUOnly hφ]; omega

/-- An `untl`-free formula's `snce`-headed chains have length at most one. -/
theorem jdS_le_one_of_isSOnly {φ : USForm} (h : IsSOnly φ) : jdS φ ≤ 1 := by
  induction h with
  | leaf i => rw [jdS_leaf]; omega
  | bot => rw [jdS_bot]; omega
  | imp _ _ ihφ ihψ => rw [jdS_imp]; omega
  | @snce ψ φ hψ hφ ihψ ihφ =>
      rw [jdS_snce, jdU_eq_zero_of_isSOnly hψ, jdU_eq_zero_of_isSOnly hφ]; omega

/-- Conversely, no `snce`-headed chain means `snce`-free: every `snce` node starts one. -/
theorem isUOnly_of_jdS_eq_zero : ∀ {φ : USForm}, jdS φ = 0 → IsUOnly φ
  | .leaf i, _ => IsUOnly.leaf i
  | .bot, _ => IsUOnly.bot
  | .imp φ ψ, h => by
      rw [jdS_imp] at h
      exact IsUOnly.imp (isUOnly_of_jdS_eq_zero (by omega)) (isUOnly_of_jdS_eq_zero (by omega))
  | .untl ψ φ, h => by
      rw [jdS_untl] at h
      exact IsUOnly.untl (isUOnly_of_jdS_eq_zero (by omega)) (isUOnly_of_jdS_eq_zero (by omega))
  | .snce ψ φ, h => by rw [jdS_snce] at h; omega

/-- Conversely, no `untl`-headed chain means `untl`-free: every `untl` node starts one. -/
theorem isSOnly_of_jdU_eq_zero : ∀ {φ : USForm}, jdU φ = 0 → IsSOnly φ
  | .leaf i, _ => IsSOnly.leaf i
  | .bot, _ => IsSOnly.bot
  | .imp φ ψ, h => by
      rw [jdU_imp] at h
      exact IsSOnly.imp (isSOnly_of_jdU_eq_zero (by omega)) (isSOnly_of_jdU_eq_zero (by omega))
  | .snce ψ φ, h => by
      rw [jdU_snce] at h
      exact IsSOnly.snce (isSOnly_of_jdU_eq_zero (by omega)) (isSOnly_of_jdU_eq_zero (by omega))
  | .untl ψ φ, h => by rw [jdU_untl] at h; omega

/--
**GHR Lemma 10.2.8's base case**: at junction depth at most one every `untl` has `snce`-free
arguments and every `snce` has `untl`-free arguments, which is `IsSeparated` constructor for
constructor.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 (the base case, "if the junction depth is 0 or 1 then
the formula is already separated"); the manuscript states no separation theorem)
-/
theorem isSeparated_of_junctionDepth_le_one : ∀ {φ : USForm}, junctionDepth φ ≤ 1 → IsSeparated φ
  | .leaf i, _ => IsSeparated.leaf i
  | .bot, _ => IsSeparated.bot
  | .imp φ ψ, h => by
      have h1 : junctionDepth φ ≤ 1 := le_trans (junctionDepth_le_imp_left φ ψ) h
      have h2 : junctionDepth ψ ≤ 1 := le_trans (junctionDepth_le_imp_right φ ψ) h
      exact IsSeparated.imp (isSeparated_of_junctionDepth_le_one h1)
        (isSeparated_of_junctionDepth_le_one h2)
  | .untl ψ φ, h => by
      simp only [junctionDepth, jdU_untl, jdS_untl] at h
      exact IsSeparated.untl (isUOnly_of_jdS_eq_zero (by omega)) (isUOnly_of_jdS_eq_zero (by omega))
  | .snce ψ φ, h => by
      simp only [junctionDepth, jdU_snce, jdS_snce] at h
      exact IsSeparated.snce (isSOnly_of_jdU_eq_zero (by omega)) (isSOnly_of_jdU_eq_zero (by omega))

/-- The converse of the base case: a separated formula has junction depth at most one. This is
what makes part (b) of the strict-decrease obligation two lines. -/
theorem junctionDepth_le_one_of_isSeparated {φ : USForm} (h : IsSeparated φ) :
    junctionDepth φ ≤ 1 := by
  induction h with
  | leaf i => simp only [junctionDepth, jdU_leaf, jdS_leaf]; omega
  | bot => simp only [junctionDepth, jdU_bot, jdS_bot]; omega
  | imp _ _ ihφ ihψ =>
      simp only [junctionDepth, jdU_imp, jdS_imp] at ihφ ihψ ⊢; omega
  | @untl ψ φ hψ hφ =>
      have h1 := jdS_eq_zero_of_isUOnly hψ
      have h2 := jdS_eq_zero_of_isUOnly hφ
      have h3 := jdU_le_one_of_isUOnly hψ
      have h4 := jdU_le_one_of_isUOnly hφ
      simp only [junctionDepth, jdU_untl, jdS_untl]; omega
  | @snce ψ φ hψ hφ =>
      have h1 := jdU_eq_zero_of_isSOnly hψ
      have h2 := jdU_eq_zero_of_isSOnly hφ
      have h3 := jdS_le_one_of_isSOnly hψ
      have h4 := jdS_le_one_of_isSOnly hφ
      simp only [junctionDepth, jdU_snce, jdS_snce]; omega

/-- Under GHR 10.2.7's hypothesis, `untl`-headed chains have length at most one and `snce`-headed
chains at most two: a chain of length three is `U, S, U` or `S, U, S`, and both put an `S` beneath
a `U`. -/
theorem jd_le_of_noSnceUnderUntl {φ : USForm} (h : NoSnceUnderUntl φ) :
    jdU φ ≤ 1 ∧ jdS φ ≤ 2 := by
  induction h with
  | leaf i => simp only [jdU_leaf, jdS_leaf]; omega
  | bot => simp only [jdU_bot, jdS_bot]; omega
  | imp _ _ ihφ ihψ => simp only [jdU_imp, jdS_imp]; omega
  | snce _ _ ihψ ihφ => simp only [jdU_snce, jdS_snce]; omega
  | @untl ψ φ hψ hφ =>
      have h1 := jdS_eq_zero_of_isUOnly hψ
      have h2 := jdS_eq_zero_of_isUOnly hφ
      have h3 := jdU_le_one_of_isUOnly hψ
      have h4 := jdU_le_one_of_isUOnly hφ
      simp only [jdU_untl, jdS_untl]; omega

/-- Under GHR 10.2.7's hypothesis the junction depth is at most two. -/
theorem junctionDepth_le_two_of_noSnceUnderUntl {φ : USForm} (h : NoSnceUnderUntl φ) :
    junctionDepth φ ≤ 2 := by
  have := jd_le_of_noSnceUnderUntl h
  simp only [junctionDepth]; omega

/-! ## The duality instruments -/

/-- The time reflection exchanges the two chain measures. -/
theorem jd_swap : ∀ φ : USForm, jdU φ.swap = jdS φ ∧ jdS φ.swap = jdU φ
  | .leaf i => ⟨rfl, rfl⟩
  | .bot => ⟨rfl, rfl⟩
  | .imp φ ψ => by
      obtain ⟨h1, h2⟩ := jd_swap φ
      obtain ⟨h3, h4⟩ := jd_swap ψ
      refine ⟨?_, ?_⟩ <;> simp only [USForm.swap, jdU_imp, jdS_imp, h1, h2, h3, h4]
  | .untl ψ φ => by
      obtain ⟨h1, h2⟩ := jd_swap ψ
      obtain ⟨h3, h4⟩ := jd_swap φ
      refine ⟨?_, ?_⟩ <;>
        simp only [USForm.swap, jdU_untl, jdS_untl, jdU_snce, jdS_snce, h1, h2, h3, h4]
  | .snce ψ φ => by
      obtain ⟨h1, h2⟩ := jd_swap ψ
      obtain ⟨h3, h4⟩ := jd_swap φ
      refine ⟨?_, ?_⟩ <;>
        simp only [USForm.swap, jdU_untl, jdS_untl, jdU_snce, jdS_snce, h1, h2, h3, h4]

theorem jdU_swap (φ : USForm) : jdU φ.swap = jdS φ := (jd_swap φ).1

theorem jdS_swap (φ : USForm) : jdS φ.swap = jdU φ := (jd_swap φ).2

/-- **Junction depth is stable under the time reflection.** This is what lets GHR 10.2.8's
`untl`-headed case be reached from its `snce`-headed case by conjugation. -/
theorem junctionDepth_swap (φ : USForm) : junctionDepth φ.swap = junctionDepth φ := by
  simp only [junctionDepth, jdU_swap, jdS_swap]; omega

/-- **Separatedness is stable under the time reflection**, through the landed purity reflections
`IsUOnly.swap` and `IsSOnly.swap` (`LeafAbstraction.lean`). -/
theorem isSeparated_swap {φ : USForm} (h : IsSeparated φ) : IsSeparated φ.swap := by
  induction h with
  | leaf i => exact IsSeparated.leaf i
  | bot => exact IsSeparated.bot
  | imp _ _ ihφ ihψ => exact IsSeparated.imp ihφ ihψ
  | untl hψ hφ => exact IsSeparated.snce hψ.swap hφ.swap
  | snce hψ hφ => exact IsSeparated.untl hψ.swap hφ.swap

/-- `usTruth_swap` read backwards: the reflected valuation at the reflected time, on the
reflected formula, is the original. -/
theorem usTruth_swap_reflect (v : ℕ → ℤ → Prop) (t : ℤ) (φ : USForm) :
    usTruth (reflectVal v) (-t) φ.swap ↔ usTruth v t φ := by
  rw [usTruth_swap, reflectVal_reflectVal, neg_neg]

/-- **The conjugate of GHR 10.2.7's hypothesis**: `φ` contains no `untl` nested within a `snce`.
Lemma 10.2.7 constrains `S` under `U`, so it is not self-dual, and this is a distinct predicate,
taken as the reflection of the landed one. -/
def NoUntlUnderSnce (φ : USForm) : Prop := NoSnceUnderUntl φ.swap

instance : DecidablePred NoUntlUnderSnce :=
  fun φ => inferInstanceAs (Decidable (NoSnceUnderUntl φ.swap))

/-- **The conjugate of GHR 10.2.7's construction**: reflect, separate by `sep7`, reflect back. A
plain `def`, deliberately not `noncomputable`. -/
def sep7Dual (φ : USForm) : USForm := (sep7 φ.swap).swap

/--
**GHR Lemma 10.2.7, conjugated**, the separatedness half: a formula containing no `U` nested
within an `S` is syntactically separable. Obtained from `sep7` by the time reflection, never by a
second argument.

Paper: — (a result of GHR vol. 1, Lemma 10.2.7 (its dual, which the proof of Lemma 10.2.8 invokes as
"the dual nature of the results so far"); the manuscript states no separation theorem)
-/
theorem isSeparated_sep7Dual {φ : USForm} (h : NoUntlUnderSnce φ) : IsSeparated (sep7Dual φ) :=
  isSeparated_swap (isSeparated_sep7 h)

/--
**GHR Lemma 10.2.7, conjugated**, the equivalence half.

Paper: — (a result of GHR vol. 1, Lemma 10.2.7 (its dual); the manuscript states no separation
theorem)
-/
theorem usTruth_sep7Dual {φ : USForm} (h : NoUntlUnderSnce φ) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (sep7Dual φ) ↔ usTruth v t φ := by
  rw [sep7Dual, usTruth_swap, usTruth_sep7 h, usTruth_swap_reflect]

/-! ## The maximal `snce` subformulae, and GHR's inner `S`s

The mirror of `Hierarchy.lean`'s `uTypes` and `UNesting.lean`'s `argUTypes`/`innerTypes`: `sTypes`
collects each `snce` node without recursing into its arguments, descending through `imp` and
`untl`; `innerSTypes φ` is the deduplicated collection of the maximal `snce`s of both arguments of
each maximal `untl` of `φ` — "the maximal `S` subformulae inside the maximal `U`s", which the
abstraction step replaces by fresh atoms. -/

/-- The **maximal `snce` subformulae** of `φ`, deduplicated. -/
def sTypes : USForm → List USForm
  | .leaf _ => []
  | .bot => []
  | .imp φ ψ => (sTypes φ ++ sTypes ψ).dedup
  | .untl ψ φ => (sTypes ψ ++ sTypes φ).dedup
  | .snce ψ φ => [USForm.snce ψ φ]

@[simp] theorem sTypes_leaf (i : ℕ) : sTypes (USForm.leaf i) = [] := rfl

@[simp] theorem sTypes_bot : sTypes USForm.bot = [] := rfl

@[simp] theorem sTypes_snce (ψ φ : USForm) :
    sTypes (USForm.snce ψ φ) = [USForm.snce ψ φ] := rfl

theorem sTypes_imp (φ ψ : USForm) :
    sTypes (USForm.imp φ ψ) = (sTypes φ ++ sTypes ψ).dedup := rfl

theorem sTypes_untl (ψ φ : USForm) :
    sTypes (USForm.untl ψ φ) = (sTypes ψ ++ sTypes φ).dedup := rfl

@[simp] theorem mem_sTypes_imp {u φ ψ : USForm} :
    u ∈ sTypes (USForm.imp φ ψ) ↔ u ∈ sTypes φ ∨ u ∈ sTypes ψ := by
  rw [sTypes_imp, List.mem_dedup, List.mem_append]

@[simp] theorem mem_sTypes_untl {u ψ φ : USForm} :
    u ∈ sTypes (USForm.untl ψ φ) ↔ u ∈ sTypes ψ ∨ u ∈ sTypes φ := by
  rw [sTypes_untl, List.mem_dedup, List.mem_append]

/-- Every collected maximal `snce` is `snce`-headed. -/
theorem exists_snce_of_mem_sTypes :
    ∀ {φ u : USForm}, u ∈ sTypes φ → ∃ a b : USForm, u = USForm.snce a b
  | .leaf _, _, hu => absurd hu (by simp)
  | .bot, _, hu => absurd hu (by simp)
  | .imp φ ψ, u, hu => by
      rcases mem_sTypes_imp.mp hu with h | h
      · exact exists_snce_of_mem_sTypes h
      · exact exists_snce_of_mem_sTypes h
  | .untl ψ φ, u, hu => by
      rcases mem_sTypes_untl.mp hu with h | h
      · exact exists_snce_of_mem_sTypes h
      · exact exists_snce_of_mem_sTypes h
  | .snce ψ φ, u, hu => ⟨ψ, φ, by simpa using hu⟩

/-- A maximal `snce` has `snce`-headed chains no longer than the formula it was collected from. -/
theorem jdS_le_of_mem_sTypes : ∀ {φ u : USForm}, u ∈ sTypes φ → jdS u ≤ jdS φ
  | .leaf _, _, hu => absurd hu (by simp)
  | .bot, _, hu => absurd hu (by simp)
  | .imp φ ψ, u, hu => by
      rcases mem_sTypes_imp.mp hu with h | h
      · exact le_trans (jdS_le_of_mem_sTypes h) (jdS_le_imp_left φ ψ)
      · exact le_trans (jdS_le_of_mem_sTypes h) (jdS_le_imp_right φ ψ)
  | .untl ψ φ, u, hu => by
      rcases mem_sTypes_untl.mp hu with h | h
      · exact le_trans (jdS_le_of_mem_sTypes h) (jdS_le_untl_left ψ φ)
      · exact le_trans (jdS_le_of_mem_sTypes h) (jdS_le_untl_right ψ φ)
  | .snce ψ φ, u, hu => by
      have hu' : u = USForm.snce ψ φ := by simpa using hu
      exact le_of_eq (by rw [hu'])

/-- A maximal `untl` has `untl`-headed chains no longer than the formula it was collected from. -/
theorem jdU_le_of_mem_uTypes : ∀ {φ u : USForm}, u ∈ uTypes φ → jdU u ≤ jdU φ
  | .leaf _, _, hu => absurd hu (by simp)
  | .bot, _, hu => absurd hu (by simp)
  | .imp φ ψ, u, hu => by
      rcases mem_uTypes_imp.mp hu with h | h
      · exact le_trans (jdU_le_of_mem_uTypes h) (jdU_le_imp_left φ ψ)
      · exact le_trans (jdU_le_of_mem_uTypes h) (jdU_le_imp_right φ ψ)
  | .untl ψ φ, u, hu => by
      have hu' : u = USForm.untl ψ φ := by simpa using hu
      exact le_of_eq (by rw [hu'])
  | .snce ψ φ, u, hu => by
      rcases mem_uTypes_snce.mp hu with h | h
      · exact le_trans (jdU_le_of_mem_uTypes h) (jdU_le_snce_left ψ φ)
      · exact le_trans (jdU_le_of_mem_uTypes h) (jdU_le_snce_right ψ φ)

/-- A `snce` node's own `snce`-headed chain is strictly longer than any `untl`-headed chain in
it. -/
theorem jdU_lt_jdS_snce (ψ φ : USForm) : jdU (USForm.snce ψ φ) < jdS (USForm.snce ψ φ) := by
  simp only [jdU_snce, jdS_snce]; omega

/-- The maximal `snce`s of one maximal `untl`'s two arguments. -/
def argSTypes : USForm → List USForm
  | .untl ψ φ => sTypes ψ ++ sTypes φ
  | _ => []

theorem argSTypes_untl (ψ φ : USForm) :
    argSTypes (USForm.untl ψ φ) = sTypes ψ ++ sTypes φ := rfl

/-- GHR's **inner `S`s**: the maximal `snce` subformulae inside the maximal `untl`s of `φ`,
deduplicated. These are what Lemma 10.2.8's step abstracts to fresh atoms. -/
def innerSTypes (φ : USForm) : List USForm := ((uTypes φ).flatMap argSTypes).dedup

theorem mem_innerSTypes {φ u : USForm} :
    u ∈ innerSTypes φ ↔ ∃ w ∈ uTypes φ, u ∈ argSTypes w := by
  rw [innerSTypes, List.mem_dedup, List.mem_flatMap]

/-- A maximal `snce` of a maximal `untl`'s argument is an inner `S`. -/
theorem mem_innerSTypes_of_mem_uTypes_arg {φ a b u : USForm}
    (hw : USForm.untl a b ∈ uTypes φ) (hu : u ∈ sTypes a ∨ u ∈ sTypes b) : u ∈ innerSTypes φ := by
  refine mem_innerSTypes.mpr ⟨USForm.untl a b, hw, ?_⟩
  rw [argSTypes_untl, List.mem_append]
  exact hu

theorem mem_innerSTypes_imp_left {φ ψ u : USForm} (hu : u ∈ innerSTypes φ) :
    u ∈ innerSTypes (USForm.imp φ ψ) := by
  obtain ⟨w, hw, hu'⟩ := mem_innerSTypes.mp hu
  exact mem_innerSTypes.mpr ⟨w, mem_uTypes_imp.mpr (Or.inl hw), hu'⟩

theorem mem_innerSTypes_imp_right {φ ψ u : USForm} (hu : u ∈ innerSTypes ψ) :
    u ∈ innerSTypes (USForm.imp φ ψ) := by
  obtain ⟨w, hw, hu'⟩ := mem_innerSTypes.mp hu
  exact mem_innerSTypes.mpr ⟨w, mem_uTypes_imp.mpr (Or.inr hw), hu'⟩

theorem mem_innerSTypes_snce_left {ψ φ u : USForm} (hu : u ∈ innerSTypes ψ) :
    u ∈ innerSTypes (USForm.snce ψ φ) := by
  obtain ⟨w, hw, hu'⟩ := mem_innerSTypes.mp hu
  exact mem_innerSTypes.mpr ⟨w, mem_uTypes_snce.mpr (Or.inl hw), hu'⟩

theorem mem_innerSTypes_snce_right {ψ φ u : USForm} (hu : u ∈ innerSTypes φ) :
    u ∈ innerSTypes (USForm.snce ψ φ) := by
  obtain ⟨w, hw, hu'⟩ := mem_innerSTypes.mp hu
  exact mem_innerSTypes.mpr ⟨w, mem_uTypes_snce.mpr (Or.inr hw), hu'⟩

/-- Every inner `S` is `snce`-headed. -/
theorem exists_snce_of_mem_innerSTypes {φ u : USForm} (hu : u ∈ innerSTypes φ) :
    ∃ a b : USForm, u = USForm.snce a b := by
  obtain ⟨w, hw, hu'⟩ := mem_innerSTypes.mp hu
  obtain ⟨a, b, rfl⟩ := exists_untl_of_mem_uTypes hw
  rw [argSTypes_untl, List.mem_append] at hu'
  rcases hu' with h | h
  · exact exists_snce_of_mem_sTypes h
  · exact exists_snce_of_mem_sTypes h

/--
**The first bound on the abstracted list**: an inner `S` sits inside a maximal `untl` of `φ`, and
that `untl` starts an `untl`-headed chain through it, so the inner `S`'s own `snce`-headed chains
are strictly shorter than `φ`'s longest `untl`-headed one. This is the depth-indexed analogue of
`untlDepth_lt_of_mem_innerTypes`, restated for junction depth.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 (implicit in "of one less junction depth"); the
manuscript states no separation theorem)
-/
theorem jdS_lt_jdU_of_mem_innerSTypes {φ u : USForm} (hu : u ∈ innerSTypes φ) :
    jdS u < jdU φ := by
  obtain ⟨w, hw, hu'⟩ := mem_innerSTypes.mp hu
  obtain ⟨a, b, rfl⟩ := exists_untl_of_mem_uTypes hw
  have hwd : jdU (USForm.untl a b) ≤ jdU φ := jdU_le_of_mem_uTypes hw
  rw [jdU_untl] at hwd
  rw [argSTypes_untl, List.mem_append] at hu'
  rcases hu' with h | h
  · have := jdS_le_of_mem_sTypes h; omega
  · have := jdS_le_of_mem_sTypes h; omega

/--
**The second bound on the abstracted list**: an inner `S` is `snce`-headed, so its `untl`-headed
chains are strictly shorter than its `snce`-headed ones, hence at least two shorter than `φ`'s
longest `untl`-headed chain.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 (implicit in "of one less junction depth"); the
manuscript states no separation theorem)
-/
theorem jdU_add_two_le_jdU_of_mem_innerSTypes {φ u : USForm} (hu : u ∈ innerSTypes φ) :
    jdU u + 2 ≤ jdU φ := by
  have h1 := jdS_lt_jdU_of_mem_innerSTypes hu
  obtain ⟨a, b, rfl⟩ := exists_snce_of_mem_innerSTypes hu
  have h2 := jdU_lt_jdS_snce a b
  omega

/-! ## The abstraction of the inner `S`s -/

/-- Rewrite every maximal `snce` subformula by `k`, **descending through `untl`**: the mirror image
of `mapU`, taken as its conjugate under the landed time reflection rather than as a second
operator. Only the five equations below are ever used of it. -/
def mapSDeep (k : USForm → USForm) (φ : USForm) : USForm :=
  (mapU (fun u => (k u.swap).swap) φ.swap).swap

@[simp] theorem mapSDeep_leaf (k : USForm → USForm) (i : ℕ) :
    mapSDeep k (USForm.leaf i) = USForm.leaf i := rfl

@[simp] theorem mapSDeep_bot (k : USForm → USForm) : mapSDeep k USForm.bot = USForm.bot := rfl

@[simp] theorem mapSDeep_imp (k : USForm → USForm) (φ ψ : USForm) :
    mapSDeep k (USForm.imp φ ψ) = USForm.imp (mapSDeep k φ) (mapSDeep k ψ) := rfl

@[simp] theorem mapSDeep_untl (k : USForm → USForm) (ψ φ : USForm) :
    mapSDeep k (USForm.untl ψ φ) = USForm.untl (mapSDeep k ψ) (mapSDeep k φ) := rfl

@[simp] theorem mapSDeep_snce (k : USForm → USForm) (ψ φ : USForm) :
    mapSDeep k (USForm.snce ψ φ) = k (USForm.snce ψ φ) := by
  simp [mapSDeep, mapU, USForm.swap]

/-- GHR's "abstract each maximal `S` inside the maximal `U`s to a fresh atom", as a function on
maximal `untl`s: rewrite the maximal `snce`s of both arguments, and leave anything else alone.
This is `mapU`'s argument, exactly as `abstrArgs` is in `UNesting.lean`. -/
def abstrSnceArgs (j : ℕ) (L : List USForm) : USForm → USForm
  | .untl ψ φ => USForm.untl (mapSDeep (abstrFn j L) ψ) (mapSDeep (abstrFn j L) φ)
  | u => u

theorem abstrSnceArgs_untl (j : ℕ) (L : List USForm) (ψ φ : USForm) :
    abstrSnceArgs j L (USForm.untl ψ φ) =
      USForm.untl (mapSDeep (abstrFn j L) ψ) (mapSDeep (abstrFn j L) φ) := rfl

/-- Abstracting *every* maximal `snce` of a formula makes it `snce`-free. The mirror of
`isSOnly_mapU_abstrFn`. -/
theorem isUOnly_mapSDeep_abstrFn {j : ℕ} {L : List USForm} :
    ∀ {ψ : USForm}, (∀ u ∈ sTypes ψ, u ∈ L) → IsUOnly (mapSDeep (abstrFn j L) ψ)
  | .leaf i, _ => by rw [mapSDeep_leaf]; exact IsUOnly.leaf i
  | .bot, _ => by rw [mapSDeep_bot]; exact IsUOnly.bot
  | .imp φ ψ, h => by
      rw [mapSDeep_imp]
      exact IsUOnly.imp
        (isUOnly_mapSDeep_abstrFn fun u hu => h u (mem_sTypes_imp.mpr (Or.inl hu)))
        (isUOnly_mapSDeep_abstrFn fun u hu => h u (mem_sTypes_imp.mpr (Or.inr hu)))
  | .untl ψ φ, h => by
      rw [mapSDeep_untl]
      exact IsUOnly.untl
        (isUOnly_mapSDeep_abstrFn fun u hu => h u (mem_sTypes_untl.mpr (Or.inl hu)))
        (isUOnly_mapSDeep_abstrFn fun u hu => h u (mem_sTypes_untl.mpr (Or.inr hu)))
  | .snce ψ φ, h => by
      rw [mapSDeep_snce]
      have hmem : USForm.snce ψ φ ∈ L := h _ (by simp)
      rw [show abstrFn j L (USForm.snce ψ φ) = USForm.leaf (j + L.idxOf (USForm.snce ψ φ)) from by
        simp only [abstrFn]; rw [if_pos hmem]]
      exact IsUOnly.leaf _

/--
**The abstracted formula satisfies GHR Lemma 10.2.7's hypothesis.** Every maximal `untl` of
`mapU (abstrSnceArgs j L) φ` has `snce`-free arguments, because each maximal `snce` inside it was
an inner `S`, lies in `L`, and became a leaf. This is what makes `sep7` applicable to it.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 (the "abstract the inner `S`s, then apply Lemma
10.2.7" step); the manuscript states no separation theorem)
-/
theorem noSnceUnderUntl_mapU_abstrSnceArgs {j : ℕ} {L : List USForm} :
    ∀ {φ : USForm}, (∀ u ∈ innerSTypes φ, u ∈ L) → NoSnceUnderUntl (mapU (abstrSnceArgs j L) φ)
  | .leaf i, _ => by simp only [mapU]; exact NoSnceUnderUntl.leaf i
  | .bot, _ => by simp only [mapU]; exact NoSnceUnderUntl.bot
  | .imp φ ψ, h => by
      simp only [mapU]
      exact NoSnceUnderUntl.imp
        (noSnceUnderUntl_mapU_abstrSnceArgs fun u hu => h u (mem_innerSTypes_imp_left hu))
        (noSnceUnderUntl_mapU_abstrSnceArgs fun u hu => h u (mem_innerSTypes_imp_right hu))
  | .snce ψ φ, h => by
      simp only [mapU]
      exact NoSnceUnderUntl.snce
        (noSnceUnderUntl_mapU_abstrSnceArgs fun u hu => h u (mem_innerSTypes_snce_left hu))
        (noSnceUnderUntl_mapU_abstrSnceArgs fun u hu => h u (mem_innerSTypes_snce_right hu))
  | .untl ψ φ, h => by
      simp only [mapU, abstrSnceArgs_untl]
      have hw : USForm.untl ψ φ ∈ uTypes (USForm.untl ψ φ) := by simp
      exact NoSnceUnderUntl.untl
        (isUOnly_mapSDeep_abstrFn fun u hu =>
          h u (mem_innerSTypes_of_mem_uTypes_arg hw (Or.inl hu)))
        (isUOnly_mapSDeep_abstrFn fun u hu =>
          h u (mem_innerSTypes_of_mem_uTypes_arg hw (Or.inr hu)))

/-- The reindexing inverts the deep abstraction syntactically. The mirror of the landed
`substLeaf_mapU_abstr`, and the only place the freshness of the abstraction indices is used. -/
theorem substLeaf_mapSDeep_abstrFn {j : ℕ} {L : List USForm} : ∀ {ψ : USForm}, ψ.maxLeaf < j →
    substLeaf (unabstrFn j L) (mapSDeep (abstrFn j L) ψ) = ψ
  | .leaf i, hi => by
      rw [mapSDeep_leaf]
      simp only [substLeaf]
      exact unabstrFn_of_lt hi
  | .bot, _ => rfl
  | .imp φ ψ, hi => by
      have h1 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ ψ.maxLeaf) hi
      have h2 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_right φ.maxLeaf _) hi
      rw [mapSDeep_imp]
      simp only [substLeaf]
      rw [substLeaf_mapSDeep_abstrFn h1, substLeaf_mapSDeep_abstrFn h2]
  | .untl ψ φ, hi => by
      have h1 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ φ.maxLeaf) hi
      have h2 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_right ψ.maxLeaf _) hi
      rw [mapSDeep_untl]
      simp only [substLeaf]
      rw [substLeaf_mapSDeep_abstrFn h1, substLeaf_mapSDeep_abstrFn h2]
  | .snce ψ φ, hi => by
      rw [mapSDeep_snce]
      by_cases hmem : USForm.snce ψ φ ∈ L
      · rw [show abstrFn j L (USForm.snce ψ φ) = USForm.leaf (j + L.idxOf (USForm.snce ψ φ)) from
          by simp only [abstrFn]; rw [if_pos hmem]]
        simp only [substLeaf]
        exact unabstrFn_abstrFn_of_mem hmem
      · rw [show abstrFn j L (USForm.snce ψ φ) = USForm.snce ψ φ from
          by simp only [abstrFn]; rw [if_neg hmem]]
        exact substLeaf_eq_self_of_lt (fun i hij => unabstrFn_of_lt hij) hi

/-- **The reindexing inverts the two-level abstraction syntactically.** Each `untl` case is
`substLeaf_mapSDeep_abstrFn` applied to the node's two arguments. -/
theorem substLeaf_mapU_abstrSnceArgs {j : ℕ} {L : List USForm} : ∀ {φ : USForm}, φ.maxLeaf < j →
    substLeaf (unabstrFn j L) (mapU (abstrSnceArgs j L) φ) = φ
  | .leaf i, hi => by
      simp only [mapU, substLeaf]
      exact unabstrFn_of_lt hi
  | .bot, _ => rfl
  | .imp φ ψ, hi => by
      have h1 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ ψ.maxLeaf) hi
      have h2 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_right φ.maxLeaf _) hi
      simp only [mapU, substLeaf]
      rw [substLeaf_mapU_abstrSnceArgs h1, substLeaf_mapU_abstrSnceArgs h2]
  | .snce ψ φ, hi => by
      have h1 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ φ.maxLeaf) hi
      have h2 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_right ψ.maxLeaf _) hi
      simp only [mapU, substLeaf]
      rw [substLeaf_mapU_abstrSnceArgs h1, substLeaf_mapU_abstrSnceArgs h2]
  | .untl ψ φ, hi => by
      have h1 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ φ.maxLeaf) hi
      have h2 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_right ψ.maxLeaf _) hi
      rw [show mapU (abstrSnceArgs j L) (USForm.untl ψ φ) =
          USForm.untl (mapSDeep (abstrFn j L) ψ) (mapSDeep (abstrFn j L) φ) from rfl]
      simp only [substLeaf]
      rw [substLeaf_mapSDeep_abstrFn h1, substLeaf_mapSDeep_abstrFn h2]

/-! ## The three parts of the strict-decrease obligation -/

/--
**Part (a) of GHR Lemma 10.2.8's strict-decrease obligation: abstraction drops the junction depth
to at most two.** Replacing each maximal `snce` inside a maximal `untl` by a fresh leaf breaks
every `S`-beneath-`U` link, so the abstracted formula satisfies `NoSnceUnderUntl`, whose junction
depth is at most two.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 (the abstraction step); the manuscript states no
separation theorem)
-/
theorem junctionDepth_mapU_abstrSnceArgs_le_two (φ : USForm) {j : ℕ} :
    junctionDepth (mapU (abstrSnceArgs j (innerSTypes φ)) φ) ≤ 2 :=
  junctionDepth_le_two_of_noSnceUnderUntl (noSnceUnderUntl_mapU_abstrSnceArgs fun _ hu => hu)

/-- Part (a) as a strict drop, which holds exactly above junction depth two. At depth two the
abstraction leaves the measure where it is, and the recursion still closes because it is part (c),
not part (a), that licenses the recursive call. -/
theorem junctionDepth_mapU_abstrSnceArgs_lt {φ : USForm} (h : 2 < junctionDepth φ) {j : ℕ} :
    junctionDepth (mapU (abstrSnceArgs j (innerSTypes φ)) φ) < junctionDepth φ :=
  lt_of_le_of_lt (junctionDepth_mapU_abstrSnceArgs_le_two φ) h

/--
**Part (b) of GHR Lemma 10.2.8's strict-decrease obligation: separation by Lemma 10.2.7 does not
raise the junction depth.** There is no landed counterpart, and neither `uTypes_sepMulti` nor
`UNesting.lean`'s `untlDepth` bounds transfer — junction depth counts alternations, a different
quantity from either — but none is needed: a separated formula has junction depth at most one
outright, by `junctionDepth_le_one_of_isSeparated`.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 (the "separate by Lemma 10.2.7" step, at the level of
the measure); the manuscript states no separation theorem)
-/
theorem junctionDepth_sep7_le_one {φ : USForm} (h : NoSnceUnderUntl φ) :
    junctionDepth (sep7 φ) ≤ 1 :=
  junctionDepth_le_one_of_isSeparated (isSeparated_sep7 h)

/-! ### The four substitution bounds -/

/-- Substituting into an `snce`-free formula: its `snce`-headed chains are the substitution's. -/
theorem jdS_substLeaf_le_of_isUOnly {h : ℕ → USForm} {e : ℕ} (he : ∀ i, jdS (h i) ≤ e)
    {ψ : USForm} (hψ : IsUOnly ψ) : jdS (substLeaf h ψ) ≤ e := by
  induction hψ with
  | leaf i => exact he i
  | bot => simp only [substLeaf, jdS_bot]; omega
  | imp _ _ ihφ ihψ => simp only [substLeaf, jdS_imp]; omega
  | untl _ _ ihψ ihφ => simp only [substLeaf, jdS_untl]; omega

/-- Substituting into an `snce`-free formula: an `untl`-headed chain either is the substitution's
or starts at one of the formula's own `untl`s and continues with a `snce`-headed chain of the
substitution's, so it is bounded by `max d (1 + e)`. The `untl` case of `jdS` contributes no
`1 +`, which is what makes this go through. -/
theorem jdU_substLeaf_le_of_isUOnly {h : ℕ → USForm} {d e : ℕ} (hd : ∀ i, jdU (h i) ≤ d)
    (he : ∀ i, jdS (h i) ≤ e) {ψ : USForm} (hψ : IsUOnly ψ) :
    jdU (substLeaf h ψ) ≤ max d (1 + e) := by
  induction hψ with
  | leaf i => have := hd i; simp only [substLeaf]; omega
  | bot => simp only [substLeaf, jdU_bot]; omega
  | imp _ _ ihφ ihψ => simp only [substLeaf, jdU_imp]; omega
  | @untl ψ φ hψ hφ ihψ ihφ =>
      have h1 := jdS_substLeaf_le_of_isUOnly he hψ
      have h2 := jdS_substLeaf_le_of_isUOnly he hφ
      simp only [substLeaf, jdU_untl]; omega

/-- Substituting into an `untl`-free formula: its `untl`-headed chains are the substitution's. -/
theorem jdU_substLeaf_le_of_isSOnly {h : ℕ → USForm} {d : ℕ} (hd : ∀ i, jdU (h i) ≤ d)
    {χ : USForm} (hχ : IsSOnly χ) : jdU (substLeaf h χ) ≤ d := by
  induction hχ with
  | leaf i => exact hd i
  | bot => simp only [substLeaf, jdU_bot]; omega
  | imp _ _ ihφ ihψ => simp only [substLeaf, jdU_imp]; omega
  | snce _ _ ihψ ihφ => simp only [substLeaf, jdU_snce]; omega

/-- The mirror of `jdU_substLeaf_le_of_isUOnly`. -/
theorem jdS_substLeaf_le_of_isSOnly {h : ℕ → USForm} {d e : ℕ} (hd : ∀ i, jdU (h i) ≤ d)
    (he : ∀ i, jdS (h i) ≤ e) {χ : USForm} (hχ : IsSOnly χ) :
    jdS (substLeaf h χ) ≤ max e (1 + d) := by
  induction hχ with
  | leaf i => have := he i; simp only [substLeaf]; omega
  | bot => simp only [substLeaf, jdS_bot]; omega
  | imp _ _ ihφ ihψ => simp only [substLeaf, jdS_imp]; omega
  | @snce ψ φ hψ hφ ihψ ihφ =>
      have h1 := jdU_substLeaf_le_of_isSOnly hd hψ
      have h2 := jdU_substLeaf_le_of_isSOnly hd hφ
      simp only [substLeaf, jdS_snce]; omega

/-- The four substitution bounds combined over a separated formula's three node kinds: Boolean,
pure-`U` `untl` (both arguments `IsUOnly`) and pure-`S` `snce` (both arguments `IsSOnly`). -/
theorem jd_substLeaf_le_of_isSeparated {h : ℕ → USForm} {d e : ℕ} (hd : ∀ i, jdU (h i) ≤ d)
    (he : ∀ i, jdS (h i) ≤ e) {S : USForm} (hS : IsSeparated S) :
    jdU (substLeaf h S) ≤ max d (1 + e) ∧ jdS (substLeaf h S) ≤ max e (1 + d) := by
  induction hS with
  | leaf i => have := hd i; have := he i; simp only [substLeaf]; omega
  | bot => simp only [substLeaf, jdU_bot, jdS_bot]; omega
  | imp _ _ ihφ ihψ => simp only [substLeaf, jdU_imp, jdS_imp]; omega
  | @untl ψ φ hψ hφ =>
      have h1 := jdS_substLeaf_le_of_isUOnly he hψ
      have h2 := jdS_substLeaf_le_of_isUOnly he hφ
      have h3 := jdU_substLeaf_le_of_isUOnly hd he hψ
      have h4 := jdU_substLeaf_le_of_isUOnly hd he hφ
      simp only [substLeaf, jdU_untl, jdS_untl]; omega
  | @snce ψ φ hψ hφ =>
      have h1 := jdU_substLeaf_le_of_isSOnly hd hψ
      have h2 := jdU_substLeaf_le_of_isSOnly hd hφ
      have h3 := jdS_substLeaf_le_of_isSOnly hd he hψ
      have h4 := jdS_substLeaf_le_of_isSOnly hd he hφ
      simp only [substLeaf, jdU_snce, jdS_snce]; omega

/-- Substituting into a separated formula raises the junction depth by at most one over the
substitution's own measures. -/
theorem junctionDepth_substLeaf_le_of_isSeparated {h : ℕ → USForm} {d e : ℕ}
    (hd : ∀ i, jdU (h i) ≤ d) (he : ∀ i, jdS (h i) ≤ e) {S : USForm} (hS : IsSeparated S) :
    junctionDepth (substLeaf h S) ≤ 1 + max d e := by
  have := jd_substLeaf_le_of_isSeparated hd he hS
  simp only [junctionDepth]; omega

/-- Every value of the reindexing has `untl`-headed chains no longer than the abstracted list's.
The depth-indexed analogue of `mem_uTypes_unabstrFn` for junction depth. -/
theorem jdU_unabstrFn_le {j d : ℕ} {L : List USForm} (hLd : ∀ u ∈ L, jdU u ≤ d) (i : ℕ) :
    jdU (unabstrFn j L i) ≤ d := by
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h, jdU_leaf]; omega
  · exact hLd _ h

/-- Every value of the reindexing has `snce`-headed chains no longer than the abstracted list's. -/
theorem jdS_unabstrFn_le {j e : ℕ} {L : List USForm} (hLe : ∀ u ∈ L, jdS u ≤ e) (i : ℕ) :
    jdS (unabstrFn j L i) ≤ e := by
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h, jdS_leaf]; omega
  · exact hLe _ h

/--
**The reindexed form's junction depth, in terms of the two list bounds**: when every abstracted
member `E` has `jdS E + 1 ≤ m` and `jdU E + 2 ≤ m`, substituting the list back into a separated
formula gives junction depth at most `max m 1`.
-/
theorem junctionDepth_substLeaf_unabstrFn_le {j m : ℕ} {L : List USForm}
    (hLs : ∀ u ∈ L, jdS u + 1 ≤ m) (hLu : ∀ u ∈ L, jdU u + 2 ≤ m) {S : USForm}
    (hS : IsSeparated S) : junctionDepth (substLeaf (unabstrFn j L) S) ≤ max m 1 := by
  have hd : ∀ i, jdU (unabstrFn j L i) ≤ m - 2 :=
    jdU_unabstrFn_le fun u hu => by have := hLu u hu; omega
  have he : ∀ i, jdS (unabstrFn j L i) ≤ m - 1 :=
    jdS_unabstrFn_le fun u hu => by have := hLs u hu; omega
  have := junctionDepth_substLeaf_le_of_isSeparated hd he hS
  omega

/-! ## GHR Lemma 10.2.8's step -/

/-- **One step of GHR Lemma 10.2.8 at a `snce`-headed formula**: abstract the maximal `snce`s
inside the maximal `untl`s to fresh leaves, separate the result by Lemma 10.2.7, and substitute
them back. A plain `def`, deliberately not `noncomputable`. -/
def sep8Step (φ : USForm) : USForm :=
  substLeaf (unabstrFn φ.freshLeaf (innerSTypes φ))
    (sep7 (mapU (abstrSnceArgs φ.freshLeaf (innerSTypes φ)) φ))

/-- The step is truth-preserving at every formula: the reindexing moves onto the valuation, Lemma
10.2.7 holds there, and the syntactic round trip closes. -/
theorem usTruth_sep8Step (φ : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (sep8Step φ) ↔ usTruth v t φ := by
  have hns : NoSnceUnderUntl (mapU (abstrSnceArgs φ.freshLeaf (innerSTypes φ)) φ) :=
    noSnceUnderUntl_mapU_abstrSnceArgs fun _ hu => hu
  rw [sep8Step]
  calc usTruth v t (substLeaf (unabstrFn φ.freshLeaf (innerSTypes φ))
          (sep7 (mapU (abstrSnceArgs φ.freshLeaf (innerSTypes φ)) φ)))
    _ ↔ usTruth (fun i s => usTruth v s (unabstrFn φ.freshLeaf (innerSTypes φ) i)) t
          (sep7 (mapU (abstrSnceArgs φ.freshLeaf (innerSTypes φ)) φ)) :=
        usTruth_substLeaf _ _ _ _
    _ ↔ usTruth (fun i s => usTruth v s (unabstrFn φ.freshLeaf (innerSTypes φ) i)) t
          (mapU (abstrSnceArgs φ.freshLeaf (innerSTypes φ)) φ) :=
        usTruth_sep7 hns _ t
    _ ↔ usTruth v t (substLeaf (unabstrFn φ.freshLeaf (innerSTypes φ))
          (mapU (abstrSnceArgs φ.freshLeaf (innerSTypes φ)) φ)) :=
        (usTruth_substLeaf _ _ _ _).symm
    _ ↔ usTruth v t φ := by rw [substLeaf_mapU_abstrSnceArgs (USForm.lt_freshLeaf φ)]

/--
**Part (c) of GHR Lemma 10.2.8's strict-decrease obligation: at a `snce`-headed formula of
junction depth at least two, the reindexed form's junction depth is at most the pre-abstraction
depth less one.**

GHR leave this implicit: "of one less junction depth" is the whole of their argument. Here it is
`junctionDepth_substLeaf_unabstrFn_le` at `m = jdU φ`, with the two list bounds
`jdS_lt_jdU_of_mem_innerSTypes` and `jdU_add_two_le_jdU_of_mem_innerSTypes`, which gives
`≤ max (jdU φ) 1`; and `jdU φ < jdS φ = junctionDepth φ` **because `φ` is `snce`-headed**
(`jdU_lt_jdS_snce`). That last inequality fails for a general formula with `jdU φ = jdS φ`, so the
head kind is a genuine precondition of the bound and the recursion applies the step only at
maximal temporal nodes, reaching `untl` heads by conjugation. It is this bound that licenses the
recursive call in `sep8Body_spec`.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 (the bound licensing the induction hypothesis,
asserted there as "of one less junction depth"); the manuscript states no separation theorem)
-/
theorem junctionDepth_sep8Step_snce_le (ψ φ : USForm) (h : 2 ≤ junctionDepth (USForm.snce ψ φ)) :
    junctionDepth (sep8Step (USForm.snce ψ φ)) + 1 ≤ junctionDepth (USForm.snce ψ φ) := by
  have hsep : IsSeparated (sep7 (mapU (abstrSnceArgs (USForm.snce ψ φ).freshLeaf
      (innerSTypes (USForm.snce ψ φ))) (USForm.snce ψ φ))) :=
    isSeparated_sep7 (noSnceUnderUntl_mapU_abstrSnceArgs fun _ hu => hu)
  have hb := junctionDepth_substLeaf_unabstrFn_le (j := (USForm.snce ψ φ).freshLeaf)
    (m := jdU (USForm.snce ψ φ)) (L := innerSTypes (USForm.snce ψ φ))
    (fun u hu => jdS_lt_jdU_of_mem_innerSTypes hu)
    (fun u hu => jdU_add_two_le_jdU_of_mem_innerSTypes hu) hsep
  have hlt : jdU (USForm.snce ψ φ) < jdS (USForm.snce ψ φ) := jdU_lt_jdS_snce ψ φ
  have hjd : junctionDepth (USForm.snce ψ φ) = jdS (USForm.snce ψ φ) := by
    simp only [junctionDepth]; omega
  rw [sep8Step]
  omega

/-! ## GHR Lemma 10.2.8 as a budget recursion, and Theorem 10.2.9 -/

/-- The step at an `untl`-headed formula, by conjugation: reflect, take the `snce`-headed step,
reflect back. A plain `def`, deliberately not `noncomputable`. -/
def sep8StepDual (φ : USForm) : USForm := (sep8Step φ.swap).swap

/-- One step of GHR Lemma 10.2.8's induction, with `k` standing for the recursive call. The
Boolean skeleton is descended structurally; at each maximal temporal node of junction depth at
most one the node is already separated and is returned unchanged, and above that the recursive
call is fired at the reindexed form — `sep8Step` at a `snce` head, `sep8StepDual` at an `untl`
head. -/
def sep8Body (k : USForm → USForm) : USForm → USForm
  | .leaf i => USForm.leaf i
  | .bot => USForm.bot
  | .imp φ ψ => USForm.imp (sep8Body k φ) (sep8Body k ψ)
  | .untl ψ φ =>
      if junctionDepth (USForm.untl ψ φ) ≤ 1 then USForm.untl ψ φ
      else k (sep8StepDual (USForm.untl ψ φ))
  | .snce ψ φ =>
      if junctionDepth (USForm.snce ψ φ) ≤ 1 then USForm.snce ψ φ
      else k (sep8Step (USForm.snce ψ φ))

theorem sep8Body_leaf (k : USForm → USForm) (i : ℕ) : sep8Body k (USForm.leaf i) = USForm.leaf i :=
  rfl

theorem sep8Body_bot (k : USForm → USForm) : sep8Body k USForm.bot = USForm.bot := rfl

theorem sep8Body_imp (k : USForm → USForm) (φ ψ : USForm) :
    sep8Body k (USForm.imp φ ψ) = USForm.imp (sep8Body k φ) (sep8Body k ψ) := rfl

theorem sep8Body_untl (k : USForm → USForm) (ψ φ : USForm) :
    sep8Body k (USForm.untl ψ φ) =
      if junctionDepth (USForm.untl ψ φ) ≤ 1 then USForm.untl ψ φ
      else k (sep8StepDual (USForm.untl ψ φ)) := rfl

theorem sep8Body_snce (k : USForm → USForm) (ψ φ : USForm) :
    sep8Body k (USForm.snce ψ φ) =
      if junctionDepth (USForm.snce ψ φ) ≤ 1 then USForm.snce ψ φ
      else k (sep8Step (USForm.snce ψ φ)) := rfl

/-- GHR Lemma 10.2.8's construction with an explicit budget for the junction depth left to
eliminate, structural on the budget. A plain `def`, deliberately not `noncomputable`. -/
def sep8Fuel : ℕ → USForm → USForm
  | 0, φ => φ
  | n + 1, φ => sep8Body (sep8Fuel n) φ

/--
**The Separation Theorem's separating function**: the budget instantiated at the junction depth,
so the budget appears in no public statement. A plain `def`, deliberately not `noncomputable`:
the downstream ZTime translation's executability deliverable consumes it.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 and Theorem 10.2.9; the manuscript states no
separation theorem)
-/
def sep (φ : USForm) : USForm := sep8Fuel (junctionDepth φ) φ

/--
**One step of GHR Lemma 10.2.8**, given the recursive call's contract at the reduced budget. The
`snce` case consumes part (c) directly; the `untl` case consumes it at the reflected formula,
through `junctionDepth_swap` and `usTruth_swap`.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 (the inductive step); the manuscript states no
separation theorem)
-/
theorem sep8Body_spec {n : ℕ} {k : USForm → USForm}
    (hk : ∀ χ : USForm, junctionDepth χ ≤ n →
      IsSeparated (k χ) ∧ ∀ v t, usTruth v t (k χ) ↔ usTruth v t χ) :
    ∀ φ : USForm, junctionDepth φ ≤ n + 1 →
      IsSeparated (sep8Body k φ) ∧ ∀ v t, usTruth v t (sep8Body k φ) ↔ usTruth v t φ
  | .leaf i, _ => ⟨IsSeparated.leaf i, fun _ _ => Iff.rfl⟩
  | .bot, _ => ⟨IsSeparated.bot, fun _ _ => Iff.rfl⟩
  | .imp φ ψ, h => by
      have h1 : junctionDepth φ ≤ n + 1 := le_trans (junctionDepth_le_imp_left φ ψ) h
      have h2 : junctionDepth ψ ≤ n + 1 := le_trans (junctionDepth_le_imp_right φ ψ) h
      obtain ⟨hsφ, htφ⟩ := sep8Body_spec hk φ h1
      obtain ⟨hsψ, htψ⟩ := sep8Body_spec hk ψ h2
      rw [sep8Body_imp]
      simp only [usTruth_imp_iff]
      exact ⟨IsSeparated.imp hsφ hsψ, fun v t => imp_congr (htφ v t) (htψ v t)⟩
  | .untl ψ φ, h => by
      by_cases hle : junctionDepth (USForm.untl ψ φ) ≤ 1
      · rw [sep8Body_untl, if_pos hle]
        exact ⟨isSeparated_of_junctionDepth_le_one hle, fun _ _ => Iff.rfl⟩
      · rw [sep8Body_untl, if_neg hle]
        have hsw : junctionDepth (USForm.snce ψ.swap φ.swap) = junctionDepth (USForm.untl ψ φ) := by
          rw [← USForm.swap_untl, junctionDepth_swap]
        have hc := junctionDepth_sep8Step_snce_le ψ.swap φ.swap (by omega)
        have hχ : junctionDepth (sep8StepDual (USForm.untl ψ φ)) ≤ n := by
          rw [sep8StepDual, junctionDepth_swap, USForm.swap_untl]
          omega
        obtain ⟨hs, ht⟩ := hk _ hχ
        refine ⟨hs, fun v t => ?_⟩
        rw [ht v t, sep8StepDual, usTruth_swap, usTruth_sep8Step, usTruth_swap_reflect]
  | .snce ψ φ, h => by
      by_cases hle : junctionDepth (USForm.snce ψ φ) ≤ 1
      · rw [sep8Body_snce, if_pos hle]
        exact ⟨isSeparated_of_junctionDepth_le_one hle, fun _ _ => Iff.rfl⟩
      · rw [sep8Body_snce, if_neg hle]
        have hc := junctionDepth_sep8Step_snce_le ψ φ (by omega)
        obtain ⟨hs, ht⟩ := hk (sep8Step (USForm.snce ψ φ)) (by omega)
        exact ⟨hs, fun v t => (ht v t).trans (usTruth_sep8Step _ v t)⟩

/--
**GHR Lemma 10.2.8**, with the budget explicit: every formula of junction depth at most `n` is
equivalent to a separated formula. Induction on the budget; the step is `sep8Body_spec`, where
part (c) licenses the inductive hypothesis.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8; the manuscript states no separation theorem)
-/
theorem sep8Fuel_spec : ∀ (n : ℕ) (φ : USForm), junctionDepth φ ≤ n →
    IsSeparated (sep8Fuel n φ) ∧ ∀ v t, usTruth v t (sep8Fuel n φ) ↔ usTruth v t φ := by
  intro n
  induction n with
  | zero =>
      intro φ hd
      exact ⟨isSeparated_of_junctionDepth_le_one (le_trans hd (Nat.zero_le 1)),
        fun _ _ => Iff.rfl⟩
  | succ n ih =>
      intro φ hd
      rw [show sep8Fuel (n + 1) φ = sep8Body (sep8Fuel n) φ from rfl]
      exact sep8Body_spec (fun χ hχ => ih χ hχ) φ hd

/--
**GHR Theorem 10.2.9 — the Separation Theorem over the integers**, the separatedness half: every
formula of the until/since language is equivalent over `ℤ` to a syntactically separated one, and
`sep` computes it.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 and Theorem 10.2.9; the manuscript states no
separation theorem)
-/
theorem isSeparated_sep (ψ : USForm) : IsSeparated (sep ψ) :=
  (sep8Fuel_spec (junctionDepth ψ) ψ le_rfl).1

/--
**GHR Theorem 10.2.9 — the Separation Theorem over the integers**, the equivalence half.

Paper: — (a result of GHR vol. 1, Lemma 10.2.8 and Theorem 10.2.9; the manuscript states no
separation theorem)
-/
theorem usTruth_sep_iff (ψ : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (sep ψ) ↔ usTruth v t ψ :=
  (sep8Fuel_spec (junctionDepth ψ) ψ le_rfl).2 v t

end FormalSystem.Metalogic.Expressiveness.SeparationZ
