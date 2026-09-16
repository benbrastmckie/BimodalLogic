/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.StarLanguage.StarValidity
import FormalSystem.Semantics.PlusLanguage.PlusNonValidities

/-!
# State-locality: the L⋆ fragment whose truth is fixed by the present world state

`StarFormula.StateLocal` is a syntactic fragment of L⋆
(`FormalSystem/StarLanguage/Formula.lean`), and `IsStateLocal` is the semantic property it
approximates: at a fixed time `t` and a fixed stored-time vector `v⃗`, two possible worlds
carrying the *same world state at `t`* agree about `φ`. That is exactly the class `⊡` quantifies
over, so a state-local `φ` is already `⊡`-stable — the headline `φ ↔ ⊡φ` below.

## Main Definitions

- `StarFormula.StateLocal` — the syntactic fragment, by structural recursion
- `IsStateLocal` — the semantic property: `SameStateAt τ σ t` transfers truth at `(t, v⃗)`

## Main Results

- `isStateLocal_box`, `isStateLocal_stab` — `□` and `⊡` are state-local for an **arbitrary**
  argument, which is why the recursion admits them without a recursive hypothesis
- `isStateLocal_of_stateLocal` — soundness of the syntactic fragment against the semantics
- `not_isStateLocal_someFuture`, `not_isStateLocal_somePast`, `not_isStateLocal_timeRecall` —
  the three excluded constructors are excluded by *theorem*, not by stipulation
- `stateLocal_stab_iff` — the headline, pointwise: `φ ↔ ⊡φ` at every point, for state-local `φ`
- `stateLocal_starValid_iff_stab` — the headline as a validity

## Which constructors are state-local, and why

Read off `StarTruthAt` (`Semantics/StarLanguage/StarTruth.lean`) clause by clause, at the **same** evaluation
time and the **same** register vector on both sides:

| Constructor | State-local? | Why |
|---|---|---|
| `atom p` | yes | `M.valuation (τ.states t ht) p` reads the state at `t` and nothing else |
| `bot` | yes | constant |
| `imp φ ψ` | yes if both are | pointwise |
| `box φ` | yes, for arbitrary `φ` | `∀ σ, σ.IsTotal → …` does not mention `τ` at all |
| `stab φ` | yes, for arbitrary `φ` | the class `⟨τ⟩ₜ` is unchanged by replacing `τ` with any history agreeing at `t` (`sameStateAt_congr_left`) |
| `untl ψ φ` | no | quantifies over `s > t`, where the two histories may diverge |
| `snce ψ φ` | no | quantifies over `s < t`, likewise |
| `timeStore i φ` | yes if `φ` is | evaluation stays at `t`, and both sides write the same `t` |
| `timeRecall i φ` | no | moves evaluation to `vᵢ`, which the hypothesis at `t` does not constrain |

`box` and `stab` are the two entries a reader is most likely to expect a recursive hypothesis on.
They do not need one: `isStateLocal_box` and `isStateLocal_stab` are proved for an arbitrary
argument, so the fragment is strictly larger than a naive "every subformula is state-local"
reading would give.

## Same-time, not different-times

`stab_state_only` (`Semantics/PlusLanguage/PlusTruth.lean`) is a **different-times** statement: `τ(t) = σ(s)`
transfers `⊡φ` from `(τ, t)` to `(σ, s)`. That shape does **not** generalize to this fragment —
`box φ` at `t` and at `s` can differ, and `timeStore i` writes a different time into the register
on each side. The same-time shape used here (one `t`, one `v⃗`) is both provable for the fragment
and exactly what the consumer needs: `settledDisj_iff` (`Semantics/StarLanguage/StarValidity.lean`) evaluates
`φ` at the *single* time held in register `2`.

So this module is the companion facing the other way to `stab_state_only`: that lemma says `⊡φ`
is state-local, this one says a state-local `φ` is already `⊡`-stable.

## Sound, not complete

