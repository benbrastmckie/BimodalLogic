/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Hierarchy

/-!
# GHR Lemma 10.2.7 — no `S` nested within a `U`

[GHR][gabbay1994] vol. 1, Lemma 10.2.7 reads, verbatim:

> Suppose that wff D contains no S nested within a U. Then D is syntactically separable.

Its proof runs "by induction on the maximum depth n of nesting of Us beneath an S", with base
case `n = 1` being Lemma 10.2.6. The step takes the subformulae `U(Aᵢ, Bᵢ)` covering the maximal
appearances of `U`, abstracts each inner `U(Xᵢⱼ, Yᵢⱼ)` to a fresh atom, separates the result by
10.2.6, substitutes back, and re-separates the constituents the substitution made impure. GHR's
licensing sentence — "the level of nesting of U in `U(Aᵢ, Bᵢ)` must be strictly greater than that
in its subformula `U(Xᵢⱼ, Yᵢⱼ)`" — is asserted there without proof and is
`untlDepth_lt_of_mem_innerTypes` here.

## The measure

`untlDepth` is the `U`-within-`U` nesting depth: `0` at a leaf and at `⊥`, the `max` of the two
arguments at `imp` and at `snce`, and `1 + max` at `untl`. It is a plain total structural
recursion. It is **not** a junction depth and not a type count: it counts `untl` nested inside
`untl`, which is the quantity GHR's licensing sentence bounds and the quantity the recursion
below decreases. `uTypeCount` (`Hierarchy.lean`) bounds the number of maximal `untl` *types* and
says nothing about nesting; the two measures are independent and neither bounds the other.

## The hypothesis as a structural predicate

`NoSnceUnderUntl` is GHR's "contains no S nested within a U", stated structurally rather than as
prose so that Phase 24 can discharge it mechanically. Its `imp` and `snce` constructors recurse;
its single `untl` constructor demands `IsUOnly` of both arguments, which is exactly "no `S`
anywhere beneath this `U`", hereditarily. `noSnceUnderUntlB` is the `Bool`-valued decision
procedure and `noSnceUnderUntlB_iff` its correctness, so the predicate is decidable.

## The base case, and why it is `sepMulti` and not the identity

`untlDepth φ ≤ 1` means every maximal `untl` of `φ` has `untl`-free arguments; together with
`NoSnceUnderUntl φ` that makes those arguments `snce`-free too, so every collected type is an
`IsPureType` and `HasPureUTypes φ` holds (`hasPureUTypes_of_untlDepth_le_one`). This is exactly
GHR's `n = 1` case, and the separating function at that depth is therefore Lemma 10.2.6's
`sepMulti`, **not** the identity: a formula of `untlDepth` 1 satisfies 10.2.6's hypothesis but is
in general not itself separated, since its maximal `untl`s may sit under `snce` nodes. Returning
it unchanged would make the construction unsound at every depth-1 input and would also break the
recursive call at every greater depth, because the reindexed constituents land at depth at most
one. `sep7Fuel 0 φ = φ` is sound for a different reason: budget `0` is only ever reached at
`untlDepth φ ≤ 0`, where `isSOnly_of_untlDepth_eq_zero` makes `φ` `untl`-free and hence already
separated.

## The budget, and why there is no `decreasing_by`

The recursion is the three-declaration budget idiom `Hierarchy.lean` validates at Lemma 10.2.6:
`sep7Body` takes the recursive call as a parameter, `sep7Fuel` is structural on an explicit `ℕ`
budget, and `sep7` instantiates the budget at the measure, so the budget appears in no public
statement. A well-founded recursion on `untlDepth` is **not available**: the recursive call is
fired by `mapS` at the separated form's `snce` constituents, which are neither syntactic subterms
of the definition's argument nor in scope when the definition is elaborated, so no
`decreasing_by` goal can be stated for it at all. This is a fact about the construction, not a
tactic difficulty.

## The landed device is reused, not rebuilt

`mapU`, `mapS`, `substLeaf`, `abstrFn`, `unabstrFn` and their calculus are `Hierarchy.lean`'s and
are used verbatim; no second substitution operator is defined here. `abstrArgs` is `mapU` at a
`g` that is itself a `mapU`, which is how "abstract inside a maximal `untl`'s arguments" is said
with the landed operators. Three landed lemmas do not transfer, because their hypothesis is
`∀ u ∈ L, IsPureType u` and `innerTypes` is not a list of pure types — a member of it is an
`untl` with `IsUOnly` arguments, which may still contain `untl`. Their analogues here are
`isSeparated_unabstrFn_of_isUOnly`, `mapS_unabstrFn_of_untl` and `untlDepth_unabstrFn_le`, each
with the purity hypothesis replaced by the weaker datum this phase actually has.
`usTruth_congr_of_update` (`Syntax.lean`) is deliberately **not** cited: it is unused in this
development, and `usTruth_substLeaf` is strictly stronger for the equivalence step, which needs
no freshness side-condition on the valuation at all. Freshness enters at exactly one place, the
syntactic round trip `substLeaf_mapU_abstrArgs`.

## The strict decrease, in three parts

Three obligations, each its own named result, none standing in for another:

- **(a)** `untlDepth_mapU_abstrArgs_le_one`: abstracting every inner type leaves every maximal
  `untl` with `untl`-free arguments, so the depth falls to at most one.
  `hasPureUTypes_mapU_abstrArgs` is the same fact in the form Lemma 10.2.6 consumes; both are
  proved and kept distinct.
- **(b)** `untlDepth_sepMulti_le_one`: separation does not raise the measure. There is no landed
  counterpart — `uTypes_sepMulti` bounds `untl` *types*, not `untl` nesting, and is **not** what
  discharges this. It follows from `hasPureUTypes_sepMulti` together with
  `untlDepth_le_one_of_hasPureUTypes`.
- **(c)** `untlDepth_snce_substLeaf_le`: the reindexed form's depth is bounded by the
  pre-abstraction depth less one, via `untlDepth_unabstrFn_le`,
  `untlDepth_substLeaf_le_of_isSOnly` and `untlDepth_lt_of_mem_innerTypes`. It is this bound, not
  (a), that licenses the recursive call, and `sep7Fuel_spec` says so at the call.

## Main Definitions

- `NoSnceUnderUntl`, `noSnceUnderUntlB`: GHR 10.2.7's hypothesis and its decision procedure
- `untlDepth`: the `U`-within-`U` nesting depth
- `innerTypes`: GHR's `U(Xᵢⱼ, Yᵢⱼ)`s, the maximal `untl`s of the maximal `untl`s' arguments
- `abstrArgs`: the abstraction of the inner types, as `mapU` at a `mapU`
- `sep7Body`, `sep7Fuel`, `sep7`: GHR 10.2.7's construction in the budget idiom

