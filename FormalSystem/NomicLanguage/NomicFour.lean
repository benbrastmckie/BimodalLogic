/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.NomicLanguage.NomicValidity
import FormalSystem.Semantics.Nomic

/-!
# `app:nomic-four` — axiom 4 for the nomic operator over ℤ-time

Over a nomic frame with `D = ℤ`, the schema `◈φ → ◈◈φ` is valid **exactly** on the nomologically
uniform frames, and likewise the interderivability `◈φ ↔ □φ`. In particular the schema is invalid
over a frame that is both *Static* and *Lawful* — `prop:nomic-hierarchy`'s third witness.

The `(⇐)` direction needs no induction at all: uniformity equates the `(◈)` and `(□)` clauses
outright, so `NomicLanguage.nomic_iff_box_of_uniform` and its validity form do the whole job.

The `(⇒)` direction is the paper's explicit countermodel. From `¬ Uniform` take `v` with
`H_F^v ≠ H_F` and `ρ ∈ H_F \ H_F^v`; over ℤ-time, membership in `H_F^v` reduces to the one-step
condition, so some `n` has `¬(ρ(n) ⇒₁^v ρ(n+1))`. With `|p| = {ρ(n)}` and `|q| = {ρ(n+1)}`, the
sentence `△¬(p ∧ ◯q)` holds along every member of `H_F^v` at every time — a `μ(m) = ρ(n)` would
force `μ(m+1) ≠ ρ(n+1)` — while `ρ` falsifies it at `n`. Taking `τ ∈ H_F^v` with `τ(0) = v` and
`σ ∈ H_F^v` with `σ(0) = w`, the nomic operator holds at `(τ, 0)`, fails at `(σ, 0)`, and
`σ ∈ H_F^{τ(0)}`, so the nested form fails at `(τ, 0)`. The **same** sentence separates `◈φ` from
`□φ` there, since `ρ ∈ H_F` falsifies it.

## The ℤ-time hypothesis is load-bearing

BL has **no duration-indexed tense operator**, so a violation `¬(ρ(y) ⇒_{z-y}^v ρ(z))` at a
general duration cannot be localized at adjacent times — and localizing it at adjacent times is
exactly what the `◯` step of the witness sentence needs. Over ℤ the reduction is available:
`NomicFrame.mem_lawHist_iff_isStepPath` says membership in `H_F^v` *is* the bi-infinite one-step
condition. Whether some non-uniform nomic frame over a **dense** temporal order validates
`◈φ → ◈◈φ` is left open by the paper's own commented remark, and is **not attempted** here.

## A carrier-boundary hazard, inherited

Lifting `ρ ∉ F.lawHist v` to `¬ IsStepPath (F.at v) ρ` crosses the `↑intOrder` / `ℤ` boundary that
`FormalSystem/Semantics/Nomic/ZTime.lean` records: `rw` will not cross it, and the step is taken
with an `exact`-shaped term instead. Inside the two satisfaction claims no boundary is crossed —
`μ z` and `ρ n` are both `F.World` — so rewriting there is fine.

## Main Results

- `four_validOn_iff_uniform` — `app:nomic-four`'s first claim
- `nomic_iff_box_validOn_iff_uniform` — its second claim, on the same witness sentence
- `not_four_nomicValid` — the invalidity claim, at `prop:nomic-hierarchy`'s static-and-lawful
  witness
- `exists_refutation_of_not_uniform` — the shared countermodel both biconditionals consume

## Choice dependence, recorded honestly

Every result here reaches `lem:nomic-occurrence` and so is a theorem of **ZFC**, not of ZF,
through `thm:extension`'s Zorn appeal; `not_four_nomicValid` additionally inherits the
`Classical.choice` cost of each witness frame's *Saturation*. `rmk:choice` does not list these
among the paper's choice-free results.

## References

