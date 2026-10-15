/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.NomicLanguage.NomicTruth

/-!
# `prop:nomic-tense-free` — the state-set bridge and the S5 schemata on the fragment

Over **every** nomic frame, the nomic operator and the box agree on the tense-free fragment — the
sentences built from atoms, falsum, implication, the box and the nomic operator alone. The paper
proves it by assigning each tense-free `φ` a **state set** `S_φ ⊆ W` with `M,τ,x ⊨ φ` iff
`τ(x) ∈ S_φ`, and observing that the box and nomic clauses produce the *same* set, since
`cor:occurrence` and `lem:nomic-occurrence` both say every world state is occupied at every time.

Every **S5** schema for the nomic operator is therefore valid on the fragment, and any refutation
— such as `app:nomic-four`'s refutation of **4** — must use the until or since operators.

## The one genuine surprise worth recording

**T holds on the tense-free fragment over every nomic frame, including the non-*Lawful* ones.**
The paper's remark that *Nomologically lawful* validates **T** for the nomic operator is about the
**full** language; on the fragment T is free, because the collapse has already degenerated the
nomic operator into the box. This is `prop:nomic-tense-free`'s closing sentence ("any refutation
must use the stability or the until/since operators") read for T rather than for 4, and it is a
consistency check against `prop:nomic-hierarchy`'s first witness, which is *Static* but not
*Lawful*.

## Two shape decisions, both forced, both copied from `lem:state-set`

**The ignoring-set clause.** `nomicSatSet`'s box clause is `{_w | ∀ v, v ∈ nomicSatSet V φ}`, the
form `FormalSystem/Metalogic/Independence/StateSetTruth.lean` uses and whose rationale that module
records: the paper's displayed `if S_φ = W then W else ∅` would have to *decide* a set equality,
pulling `Classical.choice` into the **definition**. The nomic clause is given the **same** form,
which is exactly what makes `S_{◈φ} = S_{□φ}` hold by `rfl` and the fragment collapse a two-line
consequence of the bridge.

**A total recursion with a restricted theorem.** `TenseFree` is `Prop`-valued, so it cannot be
recursed into `Set F.World` — `Prop` has no large elimination. The recursion is therefore **total**
on the full formula type, with `∅` at the two temporal clauses, and the bridge theorem carries
`TenseFree φ` as a hypothesis, discharging those cases by `cases h`. This is a documented
partial-function convention on a total recursion, not a vacuous definition: the two `∅` clauses
are unreachable in every theorem below, and no clause of the form `:= True`/`Unit`/`trivial`
appears anywhere.

Unlike `satSet`, this recursion takes **no** `[LinearOrder F.World]` binder: `satSet` needs the
order only for its `untl`/`snce` clauses, and the tense-free fragment has none.

## Main Definitions

- `TenseFree` — `prop:nomic-tense-free`'s fragment: atoms, falsum, implication, box, nomic
- `nomicSatSet` — the state set of a formula, total on the full type

## Main Results

- `tenseFree_satSet_iff` — the bridge, for an **arbitrary** bare `τ`
- `nomic_iff_box_tenseFree` — the fragment collapse, over every nomic frame
- `nomic_k_tenseFree`, `nomic_t_tenseFree`, `nomic_four_tenseFree`, `nomic_five_tenseFree`,
  `nomic_b_tenseFree` — the five **S5** schemata on the fragment

## A formalization-native strengthening

The paper states `prop:nomic-tense-free` for `τ ∈ H_F`. The Lean statement holds for an
**arbitrary** bare `τ : ↑D → F.World`, with no membership hypothesis, because the box and nomic
clauses quantify over `H_F` and `H_F^{τ(x)}` and the atom clause reads only `τ x`. Strictly
stronger than the paper's claim, free in the proof, and recorded rather than silently taken.

## Choice dependence, recorded honestly

The bridge and every schema below reach `NomicFrame.occurrence`, so each is a theorem of **ZFC**,
not of ZF: `lem:nomic-occurrence` runs through `thm:extension`, whose proof appeals to Zorn's
lemma. `rmk:choice` does not list these among the paper's choice-free results.

## References

