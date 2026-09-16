/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusNonValidities

/-!
# State-locality: the L⁺ fragment whose truth is fixed by the present world state

`PlusFormula.StateLocal` is a syntactic fragment of L⁺
(`FormalSystem/PlusLanguage/Formula.lean`), and `IsPlusStateLocal` is the semantic property it
approximates: at a fixed time `t`, two possible worlds carrying the *same world state at `t`*
agree about `φ`. That is exactly the class `⊡` quantifies over, so a state-local `φ` is already
`⊡`-stable — the headline `φ ↔ ⊡φ` below.

## Main Definitions

- `PlusFormula.StateLocal` — the syntactic fragment, by structural recursion
- `IsPlusStateLocal` — the semantic property: `SameStateAt τ σ t` transfers truth at `t`

## Main Results

- `isPlusStateLocal_box`, `isPlusStateLocal_stab` — `□` and `⊡` are state-local for an
  **arbitrary** argument, which is why the recursion admits them without a recursive hypothesis
- `isPlusStateLocal_of_stateLocal` — soundness of the syntactic fragment against the semantics
- `not_isPlusStateLocal_someFuture`, `not_isPlusStateLocal_somePast` — the two excluded
  constructors are excluded by *theorem*, not by stipulation
- `plusStateLocal_stab_iff` — the headline, pointwise: `φ ↔ ⊡φ` at every point, for state-local
  `φ`
- `plusStateLocal_plusValid_iff_stab` — the headline as a validity
- `stab_of_stateLocal` — the `→` half in argument shape, and the strict generalization of the
  atom-level `p → ⊡p` this tower used to carry

## Which constructors are state-local, and why

Read off `PlusTruthAt` (`Semantics/PlusLanguage/PlusTruth.lean`) clause by clause, at the **same** evaluation
time on both sides:

| Constructor | State-local? | Why |
|---|---|---|
| `atom p` | yes | `M.valuation (τ.states t ht) p` reads the state at `t` and nothing else |
| `bot` | yes | constant |
| `imp φ ψ` | yes if both are | pointwise |
| `box φ` | yes, for arbitrary `φ` | `∀ σ, σ.IsTotal → …` does not mention `τ` at all |
| `stab φ` | yes, for arbitrary `φ` | the class `⟨τ⟩ₜ` is unchanged by replacing `τ` with any history agreeing at `t` (`stab_congr_sameState`) |
| `untl ψ φ` | no | quantifies over `s > t`, where the two histories may diverge |
| `snce ψ φ` | no | quantifies over `s < t`, likewise |

`box` and `stab` are the two entries a reader is most likely to expect a recursive hypothesis on.
They do not need one: `isPlusStateLocal_box` and `isPlusStateLocal_stab` are proved for an
arbitrary argument, so the fragment is strictly larger than a naive "every subformula is
state-local" reading would give. Both were settled here **by proof**, not by analogy with the L⋆
twin.

## Sound, not complete

`PlusFormula.StateLocal` is a **sufficient** syntactic condition, not a characterization. For
instance `Fp → Fp` is semantically state-local — it is a tautology, so both sides of the
biconditional hold at every point — yet it is syntactically rejected, because `imp` recurses into
two `untl`s and the `untl` clause is `False` unconditionally. Recorded here so the gap reads as a
design choice: the fragment is the one the consumers need, kept small enough that its soundness
proof is a seven-case induction with no side conditions.

The gap runs the other way too, and in the fragment's favour: `⊡Fp` *is* accepted, even though
its subformula `Fp` is not, because the `stab` arm is `True` at an arbitrary argument. Acceptance
turns on the outermost constructor, not on the whole subformula tree.

## The two exclusions live on one frame

`not_isPlusStateLocal_someFuture` and `not_isPlusStateLocal_somePast` are both witnessed on the
permissive frame `NF` over `ℤ` (`Semantics/PlusLanguage/PlusNonValidities.lean`), where every function `ℤ → ℕ`
is a possible world and `natModel` makes each atom true at world state `0` and nowhere else. No
second countermodel frame is built: two possible worlds agreeing at `0` and disagreeing away from
`0` refute both.

