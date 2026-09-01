/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Finset.Max
import Mathlib.Data.Fintype.Pigeonhole
import Mathlib.SetTheory.Cardinal.Finite
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Metalogic.Decidability.FMP.Periodicity

/-!
# Periodic Extension over a Finite Carrier

The Extension Theorem says every partial history extends to a possible world, and it gets there
through Zorn's lemma: a maximal element of the extension order, produced non-constructively, with
no description of the world it names. Over ℤ-time with a **finite** carrier that is more than is
needed. A bounded history has two orbits leaving it — one forward, one backward — and a finite
carrier forces each to revisit a state, so the extension can be taken **doubly ultimately
periodic**, with both periods bounded by the number of world states.

That is what this module proves. It **strengthens** the finite discrete case; it does not replace
the general theorem, which stands exactly as it is for arbitrary `W` and `D`, and which this
module neither imports nor mentions in any proof.

## No seriality hypothesis, and that is deliberate

The informal statement of this result says "with a serial relation". No such hypothesis appears
below, because *Seriality* is already a **field** of `FrameOver`: `FrameOver.serial` instantiated
at duration `x = 1` yields forward and backward one-step seriality at once, which is exactly what
`exists_iter_fwd` and `exists_iter_bwd` consume. Adding a hypothesis would duplicate a field and
diverge from the frame-intrinsic discipline the extension results are written in. Read the absence
as discharged, not as omitted.

## Relation to the effective, certificate-bearing counterpart

`FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic` proves a companion result
whose conclusion is a **finite object**: three lists of states plus an integer origin, with
coherence decidable, which a model checker can emit and a consumer re-verify.

These are two theorems, not one, and deliberately so. `Finite` is a non-constructive `Prop`: it
asserts that a bijection with some `Fin n` exists without producing one, so it yields no
enumeration and cannot drive a computation. `IntPresentation` is *data*. No bridge from the first
to the second is written anywhere, because extracting an equivalence to `Fin n` out of a
`Prop`-level existential — together with decidability of a `Prop`-valued relation — is
`Classical.choice` in its most literal role, and would produce a non-computable presentation,
destroying precisely the property the effective version exists to obtain. The theorem below is
proved **directly**, with no presentation appearing anywhere in it.

### The scope of that objection

Read the paragraph above as what it is: a claim about **emitting an evaluable certificate**. In
that setting a `Classical.choice`-produced `IntPresentation` really is worthless, because the whole
point of the object is that it compute, and one obtained by extraction does not.

The objection does **not** transfer to a setting where the classically produced presentation is
only *quantified over* and never evaluated — as in a statement of the form
`¬ ValidDiscrete φ → ∃ P ∈ cands φ, ∃ w, SatAtState P w φ.neg`, where the decision procedure ranges
over its own independently constructed `cands φ` and never sees the `P` the existence proof
produced. There, `Classical.choice` sits in the proof *about* the data and computability survives
it; `Decidability/BiLasso/Check.lean`'s `instDecidableSatAtState` is the worked instance —
kernel-evaluable, yet measuring `[propext, Classical.choice, Quot.sound]`.

There is a second and sharper reason it cannot bite there. `Fin n → Fin n → Bool` is a `Fintype`
with `DecidableEq`, so a `step` function defined via `Classical.dec` is nonetheless **equal** to
one of the finitely many enumerable functions of that type. A classically constructed presentation
is thereby automatically captured by a computable enumeration of the presentations of the same
`card`: the existential and the enumeration meet, and no extraction ever happens. What genuinely
does not work is enumerating at a **cardinality bound**, because `IntPresentation.val` is a
function on the `Infinite` type `Atom` — see `IntPresentation.lean`.

Both points are compiled rather than argued:
`specs/469_eliminate_the_bridge_filtration_into_intpresentation/evidence/decidability-assembly-family-probe.lean`
elaborates the assembly sorry-free at `[propext, Classical.choice, Quot.sound]`, alongside
`soundness-half-probe.lean` and the single-presentation variant
`decidability-assembly-probe.lean`. None of this weakens the objection where it applies; it fixes
where that is.

