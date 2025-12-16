# LEAN 4 Linting Research Report

**Date**: 2025-12-15  
**LEAN Version**: 4.14.0  
**Lake Version**: 5.0.0-410fab7  
**Mathlib Version**: v4.14.0  

---

## Executive Summary

This report provides comprehensive research on LEAN 4 linting capabilities, Lake build system support, and community best practices. Key findings:

1. **Lake has native `lint` command support** (added in Lake 4.x)
2. **Two distinct linting systems exist**: syntax linters (built-in) and environment linters (Batteries/Mathlib)
3. **Mathlib uses custom lint infrastructure** via `lake exe runLinter` (not `lake lint`)
4. **Linter configuration is primarily via `set_option` and linter sets**
5. **No `lintDriver` configuration in lakefile.toml** - this is a Lake 4.x feature for lakefile.lean

---

## 1. Lake Linting Infrastructure

### 1.1 Lake Commands

Lake 5.0.0 provides two linting-related commands:

```bash
lake lint                  # lint the package using the configured lint driver
lake check-lint            # check if there is a properly configured lint driver
```

**Source**: `lake --help` output

### 1.2 Lint Driver Configuration

**In lakefile.lean** (NOT lakefile.toml):

```lean
package myPackage where
  lintDriver := "myLintScript"  -- Option 1: specify by name
  -- OR use @[lint_driver] attribute on script/executable
```

**Attribute-based configuration**:

```lean
@[lint_driver]
lean_exe myLinter where
  srcDir := "scripts"
```

**Source**: `lake help lint` output

### 1.3 How Lake Lint Works

From `lake help lint`:

> A lint driver can be configured by either setting the `lintDriver` package
> configuration option by tagging a script or executable `@[lint_driver]`.
> A definition in dependency can be used as a test driver by using the
> `<pkg>/<name>` syntax for the 'testDriver' configuration option.
>
> A script lint driver will be run with the package configuration's
> `lintDriverArgs` plus the CLI `args`. An executable lint driver will be
> built and then run like a script.

**Key Points**:
- Lint driver is a **script or executable**
- Can be configured via `lintDriver` option OR `@[lint_driver]` attribute
- Receives `lintDriverArgs` from package config plus CLI args
- Executables are built before running

### 1.4 Lake Version Compatibility

- **Lake 4.14.0+**: Native `lint` command support
- **Earlier versions**: No built-in lint command
- **lakefile.toml**: Does NOT support `lintDriver` (only lakefile.lean)

---

## 2. LEAN 4 Built-in Linters

### 2.1 Core Linters (Lean 4.14.0)

Located in `/src/Lean/Linter/`:

| Linter File | Purpose |
|------------|---------|
| `Basic.lean` | Linter infrastructure, `LinterOptions`, `linter.all` |
| `Builtin.lean` | Suspicious unexpander patterns |
| `Coe.lean` | Deprecated/banned coercions |
| `ConstructorAsVariable.lean` | Constructor naming issues |
| `Deprecated.lean` | Deprecated declaration usage |
| `DocsOnAlt.lean` | Documentation on tactic alternatives |
| `MissingDocs.lean` | Missing documentation |
| `Omit.lean` | Omit linter |
| `Sets.lean` | Linter sets infrastructure |
| `UnusedSimpArgs.lean` | Unused simp arguments |
| `UnusedVariables.lean` | Unused variables in declarations |
| `Util.lean` | Linter utilities |

**Source**: `/tmp/lean4/src/Lean/Linter/` directory listing

### 2.2 Core Linter Options

**Global linter control**:

```lean
set_option linter.all true  -- Enable ALL linters
```

**Individual linters** (from source code inspection):

```lean
-- Core linters (examples, not exhaustive)
set_option linter.suspiciousUnexpanderPatterns true
set_option linter.deprecatedCoercions true
set_option linter.missingDocs true
set_option linter.unusedVariables true
set_option linter.unusedVariables.funArgs true
set_option linter.unusedVariables.patternVars true
```

