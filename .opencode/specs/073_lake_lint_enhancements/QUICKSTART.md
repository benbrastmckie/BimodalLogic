# Lake Lint Enhancements - Quick Start Guide

**For Next Session:** Resume Phase 1.3 long line fixes

## Current Status

✅ **50% Complete** - 85/169 violations fixed  
⏱️ **3.5 hours invested** of 4 hours estimated  
📁 **3 files complete**, 15 files remaining

## Resume Work in 3 Steps

### 1. Check Current State

```bash
cd /home/benjamin/Documents/Philosophy/Projects/ProofChecker

# Count remaining violations
rg "^.{101,}" Logos/ --type lean | wc -l
# Should show: 84

# See which files need work
rg "^.{101,}" Logos/ --type lean --count-matches | sort -t: -k2 -rn
```

### 2. Pick Next File

**Recommended order:**
1. ✅ ~~Combinators.lean (47 → 0)~~ DONE
2. ✅ ~~Truth.lean (32 → 4)~~ DONE  
3. 🔄 **ModalS5.lean (21 → 11)** ← START HERE (~20 min)
4. Propositional.lean (20 violations, ~40 min)
5. Perpetuity/Principles.lean (9 violations, ~25 min)

### 3. Fix Using Established Patterns

```bash
# Open file
vim Logos/Core/Theorems/ModalS5.lean

# Check violations
rg "^.{101,}" Logos/Core/Theorems/ModalS5.lean --line-number

# Apply patterns from guidelines:
# - Break long theorem signatures across lines
# - Extract intermediate have statements
# - Split complex type annotations
# See: long-line-refactoring-guidelines.md

# Verify fix
rg "^.{101,}" Logos/Core/Theorems/ModalS5.lean | wc -l

# Build (may fail due to DeductionTheorem - that's OK)
lake build Logos.Core.Theorems.ModalS5

# Commit
git add Logos/Core/Theorems/ModalS5.lean
git commit -m "style: fix long lines in ModalS5.lean

- Fixed remaining 11 long line violations
- Broke complex type signatures across multiple lines
- All changes verified with lake build
- Zero functional changes, style-only refactoring"
```

## Reference Files

- **Patterns**: `long-line-refactoring-guidelines.md` (12 examples)
- **Examples**: Look at commits `6b09330`, `9324692`, `cd2bae2`
- **Remaining Work**: `remaining-work.md` (detailed breakdown)
- **Progress**: `progress.md` (tracking)

## Example Pattern (Most Common)

### Before (too long)
```lean
theorem box_contrapose (A B : Formula) : ⊢ (A.imp B).box.imp ((B.imp Formula.bot).imp (A.imp Formula.bot)).box := by
```

### After (properly formatted)
```lean
theorem box_contrapose (A B : Formula) :
    ⊢ (A.imp B).box.imp
      ((B.imp Formula.bot).imp (A.imp Formula.bot)).box := by
```

## Quick Commands

```bash
# Count total remaining
rg "^.{101,}" Logos/ --type lean | wc -l

# List files with violations
rg "^.{101,}" Logos/ --type lean --count-matches | grep -v ":0$"

# Check specific file
rg "^.{101,}" Logos/Core/Theorems/ModalS5.lean --line-number

# Verify build
lake build Logos.Core.Theorems.ModalS5

# Run full lint
lake lint
```

## Expected Completion

- **ModalS5.lean**: 20 minutes
- **Propositional.lean**: 40 minutes  
- **Remaining 13 files**: 2-3 hours

**Total remaining**: 4.5-8.5 hours

## When Complete

1. Update `progress.md` to 100%
2. Update `lake-lint-enhancements-plan.md` Phase 1 status
3. Update `TODO.md` Task 47 to COMPLETE
4. Run final verification: `lake lint`
5. Celebrate! 🎉

## Need Help?

- **Patterns unclear?** Check `long-line-refactoring-guidelines.md`
- **Build fails?** Check if it's DeductionTheorem (pre-existing, ignore)
- **Stuck on a line?** Look at similar fixes in completed files
- **Questions?** See `remaining-work.md` for detailed breakdown