## Main Results

- `FormalSystem.Semantics.exists_repeat_of_card_le` — pigeonhole on a window of `Nat.card W`
  consecutive times
- `FrameOver.extend_periodic` — the extension theorem for a finite carrier over ℤ, with both
  periods bounded by `Nat.card`
-/

namespace FormalSystem.Semantics

/-!
## Pigeonhole at the sharp threshold

A window of `Nat.card W + 1` consecutive times — that is, of `Nat.card W` *steps* — already
repeats a state, so the repeat's span is at most `Nat.card W`. This is the threshold the periods
in `FrameOver.extend_periodic` are bounded by, and it is one tighter than the strict-inequality
form of the same pigeonhole gives, which yields a span of `Nat.card W + 1`. Adjacency plays no
role in either; the statement is about a bare function on ℤ, and saying so keeps it reusable.
-/

/--
**Pigeonhole on a window, at the sharp threshold.** Any `Nat.card W` consecutive steps repeat a
state, so the two occurrences are at most `Nat.card W` apart.
-/
theorem exists_repeat_of_card_le {W : Type} [Finite W] (f : ℤ → W) (c : ℤ) :
    ∃ i j : ℤ, c ≤ i ∧ i < j ∧ j ≤ c + (Nat.card W : ℤ) ∧ f i = f j := by
  classical
  haveI := Fintype.ofFinite W
  have hcW : Fintype.card W = Nat.card W := Nat.card_eq_fintype_card.symm
  have hc : Fintype.card W < Fintype.card (Fin (Nat.card W + 1)) := by
    rw [Fintype.card_fin, hcW]; omega
  obtain ⟨x, y, hxy, hfxy⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (Nat.card W + 1) => f (c + (k : ℕ))) hc
  rcases lt_or_gt_of_ne (fun h : (x : ℕ) = (y : ℕ) => hxy (Fin.ext h)) with hlt | hlt
  · exact ⟨c + (x : ℕ), c + (y : ℕ), by omega, by exact_mod_cast by omega,
      by have := y.isLt; omega, hfxy⟩
  · exact ⟨c + (y : ℕ), c + (x : ℕ), by omega, by exact_mod_cast by omega,
      by have := x.isLt; omega, hfxy.symm⟩

/-- A one-step iterate is a one-step relation. -/
private theorem step_of_iter_one {W : Type} {R : W → W → Prop} {w u : W} (h : iter R 1 w u) :
    R w u := by
  obtain ⟨v, hwv, hvu⟩ := h
  rwa [(iter_zero R w v).mp hwv]

/-- An orbit that repeats at `m < n` is periodic with period `n - m` from index `m` onward. -/
private theorem iterate_periodic {W : Type} (g : W → W) (w : W) {m n : ℕ}
    (h : g^[m] w = g^[n] w) (hmn : m ≤ n) {k : ℕ} (hk : m ≤ k) :
    g^[k + (n - m)] w = g^[k] w := by
  obtain ⟨d, rfl⟩ : ∃ d, k = m + d := ⟨k - m, by omega⟩
  rw [show m + d + (n - m) = d + n by omega, show m + d = d + m by omega,
    Function.iterate_add_apply, Function.iterate_add_apply, h]

namespace FrameOver

open TaskFrame

/--
**Periodic extension over a finite carrier.**

A partial history whose domain is exactly the integer interval `[a, b]` extends to a possible
world that is ultimately periodic in *both* directions, with both periods bounded by the number of
world states: some `n₁` past which the world repeats with period `p₁`, and some `n₀` before which
it repeats with period `p₀`.

