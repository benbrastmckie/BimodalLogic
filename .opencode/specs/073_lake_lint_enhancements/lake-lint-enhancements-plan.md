# Lake Lint Enhancements - Implementation Plan

**Spec ID:** 073  
**Created:** 2025-12-15  
**Status:** IN PROGRESS (Phase 1.3 - 50% complete)  
**Priority:** Medium  
**Estimated Effort:** 10-12 hours (3.5 hours completed, 6.5-8.5 hours remaining)  
**Dependencies:** Lake Lint Integration (Complete)

## Executive Summary

This specification defines enhancements to the Lake Lint Integration system, building on the production-ready foundation established in the initial implementation. The plan addresses remaining technical debt (169 long lines), implements full Batteries integration for environment linters, adds advanced TM-specific linters, and optimizes performance through caching and parallelization.

## Current Status (2025-12-15)

**Phase 1.3 Progress: 50% Complete** 🎉

- **Starting violations**: 169 long lines across 17 files
- **Current violations**: 84 long lines across 15 files
- **Fixed**: 85 violations (50% reduction)
- **Time invested**: 3.5 hours of estimated 4 hours

**Completed Files:**
- ✅ Combinators.lean: 47 → 0 (100% complete)
- ✅ Truth.lean: 32 → 4 (88% complete)
- 🔄 ModalS5.lean: 21 → 11 (48% complete)

**Remaining Work:**
- ModalS5.lean: 11 violations (~20 min)
- Propositional.lean: 20 violations (~40 min)
- 13 other files: 53 violations (~2-3 hours)

**Commits:**
- `6b09330` - Combinators.lean (47 fixes)
- `9324692` - Truth.lean (28 fixes)
- `cd2bae2` - ModalS5.lean (10 fixes)

**Documentation Created:**
- ✅ long-lines-analysis.md (Phase 1.1 complete)
- ✅ long-line-refactoring-guidelines.md (Phase 1.2 complete)
- ✅ progress.md (tracking document)

**Next Session:**
1. Complete ModalS5.lean (11 remaining)
2. Fix Propositional.lean (20 violations)
3. Fix remaining 13 files (53 violations)
4. Run final `lake lint` verification
5. Update plan to Phase 1 COMPLETE

**Note:** IDE integration (VS Code/Neovim plugins) has been removed from this plan. The existing CLI tools (`lake lint`, `lake lint -- --fix`) combined with pre-commit hooks and CI/CD enforcement provide sufficient workflow integration. Users can optionally configure their editors to run `lake lint` via standard mechanisms (`:make` in Neovim, tasks in VS Code, etc.).

## Current State Analysis

### Completed (Phases 1-6)

✅ **Infrastructure:**
- Lake native `lake lint` command functional
- Custom lint driver (`LintAll.lean`) orchestrating linting phases
- Lakefile.lean configuration with lint driver registration
- CI/CD integration with GitHub Actions
- Opencode validation framework integration

✅ **Environment Linters (4 total):**
- `docBlameTheorems` - Enforces theorem documentation
- `tmNamingConventions` - Checks TM naming patterns
- `axiomDocumentation` - Ensures axiom documentation
- `noSorryInProofs` - Warns about sorry placeholders (disabled)

✅ **Text-Based Linters (3 total):**
- `trailingWhitespaceLinter` - Auto-fixes trailing whitespace
- `longLineLinter` - Detects lines >100 chars
- `nonBreakingSpaceLinter` - Auto-fixes non-breaking spaces

✅ **Integration:**
- State file generation (`.claude/tmp/lean-lint-state.json`)
- GitHub problem matchers for PR annotations
- Auto-fix capability for 2/3 text linters

### Current Gaps

❌ **Technical Debt:**
- 169 long lines (>100 chars) across 17 files
- Manual fixes required (no safe auto-fix)

❌ **Environment Linter Execution:**
- Infrastructure in place but not executing
- Batteries integration incomplete
- Linters defined but not running on compiled modules

❌ **Limited Linter Coverage:**
- No proof structure validation
- No import organization checks
- No theorem naming pattern enforcement
- No cross-file consistency checks

❌ **Performance:**
- No caching (re-lints all files every time)
- No parallelization (sequential execution)
- No incremental linting for staged files

✅ **Developer Experience:**
- CLI tools available (`lake lint`, `lake lint -- --fix`)
- Pre-commit hooks block bad commits
- CI/CD enforcement on PRs
- Clear error messages with file:line information
- Auto-fix capability for common issues

## Enhancement Phases

### Phase 1: Fix Long Lines (4 hours)

**Objective:** Eliminate all 169 long line violations through manual refactoring

#### 1.1 Analyze Long Line Patterns

**Task:** Categorize long lines by type to identify common patterns

**Approach:**
```bash
# Generate detailed report
lake exe lintStyle 2>&1 | grep "Line exceeds" > long-lines-report.txt

# Categorize by file
for file in $(lake exe lintStyle 2>&1 | grep "longLine" | cut -d: -f1 | sort -u); do
  echo "=== $file ==="
  grep "$file" long-lines-report.txt
done
```

**Expected Categories:**
1. Long type signatures (theorem declarations)
2. Long proof steps (tactic applications)
3. Long docstrings (documentation comments)
4. Long import lists
5. Long pattern matches

**Deliverable:** `long-lines-analysis.md` with categorized breakdown

#### 1.2 Create Refactoring Guidelines

**Task:** Document standard patterns for fixing each category

**Guidelines Document Structure:**