`StarFormula.StateLocal` is a **sufficient** syntactic condition, not a characterization. For
instance `↑ⁱ↓ⁱφ` is semantically state-local whenever `φ` is — the store immediately preceding
the recall returns evaluation to the present time — yet it is syntactically rejected, because the
`timeRecall` clause is `False` unconditionally. Recorded here so the gap reads as a design
choice: the fragment is the one the consumers need, kept small enough that its soundness proof is
a nine-case induction with no side conditions.

## The three exclusions live on one frame

`not_isStateLocal_someFuture`, `not_isStateLocal_somePast` and `not_isStateLocal_timeRecall` are
all witnessed on the permissive frame `NF` over `ℤ` (`Semantics/PlusLanguage/PlusNonValidities.lean`), where
every function `ℤ → ℕ` is a possible world and `natModel` makes each atom true at world state `0`
and nowhere else. No second countermodel frame is built: two possible worlds agreeing at `0` and
disagreeing away from `0` refute all three.

## References

* JPL paper `def:BLstar-semantics` — the truth clauses being classified
* `FormalSystem/Semantics/StarLanguage/StarTruth.lean` — `StarTruthAt`
* `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean` — `SameStateAt`, `sameStateAt_congr_left`,
  `stab_state_only`
* `FormalSystem/Semantics/PlusLanguage/PlusNonValidities.lean` — `NF`, `natHist`, `natModel`

## Tags

star-language · state-locality · stability-modal · fragment
-/

namespace FormalSystem.StarLanguage

open FormalSystem.Syntax

/--
**The state-locality fragment of L⋆**, by structural recursion.

`atom`, `bot` and `imp` are the propositional core; `box` and `stab` are admitted for an
arbitrary argument (see `Semantics/StarLanguage/StarStateLocal.lean`'s `isStateLocal_box` and
`isStateLocal_stab`); `timeStore` is admitted recursively, since it does not move the evaluation
time; and `untl`, `snce`, `timeRecall` are excluded, each with a countermodel in that module.

Sufficient, not necessary — see the module docstring's "Sound, not complete".
-/
def StarFormula.StateLocal : StarFormula → Prop
  | .atom _ => True
  | .bot => True
  | .imp φ ψ => StarFormula.StateLocal φ ∧ StarFormula.StateLocal ψ
  | .box _ => True
  | .untl _ _ => False
  | .snce _ _ => False
  | .stab _ => True
  | .timeStore _ φ => StarFormula.StateLocal φ
  | .timeRecall _ _ => False

@[simp] theorem stateLocal_atom (p : Atom) : (StarFormula.atom p).StateLocal := trivial

@[simp] theorem stateLocal_bot : StarFormula.bot.StateLocal := trivial

@[simp] theorem stateLocal_imp_iff (φ ψ : StarFormula) :
    (StarFormula.imp φ ψ).StateLocal ↔ φ.StateLocal ∧ ψ.StateLocal := Iff.rfl

@[simp] theorem stateLocal_box (φ : StarFormula) : (StarFormula.box φ).StateLocal := trivial

@[simp] theorem not_stateLocal_untl (ψ φ : StarFormula) : ¬ (StarFormula.untl ψ φ).StateLocal :=
  id

@[simp] theorem not_stateLocal_snce (ψ φ : StarFormula) : ¬ (StarFormula.snce ψ φ).StateLocal :=
  id

@[simp] theorem stateLocal_stab (φ : StarFormula) : (StarFormula.stab φ).StateLocal := trivial

@[simp] theorem stateLocal_timeStore_iff (i : ℕ) (φ : StarFormula) :
    (StarFormula.timeStore i φ).StateLocal ↔ φ.StateLocal := Iff.rfl

@[simp] theorem not_stateLocal_timeRecall (i : ℕ) (φ : StarFormula) :
    ¬ (StarFormula.timeRecall i φ).StateLocal := id

/-- `F φ` is outside the fragment: it is an `untl`. -/
@[simp] theorem not_stateLocal_someFuture (φ : StarFormula) :
    ¬ (StarFormula.someFuture φ).StateLocal := id

/-- `P φ` is outside the fragment: it is a `snce`. -/
@[simp] theorem not_stateLocal_somePast (φ : StarFormula) :
    ¬ (StarFormula.somePast φ).StateLocal := id