L⁺ has no time registers, so the L⋆ module's third exclusion — `not_isStateLocal_timeRecall` —
has no counterpart here. Two exclusions are all the seven-constructor recursion needs.

## How this fragment relates to the other two shapes of the concept

State-locality had, before this module, three incompatible presentations across the tower. Here
is how each relates to `PlusFormula.StateLocal`, so the tower is systematic rather than merely
parallel.

**1. To the L⋆ fragment, along `ofPlus`.** `stateLocal_ofPlus_iff`
(`Semantics/StateLocalTransfer.lean`) proves `(ofPlus φ).StateLocal ↔ φ.StateLocal` — a
**biconditional**, not merely preservation. `ofPlus` maps the seven L⁺ constructors onto the
seven matching L⋆ ones and the two recursions assign each of them the same arm, so the L⁺
fragment is exactly the `ofPlus`-preimage of the L⋆ fragment. The two L⋆ constructors that have
no L⁺ source, `timeStore` (admitted recursively) and `timeRecall` (excluded), are precisely the
difference between the nine-arm and seven-arm recursions. The transfer lives in its own module,
not here: `Metalogic/Conservativity/Plus/AxiomValidity.lean` imports this one, and an L⋆ import
here would invert the L → L⁺ → L⋆ layering.

**2. To `stab_state_only` (`Semantics/PlusLanguage/PlusTruth.lean`).** That lemma is a **different-times**
statement: `τ(t) = σ(s)` transfers `⊡φ` from `(τ, t)` to `(σ, s)`, which is what the atomization
route (`Metalogic/Conservativity/Plus/Atomization.lean`) consumes. This module's `stab` arm,
`isPlusStateLocal_stab`, is its **same-time shadow**: one `t` on both sides. The two are related
by `plusTruthAt_timeShift`, and share a common core — `stab_congr_sameState`, which
`stab_state_only` is proved from and which `isPlusStateLocal_stab` is literally an instance of.
The different-times shape does **not** generalize to this fragment: `box φ` at `t` and at `s` can
differ. So the two face opposite ways: `stab_state_only` says `⊡φ` is state-local, this module
says a state-local `φ` is already `⊡`-stable.

**3. To `c_stab_state_only` (`Metalogic/Independence/CoarsenedModels.lean`).** That is the
**coarsened port** of (2), and it is the one relation that is *not* covered by anything here.
`CTruthAt` differs from `PlusTruthAt` in the `stab` clause alone: it quantifies over `SameUnder K`
(agreement of the states' `π`-images) rather than over `SameStateAt` (agreement of the states
themselves), which is strictly weaker. `IsPlusStateLocal` transfers truth along state equality
only, so no instantiation of the results here produces a `CTruthAt` goal, and the coarsened `atom`
case rests on `CoarseModel.atom_inv` — a field of the coarsened model that this fragment has no
access to. A coarsened twin of `isPlusStateLocal_of_stateLocal` is provable (its `atom` arm from
`atom_inv`, its `stab` arm from `c_stab_congr_sameUnder`, its `box` arm from the history-free
clause), but it is a second induction rather than a consequence of this one, and it is not built
here.

## References

* JPL paper `def:BLstar-semantics` — the truth clauses being classified; the atom-level
  `p → ⊡p` of its footnote (line 1119) is the `stateLocal_atom` instance of `stab_of_stateLocal`
* `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean` — `PlusTruthAt`, `SameStateAt`, `stab_congr_sameState`,
  `stab_state_only`
* `FormalSystem/Semantics/StarLanguage/StarStateLocal.lean` — the L⋆ twin this module mirrors arm for arm
* `FormalSystem/Semantics/StateLocalTransfer.lean` — `stateLocal_ofPlus_iff`
* `FormalSystem/Semantics/PlusLanguage/PlusNonValidities.lean` — `NF`, `natHist`, `natModel`