```markdown
# Long Line Refactoring Guidelines

## 1. Type Signatures

### Before (too long)
theorem very_long_name (φ ψ χ : Formula) (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) (h3 : Γ ⊢ χ) : Γ ⊢ φ ∧ ψ ∧ χ := by

### After (properly formatted)
theorem very_long_name
    (φ ψ χ : Formula)
    (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) (h3 : Γ ⊢ χ) :
    Γ ⊢ φ ∧ ψ ∧ χ := by

## 2. Proof Steps

### Before (too long)
apply Derivable.modus_ponens Γ (φ.imp ψ) ψ (Derivable.axiom (Axiom.prop_k φ ψ)) h

### After (use intermediate have)
have h_k : Γ ⊢ φ.imp ψ := Derivable.axiom (Axiom.prop_k φ ψ)
apply Derivable.modus_ponens Γ (φ.imp ψ) ψ h_k h

## 3. Docstrings

### Before (too long)
/-- This theorem proves that the modal operator distributes over implication in the context of S5 modal logic --/

### After (break into multiple lines)
/--
This theorem proves that the modal operator distributes over implication
in the context of S5 modal logic.
--/
```

**Deliverable:** `long-line-refactoring-guidelines.md`

#### 1.3 Systematic Refactoring

**Task:** Fix all 169 long lines following guidelines

**Approach:**
1. Process files in order of issue count (most issues first)
2. Fix one file at a time
3. Run `lake build` after each file to verify no breakage
4. Run `lake test` to ensure tests still pass
5. Commit after each file with descriptive message

**File Priority (based on current report):**
1. `Logos/Core/Theorems/Combinators.lean` (47 issues)
2. `Logos/Core/Semantics/Truth.lean` (32 issues)
3. `Logos/Core/Theorems/Propositional.lean` (20 issues)
4. `Logos/Core/Theorems/ModalS5.lean` (18 issues)
5. `Logos/Core/Theorems/ModalS4.lean` (15 issues)
6. ... (remaining 12 files)

**Verification Script:**
```bash
#!/usr/bin/env bash
# fix-long-lines.sh - Systematic long line fixing

FILES=(
  "Logos/Core/Theorems/Combinators.lean"
  "Logos/Core/Semantics/Truth.lean"
  "Logos/Core/Theorems/Propositional.lean"
  # ... add all files
)

for file in "${FILES[@]}"; do
  echo "=== Fixing $file ==="
  
  # Manual fix (open in editor)
  echo "Press Enter when done editing..."
  read
  
  # Verify build
  if ! lake build "$file"; then
    echo "ERROR: Build failed for $file"
    exit 1
  fi
  
  # Verify tests
  if ! lake test; then
    echo "ERROR: Tests failed after fixing $file"
    exit 1
  fi
  
  # Commit
  git add "$file"
  git commit -m "style: fix long lines in $file

- Break long type signatures across multiple lines
- Use intermediate have statements for long proofs
- Format docstrings with proper line breaks

Addresses: 073_lake_lint_enhancements Phase 1.3"
  
  echo "✓ $file fixed and committed"
done

echo "✓ All long lines fixed!"
```

**Deliverable:** All 169 long lines fixed, 17 commits

#### 1.4 Verification

**Task:** Verify all long lines are fixed

**Verification Commands:**
```bash
# Should show 0 issues
lake lint

# Should show 0 long line issues
lake exe lintStyle | grep "longLine"

# Verify build still works
lake build

# Verify tests still pass
lake test

# Verify no regressions
bash .claude/scripts/validate-all-standards.sh --lean-linting
```

**Success Criteria:**
- ✅ `lake lint` passes with 0 issues
- ✅ `lake build` succeeds
- ✅ `lake test` passes
- ✅ All commits have descriptive messages
- ✅ No functionality broken

**Deliverable:** Clean lint report, passing tests

### Phase 2: Full Batteries Integration (3 hours)

**Objective:** Implement actual environment linter execution using Batteries infrastructure

#### 2.1 Research Batteries Linting API

**Task:** Understand Batteries linting infrastructure and API

**Research Areas:**
1. `Batteries.Tactic.Lint.Frontend` module
2. `lintModules` function signature and usage
3. Environment loading and module discovery
4. Linter execution and result aggregation
5. Error formatting and reporting

**Key Questions:**
- How to load compiled modules into environment?
- How to discover all `@[env_linter]` annotated linters?
- How to run linters on specific declarations?
- How to format results for user consumption?
- How to handle linter failures gracefully?

**Research Method:**
```bash
# Examine Batteries source
cd .lake/packages/batteries
rg "lintModules" --type lean
rg "env_linter" --type lean
rg "Linter" Batteries/Tactic/Lint/Frontend.lean

# Check Mathlib usage
cd .lake/packages/mathlib
rg "runLinter" --type lean
rg "lint_modules" --type lean
```

**Deliverable:** `batteries-linting-api-research.md` with API documentation

#### 2.2 Implement Module Loading

**Task:** Load compiled Logos modules into environment

**Implementation in `scripts/RunEnvLinters.lean`:**