## Main Results

- `untlDepth_le_one_of_hasPureUTypes`, `hasPureUTypes_of_untlDepth_le_one`: the two bridges
  between the measure and Lemma 10.2.6's hypothesis, which together are this lemma's base case
- `untlDepth_lt_of_mem_innerTypes`: GHR's licensing sentence, proved rather than asserted
- `untlDepth_mapU_abstrArgs_le_one`, `untlDepth_sepMulti_le_one`, `untlDepth_snce_substLeaf_le`:
  parts (a), (b) and (c) of the strict-decrease obligation
- `sep7Fuel_spec`, `isSeparated_sep7`, `usTruth_sep7`: GHR Lemma 10.2.7

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemma 10.2.7
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## GHR 10.2.7's hypothesis as a structural predicate -/

/--
`φ` **contains no `snce` nested within an `untl`**: GHR Lemma 10.2.7's hypothesis, stated
structurally rather than as prose. The `imp` and `snce` constructors recurse; the single `untl`
constructor demands `IsUOnly` of both arguments, which is "no `S` anywhere beneath this `U`",
hereditarily.
-/
inductive NoSnceUnderUntl : USForm → Prop
  /-- Every leaf has no `snce` under an `untl`. -/
  | leaf (i : ℕ) : NoSnceUnderUntl (.leaf i)
  /-- Bottom has no `snce` under an `untl`. -/
  | bot : NoSnceUnderUntl .bot
  /-- `imp` recurses. -/
  | imp {φ ψ : USForm} : NoSnceUnderUntl φ → NoSnceUnderUntl ψ → NoSnceUnderUntl (.imp φ ψ)
  /-- `snce` recurses: an `snce` above an `untl` is unconstrained. -/
  | snce {ψ φ : USForm} :
      NoSnceUnderUntl ψ → NoSnceUnderUntl φ → NoSnceUnderUntl (USForm.snce ψ φ)
  /-- An `untl` admits only `snce`-free arguments, which is the whole hypothesis. -/
  | untl {ψ φ : USForm} : IsUOnly ψ → IsUOnly φ → NoSnceUnderUntl (USForm.untl ψ φ)

/-- The decision procedure for `IsUOnly`: `φ` carries no `snce`. -/
def hasNoSnce : USForm → Bool
  | .leaf _ => true
  | .bot => true
  | .imp φ ψ => hasNoSnce φ && hasNoSnce ψ
  | .untl ψ φ => hasNoSnce ψ && hasNoSnce φ
  | .snce _ _ => false

theorem hasNoSnce_iff : ∀ φ : USForm, hasNoSnce φ = true ↔ IsUOnly φ
  | .leaf i => ⟨fun _ => IsUOnly.leaf i, fun _ => rfl⟩
  | .bot => ⟨fun _ => IsUOnly.bot, fun _ => rfl⟩
  | .imp φ ψ => by
      rw [show hasNoSnce (USForm.imp φ ψ) = (hasNoSnce φ && hasNoSnce ψ) from rfl,
        Bool.and_eq_true, hasNoSnce_iff φ, hasNoSnce_iff ψ]
      exact ⟨fun h => IsUOnly.imp h.1 h.2, fun h => by cases h with
        | imp h1 h2 => exact ⟨h1, h2⟩⟩
  | .untl ψ φ => by
      rw [show hasNoSnce (USForm.untl ψ φ) = (hasNoSnce ψ && hasNoSnce φ) from rfl,
        Bool.and_eq_true, hasNoSnce_iff ψ, hasNoSnce_iff φ]
      exact ⟨fun h => IsUOnly.untl h.1 h.2, fun h => by cases h with
        | untl h1 h2 => exact ⟨h1, h2⟩⟩
  | .snce ψ φ => by
      refine ⟨fun h => absurd h (by simp [hasNoSnce]), fun h => absurd h ?_⟩
      intro h
      cases h

instance : DecidablePred IsUOnly := fun φ => decidable_of_iff _ (hasNoSnce_iff φ)

/-- The decision procedure for `NoSnceUnderUntl`. -/
def noSnceUnderUntlB : USForm → Bool
  | .leaf _ => true
  | .bot => true
  | .imp φ ψ => noSnceUnderUntlB φ && noSnceUnderUntlB ψ
  | .snce ψ φ => noSnceUnderUntlB ψ && noSnceUnderUntlB φ
  | .untl ψ φ => hasNoSnce ψ && hasNoSnce φ

theorem noSnceUnderUntlB_iff : ∀ φ : USForm, noSnceUnderUntlB φ = true ↔ NoSnceUnderUntl φ
  | .leaf i => ⟨fun _ => NoSnceUnderUntl.leaf i, fun _ => rfl⟩
  | .bot => ⟨fun _ => NoSnceUnderUntl.bot, fun _ => rfl⟩
  | .imp φ ψ => by
      rw [show noSnceUnderUntlB (USForm.imp φ ψ) =
            (noSnceUnderUntlB φ && noSnceUnderUntlB ψ) from rfl,
        Bool.and_eq_true, noSnceUnderUntlB_iff φ, noSnceUnderUntlB_iff ψ]
      exact ⟨fun h => NoSnceUnderUntl.imp h.1 h.2, fun h => by cases h with
        | imp h1 h2 => exact ⟨h1, h2⟩⟩
  | .snce ψ φ => by
      rw [show noSnceUnderUntlB (USForm.snce ψ φ) =
            (noSnceUnderUntlB ψ && noSnceUnderUntlB φ) from rfl,
        Bool.and_eq_true, noSnceUnderUntlB_iff ψ, noSnceUnderUntlB_iff φ]
      exact ⟨fun h => NoSnceUnderUntl.snce h.1 h.2, fun h => by cases h with
        | snce h1 h2 => exact ⟨h1, h2⟩⟩
  | .untl ψ φ => by
      rw [show noSnceUnderUntlB (USForm.untl ψ φ) = (hasNoSnce ψ && hasNoSnce φ) from rfl,
        Bool.and_eq_true, hasNoSnce_iff ψ, hasNoSnce_iff φ]
      exact ⟨fun h => NoSnceUnderUntl.untl h.1 h.2, fun h => by cases h with
        | untl h1 h2 => exact ⟨h1, h2⟩⟩

instance : DecidablePred NoSnceUnderUntl :=
  fun φ => decidable_of_iff _ (noSnceUnderUntlB_iff φ)

/-- An `untl`-free formula has no `snce` under an `untl`, vacuously. -/
theorem noSnceUnderUntl_of_isSOnly {φ : USForm} (h : IsSOnly φ) : NoSnceUnderUntl φ := by
  induction h with
  | leaf i => exact NoSnceUnderUntl.leaf i
  | bot => exact NoSnceUnderUntl.bot
  | imp _ _ ihφ ihψ => exact NoSnceUnderUntl.imp ihφ ihψ
  | snce _ _ ihψ ihφ => exact NoSnceUnderUntl.snce ihψ ihφ

