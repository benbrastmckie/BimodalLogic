/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusNonValidities
import FormalSystem.Semantics.PlusDeterminism
import FormalSystem.Metalogic.Algebraic.FlowFrame

/-!
# The stability modal is not L-definable

`stabNotDefinable`: **no** `Formula` of L is equivalent to the `PlusFormula` `⊡Fp` across all task
models. This is the result that answers "why is L⁺ a separate language at all" — `⊡` is not
shorthand for anything L can already say.

## The two models

Both live over `ℤ`, both realize **exactly the same atom profiles** along their total histories,
and they differ only in *which* histories share a world state at a given time.

| | frame | total histories | `⟨τ⟩₀` |
|---|---|---|---|
| `M₁` | `NF`, the permissive frame (`Semantics/TaskFrame.lean`, `natFrame`) | every `f : ℤ → ℕ` | every history agreeing with `τ` at `0` |
| `M₂` | `multiFamTaskFrameGen`, the deterministic clock at family index `ℤ → ℕ` | the flow lines `t ↦ (g, w₀ + t)` | `{τ}` |

The separating point is `(τ₁, 0)` against `(τ₂, 0)`, where both histories carry the profile
"`p` at time `1` and nowhere else":

* `Fp` holds at both — witness `t = 1`.
* `⊡Fp` **fails** at `(τ₁, 0)`: the constant history shares `τ₁`'s state at `0` and never
  reaches `p`.
* `⊡Fp` **holds** at `(τ₂, 0)`: `M₂`'s frame is deterministic, so `⊡` collapses onto its argument
  (`stab_iff_of_deterministic`, `Semantics/PlusDeterminism.lean`) and `Fp` holds.

## The invariance notion is the tree's own `TruthCorr`

No new bisimulation machinery is introduced. `TruthCorr` (`Semantics/TruthTransport.lean`) already
packages exactly what an L formula can see — an order isomorphism of times, a relation on
histories, agreement on atoms at related pairs, and the two `□`-existence conditions — and
`truthAt_of_truthCorr` transports every `Formula` along it. Here the relation is simply
"agrees on every atom at every time", so the `atom` field is definitional and the two totality
fields are the profile-matching constructions above.

## Why the separator has to be temporal

An *atomic* separator is impossible: `p → ⊡p` is valid on every frame (the `stateLocal_atom`
instance of `stab_of_stateLocal`, `Semantics/PlusStateLocal.lean`, the AS axiom), because an
atom's truth depends on the world state alone — which is exactly what `⊡` quantifies over. So `⊡p ↔ p` everywhere and no atom can
witness anything. `Fp` is the least temporal formula that can, which is why the statement is
about `⊡Fp` and not about `⊡` at an arbitrary argument.

Note also that `□Fp` fails at **both** points (`box_someFuture_false_left`,
`box_someFuture_false_right`): the separation is not one `□` could have made either, which is the
point — `⊡` sits strictly between the identity and `□`.

## References

* JPL paper `def:BLstar-semantics` — the `⊡` clause whose expressive strength this bounds below
* `FormalSystem/Semantics/PlusNonValidities.lean` — `NF`, `natHist`, `natModel`, reused verbatim
* `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` — the sibling
  elimination-by-indistinguishability result, on frames rather than formulas

## Tags

independence · definability · plus-language · stability-modal · expressiveness
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.Algebraic

/-! ## `M₂`: the deterministic clock whose states carry the whole profile -/

/-- The family index of `M₂`: a state's first component *is* an atom profile. -/
abbrev StabFam : Type := ℤ → ℕ

/-- `M₂`'s frame: the deterministic clock at family index `StabFam`, over `ℤ`. -/
@[reducible] noncomputable def SF : TaskFrame :=
  (multiFamTaskFrameGen (TemporalOrder.of ℤ) StabFam).toTaskFrame

/-- `M₂`'s valuation, matched to `natModel`'s: every atom is true at the states whose profile
reads `0` at the current time, and nowhere else. -/
noncomputable def stabModel : TaskModel SF where
  valuation := fun w _ => w.1 w.2 = 0

/-- `SF` is deterministic, by specialization of `multiFamTaskFrameGen_deterministic`. -/
theorem sf_deterministic : SF.Deterministic := multiFamTaskFrameGen_deterministic

/-- The flow line of `SF` through profile `g` at offset `w₀`. -/
noncomputable def stabHist (g : StabFam) (w₀ : ℤ) : ConvexHistory SF :=
  multiFamHistoryGen g w₀

theorem stabHist_isTotal (g : StabFam) (w₀ : ℤ) : (stabHist g w₀).IsTotal :=
  multiFamHistoryGen_total g w₀

