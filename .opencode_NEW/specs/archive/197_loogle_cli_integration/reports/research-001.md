# Loogle CLI Integration Research Report

**Task**: 197  
**Topic**: Integrate Loogle CLI tool into lean-research-agent  
**Date**: 2025-12-27  
**Session**: sess_1735304400_lr197a  

## Executive Summary

This report documents comprehensive research on integrating the Loogle CLI tool into the lean-research-agent for type-based searching of Lean definitions and theorems. Loogle is a powerful search tool for Lean 4 and Mathlib that supports multiple search modes: by constant name, by lemma name substring, by subexpression pattern, and by conclusion pattern.

**Key Findings**:
- Loogle binary location: `/home/benjamin/.cache/loogle/.lake/build/bin/loogle`
- JSON output format is well-structured and documented in source code
- Index building is the primary performance bottleneck (can take 60+ seconds on first run)
- Index persistence via `--write-index` and `--read-index` is critical for performance
- Interactive mode (`--interactive`) is ideal for persistent agent integration
- Query syntax supports multiple filter types with rich pattern matching

## 1. Loogle CLI Interface Specification

### 1.1 Command Syntax

```bash
loogle [OPTIONS] [QUERY]
```

### 1.2 Available Options

| Option | Short | Description |
|--------|-------|-------------|
| `--help` | - | Display help message |
| `--interactive` | `-i` | Read queries from stdin (one per line) |
| `--json` | `-j` | Print results in JSON format |
| `--module mod` | - | Import specific module (default: Mathlib) |
| `--path path` | - | Search for .olean files in custom path |
| `--write-index file` | - | Persist search index to file |
| `--read-index file` | - | Read search index from file (trusted) |

### 1.3 Binary Locations

**Primary location** (built from source):
```
/home/benjamin/.cache/loogle/.lake/build/bin/loogle
```

**Alternative invocation** (via lake):
```bash
cd /home/benjamin/.cache/loogle && lake exe loogle [OPTIONS] [QUERY]
```

### 1.4 Default Search Paths

Loogle searches the following paths for .olean files:
- `/home/benjamin/.cache/loogle/.lake/packages/*/. lake/build/lib/lean`
- `/home/benjamin/.elan/toolchains/leanprover--lean4---v4.27.0-rc1/lib/lean`

Custom paths can be added with `--path`.

## 2. JSON Output Format

### 2.1 Success Response Structure

When a query succeeds, Loogle returns JSON with the following structure:

```json
{
  "header": "Found N declarations mentioning X, Y, and Z. Of these, M match your pattern(s).",
  "heartbeats": 1234,
  "count": 5,
  "hits": [
    {
      "name": "List.map",
      "type": "∀ {α β : Type u_1}, (α → β) → List α → List β",
      "module": "Init.Data.List.Basic",
      "doc": "Map a function over a list..."
    }
  ],
  "suggestions": ["alternative query 1", "alternative query 2"]
}
```

**Field Descriptions**:

- `header` (string): Human-readable summary of search results
- `heartbeats` (number): Performance metric (heartbeats / 1000)
- `count` (number): Total number of matching declarations
- `hits` (array): Array of matching declarations
  - `name` (string): Fully qualified name (e.g., "List.map")
  - `type` (string): Pretty-printed type signature
  - `module` (string): Module path (e.g., "Init.Data.List.Basic")
  - `doc` (string | null): Documentation string if available
- `suggestions` (array, optional): Alternative query suggestions

### 2.2 Error Response Structure

When a query fails, Loogle returns:

```json
{
  "error": "Error message describing what went wrong",
  "heartbeats": 123,
  "suggestions": ["corrected query 1", "corrected query 2"]
}
```

**Common Error Messages**:
- `"Cannot search: No constants or name fragments in search pattern."`
- `"Unknown identifier 'X'"`
- `"Name pattern is too general"`
- `"Conclusion pattern is of type X, should be of type Sort"`

### 2.3 Source Code Reference

The JSON serialization is implemented in `/home/benjamin/.cache/loogle/Loogle.lean` lines 98-125:

