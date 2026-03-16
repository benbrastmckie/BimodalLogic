# Research Report: Task #971 - Deep Simplification Analysis

**Task**: 971 - Refactor to eliminate bmcs_truth_at layer
**Started**: 2026-03-15
**Completed**: 2026-03-15
**Effort**: 4-6 hours implementation (full elimination) vs 2-3 hours (bridge approach from research-001)
**Dependencies**: None (self-contained refactor)
**Sources/Inputs**: Prior research (research-001.md), codebase exploration, CanonicalConstruction.lean analysis
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

- The user's insight is correct: **directly using `canonical_truth_lemma` everywhere** is cleaner than deriving `bmcs_truth_lemma` as a corollary
- This is a more aggressive simplification than research-001's bridge approach
- The analysis reveals **7 additional simplification opportunities** of similar nature throughout the metalogic
- Key finding: The "bridge layer" pattern (`bmcs_truth_at` wrapping `truth_at`) appears in multiple places
- **Recommended approach**: Full elimination with minimal compatibility shim, not intermediate bridge derivation

---

## Context & Scope

### User's Core Insight

Research-001 recommended "Option A: Derive `bmcs_truth_lemma` as Corollary":
> "Add to CanonicalConstruction.lean: `bmcs_truth_lemma_from_canonical`..."

The user correctly identifies this as suboptimal:
> "Instead of refactoring TruthLemma.lean to derive bmcs_truth_lemma from canonical_truth_lemma, why not directly use canonical_truth_lemma, skipping the need to derive or use bmcs_truth_lemma in the first place."

This research focuses on:
1. Full elimination of `bmcs_truth_lemma` (not derivation)
2. Direct usage of `canonical_truth_lemma` everywhere
3. Systematic identification of ALL similar simplification opportunities

---

## Findings

### Finding 1: Direct Comparison of the Two Truth Lemmas

**`bmcs_truth_lemma`** (in TruthLemma.lean):
```lean
theorem bmcs_truth_lemma (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam in B.families)
    (t : D) (phi : Formula) :
    phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

**`canonical_truth_lemma`** (in CanonicalConstruction.lean):
```lean
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

**Key Differences**:
| Aspect | `bmcs_truth_lemma` | `canonical_truth_lemma` |
|--------|-------------------|------------------------|
| Domain type | Generic `D` | Concrete `Int` |
| RHS predicate | `bmcs_truth_at` | `truth_at` (standard) |
| Semantic model | BFMCS-internal | CanonicalTaskModel |
| Evaluation context | `(B, fam, t)` | `(CanonicalTaskModel, CanonicalOmega B, to_history fam, t)` |

**Insight**: The generic `D` in `bmcs_truth_lemma` is not actually used anywhere - all completeness code uses `D = Int`. The abstraction over `D` is vestigial.

### Finding 2: Usage Analysis of `bmcs_truth_lemma`

Current usage locations:

| File | Usage | Can Replace with `canonical_truth_lemma`? |
|------|-------|------------------------------------------|
| `TruthLemma.lean` | Definition site | N/A (eliminated) |
| `TruthLemma.lean` | Internal corollaries (`bmcs_eval_truth`, etc.) | Yes - redefine in terms of `canonical_truth_lemma` |
| `CanonicalConstruction.lean` | Documentation only | Already uses `canonical_truth_lemma` |
| `StagedConstruction/Completeness.lean` | Documentation reference | No code usage, update docs |
| `Metalogic.lean` | Publication list | Update publication list |
| `Boneyard/IntRepresentation/Representation.lean` | Actually uses | Deprecated file, no action needed |

**Key Finding**: `bmcs_truth_lemma` has NO non-deprecated code usage outside its own module. The "bridge" approach from research-001 would create a dependency that doesn't currently exist.

### Finding 3: Usage Analysis of `bmcs_truth_at`

Current usage locations:

| File | Line(s) | Usage Type | Action |
|------|---------|------------|--------|
| `BFMCSTruth.lean` | 86-92 | Definition | DEPRECATE (keep for backward compat) |
| `BFMCSTruth.lean` | 115-267 | Derived lemmas (`bmcs_truth_neg`, etc.) | These can be derived from `truth_at` properties |
| `TruthLemma.lean` | 38, 263, etc. | Proof uses | ELIMINATE (rewrite using `canonical_truth_lemma`) |
| `CanonicalConstruction.lean` | 20, 105, 449 | Documentation | Already states `bmcs_truth_at` is redundant |
| `Boneyard/IntRepresentation/Representation.lean` | 47 | Documentation | Deprecated file |
| `StagedConstruction/Completeness.lean` | 92 | Documentation | Update docs |
| `Bundle/README.md` | 85-100 | Documentation | Update docs |