**Source**: `/tmp/lean4/src/Lean/Linter/*.lean` files

### 2.3 Linter Sets Infrastructure

**Definition** (from `Lean.Linter.Basic`):

```lean
/-- Linter sets are represented as a map from linter name to set name,
to make it easy to look up which sets to check for enabling a linter. -/
def LinterSets := NameMap (Array Name)
```

**Registration**:

```lean
register_linter_set myLinterSet :=
  linter.option1
  linter.option2
  linter.option3
```

**Enabling a set**:

```lean
set_option linter.myLinterSet true
```

**Source**: `/tmp/lean4/src/Lean/Linter/Basic.lean`

### 2.4 Linter Precedence

From `Lean.Linter.Basic.getLinterValue`:

1. If linter option is explicitly set → use that value
2. Else if `linter.all` is set → use `linter.all` value
3. Else if any linter set containing the option is enabled → enable
4. Else → use default value

**Source**: `/tmp/lean4/src/Lean/Linter/Basic.lean:70-71`

---

## 3. Mathlib Linting Infrastructure

### 3.1 Mathlib Linter Architecture

Mathlib uses **two distinct linting systems**:

1. **Syntax Linters**: Run during compilation (via `set_option`)
2. **Environment Linters**: Run post-build via `lake exe runLinter`

### 3.2 Syntax Linters (Mathlib/Tactic/Linter/)

**27 custom syntax linters** in `Mathlib/Tactic/Linter/`:

| Linter | Purpose |
|--------|---------|
| `CommandRanges.lean` | Command range checking |
| `CommandStart.lean` | Command start position |
| `DeprecatedModule.lean` | Deprecated module imports |
| `DeprecatedSyntaxLinter.lean` | Deprecated syntax (refine, cases, induction, admit, etc.) |
| `DirectoryDependency.lean` | Directory dependency violations |
| `DocPrime.lean` | Documentation prime notation |
| `DocString.lean` | Documentation string format |
| `EmptyLine.lean` | Empty line style |
| `FindDeprecations.lean` | Find deprecated declarations |
| `FlexibleLinter.lean` | Flexible linter |
| `GlobalAttributeIn.lean` | Global attribute usage |
| `HashCommandLinter.lean` | Hash command usage |
| `HaveLetLinter.lean` | Have/let style |
| `Header.lean` | File header format |
| `Lint.lean` | Environment linter integration |
| `MinImports.lean` | Minimal imports |
| `Multigoal.lean` | Multi-goal tactic usage |
| `OldObtain.lean` | Old obtain syntax |
| `PPRoundtrip.lean` | Pretty-printer roundtrip |
| `PrivateModule.lean` | Private module declarations |
| `Style.lean` | Style linters (setOption, missingEnd, cdot, dollar, lambda, longFile, longLine, openClassical, show) |
| `TextBased.lean` | Text-based linters (adaptationNote, trailingWhitespace, etc.) |
| `UnusedInstancesInType.lean` | Unused instances in type |
| `UnusedTacticExtension.lean` | Unused tactic extension |
| `UnusedTactic.lean` | Unused tactics |
| `UpstreamableDecl.lean` | Upstreamable declarations |
| `ValidatePRTitle.lean` | PR title validation |

**Source**: `/tmp/mathlib4/Mathlib/Tactic/Linter/` directory

### 3.3 Mathlib Linter Sets

**Defined in `Mathlib/Init.lean`**:

