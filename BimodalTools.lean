/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.AtomCanonicalization
import BimodalTools.AxiomNames
import BimodalTools.ContrastiveGenerator
import BimodalTools.DataExport
import BimodalTools.DatasetAssembly
import BimodalTools.DatasetGenerator
import BimodalTools.EnrichedCountermodel
import BimodalTools.FormulaEnumerator
import BimodalTools.ForwardProofGenerator
import BimodalTools.InterestingnessMetrics
import BimodalTools.PrefilterSoundness
import BimodalTools.ProofFirstBenchmark
import BimodalTools.ProofFirstGenerator
import BimodalTools.ProofStepExtractor
import BimodalTools.TraceExport
-- The 12 `*Main` modules are deliberately absent: each declares a root-namespace `main`, so two
-- of them cannot share one environment. They are reached through their `lean_exe` targets.

/-!
# BimodalTools - Tooling library root

Aggregator for the tooling half of this repository: formula enumeration, dataset generation
and labelling, JSON export, benchmark harnesses, and the trace-certificate exporter. None of
it is part of the published `FormalSystem` library, and `lake build` does not compile it --
this library is deliberately outside `defaultTargets`.

## Direction of dependence

`BimodalTools` imports `FormalSystem`; `FormalSystem` never imports `BimodalTools`. That
asymmetry is the point of the split and is enforced by check `B3` in
`scripts/check-module-invariants.sh`.

## What this file imports

Every tooling module that does NOT declare a root-namespace `main`. The executable roots
(`*Main`) are excluded by construction: each declares its own `main`, so importing two into
one environment fails with "environment already contains 'main'". They are reached through
their `lean_exe` targets instead.

## Building

```bash
lake build BimodalTools        # the whole tooling library
lake exe dataset_generator     # one executable root
```
-/
