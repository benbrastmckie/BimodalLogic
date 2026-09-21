/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalToolsTest.C5SmokeTest
import BimodalToolsTest.DatasetGeneratorTest
import BimodalToolsTest.InterestingnessTest
import BimodalToolsTest.TraceCertificateTest
import BimodalToolsTest.TraceExportTest
import BimodalToolsTest.TraceExporterE2ETest
import BimodalToolsTest.EnumeratorCountsTest
-- `FormulaMutatorTest` and `ProofFirstTests` are deliberately absent. Each pulls in an
-- executable root that declares a root-namespace `main`, colliding with the `main` this
-- environment already carries from `C5SmokeTest`'s `BimodalTools.DatasetValidatorMain`. Both
-- are listed in `scripts/module-invariants-manifest.txt`, where check `C6` compile-checks them
-- in isolation, so neither can rot unseen. This is the same exclusion, for the same reason,
-- that `Tests/BimodalTest.lean` carried for them before the split.

/-!
# BimodalToolsTest - Tooling test library root

Aggregator for the tests of `BimodalTools`. It is the counterpart of
`Tests/BimodalTest.lean`, which covers the published `FormalSystem` library only.

The split follows the library split: a test that exercises dataset generation, JSON export
or a benchmark harness belongs here, and a test that exercises the logic itself belongs in
`BimodalTest`. A test that straddles the two is divided rather than moved wholesale, so the
library's own coverage stays inside `lake test`.

## Building

```bash
lake build BimodalToolsTest
```

`lake test` runs `BimodalTest` only (it is the package's `testDriver`); this library is built
by its own CI step.
-/