/-- The negation of a state-local formula is state-local: `¬φ` is `φ → ⊥`. -/
theorem StateLocal.neg {φ : StarFormula} (hφ : φ.StateLocal) : φ.neg.StateLocal :=
  ⟨hφ, trivial⟩

/-- Conjunction stays inside the fragment. -/
theorem StateLocal.and {φ ψ : StarFormula} (hφ : φ.StateLocal) (hψ : ψ.StateLocal) :
    (StarFormula.and φ ψ).StateLocal :=
  ⟨⟨hφ, hψ, trivial⟩, trivial⟩

/-- Disjunction stays inside the fragment. -/
theorem StateLocal.or {φ ψ : StarFormula} (hφ : φ.StateLocal) (hψ : ψ.StateLocal) :
    (StarFormula.or φ ψ).StateLocal :=
  ⟨⟨hφ, trivial⟩, hψ⟩

end FormalSystem.StarLanguage

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.StarLanguage

/-! ## The semantic property -/

/--
**State-locality, semantically.** `φ` is state-local when, at every frame and model, any two
possible worlds carrying the same world state at `t` agree about `φ` at `t` — under the *same*
stored-time vector on both sides.

The register vector is quantified inside, not fixed outside, so that the `timeStore` case of
`isStateLocal_of_stateLocal` can instantiate its inductive hypothesis at the updated vector.
-/
def IsStateLocal (φ : StarFormula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ σ : PartialHistory F), τ.IsTotal → σ.IsTotal →
    ∀ (t : F.Duration) (v : ℕ → F.Duration), SameStateAt τ σ t →
      (StarTruthAt M τ t v φ ↔ StarTruthAt M σ t v φ)

/-! ## `□` and `⊡` are state-local for an arbitrary argument -/

/--
**`□φ` is state-local, whatever `φ` is.** The `box` clause quantifies over *every* total history
and never mentions `τ`, so the two sides are literally the same proposition.

This settles, positively, the question of whether `□` belongs in the fragment: it does, and
without a hypothesis on `φ`.
-/
theorem isStateLocal_box (φ : StarFormula) : IsStateLocal (.box φ) :=
  fun _ _ _ _ _ _ _ _ _ => Iff.rfl

/--
**`⊡φ` is state-local, whatever `φ` is.** The `stab` clause quantifies over the histories in
`⟨τ⟩ₜ`, and `sameStateAt_congr_left` says that class is unchanged when `τ` is replaced by any
history carrying the same state at `t`.
-/
theorem isStateLocal_stab (φ : StarFormula) : IsStateLocal (.stab φ) := by
  intro F M τ σ hτ hσ t v h
  have hclass : ∀ ρ : PartialHistory F, SameStateAt τ ρ t ↔ SameStateAt σ ρ t := fun ρ =>
    sameStateAt_congr_left (hτ t) (hσ t) (h (hτ t) (hσ t))
  constructor
  · intro hh ρ hρ hs
    exact hh ρ hρ ((hclass ρ).mpr hs)
  · intro hh ρ hρ hs
    exact hh ρ hρ ((hclass ρ).mp hs)

/-! ## Soundness of the syntactic fragment -/

/--
**The soundness theorem.** Every formula in the syntactic fragment has the semantic property.

Nine cases, one per constructor. `box` and `stab` discharge to the two lemmas above with no
inductive hypothesis; `untl`, `snce` and `timeRecall` are vacuous, the syntactic predicate being
`False` there; `timeStore` uses its inductive hypothesis at the *updated* register vector, which
is why `IsStateLocal` quantifies the vector internally.

