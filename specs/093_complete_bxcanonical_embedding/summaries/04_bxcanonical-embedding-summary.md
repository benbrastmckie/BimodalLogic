# Implementation Summary: Task #93 — Close BXCanonical Temporal Coherence Sorries

**Completed**: 2026-04-13
**Mode**: Team Implementation (2 max concurrent teammates)
**Status**: PARTIAL — infrastructure restructured, core coherence proofs remain sorry'd

## What Was Accomplished

### Phase 1: Restricted Truth Lemma [COMPLETED]

Created `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (~370 lines):
- `restricted_parametric_shifted_truth_lemma`: Truth lemma accepting `restricted_temporally_coherent root` instead of full `temporally_coherent`. Uses `restricted_temporal_backward_G`/`restricted_temporal_backward_H` for G/H backward cases.
- `fully_restricted_parametric_shifted_truth_lemma`: Further restricted version accepting restricted buc/fuc as well.
- `restricted_parametric_representation_from_neg_membership` and `fully_restricted_parametric_representation_from_neg_membership`: Representation theorems using the restricted truth lemmas.
- Zero sorry in this file.

### Phase 4: Wire Restricted Infrastructure [COMPLETED]

Updated `bx_countermodel` in CanonicalModel.lean to use `fully_restricted_parametric_representation_from_neg_membership` with `root = φ` (the formula being disproved). The old unrestricted forward_F/backward_P/buc/fuc/tc are now dead code.

Added to `TemporalCoherence.lean`:
- `BFMCS.restricted_backward_until_since_coherent` definition
- Implication theorem from full backward coherence

### Phases 2-3: Chain Modification + Coherence Proofs [BLOCKED]

All 4 original sorries are architecturally blocked by a fundamental circularity:
- **forward_F** requires F(ψ) to persist through resolving steps, but `forward_temporal_witness_seed` only includes `{ψ} ∪ g_content(M)`, not `f_carry(M)`. Adding f_carry to the resolving seed is not provably consistent (ψ may conflict with F-formulas).
- **backward_G** (needed for the truth lemma) requires forward_F via contraposition.
- **buc step transfer** requires `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`, which has no backward propagation mechanism for Until formulas through Lindenbaum extensions.
- **fuc** depends on forward_F via BX10 (`(φ U ψ) → F(ψ)`).

The enriched seed approach (Plan C: `{ψ} ∪ g_content(M) ∪ deferralDisjunctions(M)`) was investigated and rejected — `deferralDisjunctions` elements lack G-preimages in M, breaking the temporal K consistency argument.

## Active-Path Sorry Inventory

| Sorry | Status | Notes |
|-------|--------|-------|
| `bx_bfmcs_restricted_tc` | Active | Delegates to dead-code forward_F/backward_P |
| `bx_bfmcs_restricted_buc` | Active | Direct sorry, needs step transfer |
| `bx_bfmcs_restricted_fuc` | Active | Direct sorry, needs forward_F |
| `bx_fmcs_forward_F` | Dead code | Only used by unrestricted tc |
| `bx_fmcs_backward_P` | Dead code | Only used by unrestricted tc |
| `bx_bfmcs_buc` | Dead code | Old unrestricted version |
| `bx_bfmcs_fuc` | Dead code | Old unrestricted version |

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` — **New file** (~370 lines): restricted + fully restricted truth lemma and representation theorems
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — Added `restricted_backward_until_since_coherent` definition + implication
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — Added restricted coherence theorems, rewired `bx_countermodel` to use fully restricted infrastructure

## Recommended Next Steps

1. **Biased Lindenbaum** (~150 lines): Build `biased_set_lindenbaum` that preferentially includes F-formulas from a bias set. If F(ψ) is consistent with the seed, include it. This directly solves the forward_F persistence problem.

2. **Alternative chain architecture**: Replace the dovetailed chain with a construction where each F-obligation gets a fresh witness (quasimodel-style), avoiding the Lindenbaum extension freedom problem entirely.

3. **Accept partial completeness**: The current state provides a completeness theorem modulo 3 finitely-scoped coherence conditions. These could be axiomatized as additional hypotheses if full proof is deferred.

## Verification

- `lake build` succeeds (0 errors, 948 jobs)
- No regressions in existing proofs
- `bx_completeness` compiles and type-checks (depends transitively on 3 active sorries)
