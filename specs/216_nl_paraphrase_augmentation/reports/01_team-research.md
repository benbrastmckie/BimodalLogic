# Research Report: Task #216

**Task**: Natural-language paraphrase augmentation for bmlogic-bench
**Date**: 2026-05-29
**Mode**: Team Research (4 teammates)

## Summary

This research investigated approaches for adding natural-language paraphrases to all 727 bmlogic-bench records. The team converges on a **hybrid template + LLM refinement** approach: a recursive Python AST-walker with derived-operator detection handles depth ≤ 2 formulas (87.3%, 635 records) rule-based, while an LLM-assisted pipeline with human verification handles depth ≥ 3 (12.7%, 92 records). The schema adds two backward-compatible optional fields (`nl_paraphrase`, `nl_paraphrase_method`). Several important design decisions were surfaced that must be resolved before implementation: Until/Since phrasing, variable naming convention, and derived operator detection strategy.

---

## Key Findings

### Primary Approach (from Teammate A)

**Recursive AST walker in Python** operating on the existing `formula_ast` JSON field. The walker must detect derived operators (¬, F, G, P, H, ◇, X, Y) from their primitive AST encodings before applying NL templates.

Key infrastructure findings:
- **6 primitive AST tags**: `atom`, `bot`, `imp`, `box`, `untl`, `snce` — clean and complete
- **Derived operators are mandatory to detect**: 364 negation patterns, 53 eventually patterns, 63 top (¬⊥) patterns exist in the data. Without detection, even simple formulas like G(p) produce incomprehensible output.
- **Existing `Formula.prettyPrint`** in `DataExport.lean:128-134` provides the model for the NL walker's structure, but NL generation should be Python post-processing.
- **Template table proposed** for all primitive and derived operators with depth-aware smoothing.

Confidence: **High** for overall approach, **Medium** for specific template wording.

### Alternative Approaches (from Teammate B)

**Prior art survey** identified 6 directly relevant datasets/benchmarks:

| Dataset | Records | Method | Domain | Key Insight |
|---------|---------|--------|--------|-------------|
| VLTL-Bench | 32,080 | 43 expert templates | LTL | Template-based at scale works |
| NL2TL | 28,000 | LLM + human | LTL | Reverse direction (NL→LTL) achieves >95% |
| FOLIO | 1,430 | Human-written | FOL | Gold standard for quality |
| FOL2NS | 6,696 | CFG + T5 | FOL | Neural models struggle at depth > 4 |
| ModalLogicBench | ~200 | Templates | Modal (S5) | Directly relevant modal templates |
| LogicBench | 3,000+ | GPT-3.5 | Prop+FOL | Template → narrative enhancement |

**No existing dataset covers S5 modal + temporal Until/Since** — this would be a novel contribution.

**Four alternative approaches evaluated**:
1. **Neurosymbolic pipeline** (CFG + T5): Systematic but needs training data, struggles at depth > 4
2. **Hybrid template + LLM refinement** ← **Recommended**: Templates ensure structural correctness, LLM adds naturalness
3. **Few-shot LLM prompting**: Fast but inconsistent, viable for the 92 depth ≥ 3 records
4. **Controlled Natural Language (ACE)**: Useful as verification layer, not primary output

**Schema recommendation**: Option A (single `nl_paraphrase` + `nl_paraphrase_method`) for v1, with code structured for future multi-variant extension.

Confidence: **High** for schema and approach, **Medium** for prior art reuse (novel domain).

### Gaps and Shortcomings (from Critic)

**Critical semantic faithfulness issues identified**:

1. **Until/Since operator gap**: English "until" is ambiguous about strictness, endpoint inclusion, and guard holding at intermediates. The formal semantics (strict future witness, open-interval guard) has no natural English equivalent. Template phrasing must be explicitly chosen — this is the single hardest design decision.

2. **Derived operator detection is non-optional**: The task description doesn't mention this, but without it, even depth-0 formulas produce bad NL (e.g., G(p) encoded as `imp(untl(imp(p,bot), imp(bot,bot)), bot)` would produce "it is not the case that not-p until not-falsum").

3. **Depth threshold may be insufficient**: 152 records have depth ≤ 2 but impCount ≥ 3. Some (impCount ≥ 5, ~20 records) produce deeply nested NL that is barely readable despite low modal/temporal depth.

4. **Acceptance criteria gaps**:
   - No definition of "grammatically correct" (automated vs. human)
   - No spot-check protocol (sample size, stratification)
   - No semantic equivalence verification method
   - No resolution of multiple valid readings for the same formula

5. **Variable naming unresolved**: Abstract (p, q, r) vs. assigned meanings vs. semi-formal ("proposition p holds"). For a formal benchmark, abstract is almost certainly correct but should be explicit.

6. **⊥ handling pervasive**: 465 records (64%) contain ⊥ in various structural roles (negation, ex falso, derived operators). The NL handling of ⊥ affects the majority of paraphrases.

Confidence: **High** that these gaps must be addressed before implementation.

### Strategic Horizons (from Teammate D)

**Strategic alignment**: NL paraphrases primarily serve the ML training pipeline but position the project for a **bimodal NLI benchmark** — a unique niche with no existing competition.