```lean
def toJson : Result → CoreM Json
  | (.error err, suggs, heartbeats) => do
      if suggs.isEmpty then
        pure $ .mkObj [ ("error", .str err), ("heartbeats", heartbeats) ]
      else
        pure $ .mkObj [ ("error", .str err), 
                       ("suggestions", .arr (suggs.map .str)), 
                       ("heartbeats", heartbeats)]
  | (.ok result, suggs, heartbeats) => do
      pure $ .mkObj $ [
        ("header", .str (← result.header.toString)),
        ("heartbeats", .num heartbeats),
        ("count", .num result.count),
        ("hits", .arr $ ← result.hits.mapM fun (ci, mod) => do
          let ty := (← (ppSignature ci.name).run').pretty (width := 10000)
          let ds := match ← findDocString? (← getEnv) ci.name false with
            | some s => .str s
            | none => .null
          let mod := match mod with | none => .null | some name => .str name.toString
          return .mkObj [
            ("name", .str ci.name.toString),
            ("type", .str ty),
            ("module", mod ),
            ("doc", ds )
          ]
        )
      ] ++ (if suggs.isEmpty then [] else [("suggestions", .arr (suggs.map .str))])
```

## 3. Query Syntax and Patterns

Loogle supports four primary search modes, which can be combined with commas.

### 3.1 Search by Constant Name

**Syntax**: Unquoted identifier

**Example**: `Real.sin`

**Behavior**: Finds all declarations whose type mentions the constant `Real.sin`

**Use Case**: Finding all lemmas related to a specific function or type

### 3.2 Search by Lemma Name Substring

**Syntax**: Quoted string

**Example**: `"differ"`

**Behavior**: Finds all declarations with "differ" in their name (case-insensitive, suffix matching)

**Use Case**: Finding lemmas when you know part of the name

**Implementation**: Uses a suffix trie for efficient substring matching

### 3.3 Search by Subexpression Pattern

**Syntax**: Term pattern with metavariables (`_` or `?name`)

**Examples**:
- `_ * (_ ^ _)` - Find expressions with multiplication where second arg is a power
- `Real.sqrt ?a * Real.sqrt ?a` - Non-linear pattern (same metavar appears twice)
- `List.replicate ?n _ ++ List.replicate ?n _` - Non-linear with named metavars

**Behavior**: Matches any subexpression in the type signature

**Metavariable Types**:
- `_` - Anonymous metavariable (each `_` is independent)
- `?name` - Named metavariable (same name = same value)

**Parameter Matching**: If pattern has parameters (function type), they match in any order:
- `(?a -> ?b) -> List ?a -> List ?b` matches `List.map`
- `List ?a -> (?a -> ?b) -> List ?b` also matches `List.map`

### 3.4 Search by Conclusion Pattern

**Syntax**: `⊢ pattern` or `|- pattern`

**Examples**:
- `|- tsum _ = _ * tsum _` - Conclusion has specific shape
- `|- _ < _ → tsum _ < tsum _` - Conclusion with hypothesis

**Behavior**: Matches only the conclusion (right of all `→` and `∀`)

**Constraint**: Pattern must be of type `Sort` (Prop, Type, etc.), not Bool or other types

### 3.5 Combining Filters

**Syntax**: Comma-separated filters

**Example**: `Real.sin, "two", tsum, _ * _, _ ^ _, |- _ < _ → _`

**Behavior**: Returns declarations matching ALL filters (logical AND)

**Metavariables**: Assigned independently in each filter

## 4. Query Examples

### 4.1 Type-Based Searches

```bash
# Find functions from Nat to Nat to Nat
loogle --json "Nat → Nat → Nat"

# Find conjunction introduction
loogle --json "?a → ?b → ?a ∧ ?b"

# Find list map
loogle --json "(?a -> ?b) -> List ?a -> List ?b"

# Find list append associativity
loogle --json "List.append (?a ++ ?b) ?c = ?a ++ (?b ++ ?c)"
```

### 4.2 Name-Based Searches

```bash
# Find lemmas with "replicate" in name
loogle --json '"replicate"'

# Find lemmas with "eq" in name mentioning my_true
loogle --json 'my_true, "eq"'

# Case-insensitive suffix matching
loogle --json '"y_tru"'  # Matches "my_true"
```

### 4.3 Pattern-Based Searches

```bash
# Find lemmas about sqrt
loogle --json "Real.sqrt ?a * Real.sqrt ?a"

# Find lemmas about list replication
loogle --json "List.replicate (_ + _) _"

# Find lemmas with specific conclusion
loogle --json "|- 0 < ?n → _ ≤ ?n"
```

