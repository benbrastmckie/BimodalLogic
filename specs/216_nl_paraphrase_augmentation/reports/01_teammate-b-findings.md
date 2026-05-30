# Teammate B Findings: Alternative Approaches & Prior Art

**Task**: 216 — Natural-language paraphrase augmentation for bmlogic-bench
**Angle**: Alternative patterns, prior art, schema design, integration
**Date**: 2026-05-29

---

## Key Findings

### 1. Directly Relevant Benchmarks and Datasets

**ModalLogicBench** (2025, Springer): Evaluates LLM inference on 20 modal logic rules across systems K, T, S4, S5. Uses template-based verbalization of modal formulas into NL. Directly relevant since bmlogic-bench uses S5 modal logic, though ModalLogicBench lacks temporal operators.

**NL2TL** (Chen et al., 2023): 28K NL-LTL pairs created via LLM + human annotation pipeline. Fine-tuned T5 models achieve >95% translation accuracy with <10% training data. Demonstrates the *reverse* direction (NL → LTL) is tractable, implying the forward direction (LTL → NL) should also be feasible. Covers temporal Until/Eventually/Always/Next but not S5 modal operators.

**VLTL-Bench** (2025): 32K NL-LTL pairs across 4 scenario domains (kitchen, warehouse, traffic, search-and-rescue). Uses **43 expert-crafted template patterns** with systematic atomic proposition substitution and morphological fixes. Schema includes both "lifted" (abstract) and "grounded" (concrete) versions of NL — a pattern worth adopting.

**FOLIO** (Yale-LILY, 2024 EMNLP): 1,430 NL-FOL pairs, human-written by CS students. Each record has parallel NL premises/conclusions + FOL annotations. The gold standard for NL-logic pairing quality, but FOL-only (no modal/temporal).

**FOL2NS** (2025): Neurosymbolic pipeline for FOL → NL using fine-tuned T5-large. Uses CFG-based formula generation + lexicalization + neural verbalization. Achieved BLEU 0.67 on generated NL. Key limitation: struggles with deeply nested formulas (>50% failure on complex nesting), directly relevant to our depth >= 3 challenge.

**LogicBench** (2024): Uses GPT-3.5 to convert templatized logic into story-based NL narratives. Two-step: formal template → narrative enhancement. Covers propositional and FOL but not modal/temporal.

### 2. Formula Verbalization Approaches (Alternatives to Pure Rule-Based)

#### A. Neurosymbolic Pipeline (FOL2NS pattern)
- **Approach**: CFG generates formula → lexicalize with domain terms → fine-tune T5 for final NL
- **Pros**: Systematic, reproducible, handles combinatorial explosion
- **Cons**: T5 struggles with nesting depth > 4; needs training data
- **Relevance**: Could adapt for depth >= 3 formulas as an alternative to pure LLM few-shot

#### B. Hybrid Template + LLM Refinement
- **Approach**: Rule-based generates rigid template NL → LLM polishes for fluency
- **Pros**: Preserves logical fidelity (template ensures correctness), LLM adds naturalness
- **Cons**: Risk of LLM introducing semantic drift during polishing
- **Relevance**: Best fit for this project. Templates handle the structural correctness; LLM smooths "if it is the case that q holds at all times strictly between the current time and some future time at which r holds, then p" into more readable English

#### C. Few-Shot LLM Prompting (direct)
- **Approach**: Provide 10-20 formula → NL examples, ask LLM to generate for new formulas
- **Pros**: Fast, no training needed, good for small batches
- **Cons**: Inconsistent quality, requires human verification, risk of logical errors
- **Relevance**: Viable for the 92 depth >= 3 formulas, but needs careful prompt engineering

#### D. Controlled Natural Language (ACE-style)
- **Approach**: Define a formal grammar that maps to both logic and restricted English
- **Pros**: Provably correct bidirectional mapping; machine-verifiable
- **Cons**: Produces stilted "specification English" rather than natural paraphrases; no existing ACE extension for temporal Until/Since operators
- **Relevance**: Useful as a *verification layer* (generate ACE, check it parses back to the same formula) rather than as the primary output

### 3. Schema Design Alternatives