**Key Finding**: The only non-documentation, non-deprecated usage is in `TruthLemma.lean` itself. Eliminating `TruthLemma.lean`'s internal usage eliminates ALL live usage.

### Finding 4: Full Elimination Strategy

Instead of the bridge approach, we can:

1. **Delete** `TruthLemma.lean` entirely (or archive to Boneyard)
2. **Deprecate** `BFMCSTruth.lean` with a note pointing to `CanonicalConstruction.lean`
3. **Move** any useful corollaries to `CanonicalConstruction.lean`, rewritten in terms of `truth_at`
4. **Update** import statements in downstream files

**Import Chain Before**:
```
Metalogic.lean
  -> TruthLemma.lean
     -> BFMCSTruth.lean
  -> CanonicalConstruction.lean
     -> TruthLemma.lean (imports but doesn't use bmcs_truth_lemma)
```

**Import Chain After**:
```
Metalogic.lean
  -> CanonicalConstruction.lean (provides canonical_truth_lemma, shifted_truth_lemma)
  (TruthLemma.lean and BFMCSTruth.lean: deprecated/archived)
```

### Finding 5: Systematic Survey of Similar Simplification Opportunities

Searching for patterns of indirection, we identify these additional candidates:

#### 5.1 `EvalBFMCS` Layer (Already Removed in Task 912)

| Item | Status | Notes |
|------|--------|-------|
| `eval_bmcs_truth_lemma` | REMOVED | Had 4 sorries, correctly eliminated |
| `eval_bmcs_eval_truth` | REMOVED | Documented as archived |

This was a previous example of eliminating a redundant layer - validates the approach.

#### 5.2 Generic `D` vs Concrete `Int` Throughout BFMCS

Many BFMCS modules are parameterized over generic `D` when only `D = Int` is used:

| Module | Pattern | Simplification |
|--------|---------|----------------|
| `BFMCS.lean` | `structure BFMCS (D : Type*)` | Could specialize to `Int` |
| `FMCS.lean` | `structure FMCS (D : Type*)` | Could specialize to `Int` |
| `BFMCSTruth.lean` | `def bmcs_truth_at (D : Type*)` | Already recommended for deprecation |
| `TruthLemma.lean` | `theorem bmcs_truth_lemma (D : Type*)` | Already recommended for elimination |
| `TemporalCoherence.lean` | Generic `D` | Uses CanonicalMCS as D in practice |

**Recommendation**: Not a priority for this task, but note for future simplification: the generic `D` abstraction is unused scaffolding. Future cleanup could specialize to `Int` or the syntax-derived domain.

#### 5.3 Dual Proof Paths in Completeness

The codebase has two parallel paths documented in `StagedConstruction/Completeness.lean`:
- **Path A**: BFMCS + `bmcs_truth_lemma` (legacy, via `bmcs_truth_at`)
- **Path B**: CanonicalConstruction + `canonical_truth_lemma` (modern, direct `truth_at`)

**Current Status**: Path B is already the publication path. Path A is scaffolding.

**Simplification**: After eliminating `bmcs_truth_at`, Path A ceases to exist. This is the desired outcome.

#### 5.4 Unused BFMCS Accessors (Already Removed in Task 970)

| Item | Status | Notes |
|------|--------|-------|
| `BFMCS.mcs_at` | REMOVED | Was thin wrapper |
| `BFMCS.is_mcs` | REMOVED | Was thin wrapper |
| `bmcs_valid` | REMOVED | Never used in proofs |
| `bmcs_satisfiable_at` | REMOVED | Never used in proofs |
| `bmcs_satisfies_context` | REMOVED | Never used in proofs |

Task 970 already cleaned these up. This validates that similar cleanup is appropriate.

#### 5.5 Boneyard Items Awaiting Full Removal

The following files are deprecated but not yet moved to Boneyard:

