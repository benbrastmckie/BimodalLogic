# Research Report: Audit ROAD_MAP.md Strategies and Dead Ends

**Task**: 934 - audit_roadmap_strategies_dead_ends_accuracy
**Date**: 2026-02-26
**Session**: sess_1772128991_e7a991
**Status**: COMPLETE

## Executive Summary

The audit of `specs/ROAD_MAP.md` revealed **significant inaccuracies** requiring correction. The Strategies section has **3 of 4 entries with errors** (mostly outdated file paths and one major semantic mischaracterization). The Dead Ends section has **4 of 8 entries with broken evidence paths** and **1 with a terminology error**. All task 928-933 archival actions are documented, but several Dead End entries reference pre-archival paths.

**Key Finding**: The "Indexed MCS Family Approach" strategy fundamentally mischaracterizes TM semantics as **irreflexive** when the code has used **reflexive** semantics (≤) since Task #658. This is the highest-priority correction.

---

## Strategies Section Analysis

| Strategy | Status | Assessment | Issues |
|----------|--------|------------|--------|
| Indexed MCS Family Approach | ACTIVE | **MAJOR ERRORS** | Claims irreflexive semantics; file paths archived |
| CoherentConstruction Two-Chain Design | ACTIVE | **ERRORS** | Status should be ARCHIVED; file path wrong |
| Representation-First Architecture | CONCLUDED | **PARTIAL ERRORS** | File paths outdated; sorry-free claim misleading |
| Algebraic Verification Path | PAUSED | **ACCURATE** | No issues found |

### Strategy 1: Indexed MCS Family Approach - MAJOR ERRORS

**Current Claims (Lines 178-195)**:
> "TM's G/H operators are irreflexive (strictly future/past, excluding present)"
> "These conditions match the irreflexive semantics without requiring T-axioms"

**Reality**:
1. **Semantics are REFLEXIVE, not irreflexive** - `Truth.lean:118-119` uses `≤` (not `<`)
2. **T-axioms ARE required** - `FMCSDef.lean:23` explicitly states "T-axioms (`G phi -> phi`, `H phi -> phi`) to enable coherence proofs"
3. **Coherence conditions use `≤`** - `FMCSDef.lean:91,98` use `≤` not `<`
4. **All referenced files are ARCHIVED** - `IndexedMCSFamily.lean`, `CanonicalHistory.lean`, `TruthLemma.lean` moved to Boneyard/Metalogic_v5 (Task 809)

**Required Corrections**:
- Replace "irreflexive" with "REFLEXIVE"
- Replace "without requiring T-axioms" with "T-axioms are valid via reflexivity"
- Update file paths to current `Bundle/FMCSDef.lean` and `Bundle/TruthLemma.lean`

### Strategy 2: CoherentConstruction Two-Chain Design - ERRORS

