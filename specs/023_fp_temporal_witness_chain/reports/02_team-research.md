# Team Research Report: Task #23

**Task**: F/P temporal witness chain construction
**Date**: 2026-03-21
**Mode**: Team Research (2 teammates)
**Session**: sess_1774124405_87b663

## Summary

Both research angles converged on a key insight: **the "mathematical impossibility" conclusion from the first research is correct for LINEAR LINDENBAUM chains, but a Succ-based approach bypasses this limitation entirely.**

The codebase already has significant infrastructure for this bypass path, with only **3 axioms remaining** in `SuccExistence.lean` to complete it.

## Key Findings

### 1. The Problem is Construction, Not Theory

The `bounded_witness` theorem in `CanonicalTaskRelation.lean` is **PROVEN**:
- If `F^n(phi) in u` but `F^{n+1}(phi) not in u`, and `CanonicalTask_forward_MCS u n v` (n Succ steps), then `phi in v`

The mathematical foundation exists. The sorries arise because IntBFMCS uses **generic Lindenbaum extension** which can introduce `G(~phi)`, killing `F(phi) = ~G(~phi)` before its witness step.

### 2. Succ Relation is the Key

The **Succ relation** (from `SuccRelation.lean`) adds a critical condition beyond CanonicalR:

| Condition | CanonicalR | Succ |
|-----------|------------|------|
| G-persistence | `g_content u <= v` | `g_content u <= v` |
| F-step | (none) | `f_content u <= v union f_content v` |

The F-step condition ensures F-obligations are **tracked and resolved**, preventing silent killing.

### 3. Bypass Path is Partially Implemented

**Infrastructure complete**:
- `SuccRelation.lean` - Succ definition, single_step_forcing theorem
- `CanonicalTaskRelation.lean` - CanonicalTask, bounded_witness theorem
- `SuccExistence.lean` - Succ successor construction (mostly complete)

**Three axioms remain** (all in `SuccExistence.lean`):
1. `successor_deferral_seed_consistent_axiom` (line 266)
2. `predecessor_deferral_seed_consistent_axiom` (line 311)
3. `predecessor_f_step_axiom` (line 516)

### 4. CanonicalFMCS Works Because Domain = All MCSes

`canonicalMCS_forward_F` is **sorry-free** because:
- `canonical_forward_F` gives witness MCS W
- W is automatically in CanonicalMCS domain (all MCSes are included)
- No chain membership check needed

IntBFMCS fails because witnesses may not be in the linear chain.

## Synthesis

### Conflicts Resolved

No major conflicts. Both teammates reached the same core conclusions from different angles:
- Teammate A: Mathematical analysis of CanonicalTask and constrained construction
- Teammate B: Structural comparison and codebase analysis

Both identified the Succ-based approach as viable.

### Gaps Identified

1. **Effort for 3 axioms**: Unknown complexity for proving the remaining axioms
2. **Int-indexed TaskFrame construction**: How to build `TaskFrame Int` from Succ chains (vs `TaskFrame CanonicalMCS`)
3. **AddCommGroup requirement**: CanonicalMCS lacks `AddCommGroup` needed for algebraic completeness

### Recommendations

**Option A (Recommended): Complete Succ-based path**
1. Prove the 3 remaining axioms in `SuccExistence.lean`
2. Build Int-indexed chain using Succ-successor construction (not Lindenbaum)
3. Apply bounded_witness theorem for F/P coherence

**Option B: Accept documented limitation**
1. Mark IntBFMCS sorries as fundamental mathematical blockers
2. Route Int-indexed needs through CanonicalMCS infrastructure
3. The sorries represent impossibility, not incomplete work

**Option C: Hybrid approach**
1. Use CanonicalFMCS for F/P properties (already sorry-free)
2. Build Int-indexed wrapper that delegates F/P to CanonicalFMCS
3. Accept that direct Int-indexed F/P proofs require Succ constraints

## Technical Details

### The Single-Step Forcing Theorem

From `SuccRelation.lean`:
```
If F(phi) in u, FF(phi) not in u, and Succ(u, v), then phi in v.
```

This bounds the witness distance: if `F(phi)` has nesting depth 1, the witness is at the next Succ step.

### Bounded Witness Corollary

From `CanonicalTaskRelation.lean`:
```
If F^n(phi) in u, F^{n+1}(phi) not in u, and n Succ steps to v, then phi in v.
```

F-nesting depth bounds the maximum witness distance.

### Why Constrained Construction Works

Instead of generic Lindenbaum extension at each step:
1. Build position t+1 as a **Succ successor** of position t
2. The F-step condition ensures F-obligations are tracked
3. The single-step forcing theorem guarantees eventual witnessing
4. Nesting depth decreases at each step (or formula is witnessed)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | CanonicalTask mathematical analysis | completed | medium-high |
| B | IntBFMCS vs CanonicalFMCS structure | completed | high |

## Files Referenced

### Core Infrastructure
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - Succ definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - CanonicalTask
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - 3 remaining axioms
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - Sorry-free model

### Problem Files
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - 4 sorries

### Historical Context
- `specs/006_canonical_taskframe_completeness/reports/17-20` - Three-place relation design

## Next Steps

1. **Analyze the 3 axioms**: Determine complexity and dependencies
2. **Consider task 22 findings**: The DirectMultiFamilyBFMCS approach may provide insights
3. **Evaluate Option A vs B**: Based on axiom analysis, decide path forward
4. **Update task description**: Reflect new understanding that this is NOT impossible, just requires Succ-based construction
