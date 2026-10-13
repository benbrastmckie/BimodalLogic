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

/-! ## The composition law

A middle `m ∈ L_σ^*` of a concatenation `l₁ ++ l₂` lies inside `l₁`, lies inside `l₂`, straddles
the boundary at a piece boundary of `m`, or straddles it strictly inside one piece `l' ++ l''` of
type `σ`. Read on the σ-star profile, these are the four disjuncts of `starProfile_append`; each
mentions `l₁` and `l₂` only through their profiles, which is why the profile of `l₁ ++ l₂` is a
function of the profiles of the parts (`profile_append_congr`). The type product that the law
needs is stated on representatives (`TypeMul`) and is well defined by
`kTypeOf_listSeg_append_congr` (`typeMul_iff`); no product on bare `k`-types is introduced. -/

section Append

variable {sig k}

/-- **The type product on representatives**: `TypeMul x y z` says that some `p` of type `x` and
some `q` of type `y` concatenate to a word of type `z`. By `kTypeOf_listSeg_append_congr` this
depends on nothing but `x`, `y` and `z` (`typeMul_iff`). -/
def TypeMul (x y z : KType sig k) : Prop :=
  ∃ p q : List (sig.preds → Bool),
    kTypeOf sig k (listSeg p) = x ∧ kTypeOf sig k (listSeg q) = y ∧
      kTypeOf sig k (listSeg (p ++ q)) = z

theorem typeMul_iff [Finite sig.preds] (p q : List (sig.preds → Bool)) (z : KType sig k) :
    TypeMul (kTypeOf sig k (listSeg p)) (kTypeOf sig k (listSeg q)) z ↔
      kTypeOf sig k (listSeg (p ++ q)) = z := by
  haveI := Fintype.ofFinite sig.preds
  constructor
  · rintro ⟨p', q', hp, hq, rfl⟩
    exact kTypeOf_listSeg_append_congr k hp.symm hq.symm
  · intro h
    exact ⟨p, q, rfl, rfl, h⟩

/-- **The middle-split lemma**: a cut of a word of `L_σ^*` falls either at a piece boundary
(both halves in `L_σ^*`) or strictly inside one piece `l' ++ l''` of type `σ`, with the pieces
before and after it in `L_σ^*`. By induction on the list of pieces, with
`List.append_eq_append_iff` locating the cut. -/
theorem starZero_split {σ : KType sig k} {m m₁ m₂ : List (sig.preds → Bool)}
    (hm : StarZero sig k σ m) (h : m = m₁ ++ m₂) :
    (StarZero sig k σ m₁ ∧ StarZero sig k σ m₂) ∨
      ∃ a l' l'' b : List (sig.preds → Bool),
        m₁ = a ++ l' ∧ m₂ = l'' ++ b ∧ StarZero sig k σ a ∧ StarZero sig k σ b ∧
          l' ≠ [] ∧ l'' ≠ [] ∧ kTypeOf sig k (listSeg (l' ++ l'')) = σ := by
  obtain ⟨ps, hps, rfl⟩ := hm
  induction ps generalizing m₁ with
  | nil =>
    left
    simp only [List.flatten_nil] at h
    obtain ⟨rfl, rfl⟩ := List.append_eq_nil_iff.mp h.symm
    exact ⟨starZero_nil σ, starZero_nil σ⟩
  | cons p ps ih =>
    have hp := hps p (List.mem_cons_self ..)
    have hps' : ∀ q ∈ ps, q ≠ [] ∧ kTypeOf sig k (listSeg q) = σ :=
      fun q hq => hps q (List.mem_cons_of_mem _ hq)
    simp only [List.flatten_cons] at h
    rcases List.append_eq_append_iff.mp h with ⟨a', h₁, h₂⟩ | ⟨c', h₁, h₂⟩
    · rcases ih hps' h₂ with ⟨ha, hm₂⟩ | ⟨a, l', l'', b, rfl, rfl, ha, hb, hl', hl'', hσ⟩
      · left
        exact ⟨h₁ ▸ starZero_append (starZero_single hp.1 hp.2) ha, hm₂⟩
      · right
        exact ⟨p ++ a, l', l'', b, by rw [h₁, List.append_assoc], rfl,
          starZero_append (starZero_single hp.1 hp.2) ha, hb, hl', hl'', hσ⟩
    · by_cases hm₁ : m₁ = []
      · left
        subst hm₁
        rw [List.nil_append] at h₁
        subst h₁
        exact ⟨starZero_nil σ, p :: ps, hps, by rw [h₂, List.flatten_cons]⟩
      · by_cases hc' : c' = []
        · left
          subst hc'
          rw [List.append_nil] at h₁
          subst h₁
          rw [List.nil_append] at h₂
          exact ⟨starZero_single hm₁ hp.2, ps, hps', h₂.symm⟩
        · right
          exact ⟨[], m₁, c', ps.flatten, by simp, h₂, starZero_nil σ, ⟨ps, hps', rfl⟩, hm₁, hc',
            h₁ ▸ hp.2⟩

