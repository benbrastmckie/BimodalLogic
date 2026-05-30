# Teammate A Findings: Implementation Approaches for Formula-to-NL Translation

**Task**: 216 — Natural-language paraphrase augmentation for bmlogic-bench
**Angle**: Primary — Implementation approaches and patterns
**Date**: 2026-05-29

---

## Key Findings

### 1. Prior Art in Logic-to-NL Datasets

Several established datasets and approaches inform this task:

**FOLIO (Yale, 2022)**: Expert-written NL/FOL pairs for natural language reasoning. Uses human annotators to write natural language premises and their FOL translations. Key insight: they use abstract propositional variables ("A person is happy") not bare letters (p, q, r). This makes NL more natural but adds a semantic layer we may not want for a formal benchmark.

**LogicNLI (Tian et al., 2021)**: Generates NL from propositional logic using template-based synthesis. Assigns meanings to variables ("If it rains, then the ground is wet"). Uses controlled templates per connective. Most relevant pattern: they generate NL mechanically from logical structure using fixed templates per connective.

**ProofWriter (Allen AI, 2021)**: Generates logical reasoning chains with NL. Uses simple templates for each rule. Key pattern: keeps atoms abstract but wraps them in natural-sounding frames ("X is true" → "it is the case that X").

**Key lesson**: For a formal benchmark where the logic is the focus (not the NL reasoning), **keeping atoms abstract** (using p, q, r directly) with operator-specific templates is the standard approach. This preserves semantic faithfulness without introducing confounding natural language complexity.

### 2. AST Tag Distribution in bmlogic-bench

Analysis of all 727 records reveals the AST building blocks:

| Tag | Occurrences | Notes |
|-----|-------------|-------|
| `atom` | 1,965 | Base propositions (p, q, r) |
| `imp` | 1,432 | Most frequent operator |
| `bot` | 874 | Includes ⊥ in negation patterns |
| `box` | 543 | Modal necessity |
| `untl` | 402 | Temporal until |
| `snce` | 278 | Temporal since |

**Derived operator patterns detected**:
- Negation (φ → ⊥): 364 occurrences
- Top/verum (⊥ → ⊥, i.e., ¬⊥): 63 occurrences
- Eventually F(φ) = U(φ, ¬⊥): 53 occurrences
- Previously P(φ) = S(φ, ¬⊥): 8 occurrences
- ⊥ as guard in U/S (yielding next/yesterday X/Y operators): 108+93 occurrences

This means the rule-based translator must **recognize derived operators** from their primitive encodings to produce natural paraphrases (e.g., "eventually p" instead of "p until not-falsum").

### 3. Existing Repository Infrastructure

**Lean-side `prettyPrint`** (DataExport.lean:128-134): Already implements symbolic formula rendering:
```lean
def Formula.prettyPrint : Formula → String
  | .atom a   => a.base
  | .bot      => "⊥"
  | .imp φ ψ  => "(" ++ φ.prettyPrint ++ " → " ++ ψ.prettyPrint ++ ")"
  | .box φ    => "□" ++ φ.prettyPrint
  | .untl φ ψ => "U(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .snce φ ψ => "S(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
```

This is the model for a parallel `toNL` function, but NL generation should be done in Python as a post-processing step on the existing JSONL data (no Lean pipeline changes needed).

**Python tooling**: `data/scripts/generate_splits.py` handles JSONL processing. `data/hf-dataset/validate.py` validates field schemas. New `nl_paraphrase` field must integrate with this validation pipeline.

**DatasetExport.lean**: The `DatasetRecord` struct (line ~155) defines the JSONL schema. Adding `nl_paraphrase` to the Lean struct is optional but recommended for future regeneration consistency.

### 4. Recommended AST Walker Design

A recursive Python function operating on the `formula_ast` JSON:

```python
def to_nl(node, depth=0):
    tag = node["tag"]
    
    # Atoms
    if tag == "atom":
        return node["name"]
    
    # Bottom
    if tag == "bot":
        return "falsum"
    
    # Derived operators (check BEFORE primitives)
    if tag == "imp":
        # Negation: φ → ⊥
        if node["right"]["tag"] == "bot":
            inner = to_nl(node["left"], depth+1)
            return f"it is not the case that {inner}"
        # Top: ⊥ → ⊥ (¬⊥)
        if node["left"]["tag"] == "bot" and node["right"]["tag"] == "bot":
            return "a tautology"  # or just "truth"
    
    if tag == "untl":
        # Eventually: U(φ, ¬⊥)
        if is_top(node["guard"]):
            return f"eventually, {to_nl(node['event'], depth+1)}"
        # Next: U(φ, ⊥)
        if node["guard"]["tag"] == "bot":
            return f"at the next moment, {to_nl(node['event'], depth+1)}"
    
    if tag == "snce":
        # Previously: S(φ, ¬⊥)
        if is_top(node["guard"]):
            return f"at some past time, {to_nl(node['event'], depth+1)}"
        # Yesterday: S(φ, ⊥)
        if node["guard"]["tag"] == "bot":
            return f"at the previous moment, {to_nl(node['event'], depth+1)}"
    
    # Primitive operators
    if tag == "imp":
        left = to_nl(node["left"], depth+1)
        right = to_nl(node["right"], depth+1)
        return f"if {left}, then {right}"
    
    if tag == "box":
        inner = to_nl(node["child"], depth+1)
        return f"necessarily, {inner}"
    
    if tag == "untl":
        event = to_nl(node["event"], depth+1)
        guard = to_nl(node["guard"], depth+1)
        return f"{guard} until {event}"
    
    if tag == "snce":
        event = to_nl(node["event"], depth+1)
        guard = to_nl(node["guard"], depth+1)
        return f"{guard} since {event}"
```