| File | Status | Action |
|------|--------|--------|
| `TruthLemma.lean` | To be deprecated | Move to Boneyard |
| `BFMCSTruth.lean` | To be deprecated | Move to Boneyard |
| `TemporalCoherentConstruction.lean` | Already deprecated | Already in Boneyard (Task 970) |
| `DovetailingChain.lean` | Already deprecated | Already in Boneyard |

#### 5.6 Corollaries That Should Be Preserved

These corollaries from `TruthLemma.lean` are useful and should be moved to `CanonicalConstruction.lean`:

| Corollary | Current Location | New Definition |
|-----------|------------------|----------------|
| `bmcs_eval_truth` | TruthLemma.lean:410 | Derive from `canonical_truth_lemma` |
| `bmcs_eval_mcs` | TruthLemma.lean:418 | Derive from `canonical_truth_lemma` |
| `bmcs_box_iff_all_true` | TruthLemma.lean:427 | Derive from `canonical_truth_lemma` |
| `bmcs_box_truth_unique` | TruthLemma.lean:437 | Already independent of `bmcs_truth_at` |

**Note**: These corollaries are internal to the bundle module and may not be needed at all. Check for actual usage before porting.

#### 5.7 Derived Lemmas in BFMCSTruth.lean

These lemmas derive properties of `bmcs_truth_at`:

| Lemma | Purpose | After Deprecation |
|-------|---------|-------------------|
| `bmcs_truth_neg` | Truth of negation | Use standard `truth_at` + negation |
| `bmcs_truth_and` | Truth of conjunction | Use standard `truth_at` + conjunction |
| `bmcs_truth_or` | Truth of disjunction | Use standard `truth_at` + disjunction |
| `bmcs_truth_diamond` | Truth of diamond | Use standard `truth_at` + diamond |
| `bmcs_truth_box_family_independent` | Box is family-independent | Follows from `truth_at` box definition |
| `bmcs_truth_box_reflexive` | T axiom | Already in CanonicalConstruction via MCS properties |
| `bmcs_truth_box_transitive` | 4 axiom | Already in CanonicalConstruction via MCS properties |
| `bmcs_truth_necessitation` | Necessitation | Follows from box definition |
| `bmcs_truth_all_future_transitive` | G transitivity | Follows from `truth_at` + order properties |
| `bmcs_truth_all_past_transitive` | H transitivity | Follows from `truth_at` + order properties |

**Recommendation**: These are all derivable from `truth_at` and standard formula properties. No need to port them; users should use `truth_at` directly.

---

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | LOW | This refactor is about eliminating layers, not changing D. The Int specialization in `canonical_truth_lemma` is fine because it's the Cantor-discovered D |
| EvalBFMCS | LOW | Already eliminated; validates our approach |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | Refactor aligns - `canonical_truth_lemma` is part of the publication path |
| Publication-Ready Metalogic | ACTIVE | Eliminating `bmcs_truth_at` reduces complexity, improves publication readiness |
| Proof Economy | ACTIVE | Fewer layers = fewer potential sorries |

---

## Revised Implementation Plan

### Phase 1: Verify No External Dependencies (15 min)

1. Grep for `import.*TruthLemma` outside Metalogic - confirm no external dependents
2. Grep for `bmcs_truth_lemma` and `bmcs_truth_at` usage in non-Boneyard, non-deprecated files
3. Document any blockers

### Phase 2: Port Essential Corollaries (30 min)

Add to `CanonicalConstruction.lean` (if actually used):

```lean
/-- If phi is in the MCS at the evaluation family and time 0, then phi is true there. -/
theorem canonical_eval_truth (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (phi : Formula) (h : phi in B.eval_family.mcs 0) :
    truth_at CanonicalTaskModel (CanonicalOmega B) (to_history B.eval_family) 0 phi :=
  (canonical_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 phi).mp h

-- Similar for mcs direction and shifted variants
```

### Phase 3: Deprecate BFMCSTruth.lean (15 min)

Add deprecation header:
```lean
/-!
# BFMCS Truth Definition [DEPRECATED]

**DEPRECATION NOTICE**: This module is deprecated as of Task 971.
The `bmcs_truth_at` predicate is structurally redundant with `truth_at`
when canonical constructions are used.

**Migration**: Use `canonical_truth_lemma` from `CanonicalConstruction.lean`.
The standard `truth_at` predicate with `CanonicalTaskModel` provides the same
semantics without an intermediate layer.

This module is preserved for reference but should not be imported by new code.
-/
```