/-- An `snce`-free formula has no `snce` under an `untl`, vacuously. -/
theorem noSnceUnderUntl_of_isUOnly {φ : USForm} (h : IsUOnly φ) : NoSnceUnderUntl φ := by
  induction h with
  | leaf i => exact NoSnceUnderUntl.leaf i
  | bot => exact NoSnceUnderUntl.bot
  | imp _ _ ihφ ihψ => exact NoSnceUnderUntl.imp ihφ ihψ
  | untl hψ hφ _ _ => exact NoSnceUnderUntl.untl hψ hφ

/-! ## The `untl`-nesting measure -/

/--
The **`U`-within-`U` nesting depth**: `0` at a leaf and at `⊥`, the `max` of the two arguments at
`imp` and at `snce`, and `1 + max` at `untl`. This is the quantity GHR's licensing sentence
bounds and the quantity `sep7Fuel`'s recursion decreases.

It is independent of `uTypeCount`: that measure counts maximal `untl` types and says nothing
about nesting, and neither measure bounds the other.
-/
def untlDepth : USForm → ℕ
  | .leaf _ => 0
  | .bot => 0
  | .imp φ ψ => max (untlDepth φ) (untlDepth ψ)
  | .untl ψ φ => 1 + max (untlDepth ψ) (untlDepth φ)
  | .snce ψ φ => max (untlDepth ψ) (untlDepth φ)

@[simp] theorem untlDepth_leaf (i : ℕ) : untlDepth (USForm.leaf i) = 0 := rfl

@[simp] theorem untlDepth_bot : untlDepth USForm.bot = 0 := rfl

@[simp] theorem untlDepth_imp (φ ψ : USForm) :
    untlDepth (USForm.imp φ ψ) = max (untlDepth φ) (untlDepth ψ) := rfl

@[simp] theorem untlDepth_untl (ψ φ : USForm) :
    untlDepth (USForm.untl ψ φ) = 1 + max (untlDepth ψ) (untlDepth φ) := rfl

@[simp] theorem untlDepth_snce (ψ φ : USForm) :
    untlDepth (USForm.snce ψ φ) = max (untlDepth ψ) (untlDepth φ) := rfl

/-- An `untl`-free formula has nesting depth zero. -/
theorem untlDepth_eq_zero_of_isSOnly {φ : USForm} (h : IsSOnly φ) : untlDepth φ = 0 := by
  induction h with
  | leaf i => rfl
  | bot => rfl
  | imp _ _ ihφ ihψ => rw [untlDepth_imp, ihφ, ihψ]; rfl
  | snce _ _ ihψ ihφ => rw [untlDepth_snce, ihψ, ihφ]; rfl

/-- Conversely, nesting depth zero means `untl`-free. -/
theorem isSOnly_of_untlDepth_eq_zero : ∀ {φ : USForm}, untlDepth φ = 0 → IsSOnly φ
  | .leaf i, _ => IsSOnly.leaf i
  | .bot, _ => IsSOnly.bot
  | .imp φ ψ, h => by
      rw [untlDepth_imp] at h
      exact IsSOnly.imp (isSOnly_of_untlDepth_eq_zero (by omega))
        (isSOnly_of_untlDepth_eq_zero (by omega))
  | .untl ψ φ, h => by rw [untlDepth_untl] at h; omega
  | .snce ψ φ, h => by
      rw [untlDepth_snce] at h
      exact IsSOnly.snce (isSOnly_of_untlDepth_eq_zero (by omega))
        (isSOnly_of_untlDepth_eq_zero (by omega))

/-! ## The two base-case bridges

Together these are GHR's `n = 1` case: at nesting depth at most one, Lemma 10.2.6's hypothesis
holds, and conversely 10.2.6's hypothesis bounds the nesting depth by one. -/

/-- A formula all of whose maximal `untl`s are pure types has nesting depth at most one. -/
theorem untlDepth_le_one_of_hasPureUTypes : ∀ {φ : USForm}, HasPureUTypes φ → untlDepth φ ≤ 1
  | .leaf _, _ => by rw [untlDepth_leaf]; omega
  | .bot, _ => by rw [untlDepth_bot]; omega
  | .imp φ ψ, h => by
      have h1 := untlDepth_le_one_of_hasPureUTypes
        (fun u hu => h u (mem_uTypes_imp.mpr (Or.inl hu)))
      have h2 := untlDepth_le_one_of_hasPureUTypes
        (fun u hu => h u (mem_uTypes_imp.mpr (Or.inr hu)))
      rw [untlDepth_imp]; omega
  | .snce ψ φ, h => by
      have h1 := untlDepth_le_one_of_hasPureUTypes
        (fun u hu => h u (mem_uTypes_snce.mpr (Or.inl hu)))
      have h2 := untlDepth_le_one_of_hasPureUTypes
        (fun u hu => h u (mem_uTypes_snce.mpr (Or.inr hu)))
      rw [untlDepth_snce]; omega
  | .untl ψ φ, h => by
      obtain ⟨A, B, hEq, hAs, hBs, _, _⟩ := h (USForm.untl ψ φ) (by simp)
      injection hEq with h1 h2
      subst h1
      subst h2
      rw [untlDepth_untl, untlDepth_eq_zero_of_isSOnly hBs, untlDepth_eq_zero_of_isSOnly hAs]
      omega

/--
**GHR Lemma 10.2.7's base case**, as the converse bridge: at nesting depth at most one, every
maximal `untl` has `untl`-free arguments, and `NoSnceUnderUntl` makes them `snce`-free, so every
collected type is an `IsPureType`. This is what makes the budget's base case Lemma 10.2.6's
`sepMulti`, exactly as GHR's `n = 1` case is 10.2.6.
-/
theorem hasPureUTypes_of_untlDepth_le_one {φ : USForm} (h : NoSnceUnderUntl φ)
    (hd : untlDepth φ ≤ 1) : HasPureUTypes φ := by
  revert hd
  induction h with
  | leaf i => intro _ u hu; simp at hu
  | bot => intro _ u hu; simp at hu
  | imp _ _ ihφ ihψ =>
      intro hd u hu
      rw [untlDepth_imp] at hd
      rcases mem_uTypes_imp.mp hu with h' | h'
      · exact ihφ (by omega) u h'
      · exact ihψ (by omega) u h'
  | snce _ _ ihψ ihφ =>
      intro hd u hu
      rw [untlDepth_snce] at hd
      rcases mem_uTypes_snce.mp hu with h' | h'
      · exact ihψ (by omega) u h'
      · exact ihφ (by omega) u h'
  | @untl ψ χ hψ hχ =>
      intro hd u hu
      have hu' : u = USForm.untl ψ χ := by simpa using hu
      subst hu'
      rw [untlDepth_untl] at hd
      exact ⟨χ, ψ, rfl, isSOnly_of_untlDepth_eq_zero (by omega),
        isSOnly_of_untlDepth_eq_zero (by omega), hχ, hψ⟩

