# Research Report: Task #971 - Deep Dive on 7 Simplification Opportunities

**Task**: 971 - Refactor to eliminate bmcs_truth_at layer
**Started**: 2026-03-15
**Completed**: 2026-03-15
**Effort**: Research effort ~2 hours; implementation varies by opportunity
**Dependencies**: None (research phase)
**Sources/Inputs**: research-002.md, codebase exploration (Glob/Grep/Read)
**Artifacts**: This report (research-003.md)
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

This report provides a comprehensive deep-dive on all 7 simplification opportunities identified in research-002.md (Finding 5, sections 5.1-5.7). For each opportunity, we provide:
- Exact definitions/locations
- Full usage analysis with dependencies
- Replacement strategy
- Risk assessment
- Effort estimate
- Phase recommendation for integration with implementation-002.md

**Key findings**:
- **5.1 EvalBFMCS**: Already removed in Task 912 - validates the elimination pattern
- **5.2 Generic D vs Int**: Low priority vestigial abstraction - 11 files affected
- **5.3 Dual Proof Paths**: Will be automatically resolved by bmcs_truth_at elimination
- **5.4 Unused BFMCS Accessors**: Already removed in Task 970 - validates cleanup approach
- **5.5 Boneyard Items**: 2 files to archive (BFMCSTruth, TruthLemma) - core of implementation-002
- **5.6 Corollaries to Preserve**: 4 corollaries, all in TruthLemma.lean - analysis shows none are used externally
- **5.7 Derived Lemmas in BFMCSTruth**: 10 lemmas, all derivable from truth_at - no port needed

**Recommendation**: Opportunities 5.1, 5.3, 5.4 are already handled. Opportunities 5.5, 5.6, 5.7 are addressed by implementation-002.md. Opportunity 5.2 (Generic D) should be deferred to a future task.

---

## Opportunity 5.1: EvalBFMCS Layer (Already Removed)

### Definition/Location

| Item | Original Location | Status |
|------|-------------------|--------|
| `eval_bmcs_truth_lemma` | TruthLemma.lean (removed) | ARCHIVED in Task 912 |
| `eval_bmcs_eval_truth` | TruthLemma.lean (removed) | ARCHIVED in Task 912 |

### Usage Analysis

**Grep results**: No active usages found. Only references are in TruthLemma.lean docstrings (lines 467-486) explaining the archival.

**Current documentation** (TruthLemma.lean lines 474-486):
```
## EvalBFMCS Truth Lemma (ARCHIVED)

The `eval_bmcs_truth_lemma` and `eval_bmcs_eval_truth` were removed in task 912.
They had 4 sorries due to structural limitations of EvalBFMCS (no full modal coherence).
```

### Replacement Strategy

N/A - Already removed. The `bmcs_truth_lemma` for full BFMCS replaced this.

### Risk Assessment

None. Already handled.

### Effort Estimate

0 hours - complete.

### Phase Recommendation

N/A - validates the elimination pattern for this task.

---

## Opportunity 5.2: Generic D vs Concrete Int Throughout BFMCS

### Definition/Location

The following modules are parameterized over generic `D : Type*` when only `D = Int` (or specialized domains) are ever used:

| File | Line | Pattern | Actual Usage |
|------|------|---------|--------------|
| `Bundle/BFMCS.lean` | 57, 121 | `variable (D : Type*) [Preorder D]` | Always `Int` in practice |
| `Bundle/FMCSDef.lean` | 57, 102 | `variable (D : Type*) [Preorder D]` | Always `Int` or `CanonicalMCS` |
| `Bundle/BFMCSTruth.lean` | 53 | `variable {D : Type*} [Preorder D]` | Always `Int` |
| `Bundle/TruthLemma.lean` | 81 | `variable {D : Type*} [Preorder D] [Zero D]` | Always `Int` |
| `Bundle/TemporalCoherence.lean` | 43, 147 | Generic D with Preorder + Zero | `CanonicalMCS` or `Int` |
| `Bundle/Construction.lean` | 36 | `variable {D : Type*} [Preorder D]` | Always `Int` |
| `Bundle/ModalSaturation.lean` | 48, 400 | `variable {D : Type*} [Preorder D]` | Always `Int` |