**Key design decisions**:

1. **Derived operator detection first**: Check for negation (→⊥), top (⊥→⊥), eventually (U with ¬⊥ guard), etc. before falling through to primitive templates.

2. **Depth-aware smoothing**: At depth 0, use full templates. At depth > 1, use shorter forms to avoid "if it is not the case that necessarily eventually p, then...".

3. **Parenthetical disambiguation**: Use commas and clause structure rather than literal parentheses: "if A, then B" not "(if A then B)".

4. **Operator precedence in NL**: Modal > temporal > propositional, matching the natural reading order.

### 5. Template Table

| AST Pattern | NL Template | Example |
|-------------|-------------|---------|
| `atom(p)` | `p` | "p" |
| `bot` | `falsum` | "falsum" |
| `imp(φ, ψ)` | `if {φ}, then {ψ}` | "if p, then q" |
| `imp(φ, bot)` [negation] | `it is not the case that {φ}` | "it is not the case that p" |
| `imp(bot, ψ)` [ex falso] | `if falsum, then {ψ}` | "if falsum, then p" |
| `box(φ)` | `necessarily, {φ}` | "necessarily, p" |
| `box(imp(φ,bot))` [◇] | `possibly, {φ}` | "possibly, p" (via ¬□¬) |
| `untl(ev, gd)` | `{gd} until {ev}` | "q until r" |
| `untl(ev, ¬⊥)` [F] | `eventually, {ev}` | "eventually, p" |
| `untl(ev, ⊥)` [X] | `at the next moment, {ev}` | "at the next moment, p" |
| `snce(ev, gd)` | `{gd} since {ev}` | "q since r" |
| `snce(ev, ¬⊥)` [P] | `at some past time, {ev}` | "at some past time, p" |
| `snce(ev, ⊥)` [Y] | `at the previous moment, {ev}` | "at the previous moment, p" |

**Compound derived operators** (require multi-level pattern matching):

| Pattern | Derived Op | NL Template |
|---------|-----------|-------------|
| `imp(untl(imp(φ,bot), ¬⊥), bot)` | G(φ) = ¬F¬φ | `it is always going to be that {φ}` |
| `imp(snce(imp(φ,bot), ¬⊥), bot)` | H(φ) = ¬P¬φ | `it has always been that {φ}` |

### 6. Quality Metrics

Standard metrics for NL generation from logical formulas:

| Metric | How to Evaluate | Priority |
|--------|----------------|----------|
| **Faithfulness** | Manual review: does NL preserve logical meaning? | Critical |
| **Grammaticality** | Automated grammar check + human spot-check | High |
| **Readability** | Flesch-Kincaid + human rating on 1-5 scale | Medium |
| **Consistency** | Same subformula → same NL across records | High |
| **Invertibility** | Can a reader reconstruct the formula from NL? | Medium |

For rule-based generation at depth ≤ 2, **faithfulness and consistency are automatic** (same AST → same NL). The main quality concern is grammaticality of nested templates.

---

## Recommended Approach

1. **Python post-processing script** (`data/scripts/generate_paraphrases.py`):
   - Read `bmlogic-bench.jsonl`
   - Parse each `formula_ast` JSON
   - Run recursive AST walker with derived-operator detection
   - Add `nl_paraphrase` and `nl_paraphrase_method` fields
   - Write augmented JSONL

2. **Two-pass generation**:
   - **Pass 1 (rule-based)**: Process all 727 records. For depth ≤ 2, mark method as `"rule_based"`. For depth ≥ 3, generate a "raw" template-based version and mark as `"rule_based_draft"`.
   - **Pass 2 (LLM-assisted)**: For depth ≥ 3 records (92 records), use the raw template output as a starting point for LLM smoothing. Mark as `"llm_assisted"`. Human verification of these 92 records.

3. **Derived operator recognition order** (critical for quality):
   - First: compound patterns (G, H, ◇, △, ▽)
   - Then: simple derived (¬, F, P, X, Y)
   - Finally: primitives (→, □, U, S)

4. **Integration**:
   - Update `data/hf-dataset/validate.py` to check new fields
   - Add `nl_paraphrase` as optional field (backward-compatible)
   - Update `bmlogic-bench_metadata.json` schema

---

## Evidence/Examples

Applying the template approach to actual benchmark records:

**Record 1**: `((U(r, q) → p) → p)` (depth 0+1=1)
→ "if (if q until r, then p), then p"
→ Smoothed: "if q until r implies p, then p"

**Record 2**: `(⊥ → U(q, □r))` (depth 1+1=2)
→ "if falsum, then (necessarily, r) until q"

**Record 3**: `((r → (r → r)) → ⊥)` (depth 0+0=0)
→ "it is not the case that (if r, then (if r, then r))"

**Record with ◇**: `□□p → □p` (depth 2+0=2)
→ "if necessarily, necessarily, p, then necessarily, p"

These examples show the template approach works well for depth ≤ 2, producing readable (if somewhat formal) English.

---

## Confidence Level

**High** for the overall approach (rule-based AST walker with derived operator detection). This is a well-understood pattern with clear prior art.

**Medium** for the specific template wording — the exact phrasing choices (e.g., "it is not the case that" vs "not") need iteration and review. The Until/Since operator phrasing ("guard until event" vs "event, with guard holding in the interim") needs careful consideration of the formal semantics.

**High** for Python implementation path — the existing infrastructure strongly supports this approach with minimal changes to the Lean pipeline.