* JPL paper `app:nomic-four` — the theorem formalized here, and its commented ℤ-time remark
* JPL paper `thm:nomic-uniform` — the `(⇐)` direction's input
* JPL paper `prop:nomic-hierarchy` — the static-and-lawful witness
* JPL paper `lem:nomic-occurrence`, `lem:nullity` — the two frame-level inputs
* `FormalSystem/Semantics/Nomic/ZTime.lean` — `mem_lawHist_iff_isStepPath`, the one-step bridge
* `FormalSystem/Semantics/Nomic/Witnesses.lean` — `NomicHierarchy.F3` and `F3.not_uniform`

## Tags

nomic-language · axiom-four · countermodel · uniformity · z-time
-/

namespace FormalSystem.NomicLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

/--
The shared countermodel of `app:nomic-four`'s `(⇒)` direction: over ℤ-time, a non-uniform nomic
frame carries a model, a nomologically possible world and **one** sentence at which `◈φ` holds
while both `◈◈φ` and `□φ` fail.

The sentence is `△¬(p ∧ ◯q)` for two atoms interpreted as the singletons `{ρ(n)}` and
`{ρ(n+1)}` at a one-step violation of `⇒₁^v` along a law-history outside `H_F^v`. Both
biconditionals below consume this one lemma, which is the paper's "the same `φ` separates"
sentence made explicit.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem exists_refutation_of_not_uniform (F : NomicFrame intOrder) [F.IsRegular]
    (hnu : ¬ F.Uniform) :
    ∃ (φ : NomicFormula) (M : NomicModel F) (τ : ℤ → F.World), τ ∈ F.HF ∧
      NomicTruthAt M τ 0 (.nomic φ) ∧ ¬ NomicTruthAt M τ 0 (.nomic (.nomic φ)) ∧
        ¬ NomicTruthAt M τ 0 (.box φ) := by
  -- (a) a world state whose law-histories are not all of `H_F`
  obtain ⟨v, hv⟩ : ∃ v : F.World, F.lawHist v ≠ F.HF := by
    by_contra hc
    push Not at hc
    exact hnu hc
  -- (b) a nomologically possible world outside `H_F^v`
  obtain ⟨ρ, hρHF, hρv⟩ : ∃ ρ ∈ F.HF, ρ ∉ F.lawHist v :=
    Set.exists_of_ssubset (LE.le.ssubset_of_ne (F.lawHist_subset_HF v) hv)
  obtain ⟨w, hρw⟩ := Set.mem_iUnion.mp hρHF
  -- (c) a one-step violation, the step that needs ℤ-time
  have hnotpath : ¬ IsStepPath (F.at v) ρ :=
    fun hs => hρv ((NomicFrame.mem_lawHist_iff_isStepPath F v ρ).mpr hs)
  obtain ⟨n, hstep⟩ : ∃ n : ℤ, ¬ (F.at v).step (ρ n) (ρ (n + 1)) := by
    by_contra hc
    push Not at hc
    exact hnotpath hc
  -- (d) the countermodel: two atoms, a two-clause valuation, and the witness sentence
  have hpq : (⟨"p", none⟩ : Atom) ≠ (⟨"q", none⟩ : Atom) := by decide
  refine ⟨NomicFormula.always (NomicFormula.neg (NomicFormula.and
      (.atom ⟨"p", none⟩) (NomicFormula.next (.atom ⟨"q", none⟩)))),
    ⟨fun u a => (a = ⟨"p", none⟩ ∧ u = ρ n) ∨ (a = ⟨"q", none⟩ ∧ u = ρ (n + 1))⟩, ?_⟩
  -- the two readback facts the atoms' distinctness buys
  have hvalP : ∀ u : F.World,
      ((⟨"p", none⟩ : Atom) = ⟨"p", none⟩ ∧ u = ρ n) ∨
        ((⟨"p", none⟩ : Atom) = ⟨"q", none⟩ ∧ u = ρ (n + 1)) → u = ρ n := by
    rintro u (⟨_, h⟩ | ⟨h, _⟩)
    · exact h
    · exact absurd h hpq
  have hvalQ : ∀ u : F.World,
      ((⟨"q", none⟩ : Atom) = ⟨"p", none⟩ ∧ u = ρ n) ∨
        ((⟨"q", none⟩ : Atom) = ⟨"q", none⟩ ∧ u = ρ (n + 1)) → u = ρ (n + 1) := by
    rintro u (⟨h, _⟩ | ⟨_, h⟩)
    · exact absurd h.symm hpq
    · exact h
  -- (e) every law-history at `v` satisfies the sentence at every time
  have hsat : ∀ μ ∈ F.lawHist v, ∀ z : ℤ,
      NomicTruthAt (F := F) ⟨fun u a => (a = ⟨"p", none⟩ ∧ u = ρ n) ∨
        (a = ⟨"q", none⟩ ∧ u = ρ (n + 1))⟩ μ z
        (NomicFormula.always (NomicFormula.neg (NomicFormula.and
          (.atom ⟨"p", none⟩) (NomicFormula.next (.atom ⟨"q", none⟩))))) := by
    intro μ hμ z
    have hpath : IsStepPath (F.at v) μ := (NomicFrame.mem_lawHist_iff_isStepPath F v μ).mp hμ
    rw [NomicTruth.always_iff]
    intro y
    rw [NomicTruth.neg_iff, NomicTruth.and_iff, NomicTruth.next_iff_add_one]
    rintro ⟨hp, hq⟩
    have hpy : μ y = ρ n := hvalP _ hp
    have hqy : μ (y + 1) = ρ (n + 1) := hvalQ _ hq
    have := hpath y
    rw [hpy, hqy] at this
    exact hstep this
  -- (f) `ρ` falsifies it, at every time
  have hfail : ∀ z : ℤ, ¬ NomicTruthAt (F := F)
      ⟨fun u a => (a = ⟨"p", none⟩ ∧ u = ρ n) ∨ (a = ⟨"q", none⟩ ∧ u = ρ (n + 1))⟩ ρ z
        (NomicFormula.always (NomicFormula.neg (NomicFormula.and
          (.atom ⟨"p", none⟩) (NomicFormula.next (.atom ⟨"q", none⟩))))) := by
    intro z hz
    rw [NomicTruth.always_iff] at hz
    have hn := hz n
    rw [NomicTruth.neg_iff, NomicTruth.and_iff, NomicTruth.next_iff_add_one] at hn
    exact hn ⟨Or.inl ⟨rfl, rfl⟩, Or.inr ⟨rfl, rfl⟩⟩
  -- (g) the two evaluation points, from `lem:nomic-occurrence`
  obtain ⟨τ, hτ, hτ0⟩ := F.occurrence v v (0 : ↑intOrder)
  obtain ⟨σ, hσ, hσ0⟩ := F.occurrence v w (0 : ↑intOrder)
  refine ⟨τ, F.lawHist_subset_HF v hτ, ?_, ?_, ?_⟩
  · -- `◈φ` holds at `(τ, 0)`: `H_F^{τ(0)} = H_F^v`, every member of which satisfies `φ`
    intro μ hμ
    rw [hτ0] at hμ
    exact hsat μ hμ 0
  · -- `◈◈φ` fails at `(τ, 0)`: `σ` is accessible and `ρ ∈ H_F^{σ(0)}` falsifies `φ`
    intro hnn
    refine hfail 0 ?_
    refine hnn σ (by rw [hτ0]; exact hσ) ρ ?_
    rw [hσ0]
    exact hρw
  · -- `□φ` fails at `(τ, 0)`: `ρ ∈ H_F` falsifies `φ`
    intro hbox
    exact hfail 0 (hbox ρ hρHF)