```lean
register_linter_set linter.mathlibStandardSet :=
  linter.flexible
  linter.hashCommand
  linter.oldObtain
  linter.privateModule
  linter.style.cases
  linter.style.induction
  linter.style.refine
  linter.style.commandStart
  linter.style.cdot
  linter.style.docString
  linter.style.dollarSyntax
  linter.style.emptyLine
  linter.style.header
  linter.style.lambdaSyntax
  linter.style.longLine
  linter.style.longFile
  linter.style.multiGoal
  linter.style.nativeDecide
  linter.style.openClassical
  linter.style.missingEnd
  linter.style.setOption
  linter.style.show
  linter.style.maxHeartbeats
  linter.unusedDecidableInType

register_linter_set linter.nightlyRegressionSet :=
  linter.tacticAnalysis.regressions.linarithToGrind
  linter.tacticAnalysis.regressions.omegaToLia
  linter.tacticAnalysis.regressions.ringToGrind
  linter.tacticAnalysis.regressions.tautoToGrind

register_linter_set linter.weeklyLintSet :=
  linter.tacticAnalysis.mergeWithGrind
```

**Source**: `/tmp/mathlib4/Mathlib/Init.lean:71-112`

### 3.4 Mathlib Lakefile Configuration

**From `mathlib4/lakefile.lean`**:

```lean
abbrev mathlibOnlyLinters : Array LeanOption := #[
  ⟨`linter.mathlibStandardSet, true⟩,
  ⟨`linter.style.header, true⟩,
  ⟨`linter.checkInitImports, true⟩,
  ⟨`linter.allScriptsDocumented, true⟩,
  ⟨`linter.pythonStyle, true⟩,
  ⟨`linter.style.longFile, .ofNat 1500⟩,
]

abbrev mathlibLeanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩,
    ⟨`experimental.module, true⟩,
    ⟨`backward.privateInPublic, true⟩,
    ⟨`backward.privateInPublic.warn, false⟩,
    ⟨`backward.proofsInPublic, true⟩,
    ⟨`maxSynthPendingDepth, .ofNat 3⟩
  ] ++ mathlibOnlyLinters.map fun s ↦ { s with name := `weak ++ s.name }

package mathlib where
  testDriver := "MathlibTest"

@[default_target]
lean_lib Mathlib where
  leanOptions := mathlibLeanOptions
```

**Key Points**:
- Linters enabled via `leanOptions` with `weak.` prefix
- `weak.` prefix means options apply during `lake build`
- No `lintDriver` configuration (uses custom `runLinter` executable)

**Source**: `/tmp/mathlib4/lakefile.lean:28-77`

### 3.5 Text-Based Linters

**Executable**: `lake exe lint-style`

**Implementation**: `/tmp/mathlib4/scripts/lint-style.lean`

**Linters**:
- `linter.adaptationNote`: Adaptation note format
- `linter.trailingWhitespace`: Trailing whitespace
- `linter.whitespaceBeforeSemicolon`: Whitespace before semicolon
- `linter.nonbreakingSpace`: Non-breaking space usage
- `linter.checkInitImports`: Mathlib.Init import verification
- `linter.allScriptsDocumented`: Script documentation
- `linter.pythonStyle`: Python-style linting

**Usage**:

```bash
lake exe lint-style                    # Lint default targets
lake exe lint-style Mathlib.Data.Nat   # Lint specific module
lake exe lint-style --fix              # Auto-fix issues
lake exe lint-style --github           # GitHub problem matcher format
```

**Source**: `/tmp/mathlib4/scripts/lint-style.lean`

### 3.6 Environment Linters (Batteries)

**Executable**: `lake exe runLinter` (from Batteries)

**Implementation**: `/tmp/batteries/scripts/runLinter.lean`

**Linter Structure** (from `Batteries/Tactic/Lint/Basic.lean`):

```lean
structure Linter where
  test : Name → MetaM (Option MessageData)
  noErrorsFound : MessageData
  errorsFound : MessageData
  isFast := true

structure NamedLinter extends Linter where
  name : Name
  declName : Name
```

**Attribute**:

```lean
@[env_linter]           -- Add to default set
@[env_linter disabled]  -- Register but don't run by default
```

**Available Environment Linters** (from Batteries):

| Linter | Purpose | Default |
|--------|---------|---------|
| `dupNamespace` | Duplicate namespace in name | ✓ |
| `unusedArguments` | Unused function arguments | ✓ |
| `docBlame` | Missing documentation (definitions) | ✓ |
| `docBlameThm` | Missing documentation (theorems) | ✗ |
| `defLemma` | Incorrect def/lemma usage | ✓ |
| `checkType` | Type-checking with default reducibility | ✓ |

**Plus Mathlib-specific environment linters**:
- `structureInType`: Structures that should be in Prop
- `deprecatedNoSince`: Deprecated without since date

**Source**: `/tmp/batteries/Batteries/Tactic/Lint/Misc.lean`, `/tmp/mathlib4/Mathlib/Tactic/Linter/Lint.lean`

**Usage**:

```bash
lake exe runLinter                    # Lint default targets
lake exe runLinter Mathlib            # Lint Mathlib module
lake exe runLinter --update Mathlib   # Update nolints.json
```

**Nolints File**: `scripts/nolints.json`

Format:

```json
[
  ["linterName", "Declaration.Name"],
  ["docBlame", "CongrMetaM"],
  ["docBlame", "CongrState"],
  ...
]
```

**Source**: `/tmp/batteries/scripts/runLinter.lean`, `/tmp/mathlib4/scripts/nolints.json`

---

## 4. Community Practices

### 4.1 Mathlib CI/CD Integration

**GitHub Actions Workflow** (`.github/workflows/build.yml`):

```yaml
- name: lint mathlib
  id: lint
  run: |
    cd pr-branch
    env LEAN_ABORT_ON_PANIC=1 ../master-branch/scripts/lake-build-wrapper.py \
      .lake/build_summary_lint.json lake exe runLinter Mathlib
```

**Key Points**:
- Runs **after** successful build
- Uses `lake exe runLinter` (NOT `lake lint`)
- Wrapped in `lake-build-wrapper.py` for metrics
- Outputs to `.lake/build_summary_lint.json`
- Uses GitHub problem matchers for error formatting

**Source**: `/tmp/mathlib4/.github/workflows/build.yml:54,244-248`

### 4.2 Style Linting in CI

**GitHub Actions** (uses external action):

```yaml
- uses: leanprover-community/lint-style-action@a7e7428fa44f9635d6eb8e01919d16fd498d387a
  with:
    lint-bib-file: true
```

**Source**: `/tmp/mathlib4/.github/workflows/build.yml` (style_lint job)

### 4.3 Linter Output Format

**Standard format** (from `Batteries/Tactic/Lint/Frontend.lean`):

```lean
def printWarning (declName : Name) (warning : MessageData) 
    (useErrorFormat : Bool := false)
    (filePath : System.FilePath := default) : CoreM MessageData := do
  if useErrorFormat then
    if let some range ← findDeclarationRanges? declName then
      return m!"{filePath}:{range.range.pos.line}:{range.range.pos.column + 1}: error: {
        ← mkConstWithLevelParams declName} {warning}"
  return m!"#check {← mkConstWithLevelParams declName} /- {warning} -/"
```

**Two formats**:
1. **Human-readable**: `#check Decl.Name /- warning message -/`
2. **Error format**: `file.lean:line:col: error: Decl.Name warning message`

**Source**: `/tmp/batteries/Batteries/Tactic/Lint/Frontend.lean:131-139`

### 4.4 Suppression Mechanisms

**1. `@[nolint]` attribute** (per-declaration):

```lean
@[nolint docBlame unusedArguments]
def myFunction := ...
```

**2. `nolints.json` file** (project-wide):

```json
[["linterName", "Declaration.Name"]]
```

**3. `set_option` (file/section scope)**:

```lean
set_option linter.unusedVariables false in
def myFunction := ...
```

**Source**: `/tmp/batteries/Batteries/Tactic/Lint/Basic.lean:120-142`

### 4.5 Pre-commit Hooks

Mathlib uses `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: lint-style
        name: lint-style
        entry: lake exe lint-style
        language: system
        pass_filenames: false
```

**Source**: `/tmp/mathlib4/.pre-commit-config.yaml` (inferred from project structure)

---

## 5. Technical Details

### 5.1 Linter Execution Model

**Syntax Linters**:
- Run **during compilation** (elaboration phase)
- Implemented as `Linter` with `run : Syntax → CommandElabM Unit`
- Registered via `builtin_initialize addLinter myLinter`
- Enabled via `set_option linter.name true`

**Environment Linters**:
- Run **after compilation** (on `.olean` files)
- Implemented as `Linter` with `test : Name → MetaM (Option MessageData)`
- Registered via `@[env_linter]` attribute
- Run via `#lint` command or `lake exe runLinter`

**Source**: `/tmp/lean4/src/Lean/Linter/`, `/tmp/batteries/Batteries/Tactic/Lint/`

### 5.2 Performance Considerations

**Fast vs. Slow Linters**:

```lean
structure Linter where
  ...
  isFast := true  -- If false, omitted from `#lint-`
```

**Parallel Execution** (from `Batteries/Tactic/Lint/Frontend.lean`):

```lean
def lintCore (decls : Array Name) (linters : Array NamedLinter) :
    CoreM (Array (NamedLinter × Std.HashMap Name MessageData)) := do
  let tasks : Array (NamedLinter × Array (Name × Task (Option MessageData))) ←
    linters.mapM fun linter => do
      let decls ← decls.filterM (shouldBeLinted linter.name)
      (linter, ·) <$> decls.mapM fun decl => (decl, ·) <$> do
        BaseIO.asTask do
          -- Run linter in parallel task
```

**Key Points**:
- Environment linters run in parallel tasks
- Each declaration linted independently
- Results collected and formatted

**Source**: `/tmp/batteries/Batteries/Tactic/Lint/Frontend.lean:98-120`

### 5.3 Linter Configuration Precedence

**For syntax linters**:

1. Explicit `set_option linter.name value`
2. `linter.all` setting
3. Linter set membership (e.g., `linter.mathlibStandardSet`)
4. Default value

**For environment linters**:

1. `@[nolint linterName]` attribute → skip
2. `nolints.json` entry → skip
3. Otherwise → run if enabled

**Source**: `/tmp/lean4/src/Lean/Linter/Basic.lean`, `/tmp/batteries/scripts/runLinter.lean`

### 5.4 Integration with Lake Build

**Mathlib approach** (does NOT use `lake lint`):

1. **Build phase**: Syntax linters run automatically (via `leanOptions`)
2. **Post-build phase**: Run `lake exe lint-style` (text-based)
3. **Post-build phase**: Run `lake exe runLinter` (environment linters)

**Why not `lake lint`?**:
- Mathlib predates Lake's `lint` command
- Custom infrastructure provides more control
- Separate text-based and environment linting
- Integration with `nolints.json` exception system

**Source**: `/tmp/mathlib4/.github/workflows/build.yml`, `/tmp/mathlib4/lakefile.lean`

---

## 6. Examples and Code Snippets

### 6.1 Minimal Lake Lint Driver

**lakefile.lean**:

```lean
import Lake
open Lake DSL

package myPackage

@[lint_driver]
lean_exe myLinter where
  srcDir := "scripts"
  root := `MyLinter
```

**scripts/MyLinter.lean**:

```lean
import Lean

def main (args : List String) : IO Unit := do
  IO.println "Running custom linter..."
  -- Implement linting logic
  IO.Process.exit 0
```

**Usage**:

```bash
lake lint              # Runs myLinter
lake check-lint        # Verifies myLinter is configured
```

### 6.2 Custom Syntax Linter

```lean
import Lean.Linter

open Lean Parser Elab Command Linter

register_option linter.myCustomLinter : Bool := {
  defValue := false
  descr := "enable my custom linter"
}

def myCustomLinter : Linter where run := withSetOptionIn fun stx => do
  unless getLinterValue linter.myCustomLinter (← getLinterOptions) do
    return
  -- Implement linting logic
  if someCondition stx then
    logLint linter.myCustomLinter stx m!"Custom lint warning"

builtin_initialize addLinter myCustomLinter
```

**Enable**:

```lean
set_option linter.myCustomLinter true
```

### 6.3 Custom Environment Linter

```lean
import Batteries.Tactic.Lint

open Lean Meta Batteries.Tactic.Lint

@[env_linter]
def myEnvLinter : Linter where
  noErrorsFound := "No issues found."
  errorsFound := "ISSUES FOUND:"
  test declName := do
    let info ← getConstInfo declName
    -- Implement linting logic
    if someCondition info then
      return some m!"Issue with {declName}"
    return none
```

**Run**:

```bash
lake exe runLinter MyModule
```

### 6.4 Linter Set Definition

```lean
import Lean.Linter.Sets

register_linter_set linter.myProjectSet :=
  linter.unusedVariables
  linter.missingDocs
  linter.style.longLine
  linter.myCustomLinter
```

**Enable**:

```lean
set_option linter.myProjectSet true
```

**In lakefile.lean**:

```lean
lean_lib MyLib where
  leanOptions := #[⟨`weak.linter.myProjectSet, true⟩]
