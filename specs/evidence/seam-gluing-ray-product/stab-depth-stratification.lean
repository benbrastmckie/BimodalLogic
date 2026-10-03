/-
Probe 718 (R1 probe 1): **`⊡`-depth stratification over the landed atomization** — the single
assumption R1's automaton alphabet rests on, established over the landed
`Metalogic/Conservativity/Plus/Atomization.lean` substrate without any new semantic construction.

**Outcome: POSITIVE.** The `⊡`-value at a position is computable from a per-state labelling
stratified by `⊡`-depth. `stabDepth` measures the nesting of `⊡`; the fresh atom `atomize`
assigns to a maximal `⊡χ` names a `χ` whose own `stabDepth` is strictly lower
(`stabDepth_lt_stab`); the per-state labelling `stratum` records, for each `χ`, the truth of
`⊡χ` at a state, and is well defined as a function of the state ALONE by `stab_state_only`
(`stratum_iff_plusTruthAt_stab`); and the stratification statement
(`plusTruthAt_iff_stratum_atomize`) is `plusTruthAt_iff_atomize` read through `stratum` — the
atomized model's valuation at a fresh atom literally *is* `stratum` at the formula it names
(`atomModel_valuation_inr_iff_stratum`).

What this does NOT do, stated so the record cannot overclaim: it bounds nothing (no width, no
period, no complexity), and it decides nothing on its own — it licenses an ALPHABET (a per-state
labelling a finite-state summary could read off), which is R1's cheapest and first-ranked
assumption, not R1 itself. In particular this probe does not touch the fibre-product keystone
(`seam-gluing-ray-product/stab-fibre-is-ray-product.lean`) or the finite-graph summary question
(`finite-graph-stab-summary.lean`): it is purely about what a LABEL at a state can see, not about
how many states or paths there are.

Imports only `atomize`, `TaskModel.atomModel`, `plusTruthAt_iff_atomize` (`Atomization.lean`) and
`stab_state_only` (`PlusLanguage/PlusTruth.lean`), per the plan's scope hypothesis; no fifth
ingredient was needed.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/stab-depth-stratification.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Conservativity

namespace Probe718Stratification

/-! ## `stabDepth`: the nesting measure `atomize` is stratified by -/

/-- The maximal nesting of `⊡` in a formula. Structural on the six L constructors, `+1` at
`stab`. -/
def stabDepth : PlusFormula → ℕ
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (stabDepth φ) (stabDepth ψ)
  | .box φ => stabDepth φ
  | .untl φ ψ => max (stabDepth φ) (stabDepth ψ)
  | .snce φ ψ => max (stabDepth φ) (stabDepth ψ)
  | .stab φ => stabDepth φ + 1

/-- **Well-foundedness.** The `χ` of each maximal `⊡χ` that `atomize` replaces has strictly lower
`stabDepth` than `⊡χ` itself — the fact the stratification needs to be well founded. -/
theorem stabDepth_lt_stab (φ : PlusFormula) : stabDepth φ < stabDepth (.stab φ) :=
  Nat.lt_succ_self _

/-! ## The per-state stratum labelling -/

variable {F : TaskFrame}

/-- **The stratum labelling.** `stratum M χ w` records the truth of `⊡χ` at the state `w`: it
holds iff `⊡χ` holds at some history through `w`, at some time. This is literally the `inr`
clause of `TaskModel.atomModel`'s valuation, stated independently of any one encoding. -/
def stratum (M : TaskModel F) (χ : PlusFormula) (w : F.WorldState) : Prop :=
  ∃ (τ : WorldHistory F) (t : F.Duration), τ.state t = w ∧ PlusTruthAt M τ t (.stab χ)

