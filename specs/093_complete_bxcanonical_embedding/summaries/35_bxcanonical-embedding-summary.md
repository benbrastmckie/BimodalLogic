# Implementation Summary: Task #93 (v35 - BX12 Reduction)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [BLOCKED]
- **Started**: 2026-04-17
- **Completed**: 2026-04-17
- **Effort**: ~3 hours (deep mathematical analysis)
- **Dependencies**: None
- **Artifacts**: plans/35_bxcanonical-embedding.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, summary-format.md

## Overview

Attempted to close the 8 remaining sorry sites in RootScopedChain.lean using the BX12 reduction strategy from Plan v35. Deep mathematical analysis revealed that the approach is blocked by a fundamental open problem: the Lindenbaum extension freedom in the chain construction prevents proving both the Until/Since step transfer property (needed for backward coherence) and the F-obligation eventual resolution (needed for forward coherence). This obstruction affects all three sorry targets (restricted_tc, restricted_buc, restricted_fuc) required by dd_countermodel.

## What Changed

- No code changes to Lean files. The mathematical analysis confirmed the approach cannot be executed with the current chain construction.
- Plan Phase 1 status updated to [BLOCKED].

## Decisions

- **Backward Until/Since coherence (sorry 1522)** requires a "step transfer" property: `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)`. Analysis showed this requires `phi AND F(phi U psi) -> phi U psi`, which is NOT derivable from the BX axiom system. The F_obligation_backward lemma gives `F(phi U psi) in chain(r)`, but `F(alpha) -> alpha` is not a theorem of BX (it would assert every future eventuality holds now). The Boneyard (UntilSinceCoherence.lean, line 27) explicitly documents this: "This step is NOT derivable from the bare FMCS structure (forward_G, backward_H)."
- **Forward Until/Since coherence (sorry 1527)** reduces to the same forward_F perpetual deferral problem: at each resolving step of the enriched chain, the BX11 fold may resolve a DIFFERENT formula than the target, leaving the target perpetually deferred. The BX12 reduction (`F(psi) -> top U psi`) converts forward_F to forward Until coherence, but both require eventual formula resolution in the chain.
- **Temporal coherence (sorry 1517)** was planned to derive from Until/Since coherence via BX12 bridge, so it is blocked by the above.
- The Boneyard completeness proofs (StrictSemanticsLegacy/FrameConditions/Completeness.lean) also have sorry for both backward Until step transfer (line 386) and forward Until coherence (line 393, 498), confirming this is a codebase-wide open problem.

## Impacts

- Plan v35 is blocked at Phase 1. The BX12 reduction strategy is mathematically sound (F(psi) <-> top U psi is provable), but it reduces the problem to Until/Since coherence which has the same difficulty as direct forward_F/backward_P.
- All viable resolution paths require a fundamentally different chain construction:
  1. **Quasimodel bridge** (~800-1200 new LOC): Build a HintikkaStepOracle for Until/Since defects using the quasimodel infrastructure (2132 LOC, sorry-free). This provides finite-witness proofs via defect-count decrease.
  2. **Enriched Until-aware seed**: Modify the chain to include `{phi U psi | phi U psi in M AND psi not in M}` in every seed, forcing Until persistence through chain steps. Requires new consistency arguments.
  3. **Finite deferral pigeonhole**: Use the finite subformula closure to argue that the chain's restricted theory takes finitely many values, and a cycle with unresolved Until contradicts BX axioms. The Boneyard FiniteDeferral.lean has partial progress (steps 1-4 of 5, sorry at the cycle contradiction step).

## Follow-ups

- **Highest priority**: Investigate the quasimodel bridge approach. The quasimodel infrastructure in `Quasimodel/Construction.lean` already provides Until/Since MCS-level lemmas (until_elim_mcs, refl_intro_until_mcs, etc.). The realization phase (Realization.lean) would need to lift these to chain-level coherence.
- **Alternative**: Extend the enriched seed approach. If the seed at each chain step includes Until content (`phi U psi` when `F(phi U psi)` is present AND `phi` is present), the Lindenbaum extension would be forced to include `phi U psi`, giving the step transfer.

## References

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (sorry sites at 1413, 1457, 1464, 1517, 1522, 1527, 2196, 2289)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (backward_until_from_step with step transfer parameter)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (restricted coherence definitions)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` (BX12 F_imp_top_until_mcs)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` (until_F_expansion, until_intro)
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean` (sorry at backward/forward Until)
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` (partial finite deferral argument)
- `specs/093_complete_bxcanonical_embedding/plans/35_bxcanonical-embedding.md`
