# Code Review Report: D=CanonicalMCS Architecture

**Date**: 2026-03-23
**Scope**: D=CanonicalMCS pattern elimination
**Focus**: Survey remaining work to fix architecture
**Reviewed by**: Claude

## Executive Summary

The D=CanonicalMCS pattern is **load-bearing and cannot be simply removed**. The correct strategy is **coexistence**: keep D=CanonicalMCS for proof-theoretic purposes while building a proper D=Int path. Current status:

| Path | Status | Blockers |
|------|--------|----------|
| D=CanonicalMCS (CanonicalFMCS.lean) | Sorry-free | None (working) |
| D=Int (SuccChainFMCS.lean) | Blocked | 2 sorries (f/p_nesting_is_bounded) |
| DovetailedTimelineQuot | Archived | In Boneyard |

**Key Finding**: Since the research was done, DovetailedTimelineQuot has been archived to Boneyard. The D=Int path via SuccChain is now the primary alternative, blocked on Task 48.

## Current Architecture

### Files Using D=CanonicalMCS Pattern (Active Code)

| File | Lines | Usage | Status |
|------|-------|-------|--------|
| `CanonicalFMCS.lean` | 346 | Primary definition, existence theorem | **Keep** (sorry-free, load-bearing) |
| `ModallyCoherentBFMCS.lean` | 285 | Modal coherence proofs | **Keep** |
| `SaturatedBFMCSConstruction.lean` | 175 | Saturation proofs | **Keep** |
| `FMCSTransfer.lean` | 400 | Domain transfer mechanism | **Keep** (enables D=Int) |
| `MultiFamilyBFMCS.lean` | 633 | Mixed: live + dead code | **Partial archive** |

### Dead Code to Archive

From `MultiFamilyBFMCS.lean`:
- Lines 213-289: `singletonCanonicalBFMCS` (marked DEAD END)
- Lines 531-572: `canonical_modal_backward` (marked DEAD END)

Header clearly documents: "**STATUS**: DEAD END - W=D CONFLATION"

### Sorries Blocking D=Int Path

| File | Line | Theorem | Status |
|------|------|---------|--------|
| `SuccChainFMCS.lean` | 735 | `f_nesting_is_bounded` | BLOCKED (mathematically false for arbitrary MCS) |
| `SuccChainFMCS.lean` | 970 | `p_nesting_is_bounded` | BLOCKED (mathematically false for arbitrary MCS) |

Both have migration paths to `*_restricted` variants requiring `RestrictedMCS` evidence.

## Dependency Chain

```
Task 48 (implementing, blocked)
    │   Prove succ_chain_fam MCS have bounded F-depth
    │   Status: Augmented closure approach partial (phases 0-3 done)
    │   Blocker: Architectural tension in RestrictedMCS chain construction
    │
    ├── Task 36 (blocked on 48)
    │       Prove f_nesting_boundary axiom
    │
    └── Task 37 (blocked on 36)
            Prove p_nesting_boundary axiom
```

## What Remains for Task 41

### Immediate Actions (No Dependencies)

1. **Archive Dead Code** (1-2 hours)
   - Move `MultiFamilyBFMCS.singletonCanonicalBFMCS` to Boneyard
   - Move `MultiFamilyBFMCS.canonical_modal_backward` to Boneyard
   - Update file header to reflect remaining active code

2. **Documentation Clarification** (1 hour)
   - Add "Architectural Intent" sections to CanonicalFMCS.lean and FMCSDef.lean
   - Clarify D=CanonicalMCS is proof-theoretic, not semantic
   - Document that DovetailedTimelineQuot is archived, SuccChain is the path forward

### Deferred Actions (Blocked on Task 48)

1. **FMCSTransfer Instantiation for D=Int** (requires sorry-free f_nesting_boundary)
   - Create embed/retract pair: CanonicalMCS ↔ Int chain indices
   - Prove `transferredFMCS Int` satisfies FMCS constraints

2. **D=Int Completeness Path**
   - Use `FMCSTransfer.transferredFMCS` with SuccChain MCSes
   - Requires Task 48/36/37 completion

## Architectural Decision: Coexistence Model

The research correctly identified that D=CanonicalMCS **must be kept** alongside any proper D replacement:

**Why D=CanonicalMCS Works**:
- Every Lindenbaum-produced witness MCS is automatically in the domain
- No reachability or chain membership proofs needed
- `temporal_coherent_family_exists_CanonicalMCS` is sorry-free

**Why It's Problematic**:
- Trivializes F/P witness obligations
- Semantically degenerate (no temporal structure)
- Conflates world type with timeline type

**Resolution**:
- Keep D=CanonicalMCS for TruthLemma proofs
- Build D=Int path via SuccChainFMCS for semantic completeness
- Bridge via `FMCSTransfer.transferredFMCS`

## Task 41 Scope Recommendation

Given the analysis, Task 41 should be split:

1. **Task 41A: Archive Dead Code** (immediate, no dependencies)
   - Archive MultiFamilyBFMCS dead-end code
   - Update documentation

2. **Task 41B: D=Int Path** (deferred to after Task 48)
   - FMCSTransfer instantiation
   - Completeness path via SuccChain

## Metrics

| Metric | Value |
|--------|-------|
| Files using D=CanonicalMCS | 5 active |
| Dead code functions | 2 (in MultiFamilyBFMCS) |
| Blocking sorries | 2 (f/p_nesting_is_bounded) |
| Axioms remaining | 2 (f/p_nesting_boundary) |
| Task 48 phase progress | 3/7 phases |

## Recommendations

1. **Do not block on Task 41** - The immediate work (archive dead code, update docs) is low-value compared to completing Task 48

2. **Focus on Task 48** - Completing the augmented closure approach unblocks the entire axiom elimination chain (48 → 36 → 37 → D=Int)

3. **Update Task 41 status to PLANNED** (already done) with note that it depends on Task 48 for the substantive work

4. **Archive MultiFamilyBFMCS dead code** as a quick win (can be done independently)