**Phased extension opportunity**:
- Phase 1 (this task): bmlogic-bench (727 records)
- Phase 2: Extend to bmlogic-c5 (1,513) and bmlogic-c7 (49,904) — ~50K NL-annotated examples
- Phase 3: Proof explanation generation using proof_trace/countermodel fields
- Phase 4: Benchmark suite submission (BIG-bench, HELM, or standalone)

**Integration recommendations**:
- Generator at `data/scripts/generate_paraphrases.py` (follows existing pattern)
- Do NOT integrate into Lean (keep as Python post-processing)
- Do NOT generate multiple paraphrases per formula in v1
- Do NOT attempt internationalization or contrastive explanations yet

Confidence: **High** for strategic framing, **Medium** for benchmark suite inclusion.

---

## Synthesis

### Conflicts Resolved

1. **Depth threshold adequacy**: Teammate A accepted depth ≤ 2 as sufficient; Teammate C argued for complexity-based cutoff (complexity ≤ 9 AND impCount ≤ 3). **Resolution**: Keep depth ≤ 2 as the primary threshold (it's what the task specifies and covers 87.3%), but add a **secondary flag** for high-impCount records within the rule-based set. Records with depth ≤ 2 but impCount ≥ 5 (~20 records) should receive automated quality review and may be escalated to LLM-assisted if template output is unreadable. This preserves the simple boundary while addressing the critic's valid concern.

2. **Schema complexity**: Teammate B presented 4 schema options (A through D); Teammate D recommended minimal approach. **Resolution**: Option A (single `nl_paraphrase` + `nl_paraphrase_method`) for v1 is unanimous. The generation code should use a function signature that returns a list (enabling future multi-variant), but the JSONL output stores only one.

3. **Lean vs. Python implementation**: Teammate A noted Lean-side `prettyPrint` as a model; Teammate D argued against Lean integration. **Resolution**: Python post-processing is correct. No changes to Lean pipeline. The `prettyPrint` pattern informs the Python walker's structure but the implementation is entirely in `data/scripts/`.

### Gaps Identified

1. **Until/Since phrasing**: No teammate produced a definitive English rendering that is both faithful and readable. This must be resolved in the planning phase with explicit examples and user review before implementation.

2. **Round-trip verification**: Teammates B and D both suggested NL → AST round-trip checking, but no implementation path was proposed. This requires building a simple NL parser for the template grammar — feasible for rule-based outputs but non-trivial.

3. **LLM pipeline specifics**: The 92 depth ≥ 3 records need LLM-assisted generation, but no specific model, prompt template, or verification protocol was proposed. This needs planning-phase attention.

4. **Bimodal interaction formulas**: 239 records (33%) mix modal and temporal operators. These are within the rule-based threshold (many are depth 2) but the NL is particularly challenging. No teammate proposed a specific template strategy for bimodal nesting.

5. **Conjunction/disjunction detection**: ∧ = `imp(imp(φ, imp(ψ, bot)), bot)` and ∨ = `imp(imp(φ, bot), ψ)` are 3-level and 2-level patterns respectively. Teammate C noted this but no teammate proposed detection logic. These derived operators are important for readable NL.

### Recommendations

1. **Resolve design decisions BEFORE implementation**:
   - Variable naming: use abstract (p, q, r) directly
   - Until phrasing: propose 2-3 candidates, get user feedback
   - ⊥ handling: define rendering for each structural position
   - Acceptance criteria: define grammar check method and spot-check protocol

2. **Implementation order**:
   - Step 1: Derived operator detector (pattern match AST for all 8+ derived operators)
   - Step 2: Template table with depth-aware smoothing
   - Step 3: Rule-based generator for depth ≤ 2
   - Step 4: Quality review of rule-based output (automated + sample human review)
   - Step 5: LLM-assisted pipeline for depth ≥ 3
   - Step 6: Integration (validate.py, metadata, README updates)

3. **Quality validation approach**: Automated grammar check (LanguageTool) for all records. Semantic faithfulness spot-check of 30% sample stratified by operator type. Full human review of all 92 LLM-assisted records.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary implementation approach | completed | high |
| B | Alternative approaches & prior art | completed | high |
| C | Critic — gaps and blind spots | completed | high |
| D | Strategic horizons | completed | high |

---

## References

- [FOLIO: Natural Language Reasoning with First-Order Logic](https://arxiv.org/abs/2209.00840) (Han et al., 2024)
- [FOL2NS: Generating Natural Sentences from FOL](https://arxiv.org/html/2605.18155) (2025)
- [NL2TL: Natural Languages to Temporal Logics using LLMs](https://arxiv.org/abs/2305.07766) (Chen et al., 2023)
- [VLTL-Bench: Verifiable NL to LTL Translation](https://arxiv.org/abs/2507.00877) (2025)
- [ModalLogicBench: Modal Logic Reasoning of LLMs](https://link.springer.com/chapter/10.1007/978-981-95-0014-7_2) (2025)
- [LogicBench: Systematic Evaluation of Logical Reasoning](https://arxiv.org/html/2404.15522v2) (2024)
- [Toward Generating NL Explanations of Modal-Logic Proofs](https://link.springer.com/chapter/10.1007/978-3-031-19907-3_21) (2022)
- Existing infrastructure: `DataExport.lean:128-134` (Formula.prettyPrint), `data/scripts/generate_splits.py`, `data/hf-dataset/validate.py`
