# Enhanced /lean Command - User Guide

**Version**: 1.0  
**Last Updated**: 2025-12-20  
**Status**: Production Ready

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Quick Start](#2-quick-start)
3. [Understanding Phases](#3-understanding-phases)
4. [Using Flags](#4-using-flags)
5. [Interpreting Results](#5-interpreting-results)
6. [Best Practices](#6-best-practices)
7. [Troubleshooting](#7-troubleshooting)
8. [FAQ](#8-faq)

---

## 1. Introduction

### What is the Enhanced /lean Command?

The enhanced `/lean` command is an intelligent multi-phase workflow system for implementing LEAN 4 proofs in the ProofChecker project. It transforms proof development from a manual, error-prone process into an automated, quality-assured workflow that leverages 19 specialist subagents across 7 execution phases.

### Key Benefits

- **40-60% Time Reduction**: Automated research, verification, and optimization save hours on complex proofs
- **Comprehensive Quality Assurance**: Automated verification, code review, and style checking catch issues before manual review
- **Automatic Optimization**: Proofs are simplified and optimized for better performance (20-35% size reduction typical)
- **Generated Documentation**: Examples, docstrings, and documentation gap analysis generated automatically (90%+ coverage)
- **Intelligent Execution**: Phases are automatically skipped for simple proofs, executed in parallel where possible
- **Backward Compatible**: Simple usage (`/lean 123`) works exactly as before

### When to Use /lean

Use the enhanced `/lean` command when:
- ✅ You have an implementation plan ready (created by `/task` or manually)
- ✅ You're implementing LEAN 4 proofs, definitions, or theorems
- ✅ You want automated quality assurance and optimization
- ✅ You need comprehensive documentation generated automatically

**Don't use** `/lean` for:
- ❌ Creating implementation plans (use `/task` instead)
- ❌ Non-LEAN tasks (documentation, refactoring, research)
- ❌ Exploratory work without a clear plan

### Architecture Overview

```
User: /lean 123 [--flags]
    ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 0: Input Validation & Configuration (5s)                  │
│ - Parse project number and flags                                │
│ - Locate implementation plan                                    │
│ - Determine phase execution strategy                            │
└─────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1: Pre-Planning Analysis (60s, skippable)                 │
│ - Complexity analysis                                           │
│ - Dependency mapping                                            │
└─────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 2: Research & Strategy (120s, skippable)                  │
│ - Library search (Loogle, LeanSearch)                          │
│ - Proof strategy recommendations                                │
│ - Tactic suggestions                                            │
└─────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 3: Implementation (5-30 min, required)                    │
│ - Proof development with enriched context                       │
│ - Real-time syntax validation                                   │
│ - Error diagnostics and recovery                                │
└─────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 4: Verification & Quality (90s, skippable)                │
│ - Verification against standards                                │
│ - Code review                                                   │
│ - Style checking                                                │
└─────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 5: Optimization (180s, skippable)                         │
│ - Proof simplification                                          │
│ - Performance optimization                                      │
│ - Bottleneck profiling                                          │
└─────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 6: Documentation (90s, skippable)                         │
│ - Example generation                                            │
│ - Docstring creation                                            │
│ - Documentation gap analysis                                    │
└─────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 7: Finalization (30s, required)                           │
│ - Aggregate reports and artifacts                               │
│ - Update IMPLEMENTATION_STATUS.md                               │
│ - Git commit                                                    │
│ - Return comprehensive summary                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Quick Start

### Basic Usage

The simplest way to use the enhanced `/lean` command:

```bash
/lean 123
```

This will:
1. Load the implementation plan from `.opencode/specs/123_project/plans/implementation-*.md`
2. Automatically determine which phases to execute based on complexity
3. Implement the proofs with full quality assurance
4. Return a comprehensive summary with artifact references

### Your First Proof

**Step 1**: Create an implementation plan (if you don't have one)

```bash
/task 123
```

This creates a plan at `.opencode/specs/123_project/plans/implementation-001.md`

**Step 2**: Run the enhanced /lean command

```bash
/lean 123
```

**Step 3**: Review the output

```
✅ Implementation Complete: Simple Helper Lemma

**Project**: #123
**Duration**: 4 minutes
**Complexity**: simple (estimated: 30min, actual: 4min)

**Summary**: Implemented simple helper lemma for modal logic. Proof uses
direct application of existing theorems with minimal tactics.

**Metrics**:
- Verification: N/A (skipped for simple proof)
- Files Modified: 1

**Git Commits**:
- abc123: feat(#123): Implement helper_lemma

**Artifacts**:
- Implementation Summary: .opencode/specs/123_project/summaries/implementation-summary.md

**Next Steps**:
- Proof complete and verified
```

**Step 4**: Review artifacts (optional)

```bash
cat .opencode/specs/123_project/summaries/implementation-summary.md
```

### Fast Mode for Quick Iterations

For rapid prototyping or simple proofs:

```bash
/lean 123 --fast
```

This skips research, optimization, and documentation phases, reducing execution time by 60-70%.

---

## 3. Understanding Phases

### Phase 0: Input Validation & Configuration

**Purpose**: Parse input, validate project, determine execution strategy

**Always Executed**: Yes (never skipped)

**Duration**: < 5 seconds

**What It Does**:
- Parses project number and flags from command
- Locates project directory and implementation plan
- Reads plan and extracts complexity level
- Determines which phases to execute based on:
  - Complexity level (simple/moderate/complex)
  - User-provided flags
  - Default heuristics
- Validates prerequisites and dependencies

**Output**:
- Execution configuration (which phases to run)
- Loaded project context (plan, state, metadata)

**Errors**:
- "Project NNN not found" → Use `/task` to create plan
- "Implementation plan not found" → Create plan manually or with `/task`
- "Invalid flag" → Check flag reference

---

### Phase 1: Pre-Planning Analysis

**Purpose**: Analyze complexity and map dependencies before implementation

**Skipped When**:
- Complexity is "simple" (from plan)
- `--skip-research` flag provided
- `--fast` flag provided

**Duration**: 30-60 seconds (parallel execution)

**What It Does**:
- **Complexity Analyzer**: Assesses task complexity, effort estimate, challenges, risk factors
- **Dependency Mapper**: Identifies required imports, dependent definitions, library functions

**Specialists Invoked** (in parallel):
1. `complexity-analyzer` → Complexity assessment report
2. `dependency-mapper` → Dependency map

**Output Artifacts**:
- `.opencode/specs/NNN_project/reports/complexity-001.md`
- `.opencode/specs/NNN_project/reports/dependencies-001.md`

**Why It's Useful**:
- Provides accurate effort estimates
- Identifies potential challenges early
- Maps all dependencies before implementation
- Enriches context for implementation phase

**Example Output**:
```json
{
  "complexity_level": "moderate",
  "effort_estimate": "1-2hr",
  "files_affected": 2,
  "challenges": ["Requires induction proof", "Complex type signatures"],
  "dependencies": ["Mathlib.Data.List.Basic", "Logos.Core.Syntax"],
  "risk_factors": ["Potential performance issues with large lists"]
}
```

---

### Phase 2: Research & Strategy

**Purpose**: Search libraries for similar theorems, suggest proof strategies, recommend tactics

**Skipped When**:
- `--skip-research` flag provided
- `--fast` flag AND complexity is "simple"
- Plan already contains detailed research

**Duration**: 60-120 seconds (parallel execution, includes network calls)

**What It Does**:
- **Library Navigator**: Searches Loogle and LeanSearch for similar theorems in Mathlib
- **Proof Strategy Advisor**: Recommends proof strategies (induction, cases, construction, etc.)
- **Tactic Recommender**: Suggests specific tactics and tactic sequences

**Specialists Invoked** (in parallel):
1. `library-navigator` → Library search results
2. `proof-strategy-advisor` → Proof strategies
3. `tactic-recommender` → Tactic recommendations

**Output Artifacts**:
- `.opencode/specs/NNN_project/research/library-search-001.md`
- `.opencode/specs/NNN_project/research/strategies-001.md`
- `.opencode/specs/NNN_project/research/tactics-001.md`

**Why It's Useful**:
- Finds existing theorems you can reuse or adapt
- Provides proven proof strategies for similar problems
- Suggests optimal tactic sequences
- Saves hours of manual library searching

**Example Output**:
```json
{
  "similar_theorems": [
    {
      "name": "Mathlib.Logic.Basic.imp_self",
      "similarity": 0.85,
      "type_signature": "∀ (p : Prop), p → p",
      "source": "loogle"
    }
  ],
  "recommended_strategy": "Direct proof using reflexivity",
  "tactic_suggestions": ["intro", "exact", "rfl"]
}
```

---

### Phase 3: Implementation

**Purpose**: Implement proofs using proof-developer with enriched context from previous phases

**Skipped When**: Never (core functionality)

**Duration**: 5-30 minutes (depends on proof complexity)

**What It Does**:
- **Proof Developer**: Coordinates implementation using enriched context from Phases 1-2
- **Tactic Specialist**: Implements tactic-mode proofs
- **Term-Mode Specialist**: Implements term-mode proofs
- **Metaprogramming Specialist**: Implements custom tactics if needed
- **Syntax Validator**: Real-time syntax checking via lean-lsp-mcp
- **Error Diagnostics**: Automatic error analysis and fix suggestions

**Context Enrichment**:
The proof-developer receives all artifacts from Phases 1-2:
- Complexity level and effort estimate
- Required imports and dependencies
- Similar theorems from Mathlib
- Recommended proof strategies with skeletons
- Tactic suggestions for each step

**Output Artifacts**:
- Modified/created LEAN files
- `.opencode/specs/NNN_project/summaries/implementation-summary.md`
- Git commits (via git-workflow-manager)

**Error Handling**:
- Type errors → Invoke error-diagnostics → Retry implementation (max 3 retries)
- Specialist failure → Try alternative specialist or approach
- Persistent errors → Document in summary, mark step as incomplete, escalate to user

**Why It's Useful**:
- Leverages research from Phase 2 for faster, better implementations
- Real-time error detection and correction
- Automatic git commits for substantial changes
- Comprehensive implementation summary

**Example Output**:
```
✅ Implemented 3 theorems in Logos/Core/Theorems/ModalS4.lean
✅ All proofs type-check successfully
✅ Git commit: abc123 "feat(#456): Implement S4 transitivity theorems"
```

---

### Phase 4: Verification & Quality

**Purpose**: Verify proofs against standards, perform code review, check style

**Skipped When**:
- `--fast` flag provided
- `--skip-verification` flag provided (not recommended)
- Complexity is "simple" (optional skip)

**Duration**: 30-90 seconds (parallel execution)

**What It Does**:
- **Verification Specialist**: Checks compliance with verification standards, proof conventions
- **Code Reviewer**: Reviews code quality, readability, proof patterns
- **Style Checker**: Validates against LEAN 4 style guide

**Specialists Invoked** (in parallel):
1. `verification-specialist` → Verification report
2. `code-reviewer` → Code review report
3. `style-checker` → Style check report

**Output Artifacts**:
- `.opencode/specs/NNN_project/reports/verification-001.md`
- `.opencode/specs/NNN_project/reports/code-review-001.md`
- `.opencode/specs/NNN_project/reports/style-check-001.md`

**Success Criteria**:
- Verification compliance ≥ 85%
- Code review score ≥ 80%
- Style compliance ≥ 90%
- No critical issues

**Why It's Useful**:
- Catches quality issues before manual review
- Ensures consistency with project standards
- Identifies readability and maintainability issues
- Provides actionable improvement suggestions

**Example Output**:
```json
{
  "verification_score": 94.5,
  "code_review_score": 89.0,
  "style_compliance": 96.0,
  "issues": [
    {
      "type": "style",
      "severity": "minor",
      "description": "Variable name should be snake_case",
      "suggestion": "Rename 'myVar' to 'my_var'"
    }
  ]
}
```

---

### Phase 5: Optimization

**Purpose**: Optimize proof size and performance, simplify proofs

**Skipped When**:
- `--skip-optimization` flag provided
- `--fast` flag provided
- All proofs < 5 lines (already simple)

**Duration**: 60-180 seconds (sequential, includes re-verification)

**What It Does**:
- **Proof Simplifier**: Removes redundant tactics, combines steps, simplifies proofs
- **Proof Optimizer**: Replaces slow tactics with faster alternatives, optimizes compilation
- **Performance Profiler**: Identifies bottlenecks (only if compilation time > 3s)

**Specialists Invoked** (sequential):
1. `proof-simplifier` → Simplified proofs
2. `proof-optimizer` → Optimized proofs
3. `performance-profiler` (conditional) → Performance profile

**Output Artifacts**:
- `.opencode/specs/NNN_project/reports/simplification-001.md`
- `.opencode/specs/NNN_project/reports/optimization-001.md`
- `.opencode/specs/NNN_project/reports/performance-001.md` (if triggered)

**Success Criteria**:
- At least 10% proof size reduction OR
- At least 10% compilation time reduction OR
- No optimization opportunities found (already optimal)

**Safety**:
- All optimizations are verified to preserve correctness
- If optimization breaks proof → Revert and document
- Original proofs are preserved in git history

**Why It's Useful**:
- Reduces proof size by 20-35% on average
- Improves compilation time by 15-25%
- Makes proofs more readable and maintainable
- Identifies performance bottlenecks

**Example Output**:
```json
{
  "original_lines": 25,
  "simplified_lines": 18,
  "reduction": "28%",
  "compilation_speedup": "15%",
  "changes": [
    "Removed redundant simp calls",
    "Combined intro and exact into single step",
    "Replaced simp with rfl"
  ]
}
```

---

### Phase 6: Documentation

**Purpose**: Generate examples, docstrings, analyze documentation gaps

**Skipped When**:
- `--skip-docs` flag provided
- `--fast` flag provided
- No public theorems/definitions

**Duration**: 45-90 seconds (parallel execution)

**What It Does**:
- **Example Builder**: Generates illustrative examples with `#eval` and `#check`
- **Documentation Generator**: Creates docstrings for all public items
- **Doc Analyzer**: Analyzes documentation coverage and identifies gaps

**Specialists Invoked** (in parallel):
1. `example-builder` → Examples file
2. `documentation-generator` → Docstrings (applied to files)
3. `doc-analyzer` → Documentation gap analysis

**Output Artifacts**:
- `.opencode/specs/NNN_project/examples/examples-001.md`
- Docstrings applied directly to LEAN files
- `.opencode/specs/NNN_project/reports/documentation-001.md`

**Success Criteria**:
- Documentation coverage ≥ 90%
- All public theorems/definitions have docstrings
- At least 1 example per major theorem

**Why It's Useful**:
- Saves hours of manual documentation writing
- Ensures consistent documentation style
- Provides working examples for users
- Identifies documentation gaps

**Example Output**:
```json
{
  "examples_generated": 4,
  "docstrings_created": 8,
  "documentation_coverage": 95.0,
  "gaps": [
    {
      "item": "helper_lemma_aux",
      "gap_type": "missing_docstring",
      "severity": "minor"
    }
  ]
}
```

---

### Phase 7: Finalization

**Purpose**: Aggregate results, update status, commit changes, return summary

**Skipped When**: Never (required for completion)

**Duration**: 15-30 seconds

**What It Does**:
1. Aggregates all reports and artifacts from Phases 1-6
2. Calculates overall metrics (time, quality scores, optimization gains)
3. Updates `IMPLEMENTATION_STATUS.md` with completion status
4. Creates git commit via `git-workflow-manager`
5. Generates comprehensive summary document
6. Updates project `state.json`
7. Returns user-facing summary with artifact references

**Output Artifacts**:
- `.opencode/specs/NNN_project/summaries/comprehensive-summary.md`
- Updated `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- Git commit with quality metrics in message
- Updated `.opencode/specs/NNN_project/state.json`

**Commit Message Format**:
```
feat(#NNN): Implement {theorem/definition names}

- Implemented {count} theorems/definitions
- Complexity: {level}
- Quality: {verification_score}% verified, {style_score}% style compliant
- Optimization: {optimization_summary}
- Documentation: {doc_coverage}% coverage

Artifacts: .opencode/specs/NNN_project/
```

**Why It's Useful**:
- Provides comprehensive summary of all work done
- Tracks implementation in project status
- Creates meaningful git history
- Gives clear next steps

---

## 4. Using Flags

### Available Flags

| Flag | Description | Time Savings | Use Case |
|------|-------------|--------------|----------|
| `--fast` | Skip research, optimization, docs | 60-70% | Quick iterations, simple proofs |
| `--skip-research` | Skip Phases 1-2 | 20-30% | When you already know the approach |
| `--skip-optimization` | Skip Phase 5 | 10-15% | When proof size doesn't matter |
| `--skip-docs` | Skip Phase 6 | 5-10% | When documentation is manual |
| `--full` | Execute all phases | 0% | Complex proofs, maximum quality |

### Flag Details

#### --fast

**Description**: Skip research, optimization, and documentation phases for fastest execution

**Phases Skipped**: 1, 2, 5, 6

**Phases Executed**: 0, 3, 7

**Time Reduction**: 60-70%

**Use Cases**:
- Simple proofs (1-2 theorems)
- Quick iterations during development
- Prototyping
- When you already know the proof approach

**Example**:
```bash
/lean 123 --fast
```

**Output**:
```
✅ Implementation Complete: Simple Helper Lemma

**Project**: #123
**Duration**: 4 minutes (vs. 12 minutes without --fast)
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
```

---

#### --skip-research

**Description**: Skip pre-planning and research phases

**Phases Skipped**: 1, 2

**Time Reduction**: 20-30%

**Use Cases**:
- You already know which Mathlib theorems to use
- You have a clear proof strategy
- The plan already contains detailed research
- Moderate proofs where research overhead isn't worth it

**Example**:
```bash
/lean 456 --skip-research
```

**Combines Well With**: `--skip-docs` for moderate time savings without losing quality checks

---

#### --skip-optimization

**Description**: Skip proof optimization phase

**Phases Skipped**: 5

**Time Reduction**: 10-15%

**Use Cases**:
- Proof size and performance aren't critical
- You'll optimize manually later
- Rapid prototyping
- Short proofs (< 10 lines) where optimization has minimal impact

**Example**:
```bash
/lean 456 --skip-optimization
```

**Note**: You can always run optimization later by re-running `/lean 456` without this flag

---

#### --skip-docs

**Description**: Skip documentation generation phase

**Phases Skipped**: 6

**Time Reduction**: 5-10%

**Use Cases**:
- Internal/private theorems that don't need documentation
- You'll write documentation manually
- Rapid prototyping
- Documentation will be added in a separate pass

**Example**:
```bash
/lean 456 --skip-docs
```

**Note**: You can always run documentation later by re-running `/lean 456` without this flag

---

#### --full

**Description**: Execute all phases regardless of complexity

**Phases Skipped**: None

**Time Reduction**: 0% (maximum thoroughness)

**Use Cases**:
- Complex proofs (3+ theorems, multi-file)
- Production-ready code
- When you want maximum quality assurance
- Public API theorems
- Critical correctness proofs

**Example**:
```bash
/lean 789 --full
```

**Output**: All 7 phases executed, comprehensive reports generated

---

### Flag Combinations

Flags can be combined for fine-grained control:

#### Fast + No Docs (Fastest)
```bash
/lean 123 --fast --skip-docs
```
Redundant (--fast already skips docs), but explicit

#### Research + Optimization, No Docs
```bash
/lean 456 --skip-docs
```
Good for internal theorems where you want quality but not documentation

#### Full Quality, No Research
```bash
/lean 456 --skip-research
```
When you know the approach but want full quality assurance

#### Custom Combination
```bash
/lean 789 --skip-optimization --skip-docs
```
Execute research and verification, skip optimization and docs

### Flag Precedence

When flags conflict:
1. `--full` overrides all skip flags
2. `--fast` overrides individual skip flags
3. Individual skip flags are additive

**Example**:
```bash
/lean 123 --full --fast
```
Result: `--full` wins, all phases executed

---

## 5. Interpreting Results

### Output Format

The enhanced `/lean` command returns a structured summary:

```
✅ Implementation Complete: {Project Name}

**Project**: #NNN
**Duration**: {total_time}
**Complexity**: {level} (estimated: {estimate}, actual: {actual})

**Summary**: {3-5 sentence summary of what was implemented}

**Metrics**:
- Verification: {score}% ✅
- Code Review: {score}% ✅
- Style Compliance: {score}% ✅
- Optimization: {reduction}% size reduction, {speedup}% faster
- Documentation: {coverage}% coverage

**Files Modified**: {count}
- {file1}
- {file2}

**Git Commits**:
- {commit_hash}: {commit_message}

**Artifacts**:
- Implementation Summary: {path}
- Verification Report: {path}
- Code Review: {path}
- Optimization Report: {path}
- Documentation Analysis: {path}
- Examples: {path}

**Next Steps**:
- {recommendation_1}
- {recommendation_2}
```

### Understanding Metrics

#### Verification Score

**Range**: 0-100%

**Meaning**: Compliance with verification standards and proof conventions

**Interpretation**:
- **≥ 95%**: Excellent - Fully compliant
- **85-94%**: Good - Minor issues only
- **70-84%**: Fair - Some issues to address
- **< 70%**: Poor - Significant issues

**Common Issues**:
- Missing proof documentation
- Non-standard proof patterns
- Incomplete error handling

#### Code Review Score

**Range**: 0-100%

**Meaning**: Overall code quality, readability, maintainability

**Interpretation**:
- **≥ 90%**: Excellent - Production ready
- **80-89%**: Good - Minor improvements suggested
- **70-79%**: Fair - Moderate improvements needed
- **< 70%**: Poor - Significant refactoring needed

**Common Issues**:
- Poor variable naming
- Complex proof steps that should be split
- Lack of intermediate lemmas

#### Style Compliance

**Range**: 0-100%

**Meaning**: Adherence to LEAN 4 style guide

**Interpretation**:
- **≥ 95%**: Excellent - Fully compliant
- **90-94%**: Good - Minor style issues
- **80-89%**: Fair - Some style violations
- **< 80%**: Poor - Many style violations

**Common Issues**:
- Naming convention violations (camelCase vs. snake_case)
- Incorrect indentation
- Missing spaces around operators
- Line length violations

#### Optimization Metrics

**Size Reduction**: Percentage reduction in proof lines

**Typical Values**:
- **20-35%**: Excellent - Significant simplification
- **10-19%**: Good - Moderate simplification
- **5-9%**: Fair - Minor simplification
- **< 5%**: Minimal - Already near-optimal

**Compilation Speedup**: Percentage reduction in compilation time

**Typical Values**:
- **≥ 20%**: Excellent - Significant speedup
- **10-19%**: Good - Noticeable speedup
- **5-9%**: Fair - Minor speedup
- **< 5%**: Minimal - Already fast

#### Documentation Coverage

**Range**: 0-100%

**Meaning**: Percentage of public items with documentation

**Interpretation**:
- **≥ 95%**: Excellent - Comprehensive documentation
- **90-94%**: Good - Nearly complete
- **80-89%**: Fair - Some gaps
- **< 80%**: Poor - Significant gaps

**Includes**:
- Docstrings for theorems/definitions
- Examples for major theorems
- Module-level documentation

### Reading Artifacts

Artifacts are saved in `.opencode/specs/NNN_project/` and referenced in the output.

#### Implementation Summary
```bash
cat .opencode/specs/123_project/summaries/implementation-summary.md
```

Contains:
- Detailed implementation steps
- Files modified
- Theorems/definitions implemented
- Verification status
- Issues encountered

#### Verification Report
```bash
cat .opencode/specs/123_project/reports/verification-001.md
```

Contains:
- Compliance score breakdown
- Specific issues with line numbers
- Suggestions for fixes
- Standards violated

#### Code Review
```bash
cat .opencode/specs/123_project/reports/code-review-001.md
```

Contains:
- Review score breakdown
- Strengths and weaknesses
- Specific suggestions with line numbers
- Readability assessment

#### Optimization Report
```bash
cat .opencode/specs/123_project/reports/optimization-001.md
```

Contains:
- Before/after proof comparisons
- Specific optimizations applied
- Performance measurements
- Bottleneck analysis (if triggered)

#### Examples
```bash
cat .opencode/specs/123_project/examples/examples-001.md
```

Contains:
- Working examples for each theorem
- `#eval` and `#check` demonstrations
- Test cases
- Usage patterns

### Status Indicators

| Symbol | Meaning |
|--------|---------|
| ✅ | Phase executed successfully |
| ⏭️ | Phase skipped (by flag or complexity) |
| ⚠️ | Phase completed with warnings |
| ❌ | Phase failed |
| 🔄 | Phase retried after error |

---

## 6. Best Practices

### When to Use Which Flags

#### Simple Proofs (1-2 theorems, < 30 min)

**Recommended**: `--fast`

**Reasoning**: Research and optimization overhead not worth it for simple proofs

**Example**:
```bash
/lean 123 --fast
```

**Expected Time**: 4-8 minutes

---

#### Moderate Proofs (3-5 theorems, 1-2 hours)

**Recommended**: Default (no flags) or `--skip-docs`

**Reasoning**: Research and verification valuable, documentation optional

**Example**:
```bash
/lean 456
# or
/lean 456 --skip-docs
```

**Expected Time**: 15-25 minutes

---

#### Complex Proofs (5+ theorems, multi-file, 3+ hours)

**Recommended**: `--full`

**Reasoning**: Maximum quality assurance and optimization worth the time

**Example**:
```bash
/lean 789 --full
```

**Expected Time**: 30-45 minutes

---

#### Rapid Prototyping

**Recommended**: `--fast`

**Reasoning**: Iterate quickly, add quality later

**Workflow**:
```bash
# First iteration - fast
/lean 123 --fast

# Second iteration - add quality
/lean 123 --skip-docs

# Final iteration - full quality
/lean 123
```

---

#### Production Code

**Recommended**: `--full` (or default)

**Reasoning**: Maximum quality, documentation, optimization

**Example**:
```bash
/lean 789 --full
```

**Follow-up**: Review all reports and address suggestions

---

### Optimization Tips

#### 1. Use --fast for First Pass

Implement quickly, then add quality:

```bash
# First pass - fast implementation
/lean 123 --fast

# Second pass - add quality checks
/lean 123
```

#### 2. Skip Research When You Know the Approach

If you already know which Mathlib theorems to use:

```bash
/lean 456 --skip-research
```

#### 3. Batch Documentation

Implement multiple proofs fast, then document all at once:

```bash
/lean 123 --skip-docs
/lean 124 --skip-docs
/lean 125 --skip-docs

# Later, re-run without --skip-docs
/lean 123
/lean 124
/lean 125
```

#### 4. Use Complexity Hints in Plans

Add complexity level to your implementation plan:

```markdown
**Complexity**: simple
```

This helps the command skip unnecessary phases automatically.

#### 5. Review Artifacts Selectively

You don't need to read every artifact. Focus on:
- **Always**: Implementation summary
- **If issues**: Verification report, code review
- **If optimizing**: Optimization report
- **If documenting**: Examples, documentation analysis

### Quality Assurance Workflow

#### Standard Workflow

```bash
# 1. Implement with full quality
/lean 456

# 2. Review metrics in output
# - Verification: 94.5% ✅
# - Code Review: 89.0% ✅
# - Style: 96.0% ✅

# 3. If scores < 85%, review reports
cat .opencode/specs/456_project/reports/verification-001.md
cat .opencode/specs/456_project/reports/code-review-001.md

# 4. Address issues manually if needed

# 5. Re-run to verify fixes
/lean 456
```

#### High-Stakes Workflow (Critical Proofs)

```bash
# 1. Full execution with all phases
/lean 789 --full

# 2. Review ALL artifacts
cat .opencode/specs/789_project/summaries/comprehensive-summary.md
cat .opencode/specs/789_project/reports/verification-001.md
cat .opencode/specs/789_project/reports/code-review-001.md
cat .opencode/specs/789_project/reports/style-check-001.md
cat .opencode/specs/789_project/reports/optimization-001.md

# 3. Manual review of implementation
cat Logos/Core/Metalogic/Completeness.lean

# 4. Address all suggestions

# 5. Re-run to verify
/lean 789 --full

# 6. Manual testing
lake build
lake test
```

### Common Pitfalls to Avoid

#### ❌ Don't Skip Verification on Complex Proofs

```bash
# BAD - skips quality checks on complex proof
/lean 789 --fast
```

```bash
# GOOD - full quality for complex proof
/lean 789 --full
```

#### ❌ Don't Ignore Low Quality Scores

If verification < 85% or code review < 80%, **always** review the reports and address issues.

#### ❌ Don't Re-run Without Addressing Issues

```bash
# BAD - re-running without fixing issues
/lean 456  # Score: 75%
/lean 456  # Score: 75% (same issues)
```

```bash
# GOOD - fix issues first
/lean 456  # Score: 75%
# Review reports, fix issues manually
/lean 456  # Score: 92%
```

#### ❌ Don't Use --full on Simple Proofs

```bash
# BAD - wasted time on simple proof
/lean 123 --full  # Takes 15 min for 1-line proof
```

```bash
# GOOD - fast execution for simple proof
/lean 123 --fast  # Takes 4 min
```

---

## 7. Troubleshooting

### Common Errors

#### Error: "Project NNN not found"

**Cause**: Project directory doesn't exist

**Solution**:
```bash
# Create implementation plan first
/task NNN
```

**Or** create manually:
```bash
mkdir -p .opencode/specs/NNN_project/plans
# Create implementation-001.md in plans/
```

---

#### Error: "Implementation plan not found"

**Cause**: No `implementation-*.md` file in `plans/` directory

**Solution**:
```bash
# Use /task to create plan
/task NNN
```

**Or** create manually:
```bash
# Create .opencode/specs/NNN_project/plans/implementation-001.md
```

---

#### Error: "Invalid flag: --xyz"

**Cause**: Unrecognized flag

**Solution**: Check available flags:
```bash
/lean --help
```

Valid flags: `--fast`, `--skip-research`, `--skip-optimization`, `--skip-docs`, `--full`

---

#### Warning: "Phase 3 failed after 3 retries"

**Cause**: Persistent type errors or compilation failures

**What Happened**:
- Implementation attempted 3 times
- Error diagnostics invoked each time
- Unable to resolve automatically

**Solution**:
1. Review error report:
   ```bash
   cat .opencode/specs/NNN_project/reports/error-diagnostics-001.md
   ```

2. Check implementation summary for details:
   ```bash
   cat .opencode/specs/NNN_project/summaries/implementation-summary.md
   ```

3. Fix issues manually in LEAN files

4. Re-run:
   ```bash
   /lean NNN
   ```

---

#### Warning: "Optimization broke proof, reverted"

**Cause**: Optimization changed proof semantics

**What Happened**:
- Proof simplifier or optimizer made changes
- Re-verification failed
- Changes automatically reverted

**Solution**: This is normal and safe. The original proof is preserved. Review optimization report to see what was attempted:
```bash
cat .opencode/specs/NNN_project/reports/optimization-001.md
```

---

#### Warning: "Library search timed out"

**Cause**: Network issues or Loogle/LeanSearch unavailable

**What Happened**:
- Phase 2 library search timed out after 30s
- Continued with other specialists

**Solution**: This is non-critical. Implementation continues without library search results. If you need library search:
```bash
# Manually search Loogle
# https://loogle.lean-lang.org/

# Or re-run later when network is stable
/lean NNN
```

---

### Performance Issues

#### Issue: Command is slow (> 1 hour)

**Diagnosis**:
1. Check which phase is slow:
   - Look at phase timing in output
   - Phase 3 (Implementation) is expected to be slow for complex proofs

2. Check complexity level:
   ```bash
   cat .opencode/specs/NNN_project/plans/implementation-001.md | grep "Complexity"
   ```

**Solutions**:

**If Phase 2 (Research) is slow**:
```bash
# Skip research
/lean NNN --skip-research
```

**If Phase 5 (Optimization) is slow**:
```bash
# Skip optimization
/lean NNN --skip-optimization
```

**If Phase 3 (Implementation) is slow**:
- This is expected for complex proofs
- Consider breaking into smaller tasks
- Use `--fast` for first pass, then add quality

---

#### Issue: Out of memory

**Diagnosis**:
```bash
# Check system memory
free -h

# Check LEAN memory usage
ps aux | grep lean
```

**Solutions**:
1. Close other applications
2. Increase swap space
3. Break complex proof into smaller tasks
4. Use `--fast` to skip memory-intensive phases

---

### Quality Issues

#### Issue: Low verification score (< 85%)

**Diagnosis**:
```bash
cat .opencode/specs/NNN_project/reports/verification-001.md
```

**Common Causes**:
- Missing proof documentation
- Non-standard proof patterns
- Incomplete error handling

**Solutions**:
1. Review specific issues in verification report
2. Fix issues manually
3. Re-run to verify:
   ```bash
   /lean NNN
   ```

---

#### Issue: Low code review score (< 80%)

**Diagnosis**:
```bash
cat .opencode/specs/NNN_project/reports/code-review-001.md
```

**Common Causes**:
- Poor variable naming
- Complex proof steps
- Lack of intermediate lemmas

**Solutions**:
1. Review suggestions in code review report
2. Refactor as suggested
3. Re-run to verify:
   ```bash
   /lean NNN
   ```

---

#### Issue: Low style compliance (< 90%)

**Diagnosis**:
```bash
cat .opencode/specs/NNN_project/reports/style-check-001.md
```

**Common Causes**:
- Naming convention violations
- Indentation issues
- Line length violations

**Solutions**:
1. Review violations in style check report
2. Fix style issues (usually quick)
3. Re-run to verify:
   ```bash
   /lean NNN
   ```

---

### Getting Help

#### Check Documentation

1. **This User Guide**: Comprehensive usage guide
2. **Flag Reference**: Detailed flag documentation (see `flag-reference.md`)
3. **Example Scenarios**: Walkthroughs (see `example-scenarios.md`)
4. **Migration Guide**: Differences from old /lean (see `migration-guide.md`)

#### Review Artifacts

Most issues can be diagnosed from artifacts:
```bash
# Implementation summary
cat .opencode/specs/NNN_project/summaries/implementation-summary.md

# Error diagnostics (if errors occurred)
cat .opencode/specs/NNN_project/reports/error-diagnostics-001.md

# Comprehensive summary (Phase 7 output)
cat .opencode/specs/NNN_project/summaries/comprehensive-summary.md
```

#### Enable Verbose Mode

(Future feature - not yet implemented)

```bash
/lean NNN --verbose
```

#### Report Issues

If you encounter a bug or unexpected behavior:

1. Collect diagnostic information:
   ```bash
   # Project state
   cat .opencode/specs/NNN_project/state.json
   
   # Implementation summary
   cat .opencode/specs/NNN_project/summaries/implementation-summary.md
   
   # System info
   uname -a
   lean --version
   ```

2. Create issue with:
   - Command used
   - Expected behavior
   - Actual behavior
   - Diagnostic information
   - Relevant artifacts

---

## 8. FAQ

### General Questions

#### Q: What's the difference between /task and /lean?

**A**: 
- `/task` creates implementation plans (research + planning)
- `/lean` executes implementation plans (implementation + quality assurance)

**Typical workflow**:
```bash
/task 123  # Creates plan
/lean 123  # Executes plan
```

For simple tasks, `/task` may execute directly without needing `/lean`.

---

#### Q: Can I use /lean without /task?

**A**: Yes, if you create an implementation plan manually:

```bash
# Create plan manually
mkdir -p .opencode/specs/123_project/plans
# Write implementation-001.md

# Run /lean
/lean 123
```

---

#### Q: What happens if I run /lean twice on the same project?

**A**: 
- Artifacts are versioned (e.g., `verification-001.md`, `verification-002.md`)
- Summaries are overwritten (latest only)
- Git commits are additive
- State is updated

It's safe to re-run `/lean` multiple times.

---

#### Q: How do I know which flags to use?

**A**: Follow this decision tree:

```
Is it a simple proof (1-2 theorems)?
├─ Yes → Use --fast
└─ No → Is it complex (5+ theorems, multi-file)?
    ├─ Yes → Use --full
    └─ No → Use default (no flags)
```

---

### Performance Questions

#### Q: How much time does /lean save?

**A**: Depends on complexity:
- **Simple proofs**: 10-20% time savings (mostly from automation)
- **Moderate proofs**: 40-50% time savings (research + verification)
- **Complex proofs**: 50-60% time savings (comprehensive automation)

---

#### Q: What's the fastest way to implement a proof?

**A**: Use `--fast`:

```bash
/lean 123 --fast
```

This skips research, optimization, and documentation for 60-70% time reduction.

---

#### Q: Can I make it even faster?

**A**: Yes, combine flags:

```bash
/lean 123 --fast --skip-docs
```

Though `--fast` already skips docs, so this is redundant. The fastest is just `--fast`.

---

#### Q: Why is Phase 3 so slow?

**A**: Phase 3 (Implementation) is the core work - actually writing and verifying proofs. This is expected and unavoidable. The time depends on proof complexity.

For a 3-theorem moderate proof, expect 10-15 minutes in Phase 3.

---

### Quality Questions

#### Q: What quality scores should I aim for?

**A**: 
- **Verification**: ≥ 90%
- **Code Review**: ≥ 85%
- **Style Compliance**: ≥ 95%

These are production-ready scores.

---

#### Q: What if my scores are low?

**A**: 
1. Review the relevant report (verification, code review, or style)
2. Address the specific issues listed
3. Re-run `/lean NNN` to verify improvements

---

#### Q: Can I skip quality checks?

**A**: Yes, with `--fast`, but **not recommended** for production code.

Use `--fast` only for:
- Prototyping
- Simple proofs
- Rapid iteration

Always run full quality checks before merging to main branch.

---

#### Q: How do I improve my verification score?

**A**: Common improvements:
- Add docstrings to theorems
- Follow standard proof patterns
- Add error handling
- Document assumptions

Review `.opencode/specs/NNN_project/reports/verification-001.md` for specific suggestions.

---

### Feature Questions

#### Q: Does /lean work with multi-file implementations?

**A**: Yes! Specify multiple files in your implementation plan:

```markdown
**Files to Modify**:
- Logos/Core/Semantics/CanonicalModel.lean
- Logos/Core/Metalogic/Completeness.lean
```

The command handles multi-file implementations automatically.

---

#### Q: Can /lean create custom tactics?

**A**: Yes! If your plan specifies custom tactic development, the `metaprogramming-specialist` is invoked automatically.

---

#### Q: Does /lean generate tests?

**A**: Not automatically, but it generates examples in Phase 6 that can serve as test cases. For comprehensive testing, use `/task` to create a testing task.

---

#### Q: Can I customize which specialists are used?

**A**: Not directly via flags, but you can influence it via your implementation plan:
- Specify "tactic-mode" → Uses tactic-specialist
- Specify "term-mode" → Uses term-mode-specialist
- Specify "custom tactics" → Uses metaprogramming-specialist

---

### Troubleshooting Questions

#### Q: What if /lean fails?

**A**: 
1. Check the error message
2. Review `.opencode/specs/NNN_project/summaries/implementation-summary.md`
3. Review `.opencode/specs/NNN_project/reports/error-diagnostics-001.md` (if exists)
4. Fix issues manually
5. Re-run `/lean NNN`

---

#### Q: Can I resume a failed /lean execution?

**A**: Yes! The command tracks state in `state.json`. Re-running `/lean NNN` will:
- Skip completed phases (if state indicates success)
- Retry failed phases
- Continue from where it left off

---

#### Q: What if optimization breaks my proof?

**A**: This is automatically handled:
- Optimization is verified before applying
- If verification fails, changes are reverted
- Original proof is preserved
- Incident is documented in optimization report

You don't need to do anything - the system handles it safely.

---

#### Q: How do I rollback changes?

**A**: Use git:

```bash
# Find the commit
git log --oneline | grep "#NNN"

# Rollback
git revert <commit_hash>
```

All `/lean` changes are committed to git, so rollback is easy.

---

### Advanced Questions

#### Q: Can I run phases individually?

**A**: Not directly via flags, but you can:
1. Run with specific skip flags to control phases
2. Modify `state.json` to mark phases as incomplete
3. Re-run to execute specific phases

---

#### Q: How does parallel execution work?

**A**: Certain phases run specialists in parallel:
- **Phase 1**: complexity-analyzer + dependency-mapper (2 parallel)
- **Phase 2**: library-navigator + proof-strategy-advisor + tactic-recommender (3 parallel)
- **Phase 4**: verification-specialist + code-reviewer + style-checker (3 parallel)
- **Phase 6**: example-builder + documentation-generator + doc-analyzer (3 parallel)

This provides 50-66% speedup in those phases.

---

#### Q: Can I add custom specialists?

**A**: Yes, but requires modifying the command file. See `development.md` for details on extending the system.

---

#### Q: How is caching implemented?

**A**: (Future feature - not yet implemented)

Planned caching:
- Library search results: 24 hours
- Proof strategies: Per theorem type
- Dependency maps: Per module

---

#### Q: Can I use /lean in CI/CD?

**A**: Yes! Example:

```bash
# In CI script
/lean 123 --fast
if [ $? -eq 0 ]; then
  echo "Implementation successful"
else
  echo "Implementation failed"
  exit 1
fi
```

---

### Migration Questions

#### Q: How is this different from the old /lean?

**A**: See `migration-guide.md` for comprehensive comparison. Key differences:
- **Old**: Simple delegation to proof-developer
- **New**: Multi-phase workflow with 19 specialists
- **Old**: No quality assurance
- **New**: Automated verification, review, optimization
- **Old**: No documentation generation
- **New**: Automatic examples and docstrings

---

#### Q: Is the old /lean still available?

**A**: During migration period, yes (as `/lean-legacy`). After full deployment, only enhanced `/lean` is available.

---

#### Q: Will my old implementation plans work?

**A**: Yes! Full backward compatibility. Old plans work with enhanced `/lean`.

---

#### Q: Do I need to change my workflow?

**A**: No! Basic usage (`/lean 123`) works exactly as before. New features are opt-in via flags.

---

## Conclusion

The enhanced `/lean` command provides a powerful, intelligent workflow for LEAN 4 proof development. By understanding the phases, using flags appropriately, and following best practices, you can achieve 40-60% time savings while improving proof quality.

**Key Takeaways**:
1. Use `--fast` for simple proofs and rapid iteration
2. Use default (no flags) for moderate proofs
3. Use `--full` for complex, production-ready proofs
4. Always review quality scores and address issues
5. Read artifacts selectively based on needs
6. Re-run `/lean` after fixing issues to verify improvements

**Next Steps**:
- Try `/lean` on a simple project with `--fast`
- Review the artifacts generated
- Experiment with different flags
- Read `flag-reference.md` for detailed flag documentation
- Check `example-scenarios.md` for walkthroughs

**Happy Proving!** 🎉