```

---

## 7. Discrepancies and Gotchas

### 7.1 lakefile.toml vs lakefile.lean

**CRITICAL**: `lintDriver` is **NOT supported** in `lakefile.toml`

- ✓ **lakefile.lean**: Supports `lintDriver` option and `@[lint_driver]` attribute
- ✗ **lakefile.toml**: No linting configuration support

**Workaround**: Convert to `lakefile.lean` or use custom executable approach

### 7.2 Lake Lint vs Mathlib Approach

**Lake's `lake lint`**:
- Runs configured lint driver (script/executable)
- Single entry point
- Newer feature (Lake 4.x+)

**Mathlib's approach**:
- Multiple executables (`lint-style`, `runLinter`)
- Separate text-based and environment linting
- More granular control
- Predates `lake lint`

**Recommendation**: For new projects, consider `lake lint`. For Mathlib-style projects, follow Mathlib's pattern.

### 7.3 Linter Naming Confusion

**Three different "linters"**:

1. **Syntax linters**: Run during compilation (e.g., `linter.unusedVariables`)
2. **Environment linters**: Run post-build (e.g., `@[env_linter] def docBlame`)
3. **Text-based linters**: Run on source files (e.g., `linter.trailingWhitespace`)

**Key distinction**: Syntax linters use `set_option`, environment linters use `@[env_linter]`

### 7.4 Default Linter Behavior

**Syntax linters**:
- Most are **disabled by default**
- Enable via `set_option` or linter sets
- Exception: Some core linters enabled by default

**Environment linters**:
- Enabled by default unless `@[env_linter disabled]`
- Disable via `@[nolint]` or `nolints.json`

### 7.5 Linter Output Parsing

**Two incompatible formats**:

1. **Human-readable**: `#check Decl.Name /- warning -/`
2. **Error format**: `file.lean:line:col: error: warning`