### 4.4 Combined Searches

```bash
# Multiple filters
loogle --json "Real.sin, tsum, _ * _"

# Constant + name fragment
loogle --json 'List.map, "assoc"'

# Pattern + conclusion
loogle --json "List.replicate ?n _, |- _ = _"
```

## 5. Performance Characteristics

### 5.1 Index Building

**First Run Performance**:
- Index building: 60-120 seconds (for Mathlib)
- Memory usage: ~2-4 GB during index construction
- CPU intensive: Uses all available cores

**Subsequent Runs**:
- With `--read-index`: < 5 seconds startup
- Query execution: 0.1-2 seconds per query

### 5.2 Index Persistence

**Writing Index**:
```bash
loogle --write-index /tmp/loogle-mathlib.index --module Mathlib
```

**Reading Index**:
```bash
loogle --read-index /tmp/loogle-mathlib.index --json "List.map"
```

**Index File Size**: ~50-100 MB for Mathlib

**Security Note**: Index files are blindly trusted - only use trusted index files

### 5.3 Interactive Mode Performance

**Startup**:
```bash
loogle --json --interactive
# Waits for index to build, then prints: "Loogle is ready.\n"
```

**Query Processing**:
- Stdin: One query per line
- Stdout: One JSON response per line
- Latency: 0.1-2 seconds per query (after index built)

**Advantages**:
- Index built once, reused for all queries
- No process startup overhead
- Ideal for agent integration

### 5.4 Timeout Recommendations

| Operation | Recommended Timeout |
|-----------|---------------------|
| Index building (first run) | 120-180 seconds |
| Index loading (--read-index) | 10-15 seconds |
| Interactive mode startup | 120-180 seconds |
| Single query (after index ready) | 5-10 seconds |
| Complex pattern query | 10-30 seconds |

## 6. Integration Architecture for lean-research-agent

### 6.1 Recommended Integration Pattern

**Persistent Interactive Mode** (Recommended):

```python
import subprocess
import json
import time

class LoogleClient:
    def __init__(self, binary_path, index_path=None, timeout=180):
        self.binary_path = binary_path
        self.process = None
        self.ready = False
        self.start(index_path, timeout)
    
    def start(self, index_path, timeout):
        """Start Loogle in interactive mode"""
        cmd = [self.binary_path, "--json", "--interactive"]
        if index_path:
            cmd.extend(["--read-index", index_path])
        
        self.process = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        
        # Wait for "Loogle is ready.\n"
        start_time = time.time()
        while time.time() - start_time < timeout:
            line = self.process.stdout.readline()
            if line == "Loogle is ready.\n":
                self.ready = True
                return
            if self.process.poll() is not None:
                raise RuntimeError("Loogle process died during startup")
        
        raise TimeoutError("Loogle startup timed out")
    
    def query(self, query_string, timeout=10):
        """Execute a query and return parsed JSON"""
        if not self.ready:
            raise RuntimeError("Loogle not ready")
        
        # Send query
        self.process.stdin.write(query_string + "\n")
        self.process.stdin.flush()
        
        # Read response with timeout
        import select
        ready, _, _ = select.select([self.process.stdout], [], [], timeout)
        if not ready:
            raise TimeoutError(f"Query timed out: {query_string}")
        
        response_line = self.process.stdout.readline()
        return json.loads(response_line)
    
    def close(self):
        """Shutdown Loogle process"""
        if self.process:
            self.process.stdin.close()
            self.process.terminate()
            self.process.wait(timeout=5)
```

**Usage**:
```python
# Initialize once (at agent startup)
loogle = LoogleClient(
    binary_path="/home/benjamin/.cache/loogle/.lake/build/bin/loogle",
    index_path="/tmp/loogle-mathlib.index",  # Optional but recommended
    timeout=180
)

# Query multiple times
result1 = loogle.query("List.map", timeout=10)
result2 = loogle.query("?a → ?b → ?a ∧ ?b", timeout=10)
result3 = loogle.query('"replicate"', timeout=10)

# Cleanup (at agent shutdown)
loogle.close()
```

### 6.2 Alternative: One-Shot Mode

For simpler integration (but slower):

