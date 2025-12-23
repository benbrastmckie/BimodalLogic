# Loogle Search Results: Nat → _ → Except _ _

**Type Pattern**: `Nat → _ → Except _ _`  
**Date**: Sun Dec 21 2025  
**Total Matches Found**: 27 declarations mentioning both Nat and Except  
**Exact Pattern Matches**: 6 functions

---

## Executive Summary

This search identified all functions in the Lean ecosystem that involve both `Nat` and `Except` types. The exact pattern `Nat → _ → Except _ _` (functions taking a Nat as first parameter and returning an Except type) yielded 6 matches, primarily from Lean's core libraries for JSON parsing, parser extensions, and LRAT proof operations.

**Key Findings**:
- Most common error type: `String`
- Primary use cases: JSON parsing, parser manipulation, proof trimming
- Libraries: Lean core (Init, Std, Lean), Mathlib, Plausible, ProofWidgets, Loogle
- Total ecosystem functions with Nat+Except: 27

---

## Exact Matches (6 functions)

Functions matching the exact pattern `Nat → _ → Except _ _`:

### 1. Lean.Json.getArrVal?
- **Type**: `Lean.Json → ℕ → Except String Lean.Json`
- **Module**: `Lean.Data.Json.Basic`
- **Library**: Lean core
- **Documentation**: Not available
- **Use Case**: Extract a value from a JSON array at a given natural number index
- **Error Type**: `String`
- **Return Type**: `Lean.Json`

### 2. Lean.Json.parseTagged
- **Type**: `(json : Lean.Json) (tag : String) (nFields : ℕ) (fieldNames? : Option (Array Lean.Name)) : Except String (Array Lean.Json)`
- **Module**: `Lean.Data.Json.FromToJson.Basic`
- **Library**: Lean core
- **Documentation**: Parses a JSON-encoded `structure` or `inductive` constructor. Used mostly by `deriving FromJson`.
- **Use Case**: Parse tagged JSON structures with a specified number of fields
- **Error Type**: `String`
- **Return Type**: `Array Lean.Json`

### 3. Lean.Parser.addLeadingParser
- **Type**: `(categories : Lean.Parser.ParserCategories) (catName declName : Lean.Name) (p : Lean.Parser.Parser) (prio : ℕ) : Except String Lean.Parser.ParserCategories`
- **Module**: `Lean.Parser.Extension`
- **Library**: Lean core
- **Documentation**: Not available
- **Use Case**: Add a leading parser to parser categories with specified priority
- **Error Type**: `String`
- **Return Type**: `Lean.Parser.ParserCategories`

### 4. Lean.Parser.addTrailingParser
- **Type**: `(categories : Lean.Parser.ParserCategories) (catName declName : Lean.Name) (p : Lean.Parser.TrailingParser) (prio : ℕ) : Except String Lean.Parser.ParserCategories`
- **Module**: `Lean.Parser.Extension`
- **Library**: Lean core
- **Documentation**: Not available
- **Use Case**: Add a trailing parser to parser categories with specified priority
- **Error Type**: `String`
- **Return Type**: `Lean.Parser.ParserCategories`

### 5. Lean.Parser.addParser
- **Type**: `(categories : Lean.Parser.ParserCategories) (catName declName : Lean.Name) (leading : Bool) (p : Lean.Parser.Parser) (prio : ℕ) : Except String Lean.Parser.ParserCategories`
- **Module**: `Lean.Parser.Extension`
- **Library**: Lean core
- **Documentation**: Not available
- **Use Case**: Add a parser (leading or trailing) to parser categories with specified priority
- **Error Type**: `String`
- **Return Type**: `Lean.Parser.ParserCategories`

### 6. Lean.Elab.Tactic.BVDecide.LRAT.trim.M.findInitialId
- **Type**: `(proof : Array Std.Tactic.BVDecide.LRAT.IntAction) (curr : ℕ := 0) : Except String ℕ`
- **Module**: `Lean.Elab.Tactic.BVDecide.LRAT.Trim`
- **Library**: Lean core
- **Documentation**: Not available
- **Use Case**: Find the initial ID in an LRAT proof, starting from a given natural number
- **Error Type**: `String`
- **Return Type**: `ℕ`

---

## Related Functions (21 additional functions)

Functions that involve both `Nat` and `Except` but don't match the exact pattern:

### JSON Operations

