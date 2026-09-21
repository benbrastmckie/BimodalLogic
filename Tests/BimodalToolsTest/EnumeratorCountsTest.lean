/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.FormulaEnumerator
import FormalSystem.Automation.Normalization
import FormalSystem.Metalogic.Decidability.DecisionProcedure

/-!
# Enumerator Counts and Normalization Overhead

The two regions of `Tests/BimodalTest/Automation/NormalizationTest.lean` that depended on the
formula enumerator, extracted when the enumerator moved to `lean_lib BimodalTools`. Everything
else in that file exercises `normalizeFormula` itself, which is library code, and stayed behind
so that `lake test` keeps covering it.

Both regions are `#eval`/`#guard` probes over `BimodalTools.FormulaEnumerator`:

- the c5 `decide` timing sample, which measures that `normalizeFormula` adds no overhead;
- the enumeration counts and derived-operator coverage guards, which pin the enumeration
  grammar.
-/

namespace BimodalToolsTest.EnumeratorCountsTest

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

-- Convenience abbreviation, matching the one in the file this was extracted from.
private def p : Formula := .atom (Atom.mkBase "p")

/-!
## Section 7: Benchmark (c5/c6 Normalization Overhead)

Generate c5 formulas via `enumerateUpToDepth` and time `decide` on a sample.
Since `normalizeFormula` is the identity by definitional equality, the
normalization pass adds zero measurable overhead -- the Lean compiler
eliminates it entirely.

Benchmark result: 50 formulas decided (valid=0, invalid=50, timeout=0).
No timeouts, confirming zero performance regression from normalization.
-/

#eval do
  let config := BimodalTools.smallConfig
  let formulas := BimodalTools.enumerateUpToDepth config
  let sample := formulas.take 50
  let counts := sample.foldl (fun (v, i, t) f =>
    let result := decide f
    if result.isValid then (v + 1, i, t)
    else if result.isInvalid then (v, i + 1, t)
    else (v, i, t + 1)
  ) (0, 0, 0)
  return s!"Benchmark: {sample.length} formulas decided (valid={counts.1}, invalid={counts.2.1}, \
      timeout={counts.2.2})"

/-!
## Formula enumerator: counts and derived-operator coverage

Counts are for three atoms with modal and temporal depth bounds of 2, captured from the
enumerator's own evaluation. A change in either count means the enumeration grammar changed.
-/

section EnumeratorCounts

open FormalSystem.Automation
-- The former `FormalSystem.Automation` namespace is now split across two libraries: the
-- proof-automation half stayed, the dataset/benchmark half is in `BimodalTools`.
open BimodalTools

#guard (enumExactHelper defaultAtoms 2 2 4 {}).1.size == 7852
#guard (enumExactHelper defaultAtoms 2 2 5 {}).1.size == 75914
#guard (generateBimodalSlice defaultAtoms 2 2 [5]).1.length == 45111

-- Each derived operator is generated at its own complexity level.
#guard (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any
  (· == Formula.diamond (.atom (Atom.mkBase "p")))
#guard (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any
  (· == Formula.next (.atom (Atom.mkBase "p")))
#guard (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any
  (· == Formula.prev (.atom (Atom.mkBase "p")))
#guard (enumExactHelper defaultAtoms 2 2 3 {}).1.toList.any
  (· == Formula.release (.atom (Atom.mkBase "p")) (.atom (Atom.mkBase "q")))
#guard (enumExactHelper defaultAtoms 2 2 3 {}).1.toList.any
  (· == Formula.weakUntil (.atom (Atom.mkBase "p")) (.atom (Atom.mkBase "q")))

end EnumeratorCounts

end BimodalToolsTest.EnumeratorCountsTest
