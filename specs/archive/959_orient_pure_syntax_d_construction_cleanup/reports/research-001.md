# Research Report: Task #959 - Orientation for Pure-Syntax D Construction Cleanup

**Task**: 959 - orient_pure_syntax_d_construction_cleanup
**Started**: 2026-03-11T00:00:00Z
**Completed**: 2026-03-11T01:00:00Z
**Effort**: Comprehensive audit of Int/Rat-tainted files, StagedConstruction sorry analysis, Task 958 resolution
**Dependencies**: Task 956 (active), Task 958 (closable)
**Sources/Inputs**: Codebase audit (Metalogic/, StagedConstruction/), research-009.md (Task 958), implementation-015.md (Task 956 plan)
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Three Int/Rat-tainted files** (DovetailingChain.lean, TemporalCoherentConstruction.lean, Representation.lean) are confirmed as Int-specialized and violate the pure-syntax constraint. However, they CANNOT be archived yet because StagedExecution.lean transitively imports TemporalCoherentConstruction.lean.
- **Task 958 can be closed**: `canonicalR_irreflexive` is confirmed completely unused (no imports, no references outside its own file). The 2 sorries are self-contained and do not affect the completeness chain.
- **CantorApplication.lean has 3 sorries** (NoMaxOrder, NoMinOrder, DenselyOrdered on TimelineQuot). All three share the SAME root cause: existing DenseTimeline lemmas provide CanonicalR-witnesses but not STRICTLY ordered witnesses in the antisymmetrized quotient. This is the critical blocker for Phases 6-8.
- **ConstructiveFragment.lean has 2 sorries** with the identical strictness-in-quotient problem, confirming this is a fundamental gap.
- The StagedConstruction chain (Phases 0-5) is otherwise sorry-free. The path to completing Phases 6-8 requires resolving the quotient strictness gap.

## Context & Scope

### Task Purpose

This orientation task audits the D-from-syntax construction state to provide:
1. Clear Int/Rat contamination assessment and archive plan
2. Task 958 resolution rationale
3. Phase 6-8 roadmap with identified blockers
4. Actionable next steps for Task 956 completion

## Findings

### Finding 1: Int/Rat-Tainted File Audit

**DovetailingChain.lean**: Builds `FMCS Int` using dovetailing construction over integer-indexed time. Contains 2 sorries (forward_F, backward_P). Uses `Int` as the domain type D throughout (dovetailIndex: Nat -> Int, dovetailRank: Int -> Nat). This file is NOT imported by the StagedConstruction chain.

**TemporalCoherentConstruction.lean**: Provides `fully_saturated_bfmcs_exists_int` (1 sorry) and `construct_saturated_bfmcs_int` -- both specialized to `D = Int`. Also has a generic-D sorry-backed version (1 sorry). The file IS imported by StagedExecution.lean (line 2).

**Representation.lean**: Builds `TaskFrame Int`, `TaskModel`, `canonicalHistory`, and standard completeness theorems all specialized to `D = Int`. Contains 0 direct sorries but inherits sorry from `construct_saturated_bfmcs_int`. NOT imported by StagedConstruction.

**Archive Assessment**:
| File | Can Archive Now? | Reason |
|------|-----------------|--------|
| DovetailingChain.lean | YES | Not imported by StagedConstruction or any other active file |
| TemporalCoherentConstruction.lean | NO | Imported by StagedExecution.lean (possibly for transitive definitions) |
| Representation.lean | NO (but not blocking) | Active completeness theorems; will be superseded by Phase 8 TaskFrameFromSyntax.lean |

**Import chain analysis for StagedExecution.lean**:
- Line 2: `import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction`
- Line 3: `import Bimodal.Metalogic.Completeness`

StagedExecution uses `theorem_in_mcs`, `set_mcs_*`, `CanonicalR`, `SetMaximalConsistent`, `temp_linearity_derivation`, `canonical_forward_reachable_linear` -- all from Core/Bundle modules. The TemporalCoherentConstruction import may be pulling in needed transitive definitions (ModalSaturation, WitnessSeed, etc.). Before archiving, the import dependency must be refactored to import only what is actually needed.

### Finding 2: Task 958 Resolution -- canonicalR_irreflexive Is Unused

Confirmed via exhaustive codebase search (per research-009.md):

```
grep -r "import.*CanonicalIrreflexivity" Theories/ -> NO MATCHES
grep -r "canonicalR_irreflexive" Theories/ -> ONLY in CanonicalIrreflexivity.lean
grep -r "import.*DirectIrreflexivity" Theories/ -> NO MATCHES
```

The completeness chain flows through Representation.lean <- TemporalCoherentConstruction.lean <- DovetailingChain.lean. CanonicalIrreflexivity.lean is a dead-end file never integrated.

