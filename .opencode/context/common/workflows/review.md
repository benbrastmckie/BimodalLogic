<!-- Context: workflows/review | Priority: high | Version: 3.0 | Updated: 2025-12-25 -->

# Repository Review Workflow

## Quick Reference

**Purpose**: Gap analysis, coverage checks, registry updates, task registration

**Workflow**: Analyze → Read MAINTENANCE.md → Update Registries → Register Tasks

**Registries**: IMPLEMENTATION_STATUS.md, FEATURE_REGISTRY.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md

**Principles**: Configuration-driven, Repository-agnostic, No implementation

---

## Workflow Overview

The `/review` command performs comprehensive repository analysis and updates project tracking documentation based on findings. The workflow is configuration-driven, reading update instructions from the repository's MAINTENANCE.md file.

## Workflow Stages

### Stage 1: Repository Analysis

Perform comprehensive gap analysis covering:

**Functionality**:
- [ ] Does what it's supposed to do
- [ ] Edge cases handled
- [ ] Error cases handled
- [ ] No obvious bugs

**Code Quality**:
- [ ] Clear, descriptive naming
- [ ] Functions small and focused
- [ ] No unnecessary complexity
- [ ] Follows coding standards
- [ ] DRY - no duplication

**Security**:
- [ ] Input validation present
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No hardcoded secrets
- [ ] Sensitive data handled properly
- [ ] Auth/authorization appropriate

**Testing**:
- [ ] Tests present
- [ ] Happy path covered
- [ ] Edge cases covered
- [ ] Error cases covered
- [ ] All tests pass

**Performance**:
- [ ] No obvious performance issues
- [ ] Efficient algorithms
- [ ] No unnecessary operations
- [ ] Resources properly managed

**Maintainability**:
- [ ] Easy to understand
- [ ] Complex logic documented
- [ ] Follows project conventions
- [ ] Easy to modify/extend

### Stage 2: Read Update Instructions

Locate and read the repository's MAINTENANCE.md file to extract update instructions:

1. **Find MAINTENANCE.md**:
   - Check Documentation/ProjectInfo/MAINTENANCE.md (ProofChecker convention)
   - Check docs/MAINTENANCE.md (common alternative)
   - Check MAINTENANCE.md in repository root
   - If not found, use default registry list (see Stage 3)

2. **Extract "Update Instructions for /review Command" section**:
   - Read the section that specifies which files to update
   - Extract the list of registry/status files
   - Read task registration workflow requirements
   - Note any repository-specific guidance

3. **Parse file list**:
   - Extract file paths from the update instructions
   - Validate that files exist in the repository
   - Prepare update operations for each file

### Stage 3: Update Registry and Status Files

Update the files specified in MAINTENANCE.md update instructions (or defaults if not found):

**Default Registry Files** (if MAINTENANCE.md not found or section missing):
- IMPLEMENTATION_STATUS.md
- FEATURE_REGISTRY.md
- SORRY_REGISTRY.md
- TACTIC_REGISTRY.md

**Update Operations**:

1. **IMPLEMENTATION_STATUS.md**:
   - Update module completion percentages based on analysis
   - Update sorry counts from codebase scan
   - Add new gaps/limitations discovered during review
   - Remove limitations that have been resolved
   - Update Known Limitations section

2. **FEATURE_REGISTRY.md**:
   - Register new features or capabilities discovered
   - Add entries for undocumented features found in code
   - Update feature status based on implementation state
   - Cross-reference with IMPLEMENTATION_STATUS.md

3. **SORRY_REGISTRY.md**:
   - Add newly discovered sorry placeholders
   - Remove resolved placeholders
   - Update resolution guidance based on findings
   - Update counts and module breakdowns

4. **TACTIC_REGISTRY.md** (if applicable):
   - Add newly discovered tactics
   - Update tactic descriptions and usage examples
   - Cross-reference with implementation files

### Stage 4: Register Tasks for Remaining Work

Create tasks in TODO.md for all remaining work identified during review:

