/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.TableauBridge

/-!
# Tableau Bridge: the executable root

The root of `lake exe tableau_bridge`: `main`, and nothing else. The JSONL protocol, the
parsers, the branch gates and the REPL loop itself are `BimodalTools.TableauBridge` in
`BimodalTools/TableauBridge.lean`; read that module's docstring for the protocol.

The split exists because an executable root declares a root-namespace `main`, and two of those
cannot share one environment — so a test module could not import the bridge while the protocol
lived here. This mirrors the `ProofFirstGeneratorMain` / `ProofFirstGenerator` pair.
-/

/-- Main entry point for the `tableau_bridge` REPL. Ignores command-line arguments. -/
def main (_args : List String) : IO Unit :=
  BimodalTools.TableauBridge.replLoop
