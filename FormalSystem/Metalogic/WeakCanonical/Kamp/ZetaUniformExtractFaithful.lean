/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ZetaUniformExtract
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.VecEANegFixFaithful

/-!
# The ζ wire at the faithful eq (5.2) carrier

`ZetaUniformExtract.lean` runs the `M`-uniform `∨∃∀` extraction (Rabinovich 2014, Theorem 4.4,
PDF p.6) on `HasAttainedINF` / `HasAttainedSUP` — the *attained originals*. This module re-bases
that wire onto `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP` (`Kamp/KPlusFaithful.lean:320`,
`:339`), which are Rabinovich's eq (5.2) dichotomy (PDF p.8) at the source's own `K⁺`/`K⁻`.

## What the re-base actually cost, as measured

`HasAttainedINF` is a *strictly stronger* carrier than `HasFaithfulDedekindINF`
(`HasAttainedINF.toHasFaithfulDedekindINF`, `KPlusFaithful.lean:382`, runs attained → faithful and
has no converse — `hasFaithfulDedekindINF_not_implies_hasDedekindINF`, `:693`). So this is not a
free swap: it weakens a hypothesis the originals could have leaned on anywhere.

The measurement says they lean on it in exactly one place. Across `ZetaUniformExtract.lean`'s
fourteen `HasAttained*` occurrences, `h_INF`/`h_SUP` are **consumed** at exactly one site —
`VVecEA2.negFix_iff` inside `prop42_efSat_negation_general_uniformFin` (`:162`) — and
**constructed** at two (`:800`, `:802`). Every other occurrence is pure threading: bound by
`intro` and passed unexamined to a sibling uniform lemma. The five re-based theorems below are
therefore the originals' proof bodies verbatim, with the single consuming step redirected to
`VVecEA2.negFixFaithful_iff` (`EANegationFixFaithful/VecEANegFixFaithful.lean:244`) and its
witness to `VVecEA2.negFixFaithful`.

**A finding worth recording**: at the faithful carrier the `SUP` half is *not consumed at all*.
`VVecEA2.negFix_iff` needs `HasAttainedINF` **and** `HasAttainedSUP`; `VVecEA2.negFixFaithful_iff`
needs `HasFaithfulDedekindINF` **alone**. The `HasFaithfulDedekindSUP` hypothesis is kept in every
statement below so the shapes stay parallel to the attained originals and to the consuming
obligation, but it is bound to `_h_SUP` and never used. Strengthening these statements by deleting
it is left as a separate decision, not taken here.

## Nothing is removed and nothing is renamed

Every declaration of `ZetaUniformExtract.lean` stands untouched; this module only adds `_faithful`
siblings. The three carrier-free uniform lemmas of that module —
`efSat_negation_diagonal_uniformFin`, `vvecea2_collapse_bridge_uniformFin` and
`ex_closure_translate_uniformFin` — are *reused verbatim*, not duplicated: they never mention a
completeness carrier.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014): Proposition 4.2 (closure under negation, PDF
  p.6), Proposition 4.3 / Theorem 4.4 (PDF p.6), Definition 4.1 (PDF p.5), eq (5.2) (PDF p.8),
  Definitions (2)/(3) for `K⁻`/`K⁺` (PDF p.3).
- `EANegationFixFaithful/VecEANegFixFaithful.lean`: the faithful De Morgan fold.
- `ZetaPriorTransfer.lean`: the attained transfers this module's §1 mirrors.

**No source for §1.** The canonical-expansion transfer lemmas below have no counterpart in
Rabinovich or Reynolds. Rabinovich's Definition 4.1 introduces the expanded alphabet but states no
transfer of a completeness property along it; this tree needs one because it instantiates the
uniform translate at `canonExpand`. §1 is therefore original work, modelled on the landed
`canonExpand_hasAttainedINF` (`ZetaPriorTransfer.lean:110`).
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula Atom)
open FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The faithful carrier transfers to the canonical expansion

Mirror of `canonExpand_hasAttainedINF` / `canonExpand_hasAttainedSUP`
(`ZetaPriorTransfer.lean:110`, `:124`) at the faithful carrier. Unlike those two, these do **not**
route through a semantic Prior axiom: `HasFaithfulDedekindINF` mentions only the carrier, its
order, and `TemporalTruth · P` for object-language formulas `P`. The canonical expansion inherits
carrier and order verbatim and `temporal_truth_canonExpand` (`ESigmaCapture.lean:70`) transports
every truth occurrence, so the property transfers directly. **No source** — see the module header.
-/

/-- **The faithful eq (5.2) infimum carrier transfers to the canonical expansion.**

