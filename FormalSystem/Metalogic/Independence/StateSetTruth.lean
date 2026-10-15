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
- `plusTruthAt_iff_mem_satSet_of_isRegular` — `lem:state-set`'s first sentence: the bridge over a
  frame satisfying `def:flow`, with (H2) discharged
- `determined_of_orderFlow_of_isRegular` — its second sentence: *Determined* is valid over every
  such frame
- `plusValidOn_iff_satSet_univ_of_isRegular` — its third sentence: frame-validity is the state set
  exhausting the carrier under every assignment

## The two hypothesis forms

(H2) is derivable for a regular frame: `StateOccurs.of_isRegular`
(`Independence/OrderTransfer.lean`) reads it off `cor:occurrence`. The `_of_isRegular` section at
the end of this file therefore states all three results over `def:flow`'s hypotheses alone —
`[LinearOrder F.WorldState]` with `OrderFlow F` — which is how `lem:state-set` itself reads.

Both forms earn their keep, for different reasons. The derivation runs through `thm:extension` and
hence Zorn's lemma, so the `_of_isRegular` forms carry `Classical.choice`. The two-hypothesis
forms carry none: `Independence/DeterminismUndefinable.lean` discharges (H2) at each of its two
frames by an explicit affine witness, and a choice-free axiom profile is exactly what the pin it
keeps on them asserts.

## Choice dependence

Three routes reach `lem:state-set`'s three sentences, and they differ in what they cost. The
table answers, at a glance, whether a given result is choice-dependent.

| Route | Hypotheses | (H2) from | Choice cost | Consumers |
|---|---|---|---|---|
| two-hypothesis | `OrderFlow F`, `StateOccurs F` | assumed | none | `F°`, `F¹` |
| `_of_isRegular` | `OrderFlow F`, `[F.IsRegular]` | `cor:occurrence` | argument-borne | none |
| flow | `(D : TemporalOrder)` | explicit translation | none | none |
| frame | `(D : TemporalOrder)` | the paper's `σ_c` | frame-borne | none |

The first two rows are this file; the last two are `Independence/TranslationStateSet.lean`.

Route by route:

* **The two-hypothesis forms** take (H2) as a hypothesis and cost nothing:
  `plusTruthAt_iff_mem_satSet` reports `[propext]` alone and `determined_of_orderFlow`
  `[propext, Quot.sound]`. The whole generic argument — the recursion, the bridge and the
  validity corollary — is therefore choice-free, and only *instantiation* can add choice.
* **The `_of_isRegular` forms** derive (H2) through `StateOccurs.of_isRegular`, hence
  `cor:occurrence`, hence `thm:extension`, hence Zorn's lemma, and so carry `Classical.choice`
  argument-borne. They state `lem:state-set` at `def:flow`'s hypotheses alone, which is how the
  paper reads it.
* **The flow route** (`Independence/TranslationStateSet.lean`) is where the choice-free
  instantiation lives. Over an arbitrary duration group it exhibits the witnessing world history
  outright, as the translation through the required state, so the `cor:occurrence` chain is never
  entered: the three sentences there report `[propext, Quot.sound]`, with no `Classical.choice`
  at all.
* **The frame route** (same file) restates them at the translation frame, with the witness
  written as the paper's own `σ_c`. Its `Classical.choice` is the frame constant's own, carried by
  the structural obligation that constant discharges, and `#print axioms` traverses a
  declaration's type as well as its value — so the cost is frame-borne, not a consequence of how
  (H2) is reached there.

**The consumer audit.** Every consumption of the results in this file, across the whole live tree,
sits in `Independence/DeterminismUndefinable.lean`: `fzero_determined` applies
`determined_of_orderFlow` at `F°`, and `fzero_plusValidOn_iff_f1` applies
`plusValidOn_iff_satSet_univ` twice, at `F°` and at `F¹`; `determined_valid_on_non_deterministic`
and `deterministic_not_plusDefinable` rest on those two in turn. All four take the
two-hypothesis route, each passing an explicitly constructed (H2) witness, so **none is on the
Zorn route** and none has a choice-free route to move to that it does not already take; their
residual `Classical.choice` is carrier-borne, from `ℝ`. The three `_of_isRegular` forms have no
consumer at all: they exist to state `lem:state-set` at `def:flow`'s own hypotheses.

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
* JPL paper `def:state-set` — the recursion `satSet` transcribes; `def:flow` — the order-isomorphism
  condition `OrderFlow` states pointwise; `lem:state-set` — the three sentences the `_of_isRegular`
  section states; `cor:occurrence` — the discharge of (H2)
