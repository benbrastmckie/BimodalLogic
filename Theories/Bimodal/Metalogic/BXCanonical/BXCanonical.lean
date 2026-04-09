import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.TruthLemma
import Bimodal.Metalogic.BXCanonical.CanonicalEmbedding
import Bimodal.Metalogic.BXCanonical.Completeness

/-!
# BX Canonical Model Completeness

This module collects the BX canonical model completeness proof.

## Architecture

1. `Frame.lean` — BXPoint, canonical ordering, forward/backward witnesses
2. `TruthLemma.lean` — Truth lemma by formula induction
3. `CanonicalEmbedding.lean` — Fragment completeness for temporal-free formulas
4. `Completeness.lean` — BX completeness theorem (sorry for full completeness)
-/
