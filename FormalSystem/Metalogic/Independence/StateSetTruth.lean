/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.OrderTransfer

/-!
# `satSet` and the state-set bridge — truth depends on the world state alone

The one real proof obligation behind `cor:no-characterization`. Over a frame satisfying (H1) and
(H2) (`Independence/OrderTransfer.lean`) the truth of an L⁺ formula at a world history and a time
depends **only on the world state of evaluation** — not on which history passes through it, and
not on the time.

That is made precise by a recursion `satSet` computing, from a valuation alone, the set of world
states at which a formula holds, together with the bridge theorem identifying `PlusTruthAt` with
membership in it.

## Main Definitions

- `satSet V φ` — the state set of `φ` under the valuation `V`, by recursion on `PlusFormula`

## Main Results

- `plusTruthAt_iff_mem_satSet` — **the bridge**: `PlusTruthAt M τ t φ ↔ τ(t) ∈ satSet M.valuation φ`
- `plusValidOn_iff_satSet_univ` — the validity corollary: `F ⊨ φ` iff `satSet V φ` is everything,
  for every `V`
- `determined_of_orderFlow` — *Determined* is valid over **any** (H1)+(H2) frame, deterministic or
  not

## The recursion, clause by clause

Every clause but two is the obvious one. The two worth pausing on:

* **`box`.** `PlusTruthAt`'s `□` clause quantifies over all world histories at the *same* time,
  and under (H2) the states those histories occupy at that time exhaust `W`. So `□φ` is true
  everywhere or nowhere, according as `satSet φ` is everything or not. That is written here as
  `{_w | ∀ v, v ∈ satSet V φ}` — a set whose defining condition ignores its own argument. This
  encoding is deliberate: writing it as `if satSet V φ = Set.univ then univ else ∅` would require
  deciding a set equality and pull `Classical.choice` into the *definition*, which the axiom pin
  in `Independence/DeterminismUndefinable.lean` would then have to explain away. The ignoring-set
  form needs no decidability at all.
* **`stab`.** `satSet V (⊡φ) = satSet V φ`, one line — and it holds for the two frames this is
  instantiated at for genuinely *different* reasons. Over `F°` the histories through a state at a
  time are many, but truth depends only on that state, so quantifying over them changes nothing.
  Over `F¹` there is only one such history (`f1_eq_of_states_eq`), so the quantifier is vacuous.
  The `F¹` reason uses only the choice-free (⇒) half of `lem:deterministic-singleton`. Neither
  reason is needed *here*: the clause falls out of the induction hypothesis alone.

## Why the history is quantified inside the induction

`generalizing` would not suffice — the `box` case needs the induction hypothesis at a *different*
history than the one the goal mentions, and the temporal cases need it at a different time. So
the statement proved is `∀ φ, ∀ τ t, …`, with `τ` and `t` bound inside. This is the
`Independence/` house style; see that directory's README.

## References

* JPL paper `cor:no-characterization`, `app:drift`, `lem:deterministic-singleton`
* `FormalSystem/Metalogic/Independence/OrderTransfer.lean` — (H1), (H2) and the transfer lemmas
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage

/--
The **state set** of an L⁺ formula under a valuation `V` on a linearly ordered carrier `W`: the
set of world states at which the formula holds, computed without reference to any frame, any
history, or any task relation.

The recursion mentions only the order on `W`. That is the crux of `cor:no-characterization`: two
frames with the same state order and (H1)+(H2) satisfy the same recursion, hence validate exactly
the same formulas, however differently their task relations behave.
-/
def satSet {W : Type} [LinearOrder W] (V : W → Atom → Prop) : PlusFormula → Set W
  | .atom p => {w | V w p}
  | .bot => ∅
  | .imp φ ψ => {w | w ∈ satSet V φ → w ∈ satSet V ψ}
  | .box φ => {_w | ∀ v : W, v ∈ satSet V φ}
  | .untl ψ φ => {w | ∃ v, w < v ∧ v ∈ satSet V φ ∧ ∀ u, w < u → u < v → u ∈ satSet V ψ}
  | .snce ψ φ => {w | ∃ v, v < w ∧ v ∈ satSet V φ ∧ ∀ u, v < u → u < w → u ∈ satSet V ψ}
  | .stab φ => satSet V φ

section Clauses

variable {W : Type} [LinearOrder W] (V : W → Atom → Prop)

@[simp] theorem mem_satSet_atom (p : Atom) (w : W) :
    w ∈ satSet V (.atom p) ↔ V w p := Iff.rfl

@[simp] theorem mem_satSet_bot (w : W) : w ∈ satSet V .bot ↔ False := Iff.rfl

@[simp] theorem mem_satSet_imp (φ ψ : PlusFormula) (w : W) :
    w ∈ satSet V (.imp φ ψ) ↔ (w ∈ satSet V φ → w ∈ satSet V ψ) := Iff.rfl

@[simp] theorem mem_satSet_box (φ : PlusFormula) (w : W) :
    w ∈ satSet V (.box φ) ↔ ∀ v : W, v ∈ satSet V φ := Iff.rfl

@[simp] theorem mem_satSet_untl (ψ φ : PlusFormula) (w : W) :
    w ∈ satSet V (.untl ψ φ) ↔
      ∃ v, w < v ∧ v ∈ satSet V φ ∧ ∀ u, w < u → u < v → u ∈ satSet V ψ := Iff.rfl

@[simp] theorem mem_satSet_snce (ψ φ : PlusFormula) (w : W) :
    w ∈ satSet V (.snce ψ φ) ↔
      ∃ v, v < w ∧ v ∈ satSet V φ ∧ ∀ u, v < u → u < w → u ∈ satSet V ψ := Iff.rfl

