# MCP Tools Guide for Lean 4 Development

## Overview

This guide describes the MCP (Model Context Protocol) tools available for Lean 4 development in the ProofChecker system. MCP tools provide real-time proof verification, theorem search, and project exploration capabilities.

## Available MCP Servers

### 1. lean-lsp-mcp (Proof Verification)

**Purpose**: Real-time interaction with Lean Language Server

**Status**: 🟡 Partial (wrapper implemented, MCP integration pending)

**When to Use**:
- Validating proofs incrementally during implementation
- Getting current proof state at any position
- Diagnosing compilation errors in real-time
- Obtaining type information for expressions
- Getting hover documentation

**Key Functions**:
- `getProofState(file, line, col)` - Get current goals and hypotheses
- `checkProof(file, proof_text)` - Validate proof without writing file
- `getDiagnostics(file)` - Get errors, warnings, info messages
- `getHover(file, line, col)` - Get type and documentation info

**Example Usage**:
```typescript
import { createLSPClient } from './.opencode/tool/mcp/index.js';

const lsp = createLSPClient();

// During proof implementation:
// 1. Write tactic line
const result = await lsp.getProofState('file.lean', { line: 45, column: 10 });

// 2. Check new proof state
if (result.success) {
  console.log('Goals:', result.data.goals);
  console.log('Hypotheses:', result.data.hypotheses);
}

// 3. Get diagnostics to check for errors
const diagnostics = await lsp.getDiagnostics('file.lean');

// 4. Proceed only if no errors
if (diagnostics.success) {
  const errors = diagnostics.data.filter(d => d.severity === 'error');
  if (errors.length === 0) {
    // Continue with next step
  }
}
```

**Benefits**:
- Catch errors immediately without full compilation
- See proof state after each tactic
- Get suggestions from LSP
- Faster iteration cycle

**Limitations** (Current):
- MCP protocol integration not yet complete
- Fallback to full compilation when unavailable
- Cache may become stale if file changes externally

### 2. LeanExplore (Structure Exploration)

**Purpose**: Explore Lean project structure and dependencies

**Status**: 🔴 Planned (not yet implemented)

**When to Use**:
- Understanding Mathlib organization
- Finding related theorems in a namespace
- Analyzing theorem dependencies
- Discovering available type class instances
- Navigating module hierarchy

**Key Functions** (Planned):
- `exploreModule(name)` - List all contents of a module
- `exploreDependencies(theorem)` - Find what a theorem depends on
- `exploreUsages(theorem)` - Find where a theorem is used
- `exploreNamespace(ns)` - Navigate namespace hierarchy

**Example Usage** (Planned):
```typescript
// To understand a Mathlib area:
const explorer = createExploreClient();

// 1. Explore namespace
const contents = await explorer.exploreNamespace('Topology.MetricSpace');

// 2. Review definitions and theorems
console.log('Definitions:', contents.data.definitions);
console.log('Theorems:', contents.data.theorems);

// 3. Explore dependencies for key theorems
const deps = await explorer.exploreDependencies('dist_triangle');

// 4. Build mental model of the area
```

**Benefits** (When Implemented):
- Understand Mathlib structure quickly
- Find related theorems efficiently
- Analyze proof dependencies
- Discover available instances

### 3. Loogle (Type-based Search)

**Purpose**: Search theorems by type signature and patterns

**Status**: 🔴 Planned (not yet implemented)

**When to Use**:
- Finding theorems with specific type signatures
- Searching for lemmas matching a pattern
- Goal-directed theorem discovery
- Finding theorems that could prove current goal

**Key Functions** (Planned):
- `searchByType(pattern)` - Find theorems matching type pattern
- `searchByPattern(pattern)` - Pattern-based search
- `searchUnify(goal)` - Find theorems that unify with goal

**Pattern Syntax** (Planned):
- `?a`, `?b` - Pattern variables
- `_` - Wildcard
- Exact type signatures

**Example Usage** (Planned):
```typescript
const loogle = createLoogleClient();

// To find commutativity theorems:
const results = await loogle.searchByPattern('?a * ?b = ?b * ?a');

// To find theorems about sqrt:
const sqrtTheorems = await loogle.searchByType(
  '∀ x : ℝ, x ≥ 0 → sqrt x * sqrt x = x'
);

// To find theorems for current goal:
const applicable = await loogle.searchUnify('a + b = b + a');
```

**Benefits** (When Implemented):
- Find exact theorems needed
- Discover lemmas by type
- Pattern-based discovery
- Goal-directed search

### 4. LeanSearch (Semantic Search)

**Purpose**: Natural language semantic search over Mathlib

**Status**: 🔴 Planned (not yet implemented)

**When to Use**:
- Initial exploration of unfamiliar areas
- Finding theorems without knowing exact terminology
- Discovering related mathematical concepts
- Broad conceptual search