/-! ## The collected types, and GHR's inner types `U(Xᵢⱼ, Yᵢⱼ)` -/

/-- Every collected maximal type is `untl`-headed. -/
theorem exists_untl_of_mem_uTypes :
    ∀ {φ u : USForm}, u ∈ uTypes φ → ∃ a b : USForm, u = USForm.untl a b
  | .leaf _, _, hu => absurd hu (by simp)
  | .bot, _, hu => absurd hu (by simp)
  | .imp φ ψ, u, hu => by
      rcases mem_uTypes_imp.mp hu with h | h
      · exact exists_untl_of_mem_uTypes h
      · exact exists_untl_of_mem_uTypes h
  | .untl ψ φ, u, hu => ⟨ψ, φ, by simpa using hu⟩
  | .snce ψ φ, u, hu => by
      rcases mem_uTypes_snce.mp hu with h | h
      · exact exists_untl_of_mem_uTypes h
      · exact exists_untl_of_mem_uTypes h

/-- A collected maximal type nests no deeper than the formula it was collected from. -/
theorem untlDepth_le_of_mem_uTypes :
    ∀ {φ u : USForm}, u ∈ uTypes φ → untlDepth u ≤ untlDepth φ
  | .leaf _, _, hu => absurd hu (by simp)
  | .bot, _, hu => absurd hu (by simp)
  | .imp φ ψ, u, hu => by
      rcases mem_uTypes_imp.mp hu with h | h
      · have := untlDepth_le_of_mem_uTypes h; rw [untlDepth_imp]; omega
      · have := untlDepth_le_of_mem_uTypes h; rw [untlDepth_imp]; omega
  | .untl ψ φ, u, hu => by
      have hu' : u = USForm.untl ψ φ := by simpa using hu
      exact le_of_eq (by rw [hu'])
  | .snce ψ φ, u, hu => by
      rcases mem_uTypes_snce.mp hu with h | h
      · have := untlDepth_le_of_mem_uTypes h; rw [untlDepth_snce]; omega
      · have := untlDepth_le_of_mem_uTypes h; rw [untlDepth_snce]; omega

/-- A maximal type of an `snce`-free formula is itself `snce`-free. -/
theorem isUOnly_of_mem_uTypes {φ : USForm} (h : IsUOnly φ) : ∀ u ∈ uTypes φ, IsUOnly u := by
  induction h with
  | leaf i => intro u hu; simp at hu
  | bot => intro u hu; simp at hu
  | imp _ _ ihφ ihψ =>
      intro u hu
      rcases mem_uTypes_imp.mp hu with h' | h'
      · exact ihφ u h'
      · exact ihψ u h'
  | @untl ψ χ hψ hχ _ _ =>
      intro u hu
      have hu' : u = USForm.untl ψ χ := by simpa using hu
      exact hu' ▸ IsUOnly.untl hψ hχ

/-- Under GHR 10.2.7's hypothesis, both arguments of every maximal `untl` are `snce`-free. -/
theorem isUOnly_args_of_mem_uTypes {φ : USForm} (h : NoSnceUnderUntl φ) :
    ∀ {a b : USForm}, USForm.untl a b ∈ uTypes φ → IsUOnly a ∧ IsUOnly b := by
  induction h with
  | leaf i => intro a b hu; simp at hu
  | bot => intro a b hu; simp at hu
  | imp _ _ ihφ ihψ =>
      intro a b hu
      rcases mem_uTypes_imp.mp hu with h' | h'
      · exact ihφ h'
      · exact ihψ h'
  | snce _ _ ihψ ihφ =>
      intro a b hu
      rcases mem_uTypes_snce.mp hu with h' | h'
      · exact ihψ h'
      · exact ihφ h'
  | @untl ψ χ hψ hχ =>
      intro a b hu
      have hEq : USForm.untl a b = USForm.untl ψ χ := by simpa using hu
      injection hEq with h1 h2
      subst h1
      subst h2
      exact ⟨hψ, hχ⟩

/-- The maximal `untl`s of one maximal `untl`'s two arguments. -/
def argUTypes : USForm → List USForm
  | .untl ψ φ => uTypes ψ ++ uTypes φ
  | _ => []

theorem argUTypes_untl (ψ φ : USForm) :
    argUTypes (USForm.untl ψ φ) = uTypes ψ ++ uTypes φ := rfl

/--
GHR's **inner types** `U(Xᵢⱼ, Yᵢⱼ)`: the deduplicated concatenation of the maximal `untl`s of
both arguments of each maximal `untl` of `φ`. These are the subformulae the abstraction step
replaces by fresh atoms.
-/
def innerTypes (φ : USForm) : List USForm := ((uTypes φ).flatMap argUTypes).dedup

theorem mem_innerTypes {φ u : USForm} :
    u ∈ innerTypes φ ↔ ∃ w ∈ uTypes φ, u ∈ argUTypes w := by
  rw [innerTypes, List.mem_dedup, List.mem_flatMap]

/-- A maximal `untl` of a maximal `untl`'s argument is an inner type. -/
theorem mem_innerTypes_of_mem_uTypes_arg {φ a b u : USForm}
    (hw : USForm.untl a b ∈ uTypes φ) (hu : u ∈ uTypes a ∨ u ∈ uTypes b) : u ∈ innerTypes φ := by
  refine mem_innerTypes.mpr ⟨USForm.untl a b, hw, ?_⟩
  rw [argUTypes_untl, List.mem_append]
  exact hu

/-- Every inner type is `untl`-headed. -/
theorem exists_untl_of_mem_innerTypes {φ u : USForm} (hu : u ∈ innerTypes φ) :
    ∃ a b : USForm, u = USForm.untl a b := by
  obtain ⟨w, hw, hu'⟩ := mem_innerTypes.mp hu
  obtain ⟨a, b, rfl⟩ := exists_untl_of_mem_uTypes hw
  rw [argUTypes_untl, List.mem_append] at hu'
  rcases hu' with h | h
  · exact exists_untl_of_mem_uTypes h
  · exact exists_untl_of_mem_uTypes h

/-- Under GHR 10.2.7's hypothesis every inner type is `snce`-free. -/
theorem isUOnly_of_mem_innerTypes {φ : USForm} (h : NoSnceUnderUntl φ) :
    ∀ u ∈ innerTypes φ, IsUOnly u := by
  intro u hu
  obtain ⟨w, hw, hu'⟩ := mem_innerTypes.mp hu
  obtain ⟨a, b, rfl⟩ := exists_untl_of_mem_uTypes hw
  obtain ⟨ha, hb⟩ := isUOnly_args_of_mem_uTypes h hw
  rw [argUTypes_untl, List.mem_append] at hu'
  rcases hu' with hm | hm
  · exact isUOnly_of_mem_uTypes ha u hm
  · exact isUOnly_of_mem_uTypes hb u hm

/--
**GHR's licensing sentence, proved rather than asserted**: "the level of nesting of U in
`U(Aᵢ, Bᵢ)` must be strictly greater than that in its subformula `U(Xᵢⱼ, Yᵢⱼ)`". An inner type
is a maximal `untl` of one of a maximal `untl`'s arguments, so it sits strictly below the `1 +`
that the enclosing `untl` contributes. This is what part (c) of the strict-decrease obligation
consumes.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 (the sentence licensing the induction, asserted
there without proof)
-/
theorem untlDepth_lt_of_mem_innerTypes {φ u : USForm} (hu : u ∈ innerTypes φ) :
    untlDepth u < untlDepth φ := by
  obtain ⟨w, hw, hu'⟩ := mem_innerTypes.mp hu
  obtain ⟨a, b, rfl⟩ := exists_untl_of_mem_uTypes hw
  have hwd : untlDepth (USForm.untl a b) ≤ untlDepth φ := untlDepth_le_of_mem_uTypes hw
  rw [untlDepth_untl] at hwd
  rw [argUTypes_untl, List.mem_append] at hu'
  rcases hu' with h | h
  · have := untlDepth_le_of_mem_uTypes h; omega
  · have := untlDepth_le_of_mem_uTypes h; omega

/-! ## The abstraction of the inner types

`abstrArgs` is `mapU` at a `g` that is itself a `mapU` — the landed operator composed with
itself, which is how "abstract inside a maximal `untl`'s arguments" is said without a second
substitution operator. -/

/-- GHR's "abstract each `U(Xᵢⱼ, Yᵢⱼ)` to a fresh atom `zᵢⱼ`", as a function on maximal types:
rewrite inside a maximal `untl`'s two arguments, and leave anything else alone. -/
def abstrArgs (j : ℕ) (L : List USForm) : USForm → USForm
  | .untl ψ φ => .untl (mapU (abstrFn j L) ψ) (mapU (abstrFn j L) φ)
  | u => u

theorem abstrArgs_untl (j : ℕ) (L : List USForm) (ψ φ : USForm) :
    abstrArgs j L (USForm.untl ψ φ) =
      USForm.untl (mapU (abstrFn j L) ψ) (mapU (abstrFn j L) φ) := rfl

/-- Abstracting maximal types preserves `snce`-freeness: each node either becomes a leaf or is
kept with its arguments untouched. -/
theorem isUOnly_mapU_abstrFn {j : ℕ} {L : List USForm} {ψ : USForm} (h : IsUOnly ψ) :
    IsUOnly (mapU (abstrFn j L) ψ) := by
  induction h with
  | leaf i => exact IsUOnly.leaf i
  | bot => exact IsUOnly.bot
  | imp _ _ ihφ ihψ => exact IsUOnly.imp ihφ ihψ
  | @untl a b ha hb _ _ =>
      rw [show mapU (abstrFn j L) (USForm.untl a b) = abstrFn j L (USForm.untl a b) from rfl]
      by_cases hmem : USForm.untl a b ∈ L
      · rw [show abstrFn j L (USForm.untl a b) =
            USForm.leaf (j + L.idxOf (USForm.untl a b)) from by
          simp only [abstrFn]; rw [if_pos hmem]]
        exact IsUOnly.leaf _
      · rw [show abstrFn j L (USForm.untl a b) = USForm.untl a b from by
          simp only [abstrFn]; rw [if_neg hmem]]
        exact IsUOnly.untl ha hb

/-- Abstracting *every* maximal type of a formula makes it `untl`-free. -/
theorem isSOnly_mapU_abstrFn {j : ℕ} {L : List USForm} {ψ : USForm}
    (h : ∀ u ∈ uTypes ψ, u ∈ L) : IsSOnly (mapU (abstrFn j L) ψ) := by
  refine isSOnly_of_uTypes_empty fun u hu => ?_
  obtain ⟨h1, h2⟩ := uTypes_mapU_abstr hu
  exact h2 (h u h1)

/--
**The abstracted formula satisfies GHR Lemma 10.2.6's hypothesis.** Every maximal `untl` of
`mapU (abstrArgs j (innerTypes φ)) φ` has `untl`-free arguments, because each of its own maximal
`untl`s was an inner type and became a leaf, and `snce`-free arguments, because
`NoSnceUnderUntl φ` gives that before the abstraction and the abstraction introduces only leaves.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 (the "abstract each `U(Xᵢⱼ, Yᵢⱼ)` to a fresh atom,
separate the result by 10.2.6" step)
-/
theorem hasPureUTypes_mapU_abstrArgs {φ : USForm} (h : NoSnceUnderUntl φ) {j : ℕ} :
    HasPureUTypes (mapU (abstrArgs j (innerTypes φ)) φ) := by
  intro u hu
  obtain ⟨w, hw, hu'⟩ := mem_uTypes_mapU hu
  obtain ⟨a, b, rfl⟩ := exists_untl_of_mem_uTypes hw
  obtain ⟨ha, hb⟩ := isUOnly_args_of_mem_uTypes h hw
  rw [abstrArgs_untl, uTypes_untl, List.mem_singleton] at hu'
  subst hu'
  exact ⟨mapU (abstrFn j (innerTypes φ)) b, mapU (abstrFn j (innerTypes φ)) a, rfl,
    isSOnly_mapU_abstrFn (fun v hv => mem_innerTypes_of_mem_uTypes_arg hw (Or.inr hv)),
    isSOnly_mapU_abstrFn (fun v hv => mem_innerTypes_of_mem_uTypes_arg hw (Or.inl hv)),
    isUOnly_mapU_abstrFn hb, isUOnly_mapU_abstrFn ha⟩

/-! ## The three parts of the strict-decrease obligation -/

/--
**Part (a) of GHR Lemma 10.2.7's strict-decrease obligation: abstraction drops the measure to at
most one.** Abstracting every inner type leaves every maximal `untl` with `untl`-free arguments,
so the depth falls to at most `1` from at least `2`.

This is the form the *measure* argument consumes; `hasPureUTypes_mapU_abstrArgs` is the same fact
in the form Lemma 10.2.6 consumes, and the two are deliberately kept distinct.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 (the abstraction step)
-/
theorem untlDepth_mapU_abstrArgs_le_one {φ : USForm} (h : NoSnceUnderUntl φ) {j : ℕ} :
    untlDepth (mapU (abstrArgs j (innerTypes φ)) φ) ≤ 1 :=
  untlDepth_le_one_of_hasPureUTypes (hasPureUTypes_mapU_abstrArgs h)

/--
**Part (b) of GHR Lemma 10.2.7's strict-decrease obligation: separation does not raise the
measure.** Proved here from `hasPureUTypes_sepMulti` together with
`untlDepth_le_one_of_hasPureUTypes` — two lines, not an induction.

There is **no** landed counterpart, and `uTypes_sepMulti` is not it: that lemma bounds `untl`
*types* and says nothing about `untl` nesting, so citing it here would discharge a different
claim.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 (the "separate the result by 10.2.6" step, at the
level of the measure)
-/
theorem untlDepth_sepMulti_le_one {φ : USForm} (h : HasPureUTypes φ) :
    untlDepth (sepMulti φ) ≤ 1 :=
  untlDepth_le_one_of_hasPureUTypes (hasPureUTypes_sepMulti h)

/-- Every value of the reindexing nests no deeper than the abstracted list does. This is the
depth-indexed analogue of the landed `mem_uTypes_unabstrFn`, whose `IsPureType` hypothesis does
not transfer: an inner type need not be pure. -/
theorem untlDepth_unabstrFn_le {j d : ℕ} {L : List USForm} (hLd : ∀ u ∈ L, untlDepth u ≤ d)
    (i : ℕ) : untlDepth (unabstrFn j L i) ≤ d := by
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h, untlDepth_leaf]; omega
  · exact hLd _ h

/-- Substituting into an `untl`-free formula nests no deeper than the substitution's image. -/
theorem untlDepth_substLeaf_le_of_isSOnly {h : ℕ → USForm} {d : ℕ}
    (hh : ∀ i, untlDepth (h i) ≤ d) {χ : USForm} (hχ : IsSOnly χ) :
    untlDepth (substLeaf h χ) ≤ d := by
  induction hχ with
  | leaf i => exact hh i
  | bot => rw [show substLeaf h USForm.bot = USForm.bot from rfl, untlDepth_bot]; omega
  | @imp a b _ _ iha ihb =>
      rw [show substLeaf h (USForm.imp a b) = USForm.imp (substLeaf h a) (substLeaf h b) from rfl,
        untlDepth_imp]
      omega
  | @snce a b _ _ iha ihb =>
      rw [show substLeaf h (USForm.snce a b) = USForm.snce (substLeaf h a) (substLeaf h b) from
          rfl, untlDepth_snce]
      omega

/--
**Part (c) of GHR Lemma 10.2.7's strict-decrease obligation: the reindexed form's depth is
bounded by the abstracted list's.**

The composite of `untlDepth_unabstrFn_le` (every value of the reindexing nests at most `d`) and
`untlDepth_substLeaf_le_of_isSOnly` (a separated `snce` constituent has `IsSOnly` arguments by
`IsSeparated.snce`, so every `untl` it acquires comes from the reindexing). Instantiated at
`L = innerTypes φ` and `d = untlDepth φ - 1` through `untlDepth_lt_of_mem_innerTypes`, this is
GHR's "the pre-abstraction depth less one", and it is **this** bound, not part (a), that licenses
the recursive call.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 (the bound licensing the induction hypothesis)
-/
theorem untlDepth_snce_substLeaf_le {j d : ℕ} {L : List USForm}
    (hLd : ∀ u ∈ L, untlDepth u ≤ d) {ψ χ : USForm} (hψ : IsSOnly ψ) (hχ : IsSOnly χ) :
    untlDepth (USForm.snce (substLeaf (unabstrFn j L) ψ) (substLeaf (unabstrFn j L) χ)) ≤ d := by
  have h1 := untlDepth_substLeaf_le_of_isSOnly (untlDepth_unabstrFn_le (j := j) hLd) hψ
  have h2 := untlDepth_substLeaf_le_of_isSOnly (untlDepth_unabstrFn_le (j := j) hLd) hχ
  rw [untlDepth_snce]
  omega

/-! ## The reindexing analogues that the landed purity hypothesis does not reach -/

/-- `mapS k` is the identity on every value of the reindexing, because each value is a leaf or an
`untl`-headed member of the abstracted list. Membership of a `uTypes`-collected list is what
gives `untl`-headedness; no purity is needed, which is what distinguishes this from the landed
`mapS_unabstrFn`. -/
theorem mapS_unabstrFn_of_untl {k : USForm → USForm} {j : ℕ} {L : List USForm}
    (hLt : ∀ u ∈ L, ∃ a b : USForm, u = USForm.untl a b) (i : ℕ) :
    mapS k (unabstrFn j L i) = unabstrFn j L i := by
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h]; rfl
  · obtain ⟨a, b, hEq⟩ := hLt _ h
    rw [hEq]; rfl

/-- Every value of the reindexing is `snce`-free, given that the abstracted list is. -/
theorem isUOnly_unabstrFn {j : ℕ} {L : List USForm} (hLu : ∀ u ∈ L, IsUOnly u) (i : ℕ) :
    IsUOnly (unabstrFn j L i) := by
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h]; exact IsUOnly.leaf i
  · exact hLu _ h