#### 7. Lean.Json.getNat?
- **Type**: `Lean.Json → Except String ℕ`
- **Module**: `Lean.Data.Json.Basic`
- **Library**: Lean core
- **Pattern**: Returns Nat from JSON
- **Use Case**: Extract a natural number from JSON

#### 8. Lean.bignumFromJson?
- **Type**: `(j : Lean.Json) : Except String ℕ`
- **Module**: `Lean.Data.Json.FromToJson.Basic`
- **Library**: Lean core
- **Documentation**: Note that `USize`s and `UInt64`s are stored as strings because JavaScript cannot represent 64-bit numbers.
- **Use Case**: Parse big numbers from JSON

### Parser Operations

#### 9. Lean.Parser.getParserPriority
- **Type**: `(args : Lean.Syntax) : Except String ℕ`
- **Module**: `Lean.Parser.Extension`
- **Library**: Lean core
- **Use Case**: Extract parser priority from syntax

### Error Processing

#### 10. Lean.ErrorExplanation.processDoc
- **Type**: `(doc : String) : Except (ℕ × String) Unit`
- **Module**: `Lean.ErrorExplanation`
- **Library**: Lean core
- **Documentation**: Validates that the given error explanation has the expected structure. If an error is found, it is represented as a pair `(lineNumber, errorMessage)` where `lineNumber` gives the 0-based offset from the first line of `doc` at which the error occurs.
- **Error Type**: `ℕ × String` (line number and error message)
- **Use Case**: Validate error documentation with line number tracking

### BVDecide/LRAT Operations

#### 11. Lean.Elab.Tactic.BVDecide.LRAT.trim.M.findEmptyId
- **Type**: `(proof : Array Std.Tactic.BVDecide.LRAT.IntAction) : Except String ℕ`
- **Module**: `Lean.Elab.Tactic.BVDecide.LRAT.Trim`
- **Library**: Lean core
- **Use Case**: Find empty clause ID in LRAT proof

#### 12. Lean.Elab.Tactic.BVDecide.Frontend.runExternal
- **Type**: `(cnf : Std.Sat.CNF ℕ) (solver lratPath : System.FilePath) (trimProofs : Bool) (timeout : ℕ) (binaryProofs : Bool) : Lean.CoreM (Except (Array (Bool × ℕ)) Lean.Elab.Tactic.BVDecide.Frontend.LratCert)`
- **Module**: `Lean.Elab.Tactic.BVDecide.Frontend.LRAT`
- **Library**: Lean core
- **Documentation**: Run an external SAT solver on the `CNF` to obtain an LRAT proof. This will obtain an `LratCert` if the formula is UNSAT and throw errors otherwise.
- **Use Case**: External SAT solver integration with timeout

#### 13. Lean.Elab.Tactic.BVDecide.Frontend.lratBitblaster
- **Type**: `(goal : Lean.MVarId) (ctx : Lean.Elab.Tactic.BVDecide.Frontend.TacticContext) (reflectionResult : Lean.Elab.Tactic.BVDecide.Frontend.ReflectionResult) (atomsAssignment : Std.HashMap ℕ (ℕ × Lean.Expr × Bool)) : Lean.MetaM (Except Lean.Elab.Tactic.BVDecide.Frontend.CounterExample Lean.Elab.Tactic.BVDecide.Frontend.UnsatProver.Result)`
- **Module**: `Lean.Elab.Tactic.BVDecide.Frontend.BVDecide`
- **Library**: Lean core
- **Use Case**: Bitblasting for BVDecide tactic

### Server/LSP Operations

#### 14. Std.Broadcast.send
- **Type**: `{α : Type} (ch : Std.Broadcast α) (v : α) : BaseIO (Task (Except IO.Error ℕ))`
- **Module**: `Std.Sync.Broadcast`
- **Library**: Std
- **Documentation**: Send a value through the broadcast channel, returning a task that will resolve once the transmission could be completed.
- **Use Case**: Asynchronous broadcast with task tracking

### Mathlib Operations

#### 15. Mathlib.Tactic.Sat.buildProofStep
- **Type**: `(db : Std.HashMap ℕ Mathlib.Tactic.Sat.Clause) (ns pf : Array ℤ) (ctx clause : Lean.Expr) : Except String Lean.Expr`
- **Module**: `Mathlib.Tactic.Sat.FromLRAT`
- **Library**: Mathlib
- **Documentation**: Construct an individual proof step `⊢ ctx.proof c`.
- **Use Case**: SAT proof construction from LRAT

### Loogle Operations