Paper: — (the formalization's own: the manuscript has no fragment of L⋆ and no state-locality
predicate, and this result exists to close the reason the sentence-letter form of the
forward-determinism separation gave for its own restriction)
-/
theorem isStateLocal_of_stateLocal : ∀ {φ : StarFormula}, φ.StateLocal → IsStateLocal φ := by
  intro φ
  induction φ with
  | atom p =>
    intro _ _ M τ σ hτ hσ t _ h
    constructor
    · rintro ⟨ht, hv⟩
      refine ⟨hσ t, ?_⟩
      rw [← h ht (hσ t)]
      exact hv
    · rintro ⟨ht, hv⟩
      refine ⟨hτ t, ?_⟩
      rw [h (hτ t) ht]
      exact hv
  | bot => intro _ _ _ _ _ _ _ _ _ _; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
    rintro ⟨hφ, hψ⟩ F M τ σ hτ hσ t v h
    exact imp_congr (ihφ hφ F M τ σ hτ hσ t v h) (ihψ hψ F M τ σ hτ hσ t v h)
  | box φ _ => intro _; exact isStateLocal_box φ
  | untl ψ φ _ _ => intro hφ; exact absurd hφ (not_stateLocal_untl ψ φ)
  | snce ψ φ _ _ => intro hφ; exact absurd hφ (not_stateLocal_snce ψ φ)
  | stab φ _ => intro _; exact isStateLocal_stab φ
  | timeStore i φ ih =>
    intro hφ F M τ σ hτ hσ t v h
    exact ih hφ F M τ σ hτ hσ t (Function.update v i t) h
  | timeRecall i φ _ => intro hφ; exact absurd hφ (not_stateLocal_timeRecall i φ)

/-! ## The excluded constructors are excluded by theorem

Each witness lives on `NF` with `natModel`, and each uses a pair of possible worlds agreeing at
time `0` and disagreeing away from it. All three are stated as negations of `IsStateLocal`, the
semantic property: the *syntactic* predicate is `False` on these constructors by definition, so
its negation would be a vacuous claim. -/

/-- The constant possible world of `NF` at world state `0`. -/
private def zeroHist : PartialHistory NF := natHist (fun _ => 0)

/-- The possible world of `NF` that sits at state `0` up to time `0` and leaves it afterwards. -/
private def lateHist : PartialHistory NF := natHist (fun s => if s ≤ 0 then 0 else 1)

/-- The possible world of `NF` that sits away from state `0` before time `0` and at it after. -/
private def earlyHist : PartialHistory NF := natHist (fun s => if s < 0 then 1 else 0)

private theorem zero_lateHist_same : SameStateAt zeroHist lateHist (0 : ℤ) := by
  intro _ _
  show (0 : ℕ) = (if (0 : ℤ) ≤ 0 then 0 else 1)
  simp

private theorem zero_earlyHist_same : SameStateAt zeroHist earlyHist (0 : ℤ) := by
  intro _ _
  show (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0)
  simp

/--
**`F φ` is not state-local**, already at an atom. `zeroHist` and `lateHist` agree at time `0` and
differ at every later time, and `natModel` makes `p` true exactly at world state `0`: so `F p`
holds at `(zeroHist, 0)` and fails at `(lateHist, 0)`. This is the `untl` exclusion.
-/
theorem not_isStateLocal_someFuture (p : Atom) :
    ¬ IsStateLocal (StarFormula.someFuture (.atom p)) := by
  intro h
  have hleft : StarTruthAt natModel zeroHist (0 : ℤ) (fun _ => 0)
      (StarFormula.someFuture (.atom p)) := by
    rw [StarTruth.someFuture_iff]
    exact ⟨(1 : ℤ), by norm_num, trivial, rfl⟩
  have hright := (h NF natModel zeroHist lateHist (natHist_isTotal _) (natHist_isTotal _)
    (0 : ℤ) (fun _ => 0) zero_lateHist_same).mp hleft
  rw [StarTruth.someFuture_iff] at hright
  obtain ⟨s, hs, _, hval⟩ := hright
  have hval' : (if s ≤ (0 : ℤ) then (0 : ℕ) else 1) = 0 := hval
  rw [if_neg (not_le.mpr hs)] at hval'
  exact one_ne_zero hval'

