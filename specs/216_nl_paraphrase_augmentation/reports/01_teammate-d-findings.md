# Teammate D — Horizons: Strategic Direction for NL Paraphrase Augmentation

**Task**: 216 — Natural-language paraphrase augmentation for bmlogic-bench
**Date**: 2026-05-29
**Angle**: Long-term alignment, strategic opportunities, creative approaches

---

## Key Findings

### 1. Dual-Purpose Alignment: Formalization + ML Training

The BimodalLogic project serves two audiences simultaneously:
- **Formal logic community**: Sorry-free completeness proofs in Lean 4 for TM (tense + modality)
- **ML/AI community**: Training data for logical reasoning (bmlogic-c5/c7/bench, proof_steps)

NL paraphrases primarily serve the **ML training pipeline** but have secondary benefits for the formalization side:

- **ML training**: Enables NL→formula translation tasks (semantic parsing), formula→NL generation tasks, and NLI-style reasoning (does paraphrase A entail paraphrase B?). These are standard benchmark task categories for inclusion in suites like BIG-bench or HELM.
- **Formalization**: Natural-language readings in the README already document operator semantics (e.g., `□φ` → "necessarily φ", `U(φ,ψ)` → "ψ until φ"). NL paraphrases could be surfaced in Lean docstrings or proof explanations, but this is a secondary benefit.
- **Educational**: An NL-annotated benchmark enables non-logicians to understand what the formulas mean, lowering the barrier to contributing and evaluating.

### 2. Existing Infrastructure Supports Rule-Based Generation

The project already has the ingredients for compositional NL generation:

- **Operator readings**: The README defines readings for all 5 primitives and 8 derived operators. These are compositional — each operator has a fixed English template.
- **Formula AST**: Every record in bmlogic-bench.jsonl has a `formula_ast` field with tagged nodes (`imp`, `box`, `untl`, `snce`, `bot`, `atom`). This is a clean recursive structure perfect for template-based traversal.
- **Depth metrics**: `pattern_key.modalDepth` and `pattern_key.temporalDepth` are already computed. The 87%/13% depth split (≤2 vs ≥3) is well-characterized.
- **Dataset generation pipeline**: The Lean executables (`dataset_generator`, `benchmark_oracle`) already produce structured output. NL generation could be added as a post-processing step in Python (matching the existing `scripts/` pattern) or as a Lean-side `toString`/`toEnglish` method.

### 3. Benchmark Is the Right Starting Point, But Training Data Is the Prize

- **bmlogic-bench (727 records)**: Right size for a pilot with quality control. The stratified design (340 valid, 387 invalid) and known depth distribution make it ideal for validation.
- **bmlogic-c5 (1,513 records)**: All ≤ complexity 5, so likely all ≤ depth 2. Could be entirely rule-based. ~2x the benchmark size, modest effort.
- **bmlogic-c7 (49,904 records)**: The real value. If the rule-based generator works for depth ≤ 2 and the LLM pipeline works for depth ≥ 3, this would produce ~50K NL-annotated logic examples — a significant training resource.
- **proof_steps (2,424 records)**: Different schema (proof steps, not formulas). NL annotation here would produce step-by-step proof explanations. Higher value but different task.

**Recommendation**: Start with bmlogic-bench, validate the approach, then extend to c5 and c7. proof_steps is a separate task.

### 4. Strategic Positioning Opportunities

#### 4a. Bimodal NLI Benchmark
With NL paraphrases + valid/invalid labels, the benchmark naturally supports:
- **NLI format**: Given paraphrase of φ, is φ valid? (binary classification from NL)
- **Semantic parsing**: Given NL, produce the formula (generation task)
- **Formula verification**: Given formula + NL, do they match? (cross-modal matching)

This is a **unique niche** — no existing benchmark covers tense+modality NLI with formal verification backing. ProofWriter, FOLIO, and LogicNLI focus on first-order or propositional logic.

#### 4b. Inclusion in Benchmark Suites
For BIG-bench/HELM inclusion, the key requirements are:
- Machine-readable format (already have JSONL + Croissant metadata)
- NL task descriptions (NL paraphrases would provide these)
- Multiple task variants (classification, generation, entailment)
- Size (727 for bench, 50K+ for training — adequate)

#### 4c. Countermodel and Proof Trace Explanations
The benchmark already has `proof_trace` (for valid) and `countermodel` (for invalid). These could generate **explanations**:
- Valid: "This formula is a theorem because it follows from ex_falso (anything follows from a contradiction)"
- Invalid: "This formula is not valid; a counterexample assigns p to false at the base state"

This is a natural extension of NL paraphrases but is a distinct, more complex task.

### 5. Scope and Phasing Recommendation

The task description's scope (benchmark only, rule-based + LLM-assisted) is well-calibrated for a first pass. Strategic considerations suggest:

