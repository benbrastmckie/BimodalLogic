# Implementation Plan: Task #180

**Task**: Add Bimodal test coverage metrics and reporting
**Version**: 002
**Created**: 2026-01-12
**Revision of**: implementation-001.md
**Reason**: Many changes have since taken place to the Bimodal/ theory. Research improvements that could be made to the plan.

## Revision Summary

Task 179 was completed, adding comprehensive benchmark infrastructure (`scripts/run-benchmarks.sh`, `scripts/check-regression.sh`). The Bimodal theory now has well-documented testing standards and benchmark baselines. This revision focuses the coverage task on what's NOT already covered: definition-level coverage tracking (how many definitions have tests) rather than performance benchmarking (already complete).

### Previous Plan Status (v001)
- Phase 1: Definition Extraction Script [NOT STARTED] - Still needed
- Phase 2: Test Coverage Mapping [NOT STARTED] - Still needed
- Phase 3: Sorry Audit Script [NOT STARTED] - Simplified (only 11 sorries remain)
- Phase 4: Coverage Documentation [NOT STARTED] - Scope reduced (performance docs exist)

### Key Changes
1. **Leverage existing infrastructure**: Task 179 created `scripts/run-benchmarks.sh` - extend this pattern
2. **Simplified sorry audit**: Only 5 actual sorry placeholders exist (down from estimate)
3. **Remove redundant documentation**: PERFORMANCE_TARGETS.md and BENCHMARKING_GUIDE.md already exist
4. **Focus on definition coverage**: The gap is knowing which Bimodal definitions lack tests
5. **Use Lean-native approach**: Extract definitions via Lean Environment API (more accurate than grep)

### What Changed Since v001
- Task 179 completed: 3 benchmark files, 2 CI scripts, 2 documentation files
- Sorry count reduced from ~20 to 11 (5 actual, 6 in comments)
- TESTING_STANDARDS.md and PERFORMANCE_TARGETS.md provide baseline documentation
- `benchmarks/` directory with baseline.json and current.json

## Overview

Create definition-level coverage measurement for Bimodal by:
1. Extracting all public definitions from Bimodal/ using Lean's Environment API
2. Analyzing which definitions are exercised in BimodalTest/
3. Generating a coverage report with module breakdown
4. Adding a sorry audit summary to existing test documentation

## Phases

### Phase 1: Definition Extraction via Lean

**Status**: [NOT STARTED]
**Estimated effort**: 1.5 hours

**Objectives**:
1. Create Lean script that lists all public definitions from Bimodal/
2. Output categorized by module and definition kind
3. JSON output for processing

**Files to create**:
- `scripts/ExtractDefinitions.lean` (new)

**Implementation**:

```lean
/-!
# Definition Extractor

Extracts all public definitions from Bimodal/ for coverage analysis.
-/
import Lean
import Bimodal

open Lean in
def getPublicDecls (env : Environment) (modulePrefix : Name) : Array (Name × ConstantInfo) :=
  env.constants.fold (init := #[]) fun acc name info =>
    if name.getPrefix.isPrefixOf modulePrefix && !name.isInternal then
      acc.push (name, info)
    else
      acc

-- Categorize by kind
def declKind (info : ConstantInfo) : String :=
  match info with
  | .defnInfo _ => "def"
  | .thmInfo _ => "theorem"
  | .inductInfo _ => "inductive"
  | .ctorInfo _ => "constructor"
  | .recInfo _ => "recursor"
  | .axiomInfo _ => "axiom"
  | .opaqueInfo _ => "opaque"
  | .quotInfo _ => "quotient"

def main : IO Unit := do
  let env ← importModules #[{module := `Bimodal}] {}
  let decls := getPublicDecls env `Bimodal
  -- Output as JSON
  IO.println "{"
  IO.println "  \"definitions\": ["
  for (name, info) in decls do
    IO.println s!"    {{\"name\": \"{name}\", \"kind\": \"{declKind info}\"}},"
  IO.println "  ]"
  IO.println "}"
```

**Alternative (simpler grep approach)**:

If Lean approach proves complex, fall back to:
```bash
grep -rn "^def \|^theorem \|^lemma \|^inductive \|^structure \|^instance " Bimodal/ \
  --include="*.lean" | \
  grep -v "^BimodalTest/" | \
  awk -F: '{print $1 ":" $2 ": " $3}'
```

**Verification**:
- Script runs without errors
- Output includes known definitions (Formula, Derivable, etc.)
- Count is reasonable (50-200 definitions expected)

---

### Phase 2: Coverage Mapping Script

**Status**: [NOT STARTED]
**Estimated effort**: 1.5 hours

**Objectives**:
1. For each definition in Bimodal/, check if it's used in BimodalTest/
2. Calculate coverage percentage per module
3. Identify untested definitions

**Files to create**:
- `scripts/coverage-analysis.sh` (new)

**Implementation**:

```bash
#!/usr/bin/env bash
# Coverage Analysis Script
# Maps Bimodal definitions to their test coverage in BimodalTest

set -e

echo "=== Bimodal Definition Coverage Analysis ==="
echo "Generated: $(date -Iseconds)"
echo ""

# Get list of all Bimodal source files
BIMODAL_FILES=$(find Bimodal -name "*.lean" -type f | sort)

# For each module, count definitions and test references
for file in $BIMODAL_FILES; do
  module=$(basename "$file" .lean)

  # Extract definition names from this file
  defs=$(grep -oP "^(def|theorem|lemma|inductive|structure|instance)\s+\K\w+" "$file" 2>/dev/null || true)

  if [ -n "$defs" ]; then
    total=0
    covered=0

    for def in $defs; do
      total=$((total + 1))
      # Check if this definition appears in BimodalTest
      if grep -rq "\b${def}\b" BimodalTest/ --include="*.lean" 2>/dev/null; then
        covered=$((covered + 1))
      fi
    done

    if [ $total -gt 0 ]; then
      pct=$((100 * covered / total))
      echo "$module: $covered/$total ($pct%)"
    fi
  fi
done

echo ""
echo "=== Uncovered Definitions ==="
# List definitions not found in tests
for file in $BIMODAL_FILES; do
  defs=$(grep -oP "^(def|theorem|lemma|inductive|structure|instance)\s+\K\w+" "$file" 2>/dev/null || true)
  for def in $defs; do
    if ! grep -rq "\b${def}\b" BimodalTest/ --include="*.lean" 2>/dev/null; then
      echo "  - $(basename "$file" .lean).$def"
    fi
  done
done
```

**Verification**:
- Script produces reasonable coverage numbers
- Known tested definitions (Formula, Derivable) show as covered
- Output is parseable

---

### Phase 3: Sorry Audit Integration

**Status**: [NOT STARTED]
**Estimated effort**: 0.5 hours

**Objectives**:
1. Document current sorry locations in test files
2. Integrate into coverage report
3. Categorize by type (infrastructure-blocked vs. proof-needed)

**Current sorry inventory** (from research):
```
BimodalTest/Metalogic/CompletenessTest.lean:51   - Pending completeness proof
BimodalTest/Metalogic/CompletenessTest.lean:65   - Pending completeness proof
BimodalTest/Metalogic/CompletenessTest.lean:83   - Pending completeness proof
BimodalTest/Theorems/PerpetuityTest.lean:76      - Needs concrete proof
BimodalTest/Theorems/PropositionalTest.lean:193  - Pending deduction theorem
```

**Files to modify**:
- `scripts/coverage-analysis.sh` - Add sorry section

**Add to coverage script**:
```bash
echo ""
echo "=== Sorry Audit ==="
echo "Pending Infrastructure (blocked by source implementation):"
grep -rn "sorry" BimodalTest/Metalogic/CompletenessTest.lean --include="*.lean" | wc -l
echo "  - CompletenessTest.lean: 3 sorries (pending completeness proof)"
echo ""
echo "Pending Proofs (could be completed):"
echo "  - PerpetuityTest.lean: 1 sorry (box_conj_intro proof)"
echo "  - PropositionalTest.lean: 1 sorry (deduction theorem)"
echo ""
echo "Total: 5 sorry placeholders"
```

**Verification**:
- Counts match actual grep results
- Categories are accurate

---