```lean
import Batteries.Tactic.Lint.Frontend
import Logos.Lint.EnvLinters
import Lean

open Lean Batteries.Tactic.Lint

/-- Load a module by name into the environment -/
def loadModule (moduleName : Name) : IO Environment := do
  -- Initialize environment with module
  let env ← importModules
    #[{module := moduleName}]
    {}
    0
  return env

/-- Get all modules in Logos package -/
def getLogosModules : IO (Array Name) := do
  -- Discover all .olean files in .lake/build/lib/Logos/
  let logosDir := ".lake/build/lib/Logos"
  let mut modules : Array Name := #[]
  
  -- Recursively find all .olean files
  let files ← findOleanFiles logosDir
  
  for file in files do
    -- Convert file path to module name
    -- e.g., ".lake/build/lib/Logos/Core/Syntax/Formula.olean" 
    --    -> `Logos.Core.Syntax.Formula`
    let moduleName := filePathToModuleName file
    modules := modules.push moduleName
  
  return modules

/-- Recursively find all .olean files in directory -/
partial def findOleanFiles (dir : String) : IO (Array String) := do
  let mut files : Array String := #[]
  
  if !(← FilePath.pathExists dir) then
    return files
  
  let entries ← FilePath.readDir dir
  
  for entry in entries do
    let path := dir ++ "/" ++ entry.fileName
    
    if ← FilePath.isDir path then
      files := files ++ (← findOleanFiles path)
    else if entry.fileName.endsWith ".olean" then
      files := files.push path
  
  return files

/-- Convert file path to module name -/
def filePathToModuleName (path : String) : Name :=
  -- Remove ".lake/build/lib/" prefix and ".olean" suffix
  let withoutPrefix := path.replace ".lake/build/lib/" ""
  let withoutSuffix := withoutPrefix.replace ".olean" ""
  -- Convert "/" to "."
  let modulePath := withoutSuffix.replace "/" "."
  -- Convert to Name
  modulePath.toName
  where
    String.toName (s : String) : Name :=
      s.splitOn "." |>.foldl (fun acc part => Name.str acc part) Name.anonymous
```

**Deliverable:** Module loading infrastructure

#### 2.3 Implement Linter Discovery

**Task:** Discover all `@[env_linter]` annotated linters

**Implementation:**

```lean
/-- Get all environment linters from the environment -/
def getEnvLinters (env : Environment) : Array Linter := do
  -- Get all declarations with @[env_linter] attribute
  let linterDecls := env.getAttributeNames.filter (·.toString.contains "env_linter")
  
  -- Extract linter definitions
  let mut linters : Array Linter := #[]
  
  for declName in linterDecls do
    -- Get the linter value
    match env.find? declName with
    | some info =>
      -- Extract Linter value from ConstantInfo
      -- This requires unsafe casting or reflection
      linters := linters.push (extractLinter info)
    | none => continue
  
  return linters

/-- Extract Linter from ConstantInfo -/
unsafe def extractLinter (info : ConstantInfo) : Linter :=
  -- Use unsafe evaluation to get the Linter value
  -- This is necessary because we're working with compiled code
  unsafeEvalConstCheck Linter info.name
```

**Note:** This requires unsafe operations. Alternative approach is to manually register linters:

```lean
/-- Manually registered environment linters -/
def registeredEnvLinters : Array Linter := #[
  docBlameTheorems,
  tmNamingConventions,
  axiomDocumentation,
  noSorryInProofs
]
```

**Deliverable:** Linter discovery mechanism

#### 2.4 Implement Linter Execution

**Task:** Run linters on all declarations in loaded modules

**Implementation:**

```lean
/-- Run all linters on a module -/
def lintModule (env : Environment) (moduleName : Name) (linters : Array Linter) 
    (verbose : Bool) : IO UInt32 := do
  if verbose then
    IO.println s!"[RunEnvLinters] Linting module: {moduleName}"
  
  -- Get all declarations in module
  let decls := getModuleDeclarations env moduleName
  
  let mut totalErrors := 0
  
  -- Run each linter on each declaration
  for linter in linters do
    if verbose then
      IO.println s!"[RunEnvLinters]   Running linter: {linter.name}"
    
    let mut linterErrors := 0
    
    for declName in decls do
      -- Run linter test
      match ← runLinterTest env linter declName with
      | some errorMsg =>
        IO.println s!"{declName}: {errorMsg}"
        linterErrors := linterErrors + 1
      | none => continue
    
    if linterErrors > 0 then
      IO.println s!"  {linter.errorsFound} ({linterErrors} issues)"
      totalErrors := totalErrors + linterErrors
    else if verbose then
      IO.println s!"  {linter.noErrorsFound}"
  
  return if totalErrors > 0 then 1 else 0

/-- Get all declarations in a module -/
def getModuleDeclarations (env : Environment) (moduleName : Name) : Array Name := do
  -- Filter environment declarations by module
  env.constants.fold (init := #[]) fun acc name info =>
    if info.module? == some moduleName then
      acc.push name
    else
      acc

/-- Run a linter test on a declaration -/
def runLinterTest (env : Environment) (linter : Linter) (declName : Name) 
    : IO (Option String) := do
  -- Create MetaM context
  let metaCtx : MetaM (Option MessageData) := linter.test declName
  
  -- Run in MetaM context
  let (result, _) ← metaCtx.run {} { env := env }
  
  return result.map (·.toString)
```

**Deliverable:** Linter execution engine

#### 2.5 Update Main Entry Point

**Task:** Wire up new implementation in `main` function

**Implementation:**