/-- Every value of the reindexing is separated. The analogue of the landed
`isSeparated_unabstrFn` with the `IsPureType` hypothesis weakened to `IsUOnly`. -/
theorem isSeparated_unabstrFn_of_isUOnly {j : ℕ} {L : List USForm} (hLu : ∀ u ∈ L, IsUOnly u)
    (i : ℕ) : IsSeparated (unabstrFn j L i) := by
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h]; exact IsSeparated.leaf i
  · exact IsSeparated.ofIsUOnly (hLu _ h)

/-- Substituting `snce`-free formulas into an `snce`-free formula keeps it `snce`-free. -/
theorem isUOnly_substLeaf {h : ℕ → USForm} (hh : ∀ i, IsUOnly (h i)) {ψ : USForm}
    (hψ : IsUOnly ψ) : IsUOnly (substLeaf h ψ) := by
  induction hψ with
  | leaf i => exact hh i
  | bot => exact IsUOnly.bot
  | @imp a b _ _ iha ihb => exact IsUOnly.imp iha ihb
  | @untl a b _ _ iha ihb => exact IsUOnly.untl iha ihb

/-- Substituting into an `untl`-free formula re-establishes GHR 10.2.7's hypothesis, given that
the substitution's image satisfies it. -/
theorem noSnceUnderUntl_substLeaf_of_isSOnly {h : ℕ → USForm}
    (hh : ∀ i, NoSnceUnderUntl (h i)) {χ : USForm} (hχ : IsSOnly χ) :
    NoSnceUnderUntl (substLeaf h χ) := by
  induction hχ with
  | leaf i => exact hh i
  | bot => exact NoSnceUnderUntl.bot
  | @imp a b _ _ iha ihb => exact NoSnceUnderUntl.imp iha ihb
  | @snce a b _ _ iha ihb => exact NoSnceUnderUntl.snce iha ihb

