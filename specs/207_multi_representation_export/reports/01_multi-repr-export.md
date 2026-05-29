# Research Report: Multi-Representation Formula Export (Task 207)

**Session**: sess_1780086634_783b73
**Task**: 207 - Multi-representation formula export
**Task Type**: lean4
**Dependencies**: Task 203 (completed)

---

## 1. Current Export Infrastructure

### 1.1 DatasetExport.lean (JSONL pipeline)

The primary export pipeline lives in `Theories/Bimodal/Automation/DatasetExport.lean`. It is compiled as `lake exe dataset_generator` (root module for `lean_exe` target).

**Current JSONL record structure** (`DatasetRecord`):

| Field | Type | Source |
|-------|------|--------|
| `id` | `String` | Sequential `"bmlogic-NNNNN"` |
| `split` | `String` | Deterministic hash-based `train`/`val`/`test` |
| `formula_str` | `String` | `Formula.prettyPrint` (human-readable) |
| `formula_ast` | `String` | `Formula.toJson` (recursive JSON AST) |
| `frame_class` | `String` | Always `"Base"` |
| `label` | `FormulaLabel` | `valid`/`invalid`/`timeout` |
| `proof_trace` | `Option ProofTrace` | Height, axiom names, rule names |
| `countermodel` | `Option SimpleCountermodel` | True/false atoms |
| `pattern_key` | `PatternKey` | 5 numeric features + topOperator |
| `metrics` | `DifficultyMetrics` | complexity, depths, timing, tier |
| `augmentation` | `Option AugmentationInfo` | Temporal dual info |

**Key observation**: The `pattern_key` field is **already exported** via `PatternKey.toJson`. The task description mentions adding PatternKey export, but this is already present. The task should focus on the two genuinely missing representations: S-expression and token list.

### 1.2 DataExport.lean (serialization primitives)

`Theories/Bimodal/Automation/DataExport.lean` provides the foundational serialization:

- `Formula.toJson` -- Recursive JSON AST with `tag` field discriminator
- `Formula.prettyPrint` -- Human-readable unicode notation
- `PatternKey.toJson` -- 5-field JSON object
- `SimpleCountermodel.toJson` -- Atom lists + formula
- `escapeJsonString` / `listToJsonArray` -- JSON helpers
- `RuleProfile` / `walkDerivationTree` -- Proof metrics

### 1.3 DatasetExporter.lean (structured JSON pipeline)

A second export pipeline in `DatasetExporter.lean` produces a single JSON file (not JSONL) with `metadata` + `formulas` array. Uses `LabeledFormula.toJson` which has a slightly different schema from `DatasetRecord`. This is a parallel export path, not the primary JSONL target.

### 1.4 Conversion Flow

```
Formula
  |
  +---> prettyPrint     --> formula_str  (String)
  +---> toJson          --> formula_ast  (JSON AST String)
  +---> PatternKey.fromFormula --> pattern_key (JSON Object String)
```

The `labeledToRecord` function (line 224) constructs `DatasetRecord` from `LabeledFormula`, calling `lf.formula.prettyPrint` and `lf.formula.toJson`.

---

## 2. Formula Type Analysis

The `Formula` inductive type has 6 primitive constructors:

```lean
inductive Formula : Type where
  | atom : Atom → Formula        -- Propositional variable
  | bot : Formula                -- Bottom (falsum)
  | imp : Formula → Formula → Formula  -- Implication
  | box : Formula → Formula      -- Modal necessity
  | untl : Formula → Formula → Formula -- Until (temporal)
  | snce : Formula → Formula → Formula -- Since (temporal)
```

Derived operators (defined as `def`, not constructors):
- `neg` = `imp _ bot`
- `top` = `imp bot bot`
- `and` = `neg (imp _ (neg _))`
- `or` = `imp (neg _) _`
- `diamond` = `neg (box (neg _))`
- `some_future` = `untl _ top`
- `some_past` = `snce _ top`
- `all_future` = `neg (some_future (neg _))`
- `all_past` = `neg (some_past (neg _))`
- `always` = `and (all_past _) (and _ (all_future _))`
- `sometimes` = `neg (always (neg _))`
- `next` = `untl _ bot`
- `prev` = `snce _ bot`

**Atoms** are structured: `{ base : String, fresh_index : Option Nat }`.

---

## 3. S-Expression Representation

### 3.1 Design

S-expressions provide a canonical, parenthesized text format widely used in theorem provers (Coq `Sexp`, SMT-LIB, ACL2). For bimodal formulas:

```
(atom "p")
bot
(imp (atom "p") (atom "q"))
(box (atom "p"))
(untl (atom "p") (atom "q"))
(snce (atom "p") (atom "q"))
```

### 3.2 Implementation

A simple recursive function on `Formula`:

