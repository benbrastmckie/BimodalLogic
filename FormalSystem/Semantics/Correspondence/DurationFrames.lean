/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.Indicator
import FormalSystem.Semantics.DurationClassification

/-!
# Witness frames for the duration-level correspondence theorems

`app:discrete`, `app:dense` and `app:complete` are the paper's three correspondence theorems,
one per frame-class clause of `def:frame-properties`. Each has a (⇐) direction that is per-frame
soundness and a (⇒) direction that needs a *witness frame over the given duration group*
refuting the axiom whenever the order condition fails. This module supplies the two witness
frames and the order-theoretic glue the second of them needs; the biconditionals themselves are
stated below them.

* **The translation frame** `translationFrame D` — `W = D`, `w ⇒_x u ⟺ u = w + x`. Deterministic,
  so its fibres are singletons and the *Saturation* argument is `ClockFrame.clockRel_saturation`'s;
  *Limit* is `TaskFrame.limit_of_shift` at the identity position function, whose docstring names
  exactly this flow-style shape as its intended use. Serves `app:discrete` and `app:complete`,
  because its total histories realize an arbitrary set of times as the truth set of an atom.
* **The permissive frame** `permissiveFrame D` — `W = Bool`, `w ⇒_d u ⟺ d ≠ 0 ∨ w = u`. Every
  state assignment whatsoever is a legal history, which is what lets it carry the one-off
  "blip" history that refutes the density schema over a non-dense carrier. Serves `app:dense`.

## Why the permissive frame needs glue, and the translation frame does not

`TaskFrame.limit_of_permissive` carries `[SuccOrder D] [NoMaxOrder D]`, and neither is available
for an arbitrary `TemporalOrder`. Both are supplied by the hypothesis under which the frame is
*used* — that `D` is **not** densely ordered:

* `NoMaxOrder D` is free from `Nontrivial` plus the ordered-group structure, via
  `TaskFrame.exists_pos_of_nontrivial` (`noMaxOrder_of_duration`);
* `SuccOrder D` comes from `Semantics.duration_dense_or_least_pos`'s non-dense branch fed into
  `SuccOrder.ofSuccLeIff (· + p)` (`succOrder_of_isLeast_pos`).

Both are plain lemmas returning the structure, **not** global instances: `SuccOrder` and
`NoMaxOrder` on an arbitrary duration carrier have tree-wide elaboration surface, and the frame
constructions below need them only locally, at a `letI`.

## Statement shape: (T1), and the (T0) refutation

The three biconditionals below quantify over the **fibre** `FrameOver D`, never over bundled
frames constrained by a `Duration` equation. `FrameOver.toTaskFrame` is `@[reducible]` with
`(F.toTaskFrame).Duration = D` by `rfl`, so the fibre-quantified shape needs no transport, while
an `F.Duration = D` formulation would.

**The per-frame reading (T0) is false and must not be silently substituted.** (T0) reads
"`F ⊨ ax` iff `F` is a Discrete/Dense/Complete task frame", and its (⇒) direction fails on
degenerate frames: `FrameOver.staticFrame` over `ℤ` has constant histories, so it validates the
*whole* density schema while `ℤ` is not densely ordered. (See
`Metalogic/Independence/StaticFrame.lean`, whose `static_untl_iff_disc` makes every `untl` on
such a frame collapse to its event.) Only (T1) — "(∀ `F` over `D`, `F ⊨ ax`) iff `D` is
Discrete/Dense/Complete" — is true, and it is what the appendix proofs actually conclude. The
adjudication of record is `specs/paper-definitions-of-record.md`'s reading note on
`app:discrete`/`app:dense`/`app:complete`, from the definitional review's §2.4.

## Main results

* `translationFrame`, `permissiveFrame` — the two witness frames
* `noMaxOrder_of_duration`, `succOrder_of_isLeast_pos` — the glue
* `validOn_df_iff_isDiscrete`, `validOn_dn_iff_denselyOrdered`, `validOn_co_iff_isComplete` —
  the three (T1) biconditionals
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/-! ## Order-theoretic glue -/

/--
A duration group has no maximum: `Nontrivial` supplies a positive element, and adding it moves
strictly upward. A plain lemma rather than a global instance — see the module docstring.
-/
theorem noMaxOrder_of_duration (D : TemporalOrder) : NoMaxOrder ↑D := by
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
  exact ⟨fun a => ⟨a + p, lt_add_of_pos_right a hp⟩⟩