**Resolution**: Task 958 should be marked [PARTIAL] with documentation that the theorem is unused and the mathematical gap (String atom global freshness impossibility) is well-understood. The 2 sorries should NOT be counted in the completeness chain sorry inventory.

### Finding 3: CantorApplication.lean -- The Quotient Strictness Gap

The 3 sorries in CantorApplication.lean are:

**1. NoMaxOrder (line 110-135)**: Given point p in the quotient, need q with [p] < [q]. The existing `dense_timeline_has_future` gives q with `CanonicalR(p.mcs, q.mcs)`, but this does NOT guarantee `NOT CanonicalR(q.mcs, p.mcs)`. If both directions hold, [p] = [q] in the antisymmetrization quotient.

**2. NoMinOrder (line 138-143)**: Symmetric problem -- need strict predecessor.

**3. DenselyOrdered (line 146-149)**: Given [a] < [b] in quotient, need [c] with [a] < [c] < [c]. The existing `dense_timeline_has_intermediate` already requires `NOT CanonicalR(b.mcs, a.mcs)` as a precondition, so it does provide an intermediate c with `CanonicalR(a.mcs, c.mcs)` and `CanonicalR(c.mcs, b.mcs)`. BUT it does not guarantee that c is STRICTLY between a and b in the quotient (i.e., `NOT CanonicalR(c.mcs, a.mcs)` and `NOT CanonicalR(b.mcs, c.mcs)` are not established).

