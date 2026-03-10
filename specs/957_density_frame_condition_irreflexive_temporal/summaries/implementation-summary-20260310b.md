# Implementation Summary: Task #957 (v2 attempt)

**Task**: 957 - density_frame_condition_irreflexive_temporal
**Plan**: implementation-002.md (Option C: Staged Case A Guarantee)
**Session**: sess_1773180949_938468
**Date**: 2026-03-10
**Status**: BLOCKED - Option C is not provable

## What Was Attempted

Implementation plan v2 proposed Option C: prove that the staged construction only produces
MCS pairs where Case A holds, then use the existing `density_frame_condition_caseA` for
all staged density needs.

## Phase 1: Analyze Staged Construction [COMPLETED]

Exhaustive analysis of the staged construction (StagedExecution.lean) and all supporting
modules to determine whether the "staged Case A guarantee" is provable.

### Files Analyzed
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` (976 lines)
- `Theories/Bimodal/Metalogic/StagedConstruction/WitnessSeedWrapper.lean` (241 lines)
- `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` (227 lines)
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` (423 lines)
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedTimeline.lean` (255 lines)
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` (192 lines)
- `specs/957_.../reports/research-002.md` (full report)

### Key Findings

1. **Option C is NOT provable.** The staged construction uses standard Lindenbaum extensions
   which give no control over G-formulas in the extension. Forward/density witnesses from
   parent p can contain G(delta) for arbitrary formulas delta, including those where
   G(delta) is also in p (Case B). Research-002 Finding 1's counterexample applies equally
   to staged construction pairs.

2. **The "GContent forcing" obstruction**: For any W with CanonicalR(M, W) (i.e., GContent(M)
   subseteq W), the seed GContent(M) can force G-formulas into W whose stripped versions
   are not in M'. Specifically, G(G(psi)) in M implies G(psi) in GContent(M) subseteq W,
   so G(psi) in W, so psi in GContent(W). But psi need not be in M' under irreflexive
   semantics (where G(psi) in M' does not imply psi in M'). This makes CanonicalR(W, M')
   fail.

3. **Controlled/Selective Lindenbaum (Option B) also has the same obstruction**: Attempting
   to filter out G(psi) with psi not in M' is inconsistent with the seed when G(psi) is
   already an element of GContent(M).

4. **The obstruction is fundamental to irreflexive semantics without the IRR rule**: Under
   reflexive semantics, G(psi) in M implies psi in M, so GContent(M) subseteq M and the
   issue vanishes. Under irreflexive semantics, this implication fails, creating the
   GContent forcing problem.

## Phase 2: Prove Staged Case A Lemma [BLOCKED]

Blocked by the mathematical obstruction identified in Phase 1. Option C is not provable.

## Why This Matters

The sorry in `density_frame_condition` (Case B, line 184 of DensityFrameCondition.lean)
blocks task 956 Phase 5 (`staged_timeline_densely_ordered`), which in turn blocks
Phases 6-8 of the D-from-syntax construction.

## Recommended Next Steps

In order of estimated feasibility:

### Option E: Bypass density via lexicographic product T x Q (RECOMMENDED)
- The task description forbids importing external dense linear orders, but research-035
  already identified this approach as viable via Mathlib's PSigma.Lex infrastructure
- If the constraint can be relaxed, this is by far the simplest path (50-100 lines)
- T does NOT need to be densely ordered; T x Q is densely ordered from Q's density

### Option D: Add the Gabbay IRR rule
- Add the rule `[(p AND H(neg p)) -> phi] / phi` (p fresh) to the proof system
- This enables density proofs under irreflexive semantics
- Risk: changes the logical foundation, affects all existing proofs
- Estimated: 200-400 lines (rule definition + integration)

### Option A: Full selective Lindenbaum with enumeration control
- Build MCS W step-by-step, choosing formulas to control GContent(W) subset M'
- Requires new infrastructure: enumeration-based Lindenbaum variant
- Estimated: 400-600 lines, high complexity
- May still fail if the consistency argument doesn't go through

### Option F: Accept the sorry and mark as known debt
- Use `density_frame_condition` (with sorry) in `staged_timeline_densely_ordered`
- Document as known proof debt
- Lowest effort but violates zero-debt requirement

## Artifacts

- `plans/implementation-002.md` - Updated with Phase 1 COMPLETED, Phase 2 BLOCKED
- `summaries/implementation-summary-20260310b.md` - This file

## Sorry Status

- Pre-existing: 1 sorry in `density_frame_condition` Case B (line 184)
- New: 0 (no code was written)
- Net change: 0
