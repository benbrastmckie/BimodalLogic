import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Metalogic.BXCanonical.TruthLemma
import Bimodal.Metalogic.BXCanonical.Completeness
import Bimodal.Metalogic.BXCanonical.Quasimodel.SubformulaClosure
import Bimodal.Metalogic.BXCanonical.Quasimodel.HintikkaPoint
import Bimodal.Metalogic.BXCanonical.Quasimodel.Construction
import Bimodal.Metalogic.BXCanonical.Quasimodel.Realization
import Bimodal.Metalogic.BXCanonical.Quasimodel.LocusControl

/-!
# BX Canonical Model Completeness

This module collects the BX canonical model completeness proof.

## Architecture

1. `Frame.lean` — BXPoint, canonical ordering, forward/backward witnesses
2. `TruthLemma.lean` — Truth lemma by formula induction
3. `Completeness.lean` — BX completeness theorem (sorry for full completeness)
4. `Quasimodel/` — Hintikka-set quasimodel infrastructure for Until/Since
   - `SubformulaClosure.lean` — Finite subformula closure (Sigma-closure)
   - `HintikkaPoint.lean` — Hintikka point definition and sigma-signature
   - `Construction.lean` — BX axiom lemmas at MCS level
   - `Realization.lean` — Realization lifting (Until/Since eventuality resolution)
   - `LocusControl.lean` — Locus-control and sorry-closure interface
-/
