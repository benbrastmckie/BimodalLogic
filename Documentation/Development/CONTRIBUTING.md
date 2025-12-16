# Contributing to Logos

Thank you for your interest in contributing to Logos! This document provides guidelines for contributing to the project.

## 1. Getting Started

### Prerequisites

- LEAN 4 v4.14.0 or later
- Lake (included with LEAN 4)
- Git
- VS Code with lean4 extension (recommended)

### Development Setup

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR-USERNAME/Logos.git
cd Logos

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL-OWNER/Logos.git

# Install dependencies and build
lake update
lake build

# Run tests to verify setup
lake test
```

### Verifying Setup

```bash
# Build should complete without errors
lake build

# Tests should pass
lake test

# Linter should have no warnings
lake lint
```

## 2. Development Workflow

### Test-Driven Development (TDD)

Logos requires TDD for all new features:

#### 1. RED: Write a Failing Test

```lean
-- LogosTest/ProofSystem/NewFeatureTest.lean

/-- Test new theorem is provable -/
example : ⊢ my_new_theorem := by
  sorry  -- Test fails because theorem doesn't exist
```

#### 2. GREEN: Implement Minimal Code

```lean
-- Logos/Theorems/NewTheorem.lean

/-- New theorem: description -/
theorem my_new_theorem : ⊢ ... := by
  -- Implementation to make test pass
```

#### 3. REFACTOR: Improve Code Quality

- Add documentation
- Optimize if needed
- Ensure style compliance

### Code Style Compliance

All code must follow the [LEAN Style Guide](../Development/LEAN_STYLE_GUIDE.md):

```lean
-- Good: follows style guide
/-- Brief description of function -/
def my_function (x : Nat) : Nat :=
  x + 1

-- Bad: missing docstring, wrong naming
def MyFunction(x:Nat):Nat := x+1
```

### Documentation Requirements

Every public definition needs:

- Declaration docstring (`/-- ... -/`)
- Module docstrings for new files (`/-! ... -/`)
- Examples where appropriate

```lean
/-- Compute the complexity of a formula.

Returns the number of operators plus atomic formulas.

## Example

```lean
#eval (Formula.atom "p").complexity  -- 1
#eval (Formula.box (Formula.atom "p")).complexity  -- 2
```
-/
def complexity (φ : Formula) : Nat := ...
```

## 3. Pull Request Process

### Branch Naming

```
feature/description    -- New features
fix/issue-number      -- Bug fixes
docs/description      -- Documentation updates
refactor/description  -- Refactoring
```

Examples:
- `feature/temporal-duality-tactic`
- `fix/123-modus-ponens-edge-case`
- `docs/update-examples`

### Commit Message Format

```
<type>: <short description>

<detailed description if needed>

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Adding tests
- `refactor`: Code refactoring
- `style`: Style/formatting changes
- `chore`: Maintenance tasks

Examples:
```
feat: Add temporal_k tactic for TK rule application

Implements a custom tactic that automatically applies the
temporal K inference rule when the goal matches the pattern.

Fixes #45
```

### PR Description Template

```markdown
## Summary

Brief description of changes.

## Changes

- Change 1
- Change 2
- Change 3

## Testing

- [ ] Added unit tests
- [ ] All existing tests pass
- [ ] Manual testing performed

## Checklist

- [ ] Code follows style guide
- [ ] All public definitions have docstrings
- [ ] No `sorry` in committed code
- [ ] `lake lint` has no warnings
- [ ] Updated relevant documentation
```

### Submitting a PR

1. Create a feature branch from `main`
2. Make your changes with tests
3. Ensure `lake build`, `lake test`, `lake lint` all pass
4. Push to your fork
5. Open PR against upstream `main`
6. Address review feedback
7. Squash commits if requested

## 4. Code Review Checklist

Reviewers will check:

### Correctness
- [ ] All tests pass
- [ ] No `sorry` in committed code
- [ ] Logic is correct
- [ ] Edge cases handled

### Style
- [ ] Follows [LEAN Style Guide](../Development/LEAN_STYLE_GUIDE.md)
- [ ] 100-char line limit
- [ ] 2-space indentation
- [ ] Proper naming conventions

### Documentation
- [ ] All public definitions have docstrings
- [ ] Module docstring if new file
- [ ] Examples where appropriate
- [ ] Updated README if needed

### Testing
- [ ] New tests for new features
- [ ] Tests cover edge cases
- [ ] No decrease in coverage

### Performance
- [ ] No unnecessary computation
- [ ] Reasonable proof complexity
- [ ] Build time not significantly increased

## 5. Types of Contributions

### Bug Fixes

1. Create issue describing the bug
2. Reference issue in PR
3. Add regression test
4. Fix the bug
5. Verify fix with tests

### New Features

1. Discuss in issue first (for large features)
2. Follow TDD process
3. Document thoroughly
4. Add examples

### Documentation

- Fix typos and unclear explanations
- Add examples
- Improve tutorials
- Update outdated information

### Tests

- Increase coverage
- Add edge case tests
- Add integration tests
- Improve test organization

### Refactoring

- Discuss approach in issue first
- Ensure no behavior change
- All tests must pass
- Update documentation if APIs change

## 6. Community Resources

### Communication

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: Questions, ideas
- **Lean Zulip**: `#lean4` and `#mathlib4` channels

### Getting Help

- Check existing documentation first
- Search closed issues
- Ask in GitHub Discussions
- Ask on Lean Zulip

### Reporting Bugs

Include:
1. LEAN version (`lean --version`)
2. Steps to reproduce
3. Expected behavior
4. Actual behavior
5. Minimal reproducible example

```markdown
## Bug Report

### Environment
- LEAN: v4.14.0
- OS: Ubuntu 22.04

### Steps to Reproduce
1. Step 1
2. Step 2

### Expected Behavior
Description of expected behavior

### Actual Behavior
Description of actual behavior

### Minimal Example
```lean
-- Code that reproduces the issue
```
```

### Feature Requests

Include:
1. Problem being solved
2. Proposed solution
3. Alternatives considered
4. Additional context

## 7. Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes for significant contributions
- Commit history

## 8. Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn
- Follow project guidelines
- Report issues appropriately

## References

- [LEAN Style Guide](../Development/LEAN_STYLE_GUIDE.md)
- [Testing Standards](../Development/TESTING_STANDARDS.md)
- [Module Organization](../Development/MODULE_ORGANIZATION.md)
- [Quality Metrics](../Development/QUALITY_METRICS.md)
- [Tactic Development](../UserGuide/TACTIC_DEVELOPMENT.md)