```lean
def Formula.toSExpr : Formula → String
  | .atom a   => "(atom \"" ++ escapeJsonString a.base ++ "\")"
  | .bot      => "bot"
  | .imp φ ψ  => "(imp " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .box φ    => "(box " ++ φ.toSExpr ++ ")"
  | .untl φ ψ => "(untl " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .snce φ ψ => "(snce " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
```

**Fresh index handling**: Include `fresh_index` when present:
```lean
  | .atom a   =>
    let idx := match a.fresh_index with
      | none => ""
      | some n => " " ++ toString n
    "(atom \"" ++ escapeJsonString a.base ++ "\"" ++ idx ++ ")"
```

### 3.3 Design Choices

- Use constructor names as S-expression heads (matches the `Formula` inductive exactly)
- Atoms include the base string quoted (to handle special characters)
- Binary operators list children positionally (left then right)
- No derived operator detection -- always serialize the primitive form
- This matches the existing `Formula.toJson` strategy of working on primitives only

---

## 4. Token List Representation

### 4.1 Design for Transformer Consumption

Transformers process sequential token lists. The tokenization should produce a fixed vocabulary of symbolic tokens (no BPE/subword -- these are structured symbolic expressions, not natural language).

**Proposed token vocabulary** (15 tokens):

| Token ID | Token | Description |
|----------|-------|-------------|
| 0 | `<PAD>` | Padding token |
| 1 | `<BOS>` | Beginning of sequence |
| 2 | `<EOS>` | End of sequence |
| 3 | `ATOM` | Atom marker |
| 4 | `BOT` | Bottom |
| 5 | `IMP` | Implication |
| 6 | `BOX` | Modal necessity |
| 7 | `UNTL` | Until |
| 8 | `SNCE` | Since |
| 9 | `LPAREN` | Left parenthesis |
| 10 | `RPAREN` | Right parenthesis |
| 11-N | `a_p`, `a_q`, `a_r`, ... | Individual atom names |

### 4.2 Tokenization Strategy

Use **prefix notation** (Polish notation) which is unambiguous without parentheses and produces shorter sequences:

```
IMP ATOM p ATOM q        -- p → q
BOX ATOM p               -- □p
UNTL ATOM p ATOM q       -- U(p, q)
IMP BOX ATOM p ATOM p    -- □p → p
```

This is essentially the S-expression without parentheses -- prefix notation is naturally unambiguous for fixed-arity operators.

### 4.3 Implementation

```lean
def Formula.tokenize : Formula → List String
  | .atom a   => ["ATOM", a.base]
  | .bot      => ["BOT"]
  | .imp φ ψ  => "IMP" :: (φ.tokenize ++ ψ.tokenize)
  | .box φ    => "BOX" :: φ.tokenize
  | .untl φ ψ => "UNTL" :: (φ.tokenize ++ ψ.tokenize)
  | .snce φ ψ => "SNCE" :: (φ.tokenize ++ ψ.tokenize)
```

The token list is serialized as a JSON array of strings in the JSONL record.

### 4.4 Vocabulary Map Export

Add a `tokenVocab` definition that maps token strings to integer IDs. This can be exported as a companion JSON file or included in metadata. The vocabulary is static (determined by the `Formula` type and the atom pool used).

```lean
def tokenToId : String → Nat
  | "PAD" => 0 | "BOS" => 1 | "EOS" => 2
  | "ATOM" => 3 | "BOT" => 4 | "IMP" => 5
  | "BOX" => 6 | "UNTL" => 7 | "SNCE" => 8
  | s => 9 + atomIndex s  -- atom names get dynamic IDs
```

### 4.5 Sequence Length Considerations

For the current formula bounds (max complexity 5, max modal/temporal depth 2), token sequences will be short (typically 3-15 tokens). For larger formulas (complexity 12), sequences could reach ~30-50 tokens. This is well within typical transformer context lengths.

---

## 5. AST Tree for GNN Models

### 5.1 Current AST (formula_ast)

The existing `Formula.toJson` already produces a nested JSON tree:

```json
{"tag": "imp", "left": {"tag": "box", "child": {"tag": "atom", "name": "p"}}, "right": {"tag": "atom", "name": "p"}}
```

This is a valid tree structure for GNNs that can handle nested JSON. However, many GNN frameworks prefer an **adjacency list** representation with explicit node IDs.

### 5.2 Adjacency List Format for GNNs

A flat representation with node list + edge list:

```json
{
  "nodes": [
    {"id": 0, "type": "imp"},
    {"id": 1, "type": "box"},
    {"id": 2, "type": "atom", "name": "p"},
    {"id": 3, "type": "atom", "name": "p"}
  ],
  "edges": [
    {"src": 0, "dst": 1, "rel": "left"},
    {"src": 0, "dst": 3, "rel": "right"},
    {"src": 1, "dst": 2, "rel": "child"}
  ]
}
```

