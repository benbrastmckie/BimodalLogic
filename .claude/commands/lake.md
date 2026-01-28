---
description: Run Lean build with automatic error repair
allowed-tools: Read, Write, Edit, Bash, mcp__lean-lsp__lean_build, mcp__lean-lsp__lean_diagnostic_messages
argument-hint: [--clean] [--max-retries N] [--dry-run] [--module NAME]
---

# /lake Command

Run `lake build` with automatic repair of common errors. Iteratively builds, parses errors, and applies mechanical fixes until the build succeeds or max retries are reached.

## Syntax

```
/lake [options]
```

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--clean` | Run `lake clean` before building | false |
| `--max-retries N` | Maximum auto-fix iterations | 3 |
| `--dry-run` | Show what would be fixed without applying changes | false |
| `--module NAME` | Build specific module only (e.g., `Logos.Layer0.Basic`) | (all) |

## Auto-Fixable Errors

The skill automatically fixes these common error types:

| Error Type | Detection Pattern | Fix Strategy |
|------------|-------------------|--------------|
| Missing pattern match cases | `error: Missing cases:\n{case1}\n{case2}` | Add `\| {case} => sorry` branches |
| Unused variable | `warning: unused variable '{name}'` | Rename to `_{name}` |
| Unused import | `warning: unused import '{module}'` | Remove import line |

Errors not in this list are reported but not auto-fixed.

## Execution

Invoke skill-lake-repair:

```
skill: skill-lake-repair
args: {flags from command}
```

The skill executes a repair loop:

1. **Initial Build**: Run `lake build` (with `lake clean` if `--clean`)
2. **Parse Errors**: Extract errors from build output
3. **Classify Errors**: Identify auto-fixable vs unfixable errors
4. **Apply Fixes**: Edit source files to fix errors (unless `--dry-run`)
5. **Retry Build**: Rebuild and repeat until success or max retries

## Examples

### Basic Build with Auto-Repair

```bash
# Build and automatically fix mechanical errors
/lake
```

### Clean Rebuild

```bash
# Clean build artifacts first, then build with repair
/lake --clean
```

### Preview Mode

```bash
# Show what would be fixed without modifying files
/lake --dry-run
```

### Module-Specific Build

```bash
# Build only the specified module
/lake --module Logos.Layer1.Soundness
```

### Extended Retries

```bash
# Allow more fix iterations for complex cascading errors
/lake --max-retries 5
```

## Output

### Success

```
Lake Build Complete
===================

Build succeeded after 2 iterations.

Fixes applied:
- Logos/Layer1/Completeness.lean:45 - Added 2 missing match cases
- Logos/Layer0/Basic.lean:23 - Renamed unused variable 'h' to '_h'

All modules built successfully.
```

### Partial Success (Max Retries)

```
Lake Build Partial
==================

Max retries (3) reached. Build not yet passing.

Fixes applied (2 iterations):
- Logos/Layer1/Completeness.lean:45 - Added 2 missing match cases

Remaining errors (unfixable):
- Logos/Layer1/Soundness.lean:89:15: error: Type mismatch
    expected: Model.Valid M φ
    found:    Frame.Valid F φ

Recommendation: Fix the type error manually, then run /lake again.
```

### Dry Run

```
Lake Build Dry Run
==================

Would apply 3 fixes:

1. Logos/Layer1/Completeness.lean:45
   Error: Missing cases: Formula.implies, Formula.iff
   Fix: Add 2 match cases with sorry placeholders

2. Logos/Layer0/Basic.lean:23
   Warning: unused variable 'h'
   Fix: Rename to '_h'

3. Logos/Layer0/Basic.lean:5
   Warning: unused import 'Mathlib.Data.Nat.Basic'
   Fix: Remove import line

No changes made (dry run mode).
```

### No Errors

```
Lake Build Complete
===================

Build succeeded on first attempt.
No fixes needed.
```

## Stop Conditions

The repair loop stops when:

1. **Build succeeds**: All modules compile without errors
2. **Max retries reached**: Default 3 iterations
3. **No fixable errors**: All remaining errors are unfixable types
4. **Same errors repeated**: Fixes didn't resolve the errors (infinite loop prevention)

## Safety

- All fixes use `sorry` placeholders that compile but indicate incomplete work
- Git provides full undo capability (`git checkout -- path/to/file`)
- Original code is never deleted, only modified
- Use `--dry-run` to preview changes before applying
- Unused import removal is conservative (only removes the specific line)

## Troubleshooting

### Build hangs or times out

The `lake build` command may take a long time for large projects. Consider:
- Using `--module` to build specific modules
- Running `lake build` directly to see real-time output

### Fixes create new errors

This can happen when auto-fixes interact unexpectedly. The skill tracks whether the same errors recur and stops to prevent infinite loops. Review the changes and adjust manually if needed.

### MCP tool unavailable

If the `lean_build` MCP tool fails, the skill falls back to `lake build` via Bash.