If `M` satisfies `HasFaithfulDedekindINF` under its old-signature atom map `g`, then
`canonExpand sig F M sat` satisfies it under `atomMap = oldPred ∘ g`.

Both disjuncts of the dichotomy are transported clause by clause: `kplusOpen` and the `kplus`
right disjunct are `∀`/`∃` statements over the shared carrier whose only non-order atom is
`TemporalTruth · P`, and `P` ranges over object-language formulas, which the expansion does not
touch. -/
theorem canonExpand_hasFaithfulDedekindINF
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hINF : HasFaithfulDedekindINF M g) :
    HasFaithfulDedekindINF (canonExpand sig F M sat) atomMap where
  first_occ P z0 z1 hlt hocc := by
    have hTT : ∀ (Q : Formula) (y : M.carrier),
        TemporalTruth (canonExpand sig F M sat) atomMap y Q ↔ TemporalTruth M g y Q :=
      fun Q y => temporal_truth_canonExpand M sat atomMap g hMap Q y
    obtain ⟨x, hx0, hx1, hxP⟩ := hocc
    rcases hINF.first_occ P z0 z1 hlt ⟨x, hx0, hx1, (hTT P x).mp hxP⟩ with
      hL | ⟨r0, hr0a, hr0b, hno, hr0c⟩
    · refine Or.inl fun s hs => ?_
      obtain ⟨r, h1, h2, h3⟩ := hL s hs
      exact ⟨r, h1, h2, (hTT P r).mpr h3⟩
    · refine Or.inr ⟨r0, hr0a, hr0b,
        fun y hy1 hy2 hyP => hno y hy1 hy2 ((hTT P y).mp hyP), ?_⟩
      rcases hr0c with h | h
      · exact Or.inl ((hTT P r0).mpr h)
      · refine Or.inr ⟨fun hc => h.1 ((hTT P r0).mp hc), fun s hs => ?_⟩
        obtain ⟨r, h1, h2, h3⟩ := h.2 s hs
        exact ⟨r, h1, h2, (hTT P r).mpr h3⟩

/-- **The faithful eq (5.2) supremum carrier transfers to the canonical expansion.**
Mirror of `canonExpand_hasFaithfulDedekindINF` at the right endpoint, through `kminusOpen` and
`kminus`. -/
theorem canonExpand_hasFaithfulDedekindSUP
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hSUP : HasFaithfulDedekindSUP M g) :
    HasFaithfulDedekindSUP (canonExpand sig F M sat) atomMap where
  last_occ P z0 z1 hlt hocc := by
    have hTT : ∀ (Q : Formula) (y : M.carrier),
        TemporalTruth (canonExpand sig F M sat) atomMap y Q ↔ TemporalTruth M g y Q :=
      fun Q y => temporal_truth_canonExpand M sat atomMap g hMap Q y
    obtain ⟨x, hx0, hx1, hxP⟩ := hocc
    rcases hSUP.last_occ P z0 z1 hlt ⟨x, hx0, hx1, (hTT P x).mp hxP⟩ with
      hL | ⟨r0, hr0a, hr0b, hno, hr0c⟩
    · refine Or.inl fun s hs => ?_
      obtain ⟨r, h1, h2, h3⟩ := hL s hs
      exact ⟨r, h1, h2, (hTT P r).mpr h3⟩
    · refine Or.inr ⟨r0, hr0a, hr0b,
        fun y hy1 hy2 hyP => hno y hy1 hy2 ((hTT P y).mp hyP), ?_⟩
      rcases hr0c with h | h
      · exact Or.inl ((hTT P r0).mpr h)
      · refine Or.inr ⟨fun hc => h.1 ((hTT P r0).mp hc), fun s hs => ?_⟩
        obtain ⟨r, h1, h2, h3⟩ := h.2 s hs
        exact ⟨r, h1, h2, (hTT P r).mpr h3⟩

/-! ## 2. The low-arity negation leaf, faithful -/

/-- **Uniform arity-2 model-side engine, faithful.** `∃v'`-outside-`∀N` form of
`prop42_efSat_negation_generalFin` at the eq (5.2) carrier, and **the only declaration in this
module whose proof differs from its attained original** (`ZetaUniformExtract.lean:146`).

Two changes, both at the single consuming step: the middle-bracket witness is
`VVecEA2.negFixFaithful` in place of `VVecEA2.negFix`, and the correctness rewrite is
`VVecEA2.negFixFaithful_iff` in place of `VVecEA2.negFix_iff`. Since the witness `v'` is
existentially quantified, the statement is unchanged apart from the carrier.

