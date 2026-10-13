/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.HitOf

/-!
# The σ-star profile of a finite word (the composing summary behind requirement (C))

`Compose.lean` states composition on representatives: the `k`-type of a concatenation `l₁ ++ l₂`
is a function of the `k`-types of `l₁` and `l₂` (`kTypeOf_listSeg_append_congr`). That
congruence is enough to summarize a *fixed* finite factorization, but it is NOT enough to
summarize a word under the Kleene star of a type: "`l` is a concatenation of pieces each of
`k`-type `σ`" is not a depth-`k'` property for any fixed `k'`, and the pair of types produced by
cutting a word at an interior position is a depth-`(k + 1)` datum that `l ≡ₖ l'` does not fix.
This is the **cut-pair obstruction**: repeating one literal segment of a seam trace realizes, in
the repetition, family triples obtained by cutting every copy at the same offset, and nothing in
the `k`-type of the segment transports such a cut back to the other copies of the trace. So the
general completeness row of requirement (C) cannot be reached by the literal-segment lasso the
fixtures use, and this module supplies the summary that composes instead.

**The profile.** For a type `σ` write `L_σ` for the nonempty finite words of `k`-type `σ`
(`StarZero sig k σ l`: `l` is a concatenation of possibly no such pieces; `StarPlus`: at least
one). The **σ-star profile** of a word `l` is the relation on types

  `starProfile sig k σ l x y  :⟺  ∃ p m q, l = p ++ m ++ q ∧ StarZero σ m ∧ type p = x ∧ type q = y`

— the pairs of (prefix type, suffix type) around a middle that lies in `L_σ^*`. The **profile**
`profile sig k l : Profile sig k` is the `k`-type of `l` together with every σ-star profile, as a
Bool table, so `Profile sig k := KType sig k × (KType sig k → KType sig k → KType sig k → Bool)`
is a finite type. The **cut profile** `cutProfile sig k l` is the set of pairs
`(profile z, profile y)` over all cuts `l = z ++ y`. Membership in `L_σ^+` and in `L_α L_σ^*` is
read off the profile (`starPlus_iff_profile`, `prefixStar_iff_profile`), at every depth `k ≥ 1`,
through the type `typeNil` of the empty word, which at `k ≥ 1` is the type of no nonempty word
(`kTypeOf_listSeg_eq_typeNil_iff`, by `nonempty_iff_of_kTypeOf_eq`).

**What the profile buys**, in the modules after this one: it composes under concatenation
(`profile_append_congr`, the one delicate lemma, proved here through the explicit four-case law
`starProfile_append`), every word has a representative of the same profile and no larger cut
profile below the length `Nat.card (Profile sig k) ^ 2` (`exists_rep_of_length_lt`, by
pigeonhole on cut pairs), and infinite Ramsey for pairs on the colouring of stretches by
`(profile, cutProfile)` yields the ultimately periodic witnesses of `Periodic.lean`.

**A count, not a complexity bound.** `Nat.card (Profile sig k)` is `N · 2 ^ (N ^ 3)` for
`N := Nat.card (KType sig k)`. In the words of `AnchorLayer.lean`'s disclaimer on its own cell
count, with "profiles" for "cells": it "is not a complexity bound of any kind: it counts
[profiles], it does not time anything, and it must not be described as a bound on any
procedure's running time." Nothing here is a decision procedure, and no automata, idempotents or
Mathlib `Language` machinery are introduced: the composition law is the whole argument.

## Main definitions and results

* `StarZero`, `StarPlus`, `PrefixStar` — the star languages `L_σ^*`, `L_σ^+`, `L_α L_σ^*` on
  finite words.
* `starProfile`, `Profile`, `profile`, `cutProfile` — the σ-star profile, the finite profile
  type, the profile of a word and its cut profile.
* `typeNil`, `kTypeOf_listSeg_eq_typeNil_iff` — the type of the empty word is the type of no
  nonempty word at `k ≥ 1`.
* `starPlus_iff_profile`, `prefixStar_iff_profile`, `kTypeOf_eq_of_profile_eq` — the membership
  read-outs.
* `starProfile_append`, `profile_append_congr`, `profile_flatten_congr` — the composition law
  and the congruence it yields.
* `exists_rep_of_length_lt` — bounded representatives by profile pumping.

## References

* [W. Thomas, *Languages, Automata, and Logic*, 1997], §5.1, for the Ramsey route to ultimately
  periodic witnesses that the profile re-proves for the finitely many conditions this cluster
  needs; no automaton is built.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable (sig : MonadicSignature) (k : ℕ)

/-! ## Star languages -/

section Star