#### Option A: Single Paraphrase (Minimal)
```json
{
  "nl_paraphrase": "If q holds until r, then p",
  "nl_paraphrase_method": "rule_based"
}
```
- **Pros**: Simple, backward-compatible, matches task description
- **Cons**: Single register, no diversity for training

#### Option B: Multi-Variant with Register Levels
```json
{
  "nl_paraphrase": "If q holds until r, then p",
  "nl_paraphrase_formal": "It is the case that p, given that q persists until the occurrence of r",
  "nl_paraphrase_colloquial": "Assuming q keeps being true up to when r happens, p must hold",
  "nl_paraphrase_method": "rule_based"
}
```
- **Pros**: Richer training signal, supports diverse NLI evaluation
- **Cons**: 3x annotation effort, schema bloat, harder to maintain consistency

#### Option C: Array of Paraphrases (FOLIO-inspired)
```json
{
  "nl_paraphrases": [
    {"text": "If q holds until r, then p", "register": "formal", "method": "rule_based"},
    {"text": "Assuming q keeps going until r happens, p follows", "register": "informal", "method": "llm_assisted"}
  ],
  "nl_paraphrase_method": "mixed"
}
```
- **Pros**: Extensible, each variant tracks its own method, future-proof
- **Cons**: Complex schema, harder to consume downstream, overkill for v1

#### Option D: Lifted + Grounded (VLTL-Bench-inspired)
```json
{
  "nl_paraphrase": "If q holds until r, then p",
  "nl_paraphrase_lifted": "If [guard] holds until [event], then [conclusion]",
  "nl_paraphrase_method": "rule_based"
}
```
- **Pros**: "Lifted" version reveals the template structure, useful for template debugging
- **Cons**: Adds a field that mainly serves tooling, not end users

**Recommendation**: Start with **Option A** for v1 (matches the task description exactly), but structure the generation code to support Option C in the future. The `nl_paraphrase_method` field already provides extensibility.

### 4. Integration Patterns & Backward Compatibility

**HuggingFace best practice for adding optional fields to JSONL**:
- Adding an optional field with null default is backward compatible
- Old consumers that don't reference the field continue working
- Use `on_mixed_types="use_json"` for mixed schemas during transition
- Never remove or rename existing fields; deprecate first

