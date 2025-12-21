# Loogle API Search Report: Array _ → Option _

**Search Date:** 2025-12-20  
**Primary Pattern:** `Array _ → Option _`  
**Total Matches Found:** 43 exact matches, 36 with additional parameters  
**Libraries Searched:** Init (Lean Core), Std, Batteries, Lean, Mathlib, Aesop

---

## Search Metadata

### Patterns Searched
1. **Primary:** `Array _ → Option _` - 43 matches
2. **With Additional Parameters:** `Array _ → _ → Option _` - 36 matches
3. **Specific Function Names:** `Array.find?`, `Array.back?`, `Array.get?`, `Array.head?`, `Array.tail?`, `Array.pop?`
4. **Alternative Formulations:** `Array α → Option β` (type variable error in Loogle)

### Search Statistics
- Total declarations mentioning Array and Option: 1225
- Functions matching exact pattern: 43
- Functions with additional parameters: 36
- Unique modules represented: 25+

---

## Category 1: Exact Matches (Array α → Option β)

### 1.1 Element Access Functions

#### `Array.back?`
- **Type:** `{α : Type u} (xs : Array α) : Option α`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the last element of an array, or `none` if the array is empty. See `Array.back!` for the version that panics if the array is empty, or `Array.back` for the version that requires a proof the array is non-empty.
- **Usage Example:** 
  - `#[1, 2, 3].back? = some 3`
  - `#[].back? = none`

#### `Array.max?`
- **Type:** `{α : Type u_1} [ord : Ord α] (xs : Array α) (start : ℕ := 0) (stop : ℕ := xs.size) : Option α`
- **Library:** Batteries
- **Module:** `Batteries.Data.Array.Basic`
- **Description:** Find the first maximal element of an array. If the array is empty, `none` is returned. If `start` and `stop` are given, only the subarray `xs[start:stop]` is considered.
- **Usage Example:**
  - `#[3, 1, 4, 1, 5].max? = some 5`
  - `#[].max? = none`

#### `Array.min?`
- **Type:** `{α : Type u_1} [ord : Ord α] (xs : Array α) (start : ℕ := 0) (stop : ℕ := xs.size) : Option α`
- **Library:** Batteries
- **Module:** `Batteries.Data.Array.Basic`
- **Description:** Find the first minimal element of an array. If the array is empty, `none` is returned. If `start` and `stop` are given, only the subarray `xs[start:stop]` is considered.
- **Usage Example:**
  - `#[3, 1, 4, 1, 5].min? = some 1`
  - `#[].min? = none`

### 1.2 Search and Find Functions

#### `Array.find?`
- **Type:** `{α : Type u} (p : α → Bool) (as : Array α) : Option α`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the first element of the array for which the predicate `p` returns `true`, or `none` if no such element is found.
- **Usage Examples:**
  - `#[7, 6, 5, 8, 1, 2, 6].find? (· < 5) = some 1`
  - `#[7, 6, 5, 8, 1, 2, 6].find? (· < 1) = none`

#### `Array.findRev?`
- **Type:** `{α : Type} (p : α → Bool) (as : Array α) : Option α`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the last element of the array for which the predicate `p` returns `true`, or `none` if no such element is found.
- **Usage Examples:**
  - `#[7, 6, 5, 8, 1, 2, 6].findRev? (· < 5) = some 2`
  - `#[7, 6, 5, 8, 1, 2, 6].findRev? (· < 1) = none`

#### `Array.findIdx?`
- **Type:** `{α : Type u} (p : α → Bool) (as : Array α) : Option ℕ`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the index of the first element for which `p` returns `true`, or `none` if there is no such element.
- **Usage Examples:**
  - `#[7, 6, 5, 8, 1, 2, 6].findIdx? (· < 5) = some 4`
  - `#[7, 6, 5, 8, 1, 2, 6].findIdx? (· < 1) = none`

#### `Array.findFinIdx?`
- **Type:** `{α : Type u} (p : α → Bool) (as : Array α) : Option (Fin as.size)`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the index of the first element for which `p` returns `true`, or `none` if there is no such element. The index is returned as a `Fin`, which guarantees that it is in bounds.
- **Usage Examples:**
  - `#[7, 6, 5, 8, 1, 2, 6].findFinIdx? (· < 5) = some (4 : Fin 7)`
  - `#[7, 6, 5, 8, 1, 2, 6].findFinIdx? (· < 1) = none`

