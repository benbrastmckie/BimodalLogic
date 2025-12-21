# LeanSearch Semantic Search Report: Axiom Pattern Matching

**Report Generated**: 2025-12-21  
**Status**: ⚠️ LeanSearch MCP Server Not Available  
**Alternative Approach**: Manual research based on Lean 4 documentation and Mathlib knowledge

## Executive Summary

The LeanSearch MCP server is not currently configured in this project (listed as planned in `.mcp.json`). The web API for LeanSearch also appears to be inaccessible via programmatic requests. 

However, based on extensive knowledge of Lean 4's metaprogramming infrastructure and Mathlib, I can provide a comprehensive analysis of the components most relevant to axiom pattern matching in proof search automation.

## Queries Attempted

1. "match axiom pattern"
2. "axiom matching"
3. "pattern matching axioms"
4. "axiom unification"
5. "pattern matching proof search"
6. "unification axiom schema"

## Key Findings for ProofChecker's Axiom Pattern Matching

### Critical Components for Axiom Pattern Matching

Based on Lean 4's architecture, here are the most relevant components for implementing axiom pattern matching in proof search:

#### 1. **Lean.Meta.isDefEq** - Definitional Equality Check
- **Type**: `meta`
- **Module**: `Lean.Meta.InferType`
- **Signature**: `isDefEq : Expr → Expr → MetaM Bool`
- **Relevance**: 9/10
- **Description**: Core function for checking if two expressions are definitionally equal. Essential for matching proof goals against axiom conclusions.
- **Usage**: Use this to check if an axiom's conclusion matches the current goal modulo definitional equality.

#### 2. **Lean.Meta.kabstract** - Expression Abstraction
- **Type**: `meta`
- **Module**: `Lean.Meta.KAbstract`
- **Signature**: `kabstract : Expr → Expr → MetaM Expr`
- **Relevance**: 8/10
- **Description**: Abstracts occurrences of an expression within another expression, replacing them with bound variables.
- **Usage**: Useful for pattern matching when you need to identify where a subexpression appears in a larger term.

#### 3. **Lean.Meta.Match** - Pattern Matching Infrastructure
- **Type**: `meta`
- **Module**: `Lean.Meta.Match.Match`
- **Signature**: Multiple functions for pattern matching compilation
- **Relevance**: 7/10
- **Description**: The core pattern matching infrastructure used by Lean's match expressions.
- **Usage**: Can be adapted for matching axiom patterns against goals.

#### 4. **Lean.Elab.Tactic.getGoals** - Goal Retrieval
- **Type**: `meta`
- **Module**: `Lean.Elab.Tactic.Basic`
- **Signature**: `getGoals : TacticM (List MVarId)`
- **Relevance**: 10/10
- **Description**: Retrieves the current list of goals in a tactic state.
- **Usage**: Essential for accessing the goal you want to match against axioms.

#### 5. **Lean.Meta.forallTelescopeReducing** - Binder Traversal
- **Type**: `meta`
- **Module**: `Lean.Meta.Basic`
- **Signature**: `forallTelescopeReducing {α} : Expr → (Array Expr → Expr → MetaM α) → MetaM α`
- **Relevance**: 9/10
- **Description**: Traverses through forall binders in an expression, useful for handling universally quantified axioms.
- **Usage**: Use this to extract the conclusion of an axiom from its full type (which may have multiple forall binders).

#### 6. **Lean.Meta.matchEq** - Equality Matching
- **Type**: `meta`
- **Module**: `Lean.Meta.Basic`
- **Signature**: `matchEq? : Expr → MetaM (Option (Expr × Expr × Expr))`
- **Relevance**: 7/10
- **Description**: Matches an expression against the pattern `a = b`, returning the type and both sides.
- **Usage**: Useful for axioms that are equality statements.

#### 7. **Lean.Meta.DiscrTree** - Discrimination Tree
- **Type**: `definition`
- **Module**: `Lean.Meta.DiscrTree`
- **Signature**: `DiscrTree (α : Type) : Type`
- **Relevance**: 10/10
- **Description**: A discrimination tree data structure for efficient pattern indexing and lookup.
- **Usage**: **CRITICAL** - This is the primary data structure for efficient axiom indexing. Build a DiscrTree indexed by axiom conclusion patterns for O(log n) lookup instead of O(n) linear search.

#### 8. **Lean.Meta.DiscrTree.mkPath** - Index Path Creation
- **Type**: `meta`
- **Module**: `Lean.Meta.DiscrTree`
- **Signature**: `mkPath : Expr → Array DiscrTree.Key`
- **Relevance**: 10/10
- **Description**: Creates an indexing path from an expression for insertion into a discrimination tree.
- **Usage**: Use this to index each axiom by its conclusion pattern. Essential for efficient axiom lookup.

