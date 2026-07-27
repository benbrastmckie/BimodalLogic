# LeanSearch API Specification

**Research Date:** December 21, 2025  
**Primary Sources:**
- https://leansearch.net/
- https://github.com/leanprover-community/LeanSearchClient
- https://loogle.lean-lang.org/
- https://github.com/nomeata/loogle

## Executive Summary

This document provides the complete API specification for semantic search services available for Lean 4 and Mathlib4. There are three main search services:

1. **LeanSearch** - Natural language semantic search using embeddings
2. **LeanStateSearch** - Goal state-based search for tactics
3. **Loogle** - Pattern-based structural search

All three services are accessible via HTTP APIs and have Lean 4 client implementations available in the `LeanSearchClient` package.

---

## 1. LeanSearch API

### Overview
LeanSearch provides natural language semantic search over Mathlib4 using neural embeddings. It's hosted at https://leansearch.net/.

### API Endpoint

**Base URL:** `https://leansearch.net/search`

**Method:** `POST`

**Content-Type:** `application/json`

**Accept:** `application/json`

### Request Format

```json
{
  "query": ["<natural language query>"],
  "num_results": 6
}
```

**Parameters:**
- `query` (array of strings, required): Natural language description of the theorem/definition you're looking for. Must be wrapped in an array.
- `num_results` (integer, optional): Number of results to return. Default: 6

### Request Headers

```
Content-Type: application/json
Accept: application/json
User-Agent: <your-user-agent>
```

### Response Format

The response is a nested JSON array structure:

```json
[
  [
    {
      "result": {
        "name": ["Module", "Name", "Parts"],
        "type": "∀ (n m : ℕ), n < m → Nat.succ n < Nat.succ m",
        "docstring": "Documentation string for the theorem",
        "doc_url": "https://leanprover-community.github.io/mathlib4_docs/...",
        "kind": "theorem"
      }
    },
    {
      "result": {
        "name": ["Another", "Result"],
        "type": "...",
        "docstring": "...",
        "doc_url": "...",
        "kind": "..."
      }
    }
  ]
]
```

**Response Fields:**
- Outer array: Contains one element (the results array)
- Inner array: Contains the actual search results
- Each result object contains:
  - `result.name` (array of strings): Module path components that form the full name
  - `result.type` (string, optional): The type signature of the theorem/definition
  - `result.docstring` (string, optional): Documentation string (may be empty)
  - `result.doc_url` (string, optional): URL to the documentation
  - `result.kind` (string, optional): Kind of declaration (e.g., "theorem", "def", "lemma")

### Example cURL Command

```bash
curl -X POST https://leansearch.net/search \
  --user-agent "LeanSearchClient" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  --data '{"query":["If a natural number n is less than m, then the successor of n is less than the successor of m."],"num_results":6}'
```

### Environment Variable Override

You can override the API URL by setting:
```bash
export LEANSEARCHCLIENT_LEANSEARCH_API_URL="https://your-custom-url.com/search"
```

### Authentication

No authentication required. The service is publicly accessible.

### Rate Limiting

Not documented. Use responsibly with appropriate user-agent identification.

---

## 2. LeanStateSearch API

### Overview
LeanStateSearch provides tactic suggestions based on the current proof goal state. It's hosted at https://premise-search.com/.

### API Endpoint

**Base URL:** `https://premise-search.com/api/search`

**Method:** `GET`

### Request Format

Query parameters in URL:
```
?query=<goal-state>&results=<num>&rev=<revision>
```

**Parameters:**
- `query` (string, required): The pretty-printed goal state (URL-encoded)
- `results` (integer, optional): Number of results to return. Default: 6
- `rev` (string, optional): Lean/Mathlib revision to search. Default: current version (e.g., "v4.16.0")

### Request Headers

```
User-Agent: <your-user-agent>
```

### Response Format

JSON array of results:

```json
[
  {
    "name": "Nat.succ_le_succ",
    "formal_type": "∀ {n m : ℕ}, n ≤ m → Nat.succ n ≤ Nat.succ m",
    "doc": "Documentation string",
    "kind": "theorem"
  },
  {
    "name": "Another.theorem",
    "formal_type": "...",
    "doc": "...",
    "kind": "..."
  }
]
```

**Response Fields:**
- `name` (string): Full name of the theorem/definition
- `formal_type` (string, optional): The type signature
- `doc` (string, optional): Documentation string
- `kind` (string, optional): Kind of declaration