### 5.3 Implementation

This requires a stateful tree traversal to assign node IDs:

```lean
structure GNNNode where
  id : Nat
  nodeType : String
  atomName : Option String  -- Only for atom nodes
  deriving Repr

structure GNNEdge where
  src : Nat
  dst : Nat
  rel : String  -- "left", "right", "child", "event", "guard"
  deriving Repr

structure GNNGraph where
  nodes : List GNNNode
  edges : List GNNEdge
  deriving Repr

def Formula.toGNNGraph (φ : Formula) : GNNGraph :=
  let (_, nodes, edges) := go φ 0
  { nodes := nodes.reverse, edges := edges.reverse }
where
  go (φ : Formula) (nextId : Nat) : (Nat × List GNNNode × List GNNEdge) :=
    match φ with
    | .atom a =>
      let node := { id := nextId, nodeType := "atom", atomName := some a.base }
      (nextId + 1, [node], [])
    | .bot =>
      let node := { id := nextId, nodeType := "bot", atomName := none }
      (nextId + 1, [node], [])
    | .imp l r =>
      let myId := nextId
      let node := { id := myId, nodeType := "imp", atomName := none }
      let (nextId', lNodes, lEdges) := go l (nextId + 1)
      let (nextId'', rNodes, rEdges) := go r nextId'
      let leftEdge := { src := myId, dst := nextId + 1, rel := "left" }
      let rightEdge := { src := myId, dst := nextId', rel := "right" }
      (nextId'', node :: lNodes ++ rNodes,
       leftEdge :: rightEdge :: lEdges ++ rEdges)
    -- similar for box (child), untl (event/guard), snce (event/guard)
    ...
```

### 5.4 Assessment

The existing nested `formula_ast` is already usable for GNNs via Python-side flattening. Adding the adjacency list format is useful but lower priority than S-expression and tokenization, since it requires more implementation effort (stateful traversal) and the nested format is easily convertible in Python.

**Recommendation**: Implement the adjacency list format but consider it Phase 2 if time is constrained. The nested JSON AST already covers GNN needs with minimal Python preprocessing.

---

## 6. PatternKey Features

### 6.1 Current State

`PatternKey` (in `SuccessPatterns.lean`) contains 5 fields:

```lean
structure PatternKey where
  modalDepth : Nat         -- Modal nesting depth
  temporalDepth : Nat      -- Temporal nesting depth
  impCount : Nat           -- Number of implication operators
  complexity : Nat         -- Total connective count + 1
  topOperator : GoalCategory -- Top-level operator category
```

`PatternKey.fromFormula` computes all 5 fields from a `Formula`.

### 6.2 Existing Export

`PatternKey.toJson` already serializes this as:
```json
{"modalDepth": 1, "temporalDepth": 0, "impCount": 1, "complexity": 3, "topOperator": "Implication"}
```

### 6.3 What the Task Actually Needs

The `pattern_key` field is **already present** in `DatasetRecord` and exported in the JSONL. The task description's mention of "PatternKey numeric features (for value estimator)" is asking to export these as a **flat numeric vector** suitable for direct input to a neural value estimator:

```json
"pattern_features": [1, 0, 1, 3, 2]
```

Where the last element maps `GoalCategory` to a numeric ID:
- `Atom` = 0, `Bottom` = 1, `Implication` = 2, `Box` = 3,
  `AllPast` = 4, `AllFuture` = 5, `Until` = 6, `Since` = 7

### 6.4 Implementation

```lean
def GoalCategory.toNat : GoalCategory → Nat
  | .Atom => 0 | .Bottom => 1 | .Implication => 2 | .Box => 3
  | .AllPast => 4 | .AllFuture => 5 | .Until => 6 | .Since => 7

def PatternKey.toFeatureVector (pk : PatternKey) : List Nat :=
  [pk.modalDepth, pk.temporalDepth, pk.impCount, pk.complexity, pk.topOperator.toNat]

def PatternKey.featureVectorToJson (pk : PatternKey) : String :=
  listToJsonArray (pk.toFeatureVector.map toString)
```

---

## 7. Implementation Plan

### 7.1 New Fields in DatasetRecord

Add three new fields:

| Field | Type | Source |
|-------|------|--------|
| `formula_sexpr` | `String` | `Formula.toSExpr` |
| `formula_tokens` | `String` | `Formula.tokenize` serialized as JSON array |
| `pattern_features` | `String` | `PatternKey.toFeatureVector` as JSON array |

### 7.2 File Organization

All new serialization functions should be added to **`DataExport.lean`**, which is the existing home for Formula serialization primitives. This keeps the serialization layer cohesive.

The `DatasetRecord` structure and `datasetRecordToJson` in **`DatasetExport.lean`** need updating to include the new fields.