```lean
def main (args : List String) : IO UInt32 := do
  let linterArgs := parseArgs args
  
  if linterArgs.verbose then
    IO.println "[RunEnvLinters] Logos Environment Linter v2.0.0"
    IO.println s!"[RunEnvLinters] Modules: {linterArgs.modules}"
  
  -- Load modules
  let modules ← if linterArgs.modules.isEmpty then
    getLogosModules
  else
    return linterArgs.modules.toArray.map (·.toName)
  
  if linterArgs.verbose then
    IO.println s!"[RunEnvLinters] Found {modules.size} modules"
  
  -- Get linters
  let linters := registeredEnvLinters
  
  if linterArgs.verbose then
    IO.println s!"[RunEnvLinters] Registered {linters.size} linters"
  
  -- Load environment (use first module to initialize)
  let env ← loadModule modules[0]!
  
  -- Run linters on all modules
  let mut exitCode : UInt32 := 0
  
  for moduleName in modules do
    let result ← lintModule env moduleName linters linterArgs.verbose
    if result ≠ 0 then
      exitCode := 1
  
  -- Summary
  if exitCode = 0 then
    IO.println "✓ All environment linters passed"
  else
    IO.eprintln "✗ Environment linting failed - see errors above"
  
  return exitCode
```

**Deliverable:** Fully functional environment linter execution

#### 2.6 Testing

**Task:** Verify environment linters execute correctly

**Test Cases:**

1. **Test docBlameTheorems:**
   ```bash
   # Create test file with undocumented theorem
   cat > Logos/Test/LintTest.lean <<EOF
   theorem test_undocumented : True := trivial
   EOF
   
   # Should detect missing docstring
   lake exe runEnvLinters Logos.Test.LintTest
   ```

2. **Test tmNamingConventions:**
   ```bash
   # Create test file with bad naming
   cat > Logos/Test/LintTest.lean <<EOF
   /-- Test theorem --/
   theorem box_dist : True := trivial  -- Should warn: missing 'modal'
   EOF
   
   lake exe runEnvLinters Logos.Test.LintTest
   ```

3. **Test axiomDocumentation:**
   ```bash
   # Create test file with poorly documented axiom
   cat > Logos/Test/LintTest.lean <<EOF
   /-- Test --/  -- Too short
   axiom test_axiom : True
   EOF
   
   lake exe runEnvLinters Logos.Test.LintTest
   ```

**Verification:**
```bash
# Run on full Logos codebase
lake exe runEnvLinters

# Should integrate with lake lint
lake lint

# Verify exit codes
echo $?  # Should be 1 if issues found
```

**Success Criteria:**
- ✅ Environment linters execute on compiled modules
- ✅ Linters detect violations correctly
- ✅ Error messages are clear and actionable
- ✅ Integration with `lake lint` works
- ✅ Performance is acceptable (<30 seconds)

**Deliverable:** Fully functional environment linting

### Phase 3: Advanced TM Linters (3 hours)

**Objective:** Implement additional TM-specific linters for proof quality

#### 3.1 Proof Structure Linter

**Task:** Validate proof structure and organization

**Linter Implementation:**

```lean
/--
Check proof structure for common anti-patterns.
Detects overly long proofs, missing intermediate lemmas, and poor organization.
-/
@[env_linter]
def proofStructure : Batteries.Tactic.Lint.Linter where
  noErrorsFound := "All proofs well-structured."
  errorsFound := "PROOF STRUCTURE ISSUES:"
  test declName := do
    let info ← getConstInfo declName
    
    -- Only check theorems
    if !info.isTheorem then
      return none
    
    -- Get proof term
    let proof := info.value!
    
    -- Check 1: Proof too long (>50 tactics)
    let tacticCount := countTactics proof
    if tacticCount > 50 then
      return some m!"Proof too long ({tacticCount} tactics). Consider extracting lemmas."
    
    -- Check 2: Deep nesting (>5 levels)
    let nestingDepth := maxNestingDepth proof
    if nestingDepth > 5 then
      return some m!"Proof too deeply nested ({nestingDepth} levels). Flatten structure."
    
    -- Check 3: Repeated patterns (same tactic sequence >3 times)
    if hasRepeatedPatterns proof then
      return some m!"Proof has repeated patterns. Extract common lemma."
    
    return none

/-- Count tactics in proof term -/
def countTactics (expr : Expr) : Nat :=
  -- Traverse expression tree and count tactic applications
  expr.fold 0 fun count e =>
    if isTacticApplication e then count + 1 else count

/-- Calculate maximum nesting depth -/
def maxNestingDepth (expr : Expr) : Nat :=
  expr.fold 0 fun maxDepth e =>
    let depth := nestingDepth e
    max maxDepth depth

/-- Check for repeated tactic patterns -/
def hasRepeatedPatterns (expr : Expr) : Bool :=
  -- Extract tactic sequences
  let sequences := extractTacticSequences expr
  -- Count occurrences
  let counts := sequences.foldl (fun acc seq =>
    acc.insert seq (acc.findD seq 0 + 1)
  ) {}
  -- Check if any sequence appears >3 times
  counts.any (fun _ count => count > 3)
```

**Test Cases:**
```lean
-- Should pass
theorem good_proof : A → B := by
  intro h
  exact h

-- Should warn: too long
theorem bad_proof_long : A → B := by
  -- 51+ tactics
  sorry

-- Should warn: too nested
theorem bad_proof_nested : A → B := by
  by_cases h : A
  · by_cases h2 : B
    · by_cases h3 : C
      · by_cases h4 : D
        · by_cases h5 : E
          · by_cases h6 : F  -- 6 levels deep
            sorry
```

**Deliverable:** Proof structure linter

#### 3.2 Import Organization Linter

**Task:** Enforce import organization standards

**Linter Implementation:**