**Error Response:**
```json
{
  "error": "Error message",
  "schema": {
    "description": "Detailed error description"
  }
}
```

### Example cURL Command

```bash
curl -X GET \
  --user-agent "LeanSearchClient" \
  "https://premise-search.com/api/search?query=n%20%3A%20%E2%84%95%0A%E2%8A%A2%200%20%E2%89%A4%201&results=6&rev=v4.16.0"
```

### Environment Variable Override

```bash
export LEANSEARCHCLIENT_LEANSTATESEARCH_API_URL="https://your-custom-url.com/api/search"
```

### Authentication

No authentication required.

---

## 3. Loogle API

### Overview
Loogle provides pattern-based structural search over Mathlib4. It's hosted at https://loogle.lean-lang.org/.

### API Endpoint

**Base URL:** `https://loogle.lean-lang.org/json`

**Method:** `GET`

### Request Format

Query parameter in URL:
```
?q=<search-pattern>
```

**Parameters:**
- `q` (string, required): Search pattern (URL-encoded)

### Search Pattern Syntax

Loogle supports several search modes:

1. **By constant name:**
   ```
   Real.sin
   ```

2. **By lemma name substring:**
   ```
   "differ"
   ```

3. **By type pattern:**
   ```
   _ * (_ ^ _)
   List ?a → ?a
   (?a -> ?b) -> List ?a -> List ?b
   ```

4. **By conclusion pattern:**
   ```
   |- tsum _ = _ * tsum _
   |- _ < _ → tsum _ < tsum _
   ```

5. **Combined filters (comma-separated):**
   ```
   Real.sin, "two", tsum, _ * _, _ ^ _, |- _ < _ → _
   ```

### Request Headers

```
User-Agent: <your-user-agent>
```

### Response Format

**Success Response:**
```json
{
  "hits": [
    {
      "name": "List.head",
      "type": "List ?a → ?a",
      "doc": "Documentation string"
    },
    {
      "name": "List.getLast",
      "type": "List ?a → ?a",
      "doc": "..."
    }
  ]
}
```

**Empty Response:**
```json
{
  "hits": null
}
```

**Error Response:**
```json
{
  "error": "Error message",
  "suggestions": ["suggestion1", "suggestion2"]
}
```

**Response Fields:**
- `hits` (array or null): Array of matching results, or null if no results
  - `name` (string): Full name of the declaration
  - `type` (string): Type signature
  - `doc` (string, optional): Documentation string
- `error` (string, optional): Error message if query failed
- `suggestions` (array of strings, optional): Suggested corrections

### Example cURL Commands

```bash
# Search by type pattern
curl -X GET \
  --user-agent "LeanSearchClient" \
  "https://loogle.lean-lang.org/json?q=List%20%3Fa%20%E2%86%92%20%3Fa"

# Search by constant
curl -X GET \
  --user-agent "LeanSearchClient" \
  "https://loogle.lean-lang.org/json?q=Real.sin"

# Search by name substring
curl -X GET \
  --user-agent "LeanSearchClient" \
  "https://loogle.lean-lang.org/json?q=%22differ%22"
```

### Environment Variable Override

```bash
export LEANSEARCHCLIENT_LOOGLE_API_URL="https://your-custom-url.com/json"
```

### Authentication

No authentication required.

---

## Lean 4 Client Usage

### Installation

Add to your `lakefile.lean`:

```lean
require LeanSearchClient from git
  "https://github.com/leanprover-community/LeanSearchClient.git"
```

### Usage Examples

#### LeanSearch (Natural Language)

```lean
-- As a command
#leansearch "If a natural number n is less than m, then the successor of n is less than the successor of m."

-- As a term
example := #leansearch "theorem about successor and less than."

-- As a tactic
example : 3 ≤ 5 := by
  #leansearch "successor preserves less than or equal."
  sorry
```

#### LeanStateSearch (Goal-based)

```lean
example : 0 ≤ 1 := by
  #statesearch  -- Searches based on current goal state
  sorry
```

#### Loogle (Pattern-based)

```lean
-- As a command
#loogle List ?a → ?a

-- As a term
example := #loogle List ?a → ?a

-- As a tactic
example : 3 ≤ 5 := by
  #loogle Nat.succ_le_succ
  sorry
```

### Configuration Options