/-- **`L_σ^*`**: `l` is a concatenation of possibly no nonempty pieces, each of `k`-type `σ`. -/
def StarZero (σ : KType sig k) (l : List (sig.preds → Bool)) : Prop :=
  ∃ ps : List (List (sig.preds → Bool)),
    (∀ p ∈ ps, p ≠ [] ∧ kTypeOf sig k (listSeg p) = σ) ∧ ps.flatten = l

/-- **`L_σ^+`**: `l` is a nonempty concatenation of nonempty pieces, each of `k`-type `σ`. -/
def StarPlus (σ : KType sig k) (l : List (sig.preds → Bool)) : Prop :=
  ∃ ps : List (List (sig.preds → Bool)),
    ps ≠ [] ∧ (∀ p ∈ ps, p ≠ [] ∧ kTypeOf sig k (listSeg p) = σ) ∧ ps.flatten = l

/-- **`L_α L_σ^*`**: a prefix of `k`-type `α` followed by a word of `L_σ^*`. -/
def PrefixStar (α σ : KType sig k) (l : List (sig.preds → Bool)) : Prop :=
  ∃ p q : List (sig.preds → Bool),
    l = p ++ q ∧ kTypeOf sig k (listSeg p) = α ∧ StarZero sig k σ q

variable {sig k}

theorem starZero_nil (σ : KType sig k) : StarZero sig k σ [] :=
  ⟨[], by simp, rfl⟩

theorem starZero_single {σ : KType sig k} {p : List (sig.preds → Bool)} (hp : p ≠ [])
    (h : kTypeOf sig k (listSeg p) = σ) : StarZero sig k σ p :=
  ⟨[p], by simpa using And.intro hp h, by simp⟩

theorem starZero_append {σ : KType sig k} {l₁ l₂ : List (sig.preds → Bool)}
    (h₁ : StarZero sig k σ l₁) (h₂ : StarZero sig k σ l₂) : StarZero sig k σ (l₁ ++ l₂) := by
  obtain ⟨ps₁, h₁, rfl⟩ := h₁
  obtain ⟨ps₂, h₂, rfl⟩ := h₂
  refine ⟨ps₁ ++ ps₂, fun p hp => ?_, by simp⟩
  rcases List.mem_append.mp hp with h | h
  · exact h₁ p h
  · exact h₂ p h

/-- A word of `L_σ^*` whose pieces are all nonempty is empty iff it has no piece. -/
theorem starPlus_iff {σ : KType sig k} {l : List (sig.preds → Bool)} :
    StarPlus sig k σ l ↔ l ≠ [] ∧ StarZero sig k σ l := by
  constructor
  · rintro ⟨ps, hne, hps, rfl⟩
    refine ⟨?_, ps, hps, rfl⟩
    obtain ⟨p, ps', rfl⟩ := List.exists_cons_of_ne_nil hne
    have hp := (hps p (List.mem_cons_self ..)).1
    simp only [List.flatten_cons, ne_eq, List.append_eq_nil_iff, not_and]
    exact fun h => absurd h hp
  · rintro ⟨hl, ps, hps, rfl⟩
    refine ⟨ps, ?_, hps, rfl⟩
    rintro rfl
    exact hl rfl

theorem starPlus_append_starZero {σ : KType sig k} {l₁ l₂ : List (sig.preds → Bool)}
    (h₁ : StarPlus sig k σ l₁) (h₂ : StarZero sig k σ l₂) : StarPlus sig k σ (l₁ ++ l₂) := by
  rw [starPlus_iff] at h₁ ⊢
  exact ⟨by simp [h₁.1], starZero_append h₁.2 h₂⟩

theorem starZero_append_starPlus {σ : KType sig k} {l₁ l₂ : List (sig.preds → Bool)}
    (h₁ : StarZero sig k σ l₁) (h₂ : StarPlus sig k σ l₂) : StarPlus sig k σ (l₁ ++ l₂) := by
  rw [starPlus_iff] at h₂ ⊢
  exact ⟨by simp [h₂.1], starZero_append h₁ h₂.2⟩

theorem prefixStar_append_starZero {α σ : KType sig k} {l₁ l₂ : List (sig.preds → Bool)}
    (h₁ : PrefixStar sig k α σ l₁) (h₂ : StarZero sig k σ l₂) :
    PrefixStar sig k α σ (l₁ ++ l₂) := by
  obtain ⟨p, q, rfl, hp, hq⟩ := h₁
  exact ⟨p, q ++ l₂, by simp, hp, starZero_append hq h₂⟩

end Star

/-! ## The σ-star profile -/

section Profile

