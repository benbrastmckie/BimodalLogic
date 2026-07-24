/-!
# Axiom Names - Canonical 42-Constructor Name List

The canonical list of all `Bimodal.ProofSystem.Axiom` constructor names, in
`Axioms.lean` source order.

Extracted from `BenchmarkAnchors.lean` into a leaf module so that
multiple executables can share it: `BenchmarkAnchors.lean` declares a
root-level `main` (it is a `lean_exe` root), so importing it from another
executable module would clash on `main`. Both `BenchmarkAnchors.lean` and
`MachineAppendixExport.lean` import this module and check their coverage
against `allAxiomNames`.

## Maintenance

When a constructor is added to (or removed from) `inductive Axiom` in
`ProofSystem/Axioms.lean`, this list MUST be updated in the same change.
The mismatch is caught mechanically:
- `lake exe machine_appendix` fails its coverage assertion, and
- `scripts/typst-sync-check.sh` Check 3 recomputes the constructor count from
  live source and compares it against the shipped machine appendix.
-/

namespace Bimodal.Automation

/-- All 42 axiom constructor names, in `Axioms.lean` source order. -/
def allAxiomNames : List String :=
  [ "prop_k", "prop_s", "ex_falso", "peirce"
  , "modal_t", "modal_4", "modal_b", "modal_5_collapse", "modal_k_dist"
  , "serial_future", "serial_past"
  , "left_mono_until_G", "left_mono_since_H"
  , "right_mono_until", "right_mono_since"
  , "connect_future", "connect_past"
  , "enrichment_until", "enrichment_since"
  , "self_accum_until", "self_accum_since"
  , "absorb_until", "absorb_since"
  , "linear_until", "linear_since"
  , "until_F", "since_P"
  , "temp_linearity", "temp_linearity_past"
  , "F_until_equiv", "P_since_equiv"
  , "modal_future"
  , "discrete_symm_fwd", "discrete_symm_bwd"
  , "discrete_propagate_fwd", "discrete_propagate_bwd"
  , "discrete_box_necessity"
  , "prior_UZ", "prior_SZ"
  , "z1"
  , "density", "dense_indicator"
  ]

end Bimodal.Automation