#### 9. **Lean.Meta.DiscrTree.getMatch** - Pattern Lookup
- **Type**: `meta`
- **Module**: `Lean.Meta.DiscrTree`
- **Signature**: `getMatch : DiscrTree α → Expr → MetaM (Array α)`
- **Relevance**: 10/10
- **Description**: Retrieves all entries in the discrimination tree that could match the given expression.
- **Usage**: **PRIMARY OPERATION** - Given a goal, retrieve all axioms whose conclusions could potentially match.

#### 10. **Lean.Meta.synthInstance** - Type Class Synthesis
- **Type**: `meta`
- **Module**: `Lean.Meta.SynthInstance`
- **Signature**: `synthInstance : Expr → MetaM Expr`
- **Relevance**: 6/10
- **Description**: Synthesizes a type class instance for the given type.
- **Usage**: If your axioms have type class preconditions (like `[TaskFrame F]`), use this to check if instances can be synthesized.

#### 11. **Lean.Meta.getMVarDecl** - Metavariable Information
- **Type**: `meta`
- **Module**: `Lean.Meta.Basic`
- **Signature**: `getMVarDecl : MVarId → MetaM MVarDecl`
- **Relevance**: 8/10
- **Description**: Gets the declaration information for a metavariable (goal).
- **Usage**: Extract the target type of a goal to match against axiom conclusions.

#### 12. **Lean.Meta.instantiateMVars** - Metavariable Instantiation
- **Type**: `meta`
- **Module**: `Lean.Meta.Basic`
- **Signature**: `instantiateMVars : Expr → MetaM Expr`
- **Relevance**: 8/10
- **Description**: Instantiates all metavariables in an expression with their assigned values.
- **Usage**: Normalize expressions before pattern matching to ensure you're matching against concrete terms.

#### 13. **Lean.Meta.apply** - Axiom Application
- **Type**: `meta`
- **Module**: `Lean.Meta.Tactic.Apply`
- **Signature**: `apply : MVarId → Expr → MetaM (List MVarId)`
- **Relevance**: 10/10
- **Description**: Applies a theorem/axiom to a goal, returning new subgoals for the axiom's premises.
- **Usage**: **PRIMARY OPERATION** - Once you've found a matching axiom, use this to apply it to the goal.

#### 14. **Lean.Meta.ppExpr** - Expression Pretty Printing
- **Type**: `meta`
- **Module**: `Lean.Meta.PProdN`
- **Signature**: `ppExpr : Expr → MetaM Format`
- **Relevance**: 5/10 (debugging)
- **Description**: Pretty prints an expression for debugging.
- **Usage**: Debug your pattern matching to see what expressions are being compared.

#### 15. **Lean.Environment.find?** - Declaration Lookup
- **Type**: `meta`
- **Module**: `Lean.Environment`
- **Signature**: `find? : Environment → Name → Option ConstantInfo`
- **Relevance**: 9/10
- **Description**: Looks up a constant (axiom, theorem, definition) by name in the environment.
- **Usage**: Retrieve axiom declarations from the environment to build your axiom database.

## Recommendations for ProofChecker Project

### 1. **Build an Axiom Index Using DiscrTree**

**Priority**: CRITICAL

The most important recommendation is to use `Lean.Meta.DiscrTree` to index your axioms. This provides O(log n) lookup time instead of O(n) linear search through all axioms.

```lean
-- Axiom database structure
structure AxiomDB where
  tree : DiscrTree Name  -- Maps conclusion patterns to axiom names
  deriving Inhabited

-- Build the index
def buildAxiomIndex (axioms : List Name) : MetaM AxiomDB := do
  let mut tree := DiscrTree.empty
  for axiomName in axioms do
    let info ← getConstInfo axiomName
    forallTelescopeReducing info.type fun _ conclusion => do
      let keys ← DiscrTree.mkPath conclusion
      tree := tree.insert keys axiomName
  return { tree }

-- Lookup matching axioms
def findMatchingAxioms (db : AxiomDB) (goal : Expr) : MetaM (Array Name) := do
  db.tree.getMatch goal
```

### 2. **Implement Axiom Application with Backtracking**

When multiple axioms match, implement a backtracking search:

```lean
def tryAxioms (goal : MVarId) (axioms : Array Name) : MetaM (Option (List MVarId)) := do
  for axiom in axioms do
    try
      let subgoals ← Meta.apply goal (← mkConst axiom)
      return some subgoals
    catch _ =>
      continue
  return none
```

### 3. **Handle Axiom Preconditions**

Your LOGOS axioms have preconditions (like `TaskFrame F`). Check these before attempting to apply:

```lean
def checkPreconditions (axiomType : Expr) : MetaM Bool := do
  forallTelescopeReducing axiomType fun params _ => do
    for param in params do
      let paramType ← inferType param
      if ← isClass? paramType then
        -- Try to synthesize instance
        try
          let _ ← synthInstance paramType
        catch _ =>
          return false
    return true
```

### 4. **Normalize Before Matching**

Always instantiate metavariables before pattern matching:

```lean
def normalizeGoal (goal : MVarId) : MetaM Expr := do
  let decl ← getMVarDecl goal
  instantiateMVars decl.type
```

### 5. **Use Type-Based Filtering**

Before using the DiscrTree, filter axioms by the goal's syntactic structure (modal operator, temporal operator, etc.):

```lean
def classifyGoal (goal : Expr) : GoalClass :=
  match goal with
  | App (Const ``Box ..) _ => .Modal
  | App (Const ``Perpetuity ..) _ => .Temporal
  | App (Const ``Implies ..) _ => .Propositional
  | _ => .Other
```

### 6. **Implement Axiom Ranking**

When multiple axioms match, rank them by:
- Specificity (more specific patterns first)
- Historical success rate (learning from past proofs)
- Complexity (prefer simpler axioms)

## Implementation Roadmap

### Phase 1: Basic Axiom Matching (Week 1)
1. Create `AxiomDB` structure with DiscrTree
2. Implement `buildAxiomIndex` to index all LOGOS axioms
3. Implement `findMatchingAxioms` for lookup
4. Test with simple modal axioms

### Phase 2: Smart Application (Week 2)
1. Implement `tryAxioms` with backtracking
2. Add precondition checking
3. Integrate with existing proof search
4. Add logging and debugging

### Phase 3: Optimization (Week 3)
1. Implement axiom ranking
2. Add caching for repeated patterns
3. Profile and optimize hot paths
4. Add metrics collection

### Phase 4: Advanced Features (Week 4)
1. Learn from successful applications
2. Implement axiom combination strategies
3. Add support for derived rules
4. Integration testing

## Specific Code Locations in ProofChecker

### Where to Implement

1. **Create new file**: `Logos/Core/Automation/AxiomDB.lean`
   - Define `AxiomDB` structure
   - Implement DiscrTree-based indexing
   - Implement axiom lookup and matching

2. **Extend**: `Logos/Core/Automation/ProofSearch.lean`
   - Integrate `AxiomDB` into proof search
   - Add axiom-based search strategies
   - Implement backtracking for axiom application

3. **Update**: `Logos/Core/Automation/Tactics.lean`
   - Add `apply_axiom` tactic
   - Add `find_axioms` tactic (for debugging)
   - Add `axiom_search` tactic (automated search)

### Axioms to Index

From your codebase, index these axiom sets:

1. **Modal Axioms** (`Logos/Core/ProofSystem/Axioms.lean`):
   - K axiom
   - T axiom (reflexivity)
   - 4 axiom (transitivity)
   - 5 axiom
   - Distribution axioms

2. **Temporal Axioms**:
   - Perpetuity axioms
   - Task completion axioms
   - History axioms

3. **Derived Rules** (`Logos/Core/Theorems/`):
   - All theorems in `ModalS4.lean`
   - All theorems in `ModalS5.lean`
   - All theorems in `Perpetuity.lean`
   - All theorems in `Propositional.lean`

## Technical Considerations

### Memory Usage
- DiscrTree is memory-efficient but does allocate
- Consider lazy loading for large axiom sets
- Profile memory usage during proof search

### Performance
- DiscrTree lookup is O(log n) in tree depth
- Consider caching for frequently used patterns
- Profile to find bottlenecks

### Correctness
- Always verify that matched axioms are applicable
- Check preconditions before application
- Ensure soundness by using Lean's built-in `apply` tactic

## Alternative Approaches

If DiscrTree proves too complex initially:

1. **Simple Linear Search**: O(n) but easier to implement
2. **Hash-based Indexing**: Group by head symbol
3. **Hybrid Approach**: Use simple hashing, upgrade to DiscrTree later

## Conclusion

While the LeanSearch MCP server is not available, the components listed above provide everything needed to implement robust axiom pattern matching for the ProofChecker project. The DiscrTree-based approach is the gold standard used by Lean's own automation (like `simp` and `aesop`), and should be adopted for ProofChecker's axiom database.

**Key Takeaway**: Use `Lean.Meta.DiscrTree` for axiom indexing and `Lean.Meta.apply` for axiom application. This combination provides efficient, correct, and maintainable axiom pattern matching.

## Next Steps

1. **Configure LeanSearch MCP Server**: Research and configure the server in `.mcp.json` for future semantic searches
2. **Implement AxiomDB**: Start with the DiscrTree-based implementation
3. **Test on Simple Cases**: Validate with basic modal logic proofs
4. **Iterate and Optimize**: Profile and improve based on real usage

## References

- Lean 4 Metaprogramming Book: https://lean-lang.org/lean4/doc/metaprogramming.html
- DiscrTree Documentation: Lean 4 source code `Lean/Meta/DiscrTree.lean`
- Aesop Source: https://github.com/leanprover-community/aesop (excellent example of DiscrTree usage)
- Mathlib's apply_rules tactic: Uses similar axiom-application approach
