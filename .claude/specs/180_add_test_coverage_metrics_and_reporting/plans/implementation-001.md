# Implementation Plan: Task #180

**Task**: Add Bimodal test coverage metrics and reporting
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Revision Summary

This plan replaces the original task 180 scope (which assumed no testing standards existed) with a scope that builds on the existing comprehensive BimodalTest infrastructure.

### Previous Scope (Obsolete)
- Targeted `docs/Development/TEST_COVERAGE.md` (general)
- Dependency on Task 175 (CI/CD pipeline)
- 9 hours effort

### Current State
`BimodalTest/` already has:
- 30 test files organized by module
- Comprehensive README.md with testing standards
- Coverage targets defined (85% overall, 90% metalogic, 80% automation)
- Module-by-module status tracking
- Sorry placeholder documentation

### New Scope (Current)
Build on existing infrastructure to add:
1. Definition-level coverage analysis script
2. Sorry audit automation
3. Coverage baseline documentation
4. Module-by-module breakdown

## Overview

Create practical coverage measurement for Lean 4 by analyzing which definitions in `Bimodal/` have corresponding tests in `BimodalTest/`. Since traditional code coverage tools don't work with Lean, we implement definition-level coverage: counting how many public definitions have at least one test exercising them.

## Phases

### Phase 1: Definition Extraction Script

**Status**: [NOT STARTED]
**Estimated effort**: 2 hours

**Objectives**:
1. Extract all public definitions from Bimodal/
2. Categorize by module and type (def, theorem, inductive, etc.)
3. Generate machine-readable output

**Files to create**:
- `scripts/extract-definitions.sh` (new)

**Implementation**:

```bash
#!/bin/bash
# Extract public definitions from Lean files

# Categories to track
# - def: function definitions
# - theorem/lemma: proven statements
# - inductive: type definitions
# - structure: record types
# - instance: typeclass instances

# Output format: JSON
# { "module": "Bimodal.Syntax.Formula",
#   "definitions": [
#     {"name": "Formula", "kind": "inductive", "line": 15},
#     {"name": "Formula.box", "kind": "def", "line": 42}
#   ]}

grep -rn "^def \|^theorem \|^lemma \|^inductive \|^structure \|^instance " Bimodal/ \
  --include="*.lean" | \
  awk -F: '{print $1, $2, $3}' | \
  # Format as JSON...
```

**Alternative - Lean script**:

```lean
-- scripts/ExtractDefinitions.lean
import Lean
import Std

-- Use Lean's Environment to extract declarations
def extractPublicDefs (env : Environment) : List Name :=
  env.constants.fold (init := []) fun acc name _ =>
    if name.isInternal then acc else name :: acc
```

**Verification**:
- Script runs without errors
- Output includes known definitions from each module

---

### Phase 2: Test Coverage Mapping

**Status**: [NOT STARTED]
**Estimated effort**: 2 hours

**Objectives**:
1. Map definitions to test files that exercise them
2. Identify untested definitions
3. Calculate coverage percentages

**Files to create**:
- `scripts/coverage-report.sh` (new)

**Implementation approach**:

```bash
#!/bin/bash
# Generate coverage report

# For each definition in Bimodal/
#   Search BimodalTest/ for references to that definition
#   Mark as covered if found in a test file

# Output:
# Module Coverage Report
# =====================
# Bimodal.Syntax.Formula: 18/20 (90%)
#   - Covered: Formula, Formula.box, Formula.imp, ...
#   - Missing: Formula.complexity, Formula.subformulas
#
# Bimodal.ProofSystem.Axioms: 12/12 (100%)
#   - All definitions tested
#
# Overall: 85/100 (85%)
```

**Heuristics for coverage**:
- Definition `Foo` is covered if `Foo` appears in `BimodalTest/*.lean`
- Theorem `bar` is covered if `bar` appears in a test `example` or assertion
- Instance coverage counted separately (harder to verify)

**Verification**:
- Report generates for all modules
- Coverage percentages are reasonable (50-100%)
- Known tested definitions show as covered