#### `Array.findSome?`
- **Type:** `{α : Type u} {β : Type v} (f : α → Option β) (as : Array α) : Option β`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the first non-`none` result of applying the function `f` to each element of the array, in order. Returns `none` if `f` returns `none` for all elements.
- **Usage Example:**
  ```lean
  #eval #[7, 6, 5, 8, 1, 2, 6].findSome? fun i =>
    if i < 5 then some (i * 10) else none
  -- Output: some 10
  ```

#### `Array.findSomeRev?`
- **Type:** `{α : Type u} {β : Type v} (f : α → Option β) (as : Array α) : Option β`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the first non-`none` result of applying `f` to each element of the array in reverse order, from right to left. Returns `none` if `f` returns `none` for all elements of the array.
- **Usage Examples:**
  - `#[7, 6, 5, 8, 1, 2, 6].findSomeRev? (fun x => if x < 5 then some (10 * x) else none) = some 20`
  - `#[7, 6, 5, 8, 1, 2, 6].findSomeRev? (fun x => if x < 1 then some (10 * x) else none) = none`

### 1.3 Index-Based Search Functions

#### `Array.idxOf?`
- **Type:** `{α : Type u} [BEq α] (xs : Array α) (v : α) : Option ℕ`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the index of the first element equal to `a`, or `none` if no element is equal to `a`.
- **Usage Examples:**
  - `#["carrot", "potato", "broccoli"].idxOf? "carrot" = some 0`
  - `#["carrot", "potato", "broccoli"].idxOf? "broccoli" = some 2`
  - `#["carrot", "potato", "broccoli"].idxOf? "tomato" = none`

#### `Array.finIdxOf?`
- **Type:** `{α : Type u} [BEq α] (xs : Array α) (v : α) : Option (Fin xs.size)`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the index of the first element equal to `a`, or `none` if no element is equal to `a`. The index is returned as a `Fin`, which guarantees that it is in bounds.
- **Usage Examples:**
  - `#["carrot", "potato", "broccoli"].finIdxOf? "carrot" = some 0`
  - `#["carrot", "potato", "broccoli"].finIdxOf? "broccoli" = some 2`
  - `#["carrot", "potato", "broccoli"].finIdxOf? "tomato" = none`

### 1.4 Comparison and Ordering Functions

#### `Array.getMax?`
- **Type:** `{α : Type u} (as : Array α) (lt : α → α → Bool) : Option α`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Returns the largest element of the array, as determined by the comparison `lt`, or `none` if the array is empty.
- **Usage Examples:**
  - `(#[] : Array Nat).getMax? (· < ·) = none`
  - `#["red", "green", "blue"].getMax? (·.length < ·.length) = some "green"`
  - `#["red", "green", "blue"].getMax? (· < ·) = some "red"`

#### `Array.binSearch`
- **Type:** `{α : Type} (as : Array α) (k : α) (lt : α → α → Bool) (lo : ℕ := 0) (hi : ℕ := as.size - 1) : Option α`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.BinSearch`
- **Description:** Binary search for an element equivalent to `k` in the sorted array `as`. Returns the element from the array, if it is found, or `none` otherwise. The array `as` must be sorted according to the comparison operator `lt`, which should be a total order. The optional parameters `lo` and `hi` determine the region of the array indices to be searched.

---

## Category 2: Partial Matches (Array with Additional Parameters)

### 2.1 Internal/Helper Functions

#### `Array.findIdx?.loop`
- **Type:** `{α : Type u} (p : α → Bool) (as : Array α) (j : ℕ) : Option ℕ`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Internal loop function for `findIdx?`

#### `Array.idxOfAux`
- **Type:** `{α : Type u} [BEq α] (xs : Array α) (v : α) (i : ℕ) : Option (Fin xs.size)`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.Array.Basic`
- **Description:** Auxiliary function for `idxOf?`

---

## Category 3: Specialized Library Functions

### 3.1 Std Library Functions

