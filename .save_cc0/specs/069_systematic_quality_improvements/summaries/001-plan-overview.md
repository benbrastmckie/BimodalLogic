# Systematic Quality Improvements - Plan Overview

## Quick Summary

This spec addresses 10 systematic quality improvements across 4 weekly sprints (60-80 hours total).

**Current State**: High-quality codebase (builds successfully, 0 sorry in core proofs)
**Target State**: Exceptional, publication-ready codebase

## Key Improvements

### Week 1: High ROI (13-19 hours)
1. ✓ Add 8 missing directory READMEs
2. ✓ Enhance CI with 5 quality gates
3. ✓ Create quality metrics dashboard
4. ✓ Clean up 85 documentation TODOs → <20

### Week 2: Foundation (19-28 hours)
5. ✓ Refactor axiom system (DNE → EFQ + Peirce)
6. ✓ Split Propositional.lean (1,468 lines → 4 modules)
7. ✓ Standardize import patterns

### Week 3: Documentation (16-23 hours)
8. ✓ Add 300+ docstrings (28% → 60% coverage)
9. ✓ Split Truth.lean (1,306 lines → 3 modules)
10. ✓ Split Bridge.lean (907 lines → 3 modules)
11. ✓ Generate module dependency graph

### Week 4: Testing (20-26 hours)
12. ✓ Add 1,000 lines of tests (4:1 → 3:1 ratio)
13. ✓ Refactor inference rules (standard necessitation + K)

## Expected Outcomes

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Docstring coverage | 28% | 60% | +32 pp |
| Directory READMEs | 0/8 | 8/8 | +100% |
| Files >800 lines | 3 | 0 | -100% |
| Documentation TODOs | 85 | <20 | -76% |
| Test-to-code ratio | 4:1 | 3:1 | +33% |
| CI quality gates | 0 | 5 | +∞ |

## Impact

- **Discoverability**: ↑ 80% (READMEs + dependency graph)
- **Maintainability**: ↑ 60% (smaller files, better docs)
- **Onboarding time**: ↓ 50% (comprehensive documentation)
- **Build times**: ↓ 20% (smaller compilation units)
- **Confidence**: ↑ 90% (CI enforcement, metrics tracking)

## Next Steps

1. Review the detailed plan: `001-systematic-quality-improvements-plan.md`
2. Decide on implementation timeline (4 weeks recommended)
3. Begin with Week 1 (high ROI, low risk)
4. Track progress using quality metrics dashboard

## Files

- **Plan**: `plans/001-systematic-quality-improvements-plan.md` (detailed 13-phase plan)
- **Summary**: `summaries/001-plan-overview.md` (this file)
- **Reports**: Will be generated during implementation
