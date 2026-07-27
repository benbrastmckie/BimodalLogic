/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ESigmaCapture
import FormalSystem.Metalogic.WeakCanonical.Kamp.PriorINF

/-!
# ζ Prior-axiom transfer to the canonical expansion (B2 / PROBE 2 GAP-A/A′)

This module transports `M`'s semantic Prior axioms (`SemanticPriorUZ`/`SemanticPriorSZ`,
`PriorDefs.lean`) along the canonical expansion `canonExpand sig F M sat`
(Rabinovich, *A Proof of Kamp's Theorem*, 2014, Definition 4.1, PDF p.5) onto the fixed
Phase-13a `atomMap = oldPred ∘ g` interface, and derives the attained-infimum/supremum
predicates `HasAttainedINF`/`HasAttainedSUP` that `translate_correct` consumes.

## Mechanism (a TRANSFER proof — no new expressiveness content)

The canonical expansion inherits `M`'s carrier and linear order **verbatim**
(`canonExpand`: `carrier := M.carrier`, `carrierOrder := M.carrierOrder`), and — because the
object-language atom map factors through the *old* predicates (`atomMap φ = oldPred (g φ)`) — its
interpretation of every `TL` formula agrees with `M`'s under `g`. That agreement is precisely the
landed bridge `temporal_truth_canonExpand` (`ESigmaCapture.lean`):

```
TemporalTruth (canonExpand sig F M sat) atomMap y A ↔ TemporalTruth M g y A
```

Since `SemanticPriorUZ`/`SemanticPriorSZ` are quantified statements over the carrier whose only
structure-dependent content is `<` (inherited definitionally) and `TemporalTruth · · · ψ`/`ψ.neg`
(bridged by `temporal_truth_canonExpand`), each Prior axiom transports by rewriting every
`TemporalTruth` occurrence through the bridge, applying `M`'s axiom, and rewriting back. No fresh
`E[Σ]` atom ever participates and no induction beyond the one already discharged inside
`temporal_truth_canonExpand` is required.

`HasAttainedINF`/`HasAttainedSUP` then follow mechanically from the transported axioms via the
landed `prior_hasAttainedINF`/`prior_hasAttainedSUP` (`PriorINF.lean`).

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5) — the canonical expansion.
- `PriorDefs.lean`: `SemanticPriorUZ`, `SemanticPriorSZ`.
- `ESigmaCapture.lean`: `temporal_truth_canonExpand` (the conservativity bridge).
- `PriorINF.lean`: `HasAttainedINF`, `HasAttainedSUP`, `prior_hasAttainedINF`,
`prior_hasAttainedSUP`.
- `ESigmaExpansion.lean`: `canonExpand`, `oldPred`.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula)
open FormalSystem.Metalogic.WeakCanonical

/-! ## 1. Transfer of the semantic Prior axioms -/

/--
**Prior-UZ transfers to the canonical expansion.** If `M` satisfies `SemanticPriorUZ` under its
old-signature atom map `g`, then the canonical expansion `canonExpand sig F M sat` satisfies
`SemanticPriorUZ` under the Phase-13a atom map `atomMap = oldPred ∘ g`. Proof: the carrier and
order are inherited verbatim, and every `TemporalTruth` occurrence is rewritten through the
conservativity bridge `temporal_truth_canonExpand`, so `M`'s axiom applies directly. (Report 16
B2, PROBE 2 GAP-A.)
-/
theorem canonExpand_semantic_prior_UZ {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hUZ : SemanticPriorUZ M g) :
    SemanticPriorUZ (canonExpand sig F M sat) atomMap := by
  intro t ψ hex
  obtain ⟨s, hts, hsψ⟩ := hex
  -- Transport the witness of occurrence down to `M`.
  have hsψM : TemporalTruth M g s ψ :=
    (temporal_truth_canonExpand M sat atomMap g hMap ψ s).mp hsψ
  -- Apply `M`'s Prior-UZ; carrier and order are `M`'s verbatim.
  obtain ⟨s', hts', hsψ', hr⟩ := hUZ t ψ ⟨s, hts, hsψM⟩
  refine ⟨s', hts', (temporal_truth_canonExpand M sat atomMap g hMap ψ s').mpr hsψ', ?_⟩
  intro r h1 h2
  exact (temporal_truth_canonExpand M sat atomMap g hMap ψ.neg r).mpr (hr r h1 h2)

/--
**Prior-SZ transfers to the canonical expansion.** Mirror of `canonExpand_semantic_prior_UZ` for
the Since direction. If `M` satisfies `SemanticPriorSZ` under `g`, then `canonExpand sig F M sat`
satisfies `SemanticPriorSZ` under `atomMap = oldPred ∘ g`. (Report 16 B2, PROBE 2 GAP-A′.)
-/
theorem canonExpand_semantic_prior_SZ {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (hSZ : SemanticPriorSZ M g) :
    SemanticPriorSZ (canonExpand sig F M sat) atomMap := by
  intro t ψ hex
  obtain ⟨s, hst, hsψ⟩ := hex
  have hsψM : TemporalTruth M g s ψ :=
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
    (hUZ : SemanticPriorUZ M g) :
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
    (hSZ : SemanticPriorSZ M g) :
    HasAttainedSUP (canonExpand sig F M sat) atomMap :=
  prior_hasAttainedSUP (canonExpand sig F M sat) atomMap
    (canonExpand_semantic_prior_SZ M sat atomMap g hMap hSZ)

end FormalSystem.Metalogic.WeakCanonical.Kamp