## Tags

plus-language · state-locality · stability-modal · fragment
-/
namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax

/--
**The state-locality fragment of L⁺**, by structural recursion.

`atom`, `bot` and `imp` are the propositional core; `box` and `stab` are admitted for an
arbitrary argument (see `Semantics/PlusLanguage/PlusStateLocal.lean`'s `isPlusStateLocal_box` and
`isPlusStateLocal_stab`); and `untl`, `snce` are excluded, each with a countermodel in that
module.

Sufficient, not necessary — see the module docstring's "Sound, not complete".
-/
def PlusFormula.StateLocal : PlusFormula → Prop
  | .atom _ => True
  | .bot => True
  | .imp φ ψ => PlusFormula.StateLocal φ ∧ PlusFormula.StateLocal ψ
  | .box _ => True
  | .untl _ _ => False
  | .snce _ _ => False
  | .stab _ => True

/-- Atoms are state-local: an atom reads the world state at the evaluation time and nothing
else. -/
@[simp] theorem stateLocal_atom (p : Atom) : (PlusFormula.atom p).StateLocal := trivial

/-- `⊥` is state-local: it is constant. -/
@[simp] theorem stateLocal_bot : PlusFormula.bot.StateLocal := trivial

/-- `φ → ψ` is state-local exactly when both sides are: the clause is pointwise. -/
@[simp] theorem stateLocal_imp_iff (φ ψ : PlusFormula) :
    (PlusFormula.imp φ ψ).StateLocal ↔ φ.StateLocal ∧ ψ.StateLocal := Iff.rfl

/-- `□φ` is state-local for an **arbitrary** `φ`: the `box` clause never mentions the history. -/
@[simp] theorem stateLocal_box (φ : PlusFormula) : (PlusFormula.box φ).StateLocal := trivial

/-- `φ U ψ` is outside the fragment: it quantifies over later times, where two worlds agreeing
at `t` may diverge. -/
@[simp] theorem not_stateLocal_untl (ψ φ : PlusFormula) : ¬ (PlusFormula.untl ψ φ).StateLocal :=
  id

/-- `φ S ψ` is outside the fragment: it quantifies over earlier times, likewise. -/
@[simp] theorem not_stateLocal_snce (ψ φ : PlusFormula) : ¬ (PlusFormula.snce ψ φ).StateLocal :=
  id

/-- `⊡φ` is state-local for an **arbitrary** `φ`: the class `⟨τ⟩ₜ` is fixed by the state at
`t`. -/
@[simp] theorem stateLocal_stab (φ : PlusFormula) : (PlusFormula.stab φ).StateLocal := trivial

/-- `F φ` is outside the fragment: it is an `untl`. -/
@[simp] theorem not_stateLocal_someFuture (φ : PlusFormula) :
    ¬ (PlusFormula.someFuture φ).StateLocal := id

/-- `P φ` is outside the fragment: it is a `snce`. -/
@[simp] theorem not_stateLocal_somePast (φ : PlusFormula) :
    ¬ (PlusFormula.somePast φ).StateLocal := id

/-- The negation of a state-local formula is state-local: `¬φ` is `φ → ⊥`. -/
theorem StateLocal.neg {φ : PlusFormula} (hφ : φ.StateLocal) : φ.neg.StateLocal :=
  ⟨hφ, trivial⟩

/-- Conjunction stays inside the fragment. -/
theorem StateLocal.and {φ ψ : PlusFormula} (hφ : φ.StateLocal) (hψ : ψ.StateLocal) :
    (PlusFormula.and φ ψ).StateLocal :=
  ⟨⟨hφ, hψ, trivial⟩, trivial⟩