This is Rabinovich's Proposition 4.2 (PDF p.6, *"the negation of ∃⃗∀-formulas with at most two
free variables is equivalent over Dedekind complete chains to a disjunction of ∃⃗∀-formulas"*) in
uniform shape, one strengthening step from his Dedekind-complete hypothesis rather than three.

`_h_SUP` is threaded and unused — see the module header. -/
theorem prop42_efSat_negation_general_uniformFin_faithful
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ψ : ExistsForallFormulaFin sig F 2) :
    ∃ v' : VVecEA2, ∀ (N : OrderedMonadicStructure (sigE sig F)),
      (∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y) →
      HasFaithfulDedekindINF N atomMap → HasFaithfulDedekindSUP N atomMap →
      ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSatFin N env ψ) := by
  by_cases hlt : (ψ.pin 0).val < (ψ.pin 1).val
  · refine ⟨VVecEA2.disj
      (VVecEA2.disj (negLeftClauseTLFin atomMap nameOf ψ)
        (middleBracketFin atomMap nameOf ψ).negFixFaithful)
      (negRightClauseTLFin atomMap nameOf ψ), ?_⟩
    intro N hName h_INF _h_SUP env henv
    rw [VVecEA2.disj_holds, VVecEA2.disj_holds, negLeftClauseTLFin_holds (_hName := hName),
      VVecEA2.negFixFaithful_iff N atomMap h_INF _ (env 0) (env 1) henv, negRightClauseTLFin_holds
          (_hName := hName),
      efSatFin_decompose_tl N atomMap nameOf hName env ψ hlt henv]
    tauto
  · refine ⟨VVecEA2.trivialTrue, ?_⟩
    intro N _ _ _ env henv
    constructor
    · intro _ hsat
      exact hlt (efSatFin_pin_lt N env ψ hsat henv)
    · intro _
      exact VVecEA2.trivialTrue_holds N atomMap (env 0) (env 1)

/-! ## 3. The pair and general negation objects (β), faithful -/

