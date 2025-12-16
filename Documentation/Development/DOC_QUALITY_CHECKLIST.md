# Documentation Quality Assurance Checklist

## Overview

This checklist provides systematic verification procedures for ensuring Logos
documentation remains accurate, consistent, and complete as implementation progresses.
Use this checklist before major releases, after significant implementation changes, and
quarterly for ongoing quality assurance.

**Purpose**: Catch documentation drift, inconsistencies, and inaccuracies early through
systematic verification

**Audience**: Developers, documentation maintainers, release managers

**Frequency**:
- Before major releases (mandatory)
- After significant implementation changes (recommended)
- Quarterly for ongoing quality assurance (recommended)

**Related Documentation**:
- [Documentation Standards](.opencode/context/core/standards/documentation-standards.md)
- [Formal Symbol Backtick Standard](.opencode/context/core/standards/
  documentation-standards.md#formal-symbol-backtick-standard)
- [Documentation/README.md](../README.md) - Documentation navigation

---

## 1. Consistency Checks

These checks verify that information is consistent across all documentation files.

### 1.1 Tactic Count Consistency

**Check**: Tactic counts match across TACTIC_DEVELOPMENT.md and implementation files.

**Verification**:
```bash
# Count tactic declarations in Tactics.lean
TACTICS_IMPL=$(grep -c "^axiom \|^def \|^elab " Logos/Automation/Tactics.lean)

# Count tactic references in TACTIC_DEVELOPMENT.md
TACTICS_DOC=$(grep -c "^\#\#\# " Documentation/ProjectInfo/TACTIC_REGISTRY.md)

echo "Implementation: $TACTICS_IMPL tactics"
echo "Documentation: $TACTICS_DOC tactics"

# Manual verification: Ensure counts align with expected values
```

**Expected**: Tactic counts should match actual implementation state. Currently
12 tactics declared (8 axiom stubs + 4 to be implemented).

**Action if Failed**: Update TACTIC_DEVELOPMENT.md or IMPLEMENTATION_STATUS.md to
reflect actual implementation state.

---

### 1.2 Completion Percentage Consistency

**Check**: Completion percentages consistent across IMPLEMENTATION_STATUS.md,
README.md.

**Verification**:
```bash
# Check Automation package completion percentage
grep -n "Automation.*%" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep -n "Automation.*%" README.md
grep -n "Automation.*%" README.md

# Manual verification: Ensure all three show same percentage
```

**Expected**: All three files show identical completion percentage for each module.
Currently Automation package is 0% complete.

**Action if Failed**: Update all three files to reflect current implementation state.

---

### 1.3 File Reference Line Numbers

**Check**: All file references include accurate line numbers for `sorry` placeholders
and implementation gaps.

**Verification**:
```bash
# Verify sorry count in Perpetuity.lean
PERPETUITY_SORRY=$(grep -c "sorry" Logos/Theorems/Perpetuity.lean)
echo "Perpetuity.lean sorry count: $PERPETUITY_SORRY"

# Check IMPLEMENTATION_STATUS.md Known Limitations section claims
grep "Perpetuity.lean.*sorry" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

# Manual verification: Line numbers in documentation match actual source locations
```

**Expected**: Line numbers referenced in IMPLEMENTATION_STATUS.md, TODO.md, and
other documentation should match actual source code locations.

**Action if Failed**: Update line number references in documentation to match
current source code.

---

### 1.4 Sorry Placeholder Count

**Check**: Total `sorry` count matches across Sorry Placeholder Registry in TODO.md
and IMPLEMENTATION_STATUS.md Known Limitations section.

**Verification**:
```bash
# Count total sorry placeholders in codebase
TOTAL_SORRY=$(find Logos -name "*.lean" -type f -exec grep -c "sorry" {} + |
              awk '{sum+=$1} END {print sum}')
echo "Total sorry placeholders in codebase: $TOTAL_SORRY"

# Check TODO.md registry
grep "Total:.*placeholders" TODO.md

# Check IMPLEMENTATION_STATUS.md Known Limitations section
grep "sorry.*placeholder" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md | wc -l

# Manual verification: Counts should match
```

**Expected**: All three sources (codebase, TODO.md, IMPLEMENTATION_STATUS.md) show
identical `sorry` counts. Currently 41 total placeholders.

**Action if Failed**: Update TODO.md Sorry Placeholder Registry and
IMPLEMENTATION_STATUS.md Known Limitations section to reflect current state.

---

## 2. Completeness Checks

These checks verify that all required documentation exists and is comprehensive.

### 2.1 Public API Documentation

**Check**: All public definitions have docstrings with proper format.

**Verification**:
```bash
# Check for undocumented public definitions (requires LEAN lint)
cd /home/benjamin/Documents/Philosophy/Projects/Logos
lake lint | grep "docBlame\|docBlameThm"

# Expected output: Zero docBlame warnings (100% docstring coverage)
```

**Expected**: Zero docBlame/docBlameThm warnings. All public definitions should
have docstrings.

**Action if Failed**: Add docstrings to undocumented public definitions following
LEAN Style Guide format.

---

### 2.2 Directory README Files

**Check**: All directories have README.md files per Directory README Standard.

**Verification**:
```bash
# Check for missing README.md files in main directories
for dir in Logos/*/ LogosTest/*/ Archive/ Documentation/*/; do
  if [ ! -f "$dir/README.md" ]; then
    echo "Missing README.md in $dir"
  fi
done

# Expected output: No missing README.md files
```

**Expected**: Every directory should have README.md following
DIRECTORY_README_STANDARD.md format.

**Action if Failed**: Create missing README.md files using standard template.

**Reference**: [Directory README Standard](DIRECTORY_README_STANDARD.md)

---

### 2.3 Limitations Documentation

**Check**: All known limitations documented in IMPLEMENTATION_STATUS.md Known Limitations section with workarounds.

**Verification**:
```bash
# Check IMPLEMENTATION_STATUS.md Known Limitations section has all modules with incomplete implementation
grep -E "^### [0-9]+\." Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md | grep -A 5 "Known Limitations"

# Manual verification: Ensure each limitation has:
# - Clear description
# - Impact assessment
# - Workaround or alternative approach
# - Reference to relevant TODO.md task
```

**Expected**: Every `sorry` placeholder or incomplete implementation should have
corresponding entry in IMPLEMENTATION_STATUS.md Known Limitations section with workaround.

**Action if Failed**: Add missing limitation entries to IMPLEMENTATION_STATUS.md Known Limitations section.

---

### 2.4 Task Dependencies

**Check**: All TODO.md tasks have effort estimates and documented dependencies.

**Verification**:
```bash
# Check TODO.md structure
grep -A5 "^### [0-9]\+\." TODO.md | grep "Effort:\|Dependencies:"

# Manual verification: Ensure each task has:
# - Effort estimate (X-Y hours)
# - Priority (High/Medium/Low)
# - Dependencies or "None"
# - Blocking status
```

**Expected**: All 13 tasks in TODO.md have complete metadata.

**Action if Failed**: Add missing effort estimates or dependencies to tasks.

---

## 3. Accuracy Checks

These checks verify that documentation claims are accurate and verifiable.

### 3.1 Status Claims Verification

**Check**: Status claims in IMPLEMENTATION_STATUS.md verifiable with provided commands.

**Verification**:
```bash
# Test status verification commands from IMPLEMENTATION_STATUS.md
cd /home/benjamin/Documents/Philosophy/Projects/Logos

# Example: Verify Soundness module sorry count
grep -c "sorry" Logos/Metalogic/Soundness.lean

# Example: Verify Automation package completion
ls Logos/Automation/*.lean

# Manual verification: Run verification commands from IMPLEMENTATION_STATUS.md
# and confirm results match documented status
```

**Expected**: All verification commands in IMPLEMENTATION_STATUS.md should produce
results matching documented status percentages and counts.

**Action if Failed**: Update IMPLEMENTATION_STATUS.md status percentages or fix
verification commands.

---

### 3.2 Code Examples Compilation

**Check**: All code examples in documentation compile and run successfully.

**Verification**:
```bash
# Extract code blocks from markdown and test compilation
# (Manual process - requires LEAN environment)

# For TACTIC_DEVELOPMENT.md examples:
cd /home/benjamin/Documents/Philosophy/Projects/Logos
# Copy code examples to temporary .lean file and run:
# lake env lean temp_example.lean

# Expected: All examples compile without errors
```

**Expected**: All LEAN code examples in TACTIC_DEVELOPMENT.md, METAPROGRAMMING_GUIDE.md,
and TUTORIAL.md should compile successfully.

**Action if Failed**: Fix code examples to match current LEAN 4 syntax and
Logos API.

---

### 3.3 External Links Validation

**Check**: All external links (web resources, GitHub repos) are valid and accessible.

**Verification**:
```bash
# Extract URLs from markdown files and test accessibility
grep -Eoh 'https?://[^ ]+' Documentation/**/*.md README.md | sort -u > urls.txt

# Manual verification: Test each URL in browser or with curl
while read url; do
  curl -s -o /dev/null -w "%{http_code} $url\n" "$url"
done < urls.txt

# Expected: All URLs return 200 status code
```

**Expected**: All external links should be accessible (HTTP 200 status).

**Action if Failed**: Update or remove broken links, find alternative resources.

---

### 3.4 Cross-Reference Validity

**Check**: All internal cross-references between documentation files remain valid.

**Verification**:
```bash
# Extract markdown links and verify local file references
for file in Documentation/**/*.md README.md TODO.md; do
  echo "Checking $file for broken references..."
  grep -Eo '\[.*\]\(([^)]+)\)' "$file" | grep -Eo '\([^)]+\)' | tr -d '()' | \
  while read ref; do
    if [[ "$ref" =~ ^http ]]; then
      # Skip external URLs (tested in 3.3)
      continue
    else
      # Check local file references
      if [[ ! -f "$ref" ]] && [[ ! -f "$(dirname $file)/$ref" ]]; then
        echo "BROKEN REFERENCE in $file: $ref"
      fi
    fi
  done
done
```

**Expected**: Zero broken local file references. All relative paths resolve to
existing files.

**Action if Failed**: Fix broken references to point to correct file locations or
remove references.

---

## 4. Formatting Checks

These checks verify that documentation follows formatting standards.

### 4.1 Line Limit Compliance

**Check**: All documentation files adhere to 100-character line limit.

**Verification**:
```bash
# Check all documentation files for line limit violations
for file in Documentation/**/*.md README.md TODO.md; do
  awk -v f="$file" 'length > 100 {print f" line "NR" exceeds 100 chars: "length" chars";
  exit 1}' "$file"
  if [ $? -eq 0 ]; then
    echo "PASS: $file line limit OK"
  else
    echo "FAIL: $file line limit exceeded"
  fi
done
```

**Expected**: All documentation files should comply with 100-character line limit
per LEAN Style Guide.

**Action if Failed**: Reformat long lines to comply with 100-character limit.

---

### 4.2 Formal Symbol Backticks

**Check**: All Unicode formal symbols wrapped in backticks per Formal Symbol Backtick
Standard.

**Verification**:
```bash
# Check for unbacked Unicode symbols
for file in Documentation/**/*.md README.md TODO.md; do
  UNBACKTICKED=$(grep -E "□|◇|△|▽|⊢|⊨" "$file" | grep -v '`' | wc -l)
  if [ "$UNBACKTICKED" -gt 0 ]; then
    echo "FAIL: $file has $UNBACKTICKED unbackticked formal symbols"
  else
    echo "PASS: $file formal symbol backtick compliance"
  fi
done
```

**Expected**: All formal symbols (`□`, `◇`, `△`, `▽`, `⊢`, `⊨`) should be wrapped
in backticks.

**Action if Failed**: Add backticks around all formal symbols in documentation.

**Reference**: [Formal Symbol Backtick Standard](.opencode/context/core/standards/
documentation-standards.md#formal-symbol-backtick-standard)

---

### 4.3 Code Block Language Specification

**Check**: All code blocks specify language for proper syntax highlighting.

**Verification**:
```bash
# Check for code blocks without language specification
for file in Documentation/**/*.md README.md; do
  # Count triple backticks without language
  UNSPECIFIED=$(grep -E "^\`\`\`$" "$file" | wc -l)
  if [ "$UNSPECIFIED" -gt 0 ]; then
    echo "FAIL: $file has $UNSPECIFIED code blocks without language specification"
  else
    echo "PASS: $file all code blocks have language specification"
  fi
done
```

**Expected**: All code blocks should specify language (```lean, ```bash, etc.).

**Action if Failed**: Add language specification to all code blocks.

---

### 4.4 ATX-Style Headings

**Check**: All headings use ATX-style (`#`, `##`, `###`) not Setext-style underlines.

**Verification**:
```bash
# Check for Setext-style heading underlines (=== or ---)
for file in Documentation/**/*.md README.md TODO.md; do
  SETEXT=$(grep -E "^(===+|---+)$" "$file" | wc -l)
  if [ "$SETEXT" -gt 0 ]; then
    echo "FAIL: $file has $SETEXT Setext-style headings"
  else
    echo "PASS: $file uses ATX-style headings"
  fi
done
```

**Expected**: All headings should use ATX-style (`#`, `##`, `###`).

**Action if Failed**: Convert Setext-style headings to ATX-style.

---

## 5. Integration Checks

These checks verify that documentation integrates correctly with project structure.

### 5.1 README.md References

**Check**: README.md references align with actual file locations and best practices.

**Verification**:
```bash
# Check README.md file references
grep -E "\[.*\]\(.*\.md\)" README.md | grep -Eo '\([^)]+\)' | tr -d '()' | \
while read ref; do
  if [[ ! -f "$ref" ]]; then
    echo "BROKEN REFERENCE in README.md: $ref"
  fi
done
```

**Expected**: All file references in README.md should resolve to existing files.

**Action if Failed**: Update README.md references to point to correct file locations.

---

### 5.2 TODO.md Task Alignment

**Check**: TODO.md tasks match best practices recommendations and implementation
priorities.

**Verification**:
```bash
# Count tasks in TODO.md
TASK_COUNT=$(grep -E "^### [0-9]+\. [A-Z]" TODO.md | grep -v "Archive/" |
             grep -v "Logos/" | wc -l)
echo "Total tasks in TODO.md: $TASK_COUNT"

# Expected: 13 tasks (11 original + 2 new from best practices)

# Manual verification: Ensure Tasks 12 and 13 exist
grep "### 12. Create Comprehensive Tactic Test Suite" TODO.md
grep "### 13. Create Proof Strategy Documentation" TODO.md
```

**Expected**: TODO.md should contain 13 tasks including new Tasks 12 and 13 derived
from best practices report.

**Action if Failed**: Add missing tasks or update task numbering to reflect
current priorities.

---

### 5.3 Documentation Reflects Implementation State

**Check**: Documentation status claims match actual implementation state in codebase.

**Verification**:
```bash
# Example: Verify Perpetuity module status
# IMPLEMENTATION_STATUS.md claims "50% complete (P1-P3 proven, P4-P6 incomplete)"

# Verify P1-P3 status
grep -A5 "theorem p1" Logos/Theorems/Perpetuity.lean | grep "sorry"
grep -A5 "theorem p2" Logos/Theorems/Perpetuity.lean | grep "sorry"
grep -A5 "theorem p3" Logos/Theorems/Perpetuity.lean | grep "sorry"

# Expected: P1-P2 have sorry in helpers, P3 has zero sorry

# Manual verification: Run verification commands from IMPLEMENTATION_STATUS.md
# for each module and confirm results match documentation
```

**Expected**: Documentation status percentages should accurately reflect
implementation state verified by source code inspection.

**Action if Failed**: Update IMPLEMENTATION_STATUS.md to reflect current
implementation state or fix incorrect status claims.

---

## Usage

### Before Major Release

1. Run all verification commands in each section
2. Document any failures in release notes
3. Fix critical failures before release (broken references, incorrect status claims)
4. Defer non-critical failures to post-release cleanup (formatting issues)

### After Significant Implementation Changes

1. Run Completeness Checks (Section 2) to ensure new code is documented
2. Run Consistency Checks (Section 1) to update counts and percentages
3. Run Accuracy Checks (Section 3) to verify status claims
4. Update IMPLEMENTATION_STATUS.md (including Known Limitations section) as needed

### Quarterly Quality Assurance

1. Run all checks in all sections
2. Document findings in quality assurance report
3. Create GitHub issues for identified problems
4. Prioritize fixes based on severity (broken references > formatting issues)

---

## Maintenance

### Updating This Checklist

When adding new documentation standards:
1. Add new check section with clear verification procedure
2. Document expected results
3. Provide action if check fails
4. Test verification commands to ensure they work correctly

### Checklist Version History

- **2025-12-02**: Initial version created as part of LEAN 4 Documentation
  Improvement Plan (Spec 022, Phase 6)
- Covers 5 check categories: Consistency, Completeness, Accuracy, Formatting,
  Integration
- 20 total checks with automated verification commands

---

## References

**Documentation Standards**:
- [Documentation Standards](.opencode/context/core/standards/documentation-standards.md)
- [Code Standards](.opencode/context/core/standards/code-standards.md)
- [LEAN Style Guide](LEAN_STYLE_GUIDE.md)
- [Directory README Standard](DIRECTORY_README_STANDARD.md)

**Implementation Tracking**:
- [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) (includes Known Limitations section)
- [TODO.md](../../TODO.md)

**Best Practices Report**:
- Report 022: Documentation Improvement Analysis (.opencode/specs/
  022_lean4_docs_implementation_improve/reports/
  001-documentation-improvement-implementation-plan.md)
- Report 022 Findings Section 4: Documentation Consistency Issues

---
