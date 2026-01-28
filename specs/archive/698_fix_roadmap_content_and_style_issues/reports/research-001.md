# Research Report: Task #698

**Task**: Fix ROAD_MAP.md content and style issues
**Date**: 2026-01-28
**Focus**: Analyze ROAD_MAP.md to understand content/style issues from FIX: and NOTE: tags. Examine actual Lean source code in Logos/ to verify architecture table accuracy. Document current state vs desired state for each issue.

## Summary

The ROAD_MAP.md file contains 8 embedded FIX/NOTE tags identifying content and style issues. The most significant finding is that the architecture tables reference file paths from the deprecated Metalogic_v2 structure (now in Boneyard), while the actual active code is in a different location (`Theories/Bimodal/Metalogic/`) with a different architecture.

## Findings

### Issue 1: Architecture Tables (Lines 22-50) - FIX Tag

**Current State** (Line 22 comment: `FIX: these need to be updated based on the actual lean source code`):

The table at lines 26-50 claims these file paths exist:
- `Soundness/Soundness.lean`
- `Core/DeductionTheorem.lean`
- `Core/MaximalConsistent.lean`
- `Representation/CanonicalModel.lean`
- `Representation/TruthLemma.lean`
- `Representation/RepresentationTheorem.lean`
- `Completeness/WeakCompleteness.lean`
- `Completeness/StrongCompleteness.lean`
- `Representation/FiniteModelProperty.lean`
- `Applications/Compactness.lean`

**Actual State**:

The active Metalogic code is at `Theories/Bimodal/Metalogic/` with structure:
```
Metalogic/
├── Core/
│   ├── Core.lean
│   └── MaximalConsistent.lean
├── Representation/
│   ├── CanonicalWorld.lean
│   ├── CanonicalHistory.lean
│   ├── CoherentConstruction.lean
│   ├── IndexedMCSFamily.lean
│   ├── TaskRelation.lean
│   ├── TruthLemma.lean
│   └── UniversalCanonicalModel.lean
├── Metalogic.lean
└── README.md
```

The old Metalogic_v2 structure with `Soundness/`, `Completeness/`, `Applications/` directories is in `Boneyard/Metalogic_v2/` (deprecated).

**Desired State**:
- Update tables to reflect actual current file structure
- Remove references to deprecated Soundness/Completeness/Applications subdirectories
- Document actual proven vs sorry status based on grep search (found 20+ sorries in active code)

### Issue 2: Historical Language "Key Architectural Achievement" (Line 52) - FIX Tag

**Current State**:
```markdown
#### Key Architectural Achievement

**Representation-First Design**: The architecture places canonical model construction as the foundation...
```

**Desired State**:
- Remove heading "Key Architectural Achievement"
- Rename to neutral "Architecture" or "Design"
- State the architecture factually without value language like "significant improvement"

### Issue 3: Diagram Order (Line 58) - FIX Tag

**Current State** (Line 58: `FIX: reverse the order so that foundations come above and derived comes below`):
```
Applications (Compactness)
    ↓
Completeness (Strong, Weak)
    ↓
FMP (Central Bridge)
    ↓
Representation (Canonical Model, Truth Lemma)
    ↓
Core (Soundness, Deduction, MCS)
```

**Desired State**:
```
Core (Soundness, Deduction, MCS)
    ↓
Representation (Canonical Model, Truth Lemma)
    ↓
FMP (Central Bridge)
    ↓
Completeness (Strong, Weak)
    ↓
Applications (Compactness)
```

### Issue 4: Remove Emojis (Line 72) - NOTE Tag

**Current State**: The document uses checkmark emojis throughout:
- Line 18: `### ✅ Metalogic_v2: Representation-First Architecture`
- Line 74: `### ✅ Bimodal/Metalogic: Universal Parametric Representation Theorem`
- Line 168: `### ✅ Syntax and Semantics`
- Line 176: `### ✅ Decidability Infrastructure`

**Desired State**:
- Remove all checkmark emojis
- Replace with plain text like `### Metalogic_v2: Representation-First Architecture (Complete)`
- Note: Unicode characters (arrows, etc.) are acceptable per the comment

### Issue 5: Historical Language "Key Innovation" (Lines 80, 82) - NOTE Tag

**Current State**:
```markdown
#### Key Innovation: Indexed MCS Family Approach

**Problem Solved**: The previous "same-MCS-at-all-times" approach required...
```

**Desired State**:
- Remove "Key Innovation" heading or rename to "Approach" or "Design"
- Remove "Problem Solved" framing
- State the approach directly: "The indexed family approach uses temporal coherence conditions..."

### Issue 6: Design Comparison Table (Line 131) - NOTE Tag

