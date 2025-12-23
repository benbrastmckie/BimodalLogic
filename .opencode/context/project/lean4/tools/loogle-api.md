# Loogle API Integration Guide

**Purpose**: Guide for integrating with Loogle formal search API

**Last Updated**: December 16, 2025

---

## Overview

Loogle is a type-based search engine for LEAN libraries (primarily Mathlib). It allows searching by type signatures, patterns, and names to find relevant theorems and definitions.

**API Endpoint**: `https://loogle.lean-lang.org/api/search`

---

## Query Types

### 1. By Constant

Search for theorems mentioning a specific constant:

```
Query: Real.sin
Example Results:
  - Real.sin_zero : Real.sin 0 = 0
  - Real.sin_pi : Real.sin π = 0
  - Real.continuous_sin : Continuous Real.sin
```

### 2. By Name Substring

Search for definitions/theorems with name containing substring:

```
Query: "differ"
Example Results:
  - Differentiable
  - DifferentiableAt
  - DifferentiableOn
  - HasDerivAt
```

**Note**: Use quotes for substring search

### 3. By Type Pattern

Search for theorems with specific type structure:

```
Query: _ * (_ ^ _)
Example Results:
  - mul_pow : ∀ (a b : R) (n : ℕ), (a * b) ^ n = a ^ n * b ^ n
  - pow_mul : ∀ (a : R) (m n : ℕ), a ^ (m * n) = (a ^ m) ^ n
```

**Wildcards**:
- `_` : Match any term
- `?n` : Match any term and bind to variable n

### 4. By Conclusion

Search for theorems with specific conclusion:

```
Query: |- tsum _ = _ * tsum _
Example Results:
  - tsum_mul_left : tsum (fun i => c * f i) = c * tsum f
  - tsum_mul_right : tsum (fun i => f i * c) = tsum f * c
```

**Note**: Use `|-` to specify conclusion pattern

### 5. Combined Queries

Combine multiple filters with AND logic:

```
Query: Real.sin, _ + _
Example Results:
  - Real.sin_add : Real.sin (x + y) = Real.sin x * Real.cos y + Real.cos x * Real.sin y
```

---

## API Specification

### HTTP Request

```http
GET https://loogle.lean-lang.org/api/search?q={query}
```

**Parameters**:
- `q` (required): URL-encoded query string

**Headers**:
```http
Accept: application/json
User-Agent: LEAN4-ProofChecker/1.0
```

### HTTP Response

**Success (200 OK)**:
```json
{
  "results": [
    {
      "name": "Real.sin_zero",
      "type": "Real.sin 0 = 0",
      "module": "Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic",
      "docstring": "The sine of zero is zero"
    },
    {
      "name": "Real.sin_pi",
      "type": "Real.sin π = 0",
      "module": "Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic",
      "docstring": "The sine of pi is zero"
    }
  ],
  "count": 2,
  "query": "Real.sin"
}
```

**Error (4xx/5xx)**:
```json
{
  "error": "Invalid query syntax",
  "code": "INVALID_QUERY",
  "details": "Expected type pattern, got invalid syntax"
}
```

---

## Integration Pattern

### Request Function

```yaml
loogle_search:
  inputs:
    query: string
    timeout: duration (default: 3s)
    retry: boolean (default: true)
    
  process:
    1. URL-encode query
    2. Construct request URL
    3. Send GET request with timeout
    4. Parse JSON response
    5. Normalize results
    6. Return structured data
    
  error_handling:
    timeout: "Retry once, then return cached or empty"
    4xx_error: "Log and return empty results"
    5xx_error: "Retry once, then return cached or empty"
    network_error: "Return cached results or empty"
    
  output:
    status: enum ["success", "partial", "cached", "error"]
    results: array[LoogleResult]
    metadata:
      query: string
      search_time_ms: integer
      source: enum ["loogle", "cache"]
```

### Result Normalization

```yaml
normalize_result:
  input: raw_loogle_result
  
  process:
    1. Extract name, type, module, docstring
    2. Parse type signature
    3. Extract type components
    4. Generate usage example
    5. Compute relevance score
    
  output:
    name: string
    type: string
    type_components:
      parameters: array[string]
      conclusion: string
    module: string
    docstring: string
    usage_example: string
    relevance_score: float [0.0, 1.0]
```

---

## Caching Strategy

### Cache Key

```yaml
cache_key:
  format: "loogle:{query_hash}"
  example: "loogle:abc123def456"
```

### Cache Entry

```yaml
cache_entry:
  key: string
  query: string
  results: array[LoogleResult]
  timestamp: datetime
  ttl: 24h
  access_count: integer
```

### Cache Policy

```yaml
caching:
  ttl: 24h
  max_entries: 500
  eviction: "LRU"
  invalidation:
    - Manual invalidation
    - Mathlib version update
    - TTL expiration
```

---

## Error Handling