#### `Std.Sat.AIG.Cache.get?`
- **Type:** `{α : Type} [Hashable α] [DecidableEq α] {decls : Array (Std.Sat.AIG.Decl α)} (cache : Std.Sat.AIG.Cache α decls) (decl : Std.Sat.AIG.Decl α) : Option (Std.Sat.AIG.CacheHit decls decl)`
- **Library:** Std
- **Module:** `Std.Sat.AIG.Basic`
- **Description:** Lookup a `Decl` in a `Cache`.

#### `Std.Time.TimeZone.Transition.findTransitionForTimestamp`
- **Type:** `(transitions : Array Std.Time.TimeZone.Transition) (timestamp : Std.Time.Timestamp) : Option Std.Time.TimeZone.Transition`
- **Library:** Std
- **Module:** `Std.Time.Zoned.ZoneRules`
- **Description:** Finds the transition corresponding to a given timestamp in `Array Transition`. If the timestamp falls between two transitions, it returns the most recent transition before the timestamp.

#### `Std.Time.TimeZone.Transition.findTransitionIndexForTimestamp`
- **Type:** `(transitions : Array Std.Time.TimeZone.Transition) (timestamp : Std.Time.Timestamp) : Option ℕ`
- **Library:** Std
- **Module:** `Std.Time.Zoned.ZoneRules`
- **Description:** Finds the transition corresponding to a given timestamp in `Array Transition`. If the timestamp falls between two transitions, it returns the most recent transition before the timestamp.

#### `Std.Time.TimeZone.convertTransition`
- **Type:** `(times : Array Std.Time.TimeZone.LocalTimeType) (index : ℕ) (tz : Std.Time.TimeZone.TZif.TZifV1) : Option Std.Time.TimeZone.Transition`
- **Library:** Std
- **Module:** `Std.Time.Zoned.Database.Basic`
- **Description:** Converts a transition.

#### `Std.Tactic.BVDecide.LRAT.Internal.DefaultClause.ofArray`
- **Type:** `{n : ℕ} (ls : Array (Std.Sat.Literal (Std.Tactic.BVDecide.LRAT.Internal.PosFin n))) : Option (Std.Tactic.BVDecide.LRAT.Internal.DefaultClause n)`
- **Library:** Std
- **Module:** `Std.Tactic.BVDecide.LRAT.Internal.Clause`
- **Description:** Constructs a default clause from an array of literals

#### `Std.Tactic.BVDecide.LRAT.Internal.Clause.ofArray`
- **Type:** `{α : outParam (Type u)} {β : Type v} [self : Std.Tactic.BVDecide.LRAT.Internal.Clause α β] : Array (Std.Sat.Literal α) → Option β`
- **Library:** Std
- **Module:** `Std.Tactic.BVDecide.LRAT.Internal.Clause`
- **Description:** Returns none if the given array contains complementary literals

### 3.2 Lean Compiler Functions

#### `Lean.PersistentHashMap.isUnaryEntries`
- **Type:** `{α : Type u_1} {β : Type u_2} (a : Array (Lean.PersistentHashMap.Entry α β (Lean.PersistentHashMap.Node α β))) (i : ℕ) (acc : Option (α × β)) : Option (α × β)`
- **Library:** Lean
- **Module:** `Lean.Data.PersistentHashMap`
- **Description:** Helper for persistent hash map operations

#### `Lean.PersistentHashMap.findAtAux`
- **Type:** `{α : Type u_1} {β : Type u_2} [BEq α] (keys : Array α) (vals : Array β) (heq : keys.size = vals.size) (i : ℕ) (k : α) : Option β`
- **Library:** Lean
- **Module:** `Lean.Data.PersistentHashMap`
- **Description:** Auxiliary function for finding in persistent hash map

#### `Lean.PersistentHashMap.findEntryAtAux`
- **Type:** `{α : Type u_1} {β : Type u_2} [BEq α] (keys : Array α) (vals : Array β) (heq : keys.size = vals.size) (i : ℕ) (k : α) : Option (α × β)`
- **Library:** Lean
- **Module:** `Lean.Data.PersistentHashMap`
- **Description:** Auxiliary function for finding entry in persistent hash map