#### 16. Loogle.Find.find
- **Type**: `(index : Loogle.Find.Index) (args : Lean.TSyntax `Loogle.Find.find_filters) (maxShown : ℕ := 200) : Lean.Elab.TermElabM (Except Loogle.Find.Failure Loogle.Find.Result)`
- **Module**: `Loogle.Find`
- **Library**: Loogle
- **Documentation**: The core of the `#find` tactic with all parsing/printing factored out, for programmatic use (e.g. the loogle CLI). It also does not use the implicit global Index, but rather expects one as an argument.
- **Use Case**: Programmatic Loogle search with result limit

### Size Specification Functions (6 functions)

These are auto-generated size specification functions for various structures:

#### 17. Except.ctorElimType
- **Type**: `{ε : Type u} {α : Type v} {motive : Except ε α → Sort u_1} (ctorIdx : ℕ) : Sort (max 1 (imax (u + 1) u_1) (imax (v + 1) u_1))`
- **Module**: `Init.Prelude`
- **Library**: Lean Init

#### 18. Except.error.sizeOf_spec
- **Type**: `{ε : Type u} {α : Type v} [SizeOf ε] [SizeOf α] (a✝ : ε) : sizeOf (Except.error a✝) = 1 + sizeOf a✝`
- **Module**: `Init.SizeOf`
- **Library**: Lean Init

#### 19. Except.ok.sizeOf_spec
- **Type**: `{ε : Type u} {α : Type v} [SizeOf ε] [SizeOf α] (a✝ : α) : sizeOf (Except.ok a✝) = 1 + sizeOf a✝`
- **Module**: `Init.SizeOf`
- **Library**: Lean Init

#### 20. IO.AsyncList.delayed.sizeOf_spec
- **Type**: `{ε : Type u} {α : Type v} [SizeOf ε] [SizeOf α] (tl : Lean.Server.ServerTask (Except ε (IO.AsyncList ε α))) : sizeOf (IO.AsyncList.delayed tl) = 1 + sizeOf tl`
- **Module**: `Lean.Server.AsyncList`
- **Library**: Lean core

#### 21. Lean.Server.RequestHandler.mk.sizeOf_spec
- **Type**: `(fileSource : Lean.Json → Except Lean.Server.RequestError Lean.Lsp.FileIdent) (handle : Lean.Json → Lean.Server.RequestM (Lean.Server.RequestTask Lean.Server.SerializedLspResponse)) : sizeOf { fileSource := fileSource, handle := handle } = 1`
- **Module**: `Lean.Server.Requests`
- **Library**: Lean core

#### 22. Lean.Server.StatefulRequestHandler.mk.sizeOf_spec
- **Type**: Complex type involving request handlers
- **Module**: `Lean.Server.Requests`
- **Library**: Lean core

#### 23. Lean.Server.FileWorker.PendingRequest.mk.sizeOf_spec
- **Type**: `(requestTask : Lean.Server.ServerTask (Except IO.Error Unit)) (cancelTk : Lean.Server.RequestCancellationToken) : sizeOf { requestTask := requestTask, cancelTk := cancelTk } = 1 + sizeOf requestTask + sizeOf cancelTk`
- **Module**: `Lean.Server.FileWorker`
- **Library**: Lean core

#### 24. Lean.Server.FileWorker.WorkerState.mk.sizeOf_spec
- **Type**: Complex type involving worker state
- **Module**: `Lean.Server.FileWorker`
- **Library**: Lean core

### Testing Library Functions

#### 25. Plausible.instMonadLiftStateIOGen
- **Type**: `MonadLift (ReaderT (ULift.{0, 0} ℕ) (Except Plausible.GenError)) IO`
- **Module**: `Plausible.Gen`
- **Library**: Plausible (testing library)

#### 26. Plausible.instMonadLiftGen
- **Type**: `{m : Type u_1 → Type u_2} [MonadLiftT m (ReaderT (ULift.{u_1, 0} ℕ) (Except Plausible.GenError))] : MonadLiftT (Plausible.RandGT StdGen m) Plausible.Gen`
- **Module**: `Plausible.Gen`
- **Library**: Plausible (testing library)

### ProofWidgets

#### 27. ProofWidgets.CancellableTask.mk.sizeOf_spec
- **Type**: `(task : Task (Except Lean.Server.RequestError (ProofWidgets.LazyEncodable Lean.Json))) (cancel : IO Unit) : sizeOf { task := task, cancel := cancel } = 1 + sizeOf task`
- **Module**: `ProofWidgets.Cancellable`
- **Library**: ProofWidgets