/-- **Uniform `efSat_negation_pairFin`, faithful.** Composition of the faithful arity-2 engine
with the carrier-free collapse bridge `vvecea2_collapse_bridge_uniformFin`, which is *reused*
from `ZetaUniformExtract.lean:179` rather than re-based: it mentions no completeness carrier.
Proof body verbatim from `efSat_negation_pair_uniformFin` (`:320`). -/
theorem efSat_negation_pair_uniformFin_faithful
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    (ξ : ExistsForallFormulaFin sig F 2) :
    ∃ Φ : VeeExistsForallFin sig F 2,
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ TemporalTruth N atomMap y A) →
        HasFaithfulDedekindINF N atomMap → HasFaithfulDedekindSUP N atomMap →
        ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (veeSatFin N env Φ ↔ ¬ efSatFin N env ξ) := by
  obtain ⟨v', hv'⟩ := prop42_efSat_negation_general_uniformFin_faithful atomMap nameOf ξ
  obtain ⟨Φ, hΦ⟩ := vvecea2_collapse_bridge_uniformFin atomMap nameOf v'
  refine ⟨Φ, fun N hName hNamed h_INF h_SUP env henv => ?_⟩
  exact (hΦ N hName hNamed env henv).trans (hv' N hName h_INF h_SUP env henv)

/-- **Uniform `efSat_negation_generalFin` (β), faithful.** Proof body verbatim from
`efSat_negation_general_uniformFin` (`ZetaUniformExtract.lean:343`); `h_INF`/`h_SUP` occur only as
`intro`-bound hypotheses passed to the faithful pair and diagonal leaves. The diagonal leaf
`efSat_negation_diagonal_uniformFin` is reused unchanged — it carries no completeness carrier. -/
theorem efSat_negation_general_uniformFin_faithful
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {r : Nat} (ψ : ExistsForallFormulaFin sig F r) :
    ∃ Φ : VeeExistsForallFin sig F r, (∀ φ ∈ Φ, StrictMono φ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ TemporalTruth N atomMap y A) →
        HasFaithfulDedekindINF N atomMap → HasFaithfulDedekindSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin r → N.carrier, StrictMono env →
        (¬ efSatFin N env ψ ↔ veeSatFin N env Φ) := by
  classical
  have hpair := fun (k l : Fin r) =>
    efSat_negation_pair_uniformFin_faithful atomMap nameOf (pairProjectFin ψ k l)
  choose P hPspec using hpair
  have hdiag := fun (k : Fin r) =>
    efSat_negation_diagonal_uniformFin atomMap nameOf (diagProjectFin ψ k)
  choose D hDspec using hdiag
  obtain ⟨E, hEspec⟩ :=
    efSat_negation_existence_uniformFin atomMap nameOf (existenceSentenceFin ψ)
  refine ⟨((List.finRange r).flatMap fun k => (List.finRange r).flatMap fun l =>
            if k < l then liftPairVFin (P k l) k l else [])
          ++ ((List.finRange r).flatMap fun k => liftSingleVFin (D k) k)
          ++ liftSentenceVFin E, ?_, ?_⟩
  · -- Pin-monotonicity of every disjunct (model-independent).
    intro φ hφ
    rw [List.mem_append, List.mem_append] at hφ
    rcases hφ with (hφ | hφ) | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      rw [List.mem_flatMap] at hφ
      obtain ⟨l, _, hφ⟩ := hφ
      by_cases hkl : k < l
      · rw [if_pos hkl] at hφ
        exact liftPairVFin_pin_strictMono (P k l) k l φ hφ
      · rw [if_neg hkl] at hφ
        exact absurd hφ List.not_mem_nil
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      exact liftSingleVFin_pin_strictMono (D k) k φ hφ
    · exact liftSentenceVFin_pin_strictMono E φ hφ
  · intro N hName hNamed h_INF h_SUP hne env h
    set A := (List.finRange r).flatMap (fun k => (List.finRange r).flatMap fun l =>
              if k < l then liftPairVFin (P k l) k l else []) with hAdef
    set B := (List.finRange r).flatMap (fun k => liftSingleVFin (D k) k) with hBdef
    set C := liftSentenceVFin E with hCdef
    have hA : veeSatFin N env A ↔
        ∃ k l : Fin r, k < l ∧ ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l) := by
      rw [hAdef, veeSatFin_flatMap]
      constructor
      · rintro ⟨k, -, hk⟩
        rw [veeSatFin_flatMap] at hk
        obtain ⟨l, -, hl⟩ := hk
        by_cases hkl : k < l
        · rw [if_pos hkl, liftPairVFin_iff N env h (P k l) k l hkl,
            hPspec k l N hName hNamed h_INF h_SUP ![env k, env l] (by simpa using h hkl)] at hl
          exact ⟨k, l, hkl, hl⟩
        · rw [if_neg hkl] at hl
          simp [veeSatFin] at hl
      · rintro ⟨k, l, hkl, hnp⟩
        refine ⟨k, List.mem_finRange k, ?_⟩
        rw [veeSatFin_flatMap]
        refine ⟨l, List.mem_finRange l, ?_⟩
        rw [if_pos hkl, liftPairVFin_iff N env h (P k l) k l hkl,
          hPspec k l N hName hNamed h_INF h_SUP ![env k, env l] (by simpa using h hkl)]
        exact hnp
    have hB : veeSatFin N env B ↔
        ∃ k : Fin r, ¬ efSatFin N ![env k, env k] (pairProjectFin ψ k k) := by
      rw [hBdef, veeSatFin_flatMap]
      constructor
      · rintro ⟨k, -, hk⟩
        rw [liftSingleVFin_iff N env h (D k) k, hDspec k N hName hNamed ![env k],
          ← diagProjectFin_efSat_iff N env ψ k] at hk
        exact ⟨k, hk⟩
      · rintro ⟨k, hk⟩
        refine ⟨k, List.mem_finRange k, ?_⟩
        rw [liftSingleVFin_iff N env h (D k) k, hDspec k N hName hNamed ![env k],
          ← diagProjectFin_efSat_iff N env ψ k]
        exact hk
    have hC : veeSatFin N env C ↔ ¬ efSatFin N ![] (existenceSentenceFin ψ) := by
      rw [hCdef, liftSentenceVFin_iff N env h E, hEspec N hName hNamed hne]
    have hDemPairs : (∃ p ∈ pairwiseProjectionsFin ψ, ¬ efSatFin N ![env p.1, env p.2.1] p.2.2)
        ↔ ∃ k l : Fin r, ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l) := by
      constructor
      · rintro ⟨p, hp, hnp⟩
        unfold pairwiseProjectionsFin at hp
        rw [List.mem_flatMap] at hp
        obtain ⟨k, -, hp⟩ := hp
        rw [List.mem_map] at hp
        obtain ⟨l, -, rfl⟩ := hp
        exact ⟨k, l, hnp⟩
      · rintro ⟨k, l, hnp⟩
        refine ⟨(k, l, pairProjectFin ψ k l), ?_, hnp⟩
        unfold pairwiseProjectionsFin
        rw [List.mem_flatMap]
        exact ⟨k, List.mem_finRange k, by rw [List.mem_map]; exact ⟨l, List.mem_finRange l, rfl⟩⟩
    have hTri : (∃ k l : Fin r, ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l))
        ↔ (∃ k l : Fin r, k < l ∧ ¬ efSatFin N ![env k, env l] (pairProjectFin ψ k l))
          ∨ (∃ k : Fin r, ¬ efSatFin N ![env k, env k] (pairProjectFin ψ k k)) := by
      constructor
      · rintro ⟨k, l, hnp⟩
        rcases lt_trichotomy k l with hkl | hkl | hkl
        · exact Or.inl ⟨k, l, hkl, hnp⟩
        · subst hkl; exact Or.inr ⟨_, hnp⟩
        · refine Or.inl ⟨l, k, hkl, ?_⟩
          rw [← pairProject_swap_efSatFin N env ψ k l]
          exact hnp
      · rintro (⟨k, l, -, hnp⟩ | ⟨k, hnp⟩)
        · exact ⟨k, l, hnp⟩
        · exact ⟨k, k, hnp⟩
    rw [efSatFin_negation_demorgan N env ψ, hDemPairs, veeSatFin_append, veeSatFin_append,
      hA, hB, hC, hTri]