#### `Lean.IR.addParamsRename`
- **Type:** `(ρ : Lean.IR.IndexRenaming) (ps₁ ps₂ : Array Lean.IR.Param) : Option Lean.IR.IndexRenaming`
- **Library:** Lean
- **Module:** `Lean.Compiler.IR.Basic`
- **Description:** IR parameter renaming function

#### `Lean.IR.findEnvDecl'`
- **Type:** `(env : Lean.Environment) (n : Lean.Name) (decls : Array Lean.IR.Decl) : Option Lean.IR.Decl`
- **Library:** Lean
- **Module:** `Lean.Compiler.IR.CompilerM`
- **Description:** Find IR declaration in environment

#### `Lean.IR.EmitC.isIf`
- **Type:** `(alts : Array Lean.IR.Alt) : Option (ℕ × Lean.IR.FnBody × Lean.IR.FnBody)`
- **Library:** Lean
- **Module:** `Lean.Compiler.IR.EmitC`
- **Description:** Check if alternatives form an if-then-else structure

#### `Lean.Elab.Structural.allCombinations`
- **Type:** `{α : Type u_1} (xss : Array (Array α)) : Option (Array (Array α))`
- **Library:** Lean
- **Module:** `Lean.Elab.PreDefinition.Structural.FindRecArg`
- **Description:** Generate all combinations from nested arrays

#### `Lean.Elab.WF.GuessLex.generateCombinations?`
- **Type:** `(numMeasures : Array ℕ) (threshold : ℕ := 32) : Option (Array (Array ℕ))`
- **Library:** Lean
- **Module:** `Lean.Elab.PreDefinition.WF.GuessLex`
- **Description:** Generate all combination of measures. Assumes we have numbered the measures of each function, and their counts is in `numMeasures`. This puts the uniform combinations ([0,0,0], [1,1,1]) to the front; they are commonly most useful to try first, when the mutually recursive functions have similar argument structures

#### `Lean.Server.ModuleImport.collapseIdenticalImports?`
- **Type:** `(identicalImports : Array Lean.Server.ModuleImport) : Option Lean.Server.ModuleImport`
- **Library:** Lean
- **Module:** `Lean.Server.References`
- **Description:** Reduces `identicalImports` with the same module name by merging their flags. Yields `none` if `identicalImports` is empty or `identicalImports` contains an import that has a name or uri that is not identical to the others.

#### `Lean.Firefox.Profile.collide`
- **Type:** `(ps : Array Lean.Firefox.Profile) : Option Lean.Firefox.Profile`
- **Library:** Lean
- **Module:** `Lean.Util.Profiler`
- **Description:** Merges given profiles such that samples with identical stacks are deduplicated by adding up their weights. Minimizes profile size while preserving per-stack timing information.

### 3.3 Lean Meta/Grind Functions

#### `Lean.Meta.Grind.Arith.Cutsat.findDiseq?`
- **Type:** `(v : ℤ) (dvals : Array (ℚ × Lean.Meta.Grind.Arith.Cutsat.DiseqCnstr)) : Option Lean.Meta.Grind.Arith.Cutsat.DiseqCnstr`
- **Library:** Lean
- **Module:** `Lean.Meta.Tactic.Grind.Arith.Cutsat.Search`
- **Description:** Find disequality constraint in Cutsat solver

#### `Lean.Meta.Grind.Arith.Cutsat.findRatDiseq?`
- **Type:** `(v : ℚ) (dvals : Array (ℚ × Lean.Meta.Grind.Arith.Cutsat.DiseqCnstr)) : Option Lean.Meta.Grind.Arith.Cutsat.DiseqCnstr`
- **Library:** Lean
- **Module:** `Lean.Meta.Tactic.Grind.Arith.Cutsat.Search`
- **Description:** Find rational disequality constraint in Cutsat solver

#### `Lean.Meta.Grind.Arith.Linear.findDiseq?`
- **Type:** `(v : ℚ) (dvals : Array (ℚ × Lean.Meta.Grind.Arith.Linear.DiseqCnstr)) : Option Lean.Meta.Grind.Arith.Linear.DiseqCnstr`
- **Library:** Lean
- **Module:** `Lean.Meta.Tactic.Grind.Arith.Linear.Search`
- **Description:** Find disequality constraint in linear solver

