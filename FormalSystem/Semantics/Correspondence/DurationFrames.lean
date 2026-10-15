/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.Indicator
import FormalSystem.Semantics.Frames.Standard
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
  `SuccOrder.ofSuccLeIff (· + p)` (`succOrderOfIsLeastPos`).

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
adjudication of record is `docs/reference/paper-definitions-of-record.md`'s reading note on
`app:discrete`/`app:dense`/`app:complete`, from the definitional review's §2.4.

## The canonical frames' characterizations

Beyond the correspondence witnesses, this module carries the characterizations the paper's own
lemma on these two frames asserts. `def:canonical-frames` is where the paper introduces them —
the translation frame and the two-state frame — and `lem:canonical-frames` makes four claims:
the translation frame is a *Deterministic* task frame whose possible worlds are exactly the
translations, and the two-state frame is a task frame just in case the duration order is
*Discrete*, in which case it is not *Deterministic* and every assignment of its two states to
times is one of its possible worlds. All four are proved in the final section below; neither
anchor's text is quoted anywhere.

Claim (c) is stated at the **bare relation** `permRel` rather than at `permissiveFrame`, because
that frame cannot be applied without the `SuccOrder` and `NoMaxOrder` data that discreteness
itself supplies — so a frame-level "is a task frame iff `D` is Discrete" would carry the
right-hand side in its own hypotheses. `permissiveFrame_taskRel_eq` identifies `permRel` with the
frame's own task relation, which is what makes the biconditionals statements about the frame of
`def:canonical-frames` rather than about a lookalike relation.

## Main results

* `translationFrame`, `permissiveFrame` — the two witness frames
* `noMaxOrder_of_duration`, `succOrderOfIsLeastPos` — the glue
* `translationHist`, `permissiveHist` — each witness frame's reference world history
* `translation_realizes`, `translation_realizes_allPast`, `translation_realizes_allFuture`,
  `permissive_realizes` — the atom-realisation step, named once instead of rebuilt inline
* `validOn_df_iff_isDiscrete`, `validOn_dn_iff_denselyOrdered`, `validOn_co_iff_isComplete` —
  the three (T1) biconditionals
* `translationFrame_deterministic` — claim (a) of `lem:canonical-frames`, at every temporal order
* `translationHistEquiv`, `translation_histSet_eq`, `translation_exists_unique` — claim (b): the
  translation frame's possible worlds are exactly the translations, in equivalence, set and
  uniqueness form
* `permRel_limit_iff_isDiscrete`, `permRel_constraints_iff_isDiscrete` — claim (c), with
  `permissiveFrame_taskRel_eq` as the tie-back to the frame
* `permissiveFrame_not_deterministic`, `permissiveHistEquiv` — claim (d)

## Tags

correspondence · duration-group · app:dense · app:discrete · app:complete · lem:canonical-frames
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
@[instance_reducible] noncomputable def succOrderOfIsLeastPos {D : TemporalOrder} {p : ↑D}
    (hp : IsLeast {x : ↑D | 0 < x} p) : SuccOrder ↑D :=
  SuccOrder.ofSuccLeIff (fun x => x + p) (by
    intro a b
    exact ⟨fun h => lt_of_lt_of_le (isLeast_succ_of_isLeast_pos hp a).1 h,
      fun h => (isLeast_succ_of_isLeast_pos hp a).2 h⟩)

/-! ## The translation frame's history and model

`translationFrame` itself now lives in `Semantics/Frames/Standard.lean`; only the reference
history and the set-indexed model stay here, where the correspondence theorems below use them.
-/

/--
The translation frame's **reference history**: the identity assignment `t ↦ t`, total.

Together with a model whose valuation is the characteristic function of a set `A ⊆ D`, this
realizes `A` as the truth set of an atom — which is what makes the translation frame a witness
for the (⇒) directions of `app:discrete` and `app:complete`.
-/
def translationHist (D : TemporalOrder) : WorldHistory (translationFrame D).toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => t) fun s t => by
    refine (translationFrame_taskRel _ _ _).mpr ?_
    show t = s + (t - s)
    abel

