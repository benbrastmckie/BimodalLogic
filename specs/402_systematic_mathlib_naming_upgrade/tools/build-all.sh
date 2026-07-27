#!/usr/bin/env bash
# Build EVERY target the package declares, not just the default one.
#
# `lake build` alone builds only `@[default_target] lean_lib FormalSystem`, whose glob is its
# root module's import closure.  Measured on this tree, that leaves 22 source files with no
# `.ilean` artifact at all -- including `Automation/ProofStepExport.lean`, which the plan names
# as load-bearing.  Those files are invisible to BOTH the resolved-reference rewriter and the
# build that is supposed to catch what the rewriter missed, so a rename would break them
# silently.  Building the test lib and all 12 `lean_exe` roots closes that gap.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"
exec lake build \
  FormalSystem BimodalTest \
  dataset_generator dataset_validator proof_extractor enum_benchmark \
  benchmark_anchors benchmark_oracle contrastive_generator tableau_bridge \
  tableau_proof_steps trace_exporter proof_first_generator machine_appendix \
  "$@"