**Current State** (Line 131: `NOTE: I don't need past comparisons which also fall under historical language`):
```markdown
#### Design Comparison

| Aspect | Metalogic_v2 (Semantic) | Bimodal/Metalogic (Parametric) |
...
```

**Desired State**:
- Remove the entire comparison table
- The table contains historical framing ("significant improvement", "avoided by design")
- If comparison is needed, keep only factual differences without value judgments

### Issue 7: Links to Reports (Line 156) - NOTE Tag

**Current State**:
```markdown
#### Research Documentation

- Research report: `specs/archive/654_.../reports/research-004.md`
- Implementation plan: `specs/archive/654_.../plans/implementation-004.md`
- Implementation summary: `specs/archive/654_.../summaries/implementation-summary-20260120.md`
```

**Desired State**:
- Remove this entire section
- Internal development artifacts don't belong in a user-facing roadmap
- The roadmap should focus on project status and future work, not task history

### Issue 8: Second Architecture Table (Line 166) - FIX Tag

**Current State** (Line 166: `FIX: Check that these tables are accurate by comparing the lean source code`):

Tables at lines 170-185 claim:
- `Decidability/Tableau.lean`
- `Decidability/Saturation.lean`
- `Decidability/BranchClosure.lean`
- `Decidability/DecisionProcedure.lean`
- `Decidability/Correctness.lean`

**Actual State**:
- These files exist only in `Boneyard/Metalogic_v2/Decidability/` (deprecated)
- No active Decidability implementation outside Boneyard
- The roadmap claims `[COMPLETE]` status but the code is in deprecated directory

**Desired State**:
- Either: Mark as deprecated/incomplete and reference Boneyard location
- Or: Accurately describe that decidability work is paused/incomplete
- Update status markers to reflect actual sorry count

### Issue 9: Initial Phase for Proofs/Boneyard (Line 188) - FIX Tag

**Current State** (Line 188: `FIX: include an initial phase here devoted to finishing the proof in full, porting elements over from the Boneyard as needed`):

Phase 1 starts at line 190 with "Proof Quality and Organization" - there is no "Phase 0" for completing proofs.

**What "Boneyard elements" means**:
The Boneyard (`Theories/Bimodal/Boneyard/`) contains:
1. `Metalogic_v2/` - Previous completeness approach with:
   - Working deduction theorem, lindenbaum lemma
   - Soundness proofs
   - Some completeness infrastructure
2. `SyntacticApproach.lean` - Deprecated syntactic approach
3. `DurationConstruction.lean` - Deprecated duration algebra

Potentially reusable elements from Boneyard:
- `Core/DeductionTheorem.lean` - Deduction theorem proofs
- `Core/MaximalConsistent.lean` - MCS properties
- `Soundness/` - Soundness lemmas
- `Decidability/` - Tableau/saturation infrastructure

**Desired State**:
Add a "Phase 0: Complete Core Proofs" section before Phase 1 that includes:
1. Audit and eliminate sorries in active `Metalogic/` directory (currently 20+)
2. Port proven elements from `Boneyard/Metalogic_v2/Core/` if applicable
3. Decide whether to deprecate or resurrect `Decidability/` infrastructure
4. Document clear sorry-free theorem inventory

## Recommendations

### Priority Order for Implementation

1. **Architecture tables (Issues 1, 8)**: Most critical - currently misleading about file structure
2. **Emoji removal (Issue 4)**: Easy mechanical change
3. **Historical language (Issues 2, 5, 6)**: Medium effort, improves neutrality
4. **Diagram order (Issue 3)**: Simple reversal
5. **Report links (Issue 7)**: Simple removal
6. **Initial phase (Issue 9)**: Requires writing new content based on Boneyard analysis

### Specific Text Changes Required

| Line | Current | Change To |
|------|---------|-----------|
| 18 | `### ✅ Metalogic_v2:` | `### Metalogic_v2:` |
| 54 | `#### Key Architectural Achievement` | `#### Architecture` |
| 56 | Remove "significant improvement" language | State architecture factually |
| 60-70 | Diagram (top-down) | Reverse to bottom-up |
| 74 | `### ✅ Bimodal/Metalogic:` | `### Bimodal/Metalogic:` |
| 82 | `#### Key Innovation:` | `#### Approach:` |
| 84 | `**Problem Solved**:` | Remove, state directly |
| 133-143 | Design Comparison table | Remove entirely |
| 158-162 | Research Documentation section | Remove entirely |
| 168, 176 | `### ✅ ...` | Remove emojis |

## References

- `specs/ROAD_MAP.md` - Source file with FIX/NOTE tags
- `Theories/Bimodal/Metalogic/` - Active metalogic code
- `Theories/Bimodal/Boneyard/` - Deprecated code archive
- `Theories/Bimodal/Metalogic/README.md` - Current architecture documentation

## Next Steps

Run `/plan 698` to create an implementation plan for making these changes systematically.