**Total files with generic D**: 7 core Bundle files

### Usage Analysis

**Concrete types actually used**:
1. `D = Int` - Used in `CanonicalConstruction.lean`, the publication path
2. `D = CanonicalMCS` - Used in `CanonicalFMCS.lean` for the all-MCS approach
3. `D = TimelineQuot` - Discussed in `StagedConstruction/Completeness.lean` but not implemented

**Key insight from research-002.md**:
> The generic `D` in `bmcs_truth_lemma` is not actually used anywhere - all completeness code uses `D = Int`. The abstraction over `D` is vestigial.

However, examining `StagedConstruction/Completeness.lean` reveals there is ongoing work to potentially use `D = TimelineQuot`:
```
The existing `canonical_truth_lemma` in CanonicalConstruction.lean uses `D = Int`,
which is a hardcoded approach we're avoiding.
```

This suggests the generic D abstraction may have future utility.

### Replacement Strategy

**Option A: Full Specialization** (Not Recommended Now)
- Replace all `D : Type*` with `D = Int`
- Remove typeclass constraints
- Simplify all proofs

**Option B: Document and Defer** (Recommended)
- Document that D is vestigial in current usage
- Defer specialization until TimelineQuot work is complete
- Add clarifying comments to key files

### Risk Assessment

| Risk | Likelihood | Impact | Notes |
|------|------------|--------|-------|
| Blocks future D variations | MEDIUM | HIGH | TimelineQuot work may need generic D |
| Premature optimization | MEDIUM | LOW | May remove useful abstraction |

### Effort Estimate

- Full specialization: 4-6 hours (modify 7+ files, update all callsites)
- Documentation only: 30 minutes

### Phase Recommendation

**Defer to future task.** The current implementation-002.md focuses on eliminating the bmcs_truth_at *layer*, not the generic D abstraction. The D specialization is a separate concern that should be addressed after TimelineQuot integration is clarified.

If added to implementation-002.md: **Phase 0 (Pre-requisite analysis)** - Just document the vestigial nature.

---

## Opportunity 5.3: Dual Proof Paths in Completeness

### Definition/Location