The construction is the one the informal argument describes. Seriality — taken from
`FrameOver.serial` at duration `1`, through `exists_iter_fwd` and `exists_iter_bwd` — supplies a
successor and a predecessor at every state. Iterating them out of the two ends of the window gives
two orbits; finiteness forces each to revisit a state (`exists_repeat_of_card_le`), which makes it
periodic from that visit onward; and `FrameOver.HFofStepPath` turns the resulting bi-infinite walk
into a genuine element of `H_F`, discharging the all-pairs task-respect obligation from adjacency
alone.

No `IntPresentation` appears here, and none can: see this module's docstring on why the effective
counterpart is a separate theorem rather than a corollary.
-/
theorem extend_periodic {F : FrameOver intOrder} [Finite F.WorldState]
    (τ : PartialHistory F.toTaskFrame) (a b : ℤ) (hab : a ≤ b)
    (hdom : ∀ t : ℤ, τ.domain t ↔ a ≤ t ∧ t ≤ b) :
    ∃ σ : TaskFrame.HF F, PartialHistory.Extends σ.val.toPartialHistory τ ∧
      ∃ n₀ p₀ n₁ p₁ : ℤ, 0 < p₀ ∧ 0 < p₁ ∧
        p₀ ≤ (Nat.card F.WorldState : ℤ) ∧ p₁ ≤ (Nat.card F.WorldState : ℤ) ∧
        (∀ x : ℤ, n₁ ≤ x → σ.path (x + p₁) = σ.path x) ∧
        (∀ x : ℤ, x ≤ n₀ → σ.path (x - p₀) = σ.path x) := by
  classical
  haveI : Inhabited F.WorldState := Classical.inhabited_of_nonempty F.worldNonempty
  -- Seriality at duration `1`, in both directions, through the iterate lemmas.
  have hser1 : ∀ w : F.WorldState, ∃ u, F.step w u := by
    intro w
    obtain ⟨u, hu⟩ :=
      exists_iter_fwd (R₁ := F.step) (fun v => (F.serial v 1 zero_le_one).1) 1 w
    exact ⟨u, step_of_iter_one hu⟩
  have hser2 : ∀ w : F.WorldState, ∃ v, F.step v w := by
    intro w
    obtain ⟨v, hv⟩ :=
      exists_iter_bwd (R₁ := F.step) (fun u => (F.serial u 1 zero_le_one).2) 1 w
    exact ⟨v, step_of_iter_one hv⟩
  set sc : F.WorldState → F.WorldState := fun w => Classical.choose (hser1 w) with hscdef
  set pr : F.WorldState → F.WorldState := fun w => Classical.choose (hser2 w) with hprdef
  have hsc : ∀ w, F.step w (sc w) := fun w => Classical.choose_spec (hser1 w)
  have hpr : ∀ w, F.step (pr w) w := fun w => Classical.choose_spec (hser2 w)
  -- The states of `τ`, extended by an irrelevant default off its domain.
  set g : ℤ → F.WorldState := fun t => if h : τ.domain t then τ.states t h else default with hg
  -- The extended path: the window in the middle, the two orbits outside it.
  set f : ℤ → F.WorldState := fun t =>
    if t < a then pr^[(a - t).toNat] (g a)
    else if t ≤ b then g t
    else sc^[(t - b).toNat] (g b) with hfdef
  have hfa : f a = g a := by
    simp only [hfdef]
    rw [if_neg (by omega), if_pos hab]
  have hfb : f b = g b := by
    simp only [hfdef]
    rw [if_neg (by omega), if_pos (le_refl b)]
  have hflt : ∀ t : ℤ, t < a → f t = pr^[(a - t).toNat] (g a) := by
    intro t ht
    simp only [hfdef]
    rw [if_pos ht]
  have hfgt : ∀ t : ℤ, b < t → f t = sc^[(t - b).toNat] (g b) := by
    intro t ht
    simp only [hfdef]
    rw [if_neg (by omega), if_neg (by omega)]
  have hfmid : ∀ t : ℤ, a ≤ t → t ≤ b → f t = g t := by
    intro t h1 h2
    simp only [hfdef]
    rw [if_neg (by omega), if_pos h2]
  -- `f` is a bi-infinite step path: two orbits, two seams, and the window itself.
  have hstep : IsStepPath F f := by
    intro t
    rcases lt_or_ge t (a - 1) with h1 | h1
    · -- Within the backward orbit.
      rw [hflt t (by omega), hflt (t + 1) (by omega),
        show (a - t).toNat = (a - (t + 1)).toNat + 1 by omega,
        Function.iterate_succ_apply']
      exact hpr _
    rcases eq_or_lt_of_le h1 with h2 | h2
    · -- The backward-to-window seam.
      rw [hflt t (by omega), show (a - t).toNat = 1 by omega,
        show t + 1 = a by omega, hfa]
      simpa using hpr (g a)
    rcases lt_or_ge t b with h3 | h3
    · -- Within the window.
      have hta : a ≤ t := by omega
      have ht1 : τ.domain (t + 1) := (hdom (t + 1)).mpr ⟨by omega, by omega⟩
      have ht0 : τ.domain t := (hdom t).mpr ⟨by omega, by omega⟩
      rw [hfmid t hta (by omega), hfmid (t + 1) (by omega) (by omega)]
      have hrel := τ.respects_task t (t + 1) ht0 ht1
      rw [show t + 1 - t = (1 : ℤ) by omega] at hrel
      have e0 : g t = τ.states t ht0 := by rw [hg]; exact dif_pos ht0
      have e1 : g (t + 1) = τ.states (t + 1) ht1 := by rw [hg]; exact dif_pos ht1
      rw [e0, e1]
      exact (F.taskRel_one_iff_step _ _).mp hrel
    rcases eq_or_lt_of_le h3 with h4 | h4
    · -- The window-to-forward seam.
      rw [← h4, hfb, hfgt (b + 1) (by omega), show (b + 1 - b).toNat = 1 by omega]
      simpa using hsc (g b)
    · -- Within the forward orbit.
      rw [hfgt t (by omega), hfgt (t + 1) (by omega),
        show (t + 1 - b).toNat = (t - b).toNat + 1 by omega,
        Function.iterate_succ_apply']
      exact hsc _
  refine ⟨FrameOver.HFofStepPath F f hstep, ⟨fun _ _ => trivial, ?_⟩, ?_⟩
  · -- Agreement on the window is extension.
    intro t ht
    obtain ⟨h1, h2⟩ := (hdom t).mp ht
    show f t = τ.states t ht
    rw [hfmid t h1 h2, hg]
    exact dif_pos ht
  -- Both periodicities, from a revisit in each orbit.
  obtain ⟨i₁, j₁, hi₁, hij₁, hj₁, heq₁⟩ :=
    exists_repeat_of_card_le (fun k : ℤ => sc^[k.toNat] (g b)) 0
  obtain ⟨i₀, j₀, hi₀, hij₀, hj₀, heq₀⟩ :=
    exists_repeat_of_card_le (fun k : ℤ => pr^[k.toNat] (g a)) 0
  refine ⟨a - i₀ - 1, j₀ - i₀, b + i₁ + 1, j₁ - i₁, by omega, by omega, by omega, by omega,
    ?_, ?_⟩
  · -- Forward: past `b + i₁ + 1` the path repeats with period `j₁ - i₁`.
    intro x hx
    show f (x + (j₁ - i₁)) = f x
    rw [hfgt _ (by omega), hfgt _ (by omega),
      show (x + (j₁ - i₁) - b).toNat = (x - b).toNat + (j₁.toNat - i₁.toNat) by omega]
    exact iterate_periodic sc (g b) heq₁ (by omega) (by omega)
  · -- Backward: before `a - i₀ - 1` the path repeats with period `j₀ - i₀`.
    intro x hx
    show f (x - (j₀ - i₀)) = f x
    rw [hflt _ (by omega), hflt _ (by omega),
      show (a - (x - (j₀ - i₀))).toNat = (a - x).toNat + (j₀.toNat - i₀.toNat) by omega]
    exact iterate_periodic pr (g a) heq₀ (by omega) (by omega)

end FrameOver

/-!
## The gapped case

`PartialHistory.domain` is an arbitrary predicate, so `{0, 5}` is a legal domain with a four-time
hole. The paper's own hypothesis is a *bounded world history*, which carries a `convex` field and
so has no holes; the statement below drops convexity and asks only that the domain be finite.

The extra work is entirely bookkeeping: order the domain, and between each consecutive pair fill
the gap with an explicit path of exactly the right length, which `respects_task` plus
`taskRel_eq_iter` plus `exists_path_of_iter` supply. Once the holes are filled the domain is an
interval and `FrameOver.extend_periodic` finishes the job.

**This is delivered at the frame level only.** There is no gapped counterpart on the effective,
certificate-bearing side, and there cannot be one built this way: `exists_path_of_iter` yields a
`Prop`-level existential filler, so a gapped certificate assembled from it would not be *data*,
which is the entire point of that tier. Producing a computable filler would need a bounded path
search over a presentation's adjacency matrix — real work, deliberately out of scope here, and
recorded as follow-up rather than quietly omitted.
-/

namespace FrameOver

open TaskFrame

/-- Adjacency along a window is an iterate between any two of its times. -/
theorem iter_of_adjacent {F : FrameOver intOrder} (w : ℤ → F.WorldState) (a b : ℤ)
    (hw : ∀ t : ℤ, a ≤ t → t < b → F.step (w t) (w (t + 1))) :
    ∀ (n : ℕ) (s : ℤ), a ≤ s → s + (n : ℤ) ≤ b → iter F.step n (w s) (w (s + (n : ℤ))) := by
  intro n
  induction n with
  | zero => intro s _ _; simp
  | succ n ih =>
    intro s hs hsb
    have hcast : ((n + 1 : ℕ) : ℤ) = (n : ℤ) + 1 := by push_cast; omega
    rw [hcast, show s + ((n : ℤ) + 1) = (s + (n : ℤ)) + 1 by omega]
    exact ⟨w (s + (n : ℤ)), ih s hs (by omega), hw (s + (n : ℤ)) (by omega) (by omega)⟩

/-- Adjacency along a window discharges the guarded task-respect obligation on that window. -/
theorem taskRel_of_adjacent {F : FrameOver intOrder} (w : ℤ → F.WorldState) (a b : ℤ)
    (hw : ∀ t : ℤ, a ≤ t → t < b → F.step (w t) (w (t + 1)))
    (s t : ℤ) (hs : a ≤ s) (hst : s ≤ t) (htb : t ≤ b) :
    F.TaskRel (w s) (t - s) (w t) := by
  have hiter := iter_of_adjacent w a b hw (t - s).toNat s hs (by omega)
  rw [show s + (((t - s).toNat : ℕ) : ℤ) = t by omega] at hiter
  rw [show t - s = (((t - s).toNat : ℕ) : ℤ) by omega]
  exact (F.taskRel_natCast_iff_iter _ _ _).mpr hiter

/--
**Gap filling.** Given a partial history and a finite set `S` of its domain points all lying
strictly after a domain point `a`, there is a single function on ℤ adjacent at every step from `a`
up to some `M` bounding `S`, agreeing with the history at `a` and at every member of `S`.

The induction is on `S.card`, peeling off the largest member and joining it to the previous
frontier with an explicit path of exactly the right length.
-/
theorem exists_filler {F : FrameOver intOrder} (τ : PartialHistory F.toTaskFrame) (a : ℤ) (ha : τ.domain a) :
    ∀ (n : ℕ) (S : Finset ℤ), S.card = n → (∀ t ∈ S, a < t) → (∀ t ∈ S, τ.domain t) →
      ∃ (M : ℤ) (w : ℤ → F.WorldState),
        (∀ t ∈ S, t ≤ M) ∧ a ≤ M ∧ (M = a ∨ M ∈ S) ∧
        w a = τ.states a ha ∧
        (∀ t : ℤ, a ≤ t → t < M → F.step (w t) (w (t + 1))) ∧
        (∀ (t : ℤ) (ht : τ.domain t), t ∈ S → w t = τ.states t ht) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro S hcard hgt hdom
    rcases S.eq_empty_or_nonempty with rfl | hne
    · exact ⟨a, fun _ => τ.states a ha, by simp, le_refl a, Or.inl rfl, rfl,
        fun t h1 h2 => absurd h2 (by omega), by simp⟩
    obtain ⟨M, hMS, hMmax⟩ : ∃ M, M ∈ S ∧ ∀ t ∈ S, t ≤ M :=
      ⟨S.max' hne, S.max'_mem hne, fun t ht => S.le_max' t ht⟩
    have haM : a < M := hgt M hMS
    have hMdom : τ.domain M := hdom M hMS
    obtain ⟨M', w', hM'max, haM', hM'or, hw'a, hw'adj, hw'ag⟩ :=
      ih (S.erase M).card (by rw [← hcard]; exact Finset.card_erase_lt_of_mem hMS)
        (S.erase M) rfl (fun t ht => hgt t (Finset.mem_of_mem_erase ht))
        (fun t ht => hdom t (Finset.mem_of_mem_erase ht))
    have hM'lt : M' < M := by
      rcases hM'or with h | h
      · omega
      · have h1 : M' ≠ M := Finset.ne_of_mem_erase h
        have h2 : M' ≤ M := hMmax M' (Finset.mem_of_mem_erase h)
        omega
    have hM'dom : τ.domain M' := by
      rcases hM'or with h | h
      · rw [h]; exact ha
      · exact hdom M' (Finset.mem_of_mem_erase h)
    have hw'M' : w' M' = τ.states M' hM'dom := by
      rcases hM'or with h | h
      · subst h; exact hw'a
      · exact hw'ag M' hM'dom h
    have hrel := τ.respects_task M' M hM'dom hMdom
    have hiter : iter F.step (M - M').toNat (τ.states M' hM'dom) (τ.states M hMdom) := by
      have hh := ((F.taskRel_eq_iter _ _ (M - M')).mp hrel).1 (by omega)
      rwa [show (M - M').natAbs = (M - M').toNat by omega] at hh
    obtain ⟨p, hp0, hpn, hpadj⟩ :=
      exists_path_of_iter F.step (M - M').toNat _ _ hiter
    refine ⟨M, fun t => if t ≤ M' then w' t else p (t - M').toNat,
      hMmax, by omega, Or.inr hMS, ?_, ?_, ?_⟩
    · show (if a ≤ M' then w' a else p (a - M').toNat) = τ.states a ha
      rw [if_pos (by omega)]
      exact hw'a
    · intro t h1 h2
      show F.step (if t ≤ M' then w' t else p (t - M').toNat)
        (if t + 1 ≤ M' then w' (t + 1) else p (t + 1 - M').toNat)
      rcases lt_or_ge t M' with h3 | h3
      · rw [if_pos (by omega), if_pos (by omega)]
        exact hw'adj t h1 h3
      rcases eq_or_lt_of_le h3 with h4 | h4
      · rw [if_pos (by omega), if_neg (by omega), show (t + 1 - M').toNat = 1 by omega,
          show t = M' by omega, hw'M', ← hp0]
        simpa using hpadj 0 (by omega)
      · rw [if_neg (by omega), if_neg (by omega),
          show (t + 1 - M').toNat = (t - M').toNat + 1 by omega]
        exact hpadj _ (by omega)
    · intro t ht htS
      show (if t ≤ M' then w' t else p (t - M').toNat) = τ.states t ht
      by_cases htM : t = M
      · subst htM
        rw [if_neg (by omega), hpn]
      · have htS' : t ∈ S.erase M := Finset.mem_erase.mpr ⟨htM, htS⟩
        rw [if_pos (hM'max t htS')]
        exact hw'ag t ht htS'

/--
**Periodic extension from a finite, possibly gapped domain.**

The `convex` hypothesis of the contiguous case is dropped: the domain need only be finite. The
conclusion is unchanged — a possible world extending the given history, ultimately periodic in
both directions with both periods bounded by the number of world states.
-/
theorem extend_periodic_of_finite_domain {F : FrameOver intOrder} [Finite F.WorldState]
    (τ : PartialHistory F.toTaskFrame) (hfin : {t : ℤ | τ.domain t}.Finite) :
    ∃ σ : TaskFrame.HF F, PartialHistory.Extends σ.val.toPartialHistory τ ∧
      ∃ n₀ p₀ n₁ p₁ : ℤ, 0 < p₀ ∧ 0 < p₁ ∧
        p₀ ≤ (Nat.card F.WorldState : ℤ) ∧ p₁ ≤ (Nat.card F.WorldState : ℤ) ∧
        (∀ x : ℤ, n₁ ≤ x → σ.path (x + p₁) = σ.path x) ∧
        (∀ x : ℤ, x ≤ n₀ → σ.path (x - p₀) = σ.path x) := by
  classical
  obtain ⟨t₀, ht₀⟩ := τ.nonempty_domain
  have hDne : (hfin.toFinset).Nonempty := ⟨t₀, by simpa using ht₀⟩
  obtain ⟨a, haS, hamin⟩ : ∃ a, a ∈ hfin.toFinset ∧ ∀ t ∈ hfin.toFinset, a ≤ t :=
    ⟨hfin.toFinset.min' hDne, hfin.toFinset.min'_mem hDne,
      fun t ht => hfin.toFinset.min'_le t ht⟩
  have ha : τ.domain a := by simpa using haS
  obtain ⟨b, w, hbmax, hab, _hbor, hwa, hwadj, hwag⟩ :=
    exists_filler τ a ha (hfin.toFinset.erase a).card (hfin.toFinset.erase a) rfl
      (fun t ht => by
        have h1 : t ≠ a := Finset.ne_of_mem_erase ht
        have h2 : a ≤ t := hamin t (Finset.mem_of_mem_erase ht)
        omega)
      (fun t ht => by simpa using Finset.mem_of_mem_erase ht)
  -- The window, as a contiguous partial history.
  set τ' : PartialHistory F :=
    PartialHistory.ofLe (fun t => a ≤ t ∧ t ≤ b) ⟨a, ⟨le_refl a, hab⟩⟩
      (fun t _ => w t)
      (fun s t hs ht hst => taskRel_of_adjacent w a b hwadj s t hs.1 hst ht.2) with hτ'
  have hτ'dom : ∀ t : ℤ, τ'.domain t ↔ a ≤ t ∧ t ≤ b := fun _ => Iff.rfl
  obtain ⟨σ, hext, hper⟩ := extend_periodic τ' a b hab hτ'dom
  refine ⟨σ, ⟨fun t _ => σ.property t, ?_⟩, hper⟩
  intro t ht
  have htD : t ∈ hfin.toFinset := by simpa using ht
  have hat : a ≤ t := hamin t htD
  have htb : @LE.le ℤ _ t b := by
    by_cases htA : t = a
    · have htA' : @Eq ℤ t a := htA
      omega
    · exact hbmax t (Finset.mem_erase.mpr ⟨htA, htD⟩)
  have hdom' : τ'.domain t := ⟨hat, htb⟩
  have h1 := hext.agree t hdom'
  have h2 : τ'.states t hdom' = w t := rfl
  have h3 : w t = τ.states t ht := by
    by_cases htA : t = a
    · subst htA; exact hwa
    · exact hwag t ht (Finset.mem_erase.mpr ⟨htA, htD⟩)
  rw [h1, h2, h3]

end FrameOver

end FormalSystem.Semantics