/-- Disjunction stays inside the fragment. -/
theorem StateLocal.or {φ ψ : PlusFormula} (hφ : φ.StateLocal) (hψ : ψ.StateLocal) :
    (PlusFormula.or φ ψ).StateLocal :=
  ⟨⟨hφ, trivial⟩, hψ⟩

end FormalSystem.PlusLanguage

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage

/-! ## The semantic property -/

/--
**State-locality, semantically.** `φ` is state-local when, at every frame and model, any two
possible worlds carrying the same world state at `t` agree about `φ` at `t`.

L⁺ has no time registers, so this is `IsStateLocal` (`Semantics/StarLanguage/StarStateLocal.lean`) with the
stored-time vector deleted and nothing else changed; the two are arm-for-arm comparable.

The hypotheses could be weakened from `τ.IsTotal`/`σ.IsTotal` to `τ.domain t`/`σ.domain t` —
every proof below uses totality only at `t`, except `plusStateLocal_stab_iff`'s right-to-left
half, which needs `τ ∈ ⟨τ⟩ₜ` and therefore genuinely needs `τ` total. The stronger hypotheses
are kept deliberately, so that this definition and `IsStateLocal` differ in exactly one respect
(the register vector) rather than two.
-/
def IsPlusStateLocal (φ : PlusFormula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ σ : ConvexHistory F), τ.IsTotal → σ.IsTotal →
    ∀ t : F.Duration, SameStateAt τ σ t →
      (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)

/-! ## `□` and `⊡` are state-local for an arbitrary argument -/

/--
**`□φ` is state-local, whatever `φ` is.** The `box` clause quantifies over *every* total history
and never mentions `τ`, so the two sides are literally the same proposition.

This settles, positively and by proof rather than by analogy with L⋆, the question of whether
`□` belongs in the fragment: it does, and without a hypothesis on `φ`.

Paper: — (the formalization's own: the manuscript classifies no L⁺ constructor for
state-locality)
-/
theorem isPlusStateLocal_box (φ : PlusFormula) : IsPlusStateLocal (.box φ) :=
  fun _ _ _ _ _ _ _ _ => Iff.rfl

/--
**`⊡φ` is state-local, whatever `φ` is.** Discharged from `stab_congr_sameState`
(`Semantics/PlusLanguage/PlusTruth.lean`), which is exactly this statement at domain hypotheses rather than
totality: the truth of `⊡φ` at `(τ, t)` depends only on the `∼ₜ`-class of `τ`.

That proof dependency is the first of the three relations this module records: the L⁺ fragment's
`stab` arm *is* `stab_congr_sameState`, not a re-derivation of it.