/-- The model on the translation frame whose atoms are all true exactly on `A ⊆ D`. -/
def translationModel (D : TemporalOrder) (A : Set ↑D) :
    TaskModel (translationFrame D).toTaskFrame where
  valuation := fun w _ => w ∈ A

/-- Truth of an atom along `translationHist` is membership in `A`, at every time. -/
@[simp] theorem translationModel_atom (D : TemporalOrder) (A : Set ↑D) (p : Atom) (t : ↑D) :
    TruthAt (translationModel D A) (translationHist D) t (Formula.atom p) ↔ t ∈ A :=
  Iff.rfl

/--
**Atom realisation.** The translation frame realises an arbitrary `A ⊆ ↑D` as the truth set of an
atom along its reference history.

This is the step the (⇒) directions of `validOn_df_iff_isDiscrete` and `validOn_co_iff_isComplete`
turn on: pick `A`, and the atom's extension *is* `A`. Any atom does — the valuation is built from
`A`, not read off a fixed one.
-/
theorem translation_realizes (D : TemporalOrder) (A : Set ↑D) (p : Atom) (t : ↑D) :
    TruthAt (translationModel D A) (translationHist D) t (Formula.atom p) ↔ t ∈ A :=
  translationModel_atom D A p t

/-- `translation_realizes` under `H`: `Hp` at `u` says every time strictly below `u` lies in `A`. -/
theorem translation_realizes_allPast (D : TemporalOrder) (A : Set ↑D) (p : Atom) (u : ↑D) :
    TruthAt (translationModel D A) (translationHist D) u (Formula.atom p).allPast
      ↔ ∀ r < u, r ∈ A := by
  rw [Truth.past_iff]
  exact forall_congr' fun r => forall_congr' fun _ => translation_realizes D A p r

/-- `translation_realizes` under `G`: `Gp` at `u` says every time strictly above `u` lies in `A`. -/
theorem translation_realizes_allFuture (D : TemporalOrder) (A : Set ↑D) (p : Atom) (u : ↑D) :
    TruthAt (translationModel D A) (translationHist D) u (Formula.atom p).allFuture
      ↔ ∀ r, u < r → r ∈ A := by
  rw [Truth.future_iff]
  exact forall_congr' fun r => forall_congr' fun _ => translation_realizes D A p r

/-! ## The permissive frame's history and model

`permissiveFrame` itself now lives in `Semantics/Frames/Standard.lean`; only the history and
model constructions stay here.
-/