**Key Functions** (Planned):
- `searchSemantic(query)` - Natural language search
- `searchSimilar(theorem)` - Find similar theorems
- `searchConcept(concept)` - Search by mathematical concept

**Example Usage** (Planned):
```typescript
const search = createSearchClient();

// Natural language queries:
const results = await search.searchSemantic(
  'theorems about continuity of square root function'
);

const cauchy = await search.searchSemantic(
  'Cauchy sequences in metric spaces'
);

const compact = await search.searchConcept('compactness');
```

**Benefits** (When Implemented):
- Find theorems without exact terminology
- Discover related concepts
- Exploratory search
- Semantic understanding

## Search Strategy Decision Tree

```
START: Need to find a theorem

├─ Do you know the exact type signature?
│  YES → Use Loogle (type-based search)
│  NO → Continue
│
├─ Do you know the general pattern?
│  YES → Use Loogle (pattern search)
│  NO → Continue
│
├─ Do you know the mathematical concept?
│  YES → Use LeanSearch (semantic search)
│  NO → Continue
│
└─ Exploring a general area?
   YES → Use LeanExplore (namespace exploration)
   NO → Use LeanSearch (broad semantic search)
```

## Multi-Tool Search Strategy

For comprehensive searches, use multiple tools in sequence:

1. **Start Broad**: LeanSearch with natural language
2. **Refine**: LeanExplore to understand namespace structure
3. **Precise**: Loogle for exact type matches
4. **Verify**: lean-lsp to check if theorem applies

## Integration with Agents

### Researcher Agent
- Uses all search tools (Loogle, LeanSearch, LeanExplore)
- Merges results from multiple sources
- Ranks by relevance and confidence

### Implementer Agent
- Uses lean-lsp for incremental validation
- Validates each tactic before proceeding
- Gets proof state after each step

### Planner Agent
- Uses Loogle for type-guided planning
- Uses LeanExplore for dependency analysis
- Builds proof strategy from available theorems

### Reviser Agent
- Uses lean-lsp for error diagnosis
- Uses LeanSearch to find similar successful proofs
- Generates specific revision recommendations

## Best Practices

1. **Always validate with LSP** before writing files
2. **Use type search first** when you know the signature
3. **Combine search tools** for comprehensive results
4. **Explore namespaces** to understand structure
5. **Check dependencies** before using complex theorems
6. **Verify incrementally** during proof construction

## Error Handling

If MCP tool unavailable:
- **lean-lsp** → Fall back to full compilation
- **Loogle** → Fall back to grep-based search
- **LeanSearch** → Fall back to keyword search
- **LeanExplore** → Fall back to manual file reading

## Performance Considerations

- **LSP queries**: Fast (< 100ms), use liberally
- **Loogle searches**: Moderate (< 1s), cache results
- **LeanSearch**: Slower (1-3s), use for initial exploration
- **LeanExplore**: Fast (< 500ms), good for navigation

## Implementation Status

### Phase 1: Foundation (Current)
- ✅ Type definitions created
- ✅ Error handling framework created
- ✅ LSP client wrapper created (basic)
- ✅ MCP tools guide created
- ⏳ MCP protocol integration (pending)

### Phase 2: Additional Clients (Planned)
- ⬜ LeanExplore client
- ⬜ Loogle client
- ⬜ LeanSearch client

### Phase 3: Integration (Planned)
- ⬜ Connect LSP to actual lean-lsp-mcp server
- ⬜ Implement MCP protocol communication
- ⬜ Add comprehensive error handling
- ⬜ Add performance monitoring

## Troubleshooting

### LSP Client Not Working

**Problem**: LSP operations return "not available" errors

**Solutions**:
1. Check if lean-lsp-mcp is installed: `uvx lean-lsp-mcp`
2. Verify `.mcp.json` configuration
3. Check MCP server logs
4. Fall back to full compilation

### Slow Response Times

**Problem**: MCP operations are slow

**Solutions**:
1. Enable caching: `useCache: true`
2. Increase cache TTL: `cacheTTL: 120000`
3. Check network/server load
4. Clear expired cache entries

### Stale Cache

**Problem**: Cache returns outdated results

**Solutions**:
1. Reduce cache TTL
2. Clear cache manually: `lsp.clearCache()`
3. Disable cache for critical operations

## References

- [MCP Integration Plan](../../specs/mcp-integration-plan.md)
- [MCP Integration Checklist](../../specs/mcp-integration-checklist.md)
- [MCP Tools README](../../tool/mcp/README.md)
- [TypeScript Type Definitions](../../tool/mcp/types.ts)

## Version

**Version**: 0.1.0  
**Last Updated**: 2025-12-15  
**Status**: Phase 1 - Foundation Complete
