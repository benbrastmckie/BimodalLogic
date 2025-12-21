# Enhanced /lean Command - Flag Reference

**Version**: 1.0  
**Last Updated**: 2025-12-20  
**Status**: Production Ready

---

## Table of Contents

1. [Overview](#overview)
2. [Flag List](#flag-list)
3. [Flag Combinations](#flag-combinations)
4. [Performance Comparison](#performance-comparison)
5. [Use Case Matrix](#use-case-matrix)
6. [Advanced Usage](#advanced-usage)

---

## Overview

### Purpose of Flags

Flags provide fine-grained control over which phases of the enhanced `/lean` command are executed. They allow you to:

- **Optimize execution time** by skipping unnecessary phases
- **Customize workflow** based on proof complexity and requirements
- **Balance speed vs. quality** according to your needs
- **Control resource usage** for large or complex proofs

### Flag Philosophy

The enhanced `/lean` command follows these principles:

1. **Intelligent Defaults**: Without flags, the command automatically determines optimal phase execution based on complexity
2. **Explicit Control**: Flags override automatic decisions for fine-grained control
3. **Safety First**: Flags can skip quality checks, but never skip core implementation
4. **Composability**: Flags can be combined for custom workflows

### Default Behavior (No Flags)

When you run `/lean NNN` without flags:

```bash
/lean 123
```

The command automatically:
1. Reads complexity level from implementation plan
2. Determines which phases to execute:
   - **Simple** (1-2 theorems): Skip Phases 1, 2, 4, 5, 6
   - **Moderate** (3-5 theorems): Skip Phase 1, execute 2, 4, 5, 6
   - **Complex** (5+ theorems): Execute all phases
3. Executes selected phases
4. Returns comprehensive summary

This provides optimal balance of speed and quality for most use cases.

---

## Flag List

### --fast

#### Description
Skip research, optimization, and documentation phases for fastest execution. Ideal for simple proofs, rapid iteration, and prototyping.

#### Phases Affected
- **Skipped**: Phase 1 (Pre-Planning), Phase 2 (Research), Phase 5 (Optimization), Phase 6 (Documentation)
- **Executed**: Phase 0 (Validation), Phase 3 (Implementation), Phase 7 (Finalization)

#### Performance Impact
- **Time Reduction**: 60-70%
- **Typical Execution**: 4-8 minutes (vs. 12-20 minutes without flag)
- **Resource Savings**: Minimal CPU/memory usage, no network calls

#### Use Cases
✅ **Good For**:
- Simple proofs (1-2 theorems)
- Quick iterations during development
- Prototyping new approaches
- When you already know the proof strategy
- Internal/private theorems
- Rapid bug fixes

❌ **Not Good For**:
- Complex proofs (5+ theorems)
- Production-ready code
- Public API theorems
- When you need documentation
- When proof optimization matters

#### Example Usage

**Basic**:
```bash
/lean 123 --fast
```

**With Context**:
```bash
# Quick iteration during development
/lean 123 --fast  # First pass
# Review implementation
/lean 123         # Second pass with quality checks
```

#### Expected Output

```
✅ Implementation Complete: Simple Helper Lemma

**Project**: #123
**Duration**: 4 minutes
**Complexity**: simple

**Phases Executed**:
- ✅ Phase 0: Input Validation (5s)
- ⏭️ Phase 1: Pre-Planning (skipped - --fast)
- ⏭️ Phase 2: Research (skipped - --fast)
- ✅ Phase 3: Implementation (3m 40s)
- ⏭️ Phase 4: Verification (skipped - simple)
- ⏭️ Phase 5: Optimization (skipped - --fast)
- ⏭️ Phase 6: Documentation (skipped - --fast)
- ✅ Phase 7: Finalization (15s)

**Files Modified**: 1
- Logos/Core/Theorems/ModalBasic.lean

**Git Commits**:
- abc123: feat(#123): Implement helper_lemma

**Artifacts**:
- Implementation Summary: .opencode/specs/123_project/summaries/implementation-summary.md
```

#### Artifacts Generated
- Implementation summary
- Git commit
- **Not Generated**: Research reports, verification reports, optimization reports, documentation analysis

#### Performance Metrics

| Metric | Without --fast | With --fast | Savings |
|--------|----------------|-------------|---------|
| Execution Time | 12-20 min | 4-8 min | 60-70% |
| Network Calls | 5-10 | 0 | 100% |
| CPU Usage | High | Low | 60% |
| Artifacts | 8-12 files | 2-3 files | 75% |

#### Comparison with Other Flags

| Aspect | --fast | --skip-research | --skip-optimization |
|--------|--------|-----------------|---------------------|
| Time Savings | 60-70% | 20-30% | 10-15% |
| Quality Checks | ❌ Skipped | ✅ Included | ✅ Included |
| Documentation | ❌ Skipped | ✅ Included | ✅ Included |
| Research | ❌ Skipped | ❌ Skipped | ✅ Included |

---

### --skip-research

#### Description
Skip pre-planning analysis and research phases. Use when you already know the proof approach and don't need library search or strategy recommendations.

#### Phases Affected
- **Skipped**: Phase 1 (Pre-Planning Analysis), Phase 2 (Research & Strategy)
- **Executed**: All other phases (0, 3, 4, 5, 6, 7)

#### Performance Impact
- **Time Reduction**: 20-30%
- **Typical Execution**: 12-15 minutes (vs. 18-20 minutes without flag)
- **Resource Savings**: No network calls to Loogle/LeanSearch

#### Use Cases
✅ **Good For**:
- You already know which Mathlib theorems to use
- You have a clear proof strategy from the plan
- The plan already contains detailed research
- Moderate proofs where research overhead isn't worth it
- Re-running after manual research

❌ **Not Good For**:
- Complex proofs where library search is valuable
- Unfamiliar proof domains
- When you want strategy recommendations
- First-time implementations in new areas

#### Example Usage

**Basic**:
```bash
/lean 456 --skip-research
```

**With Context**:
```bash
# You already researched Mathlib and know the approach
/lean 456 --skip-research

# Or: Plan already contains research
cat .opencode/specs/456_project/plans/implementation-001.md
# Shows: "Use Mathlib.Logic.Basic.imp_self and induction strategy"
/lean 456 --skip-research
```

#### Expected Output

```
✅ Implementation Complete: Modal S4 Transitivity

**Project**: #456
**Duration**: 14 minutes
**Complexity**: moderate

**Phases Executed**:
- ✅ Phase 0: Input Validation (5s)
- ⏭️ Phase 1: Pre-Planning (skipped - --skip-research)
- ⏭️ Phase 2: Research (skipped - --skip-research)
- ✅ Phase 3: Implementation (10m)
- ✅ Phase 4: Verification (1m)
- ✅ Phase 5: Optimization (2m)
- ✅ Phase 6: Documentation (1m)
- ✅ Phase 7: Finalization (20s)

**Metrics**:
- Verification: 94.5% ✅
- Code Review: 89.0% ✅
- Style Compliance: 96.0% ✅
- Optimization: 28% size reduction
- Documentation: 95.0% coverage
```

#### Artifacts Generated
- Implementation summary ✅
- Verification report ✅
- Code review ✅
- Style check ✅
- Optimization report ✅
- Documentation analysis ✅
- Examples ✅
- **Not Generated**: Complexity analysis, dependency map, library search, proof strategies, tactic recommendations

#### Performance Metrics

| Metric | Without Flag | With --skip-research | Savings |
|--------|--------------|----------------------|---------|
| Execution Time | 18-20 min | 12-15 min | 25-30% |
| Network Calls | 5-10 | 0 | 100% |
| Research Artifacts | 5 files | 0 files | 100% |
| Quality Checks | ✅ Full | ✅ Full | 0% |

#### When to Combine

**Good Combinations**:
```bash
# Skip research but keep docs
/lean 456 --skip-research

# Skip research and docs (faster)
/lean 456 --skip-research --skip-docs
```

**Redundant Combinations**:
```bash
# --fast already skips research
/lean 456 --fast --skip-research  # Redundant
```

---

### --skip-optimization

#### Description
Skip proof optimization phase. Use when proof size and compilation performance aren't critical, or when you'll optimize manually later.

#### Phases Affected
- **Skipped**: Phase 5 (Optimization)
- **Executed**: All other phases (0, 1, 2, 3, 4, 6, 7)

#### Performance Impact
- **Time Reduction**: 10-15%
- **Typical Execution**: 16-18 minutes (vs. 18-20 minutes without flag)
- **Resource Savings**: No re-verification after optimization

#### Use Cases
✅ **Good For**:
- Proof size doesn't matter (internal theorems)
- Compilation time is already fast (< 3s)
- You'll optimize manually later
- Rapid prototyping
- Short proofs (< 10 lines) where optimization has minimal impact
- When optimization keeps failing/reverting

❌ **Not Good For**:
- Large proofs (> 20 lines)
- Slow compilation (> 5s)
- Production code where performance matters
- Public API theorems
- When you want the smallest/fastest proofs

#### Example Usage

**Basic**:
```bash
/lean 456 --skip-optimization
```

**With Context**:
```bash
# Short proof where optimization won't help much
/lean 123 --skip-optimization

# Or: Optimization keeps reverting (breaking proofs)
/lean 456 --skip-optimization
# Review why optimization fails
cat .opencode/specs/456_project/reports/optimization-001.md
```

#### Expected Output

```
✅ Implementation Complete: Modal S4 Transitivity

**Project**: #456
**Duration**: 16 minutes
**Complexity**: moderate

**Phases Executed**:
- ✅ Phase 0: Input Validation (5s)
- ⏭️ Phase 1: Pre-Planning (skipped - moderate)
- ✅ Phase 2: Research (2m)
- ✅ Phase 3: Implementation (10m)
- ✅ Phase 4: Verification (1m)
- ⏭️ Phase 5: Optimization (skipped - --skip-optimization)
- ✅ Phase 6: Documentation (2m)
- ✅ Phase 7: Finalization (20s)

**Metrics**:
- Verification: 94.5% ✅
- Code Review: 89.0% ✅
- Style Compliance: 96.0% ✅
- Optimization: N/A (skipped)
- Documentation: 95.0% coverage
```

#### Artifacts Generated
- Implementation summary ✅
- Research reports ✅
- Verification report ✅
- Code review ✅
- Style check ✅
- Documentation analysis ✅
- Examples ✅
- **Not Generated**: Simplification report, optimization report, performance profile

#### Performance Metrics

| Metric | Without Flag | With --skip-optimization | Savings |
|--------|--------------|--------------------------|---------|
| Execution Time | 18-20 min | 16-18 min | 10-15% |
| Proof Size | Optimized | Original | N/A |
| Compilation Time | Optimized | Original | N/A |
| Re-verification | Yes | No | 100% |

#### Trade-offs

**What You Gain**:
- 10-15% faster execution
- No risk of optimization breaking proofs
- Original proof preserved exactly as written

**What You Lose**:
- 20-35% proof size reduction
- 15-25% compilation speedup
- Performance bottleneck identification
- Proof readability improvements

---

### --skip-docs

#### Description
Skip documentation generation phase. Use for internal theorems that don't need documentation, or when you'll write documentation manually.

#### Phases Affected
- **Skipped**: Phase 6 (Documentation)
- **Executed**: All other phases (0, 1, 2, 3, 4, 5, 7)

#### Performance Impact
- **Time Reduction**: 5-10%
- **Typical Execution**: 17-18 minutes (vs. 18-20 minutes without flag)
- **Resource Savings**: No example generation or docstring creation

#### Use Cases
✅ **Good For**:
- Internal/private theorems
- Helper lemmas that don't need documentation
- When you'll write documentation manually
- Rapid prototyping
- When documentation will be added in a separate pass
- Test files

❌ **Not Good For**:
- Public API theorems
- Complex theorems that need examples
- Production code
- When documentation coverage matters
- Theorems that will be used by others

#### Example Usage

**Basic**:
```bash
/lean 456 --skip-docs
```

**With Context**:
```bash
# Internal helper lemma
/lean 123 --skip-docs

# Batch implementation, document later
/lean 123 --skip-docs
/lean 124 --skip-docs
/lean 125 --skip-docs
# Later: Add documentation
/lean 123  # Re-run without --skip-docs
/lean 124
/lean 125
```

#### Expected Output

```
✅ Implementation Complete: Modal S4 Transitivity

**Project**: #456
**Duration**: 17 minutes
**Complexity**: moderate

**Phases Executed**:
- ✅ Phase 0: Input Validation (5s)
- ⏭️ Phase 1: Pre-Planning (skipped - moderate)
- ✅ Phase 2: Research (2m)
- ✅ Phase 3: Implementation (10m)
- ✅ Phase 4: Verification (1m)
- ✅ Phase 5: Optimization (3m)
- ⏭️ Phase 6: Documentation (skipped - --skip-docs)
- ✅ Phase 7: Finalization (20s)

**Metrics**:
- Verification: 94.5% ✅
- Code Review: 89.0% ✅
- Style Compliance: 96.0% ✅
- Optimization: 28% size reduction
- Documentation: N/A (skipped)
```

#### Artifacts Generated
- Implementation summary ✅
- Research reports ✅
- Verification report ✅
- Code review ✅
- Style check ✅
- Optimization report ✅
- **Not Generated**: Examples, docstrings, documentation gap analysis

#### Performance Metrics

| Metric | Without Flag | With --skip-docs | Savings |
|--------|--------------|------------------|---------|
| Execution Time | 18-20 min | 17-18 min | 5-10% |
| Documentation Coverage | 90-95% | 0% | N/A |
| Examples Generated | 3-5 | 0 | 100% |
| Docstrings Created | 5-10 | 0 | 100% |

#### Adding Documentation Later

You can always add documentation later by re-running without the flag:

```bash
# First pass: No docs
/lean 456 --skip-docs

# Later: Add docs
/lean 456
# Only Phase 6 executes (others already complete)
```

---

### --full

#### Description
Execute all phases regardless of complexity level. Overrides automatic phase skipping for maximum thoroughness and quality assurance.

#### Phases Affected
- **Skipped**: None
- **Executed**: All phases (0, 1, 2, 3, 4, 5, 6, 7)

#### Performance Impact
- **Time Reduction**: 0% (maximum thoroughness)
- **Typical Execution**: 30-45 minutes for complex proofs
- **Resource Savings**: None (maximum resource usage)

#### Use Cases
✅ **Good For**:
- Complex proofs (5+ theorems, multi-file)
- Production-ready code
- Public API theorems
- Critical correctness proofs
- When you want maximum quality assurance
- First-time implementations in new areas
- High-stakes proofs

❌ **Not Good For**:
- Simple proofs (1-2 theorems) - wasteful
- Rapid prototyping
- Quick iterations
- When time is limited
- Internal/private theorems

#### Example Usage

**Basic**:
```bash
/lean 789 --full
```

**With Context**:
```bash
# Complex completeness theorem - want full quality
/lean 789 --full

# Or: Override automatic skipping for simple proof
/lean 123 --full  # Normally would skip phases, but --full forces all
```

#### Expected Output

```
✅ Implementation Complete: Completeness Theorem for Bimodal Logic

**Project**: #789
**Duration**: 32 minutes
**Complexity**: complex

**Phases Executed**:
- ✅ Phase 0: Input Validation (5s)
- ✅ Phase 1: Pre-Planning (1m)
- ✅ Phase 2: Research (2m)
- ✅ Phase 3: Implementation (25m)
- ✅ Phase 4: Verification (1m 30s)
- ✅ Phase 5: Optimization (3m)
- ✅ Phase 6: Documentation (1m 30s)
- ✅ Phase 7: Finalization (30s)

**Metrics**:
- Verification: 91.5% ✅
- Code Review: 87.5% ✅
- Style Compliance: 93.0% ✅
- Optimization: 27% size reduction, 22% faster
- Documentation: 92.0% coverage

**Files Modified**: 5
- Logos/Core/Metalogic/Completeness.lean
- Logos/Core/Semantics/CanonicalModel.lean
- LogosTest/Core/Metalogic/CompletenessTest.lean
- Documentation/Reference/COMPLETENESS.md
- Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

**Artifacts**: (13 files generated)
```

#### Artifacts Generated
All possible artifacts:
- Implementation summary ✅
- Complexity analysis ✅
- Dependency map ✅
- Library search results ✅
- Proof strategies ✅
- Tactic recommendations ✅
- Verification report ✅
- Code review ✅
- Style check ✅
- Simplification report ✅
- Optimization report ✅
- Performance profile ✅ (if triggered)
- Documentation analysis ✅
- Examples ✅

#### Performance Metrics

| Metric | Simple Proof | Moderate Proof | Complex Proof |
|--------|--------------|----------------|---------------|
| Execution Time | 15-20 min | 25-35 min | 30-45 min |
| Artifacts | 13-15 files | 13-15 files | 13-15 files |
| Quality Checks | ✅ All | ✅ All | ✅ All |
| Documentation | ✅ Full | ✅ Full | ✅ Full |

#### When to Use

**Always Use --full For**:
- Production releases
- Public API changes
- Critical theorems
- Multi-file implementations
- Completeness/soundness proofs
- First implementation in new domain

**Consider --full For**:
- Moderate proofs where quality is critical
- When you want comprehensive reports
- Learning/educational purposes
- Code reviews

**Don't Use --full For**:
- Simple proofs (wasteful)
- Rapid prototyping
- Internal helper lemmas
- Quick bug fixes

---

## Flag Combinations

### Valid Combinations

Flags can be combined for custom workflows. Here are common and useful combinations:

#### --skip-research --skip-docs

**Purpose**: Moderate time savings while keeping quality checks

**Time Savings**: 25-35%

**Use Case**: You know the approach and don't need documentation

**Example**:
```bash
/lean 456 --skip-research --skip-docs
```

**Phases Executed**: 0, 3, 4, 5, 7

**Good For**:
- Internal theorems with known approach
- Re-implementations
- When plan contains research

---

#### --skip-optimization --skip-docs

**Purpose**: Keep research and quality, skip polish

**Time Savings**: 15-20%

**Use Case**: Want research and verification, but not optimization/docs

**Example**:
```bash
/lean 456 --skip-optimization --skip-docs
```

**Phases Executed**: 0, 1, 2, 3, 4, 7

**Good For**:
- First pass on complex proofs
- When you'll optimize manually
- Internal theorems

---

#### --fast --skip-docs

**Purpose**: Maximum speed (redundant but explicit)

**Time Savings**: 60-70%

**Use Case**: Absolute fastest execution

**Example**:
```bash
/lean 123 --fast --skip-docs
```

**Note**: Redundant because `--fast` already skips docs, but makes intent explicit

**Phases Executed**: 0, 3, 7

---

### Invalid/Conflicting Combinations

#### --full --fast

**Conflict**: `--full` means "execute all", `--fast` means "skip most"

**Resolution**: `--full` takes precedence (all phases executed)

**Example**:
```bash
/lean 123 --full --fast
# Result: All phases executed (--full wins)
```

**Warning**: This combination is illogical and will generate a warning

---

#### --full --skip-*

**Conflict**: `--full` means "execute all", `--skip-*` means "skip specific"

**Resolution**: `--full` takes precedence (all phases executed)

**Example**:
```bash
/lean 123 --full --skip-research
# Result: All phases executed (--full wins)
```

**Warning**: This combination is illogical and will generate a warning

---

### Recommended Combinations by Use Case

#### Rapid Prototyping
```bash
/lean 123 --fast
```
- Fastest execution
- Minimal artifacts
- No quality checks

---

#### Internal Theorems
```bash
/lean 456 --skip-docs
# or
/lean 456 --skip-research --skip-docs
```
- Good quality
- No documentation overhead
- Moderate speed

---

#### Production Code (Known Approach)
```bash
/lean 456 --skip-research
```
- Full quality checks
- Full documentation
- Skip research overhead

---

#### Production Code (Unknown Approach)
```bash
/lean 789 --full
```
- Maximum quality
- Full research
- Comprehensive reports

---

#### Batch Implementation
```bash
# First pass: Fast implementation
/lean 123 --fast
/lean 124 --fast
/lean 125 --fast

# Second pass: Add quality
/lean 123
/lean 124
/lean 125
```

---

## Performance Comparison

### Execution Time by Flag Combination

| Flag Combination | Simple (1-2 thm) | Moderate (3-5 thm) | Complex (5+ thm) |
|------------------|------------------|--------------------|--------------------|
| (none - default) | 4-8 min | 15-25 min | 30-45 min |
| --fast | 3-5 min | 8-12 min | 15-20 min |
| --skip-research | 3-6 min | 12-18 min | 25-35 min |
| --skip-optimization | 4-7 min | 14-22 min | 28-40 min |
| --skip-docs | 4-7 min | 14-23 min | 28-42 min |
| --full | 15-20 min | 25-35 min | 30-45 min |
| --skip-research --skip-docs | 3-5 min | 10-15 min | 20-30 min |
| --skip-optimization --skip-docs | 3-6 min | 12-20 min | 25-38 min |

### Phase Execution Matrix

| Flag Combination | P0 | P1 | P2 | P3 | P4 | P5 | P6 | P7 |
|------------------|----|----|----|----|----|----|----|----|
| (none - simple) | ✅ | ⏭️ | ⏭️ | ✅ | ⏭️ | ⏭️ | ⏭️ | ✅ |
| (none - moderate) | ✅ | ⏭️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| (none - complex) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| --fast | ✅ | ⏭️ | ⏭️ | ✅ | ⏭️ | ⏭️ | ⏭️ | ✅ |
| --skip-research | ✅ | ⏭️ | ⏭️ | ✅ | ✅ | ✅ | ✅ | ✅ |
| --skip-optimization | ✅ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ✅ | ✅ |
| --skip-docs | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ✅ |
| --full | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Legend**:
- ✅ = Executed
- ⏭️ = Skipped
- P0 = Phase 0 (Validation)
- P1 = Phase 1 (Pre-Planning)
- P2 = Phase 2 (Research)
- P3 = Phase 3 (Implementation)
- P4 = Phase 4 (Verification)
- P5 = Phase 5 (Optimization)
- P6 = Phase 6 (Documentation)
- P7 = Phase 7 (Finalization)

### Artifact Generation Matrix

| Flag Combination | Impl | Cmplx | Deps | Lib | Strat | Tact | Verif | Review | Style | Opt | Perf | Docs | Ex |
|------------------|------|-------|------|-----|-------|------|-------|--------|-------|-----|------|------|-----|
| (none - simple) | ✅ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ |
| (none - moderate) | ✅ | ⏭️ | ⏭️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ✅ | ✅ |
| (none - complex) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| --fast | ✅ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ |
| --skip-research | ✅ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ⏭️ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ✅ | ✅ |
| --skip-optimization | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ⏭️ | ✅ | ✅ |
| --skip-docs | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ⏭️ | ⏭️ |
| --full | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Legend**:
- Impl = Implementation Summary
- Cmplx = Complexity Analysis
- Deps = Dependency Map
- Lib = Library Search
- Strat = Proof Strategies
- Tact = Tactic Recommendations
- Verif = Verification Report
- Review = Code Review
- Style = Style Check
- Opt = Optimization Report
- Perf = Performance Profile
- Docs = Documentation Analysis
- Ex = Examples

### Resource Usage Comparison

| Flag Combination | CPU Usage | Memory Usage | Disk I/O | Network Calls |
|------------------|-----------|--------------|----------|---------------|
| (none - simple) | Low | Low | Low | 0 |
| (none - moderate) | Medium | Medium | Medium | 5-10 |
| (none - complex) | High | High | High | 10-15 |
| --fast | Low | Low | Low | 0 |
| --skip-research | Medium | Medium | Medium | 0 |
| --skip-optimization | Medium | Medium | Low | 5-10 |
| --skip-docs | Medium | Medium | Medium | 5-10 |
| --full | High | High | High | 10-15 |

---

## Use Case Matrix

### By Proof Complexity

| Complexity | Recommended Flag | Reasoning |
|------------|------------------|-----------|
| Simple (1-2 thm) | `--fast` | Research/optimization overhead not worth it |
| Moderate (3-5 thm) | (none) | Automatic phase selection optimal |
| Complex (5+ thm) | `--full` | Maximum quality assurance valuable |

### By Development Stage

| Stage | Recommended Flag | Reasoning |
|-------|------------------|-----------|
| Prototyping | `--fast` | Rapid iteration, minimal overhead |
| Development | (none) or `--skip-docs` | Balance speed and quality |
| Pre-Production | `--skip-research` | Known approach, full quality |
| Production | `--full` | Maximum quality and documentation |

### By Theorem Visibility

| Visibility | Recommended Flag | Reasoning |
|------------|------------------|-----------|
| Private/Internal | `--skip-docs` | Documentation not needed |
| Module-Level | (none) | Standard quality and docs |
| Public API | `--full` | Maximum quality and docs |
| Critical/Core | `--full` | Highest quality assurance |

### By Time Constraints

| Time Available | Recommended Flag | Reasoning |
|----------------|------------------|-----------|
| < 10 min | `--fast` | Only core implementation |
| 10-20 min | `--skip-research --skip-docs` | Moderate quality, no extras |
| 20-30 min | (none) | Standard execution |
| > 30 min | `--full` | Maximum thoroughness |

### By Quality Requirements

| Quality Level | Recommended Flag | Reasoning |
|---------------|------------------|-----------|
| Prototype | `--fast` | Minimal quality checks |
| Development | `--skip-docs` | Good quality, no docs |
| Production | (none) | Full quality |
| Critical | `--full` | Maximum quality assurance |

---

## Advanced Usage

### Conditional Flag Usage

Use flags conditionally based on plan metadata:

```bash
# Read complexity from plan
COMPLEXITY=$(grep "Complexity:" .opencode/specs/123_project/plans/implementation-001.md | awk '{print $2}')

# Choose flags based on complexity
if [ "$COMPLEXITY" = "simple" ]; then
  /lean 123 --fast
elif [ "$COMPLEXITY" = "moderate" ]; then
  /lean 123 --skip-docs
else
  /lean 123 --full
fi
```

### Iterative Refinement

Use different flags for different passes:

```bash
# Pass 1: Fast implementation
/lean 123 --fast

# Pass 2: Add quality checks
/lean 123 --skip-docs

# Pass 3: Add documentation
/lean 123
```

### Batch Processing

Process multiple projects with consistent flags:

```bash
# Batch implementation without docs
for i in 123 124 125; do
  /lean $i --skip-docs
done

# Later: Add documentation
for i in 123 124 125; do
  /lean $i
done
```

### CI/CD Integration

Use flags in continuous integration:

```bash
# CI script
if [ "$CI_STAGE" = "test" ]; then
  # Fast execution for testing
  /lean $PROJECT_NUM --fast
elif [ "$CI_STAGE" = "production" ]; then
  # Full quality for production
  /lean $PROJECT_NUM --full
fi
```

### Performance Profiling

Compare performance with different flags:

```bash
# Measure baseline
time /lean 123

# Measure with --fast
time /lean 123 --fast

# Measure with --skip-research
time /lean 123 --skip-research

# Compare results
```

### Custom Workflows

Create custom workflows with flag combinations:

```bash
# Workflow 1: Research-heavy
/lean 789 --skip-optimization --skip-docs
# Review research artifacts
cat .opencode/specs/789_project/research/*.md
# Add optimization and docs later
/lean 789

# Workflow 2: Quality-focused
/lean 456 --skip-research
# Review quality reports
cat .opencode/specs/456_project/reports/*.md
# Address issues and re-run
/lean 456 --skip-research

# Workflow 3: Documentation-focused
/lean 123 --fast
# Implement quickly
/lean 123 --skip-research --skip-optimization
# Add docs only
```

---

## Summary

### Quick Reference

| Goal | Flag | Time Savings |
|------|------|--------------|
| Fastest execution | `--fast` | 60-70% |
| Skip research | `--skip-research` | 20-30% |
| Skip optimization | `--skip-optimization` | 10-15% |
| Skip documentation | `--skip-docs` | 5-10% |
| Maximum quality | `--full` | 0% (most thorough) |

### Decision Tree

```
What's your priority?

Speed
├─ Maximum speed → --fast
├─ Moderate speed → --skip-research --skip-docs
└─ Balanced → (none)

Quality
├─ Maximum quality → --full
├─ Good quality, no docs → --skip-docs
└─ Balanced → (none)

Specific Needs
├─ Known approach → --skip-research
├─ Don't care about size → --skip-optimization
├─ Internal theorem → --skip-docs
└─ Production code → --full
```

### Best Practices

1. **Start with defaults**: Let the command choose phases automatically
2. **Use --fast for prototyping**: Iterate quickly, add quality later
3. **Use --full for production**: Maximum quality for critical code
4. **Combine flags judiciously**: Understand what each flag skips
5. **Review artifacts**: Even with flags, review generated artifacts
6. **Iterate**: Use different flags for different passes

---

**For more information**:
- User Guide: `user-guide.md`
- Example Scenarios: `example-scenarios.md`
- Migration Guide: `migration-guide.md`