### 7.3 Implementation Phases

**Phase 1: S-expression printer** (DataExport.lean)
- Add `Formula.toSExpr : Formula -> String`
- Simple recursive function, ~10 lines
- No dependencies beyond existing imports

**Phase 2: Tokenizer** (DataExport.lean)
- Add `Formula.tokenize : Formula -> List String`
- Add `tokenListToJson : List String -> String` helper
- Simple recursive function, ~15 lines

**Phase 3: Pattern feature vector** (DataExport.lean)
- Add `GoalCategory.toNat : GoalCategory -> Nat`
- Add `PatternKey.toFeatureVector : PatternKey -> List Nat`
- Add `PatternKey.featureVectorToJson : PatternKey -> String`
- ~10 lines total

**Phase 4: DatasetRecord integration** (DatasetExport.lean)
- Add `formula_sexpr`, `formula_tokens`, `pattern_features` fields to `DatasetRecord`
- Update `labeledToRecord` to compute new fields
- Update `datasetRecordToJson` to serialize new fields
- Update `Inhabited DatasetRecord` instance
- ~20 lines of changes

**Phase 5: Adjacency list GNN format** (DataExport.lean) -- optional/stretch
- Add `GNNNode`, `GNNEdge`, `GNNGraph` structures
- Add `Formula.toGNNGraph` with stateful traversal
- Add JSON serialization for GNN graph
- Add `formula_graph` field to DatasetRecord
- ~60 lines

**Phase 6: Metadata updates** (DatasetExport.lean)
- Update vocabulary metadata to include token vocabulary
- Add `"representations"` field to metadata listing available formats
- ~15 lines

### 7.4 Estimated Effort

- Phases 1-4: ~3-4 hours (core deliverable)
- Phase 5: ~2 hours (optional GNN adjacency list)
- Phase 6: ~1 hour (metadata)
- Total: 4-7 hours (within the 6-8 hour estimate)

### 7.5 Performance Considerations

All new serialization functions are:
- Pure (no IO) except where they feed into the export pipeline
- O(n) in formula size (single tree traversal each)
- String concatenation based (matches existing pattern)

The multi-representation approach adds ~3x serialization cost per formula, but since serialization is negligible compared to the decision procedure (which dominates runtime), this has no practical performance impact.

### 7.6 Testing Strategy

- Build verification: `lake build Bimodal.Automation.DatasetExport`
- Functional test: Run `lake exe dataset_generator -- --max-complexity 3 --max-formulas 10 --output /tmp/test.jsonl` and verify the new fields appear correctly in the JSONL output
- Verify S-expression round-trip readability
- Verify token sequences are valid prefix notation
- Verify feature vector lengths are consistent (always 5 elements)

---

## 8. Key Code Locations

| File | Purpose | Lines of Interest |
|------|---------|-------------------|
| `Theories/Bimodal/Syntax/Formula.lean` | Formula inductive type | 70-86 (constructors) |
| `Theories/Bimodal/Automation/DataExport.lean` | Serialization primitives | 104-134 (toJson, prettyPrint) |
| `Theories/Bimodal/Automation/DatasetExport.lean` | JSONL pipeline | 157-219 (DatasetRecord, toJson) |
| `Theories/Bimodal/Automation/SuccessPatterns.lean` | PatternKey type | 95-121 (PatternKey, fromFormula) |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | Labeling pipeline | 100-114 (LabeledFormula) |
| `lakefile.lean` | Build target | 37-39 (dataset_generator exe) |

---

## 9. Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| String concatenation performance at scale | Low | Existing pattern works; Lean's `String` is efficient |
| Token vocabulary collision with atom names | Low | Atoms are prefixed with `ATOM` token |
| GNN adjacency list stateful traversal complexity | Medium | Can defer to Phase 5; nested JSON is sufficient |
| Breaking existing JSONL consumers | Low | New fields are additive; existing fields unchanged |
| Build time increase from new definitions | Very Low | ~100 lines of pure functions |

---

## 10. Summary of Recommendations

1. **Add `Formula.toSExpr`** to DataExport.lean -- simple recursive S-expression printer
2. **Add `Formula.tokenize`** to DataExport.lean -- prefix-notation token list
3. **Add `PatternKey.toFeatureVector`** and `GoalCategory.toNat` to DataExport.lean -- numeric feature export
4. **Extend `DatasetRecord`** with three new fields: `formula_sexpr`, `formula_tokens`, `pattern_features`
5. **Defer GNN adjacency list** to optional Phase 5 (existing `formula_ast` already serves GNN needs)
6. **Do not duplicate `pattern_key`** -- it is already exported; only add the numeric vector variant
7. All new code follows existing patterns (string concatenation, recursive traversal, no external dependencies)