Paper: — (the formalization's own; the underlying clause is `def:BLstar-semantics`)
-/
theorem isPlusStateLocal_stab (φ : PlusFormula) : IsPlusStateLocal (.stab φ) :=
  fun _ M τ σ hτ hσ t h => stab_congr_sameState M τ σ t (hτ t) (hσ t) h φ

/-! ## Soundness of the syntactic fragment -/

/--
**The soundness theorem.** Every formula in the syntactic fragment has the semantic property.

Seven cases, one per constructor. `box` and `stab` discharge to the two lemmas above with no
inductive hypothesis; `untl` and `snce` are vacuous, the syntactic predicate being `False`
there.

Paper: — (the formalization's own: the manuscript has no fragment of L⁺ and no state-locality
predicate; this is the L⁺ twin of `isStateLocal_of_stateLocal`)
-/
theorem isPlusStateLocal_of_stateLocal :
    ∀ {φ : PlusFormula}, φ.StateLocal → IsPlusStateLocal φ := by
  intro φ
  induction φ with
  | atom p =>
    intro _ _ M τ σ hτ hσ t h
    constructor
    · rintro ⟨ht, hv⟩
      refine ⟨hσ t, ?_⟩
      rw [← h ht (hσ t)]
      exact hv
    · rintro ⟨ht, hv⟩
      refine ⟨hτ t, ?_⟩
      rw [h (hτ t) ht]
      exact hv
  | bot => intro _ _ _ _ _ _ _ _ _; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
    rintro ⟨hφ, hψ⟩ F M τ σ hτ hσ t h
    exact imp_congr (ihφ hφ F M τ σ hτ hσ t h) (ihψ hψ F M τ σ hτ hσ t h)
  | box φ _ => intro _; exact isPlusStateLocal_box φ
  | untl ψ φ _ _ => intro hφ; exact absurd hφ (not_stateLocal_untl ψ φ)
  | snce ψ φ _ _ => intro hφ; exact absurd hφ (not_stateLocal_snce ψ φ)
  | stab φ _ => intro _; exact isPlusStateLocal_stab φ

/-! ## The excluded constructors are excluded by theorem

Each witness lives on `NF` with `natModel` (`Semantics/PlusLanguage/PlusNonValidities.lean`), and each uses a
pair of possible worlds agreeing at time `0` and disagreeing away from it. Both are stated as
negations of `IsPlusStateLocal`, the semantic property: the *syntactic* predicate is `False` on
these constructors by definition, so its negation would be a vacuous claim.

L⁺ has no time registers, so the L⋆ module's third exclusion — `not_isStateLocal_timeRecall` —
does not arise here. Two exclusions are all the seven-constructor recursion needs. -/

/-- The constant possible world of `NF` at world state `0`. -/
private def zeroHist : ConvexHistory NF := natHist (fun _ => 0)

/-- The possible world of `NF` that sits at state `0` up to time `0` and leaves it afterwards. -/
private def lateHist : ConvexHistory NF := natHist (fun s => if s ≤ 0 then 0 else 1)

/-- The possible world of `NF` that sits away from state `0` before time `0` and at it after. -/
private def earlyHist : ConvexHistory NF := natHist (fun s => if s < 0 then 1 else 0)

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

Paper: — (the formalization's own; `untl`'s clause is `def:BLstar-semantics`)
-/
theorem not_isPlusStateLocal_someFuture (p : Atom) :
    ¬ IsPlusStateLocal (PlusFormula.someFuture (.atom p)) := by
  intro h
  have hleft : PlusTruthAt natModel zeroHist (0 : ℤ) (PlusFormula.someFuture (.atom p)) := by
    rw [PlusTruth.someFuture_iff]
    exact ⟨(1 : ℤ), by norm_num, trivial, rfl⟩
  have hright := (h NF natModel zeroHist lateHist (natHist_isTotal _) (natHist_isTotal _)
    (0 : ℤ) zero_lateHist_same).mp hleft
  rw [PlusTruth.someFuture_iff] at hright
  obtain ⟨s, hs, _, hval⟩ := hright
  have hval' : (if s ≤ (0 : ℤ) then (0 : ℕ) else 1) = 0 := hval
  rw [if_neg (not_le.mpr hs)] at hval'
  exact one_ne_zero hval'

/--
**`P φ` is not state-local**, already at an atom. `zeroHist` and `earlyHist` agree at time `0` and
differ at every earlier time, so `P p` holds at `(zeroHist, 0)` and fails at `(earlyHist, 0)`.
This is the `snce` exclusion.

Paper: — (the formalization's own; `snce`'s clause is `def:BLstar-semantics`)
-/
theorem not_isPlusStateLocal_somePast (p : Atom) :
    ¬ IsPlusStateLocal (PlusFormula.somePast (.atom p)) := by
  intro h
  have hleft : PlusTruthAt natModel zeroHist (0 : ℤ) (PlusFormula.somePast (.atom p)) := by
    rw [PlusTruth.somePast_iff]
    exact ⟨(-1 : ℤ), by norm_num, trivial, rfl⟩
  have hright := (h NF natModel zeroHist earlyHist (natHist_isTotal _) (natHist_isTotal _)
    (0 : ℤ) zero_earlyHist_same).mp hleft
  rw [PlusTruth.somePast_iff] at hright
  obtain ⟨s, hs, _, hval⟩ := hright
  have hval' : (if s < (0 : ℤ) then (1 : ℕ) else 0) = 0 := hval
  rw [if_pos hs] at hval'
  exact one_ne_zero hval'

/-! ## The headline: a state-local formula is already `⊡`-stable -/

/--
**`φ ↔ ⊡φ` for state-local `φ`**, pointwise.

Left to right is `isPlusStateLocal_of_stateLocal`: every `σ ∈ ⟨τ⟩ₜ` agrees with `τ` about `φ`.
Right to left instantiates the `⊡` clause at `τ` itself, via `SameStateAt.refl` — and that is the
only place the totality of `τ` is used.

Paper: — (the formalization's own; the nearest paper-anchored statement is the atom-level
`p → ⊡p` of `def:BLstar-semantics`'s footnote, line 1119, which this strictly extends)
-/
theorem plusStateLocal_stab_iff {F : TaskFrame} {φ : PlusFormula} (hφ : φ.StateLocal)
    (M : TaskModel F) (τ : ConvexHistory F) (hτ : τ.IsTotal) (t : F.Duration) :
    PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t (.stab φ) := by
  constructor
  · intro hh σ hσ hs
    exact (isPlusStateLocal_of_stateLocal hφ F M τ σ hτ hσ t hs).mp hh
  · intro hh
    exact hh τ hτ (SameStateAt.refl τ t)

/--
**`φ ↔ ⊡φ` for state-local `φ`**, as a validity of L⁺.

The companion facing the other way to `stab_state_only` (`Semantics/PlusLanguage/PlusTruth.lean`): that lemma
says `⊡φ` depends on the world state alone, this one says a formula that already depends on the
world state alone is `⊡`-stable.

Paper: — (the formalization's own: the manuscript states no fragment-level `φ ↔ ⊡φ` for L⁺; the
nearest paper-anchored statement is the atom-level `p → ⊡p` of line 1119, which this strictly
extends)
-/
theorem plusStateLocal_plusValid_iff_stab {φ : PlusFormula} (hφ : φ.StateLocal) :
    PlusValid (PlusFormula.iff φ (.stab φ)) := by
  refine PlusValid.of_forall_total ?_
  intro F M τ hτ x
  have hiff := plusStateLocal_stab_iff hφ M τ hτ x
  simp only [PlusFormula.iff]
  rw [PlusTruth.and_iff, PlusTruth.imp_iff, PlusTruth.imp_iff]
  exact ⟨hiff.mp, hiff.mpr⟩

/--
**`φ → ⊡φ` for state-local `φ`**, in the pointwise argument shape the consumers use.

This is the **strict generalization** of the atom-level stability lemma the L⁺ tower used to
carry: that lemma was `p → ⊡p` at an atom `p`, and this is `φ → ⊡φ` at every formula the
seven-constructor recursion admits — every Boolean combination of atoms, `□`-formulas and
`⊡`-formulas, at arbitrary arguments under the two modals. `stateLocal_atom p` recovers the atom
instance in one application, which is how `Metalogic/Conservativity/Plus/AxiomValidity.lean`
discharges the `PlusAxiom.atom_stab` arm.

The one hypothesis the atom-restricted statement did not carry is `hτ`: totality is needed for
the right-to-left half of `plusStateLocal_stab_iff` and hence, harmlessly, here. Both consumers
sit inside `PlusValidIn.of_forall_total`, which already binds it.

Paper: — (the formalization's own; the atom instance is the footnote at line 1119)
-/
theorem stab_of_stateLocal {F : TaskFrame} {φ : PlusFormula} (hφ : φ.StateLocal)
    (M : TaskModel F) (τ : ConvexHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (h : PlusTruthAt M τ t φ) : PlusTruthAt M τ t (.stab φ) :=
  (plusStateLocal_stab_iff hφ M τ hτ t).mp h

end FormalSystem.Semantics