/-- **The `⊡` clause**: stability adds nothing to a state set. -/
@[simp] theorem satSet_stab (φ : PlusFormula) : satSet V (.stab φ) = satSet V φ := rfl

end Clauses

/-! ## The bridge -/

variable {F : TaskFrame} [LinearOrder F.WorldState]

/--
**The state-set bridge.** Over a frame satisfying (H1) and (H2), an L⁺ formula is true at a world
history and a time exactly when the world state occupied there lies in the formula's state set.

By induction on `PlusFormula`, with the history and the time universally quantified inside the
induction (module docstring). Every constructor has a case: `atom`, `bot`, `imp`, `box`, `untl`,
`snce`, `stab`.
-/
theorem plusTruthAt_iff_mem_satSet (h1 : OrderFlow F) (h2 : StateOccurs F)
    (M : TaskModel F) (φ : PlusFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ := by
  induction φ with
  | atom p =>
    intro τ t
    rw [mem_satSet_atom]
    exact Iff.rfl
  | bot => intro τ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
    intro τ t
    rw [mem_satSet_imp]
    exact imp_congr (ihφ τ t) (ihψ τ t)
  | box φ ih =>
    intro τ t
    rw [mem_satSet_box]
    constructor
    · intro h v
      obtain ⟨σ, hst⟩ := h2 v t
      have hv := (ih σ t).mp (h σ)
      rwa [hst] at hv
    · intro h σ
      exact (ih σ t).mpr (h _)
  | untl ψ φ ihψ ihφ =>
    intro τ t
    rw [mem_satSet_untl]
    constructor
    · rintro ⟨s, hts, hφ, hψ⟩
      refine ⟨τ.state s, h1.strictMono τ hts, (ihφ τ s).mp hφ, ?_⟩
      intro u hu1 hu2
      obtain ⟨c, hc1, hc2, hcu⟩ := h1.between τ hu1 hu2
      have hc := (ihψ τ c).mp (hψ c hc1 hc2)
      rwa [hcu] at hc
    · rintro ⟨v, hlt, hv, hu⟩
      obtain ⟨s, hts, hsv⟩ := h1.hits_future τ hlt
      refine ⟨s, hts, (ihφ τ s).mpr (by rw [hsv]; exact hv), ?_⟩
      intro r hr1 hr2
      refine (ihψ τ r).mpr (hu _ (h1.strictMono τ hr1) ?_)
      have hrs := h1.strictMono τ hr2
      rwa [hsv] at hrs
  | snce ψ φ ihψ ihφ =>
    intro τ t
    rw [mem_satSet_snce]
    constructor
    · rintro ⟨s, hst, hφ, hψ⟩
      refine ⟨τ.state s, h1.strictMono τ hst, (ihφ τ s).mp hφ, ?_⟩
      intro u hu1 hu2
      obtain ⟨c, hc1, hc2, hcu⟩ := h1.between_past τ hu1 hu2
      have hc := (ihψ τ c).mp (hψ c hc1 hc2)
      rwa [hcu] at hc
    · rintro ⟨v, hlt, hv, hu⟩
      obtain ⟨s, hst, hsv⟩ := h1.hits_past τ hlt
      refine ⟨s, hst, (ihφ τ s).mpr (by rw [hsv]; exact hv), ?_⟩
      intro r hr1 hr2
      refine (ihψ τ r).mpr (hu _ ?_ (h1.strictMono τ hr2))
      have hsr := h1.strictMono τ hr1
      rwa [hsv] at hsr
  | stab φ ih =>
    intro τ t
    rw [satSet_stab]
    constructor
    · intro h
      exact (ih τ t).mp (h τ rfl)
    · intro h σ hsame
      refine (ih σ t).mpr ?_
      rw [← hsame]
      exact h

/--
**The validity corollary.** Over an (H1)+(H2) frame, `φ` is frame-valid exactly when its state
set is the whole carrier under every valuation.

The right-hand side mentions no frame at all — which is what makes two such frames over the same
ordered carrier validate the same formulas.
-/
theorem plusValidOn_iff_satSet_univ (h1 : OrderFlow F) (h2 : StateOccurs F) (φ : PlusFormula) :
    F.PlusValidOn φ ↔ ∀ V : F.WorldState → Atom → Prop, satSet V φ = Set.univ := by
  constructor
  · intro hv V
    ext w
    simp only [Set.mem_univ, iff_true]
    obtain ⟨τ, hst⟩ := h2 w 0
    have h := (plusTruthAt_iff_mem_satSet h1 h2 ⟨V⟩ φ τ 0).mp (hv ⟨V⟩ τ 0)
    rwa [hst] at h
  · intro h M τ t
    refine (plusTruthAt_iff_mem_satSet h1 h2 M φ τ t).mpr ?_
    rw [h M.valuation]
    exact Set.mem_univ _

/--
***Determined* is valid over every (H1)+(H2) frame**, whether or not it is deterministic.

`satSet V (φ → ⊡φ)` is `{w | w ∈ satSet V φ → w ∈ satSet V φ}`, which is everything. This is the
generic reason the converse of `determined_of_deterministic` fails: validity of *Determined*
tracks "truth depends on the state alone", which is strictly weaker than determinism of the task
relation. `Independence/DeterminismUndefinable.lean` instantiates it at a frame that is not
deterministic.
-/
theorem determined_of_orderFlow (h1 : OrderFlow F) (h2 : StateOccurs F) (φ : PlusFormula) :
    F.PlusValidOn (.imp φ (.stab φ)) := by
  rw [plusValidOn_iff_satSet_univ h1 h2]
  intro V
  ext w
  simp only [mem_satSet_imp, satSet_stab, Set.mem_univ, iff_true]
  exact id

end FormalSystem.Metalogic.Independence