/-- **The composition law.** The σ-star profile of `l₁ ++ l₂` at `(x, y)` holds iff one of:
(i) the middle lies inside `l₁` — `(x, y₁) ∈ g_σ l₁` and `y = y₁ · type l₂`;
(ii) the middle lies inside `l₂` — `(x₂, y) ∈ g_σ l₂` and `x = type l₁ · x₂`;
(iii) the middle straddles the boundary at a piece boundary — `(x, 1) ∈ g_σ l₁` and
`(1, y) ∈ g_σ l₂`, with `1 := typeNil`;
(iv) the middle straddles the boundary inside one piece — `(x, u) ∈ g_σ l₁`, `(v, y) ∈ g_σ l₂`
and `u · v = σ`.
The products are `TypeMul`. Case (iii) is not an instance of (iv): at a piece boundary both
halves have type `typeNil`, whose product is `typeNil ≠ σ` whenever `σ` is the type of a
nonempty word. Both directions are by `List.append_eq_append_iff` and `starZero_split`. -/
theorem starProfile_append [Finite sig.preds] (hk : 1 ≤ k) (σ : KType sig k)
    (l₁ l₂ : List (sig.preds → Bool)) (x y : KType sig k) :
    starProfile sig k σ (l₁ ++ l₂) x y ↔
      (∃ y₁, starProfile sig k σ l₁ x y₁ ∧ TypeMul y₁ (kTypeOf sig k (listSeg l₂)) y) ∨
      (∃ x₂, starProfile sig k σ l₂ x₂ y ∧ TypeMul (kTypeOf sig k (listSeg l₁)) x₂ x) ∨
      (starProfile sig k σ l₁ x (typeNil sig k) ∧ starProfile sig k σ l₂ (typeNil sig k) y) ∨
      (∃ u v, starProfile sig k σ l₁ x u ∧ starProfile sig k σ l₂ v y ∧ TypeMul u v σ) := by
  constructor
  · rintro ⟨p, m, q, h, hm, rfl, rfl⟩
    rcases List.append_eq_append_iff.mp h with ⟨a', h₁, h₂⟩ | ⟨c', h₁, h₂⟩
    · rcases List.append_eq_append_iff.mp h₁.symm with ⟨c, hc₁, hc₂⟩ | ⟨c, hc₁, hc₂⟩
      · right; left
        refine ⟨kTypeOf sig k (listSeg c), ⟨c, m, q, by rw [h₂, hc₂], hm, rfl, rfl⟩, ?_⟩
        rw [typeMul_iff, hc₁]
      · rcases starZero_split hm hc₂ with ⟨hc, ha⟩ |
          ⟨a, l', l'', b, rfl, rfl, ha, hb, hl', hl'', hσ⟩
        · right; right; left
          exact ⟨⟨p, c, [], by rw [hc₁, List.append_nil], hc, rfl, rfl⟩,
            ⟨[], a', q, by rw [h₂, List.nil_append], ha, rfl, rfl⟩⟩
        · right; right; right
          refine ⟨kTypeOf sig k (listSeg l'), kTypeOf sig k (listSeg l''),
            ⟨p, a, l', by rw [hc₁, List.append_assoc], ha, rfl, rfl⟩,
            ⟨l'', b, q, by rw [h₂], hb, rfl, rfl⟩, ?_⟩
          exact (typeMul_iff l' l'' σ).mpr hσ
    · left
      refine ⟨kTypeOf sig k (listSeg c'), ⟨p, m, c', h₁, hm, rfl, rfl⟩, ?_⟩
      rw [typeMul_iff, h₂]
  · rintro (⟨y₁, ⟨p, m, q₁, rfl, hm, rfl, rfl⟩, hmul⟩ | ⟨x₂, ⟨p₂, m, q, rfl, hm, rfl, rfl⟩, hmul⟩ |
      ⟨⟨p, m₁, q₁, rfl, hm₁, rfl, hq₁⟩, ⟨p₂, m₂, q, rfl, hm₂, hp₂, rfl⟩⟩ |
      ⟨u, v, ⟨p, m₁, l', rfl, hm₁, rfl, rfl⟩, ⟨l'', m₂, q, rfl, hm₂, rfl, rfl⟩, hmul⟩)
    · rw [typeMul_iff] at hmul
      exact ⟨p, m, q₁ ++ l₂, by simp only [List.append_assoc], hm, rfl, hmul⟩
    · rw [typeMul_iff] at hmul
      exact ⟨l₁ ++ p₂, m, q, by simp only [List.append_assoc], hm, hmul, rfl⟩
    · rw [kTypeOf_listSeg_eq_typeNil_iff hk] at hq₁ hp₂
      subst hq₁
      subst hp₂
      exact ⟨p, m₁ ++ m₂, q, by simp only [List.append_assoc, List.append_nil, List.nil_append],
        starZero_append hm₁ hm₂, rfl, rfl⟩
    · rw [typeMul_iff] at hmul
      refine ⟨p, m₁ ++ (l' ++ l'') ++ m₂, q, by simp only [List.append_assoc], ?_, rfl, rfl⟩
      refine starZero_append (starZero_append hm₁ ?_) hm₂
      by_cases hnil : l' ++ l'' = []
      · rw [hnil]
        exact starZero_nil σ
      · exact starZero_single hnil hmul

/-- **Composition on profiles**: the profile of a concatenation depends only on the profiles of
the parts. First component by `kTypeOf_listSeg_append_congr`; second component by
`starProfile_append` on both sides, after which every disjunct is a statement about
`profile l₁` and `profile l₂` alone. -/
theorem profile_append_congr [Finite sig.preds] (hk : 1 ≤ k)
    {l₁ l₁' l₂ l₂' : List (sig.preds → Bool)}
    (h₁ : profile sig k l₁ = profile sig k l₁') (h₂ : profile sig k l₂ = profile sig k l₂') :
    profile sig k (l₁ ++ l₂) = profile sig k (l₁' ++ l₂') := by
  haveI := Fintype.ofFinite sig.preds
  refine Prod.ext
    (kTypeOf_listSeg_append_congr k (congrArg Prod.fst h₁) (congrArg Prod.fst h₂)) ?_
  funext σ x y
  rw [Bool.eq_iff_iff, ← starProfile_iff_profile, ← starProfile_iff_profile,
    starProfile_append hk, starProfile_append hk]
  simp only [starProfile_iff_profile, ← profile_fst, h₁, h₂]

/-- **Composition on profiles, for a list of pieces**: pairwise profile-equal pieces have
profile-equal flattenings. The shape the block-by-block transport of `Periodic.lean` uses. -/
theorem profile_flatten_congr [Finite sig.preds] (hk : 1 ≤ k)
    {L L' : List (List (sig.preds → Bool))}
    (h : List.Forall₂ (fun a b => profile sig k a = profile sig k b) L L') :
    profile sig k L.flatten = profile sig k L'.flatten := by
  induction h with
  | nil => rfl
  | cons hab _ ih =>
    simp only [List.flatten_cons]
    exact profile_append_congr hk hab ih

end Append

/-! ## Bounded representatives by profile pumping

A word of length `≥ Nat.card (Profile sig k) ^ 2` has two cut positions with the same pair
`(profile prefix, profile suffix)` (pigeonhole, `Fintype.exists_ne_map_eq_of_card_lt`); deleting
the stretch between them preserves the profile (`profile_append_congr`) and shrinks the cut
profile (every cut of the shortened word carries the profile pair of a cut of the original,
`cutProfile_delete`). Iterating gives a representative below that length
(`exists_rep_of_length_lt`). `Nat.card (Profile sig k) ^ 2` is a count of pairs of profiles and
nothing else — see the module docstring. -/

section Pump

variable {sig k}

/-- **Deletion shrinks the cut profile.** For `l = a ++ b ++ c` with the two cut pairs at the
ends of `b` equal — `profile a = profile (a ++ b)` and `profile (b ++ c) = profile c` — every
cut of `a ++ c` carries the profile pair of a cut of `l`: a cut inside `a` is matched by the same
cut of `l` (congruence on the suffix side), a cut inside `c` by the cut of `l` shifted past `b`
(congruence on the prefix side). -/
theorem cutProfile_delete [Finite sig.preds] (hk : 1 ≤ k) {a b c : List (sig.preds → Bool)}
    (hab : profile sig k a = profile sig k (a ++ b))
    (hbc : profile sig k (b ++ c) = profile sig k c) :
    cutProfile sig k (a ++ c) ⊆ cutProfile sig k (a ++ b ++ c) := by
  rintro pr ⟨z, y, hzy, rfl⟩
  rcases List.append_eq_append_iff.mp hzy with ⟨a', h₁, h₂⟩ | ⟨c', h₁, h₂⟩
  · refine ⟨a ++ b ++ a', y, by rw [h₂]; simp only [List.append_assoc], ?_⟩
    rw [h₁, profile_append_congr (l₂ := a') (l₂' := a') hk hab rfl]
  · refine ⟨z, c' ++ b ++ c, by rw [h₁]; simp only [List.append_assoc], ?_⟩
    rw [h₂, profile_append_congr (l₁ := c') (l₁' := c') hk rfl hbc.symm, ← List.append_assoc]

/-- **Pigeonhole on cut pairs**: a word of length at least `Nat.card (Profile sig k) ^ 2` has two
cut positions `i < j` with the same `(profile prefix, profile suffix)` pair. -/
theorem exists_eq_cutPair_of_length_ge [Finite sig.preds] (l : List (sig.preds → Bool))
    (hl : Nat.card (Profile sig k) ^ 2 ≤ l.length) :
    ∃ i j, i < j ∧ j ≤ l.length ∧
      (profile sig k (l.take i), profile sig k (l.drop i)) =
        (profile sig k (l.take j), profile sig k (l.drop j)) := by
  haveI := Fintype.ofFinite sig.preds
  haveI := Classical.decEq sig.preds
  rw [Nat.card_eq_fintype_card, sq] at hl
  obtain ⟨i, j, hne, heq⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun i : Fin (l.length + 1) => (profile sig k (l.take i.1), profile sig k (l.drop i.1)))
    (by rw [Fintype.card_fin, Fintype.card_prod]; exact Nat.lt_succ_of_le hl)
  rcases lt_or_gt_of_ne (Fin.val_ne_of_ne hne) with hij | hij
  · exact ⟨i.1, j.1, hij, by have := j.2; omega, heq⟩
  · exact ⟨j.1, i.1, hij, by have := i.2; omega, heq.symm⟩

/-- **Bounded representatives.** Every word has a representative of the same profile, no larger
cut profile, and length below `Nat.card (Profile sig k) ^ 2`: pigeonhole on cut pairs and
deletion, iterated by induction on a length bound. The count is a count of pairs of profiles and
times nothing. -/
theorem exists_rep_of_length_lt [Finite sig.preds] (hk : 1 ≤ k) (l : List (sig.preds → Bool)) :
    ∃ l' : List (sig.preds → Bool), l'.length < Nat.card (Profile sig k) ^ 2 ∧
      profile sig k l' = profile sig k l ∧ cutProfile sig k l' ⊆ cutProfile sig k l := by
  haveI := Fintype.ofFinite sig.preds
  haveI := Classical.decEq sig.preds
  have hP : 0 < Nat.card (Profile sig k) ^ 2 := pow_pos Nat.card_pos 2
  suffices h : ∀ n (l : List (sig.preds → Bool)), l.length ≤ n →
      ∃ l' : List (sig.preds → Bool), l'.length < Nat.card (Profile sig k) ^ 2 ∧
        profile sig k l' = profile sig k l ∧ cutProfile sig k l' ⊆ cutProfile sig k l from
    h l.length l le_rfl
  intro n
  induction n with
  | zero =>
    intro l hl
    exact ⟨l, by omega, rfl, subset_rfl⟩
  | succ n ih =>
    intro l hl
    by_cases hlt : l.length < Nat.card (Profile sig k) ^ 2
    · exact ⟨l, hlt, rfl, subset_rfl⟩
    · obtain ⟨i, j, hij, hjl, heq⟩ := exists_eq_cutPair_of_length_ge l (not_lt.mp hlt)
      have hdj : l.drop j = (l.drop i).drop (j - i) := by
        rw [List.drop_drop, show i + (j - i) = j by omega]
      have hsplit : l = l.take i ++ (l.drop i).take (j - i) ++ l.drop j := by
        rw [List.append_assoc, hdj, List.take_append_drop, List.take_append_drop]
      have hab : profile sig k (l.take i) =
          profile sig k (l.take i ++ (l.drop i).take (j - i)) := by
        rw [← List.take_add, show i + (j - i) = j by omega]
        exact congrArg Prod.fst heq
      have hbc : profile sig k ((l.drop i).take (j - i) ++ l.drop j) =
          profile sig k (l.drop j) := by
        rw [show (l.drop i).take (j - i) ++ l.drop j = l.drop i by
          rw [hdj, List.take_append_drop]]
        exact congrArg Prod.snd heq
      obtain ⟨l', hl', hp, hc⟩ := ih (l.take i ++ l.drop j) (by
        rw [List.length_append, List.length_take, List.length_drop]; omega)
      refine ⟨l', hl', hp.trans ?_, hc.trans ?_⟩
      · conv_rhs => rw [hsplit]
        exact profile_append_congr (l₂ := l.drop j) (l₂' := l.drop j) hk hab rfl
      · conv_rhs => rw [hsplit]
        exact cutProfile_delete hk hab hbc

/-- **Bounded representatives of nonempty words are nonempty**: nonemptiness is profile-visible
at `k ≥ 1` (`ne_nil_of_kTypeOf_eq`). -/
theorem exists_rep_of_length_lt_ne_nil [Finite sig.preds] (hk : 1 ≤ k)
    {l : List (sig.preds → Bool)} (hl : l ≠ []) :
    ∃ l' : List (sig.preds → Bool), l' ≠ [] ∧ l'.length < Nat.card (Profile sig k) ^ 2 ∧
      profile sig k l' = profile sig k l ∧ cutProfile sig k l' ⊆ cutProfile sig k l := by
  obtain ⟨l', h1, h2, h3⟩ := exists_rep_of_length_lt hk l
  exact ⟨l', ne_nil_of_kTypeOf_eq hk (kTypeOf_eq_of_profile_eq h2.symm) hl, h1, h2, h3⟩

end Pump

end FormalSystem.Metalogic.WeakCanonical