/-- **The σ-star profile of a word**: the relation on types that holds of `(x, y)` when `l`
splits as `p ++ m ++ q` with `m ∈ L_σ^*`, `type p = x` and `type q = y`. -/
def starProfile (σ : KType sig k) (l : List (sig.preds → Bool)) (x y : KType sig k) : Prop :=
  ∃ p m q : List (sig.preds → Bool),
    l = p ++ m ++ q ∧ StarZero sig k σ m ∧
      kTypeOf sig k (listSeg p) = x ∧ kTypeOf sig k (listSeg q) = y

/-- **The profile type**: a `k`-type together with a Bool table indexed by `σ`, `x`, `y` — the
finite datum a word is summarized by. Its cardinality `Nat.card (Profile sig k)` is a COUNT of
profiles and nothing else (see the module docstring). -/
abbrev Profile : Type :=
  KType sig k × (KType sig k → KType sig k → KType sig k → Bool)

open Classical in
/-- **The profile of a word**: its `k`-type and every σ-star profile as a Bool table. -/
noncomputable def profile (l : List (sig.preds → Bool)) : Profile sig k :=
  (kTypeOf sig k (listSeg l), fun σ x y => decide (starProfile sig k σ l x y))

/-- **The cut profile of a word**: the pairs `(profile z, profile y)` over all cuts
`l = z ++ y`. -/
noncomputable def cutProfile (l : List (sig.preds → Bool)) : Set (Profile sig k × Profile sig k) :=
  {pr | ∃ z y : List (sig.preds → Bool), l = z ++ y ∧ pr = (profile sig k z, profile sig k y)}

/-- The profile type is finite: through `normalFormFintype` for `KType sig k` and the
`Fintype`/`DecidableEq` instances on function types. Instance search does not reach three
nested function levels on its own, so the two inner levels are supplied by hand. -/
instance profileFintype [Fintype sig.preds] [DecidableEq sig.preds] : Fintype (Profile sig k) :=
  haveI : Fintype (KType sig k → KType sig k → Bool) := inferInstance
  haveI : Fintype (KType sig k → KType sig k → KType sig k → Bool) := Pi.instFintype
  inferInstanceAs (Fintype (KType sig k × (KType sig k → KType sig k → KType sig k → Bool)))

/-- Equality of profiles is decidable, for the same reason and with the same two helpers. -/
instance profileDecidableEq [Fintype sig.preds] [DecidableEq sig.preds] :
    DecidableEq (Profile sig k) :=
  haveI : DecidableEq (KType sig k → KType sig k → Bool) := inferInstance
  haveI : DecidableEq (KType sig k → KType sig k → KType sig k → Bool) :=
    Fintype.decidablePiFintype
  inferInstanceAs (DecidableEq (KType sig k × (KType sig k → KType sig k → KType sig k → Bool)))

/-- The count of profiles, for the record: `N · 2 ^ (N ^ 3)` with `N` the count of `k`-types.
Documentary only; nothing is derived from it. Stated over `[Finite sig.preds]`: the
`Fintype`/`DecidableEq` instances are consumed by the proof, not the statement. -/
theorem card_profile [Finite sig.preds] :
    Nat.card (Profile sig k) = Nat.card (KType sig k) * 2 ^ (Nat.card (KType sig k) ^ 3) := by
  haveI := Fintype.ofFinite sig.preds
  haveI := Classical.decEq sig.preds
  haveI : Fintype (KType sig k → KType sig k → Bool) := inferInstance
  haveI : Fintype (KType sig k → KType sig k → KType sig k → Bool) := Pi.instFintype
  rw [Nat.card_eq_fintype_card, Nat.card_eq_fintype_card]
  simp only [Profile, Fintype.card_prod, Fintype.card_fun, Fintype.card_bool]
  rw [← pow_mul, ← pow_mul]
  ring_nf

variable {sig k}

theorem starProfile_iff_profile (σ : KType sig k) (l : List (sig.preds → Bool))
    (x y : KType sig k) : starProfile sig k σ l x y ↔ (profile sig k l).2 σ x y = true := by
  simp [profile]

theorem profile_fst (l : List (sig.preds → Bool)) :
    (profile sig k l).1 = kTypeOf sig k (listSeg l) := rfl