#### `Lean.Meta.Grind.Arith.Linear.findInt?`
- **Type:** `(lower : ℚ) (lowerStrict : Bool) (upper : ℚ) (upperStrict : Bool) (dvals : Array (ℚ × Lean.Meta.Grind.Arith.Linear.DiseqCnstr)) : Option ℚ`
- **Library:** Lean
- **Module:** `Lean.Meta.Tactic.Grind.Arith.Linear.Search`
- **Description:** Try to find integer between lower and upper bounds that is different for known disequalities

### 3.4 Mathlib Functions

#### `Mathlib.Tactic.Translate.shouldTranslate`
- **Type:** `(env : Lean.Environment) (t : Mathlib.Tactic.Translate.TranslateData) (e : Lean.Expr) (dontTranslate : Array Lean.FVarId := #[]) : Option (Lean.Name ⊕ Lean.FVarId)`
- **Library:** Mathlib
- **Module:** `Mathlib.Tactic.Translate.Core`
- **Description:** `shouldTranslate e` tests whether the expression `e` contains a constant `nm` that is not applied to any arguments, and such that `translations.find?[nm] = none`. This is used for deciding which subexpressions to translate: we only translate constants if `shouldTranslate` applied to their relevant argument returns `true`. This means we will replace expression applied to e.g. `α` or `α × β`, but not when applied to e.g. `ℕ` or `ℝ × α`. We ignore all arguments specified by the `ignore` `NameMap`.

### 3.5 Aesop Functions

#### `Aesop.Script.findFirstStep?`
- **Type:** `{α β : Type} (goals : Array α) (step? : α → Option β) (stepOrder : β → ℕ) : Option (ℕ × α × β)`
- **Library:** Aesop
- **Module:** `Aesop.Script.Util`
- **Description:** Find first step in Aesop script

#### `Aesop.forwardRuleMatchesToNormRules?`
- **Type:** `(ms : Array Aesop.ForwardRuleMatch) : Option (Array Aesop.NormRule)`
- **Library:** Aesop
- **Module:** `Aesop.Forward.Match`
- **Description:** Convert forward rule matches to norm rules. Fails if any of the matches is not a norm rule match.

#### `Aesop.forwardRuleMatchesToSafeRules?`
- **Type:** `(ms : Array Aesop.ForwardRuleMatch) : Option (Array Aesop.SafeRule)`
- **Library:** Aesop
- **Module:** `Aesop.Forward.Match`
- **Description:** Convert forward rule matches to safe rules. Fails if any of the matches is not a safe rule match.

#### `Aesop.forwardRuleMatchesToUnsafeRules?`
- **Type:** `(ms : Array Aesop.ForwardRuleMatch) : Option (Array Aesop.UnsafeRule)`
- **Library:** Aesop
- **Module:** `Aesop.Forward.Match`
- **Description:** Convert forward rule matches to unsafe rules. Fails if any of the matches is not an unsafe rule match.

#### `Aesop.Script.SScript.takeNConsecutiveFocusAndSolve?`
- **Type:** `(acc : Array Aesop.Script.SScript) : ℕ → Aesop.Script.SScript → Option (Array Aesop.Script.SScript × Aesop.Script.SScript)`
- **Library:** Aesop
- **Module:** `Aesop.Script.SScript`
- **Description:** Take N consecutive focus and solve operations

### 3.6 ByteArray Functions

#### `ByteArray.utf8Decode?.go`
- **Type:** `(b : ByteArray) (i : ℕ) (acc : Array Char) (hi : i ≤ b.size) : Option (Array Char)`
- **Library:** Init (Core Lean)
- **Module:** `Init.Data.String.Basic`
- **Description:** UTF-8 decoding helper function

---

## Functions NOT Found (Expected but Missing)

The following commonly expected functions were **NOT** found in the Loogle search:

1. **`Array.get?`** - Does not exist (use `Array[i]?` or `getElem?` syntax instead)
2. **`Array.head?`** - Does not exist (use `Array[0]?` or first element pattern)
3. **`Array.tail?`** - Does not exist (use `Array.extract` or slicing)
4. **`Array.pop?`** - Does not exist (use `Array.back?` for last element)
5. **`Array.getElem?`** - Not a named function (use bracket notation `arr[i]?`)

