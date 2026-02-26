# Research Report: Task #935

**Task**: 935 - audit_roadmap_current_state_section
**Started**: 2026-02-26T12:00:00Z
**Completed**: 2026-02-26T12:30:00Z
**Effort**: 1 hour
**Dependencies**: None
**Sources/Inputs**: Codebase (Theories/Bimodal/Metalogic/), specs/ROAD_MAP.md, README files
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

The "Current State: What's Been Accomplished" section (lines 636-1497) of specs/ROAD_MAP.md contains **significant inaccuracies** that do not match the current codebase state. Key issues:

1. **Completeness Hierarchy claims are FALSE**: The document claims `weak_completeness`, `finite_strong_completeness`, `infinitary_strong_completeness` are "PROVEN" at specific file locations that do not exist in active code. These theorems are ARCHIVED to Boneyard.

2. **Compactness claims are FALSE**: The document claims compactness theorems are "Fully proven, sorry-free" but the entire Compactness module is ARCHIVED.

3. **File paths reference ARCHIVED/non-existent code**: Multiple tables reference files like `WeakCompleteness.lean`, `FiniteStrongCompleteness.lean`, `InfinitaryStrongCompleteness.lean`, `Compactness.lean` which exist only in Boneyard.

4. **Sorry counts are OUTDATED**: Claims of "~29 sorries" and specific distributions do not match actual count of **3 sorries** in active Metalogic.

5. **IndexedMCSFamily approach is SUPERSEDED**: The section extensively describes an IndexedMCSFamily approach that is now entirely in Boneyard (Metalogic_v5).

## Context & Scope

This audit examined lines 636-1497 of specs/ROAD_MAP.md, comparing each claim against:
- Actual file existence via `glob` and `ls`
- Actual sorry counts via `grep`
- README files documenting ARCHIVED status
- Current Metalogic architecture

## Findings

### Category 1: OUTDATED - Claims No Longer True

#### 1.1 Completeness Hierarchy (Lines 711-723)

**ROAD_MAP Claims**:
```markdown
| Result | Status | Location |
|--------|--------|----------|
| **weak_completeness** | PROVEN | WeakCompleteness.lean |
| **finite_strong_completeness** | PROVEN | FiniteStrongCompleteness.lean |
| **infinitary_strong_completeness** | PROVEN | InfinitaryStrongCompleteness.lean |
```

**Reality**: These files exist ONLY in `Theories/Bimodal/Boneyard/Metalogic_v5/Completeness/`. The active Metalogic has:
- `Bundle/Completeness.lean` with `bmcs_weak_completeness`, `bmcs_strong_completeness`
- `FMP/SemanticCanonicalModel.lean` with `fmp_weak_completeness`

**Evidence**: `Theories/Bimodal/Metalogic/Representation/README.md` states "ARCHIVED to Boneyard/Metalogic_v5/ (Task 809, 2026-02-02)"

**Correction Needed**: Replace entire Completeness Hierarchy table with reference to Bundle/Completeness.lean and FMP approach.

#### 1.2 Compactness (Lines 725-736)

**ROAD_MAP Claims**:
```markdown
**Status**: Fully proven, sorry-free.
| **compactness** | PROVEN | Compactness.lean |
| **compactness_iff** | PROVEN | Compactness.lean |
```

**Reality**: `Theories/Bimodal/Metalogic/Compactness/README.md` states "ARCHIVED to Boneyard/Metalogic_v5/Compactness/ (Task 809, 2026-02-02)"

The Compactness directory contains ONLY a README.md (12 bytes + README), no .lean files.

**Correction Needed**: Update status to "ARCHIVED - see Boneyard for reference implementation".

#### 1.3 Sorry Counts (Lines 1333-1345)

**ROAD_MAP Claims**:
```markdown
**Current State** (as of 2026-01-29): ~29 sorries in Metalogic/ (excluding Boneyard)

| Directory | Count | Category | Notes |
|-----------|-------|----------|-------|
| Representation/ | ~17 | Mixed | ... |
| FMP/ | ~3 | Non-blocking | ... |
| Completeness/ | 1 | Axiom | ... |
| Algebraic/ | ~8 | Independent | ... |
```

**Reality**: Actual sorry count as of 2026-02-26 is **3 sorries** total:
- `Bundle/TemporalCoherentConstruction.lean:600` (1 sorry)
- `Bundle/DovetailingChain.lean:1869` (1 sorry)
- `Bundle/DovetailingChain.lean:1881` (1 sorry)

The `Representation/` directory contains only README.md (archived). `Completeness/` directory does not exist as active code.

**Correction Needed**: Update sorry counts to reflect current state (3 sorries in DovetailingChain/TemporalCoherentConstruction).

### Category 2: INACCURATE - Claims Never True or Wrong Location

#### 2.1 Core Infrastructure Table (Lines 662-672)

**ROAD_MAP Claims**:
```markdown
| Component | Status | Location |
|-----------|--------|----------|
| **IndexedMCSFamily** | DEFINED | IndexedMCSFamily.lean |
| **Canonical history (family-based)** | PROVEN | CanonicalHistory.lean:226-288 |
| **Truth lemma (forward, temporal)** | PROVEN | TruthLemma.lean |
```

**Reality**:
- `IndexedMCSFamily.lean` exists only at `Boneyard/Metalogic_v5/Representation/`
- `CanonicalHistory.lean` exists only at `Boneyard/Metalogic_v5/Representation/`
- Active TruthLemma is at `Bundle/TruthLemma.lean` (uses BFMCS, not IndexedMCSFamily)