/--
A least strictly positive element makes `x ↦ x + p` a successor function: `x + p ≤ y ↔ x < y`,
with (→) from `x < x + p` and (←) from `p ≤ y - x`.

Combined with `Semantics.duration_dense_or_least_pos`, this is exactly the `SuccOrder` a
*non-densely-ordered* duration group carries. A plain lemma rather than a global instance.
-/
@[instance_reducible] noncomputable def succOrder_of_isLeast_pos {D : TemporalOrder} {p : ↑D}
    (hp : IsLeast {x : ↑D | 0 < x} p) : SuccOrder ↑D :=
  SuccOrder.ofSuccLeIff (fun x => x + p) (by
    intro a b
    constructor
    · intro h
      exact lt_of_lt_of_le (lt_add_of_pos_right a hp.1) h
    · intro h
      have hmem : (0 : ↑D) < b - a := sub_pos.mpr h
      have hle : p ≤ b - a := hp.2 hmem
      have := le_sub_iff_add_le.mp hle
      rwa [add_comm] at this)

/-! ## The translation frame -/

/-- Every fibre of the translation relation is a singleton: the flow is deterministic. -/
theorem translationRel_fib_subsingleton {D : TemporalOrder} (w x : ↑D) :
    (TaskFrame.Fib (fun (w : ↑D) (x : ↑D) (u : ↑D) => u = w + x) w x).Subsingleton := by
  rintro u (rfl : u = _) u' (rfl : u' = _)
  rfl

/--
**The translation frame over `D`**: world states are durations, and `w ⇒_x u` exactly when
`u = w + x`.

The seven `FrameOver` obligations: *Nullity* and *Converse* are group arithmetic;
*Compositionality* interpolates through `w + x`; *Seriality* has `w + x` and `w - x` as the two
witnesses; *Limit* is `TaskFrame.limit_of_shift` at the identity position function; and
*Saturation* copies `ClockFrame.clockRel_saturation`'s argument, which transfers because the
translation relation is deterministic and so has singleton fibres exactly as the clock relation
does.
-/
def translationFrame (D : TemporalOrder) : FrameOver D where
  WorldState := ↑D
  worldNonempty := ⟨0⟩
  TaskRel := fun w x u => u = w + x
  nullity_identity := by
    intro w u
    constructor
    · intro h; rw [h, add_zero]
    · intro h; rw [← h, add_zero]
  comp := TaskFrame.comp_of
    (by
      intro w v x y _ _ h
      refine ⟨w + x, rfl, ?_⟩
      show v = w + x + y
      rw [show v = w + (x + y) from h]
      abel)
    (by
      intro w u v x y _ _ h1 h2
      show v = w + (x + y)
      rw [show v = u + y from h2, show u = w + x from h1]
      abel)
  converse := by
    intro w d u
    constructor
    · intro h; show w = u + -d; rw [show u = w + d from h]; abel
    · intro h; show u = w + d; rw [show w = u + -d from h]; abel
  serial := by
    intro w x _
    refine ⟨⟨w + x, rfl⟩, ⟨w - x, ?_⟩⟩
    show w = w - x + x
    abel
  limit := TaskFrame.limit_of_shift (D := ↑D) (fun w => w) (fun _ _ _ h => h)
    (by intro w u h; rw [show u = w + 0 from h, add_zero])
  saturation := by
    intro S hdir hmem
    refine TaskFrame.sInter_nonempty_of_directed_of_univ_or_singleton hdir
      (fun s hs => (hmem s hs).2) (fun s hs => ?_)
    obtain ⟨hcl, hne⟩ := hmem s hs
    obtain ⟨a, ha⟩ := hne
    refine Or.inr ⟨a, ?_⟩
    rcases hcl with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
    · exact (translationRel_fib_subsingleton w x).eq_singleton_of_mem ha
    · exact ((translationRel_fib_subsingleton w x).anti Set.inter_subset_left).eq_singleton_of_mem
        ha

@[simp] theorem translationFrame_taskRel {D : TemporalOrder} (w x u : ↑D) :
    (translationFrame D).TaskRel w x u ↔ u = w + x := Iff.rfl

/--
The translation frame's **reference history**: the identity assignment `t ↦ t`, total.

Together with a model whose valuation is the characteristic function of a set `A ⊆ D`, this
realizes `A` as the truth set of an atom — which is what makes the translation frame a witness
for the (⇒) directions of `app:discrete` and `app:complete`.
-/
def translationHist (D : TemporalOrder) : WorldHistory (translationFrame D).toTaskFrame where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => t
  respects_task := by
    intro s t _ _
    show t = s + (t - s)
    abel
  convex := fun _ _ _ _ _ _ _ => trivial