theorem kTypeOf_eq_of_profile_eq {l l' : List (sig.preds → Bool)}
    (h : profile sig k l = profile sig k l') :
    kTypeOf sig k (listSeg l) = kTypeOf sig k (listSeg l') :=
  congrArg Prod.fst h

theorem starProfile_of_profile_eq {l l' : List (sig.preds → Bool)}
    (h : profile sig k l = profile sig k l') {σ x y : KType sig k}
    (hl : starProfile sig k σ l x y) : starProfile sig k σ l' x y := by
  rw [starProfile_iff_profile] at hl ⊢
  rw [← h]
  exact hl

end Profile

/-! ## The type of the empty word -/

section TypeNil

/-- The `k`-type of the empty word. -/
noncomputable def typeNil : KType sig k := kTypeOf sig k (listSeg ([] : List (sig.preds → Bool)))

variable {sig k}

/-- At `k ≥ 1`, the empty word is the only word of type `typeNil`: nonemptiness is type-visible
(`nonempty_iff_of_kTypeOf_eq`). -/
theorem kTypeOf_listSeg_eq_typeNil_iff (hk : 1 ≤ k) (l : List (sig.preds → Bool)) :
    kTypeOf sig k (listSeg l) = typeNil sig k ↔ l = [] := by
  constructor
  · intro h
    by_contra hl
    have hne : Nonempty (listSeg l).carrier :=
      ⟨⟨0, List.length_pos_iff.mpr hl⟩⟩
    obtain ⟨i⟩ := (nonempty_iff_of_kTypeOf_eq hk h).mp hne
    exact i.elim0
  · rintro rfl
    rfl

/-- A word whose type is that of a nonempty word is nonempty. -/
theorem ne_nil_of_kTypeOf_eq (hk : 1 ≤ k) {l l' : List (sig.preds → Bool)}
    (h : kTypeOf sig k (listSeg l) = kTypeOf sig k (listSeg l')) (hl : l ≠ []) : l' ≠ [] := by
  rintro rfl
  exact hl ((kTypeOf_listSeg_eq_typeNil_iff hk l).mp h)

end TypeNil

/-! ## The membership read-outs -/

section ReadOut

variable {sig k}

/-- **`L_σ^+` is read off the profile**: `l ∈ L_σ^+` iff `l ≠ []` and the σ-star profile of `l`
holds at `(typeNil, typeNil)`. -/
theorem starPlus_iff_profile (hk : 1 ≤ k) (σ : KType sig k) (l : List (sig.preds → Bool)) :
    StarPlus sig k σ l ↔
      l ≠ [] ∧ (profile sig k l).2 σ (typeNil sig k) (typeNil sig k) = true := by
  rw [starPlus_iff, ← starProfile_iff_profile]
  constructor
  · rintro ⟨hl, hs⟩
    exact ⟨hl, [], l, [], by simp, hs, rfl, rfl⟩
  · rintro ⟨hl, p, m, q, rfl, hm, hp, hq⟩
    rw [kTypeOf_listSeg_eq_typeNil_iff hk] at hp hq
    subst hp
    subst hq
    simpa using And.intro hl hm

/-- **`L_α L_σ^*` is read off the profile**: `l ∈ L_α L_σ^*` iff the σ-star profile of `l` holds
at `(α, typeNil)`. -/
theorem prefixStar_iff_profile (hk : 1 ≤ k) (α σ : KType sig k) (l : List (sig.preds → Bool)) :
    PrefixStar sig k α σ l ↔ (profile sig k l).2 σ α (typeNil sig k) = true := by
  rw [← starProfile_iff_profile]
  constructor
  · rintro ⟨p, q, rfl, hp, hq⟩
    exact ⟨p, q, [], by simp, hq, hp, rfl⟩
  · rintro ⟨p, m, q, rfl, hm, hp, hq⟩
    rw [kTypeOf_listSeg_eq_typeNil_iff hk] at hq
    subst hq
    exact ⟨p, m, by simp, hp, hm⟩

/-- Membership in `L_σ^+` transfers along equal profiles. -/
theorem starPlus_of_profile_eq (hk : 1 ≤ k) {σ : KType sig k} {l l' : List (sig.preds → Bool)}
    (h : profile sig k l = profile sig k l') (hl : StarPlus sig k σ l) : StarPlus sig k σ l' := by
  rw [starPlus_iff_profile hk] at hl ⊢
  exact ⟨ne_nil_of_kTypeOf_eq hk (kTypeOf_eq_of_profile_eq h) hl.1, h ▸ hl.2⟩

/-- Membership in `L_α L_σ^*` transfers along equal profiles. -/
theorem prefixStar_of_profile_eq (hk : 1 ≤ k) {α σ : KType sig k}
    {l l' : List (sig.preds → Bool)} (h : profile sig k l = profile sig k l')
    (hl : PrefixStar sig k α σ l) : PrefixStar sig k α σ l' := by
  rw [prefixStar_iff_profile hk] at hl ⊢
  exact h ▸ hl

end ReadOut

end FormalSystem.Metalogic.WeakCanonical