/-- Every value of the reindexing satisfies GHR 10.2.7's hypothesis. -/
theorem noSnceUnderUntl_unabstrFn {j : ℕ} {L : List USForm} (hLu : ∀ u ∈ L, IsUOnly u) (i : ℕ) :
    NoSnceUnderUntl (unabstrFn j L i) :=
  noSnceUnderUntl_of_isUOnly (isUOnly_unabstrFn hLu i)

/-- **The reindexing inverts the two-level abstraction syntactically.** Each `untl` case is the
landed `substLeaf_mapU_abstr` applied to the node's two arguments; this is the only place the
freshness of the abstraction indices is used. -/
theorem substLeaf_mapU_abstrArgs {j : ℕ} {L : List USForm} : ∀ {φ : USForm}, φ.maxLeaf < j →
    substLeaf (unabstrFn j L) (mapU (abstrArgs j L) φ) = φ
  | .leaf i, hi => by
      rw [show mapU (abstrArgs j L) (USForm.leaf i) = USForm.leaf i from rfl,
        show substLeaf (unabstrFn j L) (USForm.leaf i) = unabstrFn j L i from rfl]
      exact unabstrFn_of_lt hi
  | .bot, _ => rfl
  | .imp φ ψ, hi => by
      have h1 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ ψ.maxLeaf) hi
      have h2 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_right φ.maxLeaf _) hi
      change USForm.imp (substLeaf (unabstrFn j L) (mapU (abstrArgs j L) φ))
          (substLeaf (unabstrFn j L) (mapU (abstrArgs j L) ψ)) = USForm.imp φ ψ
      rw [substLeaf_mapU_abstrArgs h1, substLeaf_mapU_abstrArgs h2]
  | .snce ψ φ, hi => by
      have h1 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ φ.maxLeaf) hi
      have h2 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_right ψ.maxLeaf _) hi
      change USForm.snce (substLeaf (unabstrFn j L) (mapU (abstrArgs j L) ψ))
          (substLeaf (unabstrFn j L) (mapU (abstrArgs j L) φ)) = USForm.snce ψ φ
      rw [substLeaf_mapU_abstrArgs h1, substLeaf_mapU_abstrArgs h2]
  | .untl ψ φ, hi => by
      have h1 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ φ.maxLeaf) hi
      have h2 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_right ψ.maxLeaf _) hi
      rw [show mapU (abstrArgs j L) (USForm.untl ψ φ) =
          USForm.untl (mapU (abstrFn j L) ψ) (mapU (abstrFn j L) φ) from rfl]
      change USForm.untl (substLeaf (unabstrFn j L) (mapU (abstrFn j L) ψ))
          (substLeaf (unabstrFn j L) (mapU (abstrFn j L) φ)) = USForm.untl ψ φ
      rw [substLeaf_mapU_abstr h1, substLeaf_mapU_abstr h2]