theorem translationHist_isTotal (D : TemporalOrder) : (translationHist D).IsTotal :=
  fun _ => trivial

/-- The model on the translation frame whose atoms are all true exactly on `A ⊆ D`. -/
def translationModel (D : TemporalOrder) (A : Set ↑D) :
    TaskModel (translationFrame D).toTaskFrame where
  valuation := fun w _ => w ∈ A

/-- Truth of an atom along `translationHist` is membership in `A`, at every time. -/
@[simp] theorem translationModel_atom (D : TemporalOrder) (A : Set ↑D) (p : Atom) (t : ↑D) :
    TruthAt (translationModel D A) (translationHist D) t (Formula.atom p) ↔ t ∈ A :=
  ⟨fun ⟨_, hv⟩ => hv, fun h => ⟨trivial, h⟩⟩

/-! ## The permissive frame -/

/--
**The two-state permissive frame over `D`**: `W = Bool`, and `w ⇒_d u` at every nonzero `d`.

Every state assignment is a legal history, so this frame realizes arbitrary time-valuations —
including the one-off "blip" that refutes the density schema over a non-dense carrier. It is
`03_probes.lean`'s `freeFrame` at `W = Bool`, ported to the bundled shape.

The `SuccOrder`/`NoMaxOrder` arguments are explicit rather than instance-implicit, and are
supplied at the use site from the failure of density; see the module docstring.
-/
def permissiveFrame (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    FrameOver D :=
  letI := so
  letI := nm
  { WorldState := Bool
    worldNonempty := inferInstance
    TaskRel := fun w d u => d ≠ 0 ∨ w = u
    nullity_identity := by
      intro w u
      constructor
      · rintro (h | h)
        · exact absurd rfl h
        · exact h
      · intro h; exact Or.inr h
    comp := TaskFrame.comp_of (TaskFrame.interpolates_of_permissive fun _ _ _ => Iff.rfl)
      (by
        intro w u v x y hx hy h1 h2
        rcases h1 with hxne | hw
        · refine Or.inl fun heq => ?_
          have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
          have h1' : 0 ≤ -x := hy_eq ▸ hy
          exact hxne (le_antisymm (neg_nonneg.mp h1') hx)
        · rcases h2 with hyne | hu
          · refine Or.inl fun heq => ?_
            have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
            have h1' : 0 ≤ -y := hx_eq ▸ hx
            exact hyne (le_antisymm (neg_nonneg.mp h1') hy)
          · exact Or.inr (hw.trans hu))
    converse := by
      intro w d u
      constructor
      · rintro (hd | heq)
        · exact Or.inl (by simpa using hd)
        · exact Or.inr heq.symm
      · rintro (hd | heq)
        · exact Or.inl (by simpa using hd)
        · exact Or.inr heq.symm
    serial := TaskFrame.serial_of_permissive fun _ _ _ => Iff.rfl
    limit := TaskFrame.limit_of_permissive fun _ _ _ => Iff.rfl
    saturation := TaskFrame.saturation_of_permissive fun _ _ _ => Iff.rfl }

@[simp] theorem permissiveFrame_taskRel {D : TemporalOrder} (so : SuccOrder ↑D)
    (nm : NoMaxOrder ↑D) (w : Bool) (d : ↑D) (u : Bool) :
    (permissiveFrame D so nm).TaskRel w d u ↔ (d ≠ 0 ∨ w = u) := Iff.rfl

/--
The permissive frame realizes **any** assignment of world states to times as a total history:
the task relation holds at every nonzero duration, and at duration `0` the two endpoints
coincide.
-/
def permissiveHist (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (f : ↑D → Bool) : WorldHistory (permissiveFrame D so nm).toTaskFrame where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => f t
  respects_task := by
    intro s t _ _
    by_cases h : t - s = 0
    · refine Or.inr ?_
      have : t = s := by
        have := sub_eq_zero.mp h
        exact this
      rw [this]
    · exact Or.inl h
  convex := fun _ _ _ _ _ _ _ => trivial

theorem permissiveHist_isTotal (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (f : ↑D → Bool) : (permissiveHist D so nm f).IsTotal := fun _ => trivial

/-- The model on the permissive frame that reads an atom off the `Bool` state. -/
def permissiveModel (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    TaskModel (permissiveFrame D so nm).toTaskFrame where
  valuation := fun w _ => w = true

/-- Truth of an atom along `permissiveHist D so nm f` is `f t = true`, at every time. -/
@[simp] theorem permissiveModel_atom (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (f : ↑D → Bool) (p : Atom) (t : ↑D) :
    TruthAt (permissiveModel D so nm) (permissiveHist D so nm f) t (Formula.atom p) ↔ f t = true :=
  ⟨fun ⟨_, hv⟩ => hv, fun h => ⟨trivial, h⟩⟩

/-! ## The three (T1) correspondence theorems

The atom used by the (⇒) witnesses; any atom would do, since the refuting valuations are built
by hand rather than read off a fixed one. -/

private def corrAtom : Atom := ⟨"p", none⟩

/--
**`app:dense` at (T1).** Every frame over `D` validates the density schema `GGφ → Gφ` exactly
when `D` is densely ordered.

(⇐) is the direct semantic argument: density interpolates a point `r` between `t` and the target
`s`, and `GGφ` at `t` yields `Gφ` at `r`, which yields `φ` at `s`.

(⇒) runs the contrapositive through `duration_dense_or_least_pos`: a `D` that is not densely
ordered has a least positive element `p`, which supplies both the `SuccOrder` and the
`NoMaxOrder` that `permissiveFrame` needs. On that frame the one-off "blip" history — an atom
false at `a + p` and true everywhere else — validates `GGφ` at `a` (every time strictly above a
time strictly above `a` is strictly above `a + p`) while refuting `Gφ` there.

Note the (⇒) direction genuinely needs the permissive frame: `FrameOver.staticFrame` would *not*
serve, since its constant histories validate the whole schema over every carrier. That is the
(T0) refutation, recorded in this module's header.
-/
theorem validOn_dn_iff_denselyOrdered (D : TemporalOrder) :
    (∀ (F : FrameOver D) (φ : Formula),
        F.toTaskFrame.ValidOn (φ.allFuture.allFuture.imp φ.allFuture))
      ↔ DenselyOrdered ↑D := by
  constructor
  · intro h
    rcases duration_dense_or_least_pos (D := ↑D) with hd | ⟨p, hp⟩
    · exact hd
    · exfalso
      obtain ⟨a, -⟩ := exists_ne (0 : ↑D)
      -- Nothing lies strictly between `a` and `a + p`.
      have hcov : ∀ r : ↑D, a < r → ¬ (r < a + p) := by
        intro r har hlt
        have h1 : (0 : ↑D) < r - a := sub_pos.mpr har
        have h2 : p ≤ r - a := hp.2 h1
        have h3 : a + p ≤ r := by
          have := le_sub_iff_add_le.mp h2
          rwa [add_comm] at this
        exact absurd hlt (not_lt.mpr h3)
      have hap : a < a + p := lt_add_of_pos_right a hp.1
      letI so := succOrder_of_isLeast_pos hp
      letI nm := noMaxOrder_of_duration D
      set f : ↑D → Bool := fun t => decide (t ≠ a + p) with hf
      set τ : (permissiveFrame D so nm).toTaskFrame.HF :=
        ⟨permissiveHist D so nm f, permissiveHist_isTotal D so nm f⟩ with hτ
      have hgg : TruthAt (permissiveModel D so nm) τ.val a
          (Formula.atom corrAtom).allFuture.allFuture := by
        rw [Truth.future_iff]
        intro s has
        rw [Truth.future_iff]
        intro r hsr
        simp only [hτ, permissiveModel_atom]
        have hsp : ¬ (s < a + p) := hcov s has
        have : a + p < r := lt_of_le_of_lt (not_lt.mp hsp) hsr
        simp only [hf, decide_eq_true_eq]
        exact ne_of_gt this
      have hg := h (permissiveFrame D so nm) (Formula.atom corrAtom)
        (permissiveModel D so nm) τ a hgg
      rw [Truth.future_iff] at hg
      have hbad := hg (a + p) hap
      simp only [hτ, permissiveModel_atom] at hbad
      simp only [hf, decide_eq_true_eq] at hbad
      exact hbad rfl
  · intro hd F φ M τ t hgg
    rw [Truth.future_iff]
    intro s hts
    rw [Truth.future_iff] at hgg
    obtain ⟨r, hr1, hr2⟩ := hd.dense t s hts
    have hr := hgg r hr1
    rw [Truth.future_iff] at hr
    exact hr s hr2

/--
**`app:discrete` at (T1).** Every frame over `D` validates the **DF** schema
`(Hφ ∧ φ ∧ F⊤) → F(Hφ)` exactly when `D` satisfies `def:frame-properties`' Discrete clause.

(⇐) is direct: the `F⊤` conjunct supplies a time strictly above `t`, discreteness turns that
into the *least* such time `y'`, and `Hφ` at `y'` holds because every `r < y'` is either below
`t` (covered by `Hφ` at `t`), equal to `t` (covered by `φ`), or strictly between — which
leastness excludes.

(⇒) uses the translation frame with the atom's truth set taken to be `{r | r ≤ x}`. The
antecedent holds at `x` by construction, so the consequent hands over a `v > x` with
`∀ r < v, r ≤ x` — which is exactly `IsLeast {z | x < z} v`.
-/
theorem validOn_df_iff_isDiscrete (D : TemporalOrder) :
    (∀ (F : FrameOver D) (φ : Formula),
        F.toTaskFrame.ValidOn
          (((φ.allPast.and φ).and Formula.top.someFuture).imp φ.allPast.someFuture))
      ↔ ∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y' := by
  constructor
  · intro h x hex
    set A : Set ↑D := {r : ↑D | r ≤ x} with hA
    set τ : (translationFrame D).toTaskFrame.HF :=
      ⟨translationHist D, translationHist_isTotal D⟩ with hτ
    have hant : TruthAt (translationModel D A) τ.val x
        (((Formula.atom corrAtom).allPast.and (Formula.atom corrAtom)).and
          Formula.top.someFuture) := by
      rw [Truth.and_iff, Truth.and_iff]
      refine ⟨⟨?_, ?_⟩, ?_⟩
      · rw [Truth.past_iff]
        intro s hs
        simp only [hτ, translationModel_atom]
        exact le_of_lt hs
      · simp only [hτ, translationModel_atom]
        exact le_refl x
      · rw [Truth.some_future_iff]
        obtain ⟨y, hy⟩ := hex
        exact ⟨y, hy, fun hb => hb⟩
    have hcons := h (translationFrame D) (Formula.atom corrAtom) (translationModel D A) τ x hant
    rw [Truth.some_future_iff] at hcons
    obtain ⟨v, hxv, hHv⟩ := hcons
    rw [Truth.past_iff] at hHv
    refine ⟨v, hxv, fun z hz => ?_⟩
    by_contra hlt
    have hzv : z < v := not_le.mp hlt
    have := hHv z hzv
    simp only [hτ, translationModel_atom] at this
    exact absurd (hz : x < z) (not_lt.mpr this)
  · intro hdisc F φ M τ t hant
    rw [Truth.and_iff, Truth.and_iff] at hant
    obtain ⟨⟨hH, hnow⟩, hFtop⟩ := hant
    rw [Truth.some_future_iff] at hFtop
    obtain ⟨s, hts, -⟩ := hFtop
    obtain ⟨y, hy1, hy2⟩ := hdisc t ⟨s, hts⟩
    rw [Truth.some_future_iff]
    refine ⟨y, hy1, ?_⟩
    rw [Truth.past_iff]
    intro r hry
    rcases lt_trichotomy r t with hlt | heq | hgt
    · rw [Truth.past_iff] at hH; exact hH r hlt
    · rw [heq]; exact hnow
    · exact absurd (hy2 hgt) (not_le.mpr hry)

/--
**`app:complete` at (T1).** Every frame over `D` validates the **CO** schema
`△(Hφ → F(Hφ)) → (Hφ → Gφ)` exactly when `D` satisfies `def:frame-properties`' Complete clause.

(⇐) is the least-upper-bound argument. Suppose `Hφ` holds at `t` but `φ` fails at some `s > t`.
The set `S = {u | Hφ at u}` contains `t` and is bounded above by `s`, so it has a least upper
bound `m`; `m ∈ S`, because a time below `m` is below some member of `S` and so is covered by
that member's `Hφ`. The `△` hypothesis at `m` then produces a member of `S` strictly above `m`,
contradicting that `m` bounds `S`.

(⇒) takes the atom's truth set on the translation frame to be `{r | ∃ u ∈ S, r < u}`, the strict
down-set generated by an arbitrary nonempty bounded-above `S`. `Hφ` then holds exactly at the
times no member of whose strict past is an upper bound of `S`, and the `△` antecedent holds
*because* `S` has no least upper bound — a time at which it failed would be one. `Gφ` at a
member of `S` then forces every upper bound of `S` to lie strictly below a member of `S`, which
is a contradiction.
-/
theorem validOn_co_iff_isComplete (D : TemporalOrder) :
    (∀ (F : FrameOver D) (φ : Formula), F.toTaskFrame.ValidOn (Formula.co φ))
      ↔ ∀ s : Set ↑D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x := by
  constructor
  · rintro h S ⟨s₀, hs₀⟩ ⟨b, hb⟩
    by_contra hno
    set A : Set ↑D := {r : ↑D | ∃ u ∈ S, r < u} with hA
    set τ : (translationFrame D).toTaskFrame.HF :=
      ⟨translationHist D, translationHist_isTotal D⟩ with hτ
    set M := translationModel D A with hM
    -- `Hφ` at `u` says every time strictly below `u` is strictly below a member of `S`.
    have hHiff : ∀ u : ↑D,
        TruthAt M τ.val u (Formula.atom corrAtom).allPast ↔ ∀ r < u, ∃ w ∈ S, r < w := by
      intro u
      rw [Truth.past_iff]
      constructor
      · intro hu r hr
        have := hu r hr
        simp only [hτ, hM, translationModel_atom] at this
        exact this
      · intro hu r hr
        simp only [hτ, hM, translationModel_atom]
        exact hu r hr
    -- `s₀ ∈ S` witnesses `Hφ` at `s₀`.
    have hHs₀ : TruthAt M τ.val s₀ (Formula.atom corrAtom).allPast :=
      (hHiff s₀).mpr fun r hr => ⟨s₀, hs₀, hr⟩
    -- The `△` antecedent: a time where it failed would be a least upper bound of `S`.
    have halways : ∀ u : ↑D, TruthAt M τ.val u
        ((Formula.atom corrAtom).allPast.imp (Formula.atom corrAtom).allPast.someFuture) := by
      intro u hu
      rw [Truth.some_future_iff]
      by_cases hup : ∃ w ∈ S, u < w
      · obtain ⟨w, hw, huw⟩ := hup
        exact ⟨w, huw, (hHiff w).mpr fun r hr => ⟨w, hw, hr⟩⟩
      · exfalso
        refine hno ⟨u, fun w hw => ?_, fun c hc => ?_⟩
        · by_contra hlt
          exact hup ⟨w, hw, not_le.mp hlt⟩
        · by_contra hlt
          obtain ⟨w, hw, hcw⟩ := (hHiff u).mp hu c (not_le.mp hlt)
          exact absurd (hc hw) (not_le.mpr hcw)
    have hco := h (translationFrame D) (Formula.atom corrAtom) M τ s₀
      ((Truth.always_iff _).mpr halways) hHs₀
    rw [Truth.future_iff] at hco
    -- `b` is an upper bound strictly above `s₀`, so `Gφ` at `s₀` puts `b` strictly below `S`.
    have hs₀b : s₀ < b := by
      rcases lt_or_eq_of_le (hb hs₀) with hlt | heq
      · exact hlt
      · exact absurd ⟨b, hb, fun c hc => heq ▸ hc hs₀⟩ hno
    have hbA := hco b hs₀b
    simp only [hτ, hM, translationModel_atom] at hbA
    obtain ⟨w, hw, hbw⟩ := hbA
    exact absurd (hb hw) (not_le.mpr hbw)
  · intro hcomp F φ M τ t halways hH
    rw [Truth.future_iff]
    intro s hts
    by_contra hns
    set S : Set ↑D := {u : ↑D | ∀ r < u, TruthAt M τ.val r φ} with hS
    have htS : t ∈ S := by rw [hS]; rw [Truth.past_iff] at hH; exact hH
    have hbdd : ∀ u ∈ S, u ≤ s := by
      intro u hu
      by_contra hlt
      exact hns (hu s (not_le.mp hlt))
    obtain ⟨m, hm⟩ := hcomp S ⟨t, htS⟩ ⟨s, fun u hu => hbdd u hu⟩
    have hmS : m ∈ S := by
      intro r hr
      by_contra hnr
      have hub : r ∈ upperBounds S := by
        intro u hu
        by_contra hlt
        exact hnr (hu r (not_le.mp hlt))
      exact absurd (hm.2 hub) (not_le.mpr hr)
    have hstep := (Truth.always_iff _).mp halways m
    have hF := hstep (by rw [Truth.past_iff]; exact hmS)
    rw [Truth.some_future_iff] at hF
    obtain ⟨v, hmv, hHv⟩ := hF
    rw [Truth.past_iff] at hHv
    exact absurd (hm.1 (show v ∈ S from hHv)) (not_le.mpr hmv)

end FormalSystem.Semantics