/-- Atomic truth at a total history of `M₁`: the clause's domain conjunct is discharged by
totality, leaving the valuation at the history's own state. Stated through `.valuation` rather
than by unfolding it to a numeral equation, because `NF.WorldState` does not reduce far enough
for a `ℕ` numeral to elaborate against it. -/
theorem nf_atom_iff {σ : ConvexHistory NF} (hσ : σ.IsTotal) (t : ℤ) (q : Atom) :
    TruthAt natModel σ t (Formula.atom q) ↔ natModel.valuation (σ.states t (hσ t)) q :=
  ⟨fun ⟨_, hv⟩ => hv, fun h => ⟨hσ t, h⟩⟩

/-- Atomic truth at a total history of `M₂`, the same way. -/
theorem sf_atom_iff {σ' : ConvexHistory SF} (hσ' : σ'.IsTotal) (t : ℤ) (q : Atom) :
    TruthAt stabModel σ' t (Formula.atom q) ↔ stabModel.valuation (σ'.states t (hσ' t)) q :=
  ⟨fun ⟨_, hv⟩ => hv, fun h => ⟨hσ' t, h⟩⟩

/-! ## The truth correspondence

The relation is "agrees on every atom at every time". The `atom` field is then definitional, and
the two totality fields are the profile-matching constructions: forward, read the profile off the
`M₁` history and flow it; backward, read the `ℕ`-value off the `M₂` history's own states and feed
it to `natHist`, which accepts *any* function because `NF` is permissive.
-/

/-- Every atom profile realized by a total history of `M₁` is realized by one of `M₂`, and
conversely; the relation recording that is a `TruthCorr`. -/
noncomputable def stabCorr : TruthCorr natModel stabModel where
  dur := OrderIso.refl _
  Rel := fun σ σ' => ∀ (t : ℤ) (q : Atom),
    TruthAt natModel σ t (Formula.atom q) ↔ TruthAt stabModel σ' t (Formula.atom q)
  atom := fun _ _ h t q => h t q
  total_fwd := by
    intro σ hσ
    refine ⟨stabHist (fun s => σ.states s (hσ s)) 0, stabHist_isTotal _ _, ?_⟩
    intro t q
    refine Iff.trans (nf_atom_iff hσ t q)
      (Iff.trans ?_ (sf_atom_iff (stabHist_isTotal _ _) t q).symm)
    show natModel.valuation (σ.states t (hσ t)) q ↔
      stabModel.valuation ((fun s => σ.states s (hσ s)), (0 : ℤ) + t) q
    rw [zero_add]
    exact Iff.rfl
  total_bwd := by
    intro σ' hσ'
    refine ⟨natHist (fun s => (σ'.states s (hσ' s)).1 (σ'.states s (hσ' s)).2),
      natHist_isTotal _, ?_⟩
    intro t q
    exact Iff.trans (nf_atom_iff (natHist_isTotal _) t q) (sf_atom_iff hσ' t q).symm

/-! ## The separating pair -/

/-- The profile "`p` at time `1`, nowhere else". -/
def oneProfile : ℤ → ℕ := fun s => if s = 1 then 0 else 1

/-- `τ₁`: the `M₁` history carrying `oneProfile`. -/
def tauOne : ConvexHistory NF := natHist oneProfile

/-- `τ₂`: the `M₂` flow line carrying `oneProfile`. -/
noncomputable def tauTwo : ConvexHistory SF := stabHist oneProfile 0

/-- The two histories are `stabCorr`-related: both read `oneProfile` at every time. -/
theorem tauOne_rel_tauTwo : stabCorr.Rel tauOne tauTwo := by
  intro t q
  refine Iff.trans (nf_atom_iff (natHist_isTotal oneProfile) t q)
    (Iff.trans ?_ (sf_atom_iff (stabHist_isTotal oneProfile 0) t q).symm)
  show natModel.valuation (oneProfile t) q ↔ stabModel.valuation (oneProfile, (0 : ℤ) + t) q
  rw [zero_add]
  exact Iff.rfl

/-- `Fp` holds at `(τ₁, 0)`: the profile reads `0` at time `1`. -/
theorem someFuture_tauOne (p : Atom) :
    PlusTruthAt natModel tauOne 0 (someFuture (.atom p)) := by
  rw [PlusTruth.someFuture_iff]
  exact ⟨(1 : ℤ), (one_pos : (0 : ℤ) < 1), trivial, (by simp [oneProfile] : oneProfile 1 = 0)⟩

/-- `⊡Fp` **fails** at `(τ₁, 0)`: the constant history shares `τ₁`'s state at time `0` — both are
`1`, since `oneProfile 0 = 1` — and never reaches `p`. -/
theorem not_stab_someFuture_tauOne (p : Atom) :
    ¬ PlusTruthAt natModel tauOne 0 (.stab (someFuture (.atom p))) := by
  intro h
  have hB := h (natHist fun _ => 1) (natHist_isTotal _)
    (fun _ _ => by show oneProfile 0 = 1; simp [oneProfile])
  rw [PlusTruth.someFuture_iff] at hB
  obtain ⟨s, _, hat⟩ := hB
  obtain ⟨_, v⟩ := hat
  exact one_ne_zero (v : (1 : ℕ) = 0)

/-- `Fp` holds at `(τ₂, 0)`. -/
theorem someFuture_tauTwo (p : Atom) :
    PlusTruthAt stabModel tauTwo 0 (someFuture (.atom p)) := by
  rw [PlusTruth.someFuture_iff]
  refine ⟨(1 : ℤ), (one_pos : (0 : ℤ) < 1), trivial, ?_⟩
  show oneProfile (0 + 1) = 0
  norm_num [oneProfile]

/-- `⊡Fp` **holds** at `(τ₂, 0)`: `SF` is deterministic, so `⊡` collapses onto its argument. -/
theorem stab_someFuture_tauTwo (p : Atom) :
    PlusTruthAt stabModel tauTwo 0 (.stab (someFuture (.atom p))) :=
  (stab_iff_of_deterministic sf_deterministic stabModel (stabHist_isTotal _ _) 0 _).mpr
    (someFuture_tauTwo p)

/-! ### `□Fp` fails on both sides

Recorded because it is what makes the separation informative: `⊡` is not doing `□`'s work. On
`M₁` the witness is the constant history; on `M₂` it is the flow line of the constant profile,
which is total because every flow line is. -/

/-- `□Fp` fails at `(τ₁, 0)`. -/
theorem box_someFuture_false_left (p : Atom) :
    ¬ PlusTruthAt natModel tauOne 0 (.box (someFuture (.atom p))) := by
  intro h
  have hB := h (natHist fun _ => 1) (natHist_isTotal _)
  rw [PlusTruth.someFuture_iff] at hB
  obtain ⟨s, _, _, v⟩ := hB
  exact one_ne_zero (v : (1 : ℕ) = 0)

/-- `□Fp` fails at `(τ₂, 0)`. -/
theorem box_someFuture_false_right (p : Atom) :
    ¬ PlusTruthAt stabModel tauTwo 0 (.box (someFuture (.atom p))) := by
  intro h
  have hB := h (stabHist (fun _ => 1) 0) (stabHist_isTotal _ _)
  rw [PlusTruth.someFuture_iff] at hB
  obtain ⟨s, _, _, v⟩ := hB
  exact one_ne_zero (v : (1 : ℕ) = 0)

/-! ## The theorem -/

/--
**The stability modal is not L-definable.** No `Formula` `ψ` of L is equivalent to the
`PlusFormula` `⊡Fp` at every task model, total history and time.

Any such `ψ` would have to be false at `(M₁, τ₁, 0)` and true at `(M₂, τ₂, 0)`; but the two
points are `stabCorr`-related, and `truthAt_of_truthCorr` transports every `Formula` along a
`TruthCorr`. So the two truth values coincide, and no `ψ` can separate what `⊡Fp` separates.

Paper: `def:BLstar-semantics`
-/
theorem stabNotDefinable (p : Atom) :
    ¬ ∃ ψ : Formula, ∀ (F : TaskFrame) (M : TaskModel F) (τ : ConvexHistory F),
      τ.IsTotal → ∀ t : F.Duration,
        (PlusTruthAt M τ t (PlusFormula.stab (PlusFormula.someFuture (PlusFormula.atom p))) ↔
          TruthAt M τ t ψ) := by
  rintro ⟨ψ, hψ⟩
  have hleft : ¬ TruthAt natModel tauOne 0 ψ := fun h =>
    not_stab_someFuture_tauOne p
      ((hψ NF natModel tauOne (natHist_isTotal _) 0).mpr h)
  have hright : TruthAt stabModel tauTwo 0 ψ :=
    (hψ SF stabModel tauTwo (stabHist_isTotal _ _) 0).mp (stab_someFuture_tauTwo p)
  exact hleft
    ((Truth.truthAt_of_truthCorr stabCorr ψ tauOne tauTwo tauOne_rel_tauTwo 0).mpr hright)

end FormalSystem.Metalogic.Independence
