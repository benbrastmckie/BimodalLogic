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

/-- **Per-pair negation to `∨∃∀` (engine ∘ bridge).** For any two-free-variable `∃∀`-object `ξ`
(in practice a `pairProject ψ k l`), the arbitrary-pin negation engine
`prop42_efSat_negation_general` produces a `VVecEA2` object realizing `¬ efSat ξ` on strictly
ordered pairs, and the collapse bridge `vvecea2_collapse_bridge` lifts it to a `VeeExistsForall`.
Composing the two gives a `∨∃∀`-object whose satisfaction is exactly `¬ efSat ξ` on strictly
ordered pairs. Threads `hCapture`, never discharged. -/
theorem efSat_negation_pair {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula}
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (ξ : ExistsForallFormula sig F 2) :
    ∃ Φ : VeeExistsForall sig F 2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
      (veeSat N env Φ ↔ ¬ efSat N env ξ) := by
  obtain ⟨v', hv'⟩ := prop42_efSat_negation_general N atomMap h_surj h_INF h_SUP ξ
  obtain ⟨Φ, hΦ⟩ := vvecea2_collapse_bridge N atomMap h_surj h_INF h_SUP hCapture v'
  exact ⟨Φ, fun env henv => (hΦ env henv).trans (hv' env henv)⟩

/-- **De Morgan decomposition of `¬ efSat ψ` (Prop 4.3 ¬-case, p.6).** Negating the migrated
Lemma 3.2(2) biconditional `augTarget_iff` (`efSat ψ ↔ every pairwise projection holds ∧ the
existence sentence holds`) yields: `ψ` fails iff some ordered-pair projection fails on
`![env k, env l]` **or** the existence sentence fails on `![]`. Pure classical propositional
De Morgan over the pairwise-projection list; no capture hypothesis and no arity lift needed. -/
theorem efSat_negation_demorgan {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) :
    ¬ efSat N env ψ ↔
      (∃ p ∈ pairwiseProjections ψ, ¬ efSat N ![env p.1, env p.2.1] p.2.2) ∨
        ¬ efSat N ![] (existenceSentence ψ) := by
  rw [augTarget_iff N env ψ, augConjSat, augTarget]
  constructor
  · intro h
    by_cases hex : efSat N ![] (existenceSentence ψ)
    · refine Or.inl ?_
      by_contra hall
      push_neg at hall
      exact h ⟨fun p hp => hall p hp, hex⟩
    · exact Or.inr hex
  · rintro (⟨p, hp, hnp⟩ | hex) ⟨hconj, hexist⟩
    · exact hnp (hconj p hp)
    · exact hex hexist

/-- **Pair-projection swap symmetry (`k > l` folds to `l < k`).** The 2-free-variable projection is
symmetric under swapping the two lifted variables: `pairProject ψ k l` on `![env k, env l]` holds
exactly when `pairProject ψ l k` holds on `![env l, env k]`. Both unfold to the *same* existential
chain condition (`pointType`/`intervalType` are `k,l`-independent — `pairProject` copies `ψ`'s), and
the only `env`-dependent clause, the pin clause, is a commuted pair of the same two equations
`env k = x (ψ.pin k)`, `env l = x (ψ.pin l)`. Reusing the witness chain `x` verbatim, only the pin
clause is reordered. This lets the assembly carry only the `k < l` pairs: a `k > l` pair's content is
already realized by its `l < k` counterpart's disjunct. -/
theorem pairProject_swap_efSat {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {F : Finset Formula} {r : Nat}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ : ExistsForallFormula sig F r) (k l : Fin r) :
    efSat N ![env k, env l] (pairProject ψ k l) ↔ efSat N ![env l, env k] (pairProject ψ l k) := by
  have key : ∀ (a b : Fin r), efSat N ![env a, env b] (pairProject ψ a b) →
      efSat N ![env b, env a] (pairProject ψ b a) := by
    intro a b h
    obtain ⟨x, hmono, hpin, hpt, hb, hm, ha⟩ := h
    refine ⟨x, hmono, Fin.forall_fin_two.mpr ⟨?_, ?_⟩, hpt, hb, hm, ha⟩
    · simpa [pairProject] using hpin 1
    · simpa [pairProject] using hpin 0
  exact ⟨key k l, key l k⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