### Phase 4: Archive TruthLemma.lean (30 min)

1. Create `Boneyard/Task971/TruthLemma.lean`
2. Move `TruthLemma.lean` content there
3. Update deprecation header
4. Remove `import Bimodal.Metalogic.Bundle.TruthLemma` from:
   - `Metalogic.lean`
   - `CanonicalConstruction.lean`
   - `StagedConstruction/Completeness.lean`

### Phase 5: Update Documentation (30 min)

1. Update `Metalogic.lean` publication-ready list:
   - Remove `bmcs_truth_lemma`
   - Keep `canonical_truth_lemma` and `shifted_truth_lemma`
2. Update `Bundle/README.md`:
   - Remove `bmcs_truth_at` examples
   - Point to `CanonicalConstruction.lean`
3. Update `StagedConstruction/Completeness.lean` docstrings:
   - Remove references to `bmcs_truth_lemma`
   - Reference `canonical_truth_lemma` directly

### Phase 6: Verify Build and Commit (15 min)

1. Run `lake build`
2. Fix any broken imports or references
3. Commit with message: `task 971: eliminate bmcs_truth_at layer`

---

## Comparison: Bridge Approach vs Full Elimination

| Aspect | Bridge (research-001) | Full Elimination (this report) |
|--------|----------------------|-------------------------------|
| Files Modified | 3-4 | 5-6 |
| Files Archived | 0 | 2 (TruthLemma, BFMCSTruth) |
| Complexity Reduction | Medium | High |
| Risk | Low | Medium |
| Future Maintenance | Still have two paths | Single path |
| Conceptual Clarity | Improved | Maximized |
| Implementation Time | 2-3 hours | 4-6 hours |

**Recommendation**: Full elimination is worth the extra effort. It removes technical debt permanently rather than wrapping it.

---

## Decisions

1. **Full elimination** rather than bridge derivation
2. **Archive** TruthLemma.lean and deprecate BFMCSTruth.lean rather than keeping active
3. **Port only essential corollaries** to CanonicalConstruction.lean (verify usage first)
4. **Update documentation** to reference canonical_truth_lemma directly

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| External dependencies on TruthLemma | LOW | HIGH | Grep for imports before archiving |
| Missing corollaries after port | MEDIUM | LOW | Check usage of each corollary; most are unused |
| Build breakage | MEDIUM | LOW | Incremental changes with lake build checks |
| Generic D usage discovered | LOW | MEDIUM | Can restore TruthLemma.lean from Boneyard if needed |

---

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Layer elimination pattern | Finding 4, 5 | No | new_file |
| Bridge vs elimination tradeoffs | Comparison table | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `layer-elimination-pattern.md` | `processes/` | Document pattern of eliminating redundant abstraction layers | Low | No |

### Summary

- **New files needed**: 0 (low priority)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 0

---

## Appendix

### Search Queries Used

1. `Grep import.*TruthLemma Theories/` - Import graph
2. `Grep bmcs_truth_lemma|canonical_truth_lemma Theories/` - Usage comparison
3. `Grep bmcs_truth_at Theories/` - Full usage map
4. `Grep DEPRECATED|deprecated|structurally redundant Theories/` - Prior cleanup patterns
5. `Grep def.*truth|theorem.*truth Theories/Bimodal/` - All truth definitions

### Key File Summary

| File | Purpose | Lines | Action |
|------|---------|-------|--------|
| `BFMCSTruth.lean` | Defines bmcs_truth_at | 272 | DEPRECATE |
| `TruthLemma.lean` | Proves bmcs_truth_lemma | 489 | ARCHIVE |
| `CanonicalConstruction.lean` | Proves canonical_truth_lemma | 797 | KEEP (primary) |
| `StagedConstruction/Completeness.lean` | Documents pipeline | 190 | UPDATE DOCS |
| `Metalogic.lean` | Aggregation module | 74 | UPDATE IMPORTS |

### References

- Task 970 research report: `specs/970_review_metalogic_for_publication/reports/research-001.md`
- Prior research: `specs/971_refactor_eliminate_bmcs_truth_at_layer/reports/research-001.md`
- CanonicalConstruction.lean line 20: Explicit acknowledgment of redundancy
- Task 912 summary: Precedent for EvalBFMCS elimination