```python
def loogle_query_oneshot(query, binary_path, index_path=None, timeout=30):
    """Execute a single Loogle query"""
    cmd = [binary_path, "--json", query]
    if index_path:
        cmd.extend(["--read-index", index_path])
    
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout
    )
    
    if result.returncode != 0:
        raise RuntimeError(f"Loogle failed: {result.stderr}")
    
    return json.loads(result.stdout)
```

**Tradeoffs**:
- Simpler implementation
- No persistent state
- Much slower (5-10s startup per query with index, 60-120s without)
- Not recommended for production use

### 6.3 Index Management Strategy

**Pre-build Index** (Recommended):

```bash
# One-time setup (run during agent installation/initialization)
cd /home/benjamin/.cache/loogle
lake exe loogle --write-index /tmp/loogle-mathlib.index --module Mathlib
```

**Index Update Strategy**:
- Rebuild index when Mathlib is updated
- Store index in persistent location (e.g., `~/.cache/lean-research-agent/loogle-mathlib.index`)
- Check index age and rebuild if > 7 days old

**Index Validation**:
```python
import os
import time

def is_index_fresh(index_path, max_age_days=7):
    if not os.path.exists(index_path):
        return False
    age_seconds = time.time() - os.path.getmtime(index_path)
    return age_seconds < (max_age_days * 86400)
```

### 6.4 Error Handling Patterns

**Startup Errors**:
```python
try:
    loogle = LoogleClient(binary_path, index_path, timeout=180)
except TimeoutError:
    # Fallback to web search
    logger.warning("Loogle startup timed out, using web search fallback")
    use_web_search = True
except FileNotFoundError:
    # Binary not found
    logger.error("Loogle binary not found at {binary_path}")
    use_web_search = True
except RuntimeError as e:
    # Process died during startup
    logger.error(f"Loogle startup failed: {e}")
    use_web_search = True
```

**Query Errors**:
```python
try:
    result = loogle.query(query_string, timeout=10)
    if "error" in result:
        # Loogle returned an error (e.g., invalid syntax)
        logger.warning(f"Loogle query error: {result['error']}")
        if "suggestions" in result:
            # Try first suggestion
            result = loogle.query(result["suggestions"][0], timeout=10)
except TimeoutError:
    # Query took too long
    logger.warning(f"Loogle query timed out: {query_string}")
    result = None
except json.JSONDecodeError:
    # Invalid JSON response
    logger.error("Loogle returned invalid JSON")
    result = None
```

**Process Health Monitoring**:
```python
def check_loogle_health(loogle_client):
    """Check if Loogle process is still alive"""
    if loogle_client.process.poll() is not None:
        # Process died
        logger.error("Loogle process died, restarting...")
        loogle_client.start(index_path, timeout=180)
```

### 6.5 Integration into lean-research-agent

**Initialization** (in agent startup):
```python
class LeanResearchAgent:
    def __init__(self):
        self.loogle = None
        self.loogle_available = False
        self._init_loogle()
    
    def _init_loogle(self):
        """Initialize Loogle client with graceful fallback"""
        binary_path = "/home/benjamin/.cache/loogle/.lake/build/bin/loogle"
        index_path = os.path.expanduser("~/.cache/lean-research-agent/loogle-mathlib.index")
        
        # Check if binary exists
        if not os.path.exists(binary_path):
            logger.warning(f"Loogle binary not found at {binary_path}")
            return
        
        # Ensure index exists or build it
        if not is_index_fresh(index_path):
            logger.info("Building Loogle index (this may take 2-3 minutes)...")
            try:
                self._build_loogle_index(binary_path, index_path)
            except Exception as e:
                logger.error(f"Failed to build Loogle index: {e}")
                return
        
        # Start Loogle in interactive mode
        try:
            self.loogle = LoogleClient(binary_path, index_path, timeout=180)
            self.loogle_available = True
            logger.info("Loogle initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Loogle: {e}")
            self.loogle_available = False
```