end FormalSystem.NomicLanguage

namespace FormalSystem.Semantics

open FormalSystem.NomicLanguage

/--
`app:nomic-four`, first claim: over ℤ-time, axiom **4** for the nomic operator is valid exactly on
the nomologically uniform frames.

`(⇐)` is `NomicLanguage.nomic_iff_box_of_uniform` twice, with no induction: under uniformity the
nomic clause and the box clause are literally the same, and the box clause ignores the point of
evaluation, so the nested consequent reduces to the antecedent. `(⇒)` is the countermodel of
`exists_refutation_of_not_uniform`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem four_validOn_iff_uniform (F : NomicFrame intOrder) [F.IsRegular] :
    (∀ φ : NomicFormula, F.NomicValidOn (.imp (.nomic φ) (.nomic (.nomic φ)))) ↔ F.Uniform := by
  constructor
  · intro hvalid
    by_contra hnu
    obtain ⟨φ, M, τ, hτ, hnom, hnn, _⟩ := exists_refutation_of_not_uniform F hnu
    exact hnn (hvalid φ M τ hτ 0 hnom)
  · intro h φ M τ _ x hnom σ _
    exact (nomic_iff_box_of_uniform h M σ x φ).mpr ((nomic_iff_box_of_uniform h M τ x φ).mp hnom)