```lean
/--
Check import organization follows project standards.
Enforces: Mathlib imports first, then Batteries, then project imports.
-/
@[env_linter]
def importOrganization : Batteries.Tactic.Lint.Linter where
  noErrorsFound := "All imports properly organized."
  errorsFound := "IMPORT ORGANIZATION ISSUES:"
  test declName := do
    -- Get module containing declaration
    let info ← getConstInfo declName
    let moduleName := info.module?.getD Name.anonymous
    
    -- Get module source file
    let sourceFile := moduleNameToFilePath moduleName
    
    -- Read imports from source
    let imports ← parseImports sourceFile
    
    -- Check import order
    let issues := checkImportOrder imports
    
    if issues.isEmpty then
      return none
    else
      return some m!"Import order violations:\n{issues}"

/-- Expected import order -/
inductive ImportCategory
  | Mathlib
  | Batteries
  | Project
  | Other

/-- Categorize import -/
def categorizeImport (imp : Name) : ImportCategory :=
  let s := imp.toString
  if s.startsWith "Mathlib" then ImportCategory.Mathlib
  else if s.startsWith "Batteries" then ImportCategory.Batteries
  else if s.startsWith "Logos" then ImportCategory.Project
  else ImportCategory.Other

/-- Check import order -/
def checkImportOrder (imports : Array Name) : String :=
  let categories := imports.map categorizeImport
  
  -- Expected order: Mathlib, Batteries, Project, Other
  let mut lastCategory := ImportCategory.Mathlib
  let mut issues : Array String := #[]
  
  for i in [0:categories.size] do
    let cat := categories[i]!
    if categoryOrder cat < categoryOrder lastCategory then
      issues := issues.push s!"Import {imports[i]!} out of order"
    lastCategory := cat
  
  String.intercalate "\n" issues.toList

/-- Get category order value -/
def categoryOrder : ImportCategory → Nat
  | ImportCategory.Mathlib => 0
  | ImportCategory.Batteries => 1
  | ImportCategory.Project => 2
  | ImportCategory.Other => 3
```

**Test Cases:**
```lean
-- Good import order
import Mathlib.Data.List.Basic
import Batteries.Tactic.Lint
import Logos.Core.Syntax.Formula

-- Bad import order (should warn)
import Logos.Core.Syntax.Formula
import Mathlib.Data.List.Basic  -- Out of order
import Batteries.Tactic.Lint
```

**Deliverable:** Import organization linter

#### 3.3 Theorem Naming Pattern Linter

**Task:** Enforce theorem naming conventions

**Linter Implementation:**

```lean
/--
Check theorem naming follows project conventions.
Enforces: snake_case, descriptive names, proper prefixes.
-/
@[env_linter]
def theoremNaming : Batteries.Tactic.Lint.Linter where
  noErrorsFound := "All theorems properly named."
  errorsFound := "THEOREM NAMING ISSUES:"
  test declName := do
    let info ← getConstInfo declName
    
    -- Only check theorems
    if !info.isTheorem then
      return none
    
    let name := declName.toString
    
    -- Check 1: snake_case
    if !isSnakeCase name then
      return some m!"Theorem name not in snake_case: {name}"
    
    -- Check 2: Not too short (<3 chars)
    if name.length < 3 then
      return some m!"Theorem name too short: {name}"
    
    -- Check 3: Not generic (avoid "theorem", "lemma", "test")
    if isGenericName name then
      return some m!"Theorem name too generic: {name}"
    
    -- Check 4: Modal theorems should have "modal" prefix
    if containsModalOperators info.type && !name.hasSubstring "modal" then
      return some m!"Modal theorem should include 'modal' in name: {name}"
    
    -- Check 5: Temporal theorems should have "temporal" prefix
    if containsTemporalOperators info.type && !name.hasSubstring "temporal" then
      return some m!"Temporal theorem should include 'temporal' in name: {name}"
    
    return none

/-- Check if name is snake_case -/
def isSnakeCase (s : String) : Bool :=
  s.all (fun c => c.isAlphanum || c == '_') &&
  s == s.toLower

/-- Check if name is too generic -/
def isGenericName (s : String) : Bool :=
  let generic := ["theorem", "lemma", "test", "example", "temp", "foo", "bar"]
  generic.any (s.hasSubstring ·)

/-- Check if type contains modal operators -/
def containsModalOperators (type : Expr) : Bool :=
  type.find? (fun e =>
    match e with
    | Expr.const name _ => 
      name.toString.hasSubstring "box" || 
      name.toString.hasSubstring "diamond"
    | _ => false
  ).isSome

/-- Check if type contains temporal operators -/
def containsTemporalOperators (type : Expr) : Bool :=
  type.find? (fun e =>
    match e with
    | Expr.const name _ => 
      name.toString.hasSubstring "all_past" || 
      name.toString.hasSubstring "all_future" ||
      name.toString.hasSubstring "some_past" ||
      name.toString.hasSubstring "some_future"
    | _ => false
  ).isSome
```

**Test Cases:**
```lean
-- Good names
theorem modal_k_dist : ⊢ □(φ → ψ) → (□φ → □ψ)
theorem temporal_induction : ⊢ Gφ → φ

-- Bad names (should warn)
theorem Theorem : True  -- Not snake_case
theorem t : True  -- Too short
theorem test : True  -- Too generic
theorem box_dist : ⊢ □(φ → ψ) → (□φ → □ψ)  -- Missing 'modal'
```

**Deliverable:** Theorem naming linter

#### 3.4 Cross-File Consistency Linter

**Task:** Check consistency across multiple files

**Linter Implementation:**