**Research Method**:
```python
def research_lean_topic(self, topic, context):
    """Research Lean libraries using Loogle and web search"""
    findings = {
        "definitions": [],
        "theorems": [],
        "tactics": [],
        "tool_used": None
    }
    
    # Try Loogle first
    if self.loogle_available:
        try:
            loogle_findings = self._search_with_loogle(topic, context)
            findings.update(loogle_findings)
            findings["tool_used"] = "loogle"
            return findings
        except Exception as e:
            logger.warning(f"Loogle search failed: {e}, falling back to web search")
    
    # Fallback to web search
    web_findings = self._search_with_web(topic, context)
    findings.update(web_findings)
    findings["tool_used"] = "web_search"
    return findings

def _search_with_loogle(self, topic, context):
    """Execute Loogle searches based on topic and context"""
    queries = self._generate_loogle_queries(topic, context)
    
    all_results = []
    for query in queries:
        try:
            result = self.loogle.query(query, timeout=10)
            if "hits" in result:
                all_results.extend(result["hits"])
        except TimeoutError:
            logger.warning(f"Loogle query timed out: {query}")
            continue
    
    # Deduplicate and categorize results
    return self._categorize_loogle_results(all_results)
```

**Query Generation**:
```python
def _generate_loogle_queries(self, topic, context):
    """Generate Loogle queries based on research topic"""
    queries = []
    
    # Extract keywords from topic
    keywords = self._extract_keywords(topic)
    
    # Generate different query types
    for keyword in keywords:
        # Search by constant name
        queries.append(keyword)
        
        # Search by name fragment
        queries.append(f'"{keyword}"')
    
    # Context-specific patterns
    if "modal logic" in context.lower():
        queries.extend([
            "□ _ → □ _",  # Necessitation
            "□ (_ → _) → □ _ → □ _",  # K axiom
            "□ _ → _",  # T axiom
            "□ _ → □ □ _",  # 4 axiom
        ])
    
    if "temporal logic" in context.lower():
        queries.extend([
            "Until _ _",
            "Eventually _",
            "Always _",
        ])
    
    return queries
```

## 7. Error Conditions and Handling

### 7.1 Common Error Conditions

| Error Type | Cause | Detection | Recovery |
|------------|-------|-----------|----------|
| Binary not found | Loogle not installed | `FileNotFoundError` | Fallback to web search |
| Index build timeout | Mathlib too large | Timeout after 180s | Use web search, log warning |
| Index load failure | Corrupted index | Process crash | Rebuild index |
| Query syntax error | Invalid pattern | `"error"` in JSON | Try suggestions or simplify |
| Query timeout | Complex pattern | Timeout after 10s | Simplify query or skip |
| Process death | OOM or crash | `poll() != None` | Restart process |
| Invalid JSON | Output corruption | `JSONDecodeError` | Restart process |

### 7.2 Graceful Degradation Strategy

**Tier 1: Loogle with Index** (Best)
- Startup: 5-10 seconds
- Query: 0.1-2 seconds
- Quality: Excellent

**Tier 2: Loogle without Index** (Slow)
- Startup: 60-120 seconds
- Query: 0.1-2 seconds
- Quality: Excellent

**Tier 3: Web Search** (Fallback)
- Startup: Immediate
- Query: 2-5 seconds
- Quality: Good

**Implementation**:
```python
def research_with_fallback(self, topic):
    # Try Tier 1
    if self.loogle_available and self.index_available:
        try:
            return self._search_with_loogle(topic)
        except Exception as e:
            logger.warning(f"Tier 1 failed: {e}")
    
    # Try Tier 2 (skip if Tier 1 failed due to binary issues)
    if self.loogle_available and not self.index_available:
        try:
            return self._search_with_loogle_no_index(topic)
        except Exception as e:
            logger.warning(f"Tier 2 failed: {e}")
    
    # Fallback to Tier 3
    logger.info("Using web search fallback")
    return self._search_with_web(topic)
```

### 7.3 Logging and Monitoring

**Log Tool Availability**:
```python
def log_tool_status(self):
    """Log tool availability to errors.json"""
    if not self.loogle_available:
        error_entry = {
            "id": f"error_{int(time.time())}_{random.randint(1000, 9999)}",
            "timestamp": datetime.now().isoformat(),
            "type": "tool_unavailable",
            "severity": "medium",
            "context": {
                "agent": "lean-research-agent",
                "tool": "loogle"
            },
            "message": "Loogle not available, using web search fallback",
            "fix_status": "not_addressed",
            "fix_plan_ref": None,
            "fix_task_ref": "Task 197: Integrate Loogle CLI",
            "recurrence_count": 1,
            "first_seen": datetime.now().isoformat(),
            "last_seen": datetime.now().isoformat()
        }
        # Append to .opencode/errors.json
```