/--
The permissive frame realizes **any** assignment of world states to times as a total history:
the task relation holds at every nonzero duration, and at duration `0` the two endpoints
coincide.
-/
def permissiveHist (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (f : ↑D → Bool) : WorldHistory (permissiveFrame D so nm).toTaskFrame :=
  WorldHistory.ofTotal _ f fun s t => by
    refine (permissiveFrame_taskRel (D := D) so nm _ _ _).mpr ?_
    by_cases h : t - s = 0
    · refine Or.inr ?_
      have : t = s := by
        have := sub_eq_zero.mp h
        exact this
      rw [this]
    · exact Or.inl h

/-- The model on the permissive frame that reads an atom off the `Bool` state. -/
def permissiveModel (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    TaskModel (permissiveFrame D so nm).toTaskFrame where
  valuation := fun w _ => w = true

/-- Truth of an atom along `permissiveHist D so nm f` is `f t = true`, at every time. -/
@[simp] theorem permissiveModel_atom (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (f : ↑D → Bool) (p : Atom) (t : ↑D) :
    TruthAt (permissiveModel D so nm) (permissiveHist D so nm f) t (Formula.atom p) ↔ f t = true :=
  Iff.rfl

/--
**Atom realisation, permissive twin.** The permissive frame realises an arbitrary `f : ↑D → Bool`
as the truth set of an atom along its reference history.

The counterpart of `translation_realizes` for `validOn_dn_iff_denselyOrdered`, whose (⇒) witness
is the permissive frame rather than the translation frame. Without it that proof would be the
one of the three left unconverted.
-/
theorem permissive_realizes (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (f : ↑D → Bool) (p : Atom) (t : ↑D) :
    TruthAt (permissiveModel D so nm) (permissiveHist D so nm f) t (Formula.atom p)
      ↔ f t = true :=
  permissiveModel_atom D so nm f p t

/-! ## The three (T1) correspondence theorems

All three (⇒) directions run the same argument, and the realisation lemmas above are what make
that visible: choose the realising data (a set `A ⊆ ↑D`, or an assignment `f : ↑D → Bool`), name
its realisation as an atom's truth set (`translation_realizes` / `permissive_realizes` and their
`H`/`G` forms), build the schema's antecedent through that realisation, instantiate the
hypothesis at the witness frame, and read the consequent back through the same realisation.

The atom is `Atom.mkBase "p"` throughout. Any atom would do — the refuting valuations are built
from the chosen data rather than read off a fixed one — which is why the realisation lemmas carry
a `(p : Atom)` binder instead of this module fixing one. -/

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
      letI so := succOrderOfIsLeastPos hp
      letI nm := noMaxOrder_of_duration D
      -- The realising data: the "blip" assignment, false exactly at `a + p`.
      set f : ↑D → Bool := fun t => decide (t ≠ a + p) with hf
      -- Realisation: `p` is true at `t` exactly when `f t = true`.
      have hreal := permissive_realizes D so nm f (Atom.mkBase "p")
      -- The antecedent `GGp`, built through that realisation.
      have hgg : TruthAt (permissiveModel D so nm) (permissiveHist D so nm f) a
          (Formula.atom (Atom.mkBase "p")).allFuture.allFuture := by
        rw [Truth.future_iff]
        intro s has
        rw [Truth.future_iff]
        intro r hsr
        refine (hreal r).mpr ?_
        have : a + p < r := lt_of_le_of_lt (not_lt.mp (hcov s has)) hsr
        simp only [hf, decide_eq_true_eq]
        exact ne_of_gt this
      -- Instantiate the schema at the witness frame, then read the consequent back.
      have hg := h (permissiveFrame D so nm) (Formula.atom (Atom.mkBase "p"))
        (permissiveModel D so nm) (permissiveHist D so nm f) a hgg
      rw [Truth.future_iff] at hg
      have hbad := (hreal (a + p)).mp (hg (a + p) hap)
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
    -- The realising data: the closed down-set of `x`.
    set A : Set ↑D := {r : ↑D | r ≤ x} with hA
    -- Realisation: `Hp` at `u` says every time strictly below `u` is `≤ x`.
    have hHiff : ∀ u : ↑D,
        TruthAt (translationModel D A) (translationHist D) u
            (Formula.atom (Atom.mkBase "p")).allPast ↔ ∀ r < u, r ≤ x :=
      translation_realizes_allPast D A (Atom.mkBase "p")
    -- The antecedent `(Hp ∧ p) ∧ F⊤`, built through that realisation.
    have hant : TruthAt (translationModel D A) (translationHist D) x
        (((Formula.atom (Atom.mkBase "p")).allPast.and (Formula.atom (Atom.mkBase "p"))).and
          Formula.top.someFuture) := by
      rw [Truth.and_iff, Truth.and_iff]
      refine ⟨⟨(hHiff x).mpr fun r hr => le_of_lt hr,
        (translation_realizes D A (Atom.mkBase "p") x).mpr (le_refl x)⟩, ?_⟩
      rw [Truth.some_future_iff]
      obtain ⟨y, hy⟩ := hex
      exact ⟨y, hy, fun hb => hb⟩
    -- Instantiate the schema at the witness frame, then read the consequent back.
    have hcons := h (translationFrame D) (Formula.atom (Atom.mkBase "p"))
      (translationModel D A) (translationHist D) x hant
    rw [Truth.some_future_iff] at hcons
    obtain ⟨v, hxv, hHv⟩ := hcons
    refine ⟨v, hxv, fun z hz => ?_⟩
    by_contra hlt
    exact absurd (hz : x < z) (not_lt.mpr ((hHiff v).mp hHv z (not_le.mp hlt)))
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
    -- The realising data: the strict down-set generated by `S`.
    set A : Set ↑D := {r : ↑D | ∃ u ∈ S, r < u} with hA
    -- Realisation: `Hp` at `u` says every time strictly below `u` is strictly below a member of
    -- `S`.
    have hHiff : ∀ u : ↑D,
        TruthAt (translationModel D A) (translationHist D) u
            (Formula.atom (Atom.mkBase "p")).allPast ↔ ∀ r < u, ∃ w ∈ S, r < w :=
      translation_realizes_allPast D A (Atom.mkBase "p")
    -- `s₀ ∈ S` witnesses `Hp` at `s₀`.
    have hHs₀ := (hHiff s₀).mpr fun r hr => ⟨s₀, hs₀, hr⟩
    -- The `△` antecedent: a time where it failed would be a least upper bound of `S`.
    have halways : ∀ u : ↑D, TruthAt (translationModel D A) (translationHist D) u
        ((Formula.atom (Atom.mkBase "p")).allPast.imp
          (Formula.atom (Atom.mkBase "p")).allPast.someFuture) := by
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
    -- Instantiate the schema at the witness frame, then read the consequent back.
    have hco := h (translationFrame D) (Formula.atom (Atom.mkBase "p"))
      (translationModel D A) (translationHist D) s₀ ((Truth.always_iff _).mpr halways) hHs₀
    rw [Truth.future_iff] at hco
    -- `b` is an upper bound strictly above `s₀`, so `Gp` at `s₀` puts `b` strictly below `S`.
    have hs₀b : s₀ < b := by
      rcases lt_or_eq_of_le (hb hs₀) with hlt | heq
      · exact hlt
      · exact absurd ⟨b, hb, fun c hc => heq ▸ hc hs₀⟩ hno
    obtain ⟨w, hw, hbw⟩ := (translation_realizes D A (Atom.mkBase "p") b).mp (hco b hs₀b)
    exact absurd (hb hw) (not_le.mpr hbw)
  · intro hcomp F φ M τ t halways hH
    rw [Truth.future_iff]
    intro s hts
    by_contra hns
    set S : Set ↑D := {u : ↑D | ∀ r < u, TruthAt M τ r φ} with hS
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

/-! ## The canonical frames' characterizations

`def:canonical-frames` introduces the paper's two canonical countermodel frames — the translation
frame `F^tr_D`, whose world states are the durations themselves and whose relation advances a
state by the duration elapsed, and the two-state frame `F^ts_D`, whose zero duration is the
identity and whose every positive duration permits every transition. `lem:canonical-frames` makes
four claims about them: **(a)** the translation frame is a *Deterministic* task frame; **(b)** its
possible worlds are exactly the translations `σ_c`; **(c)** the two-state frame is a task frame
just in case the duration order is *Discrete*; and **(d)** in that case it is not *Deterministic*,
and every assignment of its two states to times is one of its possible worlds.

The four claims are landed below in that order, on the two frames built in
`Semantics/Frames/Standard.lean` and the reference histories above. Claim (c) is stated at the
**bare relation** `permRel` rather than at the frame, because `permissiveFrame` cannot be applied
without the `SuccOrder` and `NoMaxOrder` data that discreteness itself supplies, so a frame-level
biconditional is not well formed; `permissiveFrame_taskRel_eq` ties the relation back to the
frame's own task relation, which is what makes the biconditionals statements about the frame
rather than about a lookalike relation.
-/

/--
**(a) of `lem:canonical-frames`.** The translation frame is *Deterministic* (`def:deterministic`),
over every temporal order: its task relation is presented by the function `fun w x => w + x`, and
a functionally presented relation has subsingleton fibres.

This generalises `f1_deterministic` in `Metalogic/Independence/RealTranslationFrame.lean`, which
proves determinism of a shift-set frame over ℝ, to the translation frame over an arbitrary
duration group.

The raw singleton-fibre fact `translationRel_fib_subsingleton` in `Semantics/Frames/Standard.lean`
does **not** discharge this goal directly: its `Fib` argument is the bare relation
`fun w x u => u = w + x` while the goal's is `(translationFrame D).toTaskFrame.TaskRel`, and the
two do not unify at the transparency the `Fib` motive's elaboration uses (measured). Routing
through `TaskFrame.fib_subsingleton_of_functional` with the relation bridge supplied pointwise is
what goes through.
-/
theorem translationFrame_deterministic (D : TemporalOrder) :
    (translationFrame D).toTaskFrame.Deterministic :=
  TaskFrame.fib_subsingleton_of_functional (f := fun (w : ↑D) (x : ↑D) => w + x)
    (fun w x u => translationFrame_taskRel w x u)

/--
The **state view** of a translation-frame history: its state function, retyped at the duration
carrier `↑D`.

Every statement below about arithmetic on a history's states goes through this view, and never
through a type ascription. `translationFrame D` is a plain `def` whose body is
`FrameOver.ofReflectiveRegular`, so its `WorldState` unifies with `↑D` at default transparency but
does not synthesize instances through it: `τ.state 0` in a position expecting a `↑D` elaborates,
any `+` with a `τ.state _` operand fails to synthesize `HAdd`, and ascribing the operand does not
repair it — the `binop%` elaborator reads the operand's inferred type before the ascription's (all
three measured). The house precedent for the view move is `WorldHistory.path` in
`Semantics/IntNormalForm.lean`, "the bare path underlying a possible world".
-/
def translationStates {D : TemporalOrder}
    (τ : WorldHistory (translationFrame D).toTaskFrame) : ↑D → ↑D := τ.state

/--
**`σ_c` of `def:canonical-frames`.** The translation by `c`, as the reference history
`translationHist` shifted in time by `c`.

Defining it as a time shift, rather than building a fresh total history over `fun z => z + c`,
keeps the non-elaborating `+` out of the definition entirely: `WorldHistory.timeShift_state` and
the state equation of `WorldHistory.ofTotal` are both `rfl`, so this history's state function is
`t ↦ t + c` definitionally, with no `HAdd` synthesis on a world-state operand anywhere.
-/
def translationSigma (D : TemporalOrder) (c : ↑D) :
    WorldHistory (translationFrame D).toTaskFrame :=
  (translationHist D).timeShift c

/-- The translation by `c` sends a time to that time plus `c`, read through the state view. -/
@[simp] theorem translationSigma_states (D : TemporalOrder) (c t : ↑D) :
    translationStates (translationSigma D c) t = t + c := rfl

/-- The reference history is the identity assignment, read through the state view. -/
@[simp] theorem translationHist_states (D : TemporalOrder) (t : ↑D) :
    translationStates (translationHist D) t = t := rfl

/-- `σ_0` is the reference history: the two agree pointwise through the state view. -/
@[simp] theorem translationSigma_zero (D : TemporalOrder) :
    translationSigma D 0 = translationHist D := by
  refine WorldHistory.ext_state fun t => ?_
  change translationStates (translationSigma D 0) t = translationStates (translationHist D) t
  rw [translationSigma_states, translationHist_states, add_zero]

/--
The paper's pointwise law for the translation frame: a possible world's state at `t` is its state
at `0` advanced by `t`.

The content is the history's own task-respecting field read through the frame's relation bridge at
the duration `t - 0`; `translationStates` is what lets the `+` in the statement elaborate.
-/
theorem translationStates_eq {D : TemporalOrder}
    (τ : WorldHistory (translationFrame D).toTaskFrame) (t : ↑D) :
    translationStates τ t = translationStates τ 0 + t := by
  have h := (translationFrame_taskRel (D := D) (τ.state 0) (t - 0) (τ.state t)).mp
    (τ.respects_task 0 t)
  rw [sub_zero] at h
  exact h

/--
**(b) of `lem:canonical-frames`, pointwise form.** Every possible world of the translation frame
*is* the translation by its own state at `0` — the paper's `τ = σ_{τ(0)}`.
-/
theorem translation_eq_sigma {D : TemporalOrder}
    (τ : WorldHistory (translationFrame D).toTaskFrame) :
    τ = translationSigma D (translationStates τ 0) := by
  refine WorldHistory.ext_state fun t => ?_
  change translationStates τ t = translationStates (translationSigma D _) t
  rw [translationSigma_states, translationStates_eq τ t, add_comm]


/--
**(b) of `lem:canonical-frames`, bijective form.** The possible worlds of the translation frame
are exactly the durations: a history goes to its state at `0`, and a duration `c` to the
translation `σ_c`.

This is the form that makes the possible-world count of the translation frame exactly the
duration count, which is what the paper's countermodel arguments over this frame use — each
countermodel picks out a translation and reads a formula along it.

The `right_inv` component needs a `change` to beta-reduce the composite before the state equation
can be rewritten (measured).
-/
def translationHistEquiv (D : TemporalOrder) :
    WorldHistory (translationFrame D).toTaskFrame ≃ ↑D where
  toFun τ := translationStates τ 0
  invFun c := translationSigma D c
  left_inv τ := (translation_eq_sigma τ).symm
  right_inv c := by
    change translationStates (translationSigma D c) 0 = c
    rw [translationSigma_states, zero_add]

/--
**(b) of `lem:canonical-frames`, set form.** The Lean reading of the paper's displayed equation
for the translation frame's history set, `H_F = {σ_c | c ∈ D}`: the translations exhaust the
world histories, stated as the range of `translationSigma` being everything.

The paper's text is cited by anchor and quoted nowhere; this is the statement its displayed
equation makes about the frame's own `WorldHistory` type.
-/
theorem translation_histSet_eq (D : TemporalOrder) :
    Set.range (translationSigma D)
      = (Set.univ : Set (WorldHistory (translationFrame D).toTaskFrame)) :=
  Set.eq_univ_of_forall fun τ => ⟨translationStates τ 0, (translation_eq_sigma τ).symm⟩

/--
**(b) of `lem:canonical-frames`, uniqueness form.** Every possible world of the translation frame
is the translation by exactly one duration — the existence half is `translation_eq_sigma` and the
uniqueness half reads the index back off the state at `0`.
-/
theorem translation_exists_unique {D : TemporalOrder}
    (τ : WorldHistory (translationFrame D).toTaskFrame) :
    ∃! c : ↑D, τ = translationSigma D c := by
  refine ⟨translationStates τ 0, translation_eq_sigma τ, fun c hc => ?_⟩
  have := congrArg (fun σ => translationStates σ 0) hc
  simpa using this.symm


/--
The **bare permissive relation** on the two-state carrier: `w ⇒_d u` iff `d ≠ 0` or `w = u`, which
is `def:canonical-frames`' two-state clause read off directly.

Claim (c) of `lem:canonical-frames` is stated here rather than at `permissiveFrame`, because that
frame cannot be applied without the `SuccOrder` and `NoMaxOrder` data that discreteness itself
supplies — so "`permissiveFrame D so nm` is a task frame iff `D` is Discrete" is not a well-formed
statement, its own hypotheses already presupposing the right-hand side. The relation carries no
such data, and `permissiveFrame_taskRel_eq` ties it back to the frame.
-/
def permRel (D : TemporalOrder) : Bool → ↑D → Bool → Prop := fun w d u => d ≠ 0 ∨ w = u

/-- The definitional bridge for `permRel`, which every helper below consumes. -/
theorem permRel_iff (D : TemporalOrder) (w : Bool) (d : ↑D) (u : Bool) :
    permRel D w d u ↔ (d ≠ 0 ∨ w = u) := Iff.rfl

/--
**The tie-back.** The two-state frame's own task relation *is* `permRel`.

Without this lemma the biconditionals below would be statements about a lookalike relation rather
than about the frame of `def:canonical-frames`: the frame is built by
`FrameOver.ofReflectiveRegular`, whose relation equation is what identifies the two.
-/
theorem permissiveFrame_taskRel_eq (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    (permissiveFrame D so nm).TaskRel = permRel D :=
  FrameOver.ofReflectiveRegular_taskRel_eq

/--
*Reflection* holds for `permRel` unconditionally — recorded so a reader of the biconditionals
below sees which of the frame constraints is not at issue in them.
-/
theorem permRel_reflection (D : TemporalOrder) :
    ∀ w (d : ↑D) u, permRel D w d u ↔ permRel D u (-d) w :=
  TaskFrame.reflection_of_permissive (permRel_iff D)

/--
**(c), the "if" half.** A least positive duration `p` makes *Limit* hold for `permRel`: the
`p`-neighbourhood of a state contains only states reachable at a duration of absolute value below
`p`, and the only such duration is `0`, which forces the two states equal.
-/
theorem permRel_limit_of_isLeast {D : TemporalOrder} {p : ↑D}
    (hp : IsLeast {x : ↑D | 0 < x} p) : TaskFrame.Limit (permRel D) := by
  intro w u h
  obtain ⟨y, hy, hR⟩ := h p hp.1
  rcases hR with hne | heq
  · exact absurd (hp.2 (abs_pos.mpr hne)) (not_le.mpr hy)
  · exact heq.symm

/--
**(c), the "only if" half.** Over a densely ordered duration carrier *Limit* fails for `permRel`:
every neighbourhood of a state contains the other one, since a positive duration strictly below
the neighbourhood's radius always exists and every nonzero duration permits every transition.

This machine-checks the sentence `TaskFrame.limit_of_permissive`'s docstring already asserts in
prose — that over a dense carrier every state lies in every cone of every other state, and *Limit*
fails outright — with `w₀` and `w₁` as the two-state witness.
-/
theorem permRel_not_limit_of_dense (D : TemporalOrder) (hd : DenselyOrdered ↑D) :
    ¬ TaskFrame.Limit (permRel D) := by
  intro h
  have : (false : Bool) = true := by
    refine h true false ?_
    intro x hx
    obtain ⟨y, hy0, hyx⟩ := hd.dense 0 x hx
    exact ⟨y, by rwa [abs_of_pos hy0], Or.inl (ne_of_gt hy0)⟩
  simp at this

/--
*Discrete* (`def:frame-properties`) is equivalent to carrying a least positive duration: forward
by instantiating the discreteness clause at `0` on the positive duration a nontrivial duration
group always has, and back by `isLeast_succ_of_isLeast_pos`, which turns a least positive `p` into
a least element of every strict upper set.

`FrameProperty.lean`'s own `IsDiscrete` docstring flags this equivalence as something that ought
to be a proof step rather than a definitional assumption. This is that proof step, and it is what
puts the discreteness side of the biconditionals below into the form
`Semantics.duration_dense_or_least_pos` consumes.
-/
theorem isDiscrete_iff_exists_isLeast_pos (D : TemporalOrder) :
    (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y')
      ↔ ∃ p : ↑D, IsLeast {x : ↑D | 0 < x} p := by
  constructor
  · intro h
    obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
    obtain ⟨y', hy'⟩ := h 0 ⟨p, hp⟩
    exact ⟨y', hy'⟩
  · rintro ⟨p, hp⟩ x -
    exact ⟨x + p, isLeast_succ_of_isLeast_pos hp x⟩

/--
**(c), headline form for *Limit*.** *Limit* holds for `permRel` exactly when the duration order is
*Discrete* — the two halves above, joined by the density dichotomy
`Semantics.duration_dense_or_least_pos`, which makes the failure under density and the success
under a least positive duration exhaustive.
-/
theorem permRel_limit_iff_isDiscrete (D : TemporalOrder) :
    TaskFrame.Limit (permRel D)
      ↔ (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y') := by
  rw [isDiscrete_iff_exists_isLeast_pos]
  constructor
  · intro h
    rcases duration_dense_or_least_pos (D := ↑D) with hd | hp
    · exact absurd h (permRel_not_limit_of_dense D hd)
    · exact hp
  · rintro ⟨p, hp⟩
    exact permRel_limit_of_isLeast hp

/--
**(c) of `lem:canonical-frames`.** The four task-frame constraints of `def:frame` — *Compositional*,
*Serial*, *Limit* and *Saturation* — hold for the two-state relation exactly when the duration
order is *Discrete*.

The conjunction, not *Limit* alone, is the honest Lean reading of the paper's "is a task frame
just in case `D` is Discrete": the other three constraints hold unconditionally for a permissive
relation, so *Limit* is the only one carrying the biconditional's weight, and saying so takes
stating all four.
-/
theorem permRel_constraints_iff_isDiscrete (D : TemporalOrder) :
    (TaskFrame.Compositional (permRel D) ∧ TaskFrame.Serial (permRel D)
        ∧ TaskFrame.Limit (permRel D) ∧ TaskFrame.Saturation (permRel D))
      ↔ (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y') := by
  rw [isDiscrete_iff_exists_isLeast_pos]
  constructor
  · rintro ⟨-, -, hlim, -⟩
    rcases duration_dense_or_least_pos (D := ↑D) with hd | hp
    · exact absurd hlim (permRel_not_limit_of_dense D hd)
    · exact hp
  · rintro ⟨p, hp⟩
    exact ⟨TaskFrame.comp_of_permissive (permRel_iff D),
      TaskFrame.serial_of_permissive (permRel_iff D),
      permRel_limit_of_isLeast hp,
      TaskFrame.saturation_of_permissive (permRel_iff D)⟩


/--
**(d) of `lem:canonical-frames`, the refutation.** Where it is a task frame, the two-state frame is
not *Deterministic*: both states sit in one fibre over a positive duration, since every nonzero
duration permits every transition.

The positive duration comes from the nontriviality of the duration group
(`TaskFrame.exists_pos_of_nontrivial`), so the refutation needs no hypothesis beyond the frame's
own data.
-/
theorem permissiveFrame_not_deterministic (D : TemporalOrder) (so : SuccOrder ↑D)
    (nm : NoMaxOrder ↑D) : ¬ (permissiveFrame D so nm).toTaskFrame.Deterministic := by
  intro h
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
  have h1 : (true : Bool) ∈ TaskFrame.Fib (permissiveFrame D so nm).toTaskFrame.TaskRel true p :=
    (permissiveFrame_taskRel so nm _ _ _).mpr (Or.inr rfl)
  have h2 : (false : Bool) ∈ TaskFrame.Fib (permissiveFrame D so nm).toTaskFrame.TaskRel true p :=
    (permissiveFrame_taskRel so nm _ _ _).mpr (Or.inl (ne_of_gt hp))
  exact absurd (h true p h1 h2) (by simp)

/--
The **state view** of a two-state-frame history: its state function, retyped as an assignment of
the two states to times. It exists for the same measured reason `translationStates` does — the
frame's `WorldState` unifies with `Bool` but does not synthesize instances through it.
-/
def permissiveStates (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (τ : WorldHistory (permissiveFrame D so nm).toTaskFrame) : ↑D → Bool := τ.state

/--
**(d) of `lem:canonical-frames`, bijective form.** Every function from durations to the two states
is one of the two-state frame's possible worlds, and distinct functions give distinct worlds:
`permissiveHist` and the state view are mutually inverse.

The module already had this claim in substance — `permissiveHist` builds a total history over an
arbitrary assignment — and this states it as the bijection the paper asserts.

The `left_inv` component is `rfl`, which depends on `permissiveHist`'s state function being
definitionally the assignment it is given. A future change breaking that would break this proof
loudly at build time rather than silently weakening it.
-/
def permissiveHistEquiv (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    (↑D → Bool) ≃ WorldHistory (permissiveFrame D so nm).toTaskFrame where
  toFun f := permissiveHist D so nm f
  invFun τ := permissiveStates D so nm τ
  left_inv f := rfl
  right_inv τ := by
    refine WorldHistory.ext_state fun t => ?_
    rfl

end FormalSystem.Semantics