```lean
/--
Check cross-file consistency.
Detects: duplicate definitions, inconsistent naming, missing dependencies.
-/
@[env_linter]
def crossFileConsistency : Batteries.Tactic.Lint.Linter where
  noErrorsFound := "All files consistent."
  errorsFound := "CROSS-FILE CONSISTENCY ISSUES:"
  test declName := do
    let info ← getConstInfo declName
    
    -- Check 1: Duplicate definitions
    if hasDuplicateDefinition declName then
      return some m!"Duplicate definition found in another module"
    
    -- Check 2: Inconsistent naming with similar definitions
    let similar := findSimilarDefinitions declName
    if !similar.isEmpty then
      return some m!"Similar definitions with inconsistent naming: {similar}"
    
    -- Check 3: Missing dependencies
    let deps := getRequiredDependencies info.type
    let missing := deps.filter (fun dep => !(← hasDefinition dep))
    if !missing.isEmpty then
      return some m!"Missing dependencies: {missing}"
    
    return none

/-- Check for duplicate definitions -/
def hasDuplicateDefinition (name : Name) : MetaM Bool := do
  let env ← getEnv
  let allDecls := env.constants.toList
  
  -- Find declarations with same name in different modules
  let duplicates := allDecls.filter fun (n, info) =>
    n.toString == name.toString && n != name
  
  return !duplicates.isEmpty

/-- Find similar definitions -/
def findSimilarDefinitions (name : Name) : MetaM (Array Name) := do
  let env ← getEnv
  let nameStr := name.toString
  
  -- Find declarations with similar names (Levenshtein distance < 3)
  let similar := env.constants.fold (init := #[]) fun acc n info =>
    if levenshteinDistance nameStr n.toString < 3 && n != name then
      acc.push n
    else
      acc
  
  return similar

/-- Calculate Levenshtein distance -/
def levenshteinDistance (s1 s2 : String) : Nat :=
  -- Standard Levenshtein distance algorithm
  sorry  -- Implementation omitted for brevity
```

**Test Cases:**
```lean
-- Should warn: duplicate
-- File 1:
theorem modal_k : ⊢ □(φ → ψ) → (□φ → □ψ)

-- File 2:
theorem modal_k : ⊢ □(φ → ψ) → (□φ → □ψ)  -- Duplicate!

-- Should warn: inconsistent naming
theorem modal_k_dist : ...
theorem modalKDist : ...  -- Inconsistent (camelCase vs snake_case)
```

**Deliverable:** Cross-file consistency linter

#### 3.5 Integration and Testing

**Task:** Integrate new linters and test thoroughly

**Integration Steps:**

1. Add linters to `Logos/Lint/EnvLinters.lean`
2. Register in `scripts/RunEnvLinters.lean`
3. Update documentation
4. Add test cases

**Test Suite:**
```bash
# Create test file with violations
cat > LogosTest/Lint/AdvancedLintTest.lean <<EOF
-- Test proof structure linter
theorem bad_proof_long : True := by
  -- 51+ tactics
  sorry

-- Test import organization linter
import Logos.Core.Syntax.Formula
import Mathlib.Data.List.Basic  -- Out of order

-- Test theorem naming linter
theorem Theorem : True  -- Bad name

-- Test cross-file consistency linter
theorem duplicate_def : True  -- Duplicate in another file
EOF

# Run linters
lake exe runEnvLinters LogosTest.Lint.AdvancedLintTest

# Verify violations detected
```

**Success Criteria:**
- ✅ All 4 new linters implemented
- ✅ Linters detect violations correctly
- ✅ No false positives
- ✅ Clear error messages
- ✅ Integration with `lake lint` works

**Deliverable:** 4 new advanced linters

### Phase 4: Performance Optimization (2 hours)

**Objective:** Optimize linting performance through caching and parallelization

#### 4.1 Implement Lint Result Caching

**Task:** Cache lint results to avoid re-linting unchanged files

**Cache Design:**

```lean
/-- Lint cache entry -/
structure LintCacheEntry where
  filePath : String
  fileHash : String  -- SHA256 of file contents
  timestamp : String  -- ISO 8601 timestamp
  lintResults : Array LintResult
  deriving ToJson, FromJson

/-- Lint result -/
structure LintResult where
  linterName : String
  declName : String
  errorMessage : Option String
  deriving ToJson, FromJson

/-- Lint cache -/
structure LintCache where
  entries : HashMap String LintCacheEntry
  deriving ToJson, FromJson

/-- Cache file location -/
def cacheFilePath : String := ".lake/lint-cache.json"
```

**Cache Implementation:**

```lean
/-- Load lint cache from disk -/
def loadLintCache : IO LintCache := do
  if ← FilePath.pathExists cacheFilePath then
    let contents ← IO.FS.readFile cacheFilePath
    match Json.parse contents >>= fromJson? with
    | Except.ok cache => return cache
    | Except.error _ => return { entries := {} }
  else
    return { entries := {} }

/-- Save lint cache to disk -/
def saveLintCache (cache : LintCache) : IO Unit := do
  let json := toJson cache
  IO.FS.writeFile cacheFilePath (toString json)

/-- Calculate file hash -/
def calculateFileHash (filePath : String) : IO String := do
  let contents ← IO.FS.readFile filePath
  -- Use SHA256 (requires crypto library or external command)
  let output ← IO.Process.output {
    cmd := "sha256sum"
    args := #[filePath]
  }
  return output.stdout.splitOn " " |>.head!

/-- Check if file needs linting -/
def needsLinting (cache : LintCache) (filePath : String) : IO Bool := do
  let currentHash ← calculateFileHash filePath
  
  match cache.entries.find? filePath with
  | none => return true  -- Not in cache
  | some entry =>
    if entry.fileHash == currentHash then
      return false  -- Hash matches, use cached results
    else
      return true  -- Hash changed, re-lint

/-- Get cached results -/
def getCachedResults (cache : LintCache) (filePath : String) 
    : Option (Array LintResult) :=
  cache.entries.find? filePath |>.map (·.lintResults)

/-- Update cache with new results -/
def updateCache (cache : LintCache) (filePath : String) 
    (results : Array LintResult) : IO LintCache := do
  let fileHash ← calculateFileHash filePath
  let timestamp := ← getCurrentTimestamp
  
  let entry : LintCacheEntry := {
    filePath := filePath
    fileHash := fileHash
    timestamp := timestamp
    lintResults := results
  }
  
  return { entries := cache.entries.insert filePath entry }
```

