/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTest.Syntax.FormulaTest
import BimodalTest.Syntax.ContextTest
import BimodalTest.Syntax.FormulaPropertyTest
import BimodalTest.Syntax.LanguageDerivationTest
import BimodalTest.ProofSystem.AxiomsTest
import BimodalTest.ProofSystem.DerivationTest
import BimodalTest.ProofSystem.DerivationPropertyTest
import BimodalTest.ProofSystem.DerivationBenchmark
import BimodalTest.Semantics.ValidityLayerTest
import BimodalTest.Semantics.TruthTest
import BimodalTest.Semantics.TaskFrameTest
import BimodalTest.Semantics.SaturationFiniteAxiomTest
import BimodalTest.Semantics.OpenLanguageAxiomTest
import BimodalTest.Semantics.SemanticPropertyTest
import BimodalTest.Semantics.DependentUltraproductProbe
import BimodalTest.Semantics.QTimeTest
import BimodalTest.Theorems.PropositionalTest
import BimodalTest.Theorems.ModalS4Test
import BimodalTest.Theorems.ModalS5Test
import BimodalTest.Theorems.PerpetuityTest
import BimodalTest.WalkthroughAxioms
import BimodalTest.Metalogic.PropDecideTest
import BimodalTest.Metalogic.PeriodicExtensionAxiomTest
import BimodalTest.Metalogic.Decidability.SaturationTest
import BimodalTest.Metalogic.Decidability.BiLassoTest
import BimodalTest.Metalogic.Decidability.BiLassoSuccessorTest
import BimodalTest.Metalogic.Decidability.Verified.TerminationProbes
import BimodalTest.Metalogic.Decidability.Verified.BridgeProbes
import BimodalTest.Metalogic.Decidability.TableauConformance
import BimodalTest.Metalogic.Decidability.BoxSpreadProbe
import BimodalTest.Metalogic.Decidability.RegionGateProbe
import BimodalTest.Metalogic.Decidability.RayRegionProbe
import BimodalTest.Metalogic.Decidability.TemporalWitnessProbe
import BimodalTest.Metalogic.Decidability.CrossWorldPropagationProbe
import BimodalTest.Metalogic.Decidability.BoxNegPreservationProbe
import BimodalTest.Metalogic.Decidability.BoxNegReachabilityProbe
import BimodalTest.Metalogic.Decidability.UntlSnceCopyProbe
import BimodalTest.Automation.ProofSearchTest
import BimodalTest.Automation.EdgeCaseTest
import BimodalTest.Automation.ProofSearchBenchmark
import BimodalTest.Automation.TacticsTest
import BimodalTest.Automation.TacticsTest_Simple
import BimodalTest.Automation.LemmaDBTest
import BimodalTest.Automation.DeductionTest
import BimodalTest.Automation.NormalizationTest
import BimodalTest.Automation.WeakeningSearchTest
import BimodalTest.Integration.Helpers
import BimodalTest.Integration.EndToEndTest
import BimodalTest.Integration.ProofSystemSemanticsTest
import BimodalTest.Integration.AutomationProofSystemTest
import BimodalTest.Integration.ComplexDerivationTest
import BimodalTest.Integration.TemporalIntegrationTest
import BimodalTest.Integration.BimodalIntegrationTest
import BimodalTest.Property.Generators
import BimodalTest.Property

/-!
# BimodalTest - Test Suite for Bimodal TM Logic

Comprehensive test suite for the Bimodal library, following the Mathlib pattern
(Mathlib/ + MathlibTest/) with tests in a separate top-level directory.

## Test Organization

Tests mirror the Bimodal library structure:
- `Syntax/` - Formula and Context tests
- `ProofSystem/` - Axiom and Derivation tests
- `Semantics/` - Truth and frame tests
- `Metalogic/` - Soundness and Completeness tests
- `Theorems/` - Specific theorem tests (Perpetuity, Modal axioms)
- `Automation/` - Proof search and tactic tests
- `Integration/` - Cross-module integration tests
- `Property/` - Property-based tests with Plausible
- Loose `Trace*Test.lean` - trace-certificate and trace-export round-trip tests

Every test module under `Tests/BimodalTest/` is imported above; none is excluded.
`scripts/module-invariants-manifest.txt`, the list of live modules outside every build closure,
is empty. A test module absent from both this file and that manifest is a gap in the gate; the
invariant check (C6) fails on exactly that condition.

## Running Tests

```bash
lake build BimodalTest    # Build test library
```
-/

namespace BimodalTest

def version : String := "0.1.0"

end BimodalTest