**Issues**:
1. **Status WRONG**: Claims `ACTIVE` but CoherentConstruction was archived to Boneyard (Task 809, 2026-02-02)
2. **File path BROKEN**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` does not exist
3. **Current approach DIFFERENT**: Active approach is `DovetailingChain.lean`, not two-chain

**Required Corrections**:
- Change status from `ACTIVE` to `SUPERSEDED`
- Update file reference to Boneyard path
- Note that `DovetailingChain.lean` is the current replacement

### Strategy 3: Representation-First Architecture - PARTIAL ERRORS

**Issues**:
1. **File paths outdated**: `Representation/` directory now archived (contains only README)
2. **"Sorry-free" claim misleading**: Archived approach had 30 sorries; sorry-free completeness is via FMP

**Required Corrections**:
- Update paths to `Theories/Bimodal/Metalogic/Representation.lean` (current BFMCS entry point)
- Clarify that sorry-free result is via FMP, not archived Representation approach

### Strategy 4: Algebraic Verification Path - ACCURATE

No issues found. All file paths verified present. Description matches code structure.

---

## Dead Ends Section Analysis

| Dead End | Assessment | Issues |
|----------|------------|--------|
| Boneyard Decidability Infrastructure | **BROKEN PATH** | Missing `Bimodal/` prefix |
| Single-History FDSM Construction | **BROKEN PATH** | Wrong archive slug (825_fdsm_construction) |
| Cross-Origin Coherence Proofs | **STALE PATHS** | Pre-task-928 paths; wrong task reference (814 vs 808) |
| Original IndexedMCSFamily | **BROKEN PATH** | Same task 814/808 reference issue |
| CanonicalReachable/CanonicalQuotient Stack | **ACCURATE** | All paths verified |
| MCS-Membership Semantics for Box | **ACCURATE** | All paths verified |
| Constant Witness Family Approach | **ACCURATE** | All paths verified |
| Single-Family BFMCS modal_backward | **TERMINOLOGY** | Mislabels converse of T-axiom as "T-axiom" |

### Tasks 928-933 Documentation Status

All four archival actions from tasks 928-933 have Dead End entries:

| Task | Dead End Entry | Status |
|------|---------------|--------|
| 928 | Cross-Origin Coherence | Entry exists but paths stale |
| 931 | MCS-Membership Semantics | Entry accurate |
| 932 | Constant Witness Family | Entry accurate |
| 933 | CanonicalReachable/CanonicalQuotient | Entry accurate |

---

## Required Corrections Checklist

### High Priority (Semantic/Factual Errors)

- [ ] **Indexed MCS Family**: Replace "irreflexive" with "REFLEXIVE" semantics
- [ ] **Indexed MCS Family**: Remove "without requiring T-axioms" claim
- [ ] **CoherentConstruction Two-Chain**: Change status ACTIVE -> SUPERSEDED

### Medium Priority (Broken Paths)

- [ ] **Boneyard Decidability**: `Theories/Boneyard/` -> `Theories/Bimodal/Boneyard/`
- [ ] **Single-History FDSM**: `825_fdsm_construction` -> `825_fdsm_multi_history_modal_saturation`
- [ ] **Cross-Origin Coherence**: Update CoherentConstruction.lean path to Boneyard
- [ ] **Cross-Origin Coherence**: Change task reference 814 -> 808
- [ ] **Original IndexedMCSFamily**: Same task 814 -> 808 fix
- [ ] **Indexed MCS Family refs**: Update file paths to current Bundle/ locations
- [ ] **CoherentConstruction refs**: Update to Boneyard path and note DovetailingChain
- [ ] **Representation-First refs**: Update to current BFMCS entry points

### Low Priority (Minor/Cosmetic)

- [ ] **Single-Family BFMCS**: Fix "T-axiom `phi → Box(phi)`" -> "converse of T-axiom"
- [ ] **Representation-First**: Clarify sorry-free via FMP, not archived approach

### Potential Additions (Not Required)

Several undocumented Boneyard items could be added as Dead Ends:
- `RecursiveSeed/` (superseded by TemporalCoherentConstruction)
- `PreCoherentBundle.lean` (self-described as MATHEMATICALLY BLOCKED)
- `SyntacticApproach.lean`, `DurationConstruction.lean` (older pre-task-800 approaches)

---

## Evidence Summary

### Reflexive Semantics Evidence

| File | Line | Content |
|------|------|---------|
| `Truth.lean` | 10 | "temporal operators G and H use REFLEXIVE semantics (≤ instead of <)" |
| `Truth.lean` | 118-119 | `all_past` uses `s ≤ t`, `all_future` uses `t ≤ s` |
| `FMCSDef.lean` | 23 | "TM logic uses REFLEXIVE temporal operators with T-axioms" |
| `FMCSDef.lean` | 91, 98 | `forward_G` and `backward_H` use `≤` not `<` |
| `SoundnessLemmas.lean` | 712-728 | T-axiom validity via `le_refl` |

### Archival Status Evidence

| Directory/File | Status | Evidence |
|---------------|--------|----------|
| `Metalogic/Representation/` | ARCHIVED | `README.md`: "Status: ARCHIVED to Boneyard/Metalogic_v5/ (Task 809)" |
| `CoherentConstruction.lean` | ARCHIVED | Now at `Boneyard/Bundle/` and `Boneyard/Metalogic_v5/Representation/` |
| `IndexedMCSFamily.lean` | ARCHIVED | Now at `Boneyard/Metalogic_v5/Representation/` |

---

## Recommendations

1. **Immediate**: Fix the reflexive/irreflexive mischaracterization - this is a fundamental factual error about TM semantics
2. **Near-term**: Update all broken file paths to Boneyard locations
3. **Optional**: Add Dead End entries for undocumented Boneyard approaches

The audit found no entries that should be removed. All Dead Ends describe genuine abandoned approaches with valid lessons. The issues are path staleness and one terminology error, not fundamental mischaracterization (unlike the Strategies section).

---

## Appendix: Source Files

**Teammate A Findings**: `research-001-teammate-a-findings.md` (Strategies section)
**Teammate B Findings**: `research-001-teammate-b-findings.md` (Dead Ends section)
