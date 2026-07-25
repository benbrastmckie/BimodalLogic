/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Table

/-!
# Prior Structure Semantic Hypotheses

Defines `semantic_prior_UZ` and `semantic_prior_SZ` -- the semantic form of
the Prior axioms. These are the hypotheses passed to `no_gaps_discrete` and
used throughout the Reynolds pipeline.

Extracted from `PriorExpressiveness.lean` to break import cycles:
`KampPrior.lean` needs these definitions, and `PriorExpressiveness.lean`
needs to import `KampPrior.lean`.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-- Semantic Prior-UZ: every future occurrence of ψ has a first occurrence.
    If ψ holds somewhere above t, then there is a FIRST occurrence of ψ
    above t, with ψ.neg holding everywhere between t and that first occurrence. -/
abbrev semantic_prior_UZ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (ψ : Formula),
    (∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ) →
    ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ ∧
      ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r ψ.neg

/-- Semantic Prior-SZ: every past occurrence of ψ has a last occurrence.
    If ψ holds somewhere below t, then there is a LAST occurrence of ψ
    below t, with ψ.neg holding everywhere between that last occurrence and t. -/
abbrev semantic_prior_SZ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (ψ : Formula),
    (∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ) →
    ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ ∧
      ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r ψ.neg

end Bimodal.Metalogic.WeakCanonical