**Integration with LintStyle:**

```lean
def main (args : List String) : IO UInt32 := do
  let linterArgs := parseArgs args
  
  -- Load cache
  let mut cache ← loadLintCache
  
  -- Determine files to lint
  let filesToLint ← getFilesToLint linterArgs
  
  let mut totalErrors := 0
  let mut filesLinted := 0
  let mut filesCached := 0
  
  for file in filesToLint do
    -- Check if needs linting
    if ← needsLinting cache file then
      -- Lint file
      let results ← lintFile file linterArgs
      totalErrors := totalErrors + results.size
      filesLinted := filesLinted + 1
      
      -- Update cache
      cache ← updateCache cache file results
    else
      -- Use cached results
      match getCachedResults cache file with
      | some results =>
        -- Report cached results
        if !results.isEmpty then
          reportResults file results
          totalErrors := totalErrors + results.size
        filesCached := filesCached + 1
      | none => continue
  
  -- Save cache
  saveLintCache cache
  
  -- Summary
  if linterArgs.verbose then
    IO.println s!"[LintStyle] Linted: {filesLinted} files"
    IO.println s!"[LintStyle] Cached: {filesCached} files"
  
  return if totalErrors > 0 then 1 else 0
```

**Deliverable:** Lint result caching

#### 4.2 Implement Parallel Linting

**Task:** Lint multiple files in parallel

**Parallel Execution:**

```lean
/-- Lint files in parallel -/
def lintFilesParallel (files : Array String) (linterArgs : StyleLinterArgs) 
    : IO (Array (String × Array LintResult)) := do
  -- Create task for each file
  let tasks := files.map fun file => Task.spawn fun () => do
    lintFile file linterArgs
  
  -- Wait for all tasks to complete
  let results ← tasks.mapM Task.get
  
  -- Combine results
  return files.zip results

/-- Lint file (returns results) -/
def lintFile (file : String) (linterArgs : StyleLinterArgs) 
    : IO (Array LintResult) := do
  if !(← FilePath.pathExists file) then
    return #[]
  
  let content ← IO.FS.readFile file
  let mut results : Array LintResult := #[]
  
  for linter in allStyleLinters do
    let errors := linter.check content
    
    for (line, msg) in errors do
      results := results.push {
        linterName := linter.name
        declName := s!"{file}:{line}"
        errorMessage := some msg
      }
  
  return results
```

**Thread Pool Configuration:**

```lean
/-- Configure thread pool size -/
def getThreadPoolSize : IO Nat := do
  -- Use number of CPU cores
  let output ← IO.Process.output {
    cmd := "nproc"
    args := #[]
  }
  return output.stdout.trim.toNat?.getD 4

/-- Lint with thread pool -/
def lintWithThreadPool (files : Array String) (linterArgs : StyleLinterArgs) 
    : IO (Array (String × Array LintResult)) := do
  let poolSize ← getThreadPoolSize
  
  -- Split files into batches
  let batches := files.toList.chunks (files.size / poolSize)
  
  -- Process batches in parallel
  let batchTasks := batches.map fun batch => Task.spawn fun () => do
    batch.mapM fun file => do
      let results ← lintFile file linterArgs
      return (file, results)
  
  -- Wait for all batches
  let batchResults ← batchTasks.mapM Task.get
  
  -- Flatten results
  return batchResults.flatten.toArray
```

**Deliverable:** Parallel linting execution

#### 4.3 Implement Incremental Linting

**Task:** Lint only staged files for pre-commit hooks

**Staged File Detection:**

```bash
#!/usr/bin/env bash
# get-staged-lean-files.sh - Get staged .lean files

git diff --cached --name-only --diff-filter=ACMR | grep '\.lean$'
```

**Integration:**

```lean
/-- Get staged files -/
def getStagedFiles : IO (Array String) := do
  let output ← IO.Process.output {
    cmd := "git"
    args := #["diff", "--cached", "--name-only", "--diff-filter=ACMR"]
  }
  
  let files := output.stdout.splitOn "\n"
    |>.filter (·.endsWith ".lean")
    |>.toArray
  
  return files

/-- Main with incremental support -/
def main (args : List String) : IO UInt32 := do
  let linterArgs := parseArgs args
  
  -- Determine files to lint
  let filesToLint ← if linterArgs.stagedOnly then
    getStagedFiles
  else
    getFilesToLint linterArgs
  
  if linterArgs.verbose then
    IO.println s!"[LintStyle] Linting {filesToLint.size} files"
  
  -- Lint files (with caching and parallelization)
  let results ← lintFilesParallel filesToLint linterArgs
  
  -- Report results
  reportResults results
  
  return if hasErrors results then 1 else 0
```

