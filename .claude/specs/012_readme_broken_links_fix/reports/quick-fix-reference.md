# Quick Fix Reference - README.md Broken Links

**6 Broken Links → 6 Simple Fixes**

---

## Fix #1: LICENSE (Line 165)
**Create new file**: `/home/benjamin/Documents/Philosophy/Projects/Logos/LICENSE`
**Content**: MIT License text (see https://opensource.org/licenses/MIT)

---

## Fix #2: LEAN Style Guide (Line 88)
**Find**:
```markdown
- [LEAN Style Guide](src/docs/LEAN_STYLE_GUIDE.md) - Coding conventions
```

**Replace**:
```markdown
- [LEAN Style Guide](docs/development/LEAN_STYLE_GUIDE.md) - Coding conventions
```

---

## Fix #3: Module Organization (Line 89)
**Find**:
```markdown
- [Module Organization](src/docs/MODULE_ORGANIZATION.md) - Project structure
```

**Replace**:
```markdown
- [Module Organization](docs/development/MODULE_ORGANIZATION.md) - Project structure
```

---

## Fix #4: Testing Standards (Line 90)
**Find**:
```markdown
- [Testing Standards](src/docs/TESTING_STANDARDS.md) - Test requirements
```

**Replace**:
```markdown
- [Testing Standards](docs/development/TESTING_STANDARDS.md) - Test requirements
```

---

## Fix #5: Tactic Development (Line 91)
**Find**:
```markdown
- [Tactic Development](src/docs/TACTIC_DEVELOPMENT.md) - Custom tactics
```

**Replace**:
```markdown
- [Tactic Development](docs/development/TACTIC_DEVELOPMENT.md) - Custom tactics
```

---

## Fix #6: API Reference (Line 85)
**Find**:
```markdown
- [API Reference](doc/) - Generated API documentation (run `lake build :docs`)
```

**Replace**:
```markdown
- [API Reference](.lake/build/doc/) - Generated API documentation (run `lake build :docs` to generate)
```

---

## One-Line Summary
**Pattern**: All developer standards moved from `src/docs/` → `docs/development/`
**Pattern**: API docs actually generate to `.lake/build/doc/` not `doc/`
**New File**: Create LICENSE file with MIT License text

---

## Verification Commands

```bash
# After fixes, verify all links point to existing files:
cd /home/benjamin/Documents/Philosophy/Projects/Logos

# Check LICENSE
ls -la LICENSE

# Check developer docs
ls -la docs/development/LEAN_STYLE_GUIDE.md
ls -la docs/development/MODULE_ORGANIZATION.md
ls -la docs/development/TESTING_STANDARDS.md
ls -la docs/development/TACTIC_DEVELOPMENT.md

# Generate and check API docs
lake build :docs
ls -la .lake/build/doc/
```

---

## End of Quick Reference