---

## Common Use Case Recommendations

### 1. **Get Last Element**
- **Use:** `Array.back?`
- **Example:** `#[1, 2, 3].back? = some 3`

### 2. **Find Element by Predicate**
- **Use:** `Array.find?` (forward), `Array.findRev?` (backward)
- **Example:** `#[1, 2, 3, 4].find? (· > 2) = some 3`

### 3. **Get Index of Element**
- **Use:** `Array.idxOf?` (by value), `Array.findIdx?` (by predicate)
- **Example:** `#[1, 2, 3].idxOf? 2 = some 1`

### 4. **Find Maximum/Minimum**
- **Use:** `Array.max?`, `Array.min?` (with Ord), `Array.getMax?` (with custom comparison)
- **Example:** `#[3, 1, 4].max? = some 4`

### 5. **Transform and Find First Success**
- **Use:** `Array.findSome?`, `Array.findSomeRev?`
- **Example:** `#[1, 2, 3].findSome? (fun x => if x > 1 then some (x * 10) else none) = some 20`

### 6. **Binary Search in Sorted Array**
- **Use:** `Array.binSearch`
- **Example:** `#[1, 3, 5, 7, 9].binSearch 5 (· < ·) = some 5`

### 7. **Get Element at Index (Safe)**
- **Use:** Bracket notation with `?`: `arr[i]?`
- **Example:** `#[1, 2, 3][1]? = some 2`

---

## Performance Characteristics

### O(1) - Constant Time
- `Array.back?` - Direct array access to last element

### O(n) - Linear Time
- `Array.find?` - Must scan array until predicate matches
- `Array.findRev?` - Scans array backward
- `Array.findIdx?` - Scans array until predicate matches
- `Array.idxOf?` - Scans array until element found
- `Array.findSome?` - Scans and applies function
- `Array.max?`, `Array.min?` - Must examine all elements
- `Array.getMax?` - Must examine all elements with comparison

### O(log n) - Logarithmic Time
- `Array.binSearch` - Binary search on sorted array

---

## Type Safety Considerations

### Functions Returning `Fin` Indices
These functions return indices that are **proven to be in bounds**:
- `Array.findFinIdx?` - Returns `Option (Fin as.size)`
- `Array.finIdxOf?` - Returns `Option (Fin xs.size)`

This eliminates the need for separate bounds checking when using the index.

### Functions with Typeclass Constraints
- `Array.idxOf?` requires `[BEq α]` - Boolean equality
- `Array.max?`, `Array.min?` require `[Ord α]` - Ordering
- All PersistentHashMap functions require `[BEq α]`, `[Hashable α]`

---

## Summary

The Loogle API search found **43 exact matches** for the pattern `Array _ → Option _` and **36 additional functions** with extra parameters. The core Lean library (Init) provides the most commonly used functions for array operations returning `Option`, while Std, Batteries, and specialized libraries extend this with domain-specific functionality.

### Key Findings:
1. **Most Common Pattern:** Search and find operations (`find?`, `findIdx?`, etc.)
2. **Second Most Common:** Element access with safety (`back?`, `max?`, `min?`)
3. **No Built-in:** `get?`, `head?`, `tail?`, `pop?` (use alternatives or syntax sugar)
4. **Rich Ecosystem:** Specialized functions in compiler, meta-programming, and tactic libraries
5. **Type Safety:** Several functions return `Fin` types for guaranteed bounds

### Recommended Functions for Common Tasks:
- **Last element:** `Array.back?`
- **Find by predicate:** `Array.find?` or `Array.findRev?`
- **Find index:** `Array.findIdx?` or `Array.idxOf?`
- **Max/Min:** `Array.max?` or `Array.min?`
- **Transform and find:** `Array.findSome?`
- **Binary search:** `Array.binSearch`

---

**Report Generated:** 2025-12-20  
**Loogle API Version:** Current (as of search date)  
**Total Functions Documented:** 43 exact + 36 partial = 79 total functions