### Phase 4: Coverage Report Document

**Status**: [NOT STARTED]
**Estimated effort**: 1 hour

**Objectives**:
1. Create TEST_COVERAGE.md with current baseline
2. Link from BimodalTest/README.md
3. Include regeneration instructions

**Files to create**:
- `Bimodal/Documentation/ProjectInfo/TEST_COVERAGE.md` (new)

**Files to modify**:
- `BimodalTest/README.md` - Add link to TEST_COVERAGE.md

**Content for TEST_COVERAGE.md**:

```markdown
# Bimodal Test Coverage Report

**Generated**: 2026-01-12
**Script**: `scripts/coverage-analysis.sh`

## Summary

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Definition Coverage | XX% | 85% | {status} |
| Sorry Placeholders | 5 | 0 | Acceptable (infrastructure-blocked) |

## Module Breakdown

| Module | Definitions | Tested | Coverage | Priority |
|--------|-------------|--------|----------|----------|
| Syntax/Formula | XX | XX | XX% | High |
| Syntax/Context | XX | XX | XX% | Medium |
| ProofSystem/Axioms | XX | XX | XX% | Critical |
| ProofSystem/Derivation | XX | XX | XX% | Critical |
| Semantics/Truth | XX | XX | XX% | Critical |
| Semantics/Validity | XX | XX | XX% | High |
| Metalogic/Soundness | XX | XX | XX% | Critical |
| Automation/Tactics | XX | XX | XX% | Medium |

## Untested Definitions

{List from coverage script}

## Sorry Audit

### Blocked by Infrastructure (3)
Cannot be resolved until source implementation completes:
- `CompletenessTest.lean:51,65,83` - Completeness proofs require Completeness.lean implementation

### Needs Concrete Proof (2)
Could be completed with additional proof work:
- `PerpetuityTest.lean:76` - box_conj_intro needs proof construction
- `PropositionalTest.lean:193` - Requires deduction theorem

## Regenerating This Report

```bash
./scripts/coverage-analysis.sh > coverage-output.txt
# Then update this document with the numbers
```

## Related Documentation

- [PERFORMANCE_TARGETS.md](PERFORMANCE_TARGETS.md) - Benchmark baselines
- [TESTING_STANDARDS.md](../../../Documentation/Development/TESTING_STANDARDS.md) - Test requirements
- [BimodalTest README](../../../BimodalTest/README.md) - Test organization
```

**Verification**:
- Document renders correctly
- Links work
- Numbers are realistic

---

## Dependencies

```
Phase 1 (Definition Extraction)
    ↓
Phase 2 (Coverage Mapping) ← Phase 3 (Sorry Audit - independent)
    ↓
Phase 4 (Coverage Documentation)
```

- Phase 1 and 3 can run in parallel
- Phase 2 requires Phase 1
- Phase 4 requires Phase 2 and 3

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Lean Environment API complexity | Medium | Fall back to grep approach (simpler but less accurate) |
| Coverage heuristic misses indirect usage | Low | Document limitations, accept as approximation |
| Report becomes stale | Low | Provide clear regeneration instructions |

## Success Criteria

- [ ] Definition extraction produces list of all Bimodal/ public definitions
- [ ] Coverage script calculates per-module coverage percentages
- [ ] Sorry audit accurately categorizes all 5 placeholders
- [ ] TEST_COVERAGE.md provides actionable coverage baseline
- [ ] Scripts are executable and documented
- [ ] BimodalTest/README.md links to coverage report

## Changes from v001

| Aspect | v001 | v002 |
|--------|------|------|
| Estimated effort | 6 hours | 4.5 hours |
| Phases | 4 | 4 (reduced scope) |
| Scripts location | scripts/ | scripts/ (same) |
| Documentation | New from scratch | Supplements existing docs |
| Sorry handling | Full audit | Summary only (5 known) |
| Lean approach | Optional | Primary (grep as fallback) |

## Post-Implementation

After task completion:
1. Coverage numbers feed into TESTING_STANDARDS.md targets
2. Uncovered definitions become candidates for Task 365 (complete sorries) or new tasks
3. Regular coverage checks can be added to CI (optional follow-up)