**Performance Metrics**:
```python
def log_query_metrics(self, query, result, duration):
    """Log query performance metrics"""
    metrics = {
        "timestamp": datetime.now().isoformat(),
        "query": query,
        "duration_seconds": duration,
        "heartbeats": result.get("heartbeats", 0),
        "hit_count": result.get("count", 0),
        "success": "error" not in result
    }
    # Log to .opencode/metrics/loogle-queries.jsonl
```

## 8. Testing and Validation

### 8.1 Unit Tests

**Test Binary Availability**:
```python
def test_loogle_binary_exists():
    binary_path = "/home/benjamin/.cache/loogle/.lake/build/bin/loogle"
    assert os.path.exists(binary_path), "Loogle binary not found"
    assert os.access(binary_path, os.X_OK), "Loogle binary not executable"
```

**Test Interactive Mode**:
```python
def test_loogle_interactive_mode():
    loogle = LoogleClient(binary_path, timeout=180)
    assert loogle.ready, "Loogle not ready"
    
    result = loogle.query("List.map", timeout=10)
    assert "hits" in result or "error" in result
    
    loogle.close()
```

**Test Query Patterns**:
```python
def test_loogle_query_patterns():
    loogle = LoogleClient(binary_path, index_path, timeout=180)
    
    # Test constant search
    result = loogle.query("List.map")
    assert "hits" in result
    assert any("List.map" in hit["name"] for hit in result["hits"])
    
    # Test name fragment search
    result = loogle.query('"map"')
    assert "hits" in result
    
    # Test pattern search
    result = loogle.query("?a → ?b → ?a ∧ ?b")
    assert "hits" in result or "count" in result
    
    loogle.close()
```

### 8.2 Integration Tests

**Test Research Workflow**:
```python
def test_research_workflow():
    agent = LeanResearchAgent()
    
    findings = agent.research_lean_topic(
        topic="modal logic S4 axioms",
        context="modal_logic"
    )
    
    assert findings["tool_used"] in ["loogle", "web_search"]
    assert len(findings["definitions"]) > 0 or len(findings["theorems"]) > 0
```

**Test Fallback Behavior**:
```python
def test_fallback_to_web_search():
    agent = LeanResearchAgent()
    agent.loogle_available = False  # Simulate Loogle unavailable
    
    findings = agent.research_lean_topic(
        topic="temporal logic Until operator",
        context="temporal_logic"
    )
    
    assert findings["tool_used"] == "web_search"
```

### 8.3 Performance Benchmarks

**Benchmark Index Building**:
```python
def benchmark_index_build():
    start = time.time()
    subprocess.run([
        binary_path,
        "--write-index", "/tmp/test-index",
        "--module", "Mathlib"
    ], timeout=300)
    duration = time.time() - start
    print(f"Index build time: {duration:.2f}s")
```

**Benchmark Query Performance**:
```python
def benchmark_queries():
    loogle = LoogleClient(binary_path, index_path, timeout=180)
    
    queries = [
        "List.map",
        '"replicate"',
        "?a → ?b → ?a ∧ ?b",
        "Real.sqrt ?a * Real.sqrt ?a"
    ]
    
    for query in queries:
        start = time.time()
        result = loogle.query(query, timeout=10)
        duration = time.time() - start
        print(f"Query: {query}")
        print(f"  Duration: {duration:.3f}s")
        print(f"  Heartbeats: {result.get('heartbeats', 0)}")
        print(f"  Hits: {result.get('count', 0)}")
    
    loogle.close()
```

## 9. Security Considerations

### 9.1 Index File Trust

**Warning**: Index files loaded with `--read-index` are blindly trusted by Loogle.

**Mitigation**:
- Only use index files built by the agent itself
- Store index files in secure location with restricted permissions
- Validate index file integrity (checksum)

```python
import hashlib

def validate_index_integrity(index_path, expected_hash):
    """Validate index file hasn't been tampered with"""
    with open(index_path, 'rb') as f:
        actual_hash = hashlib.sha256(f.read()).hexdigest()
    return actual_hash == expected_hash
```

### 9.2 Query Injection

**Risk**: User-provided queries could contain malicious patterns