/-! ## 4. Negation closure (γ), faithful -/

/-- **Uniform `veeSat_negationFin` (γ), faithful.** Proof body verbatim from
`veeSat_negation_uniformFin` (`ZetaUniformExtract.lean:462`); the carrier hypotheses are threaded
into the faithful β-negation and nowhere examined. -/
theorem veeSat_negation_uniformFin_faithful
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {r : Nat} (Φ : VeeExistsForallFin sig F r) :
    ∃ Φ' : VeeExistsForallFin sig F r, (∀ ψ ∈ Φ', StrictMono ψ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ TemporalTruth N atomMap y A) →
        HasFaithfulDedekindINF N atomMap → HasFaithfulDedekindSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin r → N.carrier, StrictMono env →
        (¬ veeSatFin N env Φ ↔ veeSatFin N env Φ') := by
  classical
  induction Φ with
  | nil =>
    obtain ⟨Gd, hGdmono, hGd⟩ :=
      efSat_negation_general_uniformFin_faithful atomMap nameOf (efArbFin sig F r)
    refine ⟨Gd ++ [efArbFin sig F r], ?_, ?_⟩
    · intro φ hφ
      rw [List.mem_append] at hφ
      rcases hφ with hφ | hφ
      · exact hGdmono φ hφ
      · rw [List.mem_singleton] at hφ
        subst hφ
        exact efArbFin_pin_strictMono sig F r
    · intro N hName hNamed h_INF h_SUP hne env hmono
      constructor
      · intro _
        rw [veeSatFin_append]
        by_cases hd : efSatFin N env (efArbFin sig F r)
        · exact Or.inr ⟨efArbFin sig F r, by simp, hd⟩
        · exact Or.inl ((hGd N hName hNamed h_INF h_SUP hne env hmono).mp hd)
      · intro _
        exact veeSatFin_nil N env
  | cons ψ rest ih =>
    obtain ⟨Gψ, hGψmono, hGψ⟩ :=
      efSat_negation_general_uniformFin_faithful atomMap nameOf ψ
    obtain ⟨Φrest, hrestmono, hrest⟩ := ih
    refine ⟨veeConjFin Gψ Φrest, ?_, ?_⟩
    · exact fun χ hχ => veeConjFin_pin_strictMono Gψ Φrest hGψmono χ hχ
    · intro N hName hNamed h_INF h_SUP hne env hmono
      rw [veeSatFin_cons, not_or, hGψ N hName hNamed h_INF h_SUP hne env hmono,
        hrest N hName hNamed h_INF h_SUP hne env hmono, veeConjFin_iff N env Gψ Φrest]

/-! ## 5. The uniform translate, faithful -/

/-- **Rabinovich Theorem 4.4 (PDF p.6) in uniform shape, faithful.** For a fixed
`atomMap`/`nameOf` naming, every monadic FO formula over the E[Σ] alphabet has a *single*
per-formula `∨∃∀`-formula equivalent to it on strictly increasing environments of every `N`
carrying the eq (5.2) dichotomy.

Proof body verbatim from `translate_uniformFin` (`ZetaUniformExtract.lean:595`), including its
`termination_by`/`decreasing_by`; the `∃`-closure assembly `ex_closure_translate_uniformFin`
(`:512`) is reused unchanged — carrier-free. -/
theorem translate_uniformFin_faithful
    (atomMap : Formula → (sigE sig F).preds)
    (nameOf : (sigE sig F).preds → Formula)
    {m : Nat} (φ : MonadicFormula (sigE sig F) m) :
    ∃ Ψ : VeeExistsForallFin sig F m, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
      ∀ (N : OrderedMonadicStructure (sigE sig F)),
        (∀ p y, TemporalTruth N atomMap y (nameOf p) ↔ N.interp p y) →
        (∀ (A : Formula) (y : N.carrier),
            N.interp (esigmaPred (F := F) A) y ↔ TemporalTruth N atomMap y A) →
        HasFaithfulDedekindINF N atomMap → HasFaithfulDedekindSUP N atomMap → Nonempty N.carrier →
        ∀ env : Fin m → N.carrier, StrictMono env →
        (veeSatFin N env Ψ ↔ eval N env φ) := by
  classical
  match m, φ with
  | 0, .atom _ i => exact i.elim0
  | (m' + 1), .atom p i =>
      -- The p.6 collapse, inlined: `p` is named by the FORMULA `nameOf p` (at ζ the readback
      -- of a fresh pred IS its formula; a base pred is a chosen atom).
      refine ⟨atomEmitFin i (capTypeFin (esigmaPred (F := F) (nameOf p))), ?_, ?_⟩
      · intro φ' hφ'
        unfold atomEmitFin at hφ'
        rw [List.mem_map] at hφ'
        obtain ⟨σ, _, rfl⟩ := hφ'
        exact skelDisjunctFin_pin_strictMono σ
      · intro N hName hNamed _ _ _ env hmono
        rw [atomEmitFin_iff N i _ env hmono,
          capTypeFin_atomNamed N atomMap hNamed (nameOf p) (env i)]
        show TemporalTruth N atomMap (env i) (nameOf p)
            ↔ eval N env (MonadicFormula.atom p i)
        simp only [eval]
        exact hName p (env i)
  | 0, .lt i _ => exact i.elim0
  | (m' + 1), .lt i j =>
      by_cases hij : i < j
      · refine ⟨skelRFin ∅ m', ?_, ?_⟩
        · exact fun φ' hφ' => skelRFin_pin_strictMono φ' hφ'
        · intro N _ _ _ _ _ env hmono
          change veeSatFin N env (skelRFin ∅ m') ↔ env i < env j
          constructor
          · intro _; exact hmono.lt_iff_lt.mpr hij
          · intro _; exact skelRFin_sat N env hmono
      · refine ⟨[], ?_, ?_⟩
        · intro φ' hφ'; exact absurd hφ' List.not_mem_nil
        · intro N _ _ _ _ _ env hmono
          change veeSatFin N env ([] : VeeExistsForallFin sig F (m' + 1)) ↔ env i < env j
          constructor
          · intro h; exact absurd h (veeSatFin_nil N env)
          · intro h; exact absurd (hmono.lt_iff_lt.mp h) hij
  | _, .not α =>
      obtain ⟨Ψα, _, hα⟩ := translate_uniformFin_faithful atomMap nameOf α
      obtain ⟨Ψ', hΨ'mono, hΨ'⟩ := veeSat_negation_uniformFin_faithful atomMap nameOf Ψα
      refine ⟨Ψ', hΨ'mono, ?_⟩
      intro N hName hNamed h_INF h_SUP hne env hmono
      change veeSatFin N env Ψ' ↔ ¬ eval N env α
      rw [← hΨ' N hName hNamed h_INF h_SUP hne env hmono, hα N hName hNamed h_INF h_SUP hne env
          hmono]
  | _, .and α β =>
      obtain ⟨Ψα, hαmono, hα⟩ := translate_uniformFin_faithful atomMap nameOf α
      obtain ⟨Ψβ, _, hβ⟩ := translate_uniformFin_faithful atomMap nameOf β
      refine ⟨veeConjFin Ψα Ψβ, ?_, ?_⟩
      · exact fun χ hχ => veeConjFin_pin_strictMono Ψα Ψβ hαmono χ hχ
      · intro N hName hNamed h_INF h_SUP hne env hmono
        change veeSatFin N env (veeConjFin Ψα Ψβ) ↔ eval N env α ∧ eval N env β
        rw [veeConjFin_iff N env Ψα Ψβ, hα N hName hNamed h_INF h_SUP hne env hmono,
          hβ N hName hNamed h_INF h_SUP hne env hmono]
  | m, .all α =>
      have hgap := fun p : Fin (m + 1) =>
        translate_uniformFin_faithful atomMap nameOf
          (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      choose Ψg hΨgmono hΨg using hgap
      have htie := fun i : Fin m =>
        translate_uniformFin_faithful atomMap nameOf (α.subst0 i)
      choose Ψt hΨtmono hΨt using htie
      have hgapN := fun p : Fin (m + 1) =>
        veeSat_negation_uniformFin_faithful atomMap nameOf (Ψg p)
      choose Ψg' hΨg'mono hΨg'neg using hgapN
      have htieN := fun i : Fin m =>
        veeSat_negation_uniformFin_faithful atomMap nameOf (Ψt i)
      choose Ψt' hΨt'mono hΨt'neg using htieN
      obtain ⟨Ψex, hΨexmono, hΨexcorr⟩ :=
        ex_closure_translate_uniformFin (.not α) Ψg' hΨg'mono Ψt' hΨt'mono
      obtain ⟨Ψall, hΨallmono, hΨallneg⟩ :=
        veeSat_negation_uniformFin_faithful atomMap nameOf Ψex
      refine ⟨Ψall, hΨallmono, ?_⟩
      intro N hName hNamed h_INF h_SUP hne env hmono
      have hΨex := hΨexcorr N
        (fun p env' h => (hΨg'neg p N hName hNamed h_INF h_SUP hne env' h).symm.trans
          (not_congr (hΨg p N hName hNamed h_INF h_SUP hne env' h)))
        (fun i env' h => (hΨt'neg i N hName hNamed h_INF h_SUP hne env' h).symm.trans
          (not_congr (hΨt i N hName hNamed h_INF h_SUP hne env' h)))
        env hmono
      rw [← hΨallneg N hName hNamed h_INF h_SUP hne env hmono, hΨex]
      exact not_exists_not
  | m, .ex α =>
      have hgap := fun p : Fin (m + 1) =>
        translate_uniformFin_faithful atomMap nameOf
          (α.rename (insertPerm p : Fin (m + 1) → Fin (m + 1)))
      choose Ψg hΨgmono hΨg using hgap
      have htie := fun i : Fin m =>
        translate_uniformFin_faithful atomMap nameOf (α.subst0 i)
      choose Ψt hΨtmono hΨt using htie
      obtain ⟨Ψex, hΨexmono, hΨexcorr⟩ :=
        ex_closure_translate_uniformFin α Ψg hΨgmono Ψt hΨtmono
      refine ⟨Ψex, hΨexmono, ?_⟩
      intro N hName hNamed h_INF h_SUP hne env hmono
      exact hΨexcorr N
        (fun p env' h => hΨg p N hName hNamed h_INF h_SUP hne env' h)
        (fun i env' h => hΨt i N hName hNamed h_INF h_SUP hne env' h)
        env hmono
termination_by φ.size
decreasing_by
  all_goals simp only [MonadicFormula.size, size_rename, size_subst0]
  all_goals omega

/-! ## 6. The ζ wire, faithful

The terminal wire at the eq (5.2) carrier. Pipeline identical to `kampArm_zeta`
(`ZetaUniformExtract.lean:769`) — Rabinovich Theorem 4.4's five steps — with step 4's carrier
premises supplied by §1's transfers instead of `ZetaPriorTransfer.lean`'s.
-/

/-- **The ζ wire at the faithful eq (5.2) carrier (Thm 4.4, PDF p.6).** For any depth `k`, the
one-free-variable existential over a depth-`k` arity-2 normal form is expressed by a single
temporal formula, uniformly over all structures carrying Rabinovich's eq (5.2) dichotomy at the
source's own `K⁺`/`K⁻`.

Faithful sibling of `kampArm_zeta` (`ZetaUniformExtract.lean:769`), which is pinned at
`SemanticPriorUZ`/`SemanticPriorSZ`. The two are **incomparable in hypothesis strength as
stated** — this one is weaker at the carrier
(`SemanticPriorUZ → HasAttainedINF → HasFaithfulDedekindINF`, via `prior_hasAttainedINF` and
`HasAttainedINF.toHasFaithfulDedekindINF`), so every consumer of the attained wire can be
re-supplied from this one, but not conversely
(`semanticPriorU_not_implies_semanticPriorUZ`). The attained original is left in place unchanged
and remains the wire the landed `kampPriorExpressiveCompleteness` consumes.

The emitted formula is the same function of `sub_nf`, `g` and the base naming as the original's;
only the per-model premise discharge differs. -/
theorem kampArm_zeta_faithful {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (g : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, g (.atom a) = p)
    {k : Nat} (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig),
        HasFaithfulDedekindINF M g → HasFaithfulDedekindSUP M g →
        ∀ t : M.carrier,
        (TemporalTruth M g t A ↔
          ∃ x : M.carrier, NfEvalNf M k 2 (Fin.cons x (fun _ => t)) sub_nf) := by
  classical
  -- 1-2. The lifted monadic target `∃x. sub_nf` over the E[Σ] alphabet (stage index `∅`).
  set ψ : MonadicFormula sig 1 := .ex (nfToFormula sub_nf) with hψdef
  set atomMapE : Formula → (sigE sig (∅ : Finset Formula)).preds :=
    fun φ => oldPred (g φ) with hatomMapE
  have hMap : ∀ φ, atomMapE φ = oldPred (g φ) := fun _ => rfl
  set nameOf : (sigE sig (∅ : Finset Formula)).preds → Formula :=
    zetaNameOf g h_surj with hnameOf
  -- 3. The uniform Prop 4.3 translate of the lifted target, at the faithful carrier.
  obtain ⟨Ψ, _hΨmono, hΨ⟩ := translate_uniformFin_faithful atomMapE nameOf (ψ.mapPreds oldPred)
  refine ⟨translateVeeProp35Fin atomMapE nameOf Ψ, ?_⟩
  intro M hINF hSUP t
  -- 4. Instantiate at the canonical expansion with `sat B := TemporalTruth M g · B`.
  set sat : Formula → M.carrier → Prop := fun B x => TemporalTruth M g x B with hsat
  set N : OrderedMonadicStructure (sigE sig (∅ : Finset Formula)) :=
    canonExpand sig ∅ M sat with hNdef
  have hNamed : ∀ (A : Formula) (y : N.carrier),
      N.interp (esigmaPred (F := (∅ : Finset Formula)) A) y ↔ TemporalTruth N atomMapE y A :=
    fun A y => canonExpand_atom_named M atomMapE g hMap A y
  have hName : ∀ p y, TemporalTruth N atomMapE y (nameOf p) ↔ N.interp p y :=
    zetaNameOf_hName N g h_surj atomMapE hMap hNamed
  have h_INF : HasFaithfulDedekindINF N atomMapE :=
    canonExpand_hasFaithfulDedekindINF M sat atomMapE g hMap hINF
  have h_SUP : HasFaithfulDedekindSUP N atomMapE :=
    canonExpand_hasFaithfulDedekindSUP M sat atomMapE g hMap hSUP
  have hne : Nonempty N.carrier := ⟨t⟩
  have hmono1 : StrictMono (fun _ : Fin 1 => (t : N.carrier)) := by
    intro i j hij
    exact absurd (Subsingleton.elim i j) (Fin.ne_of_lt hij)
  -- 5. Chain: conservativity ∘ readback ∘ uniform-translate ∘ mapPreds ∘ nfToFormula.
  calc TemporalTruth M g t (translateVeeProp35Fin atomMapE nameOf Ψ)
      ↔ TemporalTruth N atomMapE t (translateVeeProp35Fin atomMapE nameOf Ψ) :=
        (temporal_truth_canonExpand M sat atomMapE g hMap _ t).symm
    _ ↔ veeSatFin N (fun _ => t) Ψ :=
        (translateVeeProp35Fin_correct N atomMapE nameOf hName (fun _ => t) Ψ).symm
    _ ↔ eval N (fun _ => t) (ψ.mapPreds oldPred) :=
        hΨ N hName hNamed h_INF h_SUP hne (fun _ => t) hmono1
    _ ↔ eval M (fun _ => t) ψ := mapPreds_eval_iff M sat (fun _ => t) ψ
    _ ↔ ∃ x : M.carrier, NfEvalNf M k 2 (Fin.cons x (fun _ => t)) sub_nf := by
        change (∃ x : M.carrier, eval M (Fin.cons x (fun _ => t)) (nfToFormula sub_nf)) ↔ _
        exact exists_congr fun x => nf_to_formula_correct M _ sub_nf

/-- **The attained ζ wire is re-suppliable from the faithful one.** Every consumer of
`kampArm_zeta`'s conclusion that arrives holding `SemanticPriorUZ`/`SemanticPriorSZ` can be served
by `kampArm_zeta_faithful` instead, through `prior_hasAttainedINF` and
`HasAttainedINF.toHasFaithfulDedekindINF`. Recorded so the re-base is machine-checked to be a
weakening rather than a sideways move; `kampArm_zeta` itself is left untouched. -/
theorem kampArm_zeta_faithful_covers_attained
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (g : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, g (.atom a) = p)
    {k : Nat} (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig),
        SemanticPriorUZ M g → SemanticPriorSZ M g →
        ∀ t : M.carrier,
        (TemporalTruth M g t A ↔
          ∃ x : M.carrier, NfEvalNf M k 2 (Fin.cons x (fun _ => t)) sub_nf) := by
  obtain ⟨A, hA⟩ := kampArm_zeta_faithful g h_surj sub_nf
  exact ⟨A, fun M hUZ hSZ t =>
    hA M (prior_hasAttainedINF M g hUZ).toHasFaithfulDedekindINF
        (prior_hasAttainedSUP M g hSZ).toHasFaithfulDedekindSUP t⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
