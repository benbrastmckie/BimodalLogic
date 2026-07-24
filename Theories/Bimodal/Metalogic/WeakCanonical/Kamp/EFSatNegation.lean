import Bimodal.Metalogic.WeakCanonical.Kamp.VVecEA2Collapse
import Bimodal.Metalogic.WeakCanonical.Kamp.Prop42NegationGeneral
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas

/-!
# Negation of a general `∃∀`-object at the `∨∃∀` type (Rabinovich Prop 4.3, ¬-case, PDF p.6)

This module assembles the negation `¬ efSat N env ψ` of a general `r`-free-variable `∃∀`-object as a
`VeeExistsForall` (`∨∃∀`) object, threading the capture hypothesis `hCapture` (never discharging it).
It is a **CONDITIONAL** result — an orphan gated on `hCapture` until Phase ζ — off the live import
path.

## Strategy (Prop 4.3, ¬-case, p.6)

The migrated Lemma 3.2(2) biconditional `augTarget_iff` (`ExistsForallLemmas.lean`) reads
`efSat N env ψ ↔ augConjSat N env (augTarget ψ)`, i.e. `efSat ψ` iff *every* pairwise projection
`pairProject ψ k l` holds on `![env k, env l]` **and** the existence sentence holds. De Morgan
negates it into a disjunction:

```
¬ efSat ψ  ↔  (∃ (k,l), ¬ efSat ![env k, env l] (pairProject ψ k l))  ∨  ¬ efSat ![] (existenceSentence ψ)
```

Each per-pair `¬ efSat ![env k, env l] (pairProject ψ k l)` is realized as a `VeeExistsForall sig F 2`
by composing the arbitrary-pin negation engine `prop42_efSat_negation_general`
(`Prop42NegationGeneral.lean`, `VVecEA2`-valued, gate `env 0 < env 1` supplied by `StrictMono env`)
with the landed collapse bridge `vvecea2_collapse_bridge` (`VVecEA2Collapse.lean`). The existence
sentence (`r = 0`) is negated through the same engine+bridge at arity `0`/`2`.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Prop 4.3 ¬-case (PDF p.6), Def 4.1 (p.5-6). Cited
  by PDF page; the companion markdown transcription is corrupt.
- `ExistsForallLemmas.lean`: `augTarget_iff`, `pairProject`, `pairwiseProjections`, `conjSat`.
- `Prop42NegationGeneral.lean`: `prop42_efSat_negation_general` (the arbitrary-pin `VVecEA2` engine).
- `VVecEA2Collapse.lean`: `vvecea2_collapse_bridge` (the `VVecEA2 → VeeExistsForall` bridge).
- `VeeExistsForall.lean`: `veeSat`, `veeSat_append`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

/-! ## Fin layer: De Morgan decomposition and swap symmetry on the per-formula representation

Fin counterparts of the total-alphabet lemmas above, on `ExistsForallFormulaFin`/`efSatFin`
(`PerFormulaExistsForall.lean`). The pair objects `pairProjectFin`/`pairwiseProjectionsFin` and
the biconditional `augTargetFin_iff` already live in `ExistsForallLemmas.lean` (Fin section) and
are consumed directly, not re-derived. No alphabet finiteness enters: every proof is on the
partial relations. Rabinovich Prop 4.3 ¬-case (PDF p.6), Lemma 3.2(2) (p.4). -/

section FinLayer

/-- **Fin-variant of `efSat_negation_demorgan` (Prop 4.3 ¬-case, p.6).** Negating the Fin
biconditional `augTargetFin_iff` (`efSatFin ψ ↔ every pairwise projection holds ∧ the existence
sentence holds`) yields: `ψ` fails iff some ordered-pair projection fails on `![env k, env l]`
**or** the existence sentence fails on `![]`. Pure classical propositional De Morgan; no capture
hypothesis, no arity lift, no alphabet instances. -/
theorem efSatFin_negation_demorgan {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) :
    ¬ efSatFin N env ψ ↔
      (∃ p ∈ pairwiseProjectionsFin ψ, ¬ efSatFin N ![env p.1, env p.2.1] p.2.2) ∨
        ¬ efSatFin N ![] (existenceSentenceFin ψ) := by
  rw [augTargetFin_iff N env ψ, augConjSatFin, augTargetFin]
  constructor
  · intro h
    by_cases hex : efSatFin N ![] (existenceSentenceFin ψ)
    · refine Or.inl ?_
      by_contra hall
      push_neg at hall
      exact h ⟨fun p hp => hall p hp, hex⟩
    · exact Or.inr hex
  · rintro (⟨p, hp, hnp⟩ | hex) ⟨hconj, hexist⟩
    · exact hnp (hconj p hp)
    · exact hex hexist

/-- **Fin-variant of `pairProject_swap_efSat` (`k > l` folds to `l < k`).** The 2-free-variable
per-formula projection is symmetric under swapping the two lifted variables: identical chain,
`M`, and partial types (`pairProjectFin` copies `ψ`'s), and the only `env`-dependent clause, the
pin clause, is a commuted pair of the same two equations. The witness chain is reused verbatim,
only the pin clause is reordered. -/
theorem pairProject_swap_efSatFin {sig : MonadicSignature} {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormulaFin sig F r) (k l : Fin r) :
    efSatFin N ![env k, env l] (pairProjectFin ψ k l) ↔
      efSatFin N ![env l, env k] (pairProjectFin ψ l k) := by
  have key : ∀ (a b : Fin r), efSatFin N ![env a, env b] (pairProjectFin ψ a b) →
      efSatFin N ![env b, env a] (pairProjectFin ψ b a) := by
    intro a b h
    obtain ⟨x, hmono, hpin, hpt, hb, hm, ha⟩ := h
    refine ⟨x, hmono, Fin.forall_fin_two.mpr ⟨?_, ?_⟩, hpt, hb, hm, ha⟩
    · simpa [pairProjectFin] using hpin 1
    · simpa [pairProjectFin] using hpin 0
  exact ⟨key k l, key l k⟩

/-- **Fin-variant of `efSat_negation_pair` (engine ∘ bridge).** For any per-formula
two-free-variable `∃∀`-object `ξ` (in practice a `pairProjectFin ψ k l`), the arbitrary-pin
negation engine `prop42_efSat_negation_generalFin` produces a `VVecEA2` object realizing
`¬ efSatFin ξ` on strictly ordered pairs, and the collapse bridge `vvecea2_collapse_bridgeFin`
lifts it to a `VeeExistsForallFin` (each disjunct bundling its own mentioned set). Threads the
`M`-relative capture hypothesis, never discharged. -/
theorem efSat_negation_pairFin {sig : MonadicSignature} {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ (M : Finset (AtomKind (sigE sig F) 1))
        (S : IntervalTypeFin sig F M),
        ∀ y : N.carrier, intervalHoldsFin N S y ↔ temporal_truth N atomMap y A)
    (ξ : ExistsForallFormulaFin sig F 2) :
    ∃ Φ : VeeExistsForallFin sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSatFin N env Φ ↔ ¬ efSatFin N env ξ) := by
  obtain ⟨v', hv'⟩ := prop42_efSat_negation_generalFin N atomMap h_surj h_INF h_SUP ξ
  obtain ⟨Φ, hΦ⟩ := vvecea2_collapse_bridgeFin N atomMap h_surj h_INF h_SUP hCapture v'
  exact ⟨Φ, fun env henv => (hΦ env henv).trans (hv' env henv)⟩

end FinLayer

end Bimodal.Metalogic.WeakCanonical.Kamp