/--
`app:nomic-four`, second claim: over ℤ-time, the nomic operator and the box are interderivable
exactly on the nomologically uniform frames.

`(⇐)` is `nomicValidOn_nomic_iff_box_of_uniform`. `(⇒)` is the **same** countermodel sentence as
`four_validOn_iff_uniform`'s, which is the paper's own observation: `ρ ∈ H_F` falsifies the
witness while every member of `H_F^v` satisfies it, so `◈φ` and `□φ` come apart at `(τ, 0)`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_iff_box_validOn_iff_uniform (F : NomicFrame intOrder) [F.IsRegular] :
    (∀ φ : NomicFormula, F.NomicValidOn (.imp (.nomic φ) (.box φ)) ∧
        F.NomicValidOn (.imp (.box φ) (.nomic φ))) ↔ F.Uniform := by
  constructor
  · intro hvalid
    by_contra hnu
    obtain ⟨φ, M, τ, hτ, hnom, _, hbox⟩ := exists_refutation_of_not_uniform F hnu
    exact hbox ((hvalid φ).1 M τ hτ 0 hnom)
  · intro h φ
    exact nomicValidOn_nomic_iff_box_of_uniform F h φ

/--
`app:nomic-four`'s invalidity claim: axiom **4** for the nomic operator fails over a *Static* and
*Lawful* ℤ-time frame — `prop:nomic-hierarchy`'s static-and-lawful witness, which is not uniform.

Stated in `nomic_hierarchy`'s own `∃ _ : F.IsRegular` bundling shape, with the instance supplied
as a bare term: `NomicHierarchy.F3` is a plain `def`, so `[F3.IsRegular]` does not synthesize —
the instance head is not syntactically `ofStepFamily …` until `F3` unfolds. The term is bound with
`haveI` inside the proof before `four_validOn_iff_uniform` is applied.

**Choice dependence, recorded honestly.** A theorem of ZFC: through `lem:nomic-occurrence`, and
additionally through each member frame's *Saturation*, which `TaskFrame.saturation_of_finite`
supplies at a cost of `Classical.choice`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem not_four_nomicValid :
    ∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular,
      F.Static ∧ F.Lawful ∧
        ¬ ∀ φ : NomicFormula, F.NomicValidOn (.imp (.nomic φ) (.nomic (.nomic φ))) := by
  haveI : NomicHierarchy.F3.IsRegular :=
    NomicFrame.ofStepFamily_isRegular NomicHierarchy.R3 NomicHierarchy.R3.fwd
      NomicHierarchy.R3.bwd
  refine ⟨NomicHierarchy.F3,
    NomicFrame.ofStepFamily_isRegular NomicHierarchy.R3 NomicHierarchy.R3.fwd
      NomicHierarchy.R3.bwd,
    NomicHierarchy.F3.static, NomicHierarchy.F3.lawful, ?_⟩
  intro hvalid
  exact NomicHierarchy.F3.not_uniform ((four_validOn_iff_uniform NomicHierarchy.F3).mp hvalid)

end FormalSystem.Semantics