/--
**`P φ` is not state-local**, already at an atom. `zeroHist` and `earlyHist` agree at time `0` and
differ at every earlier time, so `P p` holds at `(zeroHist, 0)` and fails at `(earlyHist, 0)`.
This is the `snce` exclusion.
-/
theorem not_isStateLocal_somePast (p : Atom) :
    ¬ IsStateLocal (StarFormula.somePast (.atom p)) := by
  intro h
  have hleft : StarTruthAt natModel zeroHist (0 : ℤ) (fun _ => 0)
      (StarFormula.somePast (.atom p)) := by
    rw [StarTruth.somePast_iff]
    exact ⟨(-1 : ℤ), by norm_num, trivial, rfl⟩
  have hright := (h NF natModel zeroHist earlyHist (natHist_isTotal _) (natHist_isTotal _)
    (0 : ℤ) (fun _ => 0) zero_earlyHist_same).mp hleft
  rw [StarTruth.somePast_iff] at hright
  obtain ⟨s, hs, _, hval⟩ := hright
  have hval' : (if s < (0 : ℤ) then (1 : ℕ) else 0) = 0 := hval
  rw [if_pos hs] at hval'
  exact one_ne_zero hval'

/--
**`↓ⁱφ` is not state-local**, already at an atom. The register holds a *future* time, and the two
possible worlds agreeing at the evaluation time `0` are unconstrained there: with register `0`
holding `1`, `↓⁰p` holds at `zeroHist` and fails at `lateHist`. This is the `timeRecall`
exclusion, and it is the reason the clause is `False` unconditionally rather than recursively.
-/
theorem not_isStateLocal_timeRecall (p : Atom) :
    ¬ IsStateLocal (.timeRecall 0 (.atom p)) := by
  intro h
  have hleft : StarTruthAt natModel zeroHist (0 : ℤ) (fun _ => (1 : ℤ))
      (.timeRecall 0 (.atom p)) := by
    rw [StarTruth.timeRecall_iff]
    exact ⟨trivial, rfl⟩
  have hright := (h NF natModel zeroHist lateHist (natHist_isTotal _) (natHist_isTotal _)
    (0 : ℤ) (fun _ => (1 : ℤ)) zero_lateHist_same).mp hleft
  rw [StarTruth.timeRecall_iff] at hright
  obtain ⟨_, hval⟩ := hright
  have hval' : (if (1 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0 := hval
  simp at hval'

/-! ## The headline: a state-local formula is already `⊡`-stable -/

/--
**`φ ↔ ⊡φ` for state-local `φ`**, pointwise.

Left to right is `isStateLocal_of_stateLocal`: every `σ ∈ ⟨τ⟩ₜ` agrees with `τ` about `φ`. Right
to left instantiates the `⊡` clause at `τ` itself, via `SameStateAt.refl` — and that is the only
place the totality of `τ` is used.
-/
theorem stateLocal_stab_iff {F : TaskFrame} {φ : StarFormula} (hφ : φ.StateLocal)
    (M : TaskModel F) (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (v : ℕ → F.Duration) :
    StarTruthAt M τ t v φ ↔ StarTruthAt M τ t v (.stab φ) := by
  constructor
  · intro hh σ hσ hs
    exact (isStateLocal_of_stateLocal hφ F M τ σ hτ hσ t v hs).mp hh
  · intro hh
    exact hh τ hτ (SameStateAt.refl τ t)

/--
**`φ ↔ ⊡φ` for state-local `φ`**, as a validity of L⋆.

The companion facing the other way to `stab_state_only` (`Semantics/PlusLanguage/PlusTruth.lean`): that lemma
says `⊡φ` depends on the world state alone, this one says a formula that already depends on the
world state alone is `⊡`-stable.

Paper: — (the formalization's own: the manuscript states no fragment-level `φ ↔ ⊡φ`, and the
nearest paper-anchored statement is the atom-level `p → ⊡p` of `def:BLstar-semantics`'s footnote,
which this strictly extends)
-/
theorem stateLocal_starValid_iff_stab {φ : StarFormula} (hφ : φ.StateLocal) :
    StarValid (StarFormula.iff φ (.stab φ)) := by
  refine StarValid.of_forall_total ?_
  intro F M τ hτ x v
  have hiff := stateLocal_stab_iff hφ M τ hτ x v
  simp only [StarFormula.iff]
  rw [StarTruth.and_iff, StarTruth.imp_iff, StarTruth.imp_iff]
  exact ⟨hiff.mp, hiff.mpr⟩

end FormalSystem.Semantics