**Deliverable:** Incremental linting for staged files

#### 4.4 Performance Benchmarking

**Task:** Measure performance improvements

**Benchmark Script:**

```bash
#!/usr/bin/env bash
# benchmark-linting.sh - Benchmark linting performance

echo "=== Linting Performance Benchmark ==="

# Baseline (no optimizations)
echo "Baseline (no cache, no parallel):"
time lake exe lintStyle

# With caching
echo "With caching:"
time lake exe lintStyle  # Second run uses cache

# With parallelization
echo "With parallelization:"
time lake exe lintStyle -- --parallel

# With both
echo "With caching + parallelization:"
time lake exe lintStyle -- --parallel  # Second run

# Incremental (staged files only)
echo "Incremental (staged files):"
git add Logos/Core/Syntax/Formula.lean
time lake exe lintStyle -- --staged
```

**Performance Targets:**
- Full repository lint: <10 seconds (down from ~30 seconds)
- Cached lint: <2 seconds
- Incremental lint (5 files): <1 second
- Parallel speedup: ~3-4x on 4-core machine

**Deliverable:** Performance benchmarks and optimizations

## Implementation Timeline

### Week 1: Core Enhancements
- **Day 1-2:** Phase 1 (Fix Long Lines) - 4 hours
- **Day 3:** Phase 2 (Batteries Integration) - 3 hours
- **Day 4:** Phase 3 (Advanced Linters) - 3 hours

### Week 2: Optimization and Testing
- **Day 1:** Phase 4 (Performance) - 2 hours
- **Day 2:** Testing and documentation - 2 hours

**Total Estimated Time:** 12 hours (1.5 weeks part-time)

## Success Criteria

### Phase 1: Fix Long Lines
- ✅ All 169 long lines fixed
- ✅ Zero long line violations
- ✅ All tests passing
- ✅ Build succeeds

### Phase 2: Batteries Integration
- ✅ Environment linters execute on compiled modules
- ✅ Linters detect violations correctly
- ✅ Integration with `lake lint` works
- ✅ Performance <30 seconds

### Phase 3: Advanced Linters
- ✅ 4 new linters implemented
- ✅ No false positives
- ✅ Clear error messages
- ✅ Test coverage >80%

### Phase 4: Performance
- ✅ Full lint <10 seconds (down from ~30)
- ✅ Cached lint <2 seconds
- ✅ Incremental lint <1 second
- ✅ Parallel speedup 3-4x

## Risk Assessment

### High Risk
- **Batteries API complexity** - May require significant research
  - Mitigation: Start with manual linter registration
  - Fallback: Defer full integration to future

### Medium Risk
- **Performance optimization complexity** - Caching may be tricky
  - Mitigation: Start with simple file hash caching
  - Fallback: Focus on parallelization first

### Low Risk
- **Long line fixes** - Manual but straightforward
  - Mitigation: Follow guidelines systematically
  - Fallback: Fix highest-priority files first

## Dependencies

### Required
- ✅ Lake Lint Integration (Phases 1-6) - Complete
- ✅ LEAN 4.14.0 with Batteries
- ✅ Git for staged file detection

## Deliverables

### Code
- [ ] 169 long lines fixed (17 files)
- [ ] `scripts/RunEnvLinters.lean` enhanced (full Batteries integration)
- [ ] 4 new environment linters in `Logos/Lint/EnvLinters.lean`
- [ ] Caching implementation in `scripts/LintStyle.lean`
- [ ] Parallel execution in `scripts/LintStyle.lean`

### Documentation
- [ ] `long-lines-analysis.md` - Categorized breakdown
- [ ] `long-line-refactoring-guidelines.md` - Refactoring patterns
- [ ] `batteries-linting-api-research.md` - API documentation
- [ ] Updated LEAN_STYLE_GUIDE.md with new linters
- [ ] Performance benchmark results

### Tests
- [ ] Test suite for new environment linters
- [ ] Performance benchmarks
- [ ] Integration tests

## Future Enhancements (Beyond This Spec)

### Advanced Features
- Semantic analysis (type-level checks)
- Proof complexity metrics
- Automated refactoring suggestions
- Machine learning-based pattern detection

### Integration
- GitHub App for PR reviews
- Pre-commit hook automation
- Continuous quality monitoring
- Dashboard for quality metrics

### Developer Experience
- Editor integration (via standard mechanisms like `:make`, tasks.json, etc.)
- Language server protocol support for linting
- Real-time feedback plugins (optional, user-configured)

## Conclusion

This implementation plan provides a comprehensive roadmap for enhancing the Lake Lint Integration system. The phased approach ensures incremental delivery of value while managing risk. Each phase builds on the previous one, creating a robust, performant, and developer-friendly linting system.

The estimated 12 hours of work will transform the Logos linting system from production-ready to world-class, with advanced features that rival or exceed professional LEAN 4 projects.

**Note on Editor Integration:** This plan focuses on the core linting infrastructure. Editor integration (VS Code, Neovim, etc.) is left to individual users to configure using standard mechanisms. The CLI tools (`lake lint`, `lake lint -- --fix`) provide a solid foundation that works with any editor's build/task system.

---

**Status:** Planning  
**Next Step:** Review and approve plan  
**Estimated Start:** After approval  
**Estimated Completion:** 2 weeks from start

---

*For current implementation status, see `.opencode/specs/lake-lint-integration-complete-summary.md`*