**For this project specifically**:
- The existing `validate_datasets.py` defines `BENCHMARK_FIELDS` as a fixed set — must be updated to include new fields
- The `hf-dataset/validate.py` has `REQUIRED_FIELDS` — new fields should NOT be in this list (they're optional)
- The `bmlogic-bench_metadata.json` schema_version should bump from "1.0" to "1.1"
- The `croissant.json` MLCommons metadata needs updating to document new fields

**Concrete integration checklist**:
1. Add `nl_paraphrase` and `nl_paraphrase_method` to `BENCHMARK_FIELDS` in `validate_datasets.py`
2. Do NOT add them to `REQUIRED_FIELDS` in `hf-dataset/validate.py`
3. Bump `schema_version` in `bmlogic-bench_metadata.json` to "1.1"
4. Update `croissant.json` field descriptions
5. Update `data/README.md` schema documentation
6. Update `data/dataset-card.md` with new field documentation

### 5. Existing Infrastructure Assessment

**AST structure**: 6 node tags found: `atom`, `bot`, `box`, `imp`, `snce`, `untl`. This is a clean, small set — a rule-based verbalizer only needs to handle 6 cases plus derived operators (neg, and, or, diamond, F, P, G, H, etc. which are expressible as combinations of primitives).

**Depth distribution**: 87.3% at depth <= 2, 12.7% at depth >= 3. The rule-based approach covers the vast majority.

**No existing NL generation code**: No files reference paraphrase/verbalize/nl_ in the data scripts. This is a greenfield implementation.

**Formula string representation**: Uses standard Unicode notation (`□`, `U(·,·)`, `S(·,·)`, `→`, `⊥`). The AST JSON provides a clean recursive structure for tree-walking verbalization.

---

## Recommended Approach

**Hybrid template + LLM refinement** (Approach B above), structured as:

1. **Phase 1**: Build a recursive AST-walking verbalizer in Python that handles all 6 primitive tags + derived operators via pattern matching. This handles depth <= 2 (635 records) with deterministic, verifiable output.

2. **Phase 2**: For depth >= 3 (92 records), use the rule-based verbalizer as a *scaffold*, then pass the output to an LLM with a refinement prompt: "Improve the readability of this logical paraphrase while preserving its exact meaning: [template output]". Human-verify each result.

3. **Schema**: Option A (single `nl_paraphrase` + `nl_paraphrase_method`), with generation code structured to support future multi-variant extension.

4. **Verification**: For rule-based outputs, implement a round-trip check: parse the NL back through a simplified grammar to verify it maps to the same AST structure. For LLM-refined outputs, use human verification.

This approach is supported by the FOL2NS finding that neural models struggle at depth > 4 (our max depth is 4), and the VLTL-Bench finding that expert-crafted templates with systematic substitution produces high-quality NL at scale.

---

## Evidence/Examples

### Example Verbalizations by Depth

**Depth 0** (pure propositional, 97 records):
- Formula: `((r → (r → r)) → ⊥)`
- Template NL: "If r implies that r implies r, then a contradiction follows"
- Refined NL: "It is contradictory that if r then r implies r"

**Depth 1** (one modal or temporal operator, 296 records):
- Formula: `(⊥ → U(q, □r))`
- Template NL: "If a contradiction holds, then r is necessarily true at all times until q occurs"
- Note: Ex falso — any paraphrase should note this is trivially valid

**Depth 2** (two operators, 242 records):
- Formula: `((U(r, q) → p) → p)`
- Template NL: "If the fact that q holds until r implies p, then p"

**Depth 3+ (complex nesting, 92 records)**: These require LLM refinement to avoid deeply nested "that"-clauses.

### Comparable Dataset Scales

| Dataset | Records | NL Method | Domain |
|---------|---------|-----------|--------|
| FOLIO | 1,430 | Human-written | FOL |
| NL2TL | 28,000 | LLM + human | LTL |
| VLTL-Bench | 32,080 | Template-based | LTL |
| FOL2NS | 3,625 train + 3,071 test | Hybrid (CFG + T5) | FOL |
| **bmlogic-bench** | **727** | **Proposed: hybrid** | **S5 + LTL** |

Our 727 records is very manageable — far smaller than comparable datasets. Even full human review of all 727 paraphrases is feasible.

---

## Confidence Level

- **Schema design**: **High** — Option A is clearly the right v1 choice, with good precedent
- **Rule-based for depth <= 2**: **High** — the 6-tag AST is simple and well-structured
- **LLM refinement for depth >= 3**: **Medium** — FOL2NS shows neural models struggle at high nesting, but our max depth is only 4 and the count (92) is small enough for human verification
- **Integration patterns**: **High** — the existing validation scripts are well-structured and the changes needed are clearly scoped
- **Prior art relevance**: **Medium** — no existing dataset combines S5 modal + temporal Until/Since, so this would be a novel contribution; prior art guides methodology but doesn't provide direct reuse

---

## References

- [FOLIO: Natural Language Reasoning with First-Order Logic](https://arxiv.org/abs/2209.00840) (Han et al., 2024 EMNLP)
- [FOL2NS: Generating Natural Sentences from First-Order Logic](https://arxiv.org/html/2605.18155) (2025)
- [NL2TL: Transforming Natural Languages to Temporal Logics using LLMs](https://arxiv.org/abs/2305.07766) (Chen et al., 2023)
- [VLTL-Bench: Verifiable NL to LTL Translation Benchmark](https://arxiv.org/abs/2507.00877) (2025)
- [ModalLogicBench: Modal Logic Reasoning Abilities of LLMs](https://link.springer.com/chapter/10.1007/978-981-95-0014-7_2) (2025)
- [LogicBench: Systematic Evaluation of Logical Reasoning](https://arxiv.org/html/2404.15522v2) (2024)
- [Attempto Controlled English (ACE)](https://www.researchgate.net/publication/220483487_Attempto_Controlled_English_ACE)
- [Backward Compatibility in Schema Evolution](https://www.dataexpert.io/blog/backward-compatibility-schema-evolution-guide)
- [Toward Generating NL Explanations of Modal-Logic Proofs](https://link.springer.com/chapter/10.1007/978-3-031-19907-3_21) (2022)