```lean
-- Number of results from LeanSearch
set_option leansearch.queries 10

-- Number of results from Loogle
set_option loogle.queries 10

-- Number of results from StateSearch
set_option statesearch.queries 10

-- StateSearch revision
set_option statesearch.revision "v4.16.0"

-- User agent
set_option leansearchclient.useragent "MyProject"

-- Default backend for #search command
set_option leansearchclient.backend "leansearch"
```

---

## Implementation Details

### Caching

The LeanSearchClient implements in-memory caching for all three services:

- **LeanSearch:** Caches by `(query, num_results)`
- **LeanStateSearch:** Caches by `(query, num_results, revision)`
- **Loogle:** Caches by `(query, num_results)`

Caches are stored in `IO.Ref` and persist for the duration of the Lean session.

### Result Processing

All three services return results that are converted to a common `SearchResult` structure:

```lean
structure SearchResult where
  name : String
  type? : Option String
  docString? : Option String
  doc_url? : Option String
  kind? : Option String
```

### Tactic Validation

When used in tactic mode, the client automatically filters results to show only valid tactics for the current goal by:

1. Parsing each suggestion as a tactic
2. Attempting to apply it to the current goal (without modifying state)
3. Only displaying suggestions that successfully apply

### TryThis Integration

All search commands integrate with Lean's TryThis system, providing clickable suggestions in the infoview that can be applied via code actions.

---

## Comparison of Services

| Feature | LeanSearch | LeanStateSearch | Loogle |
|---------|-----------|----------------|--------|
| **Search Type** | Natural language | Goal state | Type patterns |
| **Best For** | Describing what you want | Finding tactics for current goal | Structural queries |
| **Query Format** | Plain English | Auto-generated from goal | Lean syntax patterns |
| **Method** | POST | GET | GET |
| **Caching** | Yes | Yes | Yes |
| **Authentication** | None | None | None |
| **Tactic Mode** | Yes | Yes | Yes |

---

## Best Practices

1. **Query Formulation:**
   - LeanSearch: Use complete sentences ending with `.` or `?`
   - LeanStateSearch: Let the system extract the goal automatically
   - Loogle: Use precise type patterns with metavariables

2. **Result Limits:**
   - Start with default (6 results)
   - Increase if needed, but be mindful of performance

3. **User Agent:**
   - Set a descriptive user agent to help service maintainers
   - Include your project name if making automated requests

4. **Error Handling:**
   - All services may fail due to network issues
   - Implement appropriate error handling and fallbacks
   - Check for null/empty results

5. **Caching:**
   - Leverage the built-in caching for repeated queries
   - Cache persists only during Lean session

---

## Related Resources

- **LeanSearch Web Interface:** https://leansearch.net/
- **Loogle Web Interface:** https://loogle.lean-lang.org/
- **LeanSearchClient Repository:** https://github.com/leanprover-community/LeanSearchClient
- **Loogle Repository:** https://github.com/nomeata/loogle
- **Mathlib4 Documentation:** https://leanprover-community.github.io/mathlib4_docs/

---

## Notes and Limitations

1. **LeanSearch Response Structure:**
   - The double-nested array structure `[[results]]` is unusual but confirmed in the implementation
   - The outer array always contains exactly one element

2. **Name Formatting:**
   - LeanSearch returns names as arrays of strings that must be joined with `.`
   - Loogle and StateSearch return names as complete strings

3. **Empty Documentation:**
   - Documentation strings may be empty even for well-documented theorems
   - Filter empty strings when processing results

4. **Revision Compatibility:**
   - StateSearch requires specifying a Lean/Mathlib revision
   - Ensure the revision matches your project's dependencies

5. **Network Dependencies:**
   - All services require internet connectivity
   - Consider implementing offline fallbacks for critical workflows

6. **Service Availability:**
   - Services are community-maintained and may have downtime
   - No SLA guarantees

---

## Future Considerations

1. **Local Deployment:**
   - Consider running local instances for production use
   - Source code available for all services

2. **Custom Embeddings:**
   - LeanSearch could be extended with domain-specific embeddings
   - Useful for specialized mathematical domains

3. **Hybrid Search:**
   - Combine multiple services for better results
   - Use LeanSearch for discovery, Loogle for refinement

4. **Integration Opportunities:**
   - Proof automation systems
   - Interactive theorem proving assistants
   - Documentation generation tools
   - Learning resources and tutorials
