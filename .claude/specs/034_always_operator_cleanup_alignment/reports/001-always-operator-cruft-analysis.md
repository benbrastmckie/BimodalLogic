# Research Report: 'Always' Operator Definition Cruft Analysis

## Executive Summary

After aligning the `always` operator definition with the JPL paper (`Pφ ∧ φ ∧ Fφ` = φ at ALL times), several frame constraint definitions and their associated documentation became obsolete. This report identifies all cruft requiring cleanup.

## Key Finding

The implementation now uses **time-shift infrastructure** (`TimeShift.time_shift_preserves_truth`) for MF/TF axioms and the **correct `always` definition** for TL axiom. As a result:

1. **`BackwardPersistence`** (Soundness.lean:119-123) - **COMPLETELY UNUSED**
2. **`ModalTemporalPersistence`** (Soundness.lean:145-149) - **COMPLETELY UNUSED**

Both definitions exist in code but are never referenced by any proof.

---

## Detailed Analysis

### 1. Unused Frame Constraint Definitions

#### 1.1 BackwardPersistence (Lines 99-123)

**Location**: `Logos/Metalogic/Soundness.lean:119-123`

```lean
def BackwardPersistence (F : TaskFrame) : Prop :=
  ∀ (M : TaskModel F) (τ : WorldHistory F) (t₁ t₂ : Int) (φ : Formula),
    t₁ < t₂ →
    (∀ (s : Int) (hs : τ.domain s), s ≥ t₂ → truth_at M τ s hs φ) →
    (∀ (r : Int) (hr : τ.domain r), t₁ ≤ r → r < t₂ → truth_at M τ r hr φ)
```

**Originally for**: TL axiom (`always φ → F(Pφ)`)

**Why unused**: After aligning with JPL paper definition where `always φ = Pφ ∧ φ ∧ Fφ` (all times), the TL axiom becomes trivially valid. The proof at line 348-384 extracts past/present/future from `always` and handles all cases without BackwardPersistence.

**Evidence** (Soundness.lean:343-345):
> After aligning with the paper's definition of `always`, this axiom no longer requires frame constraints.

#### 1.2 ModalTemporalPersistence (Lines 125-149)

**Location**: `Logos/Metalogic/Soundness.lean:145-149`

```lean
def ModalTemporalPersistence (F : TaskFrame) : Prop :=
  ∀ (M : TaskModel F) (t s : Int) (φ : Formula),
    t < s →
    (∀ (σ : WorldHistory F) (hσ : σ.domain t), truth_at M σ t hσ φ) →
    (∀ (σ : WorldHistory F) (hσ : σ.domain s), truth_at M σ s hσ φ)
```

**Originally for**: MF (`□φ → □Fφ`) and TF (`□φ → F□φ`) axioms

**Why unused**: The proofs now use `TimeShift.time_shift_preserves_truth` instead. Both `modal_future_valid` (line 409-432) and `temp_future_valid` (line 462-485) use time-shift infrastructure.

---

### 2. Outdated Documentation in Soundness.lean

The following docstrings/comments incorrectly claim frame constraints are required:

| Lines | Content | Issue |
|-------|---------|-------|
| 19-20 | "specific frame properties (BackwardPersistence, ModalTemporalPersistence) not guaranteed" | Misleading - no longer needed |
| 33 | "TL axiom (conditional on BackwardPersistence)" | Incorrect - now unconditional |
| 34-35 | "MF/TF axiom (conditional on ModalTemporalPersistence)" | Incorrect - now use time-shift |
| 45-47 | "Requires BackwardPersistence/ModalTemporalPersistence frame property" | Obsolete |
| 52-57 | "Frame Constraint Analysis" section | Entire section is misleading |
| 59-62 | "MVP Approach: Option B (Conditional Validity Documentation)" | No longer applies |
| 399 | "Frame Constraint Required (MVP): ModalTemporalPersistence" | Incorrect - proof doesn't use it |
| 401-406 | MVP approach description for MF | Obsolete |
| 452 | "Frame Constraint (MVP Alternative): ModalTemporalPersistence" | Incorrect |
| 454-459 | MVP approach description for TF | Obsolete |

---

### 3. Outdated Documentation in Other Files

#### 3.1 CLAUDE.md References

**Location**: `CLAUDE.md:191`
```
- Incomplete axioms: TL, MF, TF (require frame constraints)
```
**Issue**: These axioms are now complete and don't require frame constraints.

#### 3.2 IMPLEMENTATION_STATUS.md References

**Location**: `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md:260-286`

Multiple references to frame constraints being required for modal_k, temporal_k, TL, MF, TF. These need review/update.

#### 3.3 KNOWN_LIMITATIONS.md

Likely contains outdated information about frame constraint requirements. Should be reviewed.

#### 3.4 TODO.md

May reference frame constraints as blockers. Should be reviewed.

---

### 4. Historical Specification Files (Lower Priority)

The `.claude/specs/` directory contains many historical references to BackwardPersistence and ModalTemporalPersistence in research reports and plan files. These are historical artifacts and may not need cleanup, but the list is included for completeness:

- `.claude/specs/019_research_todo_implementation_plan/reports/frame_constraints_soundness_analysis.md`
- `.claude/specs/019_research_todo_implementation_plan/reports/task_semantics_alignment_analysis.md`
- `.claude/specs/019_research_todo_implementation_plan/summaries/*.md`
- `.claude/specs/025_soundness_automation_implementation/reports/*.md`
- Multiple backup plan files

---

## Recommendations

### High Priority (Source Code)

1. **Remove `BackwardPersistence` definition** (Soundness.lean:99-123)
   - Definition is completely unused
   - Keep as comment if historical context desired

2. **Remove `ModalTemporalPersistence` definition** (Soundness.lean:125-149)
   - Definition is completely unused
   - Keep as comment if historical context desired

3. **Update Soundness.lean docstrings** (lines 1-70)
   - Remove all references to conditional validity
   - Remove "MVP Approach" description
   - Update axiom validity descriptions to reflect they're unconditional

4. **Update theorem docstrings** for `modal_future_valid` and `temp_future_valid`
   - Remove "Frame Constraint Required" sections
   - Document actual proof strategy (time-shift)

### Medium Priority (Documentation)

5. **Update CLAUDE.md**
   - Remove "require frame constraints" from TL, MF, TF descriptions
   - Update implementation status

6. **Update IMPLEMENTATION_STATUS.md**
   - Reflect that TL, MF, TF are now proven without frame constraints

7. **Review KNOWN_LIMITATIONS.md**
   - Remove or update frame constraint limitation sections

### Low Priority (Historical)

8. **Consider archiving old spec files** referencing the incorrect definition
   - These are historical artifacts
   - May not need active cleanup

---

## Verification Commands

```bash
# Verify BackwardPersistence is unused in actual proofs
grep -n "BackwardPersistence" Logos/Metalogic/Soundness.lean | grep -v "def\|/--\|--"

# Verify ModalTemporalPersistence is unused in actual proofs
grep -n "ModalTemporalPersistence" Logos/Metalogic/Soundness.lean | grep -v "def\|/--\|--"

# Check build still works after removal
lake build
```

---

## Conclusion

The alignment with the JPL paper's `always` operator definition made two frame constraint definitions (`BackwardPersistence`, `ModalTemporalPersistence`) completely obsolete. The codebase compiles and passes tests without them, but their presence creates confusion about what constraints are actually required. Cleanup will improve code clarity and documentation accuracy.