* JPL paper `prop:nomic-tense-free` — the proposition formalized here
* JPL paper `lem:state-set`, `def:state-set` — the state-set induction this one parallels
* JPL paper `lem:nomic-occurrence`, `cor:occurrence` — the two occurrence inputs
* JPL paper `rmk:choice` — the choice record
* `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — `satSet` and the ignoring-set clause

## Tags

nomic-language · state-set · tense-free · S5
-/

namespace FormalSystem.NomicLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {D : TemporalOrder}

/-! ## The fragment and its state-set recursion -/

/--
`prop:nomic-tense-free`'s fragment: the sentences built from atoms, falsum, implication, the box
and the nomic operator alone — "tense-free", in the paper's sense of using neither until nor
since.

The stability modal is not a constructor of `NomicFormula` at all; see
`FormalSystem/NomicLanguage/README.md` for why it is excluded.
-/
inductive TenseFree : NomicFormula → Prop where
  /-- Every atom is tense-free. -/
  | atom (p : Atom) : TenseFree (.atom p)
  /-- Falsum is tense-free. -/
  | bot : TenseFree .bot
  /-- An implication of tense-free sentences is tense-free. -/
  | imp {φ ψ} : TenseFree φ → TenseFree ψ → TenseFree (.imp φ ψ)
  /-- The box of a tense-free sentence is tense-free. -/
  | box {φ} : TenseFree φ → TenseFree (.box φ)
  /-- The nomic necessitation of a tense-free sentence is tense-free. -/
  | nomic {φ} : TenseFree φ → TenseFree (.nomic φ)

/--
The state set of a formula, as in `def:state-set` but over the states of a nomic frame.

Total on the full formula type: the two temporal clauses get `∅`, a documented partial-function
convention (see this module's docstring), since a `Prop`-valued `TenseFree` cannot be recursed
into `Set F.World`. The box and nomic clauses share **one** ignoring-set form, which is what makes
`S_{◈φ} = S_{□φ}` hold by `rfl`.
-/
def nomicSatSet {F : NomicFrame D} (V : F.World → Atom → Prop) :
    NomicFormula → Set F.World
  | .atom p => {w | V w p}
  | .bot => ∅
  | .imp φ ψ => {w | w ∈ nomicSatSet V φ → w ∈ nomicSatSet V ψ}
  | .box φ => {_w | ∀ v : F.World, v ∈ nomicSatSet V φ}
  | .untl _ _ => ∅
  | .snce _ _ => ∅
  | .nomic φ => {_w | ∀ v : F.World, v ∈ nomicSatSet V φ}

/-- The identity the fragment collapse rests on: the box and the nomic operator are assigned the
same state set, by `rfl`. -/
example {F : NomicFrame D} (V : F.World → Atom → Prop) (φ : NomicFormula) :
    nomicSatSet V (.nomic φ) = nomicSatSet V (.box φ) := rfl

/-! ## The bridge -/

/--
`prop:nomic-tense-free`'s bridge: on the tense-free fragment, truth at `(τ, x)` is membership of
the occupied state `τ x` in the formula's state set.

Both the box and the nomic case run the same argument: `lem:nomic-occurrence` produces, for an
arbitrary target state `v`, a law-history at `τ x` occupying `v` at `x`; the box case additionally
lifts that law-history into `H_F`. The two temporal cases are discharged by `cases h`, since
`TenseFree` has no constructor at those shapes.

Stated for an **arbitrary** bare `τ`, with no `τ ∈ H_F` hypothesis — strictly stronger than the
paper's statement; see this module's docstring.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem tenseFree_satSet_iff {F : NomicFrame D} [F.IsRegular] (M : NomicModel F) :
    ∀ φ : NomicFormula, TenseFree φ → ∀ (τ : ↑D → F.World) (x : ↑D),
      NomicTruthAt M τ x φ ↔ τ x ∈ nomicSatSet M.valuation φ := by
  intro φ
  induction φ with
  | atom p => intro _ _ _; exact Iff.rfl
  | bot => intro _ _ _; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
    intro h τ x
    cases h with
    | imp hφ hψ =>
      simp only [NomicTruthAt, nomicSatSet, Set.mem_setOf_eq]
      rw [ihφ hφ τ x, ihψ hψ τ x]
  | box φ ih =>
    intro h τ x
    cases h with
    | box hφ =>
      simp only [NomicTruthAt, nomicSatSet, Set.mem_setOf_eq]
      constructor
      · intro hb v
        obtain ⟨σ, hσ, hσx⟩ := F.occurrence (τ x) v x
        have hmem := (ih hφ σ x).mp (hb σ (F.lawHist_subset_HF _ hσ))
        rwa [hσx] at hmem
      · intro hs σ _
        exact (ih hφ σ x).mpr (hs (σ x))
  | untl _ _ _ _ => intro h _ _; cases h
  | snce _ _ _ _ => intro h _ _; cases h
  | nomic φ ih =>
    intro h τ x
    cases h with
    | nomic hφ =>
      simp only [NomicTruthAt, nomicSatSet, Set.mem_setOf_eq]
      constructor
      · intro hb v
        obtain ⟨σ, hσ, hσx⟩ := F.occurrence (τ x) v x
        have hmem := (ih hφ σ x).mp (hb σ hσ)
        rwa [hσx] at hmem
      · intro hs σ _
        exact (ih hφ σ x).mpr (hs (σ x))

/--
`prop:nomic-tense-free`: the nomic operator and the box agree on the tense-free fragment, over
**every** nomic frame — no uniformity hypothesis at all.

Two lines from the bridge, since `nomicSatSet V (.nomic φ)` and `nomicSatSet V (.box φ)` are the
same set by `rfl`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_iff_box_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.nomic φ) ↔ NomicTruthAt M τ x (.box φ) :=
  (tenseFree_satSet_iff M _ (TenseFree.nomic hφ) τ x).trans
    (tenseFree_satSet_iff M _ (TenseFree.box hφ) τ x).symm

/-! ## The five S5 schemata on the fragment

Each is the state-set bridge read at the relevant compound: on the fragment, `◈ψ` says that the
state set of `ψ` is everything, a claim that does not mention the point of evaluation at all.
That is what makes each schema immediate — and what makes **T** hold over every nomic frame, not
only the *Lawful* ones. -/

/--
**K** for the nomic operator on the fragment.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_k_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ ψ : NomicFormula} (hφ : TenseFree φ) (hψ : TenseFree ψ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp (.nomic (.imp φ ψ)) (.imp (.nomic φ) (.nomic ψ))) := by
  intro himp hφx
  have h1 := (tenseFree_satSet_iff M _ (TenseFree.nomic (TenseFree.imp hφ hψ)) τ x).mp himp
  have h2 := (tenseFree_satSet_iff M _ (TenseFree.nomic hφ) τ x).mp hφx
  refine (tenseFree_satSet_iff M _ (TenseFree.nomic hψ) τ x).mpr ?_
  intro v
  exact h1 v (h2 v)

/--
**T** for the nomic operator on the fragment, over **every** nomic frame — including the
non-*Lawful* ones, since the fragment collapse has already degenerated the operator into the box.
The paper's remark that *Nomologically lawful* validates T for the nomic operator is about the
full language; see this module's docstring.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_t_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp (.nomic φ) φ) := by
  intro h
  have h' := (tenseFree_satSet_iff M _ (TenseFree.nomic hφ) τ x).mp h
  exact (tenseFree_satSet_iff M _ hφ τ x).mpr (h' (τ x))

/--
**4** for the nomic operator on the fragment. `app:nomic-four` shows that the hypothesis
`TenseFree φ` cannot be dropped: over ℤ-time the schema is valid on the full language exactly on
the Uniform frames.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_four_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp (.nomic φ) (.nomic (.nomic φ))) := by
  intro h
  have h' := (tenseFree_satSet_iff M _ (TenseFree.nomic hφ) τ x).mp h
  refine (tenseFree_satSet_iff M _ (TenseFree.nomic (TenseFree.nomic hφ)) τ x).mpr ?_
  intro _
  exact h'

/--
**5** for the nomic operator on the fragment.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_five_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp (.imp (.nomic φ) .bot)
      (.nomic (.imp (.nomic φ) .bot))) := by
  intro h
  refine (tenseFree_satSet_iff M _
    (TenseFree.nomic (TenseFree.imp (TenseFree.nomic hφ) TenseFree.bot)) τ x).mpr ?_
  intro v hv
  exact h ((tenseFree_satSet_iff M _ (TenseFree.nomic hφ) τ x).mpr (fun u => hv u))

/--
**B** for the nomic operator on the fragment.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_b_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp φ (.nomic (.imp (.nomic (.imp φ .bot)) .bot))) := by
  intro h
  have hx := (tenseFree_satSet_iff M _ hφ τ x).mp h
  refine (tenseFree_satSet_iff M _
    (TenseFree.nomic (TenseFree.imp (TenseFree.nomic (TenseFree.imp hφ TenseFree.bot))
      TenseFree.bot)) τ x).mpr ?_
  intro _ hv
  exact hv (τ x) hx

end FormalSystem.NomicLanguage