---

### Phase 3: Sorry Audit Script

**Status**: [NOT STARTED]
**Estimated effort**: 1 hour

**Objectives**:
1. Track all sorry placeholders in tests
2. Categorize by reason (pending infrastructure, needs proof, etc.)
3. Generate improvement roadmap

**Files to create**:
- `scripts/sorry-audit.sh` (new)

**Implementation**:

```bash
#!/bin/bash
# Audit sorry placeholders

echo "=== Sorry Audit Report ==="
echo ""

# Count by file
echo "By File:"
for file in $(find BimodalTest -name "*.lean"); do
  count=$(grep -c "sorry" "$file" 2>/dev/null || echo 0)
  if [ "$count" -gt 0 ]; then
    echo "  $file: $count"
  fi
done

echo ""
echo "Total: $(grep -r "sorry" BimodalTest --include="*.lean" | wc -l)"

# Categorization (from comments)
echo ""
echo "By Category:"
echo "  Pending infrastructure: $(grep -r "sorry.*pending\|sorry.*infrastructure" BimodalTest --include="*.lean" | wc -l)"
echo "  Needs concrete proof: $(grep -r "sorry.*proof\|sorry.*implement" BimodalTest --include="*.lean" | wc -l)"
echo "  Uncategorized: $(grep -r "sorry" BimodalTest --include="*.lean" | grep -v "pending\|infrastructure\|proof\|implement" | wc -l)"
```

**Verification**:
- Audit runs without errors
- Counts match manual inspection
- Categories are useful

---

### Phase 4: Coverage Documentation

**Status**: [NOT STARTED]
**Estimated effort**: 1 hour

**Objectives**:
1. Document current coverage baseline
2. Create module breakdown
3. Identify improvement priorities

**Files to create**:
- `Bimodal/docs/ProjectInfo/TEST_COVERAGE.md` (new)

**Content structure**:

```markdown
# Bimodal Test Coverage Report

**Generated**: 2026-01-11
**Script**: scripts/coverage-report.sh

## Summary

| Metric | Current | Target |
|--------|---------|--------|
| Overall | XX% | 85% |
| Metalogic | XX% | 90% |
| Automation | XX% | 80% |
| Sorry count | X | 0 |

## Module Breakdown

### Syntax (XX%)
- Formula: 18/20 definitions covered
- Context: 10/10 definitions covered
- Missing: Formula.complexity, Formula.depth

### ProofSystem (XX%)
...

### Semantics (XX%)
...

## Sorry Audit

### Pending Infrastructure (X total)
These cannot be resolved until source implementation completes:
- CompletenessTest.lean:45 - needs completeness proof
- ...

### Needs Concrete Proof (X total)
These could be completed with additional proof work:
- PerpetuityTest.lean:82 - box_conj_intro needs proof
- ...

## Improvement Priorities

1. **High**: Complete Metalogic tests (90% target)
2. **Medium**: Reduce sorry count in Theorems
3. **Low**: Add edge case tests in Automation

## Regenerating This Report

```bash
./scripts/coverage-report.sh > Bimodal/docs/ProjectInfo/TEST_COVERAGE.md
```
```

**Verification**:
- Document renders correctly in Markdown
- Baseline numbers are realistic
- Priorities are actionable

---

## Dependencies

- Phase 1 must complete before Phase 2
- Phase 3 is independent
- Phase 4 depends on Phase 2 and 3

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Definition extraction incomplete | Medium | Start with grep, enhance iteratively |
| Coverage heuristic too coarse | Low | Document limitations, refine over time |
| Sorry categorization inaccurate | Low | Encourage comment discipline |

## Success Criteria

- [ ] Definition extraction produces complete list for Bimodal/
- [ ] Coverage report shows per-module percentages
- [ ] Sorry audit categorizes all placeholders
- [ ] TEST_COVERAGE.md documents current baseline
- [ ] Scripts are runnable and documented
- [ ] BimodalTest/README.md links to coverage report