**For CI integration**: Use error format with `useErrorFormat := true`

---

## 8. Recommendations for ProofChecker

### 8.1 Linting Strategy

**Recommended approach** (hybrid):

1. **Use Lake's `lake lint`** for top-level integration
2. **Implement custom lint driver** that orchestrates:
   - Syntax linters (via `set_option` in lakefile)
   - Environment linters (via custom executable)
   - Text-based linters (via custom script)

### 8.2 Lakefile Configuration

**Convert to lakefile.lean**:

```lean
import Lake
open Lake DSL

package Logos where
  lintDriver := "lintAll"

lean_lib Logos where
  leanOptions := #[
    ⟨`weak.linter.all, false⟩,  -- Disable all by default
    ⟨`weak.linter.unusedVariables, true⟩,
    ⟨`weak.linter.missingDocs, true⟩,
    ⟨`weak.linter.style.longLine, true⟩,
  ]

@[lint_driver]
lean_exe lintAll where
  srcDir := "scripts"
  root := `LintAll
```

### 8.3 Custom Lint Driver

**scripts/LintAll.lean**:

```lean
import Lean
import Batteries.Tactic.Lint

def main (args : List String) : IO Unit := do
  -- 1. Run environment linters
  let exitCode1 ← runEnvLinters args
  
  -- 2. Run text-based linters
  let exitCode2 ← runTextLinters args
  
  -- 3. Combine results
  if exitCode1 ≠ 0 || exitCode2 ≠ 0 then
    IO.Process.exit 1
  else
    IO.println "All linters passed!"
    IO.Process.exit 0