**Correction Needed**: This entire section describes the ARCHIVED Metalogic_v5 approach. It should be clearly marked as historical context or removed.

#### 2.2 representation_theorem Location (Lines 678, 701-707)

**ROAD_MAP Claims**:
```markdown
| **representation_theorem** | PROVEN (no sorry) | UniversalCanonicalModel.lean:70 |
```

**Reality**: `UniversalCanonicalModel.lean` exists only in Boneyard. The active representation theorem is `bmcs_representation` in `Bundle/Completeness.lean`.

**Correction Needed**: Update to reference `bmcs_representation` at `Bundle/Completeness.lean:100`.

#### 2.3 semantic_weak_completeness Claims (Lines 721, 723)

**ROAD_MAP Claims**:
```markdown
| **semantic_weak_completeness** | PROVEN (sorry-free) | WeakCompleteness.lean |
```

**Reality**: The active sorry-free completeness theorems are:
- `bmcs_weak_completeness` at `Bundle/Completeness.lean:243`
- `fmp_weak_completeness` at `FMP/SemanticCanonicalModel.lean`

There is no active `WeakCompleteness.lean` (archived to Boneyard).

### Category 3: UNCLEAR - Confusing or Misleading

#### 3.1 Boneyard Path (Line 640, 644)

**ROAD_MAP Claims**:
```markdown
Code preserved in `Boneyard/Metalogic_v2/`
Full Boneyard documentation available in [Boneyard/README.md](Theories/Boneyard/README.md)
```

**Reality**:
- Boneyard is at `Theories/Bimodal/Boneyard/`, not `Theories/Boneyard/`
- Multiple Boneyard versions exist: Metalogic, Metalogic_v2, Metalogic_v3, Metalogic_v4, Metalogic_v5, Metalogic_v7

**Correction Needed**: Update path to `Theories/Bimodal/Boneyard/` and clarify versioning scheme.

#### 3.2 "Indexed MCS Family Approach" vs BFMCS (Section starting line 652)

The entire section "Indexed MCS Family Approach" describes an ARCHIVED architecture. The current architecture uses BFMCS (Bundle of Maximal Consistent Sets) as documented in `Metalogic/Bundle/README.md`.

**Correction Needed**: Either remove this section or clearly mark it as "Historical: Superseded by BFMCS approach".

### Category 4: MISSING - Important Accomplishments Not Documented

#### 4.1 BFMCS Completeness

The active BFMCS completeness approach (`Bundle/Completeness.lean`) provides:
- `bmcs_representation` - Representation theorem (SORRY-FREE)
- `bmcs_weak_completeness` - Weak completeness (SORRY-FREE)
- `bmcs_strong_completeness` - Strong completeness (SORRY-FREE)

This is the CURRENT primary completeness approach but is barely mentioned.

#### 4.2 FMP Completeness

`FMP/SemanticCanonicalModel.lean` provides sorry-free completeness via finite model property but is mentioned only briefly.

#### 4.3 Current Sorry Debt Location

The actual sorry debt is documented in `Metalogic_v7/README.md`:
- `fully_saturated_bfmcs_exists_int` relies on 1 sorry in `TemporalCoherentConstruction.lean`
- `DovetailingChain.lean` has 2 sorries for cross-sign propagation

## Decisions

1. This section requires a **major rewrite** to reflect current architecture
2. The IndexedMCSFamily content should be moved to a "Historical Approaches" subsection
3. All file paths must be verified and updated
4. Sorry counts must be updated to reflect actual state

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Developers trust outdated claims | High | Update immediately |
| Historical context is valuable | Medium | Preserve in clearly-marked historical section |
| Confusion about completeness approaches | High | Create clear "Current Architecture" vs "Historical" separation |

## Recommended Corrections (Summary)

### High Priority (Factual Errors)

1. **Lines 711-723**: Delete or archive Completeness Hierarchy table referencing non-existent files
2. **Lines 725-736**: Update Compactness status to "ARCHIVED"
3. **Lines 1333-1345**: Update sorry count from "~29" to "3"
4. **Lines 662-672**: Mark Core Infrastructure table as "Historical (Metalogic_v5)"
5. **Lines 678, 701-707**: Update representation_theorem reference to `bmcs_representation`

### Medium Priority (Structural Issues)

6. **Lines 646-709**: Add clear "HISTORICAL - Superseded by BFMCS" marker to entire IndexedMCSFamily section
7. Add new section documenting CURRENT BFMCS completeness approach (`Bundle/Completeness.lean`)
8. Add new section documenting FMP completeness approach (`FMP/SemanticCanonicalModel.lean`)

### Low Priority (Path Corrections)

9. **Line 640, 644**: Fix Boneyard path to `Theories/Bimodal/Boneyard/`
10. Update all file path references to verified active locations

## Appendix

### Search Queries Used

- `grep -rn "sorry" Theories/Bimodal/Metalogic --include="*.lean" | grep -v Boneyard`
- `glob **/WeakCompleteness*.lean`, `**/Compactness*.lean`, `**/IndexedMCSFamily*.lean`
- `ls Theories/Bimodal/Metalogic/*/`

### References

- `Theories/Bimodal/Metalogic/README.md` - Current architecture documentation
- `Theories/Bimodal/Metalogic/Representation/README.md` - Archived status
- `Theories/Bimodal/Metalogic/Compactness/README.md` - Archived status
- `Theories/Bimodal/Boneyard/Metalogic_v7/README.md` - Recent archival history
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Active completeness theorems