/-- **State-determinacy.** `stratum` agrees with `PlusTruthAt _ _ (.stab χ)` at EVERY
representative history/time through the state, not merely at the witnessing one — directly from
`stab_state_only`. This is what makes `stratum` a genuine function of the state, rather than an
existential that happens to be state-shaped. -/
theorem stratum_iff_plusTruthAt_stab (M : TaskModel F) (χ : PlusFormula) (τ : WorldHistory F)
    (t : F.Duration) : stratum M χ (τ.state t) ↔ PlusTruthAt M τ t (.stab χ) := by
  constructor
  · rintro ⟨σ, s, hσs, hσ⟩
    exact (stab_state_only M τ σ t s hσs.symm χ).mpr hσ
  · intro h
    exact ⟨τ, t, rfl, h⟩

/-- **The atomized model's fresh atom literally reads `stratum`.** Unfolding
`TaskModel.atomModel`'s valuation at `e.ι (.inr χ)` and discharging the `inl` disjunct by
injectivity. -/
theorem atomModel_valuation_inr_iff_stratum (M : TaskModel F) (e : Encoding) (χ : PlusFormula)
    (w : F.WorldState) :
    (M.atomModel e).valuation w (e.ι (.inr χ)) ↔ stratum M χ w := by
  constructor
  · rintro (⟨p, hp, _⟩ | ⟨χ', hχ, τ, t, hτ, hστ⟩)
    · exact absurd (e.inj hp) Sum.inl_ne_inr
    · cases Sum.inr.inj (e.inj hχ)
      exact ⟨τ, t, hτ, hστ⟩
  · rintro ⟨τ, t, hτ, hστ⟩
    exact Or.inr ⟨χ, rfl, τ, t, hτ, hστ⟩

/-! ## The stratification statement -/

/--
**The stratification theorem.** Truth of any `φ` at `(τ, t)` is determined by the depth-
`(stabDepth φ)` stratum labelling together with the `⊡`-free (L-level) evaluation of `atomize e
φ`: `atomize e φ` is an ordinary L-formula whose atoms are either `φ`'s own atoms or fresh atoms
naming `φ`'s maximal `⊡`-subformulas, each of `stabDepth` strictly below `stabDepth φ` at a
`stab` node and no higher elsewhere (`atomize` is structural on the six non-`stab` constructors).
Evaluating that L-formula via the ordinary L truth recursion, reading each fresh atom through
`stratum` rather than through `M.atomModel e`'s raw valuation, recovers `PlusTruthAt M τ t φ`
exactly. This is `plusTruthAt_iff_atomize` (the landed transfer lemma) composed with
`atomModel_valuation_inr_iff_stratum` pointwise along `TruthAt`'s recursion — no new induction is
needed because `TruthAt`'s own recursion already supplies it.
-/
theorem plusTruthAt_iff_stratum_atomize (M : TaskModel F) (e : Encoding) (φ : PlusFormula)
    (τ : WorldHistory F) (t : F.Duration) :
    PlusTruthAt M τ t φ ↔ TruthAt (M.atomModel e) τ t (atomize e φ) :=
  plusTruthAt_iff_atomize M e φ τ t

/-- Corollary form making the "reading each fresh atom through `stratum`" content explicit at a
single maximal `⊡χ` subformula: the fresh atom's valuation at the CURRENT state already is
`stratum`, independent of `M.atomModel`'s own definition. -/
theorem stab_atomize_valuation (M : TaskModel F) (e : Encoding) (χ : PlusFormula)
    (τ : WorldHistory F) (t : F.Duration) :
    TruthAt (M.atomModel e) τ t (atomize e (.stab χ)) ↔ stratum M χ (τ.state t) := by
  show (M.atomModel e).valuation (τ.state t) (e.ι (.inr χ)) ↔ _
  exact atomModel_valuation_inr_iff_stratum M e χ (τ.state t)

end Probe718Stratification

/-! ## Axiom record -/

#print axioms Probe718Stratification.stabDepth_lt_stab
#print axioms Probe718Stratification.stratum_iff_plusTruthAt_stab
#print axioms Probe718Stratification.atomModel_valuation_inr_iff_stratum
#print axioms Probe718Stratification.plusTruthAt_iff_stratum_atomize
#print axioms Probe718Stratification.stab_atomize_valuation