/--
**The reindexing-and-recursion pass of GHR Lemma 10.2.7.**

`S` is Lemma 10.2.6's output: separated. Substituting the inner types back for their fresh leaves
leaves the `untl` nodes separated — their arguments are `snce`-free and the reindexing's image is
too — and recontaminates exactly the `snce` constituents, whose arguments were `untl`-free.
`mapS k` fires `k` at each of those, and `hk` is the recursive call's contract, available at every
formula of nesting depth at most `d`: the pre-abstraction depth less one, by part (c).

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 (the "substitute back, and re-separate the
constituents the substitution made impure" step)
-/
theorem mapS_substLeaf_spec7 {j d : ℕ} {L : List USForm}
    (hLt : ∀ u ∈ L, ∃ a b : USForm, u = USForm.untl a b) (hLu : ∀ u ∈ L, IsUOnly u)
    (hLd : ∀ u ∈ L, untlDepth u ≤ d) {k : USForm → USForm}
    (hk : ∀ χ : USForm, untlDepth χ ≤ d → NoSnceUnderUntl χ →
      IsSeparated (k χ) ∧ ∀ v t, usTruth v t (k χ) ↔ usTruth v t χ)
    {S : USForm} (hS : IsSeparated S) :
    IsSeparated (mapS k (substLeaf (unabstrFn j L) S)) ∧
      ∀ v t, usTruth v t (mapS k (substLeaf (unabstrFn j L) S)) ↔
        usTruth v t (substLeaf (unabstrFn j L) S) := by
  induction hS with
  | leaf i =>
      rw [show substLeaf (unabstrFn j L) (USForm.leaf i) = unabstrFn j L i from rfl,
        mapS_unabstrFn_of_untl hLt i]
      exact ⟨isSeparated_unabstrFn_of_isUOnly hLu i, fun _ _ => Iff.rfl⟩
  | bot => exact ⟨IsSeparated.bot, fun _ _ => Iff.rfl⟩
  | @imp a b _ _ iha ihb =>
      simp only [substLeaf, mapS, usTruth_imp_iff]
      exact ⟨IsSeparated.imp iha.1 ihb.1, fun v t => imp_congr (iha.2 v t) (ihb.2 v t)⟩
  | @untl a b ha hb =>
      refine ⟨?_, fun _ _ => Iff.rfl⟩
      exact IsSeparated.untl (isUOnly_substLeaf (isUOnly_unabstrFn hLu) ha)
        (isUOnly_substLeaf (isUOnly_unabstrFn hLu) hb)
  | @snce a b ha hb =>
      simp only [substLeaf, mapS]
      exact hk (USForm.snce (substLeaf (unabstrFn j L) a) (substLeaf (unabstrFn j L) b))
        (untlDepth_snce_substLeaf_le hLd ha hb)
        (NoSnceUnderUntl.snce
          (noSnceUnderUntl_substLeaf_of_isSOnly (noSnceUnderUntl_unabstrFn hLu) ha)
          (noSnceUnderUntl_substLeaf_of_isSOnly (noSnceUnderUntl_unabstrFn hLu) hb))

/-! ## GHR Lemma 10.2.7 as a budget recursion -/

/-- One step of GHR Lemma 10.2.7's induction, with `k` standing for the recursive call: at
nesting depth at most one the formula satisfies Lemma 10.2.6's hypothesis and `sepMulti` is the
answer, which is GHR's `n = 1` base case; above that, abstract the inner types, separate by
10.2.6, reindex back, and fire `k` at the recontaminated `snce` constituents. -/
def sep7Body (k : USForm → USForm) (φ : USForm) : USForm :=
  if untlDepth φ ≤ 1 then sepMulti φ
  else mapS k (substLeaf (unabstrFn φ.freshLeaf (innerTypes φ))
    (sepMulti (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ)))

theorem sep7Body_of_le {k : USForm → USForm} {φ : USForm} (h : untlDepth φ ≤ 1) :
    sep7Body k φ = sepMulti φ := by
  rw [sep7Body, if_pos h]

theorem sep7Body_of_gt {k : USForm → USForm} {φ : USForm} (h : ¬ untlDepth φ ≤ 1) :
    sep7Body k φ = mapS k (substLeaf (unabstrFn φ.freshLeaf (innerTypes φ))
      (sepMulti (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ))) := by
  rw [sep7Body, if_neg h]

/-- GHR Lemma 10.2.7's construction with an explicit budget for the nesting depth left to
eliminate, structural on the budget. A plain `def`, deliberately not `noncomputable`. -/
def sep7Fuel : ℕ → USForm → USForm
  | 0, φ => φ
  | n + 1, φ => sep7Body (sep7Fuel n) φ

/-- **GHR Lemma 10.2.7's separating function**: the budget instantiated at the measure, so the
budget appears in no public statement. A plain `def`, deliberately not `noncomputable`.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 -/
def sep7 (φ : USForm) : USForm := sep7Fuel (untlDepth φ) φ

/--
**GHR Lemma 10.2.7**, with the budget explicit: a formula containing no `snce` nested within an
`untl` is equivalent to a syntactically separated formula.

The three decrease obligations are discharged here, each by its own named result and none
standing in for another. Part (a), `untlDepth_mapU_abstrArgs_le_one`, is the measure-level
statement that the abstraction reaches the base case; `hasPureUTypes_mapU_abstrArgs` is the same
fact in the form Lemma 10.2.6 consumes and is what is applied at `hpure`. Part (b),
`untlDepth_sepMulti_le_one`, is the measure-level statement that `sepMulti` leaves it there.
Part (c), `untlDepth_snce_substLeaf_le`, is applied inside `mapS_substLeaf_spec7` and is what
licenses the recursive call `ih` at the reduced budget: every inner type nests strictly less than
`φ` by `untlDepth_lt_of_mem_innerTypes`, so `hLd` holds at `n`.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7
-/
theorem sep7Fuel_spec : ∀ (n : ℕ) (φ : USForm), untlDepth φ ≤ n → NoSnceUnderUntl φ →
    IsSeparated (sep7Fuel n φ) ∧ ∀ v t, usTruth v t (sep7Fuel n φ) ↔ usTruth v t φ := by
  intro n
  induction n with
  | zero =>
      intro φ hd _
      exact ⟨IsSeparated.ofIsSOnly (isSOnly_of_untlDepth_eq_zero (Nat.le_zero.mp hd)),
        fun _ _ => Iff.rfl⟩
  | succ n ih =>
      intro φ hd hns
      by_cases hle : untlDepth φ ≤ 1
      · have hpure : HasPureUTypes φ := hasPureUTypes_of_untlDepth_le_one hns hle
        rw [show sep7Fuel (n + 1) φ = sepMulti φ from by
          rw [show sep7Fuel (n + 1) φ = sep7Body (sep7Fuel n) φ from rfl, sep7Body_of_le hle]]
        exact ⟨isSeparated_sepMulti hpure, fun v t => usTruth_sepMulti hpure v t⟩
      · have hmax : φ.maxLeaf < φ.freshLeaf := USForm.lt_freshLeaf φ
        have hLt : ∀ u ∈ innerTypes φ, ∃ a b : USForm, u = USForm.untl a b :=
          fun u hu => exists_untl_of_mem_innerTypes hu
        have hLu : ∀ u ∈ innerTypes φ, IsUOnly u := isUOnly_of_mem_innerTypes hns
        have hLd : ∀ u ∈ innerTypes φ, untlDepth u ≤ n := by
          intro u hu
          have := untlDepth_lt_of_mem_innerTypes hu
          omega
        have hpure : HasPureUTypes (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ) :=
          hasPureUTypes_mapU_abstrArgs hns
        obtain ⟨hsep, htruth⟩ :=
          mapS_substLeaf_spec7 (j := φ.freshLeaf) hLt hLu hLd
            (fun χ hc hp => ih χ hc hp) (isSeparated_sepMulti hpure)
        rw [show sep7Fuel (n + 1) φ = mapS (sep7Fuel n)
            (substLeaf (unabstrFn φ.freshLeaf (innerTypes φ))
              (sepMulti (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ))) from by
          rw [show sep7Fuel (n + 1) φ = sep7Body (sep7Fuel n) φ from rfl, sep7Body_of_gt hle]]
        refine ⟨hsep, fun v t => ?_⟩
        calc usTruth v t (mapS (sep7Fuel n)
                (substLeaf (unabstrFn φ.freshLeaf (innerTypes φ))
                  (sepMulti (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ))))
          _ ↔ usTruth v t (substLeaf (unabstrFn φ.freshLeaf (innerTypes φ))
                (sepMulti (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ))) := htruth v t
          _ ↔ usTruth (fun i s => usTruth v s (unabstrFn φ.freshLeaf (innerTypes φ) i)) t
                (sepMulti (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ)) :=
              usTruth_substLeaf _ _ _ _
          _ ↔ usTruth (fun i s => usTruth v s (unabstrFn φ.freshLeaf (innerTypes φ) i)) t
                (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ) :=
              usTruth_sepMulti hpure _ t
          _ ↔ usTruth v t (substLeaf (unabstrFn φ.freshLeaf (innerTypes φ))
                (mapU (abstrArgs φ.freshLeaf (innerTypes φ)) φ)) :=
              (usTruth_substLeaf _ _ _ _).symm
          _ ↔ usTruth v t φ := by rw [substLeaf_mapU_abstrArgs hmax]

/--
**GHR Lemma 10.2.7**, the separatedness half: a formula containing no `S` nested within a `U` is
syntactically separable.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 (the conclusion's separatedness)
-/
theorem isSeparated_sep7 {φ : USForm} (h : NoSnceUnderUntl φ) : IsSeparated (sep7 φ) :=
  (sep7Fuel_spec (untlDepth φ) φ le_rfl h).1

/--
**GHR Lemma 10.2.7**, the equivalence half.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.7 (the equivalence)
-/
theorem usTruth_sep7 {φ : USForm} (h : NoSnceUnderUntl φ) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (sep7 φ) ↔ usTruth v t φ :=
  (sep7Fuel_spec (untlDepth φ) φ le_rfl h).2 v t

end FormalSystem.Metalogic.Expressiveness.SeparationZ