* JPL paper `prop:nomic-tense-free` runs this same state-set induction over the tense-free fragment
  `{pᵢ, ⊥, →, □, nomic}`: `□` and the nomic operator share one clause, and there are no temporal
  clauses at all. Its `□` case consumes `cor:occurrence`, as the `box` clause here does, and its
  nomic case consumes `lem:nomic-occurrence`, which is `cor:occurrence` applied to the relativized
  frame. No nomic machinery exists in this tree, which `StarLanguage/README.md` and
  `OpenLanguage/README.md` both record as a deliberate exclusion; a port of that proposition can
  reuse the recursion and the bridge here unchanged, adding one clause and one occurrence fact.
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

/-! ## `lem:state-set` over a `def:flow` frame

The three results above read as `lem:state-set` does once (H2) is discharged rather than assumed.
`def:flow` asks that the state carrier be linearly ordered and that every possible world be an
order-isomorphism of the duration order onto it — which is `[LinearOrder F.WorldState]` together
with `OrderFlow F`, and nothing further. The three forms in this section therefore carry exactly
`def:flow`'s hypotheses, with the bundling class `[F.IsRegular]` standing in for the frame axioms
every task frame of the paper has anyway.

Each routes through `StateOccurs.of_isRegular`, hence `cor:occurrence`, hence `thm:extension` and
Zorn's lemma, so each carries `Classical.choice`. The two-hypothesis forms above carry none, and
are what `Independence/DeterminismUndefinable.lean` consumes.
-/

section Regular

/--
**`lem:state-set`, first sentence**: over a task frame satisfying `def:flow`, an L⁺ formula is
true at a possible world and a time exactly when the world state occupied there lies in the
formula's state set.

`[LinearOrder F.WorldState]` with `(h : OrderFlow F)` *is* `def:flow`'s condition, with nothing
left over: (H2) is supplied by `StateOccurs.of_isRegular` from the bundling class. That route runs
through `cor:occurrence`, hence `thm:extension` and Zorn's lemma, so this form carries
`Classical.choice` where `plusTruthAt_iff_mem_satSet` carries none.
-/
theorem plusTruthAt_iff_mem_satSet_of_isRegular {F : TaskFrame}
    [LinearOrder F.WorldState] [F.IsRegular] (h : OrderFlow F)
    (M : TaskModel F) (φ : PlusFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ :=
  plusTruthAt_iff_mem_satSet h (StateOccurs.of_isRegular F) M φ

/--
**`lem:state-set`, second sentence**: *Determined* is valid over every task frame satisfying
`def:flow`, deterministic or not.

Immediate from the first sentence, since `def:state-set`'s stability clause leaves a state set
unchanged. As above, the hypotheses are exactly `def:flow`'s, and the discharge of (H2) through
`cor:occurrence`, `thm:extension` and Zorn's lemma makes this form carry `Classical.choice` where
`determined_of_orderFlow` does not.
-/
theorem determined_of_orderFlow_of_isRegular {F : TaskFrame}
    [LinearOrder F.WorldState] [F.IsRegular] (h : OrderFlow F) (φ : PlusFormula) :
    F.PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_orderFlow h (StateOccurs.of_isRegular F) φ

/--
**`lem:state-set`, third sentence**: over a task frame satisfying `def:flow`, `φ` is frame-valid
exactly when its state set exhausts the carrier under every assignment.

The right-hand side mentions no frame, which is the reduction `lem:state-set` is cited for. The
hypotheses are exactly `def:flow`'s, and the discharge of (H2) through `cor:occurrence`,
`thm:extension` and Zorn's lemma makes this form carry `Classical.choice` where
`plusValidOn_iff_satSet_univ` does not.
-/
theorem plusValidOn_iff_satSet_univ_of_isRegular {F : TaskFrame}
    [LinearOrder F.WorldState] [F.IsRegular] (h : OrderFlow F) (φ : PlusFormula) :
    F.PlusValidOn φ ↔ ∀ V : F.WorldState → Atom → Prop, satSet V φ = Set.univ :=
  plusValidOn_iff_satSet_univ h (StateOccurs.of_isRegular F) φ

end Regular

end FormalSystem.Metalogic.Independence