**Phase 1 (this task)**: NL paraphrases for bmlogic-bench (727 records)
- Rule-based for depth ≤ 2 (~635 records, 87%)
- LLM-assisted for depth ≥ 3 (~92 records, 13%)
- Validate quality, establish the template grammar

**Phase 2 (follow-on)**: Extend to bmlogic-c5 and bmlogic-c7
- Reuse the rule-based generator (should cover most of c5)
- Scale the LLM pipeline for c7's depth ≥ 3 records

**Phase 3 (follow-on)**: Proof explanation generation
- Use proof_trace and countermodel to generate explanations
- Different task structure; separate from paraphrasing

**Phase 4 (follow-on)**: Benchmark suite submission
- Package as multi-task NLI benchmark
- Submit to BIG-bench, LM Eval Harness, or standalone

---

## Recommended Approach

### Strategic Framing

Position the NL paraphrases as the first step toward a **bimodal NLI benchmark suite** — not just an annotation task. This frames the work as building toward a published benchmark contribution alongside the completeness paper.

### Technical Integration

1. **Generator location**: `data/scripts/generate_paraphrases.py` (follows existing `data/scripts/` pattern)
2. **Output format**: Add `nl_paraphrase` and `nl_paraphrase_method` fields to each JSONL record (backward-compatible, optional fields as specified)
3. **Template grammar**: Build compositional templates from the README's operator readings, with disambiguation for nested structures
4. **Quality validation**: Automated round-trip check (NL → AST → NL should produce equivalent paraphrase) for rule-based outputs

### What NOT to Do

- **Don't integrate into Lean**: The NL generation is a Python post-processing step, not a Lean-side feature. Adding `toEnglish` to Formula would couple the Lean formalization to NL concerns.
- **Don't generate multiple paraphrases per formula yet**: One canonical paraphrase per formula is sufficient for Phase 1. Multiple paraphrases (varying register, formality, abstraction level) are a Phase 2 enhancement.
- **Don't attempt internationalization**: English-only is appropriate for a research benchmark. Multi-language paraphrases are an interesting but premature extension.
- **Don't generate contrastive explanations yet**: "φ claims X, but actually Y" requires understanding countermodels, which is Phase 3 work.

---

## Evidence/Examples

### Rule-Based Template Coverage

For depth ≤ 2 formulas, compositional templates are straightforward:

| Formula | Depth | Template-Based Paraphrase |
|---------|-------|---------------------------|
| `((r → (r → r)) → ⊥)` | 0 | "It is absurd that if r then if r then r." |
| `⊥` | 0 | "A contradiction." |
| `((U(r, q) → p) → p)` | 1 | "If q until r implies p, then p." |
| `(r → (U(q, r) → r))` | 1 | "If r, then if r until q then r." |
| `(⊥ → U(q, □r))` | 2 | "If a contradiction, then necessarily r until q." |

These demonstrate that compositional templates produce readable (if somewhat stilted) English for shallow formulas. The key challenge is **disambiguation of nesting** — "if A then if B then C" is ambiguous without careful punctuation or rephrasing.

### LLM-Assisted Needed for Depth ≥ 3

| Formula | Depth | Why Rule-Based Fails |
|---------|-------|---------------------|
| `U(q, □S(p, r))` | 3 | Triple nesting: "necessarily (r since p) until q" — grammatically awkward, semantically unclear |
| `U(□(U(...) → ⊥), □(...))` | 4 | Deeply nested: rule-based output is incomprehensible |

For these, an LLM can restructure the sentence, add clarifying phrases, and produce natural prose that a human reviewer can validate.

### Data Distribution (Verified)

```
Depth 0:  97 records (13.3%) — pure propositional, trivial templates
Depth 1: 296 records (40.7%) — single modal or temporal, straightforward
Depth 2: 242 records (33.3%) — two levels of nesting, manageable with care
Depth 3:  82 records (11.3%) — LLM-assisted recommended
Depth 4:  10 records ( 1.4%) — LLM-assisted required
```

Total rule-based coverage: 635 records (87.3%)
Total LLM-assisted: 92 records (12.7%)

---

## Confidence Level

**High** for strategic alignment assessment and technical integration recommendations.

The analysis is grounded in:
- Verified data distribution from the actual benchmark files
- Existing infrastructure (operator readings, formula AST, dataset pipeline)
- Clear alignment with the project's dual formalization + ML mission
- Well-established patterns in the NLI/semantic parsing benchmark space

**Medium** for benchmark suite positioning (BIG-bench/HELM inclusion depends on external acceptance criteria and community interest in bimodal logic specifically).

**Low** for proof explanation generation feasibility (Phase 3) — this requires deeper investigation of how proof_trace and countermodel structures map to English explanations.