### Error Types

```yaml
errors:
  timeout:
    http_code: null
    action: "Retry once with same timeout"
    fallback: "Use cached results or return empty"
    
  invalid_query:
    http_code: 400
    action: "Log error and return empty"
    fallback: "Suggest query correction"
    
  service_unavailable:
    http_code: 503
    action: "Return cached results"
    fallback: "Use local search or LeanSearch"
    
  rate_limited:
    http_code: 429
    action: "Wait and retry with backoff"
    fallback: "Use cached results"
    
  network_error:
    http_code: null
    action: "Retry once"
    fallback: "Use cached results or return empty"
```

### Fallback Chain

```yaml
fallback_chain:
  1. Try Loogle API
  2. If fails, check cache
  3. If no cache, try LeanSearch
  4. If fails, use local search
  5. If fails, return empty with error
```

---

## Query Optimization

### Query Simplification

```yaml
simplification:
  remove_redundant_wildcards:
    before: "_ + _ + _"
    after: "_ + _"
    
  normalize_spacing:
    before: "_  +  _"
    after: "_ + _"
    
  remove_duplicate_filters:
    before: "Real.sin, Real.sin"
    after: "Real.sin"
```

### Query Expansion

```yaml
expansion:
  synonyms:
    "addition": ["_ + _", "Add", "HAdd"]
    "multiplication": ["_ * _", "Mul", "HMul"]
    "equality": ["_ = _", "Eq"]
    
  related_constants:
    "Real.sin": ["Real.cos", "Real.tan", "Complex.sin"]
    "List.map": ["List.filter", "List.foldl", "Array.map"]
```

---

## Performance Optimization

### Request Batching

```yaml
batching:
  strategy: "Batch multiple queries"
  batch_size: 5
  batch_timeout: 100ms
  implementation:
    - Collect queries for 100ms
    - Send all queries in parallel
    - Combine results
```

### Result Ranking

```yaml
ranking:
  factors:
    name_similarity:
      weight: 0.3
      method: "Levenshtein distance"
      
    type_similarity:
      weight: 0.4
      method: "Type structure matching"
      
    module_relevance:
      weight: 0.2
      method: "Module popularity"
      
    usage_frequency:
      weight: 0.1
      method: "Historical usage data"
      
  formula: "weighted_sum(factors)"
```

---

## Best Practices

### Query Construction

1. **Be Specific**: Use specific constants when possible
2. **Use Patterns**: Use type patterns for structural search
3. **Combine Filters**: Combine multiple filters for precision
4. **Avoid Over-Wildcarding**: Too many wildcards reduce precision

### Caching

1. **Cache Aggressively**: Cache all successful queries
2. **Long TTL**: Use 24h TTL for stable results
3. **Invalidate on Update**: Invalidate when Mathlib updates
4. **Monitor Hit Rate**: Track and optimize cache hit rate

### Error Handling

1. **Always Timeout**: Set reasonable timeout (3s)
2. **Retry Once**: Retry failed requests once
3. **Use Fallbacks**: Have fallback chain ready
4. **Log Errors**: Log all errors for monitoring

### Performance

1. **Batch Queries**: Batch multiple queries when possible
2. **Parallel Requests**: Send multiple queries in parallel
3. **Limit Results**: Request only needed number of results
4. **Rank Results**: Rank by relevance to reduce noise

---

## Example Queries

### Find Theorems About Ring Homomorphisms

```
Query: RingHom, _ * _
Results:
  - RingHom.map_mul : f (x * y) = f x * f y
  - RingHom.map_one : f 1 = 1
  - RingHom.map_pow : f (x ^ n) = f x ^ n
```

### Find Theorems About List Length

```
Query: List.length, _ + _
Results:
  - List.length_append : (l₁ ++ l₂).length = l₁.length + l₂.length
  - List.length_cons : (x :: l).length = l.length + 1
```

### Find Continuous Functions

```
Query: Continuous, Real
Results:
  - continuous_sin : Continuous Real.sin
  - continuous_cos : Continuous Real.cos
  - continuous_exp : Continuous Real.exp
```

---

## Integration Checklist

- [ ] Implement HTTP GET request with timeout
- [ ] Parse JSON response correctly
- [ ] Normalize results to standard format
- [ ] Implement caching with 24h TTL
- [ ] Handle all error types gracefully
- [ ] Implement fallback chain
- [ ] Add query optimization (simplification, expansion)
- [ ] Add result ranking
- [ ] Test with various query types
- [ ] Test with service unavailable
- [ ] Test with timeout
- [ ] Measure and optimize cache hit rate
- [ ] Monitor API usage and rate limits

---

## References

- [Loogle Website](https://loogle.lean-lang.org/)
- [Loogle Documentation](https://loogle.lean-lang.org/about)
- [Mathlib Documentation](https://leanprover-community.github.io/mathlib4_docs/)