**Documented in** `StagedConstruction/Completeness.lean` lines 88-92:
```lean
2. **BFMCS Truth Lemma** (TruthLemma.lean):
   theorem bmcs_truth_lemma (B : BFMCS D) (h_tc : B.temporally_coherent)
       (fam : FMCS D) (hfam : fam in B.families) (t : D) (phi : Formula) :
       phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

The two paths documented in research-002.md:
- **Path A (Legacy)**: BFMCS + `bmcs_truth_lemma` (via `bmcs_truth_at`)
- **Path B (Modern)**: CanonicalConstruction + `canonical_truth_lemma` (direct `truth_at`)

### Usage Analysis

**Path A references**:
- `StagedConstruction/Completeness.lean` lines 88-92 - documentation reference
- `Bundle/README.md` lines 85-100 - example usage of bmcs_truth_at

**Path B references**:
- `CanonicalConstruction.lean` - defines canonical_truth_lemma, shifted_truth_lemma
- `Metalogic.lean` line 26 - publication list mentions bmcs_truth_lemma (should reference canonical)

### Replacement Strategy

After eliminating bmcs_truth_at (implementation-002.md Phases 2-3), Path A ceases to exist automatically. Documentation updates are included in implementation-002.md Phases 5-7.

### Risk Assessment

None - this is automatically resolved by the main elimination work.

### Effort Estimate

0 hours additional - covered by implementation-002.md documentation phases.

### Phase Recommendation

Already covered by implementation-002.md:
- **Phase 5**: Update Metalogic.lean publication exports
- **Phase 6**: Update StagedConstruction/Completeness.lean documentation
- **Phase 7**: Clean up Bundle/README.md

---

## Opportunity 5.4: Unused BFMCS Accessors (Already Removed)

### Definition/Location

| Item | Status | Removal Task |
|------|--------|--------------|
| `BFMCS.mcs_at` | REMOVED | Task 970 |
| `BFMCS.is_mcs` | REMOVED | Task 970 |
| `bmcs_valid` | REMOVED | Task 970 |
| `bmcs_satisfiable_at` | REMOVED | Task 970 |
| `bmcs_satisfies_context` | REMOVED | Task 970 |

**Evidence** (BFMCSTruth.lean lines 100-102):
```lean
-- Unused validity definitions removed in Task 970:
-- bmcs_valid, bmcs_satisfiable_at, bmcs_satisfies_context
-- These were never used in actual completeness proofs.
```

**Evidence** (BFMCS.lean line 170):
```lean
-- Unused accessors removed in Task 970: BFMCS.mcs_at, BFMCS.is_mcs
```

### Usage Analysis

**Grep results**: Only references are in documentation (README files) and comments noting their removal.

### Replacement Strategy

N/A - Already removed. The README files reference these in historical context (e.g., `bmcs_weak_completeness : bmcs_valid -> derivable`) but these are referencing the *theorem*, not the definition.

### Risk Assessment

None. Already handled.

### Effort Estimate

0 hours - complete.

### Phase Recommendation

N/A - validates the cleanup approach for this task.

---

## Opportunity 5.5: Boneyard Items Awaiting Full Removal

### Definition/Location

| File | Current Status | Action Required |
|------|----------------|-----------------|
| `Bundle/TruthLemma.lean` | Active (489 lines) | Archive to `Boneyard/Task971/` |
| `Bundle/BFMCSTruth.lean` | Active (272 lines) | Archive to `Boneyard/Task971/` |
| `Boneyard/Task970/TemporalCoherentConstruction.lean` | Already archived | None |
| `Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean` | Already archived | None |

### Usage Analysis

**TruthLemma.lean imports** (active codebase):
```
Theories/Bimodal/Metalogic.lean:6:import Bimodal.Metalogic.Bundle.TruthLemma
Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean:4:import Bimodal.Metalogic.Bundle.TruthLemma
Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean:2:import Bimodal.Metalogic.Bundle.TruthLemma
```

**BFMCSTruth.lean imports** (active codebase):
```
Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean:2:import Bimodal.Metalogic.Bundle.BFMCSTruth
```

**Boneyard imports** (deprecated, OK to ignore):
```
Theories/Bimodal/Boneyard/IntRepresentation/Representation.lean:2:import Bimodal.Metalogic.Bundle.BFMCSTruth
Theories/Bimodal/Boneyard/IntRepresentation/Representation.lean:3:import Bimodal.Metalogic.Bundle.TruthLemma
```

### Replacement Strategy

This is the core of implementation-002.md:
1. **Phase 2**: Archive BFMCSTruth.lean to `Boneyard/Task971/BFMCSTruth.lean`
2. **Phase 3**: Archive TruthLemma.lean to `Boneyard/Task971/TruthLemma.lean`
3. Remove imports from:
   - `Metalogic.lean`
   - `CanonicalConstruction.lean`
   - `StagedConstruction/Completeness.lean`

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CanonicalConstruction.lean breaks | MEDIUM | LOW | Phase 4 handles missing definitions |
| Completeness.lean documentation outdated | HIGH | LOW | Phase 6 updates documentation |
| Hidden usage in Boneyard affects build | LOW | LOW | Boneyard files are not built by default |

### Effort Estimate

1.5 hours - covered by implementation-002.md Phases 2-4.

### Phase Recommendation

Already central to implementation-002.md:
- **Phase 2**: Archive BFMCSTruth.lean
- **Phase 3**: Archive TruthLemma.lean
- **Phase 4**: Fix CanonicalConstruction.lean dependencies (if any)

---

## Opportunity 5.6: Corollaries That Should Be Preserved

### Definition/Location

| Corollary | Location | Lines | Purpose |
|-----------|----------|-------|---------|
| `bmcs_eval_truth` | TruthLemma.lean | 410-413 | Forward direction at eval family |
| `bmcs_eval_mcs` | TruthLemma.lean | 418-421 | Backward direction at eval family |
| `bmcs_box_iff_all_true` | TruthLemma.lean | 427-432 | Box membership equivalence |
| `bmcs_box_truth_unique` | TruthLemma.lean | 437-440 | Box family-independence |

### Usage Analysis

**Grep for external usage**:
```bash
Grep "bmcs_eval_truth|bmcs_eval_mcs|bmcs_box_iff_all_true|bmcs_box_truth_unique" Theories/
```

**Results**:
```
Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean:410:theorem bmcs_eval_truth ...
Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean:418:theorem bmcs_eval_mcs ...
Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean:427:theorem bmcs_box_iff_all_true ...
Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean:437:theorem bmcs_box_truth_unique ...
Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean:476:The `eval_bmcs_truth_lemma` and `eval_bmcs_eval_truth` were removed...
```

**Key finding**: ALL usages are within TruthLemma.lean itself. There are NO external usages of these corollaries.

### Replacement Strategy

**Option A: Port to CanonicalConstruction.lean** (research-002.md suggestion)

If ported, the new definitions would be:
```lean
theorem canonical_eval_truth (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (phi : Formula) (h : phi in B.eval_family.mcs 0) :
    truth_at CanonicalTaskModel (CanonicalOmega B) (to_history B.eval_family) 0 phi :=
  (canonical_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 phi).mp h
```

**Option B: Do Not Port** (Recommended)

Since there are no external usages, porting these corollaries would add code that isn't needed. Users who need these patterns can derive them directly from `canonical_truth_lemma`.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Someone needs these corollaries | LOW | LOW | Can derive from canonical_truth_lemma |
| Documentation gap | LOW | LOW | Archive header explains availability |

### Effort Estimate

- If porting: 30 minutes
- If not porting: 0 minutes

### Phase Recommendation

**Do not port.** Add a note in the archive header that these corollaries existed and can be derived from `canonical_truth_lemma` if needed.

Modify implementation-002.md Phase 3 archive header to include:
```lean
**Corollaries Available from canonical_truth_lemma**:
- bmcs_eval_truth pattern: (canonical_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 phi).mp h
- bmcs_eval_mcs pattern: (canonical_truth_lemma ...).mpr h
- bmcs_box_iff_all_true: combine truth lemma with box semantics
- bmcs_box_truth_unique: follows from box definition (quantifies over all families)
```

---

## Opportunity 5.7: Derived Lemmas in BFMCSTruth.lean

### Definition/Location

| Lemma | Line | Purpose | Direct truth_at Equivalent |
|-------|------|---------|---------------------------|
| `bmcs_truth_neg` | 115-118 | Truth of negation | Follows from `truth_at` imp/bot cases |
| `bmcs_truth_and` | 125-147 | Truth of conjunction | Follows from `truth_at` + `Formula.and` definition |
| `bmcs_truth_or` | 154-167 | Truth of disjunction | Follows from `truth_at` + `Formula.or` definition |
| `bmcs_truth_diamond` | 174-188 | Truth of diamond | Follows from `truth_at` + `Formula.diamond` definition |
| `bmcs_truth_box_family_independent` | 202-207 | Box is family-independent | Trivial from `truth_at` box definition |
| `bmcs_truth_box_reflexive` | 212-217 | T axiom | Already in CanonicalConstruction via MCS properties |
| `bmcs_truth_box_transitive` | 224-230 | 4 axiom | Already in CanonicalConstruction via MCS properties |
| `bmcs_truth_necessitation` | 235-240 | Necessitation | Follows from box definition |
| `bmcs_truth_all_future_transitive` | 252-258 | G transitivity | Follows from `truth_at` + order properties |
| `bmcs_truth_all_past_transitive` | 263-268 | H transitivity | Follows from `truth_at` + order properties |

### Usage Analysis

**Grep for external usage** of each lemma:

| Lemma | External Usage | Used In |
|-------|----------------|---------|
| `bmcs_truth_neg` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_and` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_or` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_diamond` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_box_family_independent` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_box_reflexive` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_box_transitive` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_necessitation` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_all_future_transitive` | 0 | Only in BFMCSTruth.lean definition |
| `bmcs_truth_all_past_transitive` | 0 | Only in BFMCSTruth.lean definition |

**Key finding**: ALL 10 lemmas have ZERO external usage. They are internal to the BFMCSTruth module.

### Replacement Strategy

**Do not port any of these.** The `truth_at` predicate from `Semantics/Truth.lean` already has (or can easily derive) equivalent properties. Users of standard Kripke semantics should use the standard `truth_at` lemmas.

### Risk Assessment

None. These are self-contained within the deprecated module.

### Effort Estimate

0 hours - no porting needed.

### Phase Recommendation

No action needed beyond archiving BFMCSTruth.lean (implementation-002.md Phase 2). The archive header should note:
```lean
**Derived lemmas (derivable from truth_at)**:
All bmcs_truth_* lemmas can be derived from standard truth_at properties.
See Semantics/Truth.lean for the canonical truth evaluation.
```

---

## Summary Table

| Opportunity | Status | Action | Effort | Phase |
|-------------|--------|--------|--------|-------|
| 5.1 EvalBFMCS | DONE (Task 912) | None | 0h | N/A |
| 5.2 Generic D vs Int | DEFER | Document vestigial nature | 0.5h | Future task |
| 5.3 Dual Proof Paths | COVERED | Auto-resolved by elimination | 0h | Phases 5-7 |
| 5.4 Unused Accessors | DONE (Task 970) | None | 0h | N/A |
| 5.5 Boneyard Items | CORE | Archive 2 files | 1.5h | Phases 2-4 |
| 5.6 Corollaries | ANALYSIS | Do not port (0 usage) | 0h | Phase 3 header |
| 5.7 Derived Lemmas | ANALYSIS | Do not port (0 usage) | 0h | Phase 2 header |

**Total additional effort beyond implementation-002.md**: 0.5 hours (documentation for 5.2)

---

## Recommendations for Implementation-002.md Extension

### No Phase Changes Needed

The current 8-phase structure of implementation-002.md fully addresses all actionable opportunities:
- Phases 2-3 handle opportunity 5.5 (archiving)
- Phase 4 handles any dependency fixes
- Phases 5-7 handle opportunity 5.3 (documentation updates)
- Phase 8 verifies completion

### Minor Enhancements to Archive Headers

**Phase 2 (BFMCSTruth.lean archive header)** - Add to existing header:
```lean
**Derived lemmas (derivable from truth_at)**:
All bmcs_truth_* lemmas (bmcs_truth_neg, bmcs_truth_and, etc.) can be derived
from standard truth_at properties. See Semantics/Truth.lean for the canonical
truth evaluation predicate.
```

**Phase 3 (TruthLemma.lean archive header)** - Add to existing header:
```lean
**Corollaries Available from canonical_truth_lemma**:
The corollaries bmcs_eval_truth, bmcs_eval_mcs, bmcs_box_iff_all_true, and
bmcs_box_truth_unique had no external usage and were not ported. They can
be derived from canonical_truth_lemma if needed:
- Forward at eval: (canonical_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 phi).mp h
- Backward at eval: (canonical_truth_lemma ...).mpr h
```

### Future Task: Generic D Specialization

Create a separate future task (NOT part of 971) for opportunity 5.2:
```
Task: Specialize Generic D to Concrete Types
Priority: Low
Description: The generic D abstraction in BFMCS/FMCS modules is vestigial.
Consider specializing to concrete types (Int, CanonicalMCS) after TimelineQuot
integration work is clarified. Affects ~7 Bundle files.
```

---

## Appendix: Search Queries Used

1. `Grep "BFMCS\s*\(D\s*:\s*Type" Theories/` - Generic D pattern
2. `Grep "bmcs_eval_truth|bmcs_eval_mcs|bmcs_box_iff_all_true|bmcs_box_truth_unique" Theories/` - Corollary usage
3. `Grep "bmcs_truth_neg|bmcs_truth_and|bmcs_truth_or|bmcs_truth_diamond" Theories/` - Derived lemma usage
4. `Grep "import.*TruthLemma|import.*BFMCSTruth" Theories/` - Import chain
5. `Grep "eval_bmcs|EvalBFMCS" Theories/` - EvalBFMCS references
6. `Glob "**/Boneyard/**/*.lean" Theories/Bimodal/` - Boneyard structure

---

## References

- research-001.md: Initial bmcs_truth_at analysis
- research-002.md: Systematic simplification opportunities (source of 7 items)
- implementation-002.md: Current implementation plan
- Task 912: EvalBFMCS elimination precedent
- Task 970: Unused accessor removal precedent
- specs/ROAD_MAP.md: Strategic context