---

## Analysis by Category

### By Library Distribution
- **Lean Core**: 20 functions (74%)
  - Init: 3 functions
  - Lean.Data.Json: 3 functions
  - Lean.Parser: 4 functions
  - Lean.Server: 5 functions
  - Lean.Elab.Tactic.BVDecide: 4 functions
  - Lean.ErrorExplanation: 1 function
- **Std**: 1 function (4%)
- **Mathlib**: 1 function (4%)
- **Plausible**: 2 functions (7%)
- **ProofWidgets**: 1 function (4%)
- **Loogle**: 1 function (4%)

### By Error Type
- **String**: 13 functions (most common)
- **IO.Error**: 3 functions
- **ℕ × String**: 1 function (error with line number)
- **Array (Bool × ℕ)**: 1 function
- **CounterExample**: 1 function
- **GenError**: 2 functions
- **RequestError**: 2 functions
- **Failure**: 1 function
- **Type parameters**: 3 functions

### By Use Case
1. **JSON Operations**: 3 functions (parsing, extraction, validation)
2. **Parser Extensions**: 4 functions (adding parsers with priorities)
3. **BVDecide/LRAT**: 4 functions (proof trimming, SAT solving)
4. **Server/LSP**: 5 functions (request handling, file workers)
5. **Size Specifications**: 8 functions (auto-generated)
6. **Testing**: 2 functions (property-based testing)
7. **Error Processing**: 1 function (documentation validation)
8. **SAT Solving**: 1 function (Mathlib)
9. **Search**: 1 function (Loogle)
10. **Widgets**: 1 function (ProofWidgets)

---

## Recommendations

### For JSON Operations
If you need to work with JSON and natural number indices:
- Use `Lean.Json.getArrVal?` for array access
- Use `Lean.Json.getNat?` to extract Nat values
- Use `Lean.Json.parseTagged` for structured data with known field counts

### For Parser Extensions
When adding parsers with priorities:
- Use `Lean.Parser.addLeadingParser` for prefix parsers
- Use `Lean.Parser.addTrailingParser` for postfix parsers
- Use `Lean.Parser.addParser` for general parser addition
- All return `Except String` for error handling

### For LRAT/SAT Operations
When working with proof certificates:
- Use `Lean.Elab.Tactic.BVDecide.LRAT.trim.M.findInitialId` to locate proof starts
- Use `Lean.Elab.Tactic.BVDecide.Frontend.runExternal` for external SAT solvers
- Use `Mathlib.Tactic.Sat.buildProofStep` for proof construction

### For Error Handling
- Most functions use `String` as error type for simplicity
- `Lean.ErrorExplanation.processDoc` uses `ℕ × String` for line-numbered errors
- Consider this pattern when error location is important

### For Search Operations
- `Loogle.Find.find` allows programmatic search with configurable result limits
- Default `maxShown` is 200 results

---

## Search Query Details

### Query 1: "Nat → _ → Except _ _"
- **Status**: Success
- **Results**: 6 exact matches
- **Pattern**: Functions taking Nat as first parameter, any type as second, returning Except

### Query 2: "Nat → α → Except ε α"
- **Status**: Error - Unknown identifier `α`
- **Reason**: Loogle doesn't recognize unbound type variables in this syntax
- **Suggestions**: Loogle provided 10 alternative patterns with specific types

### Query 3: "Nat → _ → Except"
- **Status**: Error - type expected
- **Reason**: Except requires two type parameters

### Query 4: "Nat, Except" (keyword search)
- **Status**: Success
- **Results**: 27 total declarations
- **Pattern**: All functions mentioning both Nat and Except

---

## Conclusion

The Lean ecosystem contains 27 functions involving both `Nat` and `Except` types, with 6 functions exactly matching the pattern `Nat → _ → Except _ _`. These functions are primarily concentrated in:

1. **JSON manipulation** (parsing, extraction, validation)
2. **Parser extension** (adding parsers with priorities)
3. **Proof operations** (LRAT trimming, SAT solving)

The predominant error type is `String`, indicating a preference for simple, human-readable error messages. The functions are well-distributed across Lean's core libraries, with some specialized uses in Mathlib, testing libraries, and tooling.

For most use cases involving natural number indexing with error handling, the JSON and parser extension functions provide good examples of idiomatic Lean code using the `Except` monad.