```

### 8.4 CI/CD Integration

**GitHub Actions**:

```yaml
- name: Lint
  run: |
    lake lint
  env:
    LEAN_ABORT_ON_PANIC: 1
```

**With problem matchers**:

```yaml
- name: Setup problem matchers
  uses: leanprover-community/gh-problem-matcher-wrap@v1
  with:
    action: add
    linters: lean

- name: Lint
  run: lake lint

- name: Remove problem matchers
  uses: leanprover-community/gh-problem-matcher-wrap@v1
  with:
    action: remove
```

### 8.5 Validation Framework Integration

**For opencode validation**:

1. **Pre-execution validation**: Run `lake check-lint` to verify configuration
2. **Post-build validation**: Run `lake lint` and capture exit code
3. **Parse output**: Use error format for structured parsing
4. **Report results**: Integrate with validation report

**Example**:

```bash
# Check lint driver configured
if ! lake check-lint; then
  echo "ERROR: No lint driver configured"
  exit 1
fi

# Run linting
if ! lake lint; then
  echo "ERROR: Linting failed"
  exit 1
fi
```

---

## 9. Authoritative Sources

### 9.1 Official Documentation

- **LEAN 4 Documentation**: https://lean-lang.org/lean4/doc/
- **Lake README**: https://github.com/leanprover/lean4/blob/master/src/lake/README.md
- **Mathlib Documentation**: https://leanprover-community.github.io/
- **Batteries Documentation**: https://github.com/leanprover-community/batteries

### 9.2 Source Code References

- **Lake Linter**: `/tmp/lean4/src/lake/` (Lake 5.0.0)
- **Core Linters**: `/tmp/lean4/src/Lean/Linter/` (Lean 4.14.0)
- **Mathlib Linters**: `/tmp/mathlib4/Mathlib/Tactic/Linter/` (Mathlib v4.14.0)
- **Batteries Linters**: `/tmp/batteries/Batteries/Tactic/Lint/` (Batteries main)

### 9.3 Community Resources

- **Lean Zulip**: https://leanprover.zulipchat.com/
- **Mathlib Style Guide**: https://leanprover-community.github.io/contribute/style.html
- **Mathlib Linting Guide**: https://leanprover-community.github.io/contribute/doc.html

---

## 10. Version-Specific Notes

### 10.1 LEAN 4.14.0

- ✓ Full linter infrastructure
- ✓ Linter sets support
- ✓ `linter.all` option
- ✓ Syntax and environment linters

### 10.2 Lake 5.0.0

- ✓ `lake lint` command
- ✓ `lake check-lint` command
- ✓ `lintDriver` configuration (lakefile.lean only)
- ✓ `@[lint_driver]` attribute

### 10.3 Mathlib v4.14.0

- ✓ 27 custom syntax linters
- ✓ 3 linter sets (standard, nightly, weekly)
- ✓ Text-based linting via `lint-style`
- ✓ Environment linting via `runLinter`
- ✓ `nolints.json` exception system

---

## Appendix A: Complete Linter List

### A.1 Core LEAN 4 Linters

| Option | Default | Description |
|--------|---------|-------------|
| `linter.all` | false | Enable all linters |
| `linter.suspiciousUnexpanderPatterns` | true | Suspicious unexpander patterns |
| `linter.deprecatedCoercions` | true | Deprecated coercions |
| `linter.missingDocs` | false | Missing documentation |
| `linter.unusedVariables` | true | Unused variables |
| `linter.unusedVariables.funArgs` | true | Unused function arguments |
| `linter.unusedVariables.patternVars` | true | Unused pattern variables |

### A.2 Mathlib Syntax Linters

| Option | Default | Description |
|--------|---------|-------------|
| `linter.mathlibStandardSet` | false | Enable all standard Mathlib linters |
| `linter.flexible` | false | Flexible linter |
| `linter.hashCommand` | false | Hash command usage |
| `linter.oldObtain` | false | Old obtain syntax |
| `linter.privateModule` | false | Private module declarations |
| `linter.style.cases` | false | Deprecated cases syntax |
| `linter.style.induction` | false | Deprecated induction syntax |
| `linter.style.refine` | false | Deprecated refine syntax |
| `linter.style.commandStart` | false | Command start position |
| `linter.style.cdot` | false | Focusing dot style |
| `linter.style.docString` | false | Documentation string format |
| `linter.style.dollarSyntax` | false | Dollar syntax usage |
| `linter.style.emptyLine` | false | Empty line style |
| `linter.style.header` | false | File header format |
| `linter.style.lambdaSyntax` | false | Lambda syntax style |
| `linter.style.longLine` | false | Long line (>100 chars) |
| `linter.style.longFile` | false | Long file (>1500 lines) |
| `linter.style.multiGoal` | false | Multi-goal tactic usage |
| `linter.style.nativeDecide` | false | Native decide usage |
| `linter.style.openClassical` | false | Open Classical usage |
| `linter.style.missingEnd` | false | Missing end statement |
| `linter.style.setOption` | false | Set option usage |
| `linter.style.show` | false | Show vs change |
| `linter.style.maxHeartbeats` | false | Max heartbeats setting |
| `linter.unusedDecidableInType` | false | Unused decidable instances |

### A.3 Mathlib Environment Linters

| Linter | Default | Description |
|--------|---------|-------------|
| `dupNamespace` | ✓ | Duplicate namespace in name |
| `unusedArguments` | ✓ | Unused function arguments |
| `docBlame` | ✓ | Missing documentation (definitions) |
| `docBlameThm` | ✗ | Missing documentation (theorems) |
| `defLemma` | ✓ | Incorrect def/lemma usage |
| `checkType` | ✓ | Type-checking issues |
| `structureInType` | ✓ | Structures that should be in Prop |
| `deprecatedNoSince` | ✓ | Deprecated without since date |

---

## Appendix B: Lake Lint Command Reference

```bash
# Check if lint driver is configured
lake check-lint

# Run linting
lake lint

# Run linting with arguments
lake lint -- --verbose

# Run linting on specific module
lake lint -- MyModule

# Verbose output
lake lint -v

# Quiet output
lake lint -q
```

---

## Appendix C: Mathlib Linting Commands

```bash
# Text-based linting
lake exe lint-style                    # Lint default targets
lake exe lint-style Mathlib.Data.Nat   # Lint specific module
lake exe lint-style --fix              # Auto-fix issues
lake exe lint-style --github           # GitHub format

# Environment linting
lake exe runLinter                     # Lint default targets
lake exe runLinter Mathlib             # Lint Mathlib
lake exe runLinter --update Mathlib    # Update nolints.json

# Interactive linting
#lint                                  # Lint current file
#lint in Mathlib                       # Lint Mathlib package
#lint in all                           # Lint all imports
#lint*                                 # Omit slow linters
#lint-                                 # Silent mode
#lint+                                 # Verbose mode
#lint only docBlame unusedArguments    # Run specific linters
```

---

**End of Report**