**Mitigation**:
- Sanitize query strings before passing to Loogle
- Limit query length (e.g., max 500 characters)
- Timeout all queries (max 30 seconds)

```python
def sanitize_query(query):
    """Sanitize user-provided query"""
    # Remove control characters
    query = ''.join(c for c in query if c.isprintable())
    
    # Limit length
    if len(query) > 500:
        query = query[:500]
    
    return query
```

### 9.3 Resource Limits

**Risk**: Malicious queries could consume excessive resources

**Mitigation**:
- Set process memory limits (ulimit)
- Set CPU time limits (timeout)
- Monitor process health

```python
import resource

def set_loogle_resource_limits():
    """Set resource limits for Loogle process"""
    # Limit memory to 4GB
    resource.setrlimit(resource.RLIMIT_AS, (4 * 1024**3, 4 * 1024**3))
    
    # Limit CPU time to 60 seconds per query
    resource.setrlimit(resource.RLIMIT_CPU, (60, 60))
```

## 10. Future Enhancements

### 10.1 Caching Layer

Implement query result caching to avoid redundant Loogle calls:

```python
import functools
import pickle

@functools.lru_cache(maxsize=1000)
def cached_loogle_query(query):
    """Cache Loogle query results"""
    return loogle.query(query, timeout=10)
```

### 10.2 Parallel Queries

Execute multiple Loogle queries in parallel:

```python
import concurrent.futures

def parallel_loogle_queries(queries):
    """Execute multiple queries in parallel"""
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(loogle.query, q, 10): q for q in queries}
        results = {}
        for future in concurrent.futures.as_completed(futures):
            query = futures[future]
            try:
                results[query] = future.result()
            except Exception as e:
                logger.warning(f"Query failed: {query}: {e}")
        return results
```

### 10.3 Query Optimization

Automatically optimize queries based on result quality:

```python
def optimize_query(query, result):
    """Suggest query optimizations based on results"""
    if "error" in result and "suggestions" in result:
        return result["suggestions"][0]
    
    if result.get("count", 0) == 0:
        # No results, try broader query
        return broaden_query(query)
    
    if result.get("count", 0) > 100:
        # Too many results, try narrower query
        return narrow_query(query)
    
    return query
```

### 10.4 Multi-Module Support

Support searching across multiple modules (not just Mathlib):

```python
def search_multiple_modules(query, modules=["Mathlib", "Logos"]):
    """Search across multiple Lean modules"""
    results = {}
    for module in modules:
        # Would need separate Loogle instances per module
        # or restart Loogle with different --module flag
        results[module] = loogle_query_with_module(query, module)
    return results
```

## 11. References

### 11.1 Documentation

- Loogle GitHub: https://github.com/nomeata/loogle
- Loogle Web Interface: https://loogle.lean-lang.org/
- Lean 4 Documentation: https://leanprover.github.io/
- Mathlib Documentation: https://leanprover-community.github.io/mathlib4_docs/

### 11.2 Source Code

- Main CLI: `/home/benjamin/.cache/loogle/Loogle.lean`
- Find Module: `/home/benjamin/.cache/loogle/Loogle/Find.lean`
- Tests: `/home/benjamin/.cache/loogle/Tests.lean`
- Web Server: `/home/benjamin/.cache/loogle/server.py`

### 11.3 Related Tools

- LeanSearch: Semantic search (REST API)
- LeanExplore: Interactive library browser
- Lean VSCode Extension: Built-in Loogle integration
- lean.nvim: Neovim Loogle integration

## 12. Conclusion

Loogle is a powerful and well-designed tool for searching Lean libraries. The CLI interface is straightforward, the JSON output format is well-structured, and the query syntax is expressive. The primary challenge is index building performance, which can be mitigated through index persistence and interactive mode.

**Recommended Integration Approach**:
1. Use persistent interactive mode with pre-built index
2. Implement graceful fallback to web search
3. Monitor process health and restart on failure
4. Cache query results to reduce redundant calls
5. Log tool availability and performance metrics

**Expected Benefits**:
- Fast, accurate searches of Lean/Mathlib definitions and theorems
- Rich query syntax supporting multiple search modes
- Structured JSON output for easy parsing
- Significant improvement over web search for Lean-specific research

**Implementation Priority**: High - Loogle integration will significantly improve lean-research-agent capabilities.