**Root cause**: The density_frame_condition (DensityFrameCondition.lean) gives an intermediate W with CanonicalR(M, W) AND CanonicalR(W, M'), but does NOT guarantee strictness of W relative to M or M'. In Case B1 (M' reflexive), W = M' itself, so W is not strictly between.

**Note**: ConstructiveFragment.lean has the identical problem (NoMaxOrder/NoMinOrder sorries at lines 579/584), confirming this is a systematic gap across both the ConstructiveQuotient and TimelineQuot approaches.

### Finding 4: What the Implementation Plan v015 Says About This

Implementation plan v015 (Task 956) identifies this gap at Phase 5b (Strictness lemma) and proposes:
- Analyze Case B1 (M' reflexive) as special case
- Prove `density_frame_condition_strict` for the non-reflexive case
- For Case B1: use "double-density trick" to find non-reflexive intermediate
- Alternative: prove between any StagedPoint.lt pair, at least one non-reflexive intermediate exists

Phase 5 is listed as [COMPLETED] in the plan but CantorApplication still has 3 sorries, suggesting Phase 5 was completed for the DenseTimeline prerequisites (countable, has_future, has_past, has_intermediate, nonempty) but the QUOTIENT-LEVEL strictness was deferred to Phase 6.

### Finding 5: Dependency Chain for Phases 6-8

The dependency chain is:

```
Phase 6 (CantorApplication.lean) -- BLOCKED on quotient strictness
  depends on: Phase 5 (DenseTimeline) -- COMPLETED (sorry-free)
  requires: NoMaxOrder, NoMinOrder, DenselyOrdered on TimelineQuot
  resolves: cantor_iso : Nonempty (TimelineQuot ≃o Q)

Phase 7 (DFromSyntax.lean) -- NOT STARTED
  depends on: Phase 6
  defines: D = Q, task_rel from Cantor isomorphism

Phase 8 (TaskFrameFromSyntax.lean) -- NOT STARTED
  depends on: Phase 7
  constructs: TaskFrame D, proves completeness
```

The Q (rational) type only appears as the TARGET of the Cantor isomorphism in CantorApplication.lean. The StagedConstruction chain itself is D-free -- it works with StagedPoint and CanonicalR, deriving ordering from syntax. This is architecturally correct for the pure-syntax constraint.

### Finding 6: Sorry Inventory Summary

| File | Sorries | On D-from-syntax path? | Nature |
|------|---------|----------------------|--------|
| CantorApplication.lean | 3 | YES (Phase 6) | Quotient strictness gap |
| ConstructiveFragment.lean | 2 | NO (alternative approach) | Same quotient strictness gap |
| TemporalCoherentConstruction.lean | 2 | NO (Int path) | Temporal+modal saturation combination |
| DovetailingChain.lean | 2 | NO (Int path) | forward_F, backward_P witness construction |
| CanonicalIrreflexivity.lean | 2 | NO (dead-end) | Naming argument impossibility |

**Total active sorries**: 9 (+ 2 CanonicalIrreflexivity = 11)
**Sorries on D-from-syntax critical path**: 3 (all in CantorApplication.lean)
**Sorries in Int-tainted files**: 4 (2 DovetailingChain + 2 TemporalCoherentConstruction)

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | HIGH | Confirms DovetailingChain/Representation are superseded |
| Product domains (D = Int x Q, etc.) | NONE | Already forbidden |
| ConstructiveQuotient approach | MEDIUM | Has same strictness gap as TimelineQuot |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | Phases 0-5 complete, 6-8 blocked on strictness |
| Pure Syntax Constraint | ACTIVE | StagedConstruction is D-free; only CantorApplication references Q |
| Irreflexive G/H Semantics | ACTIVE | Uses strict < ordering; Preorder provides this for free |

## Recommendations

### Recommendation 1: Resolve Quotient Strictness Gap (Priority: CRITICAL)

The single most important blocker is proving that the DenseTimeline witnesses are STRICT in the antisymmetrized quotient. Three sub-strategies:

**Strategy A: Prove CanonicalR is globally irreflexive**
If NO MCS M has CanonicalR(M, M), then all CanonicalR witnesses are automatically strict. But Task 958 showed this is unprovable with the current String-atom formalization. SKIP.

**Strategy B: Prove witnesses are distinct from their sources**
Show that `dense_timeline_has_future` returns q with q.mcs != p.mcs (not just CanonicalR). Then in the antisymmetrization, either [p] < [q] (desired) or [p] = [q] but then CanonicalR is bidirectional and we can try a different witness.

**Strategy C: Bypass the quotient entirely (Recommended)**
Instead of antisymmetrizing and then proving quotient properties, work directly with the preorder + strictness witnesses. The DenseTimeline already has:
- `dense_timeline_has_future` gives q with `CanonicalR(p.mcs, q.mcs)`
- `dense_timeline_has_intermediate` gives c with `CanonicalR(a.mcs, c.mcs)` and `CanonicalR(c.mcs, b.mcs)` WHEN `NOT CanonicalR(b.mcs, a.mcs)`

The gap is: for NoMaxOrder, we need to find q where `NOT CanonicalR(q.mcs, p.mcs)`.

Consider using the density axiom: if F(phi) in p.mcs, then F(F(phi)) in p.mcs. The F(F(phi)) witness q satisfies CanonicalR(p, q), and the F(phi) witness r from q satisfies CanonicalR(q, r). If CanonicalR(q, p) held, then phi in GContent(q) would be in p, and then F(phi)'s forward witness from p could be different from q. The key insight: by temporal linearity and careful formula choice, one can find witnesses that are genuinely distinct.

**Concrete approach**: For NoMaxOrder, use `not_G_implies_F_neg` (from SeparationLemma): if NOT CanonicalR(q, p), done. If CanonicalR(q, p), then since CanonicalR is bidirectional between p and q, both GContent(p) subset q and GContent(q) subset p. Apply `density_frame_condition` to any STRICT pair above p (which exists by repeatedly applying F-witnesses and temporal linearity) to get a strict future.

### Recommendation 2: Refactor StagedExecution Imports Before Archiving

Before archiving DovetailingChain.lean:
1. Analyze which definitions StagedExecution.lean actually needs from `TemporalCoherentConstruction.lean` (likely only transitive imports: ModalSaturation, WitnessSeed, etc.)
2. Refactor to import only the needed modules directly
3. Then archive DovetailingChain.lean to Boneyard

**Estimated effort**: 1-2 hours for import refactoring.

### Recommendation 3: Close Task 958 as [PARTIAL]

Per research-009.md findings:
- Add documentation to CanonicalIrreflexivity.lean header explaining the theorem is TRUE but unprovable with String atoms
- Keep the sorry as honest acknowledgment
- Mark Task 958 as [PARTIAL] with documentation that the theorem is unused
- Do NOT count these 2 sorries in the completeness chain inventory

**Estimated effort**: 30 minutes.

### Recommendation 4: Phase 6-8 Implementation Roadmap

**Phase 6 (CantorApplication.lean)** -- Resolve 3 sorries:
1. Prove a "strict future exists" lemma: given any p in the dense timeline, exists q with `CanonicalR(p.mcs, q.mcs)` AND `NOT CanonicalR(q.mcs, p.mcs)`. This requires combining density axiom + temporal linearity + the structure of the staged construction.
2. Similarly for "strict past exists".
3. For DenselyOrdered: the existing `dense_timeline_has_intermediate` already requires strictness as a precondition (`h_not_R`). The intermediate c needs to be shown strict relative to both a and b. The density_frame_condition proof's Case A already produces a non-trivial intermediate.
4. Estimated effort: 3-4 hours.

**Phase 7 (DFromSyntax.lean)** -- Straightforward once Phase 6 is done:
1. D = Q (from Cantor isomorphism)
2. Group operations inherited from Q
3. task_rel defined via Cantor isomorphism
4. Estimated effort: 1.5 hours.

**Phase 8 (TaskFrameFromSyntax.lean)** -- Most substantial phase:
1. Construct `TaskFrame D` from the staged timeline
2. Build truth lemma connecting MCS membership to standard `truth_at`
3. Prove standard completeness without Int/Rat imports
4. Estimated effort: 2.5 hours.

### NOT Recommended

1. **Archiving TemporalCoherentConstruction.lean now**: StagedExecution.lean depends on it. Refactor imports first.
2. **Archiving Representation.lean now**: It contains the current working completeness theorems. Only archive after Phase 8 produces sorry-free replacements.
3. **Trying to prove canonicalR_irreflexive**: Exhaustively analyzed in Task 958 (8 prior reports). The gap is fundamental with String atoms.
4. **Using sorry deferral for the strictness gap**: All 3 CantorApplication sorries have the same root cause. Deferring would leave the entire D-from-syntax path incomplete.

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Quotient strictness gap pattern | Finding 3 | No | new_file |
| StagedConstruction import dependency chain | Finding 1 | Partial (in StagedExecution header) | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `quotient-strictness-gap.md` | `patterns/` | Common pattern across ConstructiveQuotient and TimelineQuot | Low | No |

### Summary

- **New files needed**: 0 (the pattern is task-specific, not reusable enough for a context file)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. **The quotient strictness gap is the single critical blocker** for the D-from-syntax completion. All other issues (Int/Rat taint, Task 958, import cleanup) are secondary.
2. **Strategy C (bypass quotient / prove strict witnesses)** is the recommended approach for resolving the 3 CantorApplication sorries.
3. **Import refactoring** should precede any archival of Int/Rat-tainted files.
4. **Task 958 should be closed as [PARTIAL]** with documentation, not further attempted.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strict witness lemma is harder than expected | HIGH | MEDIUM | Fallback: prove canonicalR is irreflexive for reachable MCSs (weaker than global, but sufficient for the staged timeline) |
| StagedExecution import refactoring breaks builds | LOW | LOW | Incremental: add direct imports first, then remove TemporalCoherentConstruction import |
| Phase 8 truth lemma integration requires Int infrastructure | MEDIUM | LOW | The StagedConstruction is D-free; Phase 8 defines its own truth lemma |
| Cantor isomorphism from Mathlib unavailable | LOW | LOW | Already imported and used in CantorApplication.lean (Order.iso_of_countable_dense) |

## Appendix

### Search Queries Used

**Codebase**:
- Grep: `sorry` in Metalogic/ (excluding Boneyard), `Int\b|Rat\b` in all three tainted files, `import.*CanonicalIrreflexivity`, `import.*StagedConstruction`, `import.*TemporalCoherentConstruction` across Theories/
- Read: CantorApplication.lean (full, 157 lines), DovetailingChain.lean (header, 80 lines), TemporalCoherentConstruction.lean (header, 80 lines + sorry locations), Representation.lean (header, 80 lines), DenseTimeline.lean (full relevant sections), CantorPrereqs.lean (header, 80 lines), DensityFrameCondition.lean (header, 60 lines), StagedExecution.lean (header, 20 lines), ConstructiveFragment.lean (sorry context), ROAD_MAP.md (relevant sections), implementation-015.md (full), research-009.md (full)
- Glob: `**/StagedConstruction/*.lean`, `**/ROAD_MAP*`

### Active Sorry Inventory (Complete)

| File | Count | Description | On D-from-syntax path? |
|------|-------|-------------|----------------------|
| StagedConstruction/CantorApplication.lean | 3 | NoMaxOrder, NoMinOrder, DenselyOrdered on TimelineQuot | YES |
| Canonical/ConstructiveFragment.lean | 2 | NoMaxOrder, NoMinOrder on ConstructiveQuotient | NO |
| Bundle/TemporalCoherentConstruction.lean | 2 | temporal_coherent_family_exists_Int (1), fully_saturated_bfmcs_exists_int (1) | NO (Int path) |
| Bundle/DovetailingChain.lean | 2 | forward_F (1), backward_P (1) | NO (Int path) |
| Bundle/CanonicalIrreflexivity.lean | 2 | Naming argument gap | NO (dead-end) |
| **Total** | **11** | | **3 on critical path** |

### StagedConstruction File Dependency Graph

```
StagedTimeline.lean (D-free, sorry-free)
  <- WitnessSeedWrapper.lean (D-free, sorry-free)
    <- SeparationLemma.lean (D-free, sorry-free)
      <- StagedExecution.lean (D-free, sorry-free; imports TemporalCoherentConstruction)
        <- CantorPrereqs.lean (D-free, sorry-free)
        <- DensityFrameCondition.lean (D-free, sorry-free)
          <- DenseTimeline.lean (D-free, sorry-free)
            <- CantorApplication.lean (references Q, 3 sorries)
```