1. **Use /add command** for each identified task:
   - Ensures proper task numbering via state.json
   - Maintains lazy directory creation (no project roots created)
   - Preserves all task metadata and status markers

2. **Task metadata requirements**:
   - Clear description of work to be done
   - Effort estimate based on complexity
   - Priority based on impact and urgency
   - Language metadata (lean, markdown, etc.)
   - Dependencies and blocking relationships
   - Files affected

3. **Task categories**:
   - Missing features or capabilities
   - Documentation gaps
   - Test coverage gaps
   - Performance issues
   - Security vulnerabilities
   - Code quality improvements
   - Sorry placeholder resolutions

### Stage 5: Generate Review Report (Optional)

If requested or if significant findings warrant documentation:

1. Create review project directory (lazy creation - only when writing report)
2. Generate review report in reports/analysis-NNN.md or verification-NNN.md
3. Include summary of findings, updated registries, and registered tasks
4. Link report in TODO.md and state.json

## Principles

**Configuration-Driven**: Read update instructions from MAINTENANCE.md rather than hardcoding file paths

**Repository-Agnostic**: Workflow works for any repository with MAINTENANCE.md update instructions

**No Implementation**: Review only identifies and registers work; does not implement tasks

**Constructive**: Focus on gaps and improvements, not criticism

**Thorough**: Check functionality not just style, consider edge cases, think maintainability, look for security

**Timely**: Complete review promptly, register tasks clearly, provide actionable recommendations

## Review Checklist

### Functionality
- [ ] Does what it's supposed to do
- [ ] Edge cases handled
- [ ] Error cases handled
- [ ] No obvious bugs

### Code Quality
- [ ] Clear, descriptive naming
- [ ] Functions small and focused
- [ ] No unnecessary complexity
- [ ] Follows coding standards
- [ ] DRY - no duplication

### Security
- [ ] Input validation present
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No hardcoded secrets
- [ ] Sensitive data handled properly
- [ ] Auth/authorization appropriate

### Testing
- [ ] Tests present
- [ ] Happy path covered
- [ ] Edge cases covered
- [ ] Error cases covered
- [ ] All tests pass

### Performance
- [ ] No obvious performance issues
- [ ] Efficient algorithms
- [ ] No unnecessary operations
- [ ] Resources properly managed

### Maintainability
- [ ] Easy to understand
- [ ] Complex logic documented
- [ ] Follows project conventions
- [ ] Easy to modify/extend

## Review Report Format

```markdown
## Code Review: {Feature/PR Name}

**Summary:** {Brief overview}
**Assessment:** Approve / Needs Work / Requires Changes

---

### Issues Found

#### Critical (Must Fix)
- **File:** `src/auth.js:42`
  **Issue:** Password stored in plain text
  **Fix:** Hash password before storing

#### Warnings (Should Fix)
- **File:** `src/user.js:15`
  **Issue:** No input validation
  **Fix:** Validate email format

#### Suggestions (Nice to Have)
- **File:** `src/utils.js:28`
  **Issue:** Could be more concise
  **Fix:** Use array methods instead of loop

---

### Positive Observations
- Good test coverage (95%)
- Clear function names
- Proper error handling

---

### Recommendations
{Next steps, improvements, follow-up items}
```

## Common Issues

### Security
- Hardcoded credentials (Critical)
- SQL injection vulnerabilities (Critical)
- Missing input validation (Critical)
- Exposed sensitive data (Critical)

### Code Quality
- Large functions (>50 lines) (Warning)
- Deep nesting (>3 levels) (Warning)
- Code duplication (Warning)
- Unclear naming (Warning)

### Testing
- Missing tests (Warning)
- Low coverage (<80%) (Warning)
- Flaky tests (Warning)
- Tests testing implementation (Warning)

## Best Practices

- Review within 24 hours
- Provide specific, actionable feedback
- Explain WHY, not just WHAT
- Suggest alternatives
- Acknowledge good work
- Use severity levels (Critical/Warning/Suggestion)
- Test the code if possible
- Check for security issues first

**Golden Rule**: Review code as you'd want yours reviewed - thoroughly but kindly.
