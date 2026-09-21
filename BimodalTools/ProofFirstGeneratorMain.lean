/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.ProofFirstGenerator

/-!
# Proof-First Exporter: the executable root

The root of `lake exe proof_first_generator`: `main`, and nothing else. The pipeline itself is
`BimodalTools.runProofFirstGenerator` in `BimodalTools/ProofFirstGenerator.lean`.

The split exists because an executable root declares a root-namespace `main`, and two of those
cannot share one environment. This mirrors the `DatasetGeneratorMain` / `DatasetGenerator` pair.
-/

/-- Main entry point for the proof-first generator CLI. -/
def main (args : List String) : IO Unit :=
  BimodalTools.runProofFirstGenerator args
