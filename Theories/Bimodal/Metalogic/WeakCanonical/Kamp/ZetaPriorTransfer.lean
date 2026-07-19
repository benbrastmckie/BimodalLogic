import Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaCapture
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF

/-!
# ζ Prior-axiom transfer to the canonical expansion (B2 / PROBE 2 GAP-A/A′)

This module transports `M`'s semantic Prior axioms (`semantic_prior_UZ`/`semantic_prior_SZ`,
`PriorDefs.lean`) along the canonical expansion `canonExpand sig F M sat`
(Rabinovich, *A Proof of Kamp's Theorem*, 2014, Definition 4.1, PDF p.5) onto the fixed
Phase-13a `atomMap = oldPred ∘ g` interface, and derives the attained-infimum/supremum
predicates `HasAttainedINF`/`HasAttainedSUP` that `translate_correct` consumes.

## Mechanism (a TRANSFER proof — no new expressiveness content)

The canonical expansion inherits `M`'s carrier and linear order **verbatim**
(`canonExpand`: `carrier := M.carrier`, `carrier_order := M.carrier_order`), and — because the
object-language atom map factors through the *old* predicates (`atomMap φ = oldPred (g φ)`) — its
interpretation of every `TL` formula agrees with `M`'s under `g`. That agreement is precisely the
landed bridge `temporal_truth_canonExpand` (`ESigmaCapture.lean`):

```
temporal_truth (canonExpand sig F M sat) atomMap y A ↔ temporal_truth M g y A
```

Since `semantic_prior_UZ`/`semantic_prior_SZ` are quantified statements over the carrier whose only
structure-dependent content is `<` (inherited definitionally) and `temporal_truth · · · ψ`/`ψ.neg`
(bridged by `temporal_truth_canonExpand`), each Prior axiom transports by rewriting every
`temporal_truth` occurrence through the bridge, applying `M`'s axiom, and rewriting back. No fresh
`E[Σ]` atom ever participates and no induction beyond the one already discharged inside
`temporal_truth_canonExpand` is required.

`HasAttainedINF`/`HasAttainedSUP` then follow mechanically from the transported axioms via the
landed `prior_hasAttainedINF`/`prior_hasAttainedSUP` (`PriorINF.lean`).

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5) — the canonical expansion.
- `PriorDefs.lean`: `semantic_prior_UZ`, `semantic_prior_SZ`.
- `ESigmaCapture.lean`: `temporal_truth_canonExpand` (the conservativity bridge).
- `PriorINF.lean`: `HasAttainedINF`, `HasAttainedSUP`, `prior_hasAttainedINF`, `prior_hasAttainedSUP`.
- `ESigmaExpansion.lean`: `canonExpand`, `oldPred`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula)
open Bimodal.Metalogic.WeakCanonical

/-! ## 1. Transfer of the semantic Prior axioms -/

/--
**Prior-UZ transfers to the canonical expansion.** If `M` satisfies `semantic_prior_UZ` under its
old-signature atom map `g`, then the canonical expansion `canonExpand sig F M sat` satisfies
`semantic_prior_UZ` under the Phase-13a atom map `atomMap = oldPred ∘ g`. Proof: the carrier and
order are inherited verbatim, and every `temporal_truth` occurrence is rewritten through the
conservativity bridge `temporal_truth_canonExpand`, so `M`'s axiom applies directly. (Report 16
B2, PROBE 2 GAP-A.)
-/
theorem canonExpand_semantic_prior_UZ {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hUZ : semantic_prior_UZ M g) :
    semantic_prior_UZ (canonExpand sig F M sat) atomMap := by
  intro t ψ hex
  obtain ⟨s, hts, hsψ⟩ := hex
  -- Transport the witness of occurrence down to `M`.
  have hsψM : temporal_truth M g s ψ :=
    (temporal_truth_canonExpand M sat atomMap g hMap ψ s).mp hsψ
  -- Apply `M`'s Prior-UZ; carrier and order are `M`'s verbatim.
  obtain ⟨s', hts', hsψ', hr⟩ := hUZ t ψ ⟨s, hts, hsψM⟩
  refine ⟨s', hts', (temporal_truth_canonExpand M sat atomMap g hMap ψ s').mpr hsψ', ?_⟩
  intro r h1 h2
  exact (temporal_truth_canonExpand M sat atomMap g hMap ψ.neg r).mpr (hr r h1 h2)

/--
**Prior-SZ transfers to the canonical expansion.** Mirror of `canonExpand_semantic_prior_UZ` for
the Since direction. If `M` satisfies `semantic_prior_SZ` under `g`, then `canonExpand sig F M sat`
satisfies `semantic_prior_SZ` under `atomMap = oldPred ∘ g`. (Report 16 B2, PROBE 2 GAP-A′.)
-/
theorem canonExpand_semantic_prior_SZ {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hSZ : semantic_prior_SZ M g) :
    semantic_prior_SZ (canonExpand sig F M sat) atomMap := by
  intro t ψ hex
  obtain ⟨s, hst, hsψ⟩ := hex
  have hsψM : temporal_truth M g s ψ :=
    (temporal_truth_canonExpand M sat atomMap g hMap ψ s).mp hsψ
  obtain ⟨s', hst', hsψ', hr⟩ := hSZ t ψ ⟨s, hst, hsψM⟩
  refine ⟨s', hst', (temporal_truth_canonExpand M sat atomMap g hMap ψ s').mpr hsψ', ?_⟩
  intro r h1 h2
  exact (temporal_truth_canonExpand M sat atomMap g hMap ψ.neg r).mpr (hr r h1 h2)

/-! ## 2. Attained infima / suprema on the canonical expansion (fed to β/δ by the ζ wire) -/

/--
**The canonical expansion has attained infima.** Assembled from the transported Prior-UZ axiom via
the landed `prior_hasAttainedINF`. This is one of the two `HasAttained*` hypotheses
`translate_correct` consumes; Phase 13e feeds it to the β negation stack.
-/
theorem canonExpand_hasAttainedINF {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hUZ : semantic_prior_UZ M g) :
    HasAttainedINF (canonExpand sig F M sat) atomMap :=
  prior_hasAttainedINF (canonExpand sig F M sat) atomMap
    (canonExpand_semantic_prior_UZ M sat atomMap g hMap hUZ)

/--
**The canonical expansion has attained suprema.** Mirror of `canonExpand_hasAttainedINF`, assembled
from the transported Prior-SZ axiom via `prior_hasAttainedSUP`. Phase 13e feeds it to the δ
negation stack.
-/
theorem canonExpand_hasAttainedSUP {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hSZ : semantic_prior_SZ M g) :
    HasAttainedSUP (canonExpand sig F M sat) atomMap :=
  prior_hasAttainedSUP (canonExpand sig F M sat) atomMap
    (canonExpand_semantic_prior_SZ M sat atomMap g hMap hSZ)

end Bimodal.Metalogic.WeakCanonical.Kamp
